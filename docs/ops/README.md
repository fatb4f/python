# Ops learning guide

This guide is the operational spine of Python Immersion. It begins with real
terminal work and uses the repository's semantic and capability documents as
supporting models.

It does **not** teach Xonsh or Python feature-by-feature.

```text
task
  ↓
current evidence Kₙ + assumptions + G    PPF
  ↓
identify assumptions + constraints
  ↓
reduce to admissible realizations A(Kₙ)
  ↓
select smallest adequate realization
  ↓
execute                                  Xonsh / Python / subprocess
  ↓
observe                                  Rich / pydoc / CPython / runtime
  ↓
validate
  ↓
assert / reject / revise
  ↓
record evidence in Kₙ₊₁; revise current claims
  └────────────────────────────────────↺ until G or no admissible action
```

The stable question is:

> What operation is required, what constraints make a realization admissible,
> and what evidence supports or revises the current-state claims?

## Responsibility boundary

The guide composes existing documents rather than replacing them.

| Surface | Responsibility |
| --- | --- |
| [Learning contract](../learning.md) | Defines the two independent learning axes and escalation rule. |
| [PPF semantic practice](../semantics/README.md) | Supplies DATA, RULE, OPERATION, POLICY, BOUNDARY, COMPOSITION, and STATE. |
| [Task deconstruction](../semantics/task-deconstruction.md) | Reduces intent and constraints into admissible representations and realizations, then closes the loop through observation, validation, admission, and revision. |
| [Xonsh progression](../xonsh/README.md) | Explains the capability tiers and Python/process crossings. |
| [Xonsh workstation plan](../xonsh/implementation.md) | Defines the current real workstation migration contract and shell/runtime authority boundaries. |
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

For iterative work, make the evidence and goal explicit:

```text
Eₙ
    relevant external state, which may change

Kₙ
    accumulated observations with time and provenance

G
    required RESULT / postcondition

C(Kₙ)
    constraints derived from evidence and declared assumptions

A(Kₙ)
    realizations admissible under those constraints
```

Use the full [task-deconstruction model](../semantics/task-deconstruction.md)
when the problem is not already obvious. For routine terminal work, the
following decision path is the compact entry point:

```text
1. What external state matters, what is currently known, and what is G?

2. Which statements are established facts and which are only assumptions?

3. Is the task observation or mutation?
   |
   +-- observation
   |     `- what representation exposes the required state?
   |
   `-- mutation
         `- what preconditions and postconditions constrain the effect?

4. What is the subject?
   scalar / text / path / process / stream / object / relation

5. What operation is required?
   select / transform / compose / effect / validate

6. Which constraints make candidate representations or realizations invalid?
   |
   `- policy chooses only among the candidates that remain admissible

7. Does a subprocess or text boundary preserve the required semantics?
   |
   +-- yes -> it remains an admissible realization
   `-- no  -> cross into Python objects or another structured representation

8. Is an external boundary crossed?
   filesystem / process / serialization / network / database / shell runtime
   |
   `- preserve the result, failure, identity, and provenance evidence
      required by the task

9. What observation could support or contradict the assumptions?

10. Does the operation repeat enough to deserve a durable form?
    |
    +-- no  -> keep the interactive realization
    `-- yes -> evaluate a function, script, specimen, or project surface

11. Does correctness need to survive visual inspection?
    |
    `-- yes -> state the behavioral claim and project it into pytest
```

This is a convenience projection of the semantic decision model, not a second
authority.

## Feedback contract

The recent task-deconstruction model adds one distinction that should be
visible in every Ops runbook:

```text
assumption != assertion
```

The model supplies assumptions about the world. Constraint analysis determines
what remains admissible. Execution and observation test those assumptions.
Only validated evidence supports an assertion.

```text
model / assumptions
        ↓
constraints / predicates
        ↓
admissible realizations
        ↓
policy selects among valid choices
        ↓
execution
        ↓
observation
        ↓
validation
        ↓
assert / reject / revise
```

An external execution may change the system and produce new evidence:

```text
Kₙ + assumptions about Eₙ
 ↓
select admissible realization aₙ
 ↓
Eₙ -> external system -> Eₙ₊₁
 ↓
observation oₙ
 ↓
validate / record with provenance
 ↓
Kₙ₊₁ + revised current-state claims
```

External state is not monotonic. Files disappear, processes exit, and a
migration deliberately replaces old configuration. Current-state assertions
may therefore expire or be retracted.

Only the provenance-bearing evidence record grows monotonically:

```text
Kₙ ⊑ Kₙ₊₁
```

A successor record retains earlier observations while adding new evidence.
Contradictory evidence revises the current-state model without erasing the
earlier observation.

Within one selection step, applying additional constraints shrinks the
candidate set:

```text
S₀ ⊒ S₁ ⊒ S₂ ⊒ ... ⊒ S*
```

Across steps, changing external state and revised claims may either expand or
shrink the admissible set. Independently, the evidence record grows:

```text
K₀ ⊑ K₁ ⊑ K₂ ⊑ ... ⊑ K*
```

For ordinary Ops learning, record what was observed, where and when it was
observed, and which claim it supports or contradicts. Use the fuller model only
when changing state, stale evidence, or multiple authorities make it useful.

## Operational progression

Operations increase in composition, effects, and durability. The `O` labels
describe practice families. `T` labels describe Xonsh/Python capability;
Project and Engineering describe independent scope and maturity.

| Ops family | Practice | Typical surface |
| --- | --- | --- |
| O0 CROSS | navigate, enumerate, invoke, capture, redirect, inspect environment and runtime boundaries | T0 |
| O1 OBSERVE | type, representation, namespace, documentation, status, failure, metadata, runtime identity | T1 |
| O2 SELECT + TRANSFORM | glob, filter, map, parse, normalize, rank, aggregate, serialize | T1–T2 |
| O3 COMPOSE | value flows, structured subprocess boundaries, reusable functions, aliases | T2 |
| O4 CONTROL | predicates, branching, iteration, assertions, bounded retries | T2 |
| O5 AUTOMATE | filesystem/process orchestration, HTTP/API work, JSON, repeatable operations | T2 or project work |
| O6 QUALIFY | assumptions, preconditions, expected state, observations, assertions, postconditions, pytest, idempotence | Project work |
| O7 INSTRUMENT | timing, structured observations, failure context, provenance, tracing | Project or engineering work |
| O8 PROJECT | scripts, CLIs, libraries, TUIs, data/analytics tools, reusable infrastructure | Project or engineering work |

Do not advance because a feature exists. Advance when a concrete operation
cannot remain clear, observable, and adequately validated at the current
surface.

## Workstation execution boundaries

The workstation migration plan provides a concrete system on which to practice
boundary reasoning. It separates four roles:

```text
system/login compatibility   Bash
interactive terminal         Xonsh
project Python realization   uv + project .venv
system Python                OS-owned and untouched
```

Treat these as different execution authorities, even when they are visible in
one terminal session.

| Boundary | Operational contract |
| --- | --- |
| Bash | Login, recovery, and explicit POSIX `-lc` compatibility. |
| Xonsh | Persistent interactive Python/process crossing and composition. |
| `uv` project runtime | Explicit project interpreter, dependency, and command realization. |
| `/usr/bin/python` | OS-owned runtime; not a workstation tooling target. |

This has direct learning consequences:

```text
existing POSIX wrapper works
    -> keep Bash as an explicit admissible realization
    -> do not translate it into Xonsh merely for consistency

global interactive object/process work
    -> isolated Xonsh is the preferred manipulation surface

project execution
    -> cross explicitly through uv run

interactive access to project Python objects
    -> launch a project-mode Xonsh through uv
    -> treat it as a project interpreter, not the global shell runtime

system Python
    -> observe if necessary
    -> do not mutate for project or shell tooling
```

The migration itself is a real O5/O6 substrate, not an early syntax exercise.
Its implementation stages preserve a previous usable path until the next stage
has passed evaluation. Use the
[Xonsh workstation plan](../xonsh/implementation.md) as the authoritative
runbook for that migration rather than duplicating its commands here.

## Runbook contract

An ordinary Ops exercise needs only this compact runbook:

```text
TASK / G
    intended operation and success postcondition

CURRENT EVIDENCE + ASSUMPTIONS
    what is observed, what is inferred, and what may be stale

CONSTRAINTS
    properties that make a realization admissible

REALIZATION
    smallest adequate operation

OBSERVATION + VALIDATION
    evidence produced and predicates applied

REVISION
    claims confirmed, expired, retracted, or left unresolved
```

Use the expanded shape when state changes, provenance, capability limits, or
escalation pressure need to be explicit:

```text
TASK
    OP(WHAT | CONTEXT) -> RESULT

MODEL
    Eₙ       relevant external state
    Kₙ       accumulated provenance-bearing observations
    G        required postcondition
    current claims
             assertions derived from available evidence
    assumptions
             statements still requiring evidence

SEMANTICS
    DATA
    RULE
    OPERATION
    POLICY
    BOUNDARY
    COMPOSITION
    STATE

CONSTRAINTS
    C(Kₙ)
    properties that reduce the admissible set

ADMISSIBLE SET
    A(Kₙ)
    realizations that still satisfy the constraints

CAPABILITY
    current T tier
    allowed mechanisms
    deliberately withheld mechanisms

REALIZATION
    selected aₙ
    smallest adequate interactive or durable form

OBSERVATION
    oₙ
    runtime evidence produced by execution
    contradictions and failures remain visible

VALIDATION
    predicates used to evaluate the observation

REVISION
    evidence and provenance added to Kₙ₊₁
    current claims confirmed, expired, or retracted
    rejected claims and contradictions retained as observations

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

RESULT / G
    paths ordered by descending byte size
```

### Model

```text
E₀
    current working tree at the time of the run

K₀
    repository root is reachable

assumptions
    recursive traversal identifies candidate Python paths
    `.py` is the task's source-selection rule
    selected files remain available long enough to stat
    byte size is sufficient for the requested ranking

G
    every admitted result is a regular `.py` file
    each result has an observed byte size
    results are ordered by descending byte size
```

The assumptions become time-qualified assertions only when filesystem
observations support them for this run. A file disappearing between enumeration
and `stat()` is failure evidence, not permission to pretend the external state
was stable.

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
    traversal -> predicate -> stat projection -> sorted sequence -> rendering

STATE
    observation only; no filesystem mutation
```

The representation constraints are:

```text
preserve path identity
preserve one observed size value per selected path
ordering carries meaning
filesystem failures must remain observable
```

Candidate realizations may include subprocess tooling, Xonsh path operations,
or ordinary Python. For this task, direct path objects remain the smallest
adequate realization because no text/process crossing is required.

### T0 realization

Use ordinary Python path objects inside Xonsh. Explicit error handling keeps
traversal and metadata failures observable:

```xsh
from pathlib import Path
from stat import S_ISREG
import sys

failures = []


def report_failure(error):
    failures.append(error)
    print(f"filesystem observation failed: {error}", file=sys.stderr)

records = []
for root, _directories, filenames in Path.cwd().walk(on_error=report_failure):
    for name in filenames:
        path = root / name
        if path.suffix != ".py":
            continue
        try:
            metadata = path.stat()
        except OSError as error:
            report_failure(error)
            continue
        if S_ISREG(metadata.st_mode):
            records.append((path, metadata.st_size))

ranked = sorted(
    records,
    key=lambda item: item[1],
    reverse=True,
)

for path, size in ranked[:10]:
    print(f"{size:>10}  {path}")
```

The point is not the compact syntax. Identify each boundary:

```text
Path.cwd().walk(...)
    filesystem traversal -> Path objects + observable traversal failures

path.stat()
    Path -> filesystem observation or explicit OSError

S_ISREG(metadata.st_mode)
    observed metadata -> regular-file predicate

metadata.st_size
    observed metadata -> byte-size int

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

subject = ranked[0][0]

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
- When does traversal execute, and when does each `path.stat()` occur?
- Why must `sorted()` materialize the values before global ranking is known?
- Which failures can occur at the filesystem boundary?

Do not expand into unrelated `pathlib`, iterator, or sorting internals.

### T2 composition

If the operation recurs, extract only the stable value transformations:

```python
from stat import S_ISREG


def with_size(paths, *, on_error):
    for path in paths:
        try:
            metadata = path.stat()
        except OSError as error:
            on_error(error)
            continue
        if S_ISREG(metadata.st_mode):
            yield path, metadata.st_size


def rank_by_size(records):
    return sorted(records, key=lambda item: item[1], reverse=True)
```

The extraction is justified only if it improves reuse or makes the contracts
more observable. It is not required merely because functions are available.

### Validation and revision

For an interactive run, validate at least the observable predicates that define
`G`:

```text
each selected path has `.py` suffix
and
each selected path was observed as a regular file
and
each admitted record contains an observed byte size
and
size[i] >= size[i + 1] for the ranked sequence
and
failures is empty when claiming the traversal is complete
```

The observations and provenance may then enter `K₁`. Failures, races, or
contradictory observations remain visible and prevent the affected current-state
claim from being confirmed.

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

## Live system substrate — Xonsh migration

The workstation migration is the current larger-scale Ops exercise. It should
be approached with the same model rather than as a configuration rewrite.

```text
E₀
    existing workstation/session behavior
    Zsh currently participates in interactive/environment realization

K₀
    observations of the current login, terminal, environment, and runtimes

G
    Bash remains usable for login/recovery
    WezTerm opens Xonsh for normal interactive work
    POSIX wrapper commands still work through Bash
    PATH/XDG/session semantics remain equivalent where required
    Xonsh uses an isolated uv-managed interpreter
    project commands use the project interpreter through uv
    project-mode Xonsh imports project dependencies through uv
    system Python remains untouched
    no durable project semantics depend on Xonsh
```

Each migration stage is therefore:

```text
current evidence Kₙ + assumptions about Eₙ
  ↓
derive stage constraints
  ↓
select smallest reversible change
  ↓
execute
  ↓
observe runtime identity + behavior
  ↓
validate stage invariants
  ↓
record evidence in Kₙ₊₁ and revise current claims
  ↓
only then retire the superseded realization
```

Do not reproduce the migration implementation here. Continue in the
[Xonsh workstation migration implementation plan](../xonsh/implementation.md),
which owns its exact target contract, sequencing, and acceptance gate.

## Practice queue

The next useful runbooks should come from actual terminal work rather than
synthetic language exercises. Prefer this order until evidence suggests a
different need:

```text
filesystem observation
    -> process observation
    -> runtime identity: Bash / Xonsh / uv / system Python
    -> environment boundaries
    -> text vs structured subprocess output
    -> JSON / HTTP acquisition
    -> repeated filesystem/process operations
    -> pytest-qualified sysops
    -> workstation migration qualification
    -> instrumentation
    -> project projection
```

Each new runbook should reuse the same task contract and feedback path. New
abstractions are admitted only when repeated operational pressure demonstrates
the need.

## Exit condition

The Ops guide is working when an unfamiliar terminal task routinely triggers:

```text
intent
  -> state relevant Eₙ, current Kₙ, and G
  -> distinguish facts from assumptions
  -> constraint reduction
  -> admissible-set reduction
  -> smallest adequate realization
  -> targeted observation
  -> behavioral validation
  -> evidence-backed assertion / rejection
  -> Kₙ₊₁ + revised current-state claims
```

rather than:

```text
remember command
  -> try flags
  -> accumulate shell trick
```

The desired endpoint is not a more elaborate shell configuration. It is an
increasingly Python-native, inspectable, testable way to operate real systems.
