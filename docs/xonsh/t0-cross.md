# T0 — Cross

T0 establishes Xonsh's basic computational model: subprocess syntax, Python
expressions, and Python objects coexist and cross explicit boundaries.

## Runtime planes

```text
subprocess plane
    commands, pipes, redirects, jobs, status

Python plane
    values, functions, types, imports, exceptions

interaction plane
    prompt, history, completion, editing
```

T0 does not mean using Xonsh as Bash and adding Python later. The crossings are
the foundational capability.

## Core crossings

```xsh
# Python value -> subprocess argument
for number in range(3):
    echo @(number)

# subprocess output -> captured value
output = $(python --version)
type(output)

# path syntax -> Path object
config = p'pyproject.toml'
config.exists()
config.read_text()

# glob -> Path objects
for source in gp`**/*.py`:
    if source.is_file():
        print(source)

# structured text -> Python object
import json
payload = json.loads($(printf '{"status": "ok"}'))
payload['status']
```

Environment values can also carry Python-aware structure, but interactive
environment state must not become hidden project configuration.

## Apply task deconstruction

Before choosing a command, use the shared
[task-deconstruction model](../semantics/task-deconstruction.md):

```text
task -> constraints -> admissible representations
     -> algorithm -> realization -> observation -> validation
```

The realization may be a Python expression, Xonsh expression, subprocess, or a
combination. Preserve exit status, stdout/stderr distinctions, path identity,
and parsing failures when the contract observes them.

`Path.is_file()` is suitable only for best-effort filtering: Python 3.14
returns `False` when the metadata lookup raises `OSError`. When the contract
requires filesystem failures to remain visible, call `stat()` with explicit
error handling and apply the regular-file predicate to the returned mode.

## Completion evidence

T0 is established when these feel ordinary:

- switching deliberately between Python and subprocess syntax;
- interpolating Python values into command arguments;
- capturing output before transforming it;
- using Path and glob objects without stringly typed detours;
- converting machine-readable process output into Python values;
- observing statuses and failures at process boundaries;
- explaining which representation properties each crossing preserves or
  loses.

Rich, Coconut, custom macros, event hooks, and project-specific shell machinery
are not required for T0.
