# Xonsh workstation migration implementation plan

## Purpose

Adopt Xonsh as the normal interactive terminal environment without making it a
system or project authority.

The target separates four roles:

```text
system/login compatibility   Bash
interactive terminal         Xonsh
project Python realization   uv + project .venv
system Python                OS-owned and untouched
```

The migration is deliberately reversible. Xonsh should be removable without
changing project semantics, login viability, or POSIX command execution.

## Target contract

```text
Arch / session
    |
    +-- login shell: /bin/bash
    |      `-- recovery + POSIX compatibility
    |
    +-- WezTerm
    |      `-- Xonsh
    |             +-- interactive Python
    |             +-- process composition
    |             +-- observation / inspection
    |             `-- uv-dispatched project commands
    |
    +-- uv
    |      +-- isolated Python for the Xonsh tool runtime
    |      `-- project Python environments
    |
    `-- /usr/bin/python
           `-- OS-owned; do not mutate for workstation tooling
```

Required invariants:

- Bash remains usable without Python or Xonsh.
- WezTerm opens Xonsh directly for normal interactive work.
- POSIX wrapper commands continue to execute through Bash.
- Existing XDG, PATH, session, and tool environment semantics survive the
  migration.
- The Python interpreter running Xonsh is independent of project interpreters.
- `uv run` remains the explicit project-execution boundary.
- Closing Xonsh loses no durable project semantics.
- Rollback requires changing only terminal/session realization, not project
  state.

## 1. Separate shell roles in terminal configuration

The current dotfiles shell helper treats the account shell as both:

```text
interactive terminal program
+
executor for `-lc` command wrappers
```

Split those responsibilities before changing the account shell.

Desired interface:

```text
login_shell()
    -> /bin/bash

interactive_shell()
    -> xonsh

interactive_args()
    -> { xonsh }

shell_cmd(command)
    -> { /bin/bash, -lc, command }
```

WezTerm should then use `interactive_args()` for `default_prog`, while helper
commands, titled commands, and existing POSIX shell snippets continue through
`bash -lc`.

Do not translate existing shell wrappers into Xonsh merely to complete the
migration. They are already valid POSIX realizations and should cross the shell
boundary explicitly.

## 2. Remove environment ownership from Zsh

The current dotfiles environment path is approximately:

```text
~/.zshenv
    -> $ZDOTDIR/.zshenv
        -> zload.zsh/loader.zsh
            -> env.zsh
```

The migration should preserve the environment contract while deleting Zsh as
its required interpreter.

Prefer:

```text
environment.d / session bootstrap
        |
        +-- Bash login projection
        +-- UWSM/systemd session projection
        `-- Xonsh projection
```

rather than:

```text
Zsh implementation
    -> translated Xonsh implementation
```

### Startup layout

Use a small POSIX login surface:

```text
~/.profile
    login/session-safe environment only

~/.bash_profile
    source ~/.profile

~/.bashrc
    minimal interactive fallback behavior
```

Use Xonsh XDG startup fragments for interactive behavior:

```text
~/.config/xonsh/rc.d/
    00-env.py
    10-shell.py
    20-integrations.xsh
```

`00-env.py` should only project the environment Xonsh needs, such as:

```text
XDG defaults
PATH prefixes
GOBIN
shared tool locations
shell cache/state locations
```

Avoid placing desktop-session ownership in interactive startup. If environment
state must be imported into systemd/dbus, prefer UWSM or another session
bootstrap boundary rather than every Xonsh process repeating the operation.

## 3. Install Xonsh through uv isolation

Do not install Xonsh into the OS Python environment.

Prototype realization:

```text
uv-managed CPython
    -> isolated uv tool environment
        -> xonsh
        -> prompt-toolkit support
        -> qualified xontrib dependencies
```

Use the repository/tooling baseline Python version unless an explicit Xonsh
compatibility evaluation justifies another version.

Conceptual bootstrap:

```bash
uv python install <baseline-python>
uv tool install --python <baseline-python> 'xonsh[full]'
```

Add xontribs with the same declarative uv tool installation rather than
mutating the tool environment manually with `pip` or `xpip`.

The exact Xonsh and xontrib versions should be pinned by the provisioning
surface once qualified; version numbers are realization data, not semantic
architecture.

### Post-install qualification

At minimum verify:

```bash
xonsh --no-rc
xonsh --version
xonfig info
```

Inside Xonsh:

```python
import sys
print(sys.executable)
```

Inside a uv project:

```bash
uv run python -c 'import sys; print(sys.executable)'
```

These interpreters may intentionally differ.

The useful boundary is:

```text
Xonsh Python
    persistent interactive runtime

uv project Python
    project execution runtime
```

## 4. Implement minimal Xonsh quality of life

Do not recreate the Zsh plugin stack one plugin at a time. First use native
Xonsh/prompt-toolkit capabilities and add extensions only for demonstrated
missing behavior.

Initial shell behavior should cover:

```text
prompt-toolkit interactive shell
vi editing mode
syntax highlighting
history suggestions/search
persistent history
autopair or equivalent basic editing aid
quiet startup
completion
```

Use an Xonsh-supported persistent history backend and retain approximately the
current history capacity unless observation shows a reason to change it.

Keep prompt customization minimal. Prompt state is not project state.

## 5. Restore only required integrations

Start with the integrations currently carrying operational value:

```text
zoxide
direnv
WezTerm shell integration
```

### zoxide

Preserve the existing zoxide data/state location and useful fzf options, but
initialize the Xonsh integration rather than sourcing the Zsh integration.

### direnv

Use a Xonsh-native integration/xontrib. Do not evaluate a generated Zsh hook
inside Xonsh.

Project environment semantics should still be owned by project files such as
`.envrc`, `pyproject.toml`, and `uv.lock`, not by shell startup.

### WezTerm

Use a Xonsh-compatible WezTerm/terminal integration for the features that are
actually required, especially:

```text
working-directory reporting
prompt zones
terminal user variables when used by current configuration
```

Do not add a theme framework, Starship, broad xontrib bundles, or compatibility
layers during the initial cutover.

## 6. Switch login and interactive realization

Only switch the account login shell after the environment projection and
interactive Xonsh startup both qualify.

Desired account shell:

```bash
chsh -s /bin/bash
```

Then start a fresh login session and verify:

```text
passwd shell
    -> /bin/bash

$SHELL
    -> /bin/bash

normal WezTerm pane
    -> xonsh
```

`$SHELL` describing Bash while the current interactive process is Xonsh is
intentional. The variable identifies the configured login shell, not the
interpreter of the current prompt.

## 7. Retire Zsh only after an evaluation period

Do not remove Zsh in the same change that establishes Xonsh.

First make Zsh semantically dead:

```text
no login dependency
no environment dependency
no WezTerm default dependency
no required integration dependency
```

Then remove deployment of the legacy configuration:

```text
~/.zshenv
~/.zprofile
~/.config/zsh/
Zim configuration and generated state
Zsh-specific terminal integration
```

Package removal is a later cleanup operation after the fallback and rollback
paths have been exercised.

## 8. Acceptance gate

The migration is qualified when all of the following hold:

```text
Bash login works without Xonsh
and
WezTerm opens Xonsh by default
and
POSIX WezTerm helper commands still work
and
PATH/XDG/session environment parity holds
and
Xonsh runs from its isolated uv-managed interpreter
and
uv project commands use the project interpreter
and
history persists and searches correctly
and
vi editing/completion/highlighting work
and
zoxide works
and
direnv enters and leaves project environments correctly
and
WezTerm working-directory/prompt integration works
and
no active runtime path requires Zsh
```

## 9. Implementation sequence

Keep the realization thin and independently reversible:

```text
1. shell roles + environment boundary
2. Xonsh install + rc fragments + smoke checks
3. WezTerm interactive cutover + Bash login cutover
4. Zsh/Zim retirement
```

Each stage should preserve the previous usable shell path until the next stage
has passed its evaluation.

## Resulting operational model

```text
Bash
    compatibility and recovery

Xonsh
    interactive Python/process crossing and composition

uv
    interpreter, dependency, tool, and project-environment realization

project files
    durable semantic and execution authority
```

This preserves the repository's Xonsh capability model: Xonsh increases the
capability of terminal work without becoming semantic authority itself.
