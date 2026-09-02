# Ops learning guide

This guide is the operational spine of Python Immersion. It begins with real
terminal work and uses the repository's semantic and capability documents as
supporting models.

It does **not** teach Xonsh or Python feature-by-feature.

```text
task
  ↓
deconstruct                         PPF
  ↓
identify constraints
  ↓
choose representation
  ↓
choose smallest adequate realization
  ↓
execute                             Xonsh / Python / subprocess
  ↓
observe                             Rich / pydoc / CPython / runtime
  ↓
validate                            direct evidence / pytest
  ↓
revise or escalate
```

The stable question is:

> What operation is required, what constraints make a realization admissible,
> and what evidence establishes that the result contract was satisfied?

## Responsibility boundary

The guide composes existing documents rather than replacing them.

| Surface | Responsibility |
| --- | --- |
| [Learning contract](../learning.md) | Defines the two independent learning axes and escalation rule. |
| [PPF semantic practice](../semantics/README.md) | Supplies DATA, RULE, OPERATION, POLICY, BOUNDARY, COMPOSITION, and STATE. |
| [Task deconstruction](../semantics/task-deconstruction.md) | Reduces intent and constraints into admissible representations and realizations. |
| [Xonsh progression](../xonsh/README.md) | Explains the capability tiers and Python/process crossings. |
| [Stdlib exploration](../python/stdlib-exploration.md) | Supplies demand-driven runtime and Python-internals observation. |
| **Ops guide** | Owns which concrete operations to practice and in what order. |

The semantic axis remains horizontal practice. Xonsh/Python adoption remains a
vertical capability axis. Operational tasks are the situations in which the
two axes meet.

## Entry contract

Start every operation from the task rather than from a command, type, library,
or pattern.

```text
TASK := OP(WHAT | CONTEXT) -> RESULT
```

Use the full [task-deconstruction model](../semantics/task-deconstruction.md)
when the problem is not already obvious. For routine terminal work, the
following decision path is the compact entry point:

```text
1. Is the task observation or mutation?
   |
   +-- observation
   |     `- what representation exposes the required state?
   |
   `-- mutation
         `- what preconditions and postconditions constrain the effect?

2. What is the subject?
   scalar / text / path / process / stream / object / relation

3. What operation is required?
   select / transform / compose / effect / validate

4. Does a subprocess or text boundary preserve the required semantics?
   |
   +-- yes -> it remains an admissible realization
   `-- no  -> cross into Python objects or another structured representation

5. Is an external boundary crossed?
   filesystem / process / serialization / network / database
   |
   `- preserve the result, failure, identity, and provenance evidence
      required by the task

6. Is the operation repeated enough to deserve a durable form?
   |
   +-- no  -> keep the interactive realization
   `-- yes -> evaluate a function, script, specimen, or project surface

7. Does correctness need to survive visual inspection?
   |
   `-- yes -> state the behavioral claim and project it into pytest
```

This is a convenience projection of the semantic decision model, not a second
authority.

## Operational progression

Operations increase in composition, effects, and durability. The `O` labels
describe practice families; the `T` labels describe the Xonsh/Python capability
usually sufficient to realize them. They are not a replacement tier system.

| Ops family | Practice | Typical capability |
| --- | --- | --- |
| O0 CROSS | navigate, enumerate, invoke, capture, redirect, inspect environment state | T0 |
| O1 OBSERVE | type, representation, namespace, documentation, status, failure, metadata | T1 |
| O2 SELECT + TRANSFORM | glob, filter, map, parse, normalize, rank, aggregate, serialize | T1–T2 |
| O3 COMPOSE | value flows, structured subprocess boundaries, reusable functions, aliases | T2 |
| O4 CONTROL | predicates, branching, iteration, assertions, bounded retries | T2 |
| O5 AUTOMATE | filesystem/process orchestration, HTTP/API work, JSON, repeatable operations | T2–T4 |
| O6 QUALIFY | preconditions, expected state, postconditions, pytest, idempotence checks | T4 |
| O7 INSTRUMENT | timing, structured observations, failure context, provenance, tracing | T4 |
| O8 PROJECT | scripts, CLIs, libraries, TUIs, data/analytics tools, reusable infrastructure | T4–T5 |

Do not advance because a feature exists. Advance when a concrete operation
cannot remain clear, observable, and adequately validated at the current
surface.

## Runbook contract

An Ops exercise is a small runbook. It should contain only the fields that
matter for the operation, but the complete shape is:

```text
TASK
    OP(WHAT | CONTEXT) -> RESULT

SEMANTICS
    DATA
    RULE
    OPERATION
    POLICY
    BOUNDARY
    COMPOSITION
    STATE

CONSTRAINTS
    properties that reduce the admissible set

CAPABILITY
    current T tier
    allowed mechanisms
    deliberately withheld mechanisms

REALIZATION
    smallest adequate interactive or durable form

OBSERVATION
    runtime evidence required to understand the mechanism

VALIDATION
    evidence that establishes the result contract

INTERNALS DRILL-DOWN
    only the Python / CPython / OS mechanism exposed by this operation

ESCALATION
    observed friction required before introducing a stronger abstraction
```

An exercise is complete when the result can be explained and validated. It
does not require progressing to the highest available tier.

## Initial runbook — rank Python files by size

This operationalizes the worked shape already used by
[task deconstruction](../semantics/task-deconstruction.md#worked-shape).

### Task

```text
OP
    rank

WHAT
    Python source files

CONTEXT
    current repository subtree
    regular files only

RESULT
    paths ordered by descending byte size
```

### Semantic decomposition

```text
DATA
    filesystem paths + byte size

RULE
    suffix == ".py"
    path is a regular file

OPERATION
    enumerate -> select -> project size -> rank

POLICY
    descending size
    display only the first 10 after the full ordering is established

BOUNDARY
    filesystem metadata lookup

COMPOSITION
    glob -> predicate -> stat projection -> sorted sequence -> rendering

STATE
    observation only; no filesystem mutation
```

The representation constraints are:

```text
preserve path identity
preserve one size value per selected path
ordering carries meaning
filesystem failures must remain observable
```

### T0 realization

Use Xonsh's path/glob crossing and ordinary Python values:

```xsh
sources = [path for path in gp`**/*.py` if path.is_file()]

ranked = sorted(
    ((path, path.stat().st_size) for path in sources),
    key=lambda item: item[1],
    reverse=True,
)

for path, size in ranked[:10]:
    print(f"{size:>10}  {path}")
```

The point is not the compact syntax. Identify each boundary:

```text
gp`**/*.py`
    filesystem pattern -> Path objects

path.is_file()
    Path -> filesystem observation -> bool

path.stat().st_size
    Path -> filesystem metadata -> int

generator expression
    selected paths -> lazy (Path, int) values

sorted(...)
    iterable -> ordered list

print(...)
    Python values -> terminal projection
```

No subprocess is required because the task's required representation and
operations are already directly available as Python values.

### T1 observation

Interrogate only the mechanisms used by the operation:

```xsh
from rich import inspect as ri
import inspect

subject = sources[0]

type(subject)
repr(subject)
ri(subject, methods=True)
help(subject.stat)
inspect.signature(subject.stat)
```

Then probe the returned metadata object:

```xsh
metadata = subject.stat()

type(metadata)
repr(metadata)
ri(metadata)
metadata.st_size
```

The useful internals questions are now concrete:

- What protocol makes a `Path` usable as a filesystem subject?
- What does `stat()` return, and why is `st_size` an integer attribute?
- When does the generator actually execute `path.stat()`?
- Why must `sorted()` materialize the values before global ranking is known?
- Which failures can occur at the filesystem boundary?

Do not expand into unrelated `pathlib`, iterator, or sorting internals.

### T2 composition

If the operation recurs, extract only the stable value transformations:

```python
def with_size(paths):
    return ((path, path.stat().st_size) for path in paths if path.is_file())


def rank_by_size(records):
    return sorted(records, key=lambda item: item[1], reverse=True)
```

The extraction is justified only if it improves reuse or makes the contracts
more observable. It is not required merely because functions are available.

### Qualification gate

Promote the operation into a durable specimen or project only when its result
becomes a reusable claim. At that point, use a temporary directory fixture and
assert at least:

```text
non-Python files are excluded
non-files are excluded
path identity is preserved
byte sizes match the fixture contents
result ordering is descending
```

The filesystem fixture becomes controlled evidence. Interactive output is no
longer the sole validator.

## Practice queue

The next useful runbooks should come from actual terminal work rather than
synthetic language exercises. Prefer this order until evidence suggests a
different need:

```text
filesystem observation
    -> process observation
    -> environment boundaries
    -> text vs structured subprocess output
    -> JSON / HTTP acquisition
    -> repeated filesystem/process operations
    -> pytest-qualified sysops
    -> instrumentation
    -> project projection
```

Each new runbook should reuse the same task contract and decision path. New
abstractions are admitted only when repeated operational pressure demonstrates
the need.

## Exit condition

The Ops guide is working when an unfamiliar terminal task routinely triggers:

```text
intent
  -> semantic decomposition
  -> constraint reduction
  -> representation choice
  -> smallest adequate realization
  -> targeted observation
  -> behavioral validation
```

rather than:

```text
remember command
  -> try flags
  -> accumulate shell trick
```

The desired endpoint is not a more elaborate shell configuration. It is an
increasingly Python-native, inspectable, testable way to operate real systems.
