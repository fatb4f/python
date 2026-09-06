# Task deconstruction

Task deconstruction turns an intended result into a constrained set of
admissible realizations. It is general semantic practice, not a Xonsh-specific
procedure.

## Compact task model

```text
TASK := OP(WHAT | CONTEXT) -> RESULT
```

```text
WHAT
    the subject being observed or acted on

CONTEXT
    scope and constraints already known

OP
    the semantic operation required

RESULT
    the postcondition that defines success
```

A command, function, type, library, or service is a possible realization of a
task. It is not the task itself.

## Derivation

```text
WHAT + CONTEXT + RESULT
          ↓
constraints
          ↓
properties / invariants
          ↓
admissible operations
          ↓
admissible representations
          ↓
algorithm
          ↓
realization
          ↓
validation
```

Each step should reduce uncertainty without smuggling in an implementation
choice from a later step.

## Precision ladder

Increase precision only as the task demands:

```text
exploratory
    discover shape or state
        ↓
targeted
    narrow candidates with known properties
        ↓
surgical
    identify an exact subject or structural predicate
```

For example:

```text
What Python files exist?                 exploratory
Which Python files contain tests?        targeted
Which test modules exceed a threshold?   surgical
```

Do not construct a precise pipeline around a subject that is not yet
sufficiently understood.

## Constraint classes

### Semantic constraints

What meaning must be preserved? Which results count as equivalent?

### Representation constraints

Does order, multiplicity, uniqueness, keyed identity, mutability, or random
access carry meaning?

### Operational constraints

Which queries or transformations must the representation support: lookup,
grouping, ranking, aggregation, traversal, or incremental consumption?

### Resource constraints

Is memory bounded? Are repeated scans material? Is a subprocess or network
crossing expensive?

### Boundary constraints

Does the task cross a filesystem, process, serialization, database, service,
or authority boundary? Which evidence must survive the crossing?

### Failure constraints

What can fail? Which failures are expected domain results, and which are
unexpected mechanism failures? How must they remain observable?

## Admissible-set reduction

Selection begins with a candidate set and removes choices that violate known
constraints:

```text
candidate representations R₀
          ↓ apply C₁
R₁ ⊆ R₀
          ↓ apply C₂
R₂ ⊆ R₁
          ↓ ...
admissible representations R*
          ↓ policy, evidence, or simplest adequate choice
selected representation
```

The same abstraction applies at other levels:

```text
candidate algorithms
candidate libraries
candidate APIs
candidate execution substrates
candidate compositions
```

A constraint may eliminate a candidate; a policy selects among candidates that
remain valid. Policy must not make an invalid candidate admissible.

PPF supplies the questions that drive reduction:

| Primitive | Selection pressure |
| --- | --- |
| DATA | Required representation properties |
| RULE | Admissibility predicates |
| OPERATION | Required interfaces and supported transformations |
| POLICY | Choice among valid alternatives |
| BOUNDARY | Allowed crossings and evidence preservation |
| STATE | Ownership, lifecycle, mutation, and storage form |
| COMPOSITION | Interaction and ordering structure |

## Semantic refinement and feedback

The task model distinguishes changing external state from accumulated
evidence about that state.

```text
Eₙ
    external state at step n; it may change non-monotonically

Kₙ
    accumulated observations, with time and provenance

G
    desired RESULT / postcondition

C(Kₙ)
    constraints derived from evidence and declared assumptions

A(Kₙ)
    actions or realizations admissible under those constraints

J(a, Kₙ)
    policy or observable cost used only among admissible choices
```

The model supplies assumptions about external state. Constraint analysis
determines what remains admissible. Execution and observation test those
assumptions and add provenance-bearing evidence to the knowledge record.

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

An assumption is not an assertion. Assertions require observed evidence that
satisfies the relevant predicate or postcondition.

The admissible set is:

```text
A(Kₙ) = {a | constraints(Kₙ, a) hold}
```

Selection is conceptually:

```text
aₙ = simplest or lowest-cost adequate a
     subject to a ∈ A(Kₙ)
```

Execution may change external state and yields an observation:

```text
aₙ
 ↓
Eₙ -> external system -> Eₙ₊₁
 ↓
observation oₙ
 ↓
validate / record with provenance
 ↓
Kₙ₊₁
```

External state is not monotonic: files disappear, processes exit, and
configuration changes. A current-state assertion may therefore expire or be
retracted when newer evidence contradicts it.

The evidence record can still grow monotonically:

```text
Kₙ ⊑ Kₙ₊₁
```

The successor retains earlier observations and their provenance while adding
new evidence. Contradiction revises the current-state model without erasing
the fact that the earlier observation occurred.

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

This information order applies to the evidence record, not to the external
system or every assertion derived from it. Ordinary tasks need only record the
observation, its provenance, and whether it supports, expires, or contradicts
a current claim. A formal lattice mechanism is warranted only when repeated
use requires one.

## Representation decisions

A representation decision is a series of predicates, not a memorized lookup
table:

```text
Does order carry meaning?
├─ yes
│  ├─ random access required?
│  │  ├─ yes -> sequence / list remains admissible
│  │  └─ no  -> iterable / iterator may remain admissible
│  └─ duplicates meaningful?
│     ├─ yes -> set is inadmissible
│     └─ no  -> explicit deduplication may remain admissible
└─ no
   ├─ keyed retrieval required?
   │  └─ yes -> mapping remains admissible
   └─ unique membership required?
      └─ yes -> set remains admissible
```

The tree can continue into API and failure semantics:

```text
mapping required
   ↓
missing-key semantics?
├─ absence is an error
│    -> mapping[key]
├─ absence is a normal query result
│    -> mapping.get(...)
└─ absence constructs mutable state
     -> defaultdict(...)
```

The decision tree may later become data, but ordinary reasoning is sufficient
until repeated use justifies a reusable mechanism.

## Complexity as a constraint

Complexity matters only when it changes admissibility or an observable cost:

```text
repeated membership scans
    -> a one-time set or mapping construction may become admissible

order or multiplicity required
    -> sequence preservation remains mandatory

one-pass bounded-memory input
    -> unnecessary materialization becomes inadmissible

repeated process crossings
    -> local collection or filtering may reduce boundary cost
```

Do not use complexity notation as detached trivia.

## Control loop

1. State intent.
2. Identify WHAT.
3. Establish CONTEXT, relevant external state `Eₙ`, and current knowledge `Kₙ`.
4. Declare the RESULT postcondition `G`.
5. Choose exploratory, targeted, or surgical precision.
6. Identify assumptions, constraints, and invariants.
7. Derive the required operations.
8. Reduce candidate representations to an admissible set.
9. Reduce candidate algorithms and realizations.
10. Select the smallest adequate choice, applying policy only among valid
    alternatives.
11. Execute while preserving boundary and failure evidence.
12. Observe the result.
13. Validate the observation against the original predicates and postcondition.
14. Record evidence and provenance in `Kₙ₊₁`; keep contradictions observable.
15. Confirm, expire, or retract current-state assertions as evidence requires.
16. Repeat until the RESULT postcondition holds or no admissible realization
    remains.

The anti-pattern is selecting a command, library, type, or pattern first and
forcing the problem into it.

## Worked shape

```text
TASK
    rank Python files in a repository by size

WHAT
    filesystem files

CONTEXT
    one repository subtree
    .py suffix
    regular files only

RESULT
    paths ordered by descending byte size

constraints
    preserve path identity
    size must be observable
    ordering matters

operations
    enumerate, select, project size, rank

admissible representation
    iterable[Path] -> sequence[(Path, int)]

algorithm
    selection + keyed sorting

realization
    Python, Xonsh, or a suitable subprocess tool
```

The semantic task remains stable across those realizations.
