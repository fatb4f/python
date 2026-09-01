# Xonsh adoption — programmable Python terminal runtime

## Status

**Role:** optional terminal-native adoption profile  
**Scope:** Xonsh as a daily-driver shell, Python observation surface, structured pipeline host, and later programmable terminal runtime  
**Authority:** the repository, `uv`, CPython, tests, and the semantic companion remain authoritative; Xonsh is an optional realization surface

This document complements [`xonsh-t0.md`](xonsh-t0.md). The T0 document is the concrete constraint-driven terminal exercise profile. This document defines the broader staged adoption model and the boundary between native Xonsh, Python observation, interaction ergonomics, Coconut composition, and later shell metaprogramming.

The central proposition is:

> Xonsh is not merely a Python-capable shell. It can be adopted progressively as a programmable terminal runtime in which normal terminal work repeatedly crosses between subprocess semantics, Python objects, Python libraries, and structured transformations without replacing ordinary Unix tools.

The adoption rule is conservative:

```text
native capability
    ↓
manual use
    ↓
recurring friction observed
    ↓
small projection / helper
    ↓
only then automate or generalize
```

Do not begin by designing a shell framework. Let repeated terminal operations earn abstractions.

---

# 1. Runtime model

The useful mental model is:

```text
                         XONSH
                           │
       ┌───────────────────┼────────────────────┐
       │                   │                    │
   subprocess           Python             terminal UI
     runtime            runtime               runtime
       │                   │                    │
 pipes/redirection     objects/imports       prompt-toolkit
 aliases/capture       functions/types       completions
 jobs/history          exceptions            keybindings
       │                   │                    │
       └───────────────────┼────────────────────┘
                           │
                    programmable shell
```

Three planes cooperate without becoming the same thing:

```text
subprocess plane
    external commands, pipes, redirects, jobs, exit status

Python plane
    objects, functions, types, imports, stdlib, third-party libraries

interaction plane
    prompt-toolkit, completion, history, keybindings, terminal integration
```

The point is not to eliminate the Unix process model. The point is to make the boundary between processes and Python objects explicit and cheap.

---

# 2. Tier 0 — native Xonsh fluency

Tier 0 aligns with the productive baseline demonstrated by the upstream [`anki-code/xonsh-cheatsheet`](https://github.com/anki-code/xonsh-cheatsheet).

T0 is **not**:

```text
use Xonsh like Bash
    ↓
learn Python features later
```

It is mixed from the start:

```text
subprocess syntax
     ↕
Python expressions
     ↕
Python objects
```

The detailed exercise contract lives in [`xonsh-t0.md`](xonsh-t0.md). At the adoption level, T0 includes:

```text
T0 — Native Xonsh
│
├── subprocess mode
├── Python mode
├── Python ↔ subprocess interpolation
├── capture operators
├── structured command-output conversion
├── typed environment
├── aliases
├── path/glob objects
├── context-managed operations where encountered
├── history / jobs / navigation
└── direct use of Python libraries
```

Representative shapes:

```xsh
cd /tmp && ls

21 + 21

for i in range(3):
    echo @(i)

len($(curl https://xon.sh))

$PATH.append('/tmp')

p'/etc/passwd'.read_text()

for file in gp`*.py`:
    if file.exists():
        du -sh @(file)

import json
json.loads($(echo '{"a": 1}'))
```

The important constructs are the crossings:

```text
@(...)
    Python value → subprocess argument

$(...)
    subprocess output → captured value

p'...'
    path syntax → Path object

gp`...`
    glob → Path objects

structured output decorators
    subprocess output → Python object
```

### T0 completion condition

T0 is established when these operations feel ordinary:

```text
subprocess/Python mode switching
@() interpolation
$() capture
typed environment mutation
Path/glob object use
Python imports at the prompt
subprocess results entering Python computation
normal aliases/history/jobs/navigation
```

Rich, Jedi, Coconut, custom macros, custom keybindings, and project-specific shell machinery are not required for T0.

---

# 3. Tier 1 — Python-native observation

Tier 1 makes the running Python world easy to inspect without yet creating a custom explorer.

Primary surfaces:

```text
Rich
├── inspect
├── print
└── traceback

stdlib
├── help
├── pydoc
├── inspect
├── dis
└── pathlib

behavior
└── pytest
```

A minimal interactive setup can expose Rich directly:

```xsh
from rich import inspect as ri
from rich import print as rprint
from rich.traceback import install

install(show_locals=True)
```

Then use the runtime itself:

```xsh
import pathlib

ri(pathlib)
ri(pathlib.Path)
ri(pathlib.Path, methods=True)
help(pathlib.Path.read_text)
```

The observation split is:

```text
Rich inspect
    what is this object at runtime?

help / pydoc
    what is the documented API contract?

pytest
    what behavior is reproducibly established?

inspect / dis
    how is the object represented or lowered?
```

This is the preferred manual baseline for the eventual stdlib explorer.

---

# 4. Tier 2 — interaction ergonomics

Tier 2 improves discovery and terminal interaction without adding a new semantic layer.

Recommended candidates:

```text
xontrib-jedi
xontrib-term-integrations
```

## Jedi

`xontrib-jedi` replaces the Python completion component with Jedi-backed completion while leaving the rest of the Xonsh completion chain available.

Conceptually:

```text
Jedi
    what can I reach from this Python expression?

Rich
    what is this runtime object?

pydoc/help
    what does the API claim?
```

The manual stdlib exploration loop becomes:

```text
import module
    ↓
<Tab> namespace discovery
    ↓
Rich inspection
    ↓
pydoc/help
    ↓
direct invocation
    ↓
recurse into an interesting object
```

## WezTerm integration

`xontrib-term-integrations` can expose prompt, input, output, working-directory, and terminal-state semantics to WezTerm.

Keep the authority boundary explicit:

```text
stdlib / Python semantics
    CPython + docs + observed behavior

terminal interaction
    Xonsh + prompt-toolkit + WezTerm integration
```

Terminal zones and user variables improve navigation and interaction. They do not become semantic state for the learning repository.

## Prompt-toolkit

Prompt-toolkit is an advantage because it exposes a programmable interaction plane:

```text
completion presentation
completion threading
keybindings
VI/readline editing modes
bottom toolbar
right prompt
mouse support
styles
asynchronous prompt behavior
```

Use these features to reduce demonstrated friction, not to build decorative shell UI.

---

# 5. Tier 3 — structured and functional orchestration

Tier 3 introduces Coconut deliberately as an orchestration language over already-understood Xonsh/Python object boundaries.

Coconut belongs here because its value is not merely alternate Python syntax. In Xonsh it can provide a compact functional pipeline vocabulary over Python values produced by shell activity.

The relationship is:

```text
external command
      │ text / bytes
      ▼
Xonsh capture / decoder
      │
      ▼
Python object
      │
      ▼
Coconut composition
      │
      ├── transform
      ├── filter
      ├── project
      ├── compose
      └── reduce
      │
      ▼
Python object
      │
      ▼
Rich / Python / another process
```

The PowerShell analogy is useful but bounded:

```text
PowerShell
    object pipeline is fundamental shell semantics

Xonsh + Coconut
    ordinary Unix processes
        + explicit process/object boundaries
        + Python objects
        + functional composition syntax
```

This preserves normal Linux command behavior while allowing selected flows to become object-native.

### Adoption constraint

Do not rewrite every ordinary text pipeline into Coconut.

Use Coconut when the semantic task is naturally expressed as operations such as:

```text
map
filter
project
group
compose
reduce
```

A practical gate is to wait until several recurring object transformations are visibly clearer as compositions than as shell text pipelines.

---

# 6. Tier 4 — programmable Xonsh primitives

Tier 4 is where Xonsh stops being only the host and begins carrying small user-defined terminal capabilities.

Adopt in roughly this order:

```text
1. typed custom environment variables
2. callable aliases
3. macros
4. command/output decorators
5. events/hooks
6. keybindings/custom completers
```

## Typed environment

Xonsh environment state can hold Python-aware values rather than forcing every parameter through shell-string serialization.

Use this for explicit interactive control values, for example:

```xsh
$PY_EXPLORER_PRIVATE = False
$PY_EXPLORER_DEPTH = 2
$PY_EXPLORER_MODULES = ['pathlib', 'collections', 'itertools']
```

The environment can therefore act as a small typed interactive parameter surface. It must not become hidden project authority.

## Callable aliases

A Python function can become command-shaped shell behavior while retaining normal Python structure.

This is useful after a manual operation repeats enough to deserve a name:

```text
manual expression
    ↓ repeated
Python function
    ↓
callable alias
```

Do not begin with a command framework when a function is sufficient.

## Macros

Macros are useful where preserving or receiving source/expression structure adds real value.

A future explorer could evolve from:

```xsh
ri(pathlib.Path, methods=True)
```

into a macro-shaped operation such as:

```xsh
xp!(pathlib.Path)
```

only after the manual operation is stable and the macro provides information that a normal function call cannot.

The design rule is:

```text
not
    what macros can be invented?

but
    what operation has been repeated often enough
    that raw-expression access materially improves it?
```

## Output decorators

Structured process-output conversion is one of the strongest Xonsh/Python boundaries.

Use explicit conversion when a process has a known machine-readable representation:

```text
process
    ↓
JSON / YAML / lines / paths / custom decoder
    ↓
Python object
```

Generated or custom decoders should remain thin adapters around the external representation.

---

# 7. Tier 5 — domain projections

Only after T0–T4 stabilize should the shell host specialized domain surfaces.

Likely domains include:

```text
Python exploration
├── stdlib explorer
├── package inspection
├── source navigation
└── pytest probes

data work
├── DuckDB
├── Ibis
├── Polars
└── Harlequin

development
├── uv
├── git
├── pytest
├── Ruff
└── ty
```

At this point Xonsh is the host, not the authority:

```text
                       XONSH
                         │
        ┌────────────────┼────────────────┐
        │                │                │
      Python          process          terminal
        │                │                │
 Rich / pytest      uv/git/etc.      prompt-toolkit
        │                │                │
        └────────────┬───┴────────────────┘
                     │
                  Coconut
                     │
             domain projections
```

A domain projection should consume existing commands and Python semantics rather than redefine them.

---

# 8. Stdlib explorer — manual-first derivation

The stdlib explorer should emerge from the manual workflow rather than precede it.

Start with:

```text
1. import
      │
      ▼
2. Jedi completion
   namespace discovery
      │
      ▼
3. Rich inspect
   runtime structure
      │
      ▼
4. pydoc / help
   documented API
      │
      ▼
5. direct invocation
   behavioral probe
      │
      ▼
6. recurse into an interesting object
```

Example:

```xsh
import itertools

# discover
itertools.<Tab>

# orient
ri(itertools)

# inspect one construct
ri(itertools.chain, methods=True)

# canonical documentation
help(itertools.chain)

# observe behavior
c = itertools.chain([1, 2], [3, 4])
ri(c, methods=True)
list(c)
```

Only recurring questions should become explorer fields.

A likely eventual projection is:

```text
Object
├── identity
├── kind
├── module
├── documentation
├── signature
├── members
│   ├── attributes
│   ├── methods
│   ├── classes
│   └── functions
└── relations
    ├── bases
    ├── subclasses
    └── contained namespace
```

This schema is not authoritative yet. It is a candidate shape to be validated by repeated manual exploration.

The preferred progression is:

```text
manual observation
    ↓
repeated question
    ↓
small helper
    ↓
validated projection
    ↓
stdlib explorer
```

---

# 9. Candidate ecosystem components

## Recommended early

```text
T0
    Xonsh itself

T1
    Rich

T2
    xontrib-jedi
    xontrib-term-integrations

T3
    Coconut
```

This is the strongest initial daily-driver plateau:

```text
Xonsh
+ Rich
+ Jedi
+ WezTerm integration
+ Coconut
```

with a thin run-control file and no custom shell framework.

## Defer or evaluate only when needed

### `xontrib-fish-completer`

Useful for richer external-command completion. It is orthogonal to Python-object exploration. Add it only if native command completion becomes a real limitation.

### `xontrib-output-search`

Interesting for recycling tokens from prior terminal output, but its capture tradeoffs and terminal-manager assumptions are disproportionate to the initial learning goal. A future Python-native explorer can often preserve object identity directly instead of scraping rendered terminal output.

### `xontrib-rc-awesome`

Treat it as a pattern source. Mine individual run-control snippets rather than inheriting a shell distribution.

---

# 10. Configuration contract

Keep `.xonshrc` thin during adoption.

The target is:

```text
.xonshrc
    bootstrap and explicit interactive preferences only

Xonsh
    process/Python integration

Rich/Jedi/pydoc
    observation and discovery

Coconut
    optional functional composition

external CLIs
    actuators

repository
    durable source, tests, configuration, and progress
```

Do not move repository authority into shell aliases, prompt state, environment variables, terminal user variables, or interactive history.

The shell should be disposable:

```text
close terminal
    ↓
lose no project semantics
```

---

# 11. Adoption ladder

```text
T0  native Xonsh
 ↓
T1  Python-native observation
 ↓
T2  interactive completion + terminal integration
 ↓
T3  structured / functional orchestration
 ↓
T4  programmable shell primitives
 ↓
T5  domain-specific terminal projections
```

Each tier answers a different question:

| Tier | Question |
| --- | --- |
| T0 | Can subprocesses, Python expressions, and Python objects be used naturally in one shell? |
| T1 | Can the runtime be observed directly before tooling is abstracted? |
| T2 | Can discovery and terminal interaction become ergonomic without changing semantics? |
| T3 | Which object transformations become clearer as functional compositions? |
| T4 | Which repeated operations have earned reusable shell-native abstractions? |
| T5 | Which stable abstractions deserve domain-specific projections? |

The control invariant is:

> Prefer thin projections of already-understood operations over prospective shell architecture.
