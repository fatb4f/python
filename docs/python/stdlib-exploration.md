# Standard-library exploration

The standard library participates in both capability learning and project
work.

## T1 — Observation substrate

Inspect a module or object manually:

```text
import
  -> namespace discovery
  -> Rich inspection
  -> help / pydoc
  -> signature / source where available
  -> direct behavioral probe
```

For example:

```python
import inspect
from pathlib import Path
from rich import inspect as ri

ri(Path, methods=True)
help(Path.read_text)
inspect.signature(Path.read_text)

subject = Path("pyproject.toml")
ri(subject)
subject.exists()
```

Useful subjects include `pathlib`, `inspect`, `ast`, `dis`, `tokenize`,
`importlib`, `sqlite3`, and `subprocess`. Observe one capability at a time and
record limits: imports can execute code, built-ins may lack retrievable source,
iterators may be consumed, and representations may be unstable.

## Project implementation component

A module becomes a project component only when a concrete task requires its
operations:

```text
filesystem task -> pathlib
process boundary -> subprocess
local relational state -> sqlite3
source structure -> ast / tokenize
runtime ownership -> inspect / importlib
```

The project must state the module's role, boundary behavior, failure contract,
and tests. T1 familiarity informs the choice but does not mandate it.

## Explorer gate

Do not build a stdlib explorer from a prospective schema. Let repeated manual
questions identify stable fields such as identity, kind, module, documentation,
signature, members, bases, or source. Extract one small helper, compare it with
direct inspection, and automate only the projection that repeatedly improves
the loop.
