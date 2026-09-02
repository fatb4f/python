# T1 — Observe

T1 makes runtime observation deliberate before an explorer or abstraction is
built.

```text
subject
  ↓
type / repr
  ↓
dir / ?
  ↓
Rich inspect
  ↓
help / pydoc
  ↓
signature / source
  ↓
behavioral probe
```

## Minimal setup

Rich is installed by the repository environment:

```xsh
from rich import inspect as ri
from rich import print as rprint
from rich.traceback import install

install(show_locals=True)
```

Then inspect one subject rather than dumping an entire ecosystem:

```xsh
import inspect
import pathlib

subject = pathlib.Path
type(subject)
repr(subject)
dir(subject)
ri(subject, methods=True)
help(subject.read_text)
inspect.signature(subject.read_text)
inspect.getsource(subject.read_text)
```

Not every subject has a Python signature or retrievable source. Built-ins,
generated objects, extension modules, wrapped callables, and missing source
files can make either operation fail. That failure is evidence about the
subject, not a reason to invent a uniform result.

## Observer responsibilities

| Observer | Question |
| --- | --- |
| `type` / `repr` | What runtime value and presentation are present? |
| `dir` / completion | Which names are reachable? |
| Rich inspect | What useful runtime structure is visible? |
| `help` / pydoc | What contract is documented? |
| stdlib `inspect` | What signature, source, members, or ownership can be recovered? |
| direct call | How does the subject actually behave? |
| pytest | Which behavior is a durable claim? |

Rendered output is a projection, not the object itself. Preserve object
identity for subsequent operations rather than scraping terminal text.

## Manual-first explorer gate

Record recurring questions during direct inspection. A stdlib explorer is
earned only when several subjects repeatedly require the same projection and a
helper improves the loop without hiding observer limits.

Continue with [standard-library exploration](../python/stdlib-exploration.md)
or [T2 composition](t2-compose.md).
