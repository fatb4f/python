# Ops learning guide

This guide is the operational spine of Python Immersion. It begins with real
terminal work and uses the repository's semantic and capability documents as
supporting models.

It does **not** teach Xonsh or Python feature-by-feature.

```text
task
  ↓
model current world Wₙ + goal G          PPF
  ↓
identify assumptions + constraints
  ↓
reduce to admissible realizations A(Wₙ)
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
admit supported assertions into Wₙ₊₁
  └────────────────────────────────────↺ until G or no admissible action
```

The stable question is:

> What operation is required, what constraints make a realization admissible,
> and what evidence is sufficient to turn assumptions about the current world
> into supported assertions about the next one?

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

For iterative work, make the state and goal explicit:

```text
Wₙ
    current modeled world

G
    required RESULT / postcondition

C(Wₙ)
    constraints induced by the current world

A(Wₙ)
    realizations admissible under those constraints
```

Use the full [task-deconstruction model](../semantics/task-deconstruction.md)
when the problem is not already obvious. For routine terminal work, the
following decision path is the compact entry point:

```text
1. What is Wₙ and what is the desired postcondition G?

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

An external execution does not silently rewrite the modeled world:

```text
Wₙ
 ↓
select admissible realization aₙ
 ↓
external system
 ↓
observation oₙ
 ↓
validate / admit
 ↓
Wₙ₊₁
```

Use the lightweight information-order invariant:

```text
Wₙ ⊑ Wₙ₊₁
```

A successor world contains at least the established information of its
predecessor. Contradictory evidence remains observable; it is not silently
converted into a replacement fact.

Two complementary refinements occur during work:

```text
constraints shrink the feasible set

S₀ ⊒ S₁ ⊒ S₂ ⊒ ... ⊒ S*

while evidence grows the known world

W₀ ⊑ W₁ ⊑ W₂ ⊑ ... ⊑ W*
```

For ordinary Ops learning this is enough lattice structure: information order,
constraint refinement, admission, and contradiction. Do not build a reusable
formal lattice mechanism until repeated use demonstrates that ordinary
reasoning is insufficient.

## Operational progression

Operations increase in composition, effects, and durability. The `O` labels
describe practice families; the `T` labels describe the Xonsh/Python capability
usually sufficient to realize them. They are not a replacement tier system.

| Ops family | Practice | Typical capability |
| --- | --- | --- |
| O0 CROSS | navigate, enumerate, invoke, capture, redirect, inspect environment and runtime boundaries | T0 |
| O1 OBSERVE | type, representation, namespace, documentation, status, failure, metadata, runtime identity | T1 |
| O2 SELECT + TRANSFORM | glob, filter, map, parse, normalize, rank, aggregate, serialize | T1–T2 |
| O3 COMPOSE | value flows, structured subprocess boundaries, reusable functions, aliases | T2 |
| O4 CONTROL | predicates, branching, iteration, assertions, bounded retries | T2 |
| O5 AUTOMATE | filesystem/process orchestration, HTTP/API work, JSON, repeatable operations | T2–T4 |
| O6 QUALIFY | assumptions, preconditions, expected state, observations, assertions, postconditions, pytest, idempotence | T4 |
| O7 INSTRUMENT | timing, structured observations, failure context, provenance, tracing | T4 |
| O8 PROJECT | scripts, CLIs, libraries, TUIs, data/analytics tools, reusable infrastructure | T4–T5 |

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

interactive object/process work
    -> Xonsh is the preferred manipulation surface

project execution
    -> cross explicitly through uv run

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

An Ops exercise is a small runbook. It should contain only the fields that
matter for the operation, but the complete shape is:

```text
TASK
    OP(WHAT | CONTEXT) -> RESULT

MODEL
    Wₙ       current modeled world
    G        required postcondition
    facts    already supported assertions
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
    C(Wₙ)
    properties that reduce the admissible set

ADMISSIBLE SET
    A(Wₙ)
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

ADMISSION
    supported assertions added to Wₙ₊₁
    rejected claims and contradictions retained as observable results

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
W₀
    current working tree is reachable
    repository paths can be observed

assumptions
    the glob identifies candidate Python paths
    `.py` is the task's source-selection rule
    selected files remain available long enough to stat
    byte size is sufficient for the requested ranking

G
    every admitted result is a regular `.py` file
    each result has an observed byte size
    results are ordered by descending byte size
```

The assumptions become assertions only when filesystem observations support
them for this run. A file disappearing between enumeration and `stat()` is
failure evidence, not permission to pretend the modeled world was stable.

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
preserve one observed size value per selected path
ordering carries meaning
filesystem failures must remain observable
```

Candidate realizations may include subprocess tooling, Xonsh path operations,
or ordinary Python. For this task, direct path objects remain the smallest
adequate realization because no text/process crossing is required.

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

### Validation and admission

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
```

The supported assertions may then enter the successor model `W₁`. Failures,
races, or contradictory observations remain visible and prevent the affected
claim from being admitted.

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
W₀
    existing workstation/session behavior
    Zsh currently participates in interactive/environment realization

G
    Bash remains usable for login/recovery
    WezTerm opens Xonsh for normal interactive work
    POSIX wrapper commands still work through Bash
    PATH/XDG/session semantics remain equivalent where required
    Xonsh uses an isolated uv-managed interpreter
    project commands use the project interpreter through uv
    system Python remains untouched
    no durable project semantics depend on Xonsh
```

Each migration stage is therefore:

```text
current Wₙ
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
admit supported assertions into Wₙ₊₁
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
  -> model Wₙ and G
  -> distinguish facts from assumptions
  -> constraint reduction
  -> admissible-set reduction
  -> smallest adequate realization
  -> targeted observation
  -> behavioral validation
  -> evidence-backed assertion / rejection
  -> Wₙ₊₁
```

rather than:

```text
remember command
  -> try flags
  -> accumulate shell trick
```

The desired endpoint is not a more elaborate shell configuration. It is an
increasingly Python-native, inspectable, testable way to operate real systems.
