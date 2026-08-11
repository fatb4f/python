# Terminal-native Python development

This document consolidates the proposed development environment for the
progressive Python curriculum. It separates the repository's current contract
from optional experiments and later observation tools; inclusion here does not
mean that every named tool is installed or implemented.

## Design decision

The durable development system is the repository and its command-line
interfaces, not an editor session:

```text
one repository
one pyproject.toml
one uv.lock
one project .venv
one exercise-selection authority
```

The principal boundaries are:

| Surface | Responsibility |
| --- | --- |
| Filesystem | Persistent source and evidence |
| `uv` | Python and dependency authority |
| `tools/path.py`, later projected through `just` | Curriculum and exercise selection |
| pytest | Durable behavioral observation |
| CPython | Runtime and language authority |
| Helix | Persistent structural editing and navigation |
| Terminal | Execution and observation |
| WezTerm | Disposable layout and session composition |

Ruff and ty are independent static-diagnostic authorities in the initial
environment. pytest observes behavior and may escalate a failure into pdb, but
does not initially aggregate the static tools. Alternate interpreters are
differential probes, not authorities.

## Steady-state workspace

The preferred local arrangement is an elastic two-pane WezTerm workspace:

```text
┌──────────────────────────────┬──────────────────────────────┐
│ Helix                        │ Terminal                     │
│                              │                              │
│ persistent source mutation   │ uv / just                    │
│ modal and tree-sitter motions│ CPython / bpython            │
│ project navigation           │ pytest / pytest --pdb        │
│ optional LSP projections     │ Ruff / ty checks             │
└──────────────────────────────┴──────────────────────────────┘
                 WezTerm owns layout only
```

A terminal pane has one foreground process. A long-lived REPL should launch a
runtime command synchronously, return to the shell before another command, or
use a temporary tab or pane for concurrent observation. The normal state
remains two panes; a third surface is an explicit diagnostic escalation.

WezTerm state is disposable. Closing the workspace must lose no authority:
source remains in files, dependencies in the lockfile, behavior in tests, and
curriculum progress in the existing progress mechanism. Pane titles and
workspace names may display the selected exercise, but must not be its only
record.

Helix is preferred when the editor contract is limited to persistent editing,
navigation, and optional LSP projection. Neovim remains a compatible adapter;
neither editor owns the command loop or Python environment.

The configured workstation exposes this layout as `Alt-p` in WezTerm and as
the **Open Python learning workspace** command-palette entry. It creates or
switches to the `python-learning` workspace, runs `helix .` in the left pane,
and leaves a login shell in the right pane. Both panes start at the repository
root with `EDITOR`, `VISUAL`, and `TERM_EDITOR` set to `helix`.

The repository's `.helix/languages.toml` disables Python language servers and
automatic formatting during the manual-observer phase. Tree-sitter syntax,
text objects, motions, indentation, and structural navigation remain active.
LSP support is a later projection rather than an initial hidden observer.

## Default learning loop

The current repository feedback boundary is one exercise. The repository
contains many intentionally unfinished exercises, so a bare repository-wide
pytest invocation is not the normal loop.

```text
select exercise with tools/path.py
      ↓
enter its directory
      ↓
edit or probe
      ↓
run Python / pytest / Ruff / ty independently
      ↓
escalate a behavioral failure with pytest --pdb
      ↓
convert durable discoveries into source or tests
```

Begin with the native project and tool commands:

```sh
uv sync --locked
uv run --frozen --no-sync python tools/path.py next

cd <exercise-directory>
uv run --frozen --no-sync python <solution.py>
uv run --frozen --no-sync pytest <test-file.py>
uv run --frozen --no-sync ruff check <solution.py>
uv run --frozen --no-sync ty check <solution.py>
uv run --frozen --no-sync pytest '<test-file.py>::<node>' -x --pdb
```

This exposes working-directory semantics, uv project discovery, process
boundaries, test selection, node IDs, exit statuses, output streams, and the
difference between static and runtime observation.

After those boundaries are understood, introduce the existing `just next`,
`just show`, `just test`, `just test-file`, and `just test-node` recipes as
shorter repository projections. `tools/path.py` remains the only curriculum
and exercise selector; new surfaces must call it instead of implementing a
second target model.

## Interactive surfaces

The interactive tools have different state models and should be used for
different jobs:

| Tool | Intended role | Durable state |
| --- | --- | --- |
| CPython PyREPL | Disposable syntax, object, and algorithm probes | History only |
| bpython | Experimental live authoring and replay | Session until saved |
| Helix | Multi-file structural authoring | Repository files |
| pytest | Reproducible behavioral probes | Test files and reports |
| pdb | Interactive failure-state inspection | None unless recorded |
| xonsh | Optional shell/process orchestration | Commands and files only |

CPython's modern interactive shell is the baseline REPL. `python -i <file>` is
useful for inspecting the namespace produced by a script, but rerunning in a
clean process remains the authoritative confirmation. A user-level
`PYTHONSTARTUP` file is convenient for bare interactive sessions but is not a
reproducible project interface and is not applied uniformly to script, `-c`,
and `-m` invocation forms.

bpython is the strongest REPL-first authoring experiment. It can edit blocks
or sessions externally, save a session, replay it, show source, and watch
imports. Session replay can also repeat filesystem writes, randomness,
networking, and other side effects. It is therefore best evaluated first on
small, mostly pure exercises. A session becomes durable only after it is saved
to the canonical exercise file and confirmed by pytest in a clean process.

Set the external editor to Helix when evaluating the REPL-to-editor boundary.
Record the first reason for opening the editor, such as multi-location editing,
navigation, refactoring, test editing, persistent module structure, or unsafe
session replay.

xonsh is an optional escalation for Python-aware subprocess composition and
structured output. It never becomes project-interpreter or environment
authority; project commands still pass through `uv` and `just`. Avoid virtual
environment activation xontribs in this model.

## Dependency policy

Per-exercise virtual environments and uv workspaces are deliberately excluded.
Virtual environments placed inside one another do not compose their packages,
and uv workspaces intentionally share a lockfile and environment rather than
providing member isolation.

Use invocation-scoped variation for experiments:

| Need | Mechanism |
| --- | --- |
| Normal repository command | `uv run --frozen --no-sync ...` |
| Temporary interactive tool | `uv run --with <tool> ...` |
| Fresh ephemeral project environment | `uv run --isolated ...` |
| Standalone dependency-bearing probe | PEP 723 inline script metadata |
| Explicitly different project | `uv run --project <path> ...` |
| Different working directory | `uv run --directory <path> ...` |
| Genuine dependency-policy boundary | Independent project and lockfile |

For example, evaluate bpython without changing project requirements:

```sh
uv run \
  --directory <exercise-directory> \
  --frozen \
  --no-sync \
  --with 'bpython==<version>' \
  bpython
```

An exact top-level `--with` version does not lock all transitive dependencies,
so this is appropriate for evaluation rather than archival reproducibility. If
the experiment becomes part of the canonical interface, promote the tool to a
root development dependency and record its complete resolution in `uv.lock`.

`--project` selects project authority without changing the command's current
working directory. `--directory` changes the working directory before project
discovery. PEP 723 scripts with inline dependencies are isolated from the
containing project and must declare everything they need.

## Manual observer boundaries

The initial environment installs pytest, Ruff, and ty together but teaches
their models separately:

```text
Python semantics
      │
      ├── pytest → observed behavior
      ├── Ruff   → lint and static-rule diagnostics
      └── ty     → type constraints
```

Run each observer directly against one selected exercise:

```sh
uv run --frozen --no-sync pytest <test-file.py>
uv run --frozen --no-sync ruff check <solution.py>
uv run --frozen --no-sync ty check <solution.py>
```

Do not run Ruff or ty over the repository root: most exercises are
intentionally unfinished, and the frozen curriculum is not learner-owned
source. Static commands target the single mutable solution file. Their native
output, scope, and exit behavior remain visible.

`pytest --pdb` is intentionally different from static-tool aggregation. It is
a causal transition from a failed behavioral hypothesis into the live frame
that produced the failure:

```text
hypothesis → pytest → failure → pdb → causal state
```

Ruff and ty are independent observations and therefore remain independent
commands. Do not add `just ruff`, `just ty`, `just check`, pytest static-tool
tests, or editor-only diagnostics during the manual phase.

Static tools diagnose source, not the live REPL namespace. Runtime-created
objects, mutated values, and dynamically installed names cannot be projected
faithfully into a static checker. Keep runtime inspection and source
diagnostics as separate operations.

### Later aggregation

After the manual boundaries are understood, a future automation layer may
project them into one selected-exercise check:

```text
just check <exercise>
└── tools/path.py check <exercise>
    └── pytest
        ├── supplied behavioral tests
        ├── learner-authored tests
        ├── Ruff subprocess observer
        └── ty subprocess observer
```

That projection must preserve tool-specific exit semantics and unmodified
diagnostic output. pytest can distinguish diagnostic findings from tool or
configuration failures in its report, although its aggregate process status
still reduces both to a failed run. This aggregation is not implemented in the
initial environment.

Ruff can eventually diagnose arbitrary source through stdin with the intended
path passed as `--stdin-filename`. ty currently needs a filesystem target. Any
future ty scratch projection must be disposable, ignored, atomically written,
and unique enough that concurrent sessions cannot silently share it.

## Later REPL command bridge

Once repository projections are understood, a REPL may expose thin subprocess
helpers such as `test()`, `check()`, and `test_node()`. These helpers must call
the existing command surface rather than infer a current exercise or implement
another selector.

They must not call `pytest.main()` repeatedly in a long-lived interpreter,
because Python's import cache can make repeated in-process runs observe stale
modules. `run()` must mean a clean child-process execution. If hot reload is
later introduced, give it a different name and confirm every discovery with a
clean run.

## Observation ladder

Introduce observation tools in response to actual diagnostic limits rather
than installing the entire ecosystem at once.

### Baseline

```text
pytest output
  → explicit print/repr
  → traceback
  → native pdb / pytest --pdb
```

These surfaces teach the ordinary execution and failure model before adding
instrumentation abstractions.

### Source and execution structure

Use standard-library tools before third-party visualizations:

```text
ast / inspect / dis
  → sys.settrace
  → sys.monitoring
```

`sys.monitoring` is available in the repository's Python 3.14 baseline and can
support small learner-facing probes for calls, lines, branches, returns, and
exceptions. Present those as purpose-specific probes rather than exposing the
entire low-level event API at once.

### Optional expression and line tracing

The Alex Hall tool cluster offers three useful observation primitives:

| Surface | Primitive |
| --- | --- |
| snoop | Sequential event stream of lines and changing locals |
| Birdseye through `@spy` | Recorded expression and loop trajectory |
| pdb or pdbpp | Interactive state intervention |

`pp.deep` is particularly useful for expression evaluation order and locating
the subexpression that raised an exception. `@spy` captures both the textual
trace and Birdseye recording during the same execution: consuming the text
first is cheap, but the recording cost has already been paid. Birdseye also
uses an additional browser-backed projection and retained trace data.

`executing` correlates runtime frames and bytecode positions with source AST
nodes. That mapping is an instructive implementation study, not a CPython
semantic guarantee; generated code, missing source, pytest assertion rewriting,
and other source transformations can make it incomplete.

Do not leave diagnostic decorators or imports in canonical Exercism solutions.
Instrumentation can perturb timing, object lifetime, exception behavior, and
concurrency. Confirm every instrumented observation with an ordinary pytest
run. Learn native pdb before evaluating pdbpp's automatic replacement behavior
or a visual terminal debugger such as PuDB.

### Later automation and process observation

Add these only after the manual loop and its failure modes are understood:

| Need | Candidate |
| --- | --- |
| Restart after file changes | watchfiles |
| Select tests related to changed code | pytest-testmon |
| Attach interactively | Python 3.14 `pdb -p` |
| Sample a live process externally | py-spy |
| Inspect Python/native stacks | PyStack |
| Record whole-execution timing | VizTracer |
| Inspect Python allocations | tracemalloc |
| Inspect Python and native allocations | Memray |
| Diagnose hangs or crashes | faulthandler |

Automatic restart plus dependency-based test selection can obscure why a test
did or did not run. Keep both outside the baseline until that tradeoff is
useful. Python 3.14 process attachment and enhanced native fault reporting are
available for later lessons without changing the repository interpreter.

### Alternate interpreters

CPython remains semantic authority. Alternate runtimes answer different
questions:

| Runtime | Role |
| --- | --- |
| CPython | Language/runtime authority for this repository |
| RustPython | Implementation-difference probe for sufficiently pure code |
| PyPy | Compatibility and performance probe |

Agreement across implementations increases confidence but is not proof.
Disagreement creates an investigation: compare the language specification,
CPython behavior, observable values, exception classes, and relevant side
effects. Do not compare unstable details such as timing or incidental `repr`
output unless they are the subject of the exercise.

## Adoption sequence

Keep each change reversible and promote it only after a concrete benefit is
observed:

1. **Manual baseline:** one root uv environment, conventional CPython 3.14.x,
   direct Python execution, focused pytest with pdb escalation, direct Ruff and
   ty commands, a terminal, and an optional structural editor.
2. **Repository projections:** introduce the existing `just` recipes only
   after the native command scopes and exit semantics are understood.
3. **REPL experiment:** evaluate invocation-scoped bpython on early pure
   exercises and record when structural editing becomes necessary.
4. **Unified check experiment:** add per-exercise subprocess observers and
   aggregate them through a separate pytest-backed `check` path.
5. **Instrumentation lessons:** native `ast`/`inspect`/`dis` and
   `sys.monitoring`, followed by snoop, `pp.deep`, and one Birdseye recording.
6. **Advanced observation:** process, timeline, memory, and differential-runtime
   probes only when the curriculum reaches the behavior they illuminate.

An experiment is promoted only when it preserves the single environment and
selector invariants, works without editor integration, produces a clear
learning benefit, and ends in a reproducible clean-process check.

## References

- [uv project commands](https://docs.astral.sh/uv/concepts/projects/run/)
- [uv workspaces](https://docs.astral.sh/uv/concepts/projects/workspaces/)
- [uv scripts and PEP 723](https://docs.astral.sh/uv/guides/scripts/)
- [CPython command-line interface](https://docs.python.org/3/using/cmdline.html)
- [CPython `sys.monitoring`](https://docs.python.org/3/library/sys.monitoring.html)
- [pytest invocation and selection](https://docs.pytest.org/en/stable/how-to/usage.html)
- [pytest failure and pdb integration](https://docs.pytest.org/en/stable/how-to/failures.html)
- [Ruff configuration and stdin](https://docs.astral.sh/ruff/configuration/)
- [ty command-line interface](https://docs.astral.sh/ty/reference/cli/)
- [Helix language-server support](https://docs.helix-editor.com/master/lsp.html)
- [bpython documentation](https://docs.bpython-interpreter.org/)
- [snoop](https://github.com/alexmojaki/snoop)
- [Birdseye](https://github.com/alexmojaki/birdseye)
- [RustPython](https://github.com/RustPython/RustPython)
- [PyPy](https://www.pypy.org/)
