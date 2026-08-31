# Xonsh T0 — constraint-driven terminal projection

## Status

**Role:** optional semantic-companion realization profile  
**Scope:** native Xonsh fluency, Python data-shape recognition, small terminal algorithms, and constraint-driven task decomposition  
**Authority:** `reference.md` remains the semantic pattern atlas; this profile supplies a concrete terminal evaluation domain

This document does not define a parallel DSA curriculum and does not make Xonsh or any terminal tool an architectural dependency of the repository.

Its purpose is narrower:

> Use ordinary terminal work to repeatedly derive Python types, structures, algorithms, and realizations from a stated task, required result, and explicit constraints.

The intended learning inversion is:

```text
not

known command / container / API
        ↓
search for somewhere to use it

but

intent
  ↓
identify subject
  ↓
establish context
  ↓
specify result
  ↓
constraints analysis
  ↓
required invariants / properties
  ↓
required operations
  ↓
representation choice
  ↓
algorithm choice
  ↓
realization choice
  ↓
execution
  ↓
observation
  ↓
validate result
```

The terminal is useful because it continuously presents small concrete problems involving files, processes, structured output, environment state, and collections. Xonsh lets those problems cross directly into Python objects without requiring a separate scripting phase.

---

# 1. Relationship to the semantic companion

The semantic companion already defines the reusable vocabulary:

```text
language construct
    -> built-in idiom
    -> stdlib primitive
    -> algorithmic idiom
    -> verb_noun helper
    -> helper composition
    -> configured behavior or justified state
    -> later domain pattern
```

Xonsh T0 projects that vocabulary into a terminal environment:

```text
semantic-companion/reference.md
        semantic vocabulary
                │
                ▼
        XONSH T0 PROJECTION
                │
      ┌─────────┼─────────┐
      ▼         ▼         ▼
   paths     process     structured
             output       data
      │         │          │
      └─────────┼──────────┘
                ▼
       interactive algorithms
```

The division of responsibility is:

```text
Semantic companion
    what the operation means

Xonsh
    where the operation becomes reflexive

Later domain work
    where the same operation participates in
    larger pipelines, validation, and workflows
```

Do not duplicate atlas entries here. When a T0 exercise uses selection, coverage, grouped indexing, frequency counting, keyed sorting, or another seeded pattern, use the semantics and boundaries already defined in `reference.md`.

---

# 2. Compact task model

A useful terminal task can be stated as:

```text
TASK := OP(WHAT | CONTEXT) -> RESULT
```

where:

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

This notation is intentionally more abstract than a terminal command.

For example:

```text
TASK:
    rank Python files in a repository by size

WHAT:
    filesystem files

CONTEXT:
    repository subtree
    Python suffix
    regular files only

RESULT:
    files ordered descending by size

required properties:
    preserve file identity
    size must be observable
    ordering matters

required operations:
    enumerate
    select
    project size
    rank

representation:
    iterable[Path]
        -> sequence[(Path, int)]

algorithm:
    selection + keyed sorting

realization:
    Xonsh / Python / suitable subprocess tool
```

The important boundary is:

```text
semantic task
    !=
terminal realization
```

A command, Python expression, Xonsh expression, or external utility is one possible realization of the task. Tool choice should be derived only after the task semantics are sufficiently explicit.

---

# 3. Precision ladder

Constraint analysis should become more precise only as required.

Use this three-level ladder:

```text
exploratory
    discover shape or state
    weakly constrained
        ↓
targeted
    reduce candidates
    enough structure to narrow the problem
        ↓
surgical
    exact identity or structural predicate
    strongly constrained operation
```

Examples:

```text
What Python files exist?
    -> exploratory

Which Python files are tests?
    -> targeted

Which test modules exceed a size threshold?
    -> surgical
```

The control question is:

```text
Do I know the subject sufficiently?
│
├─ no
│   -> explore and observe shape
│
├─ partly
│   -> add only enough constraints to narrow candidates
│
└─ yes
    -> perform the exact operation
```

This prevents premature construction of elaborate patterns or pipelines when the required information has not yet been established.

---

# 4. Tier 0 contract

T0 means **native Xonsh fluency**, not Bash compatibility followed by later Python adoption.

The baseline is mixed from the start:

```text
subprocess syntax
     ↕
Python expressions
     ↕
Python objects
```

T0 covers:

```text
T0 — Native Xonsh + data-shape fluency
│
├── language boundary
│   ├── subprocess mode
│   ├── Python mode
│   ├── Python ↔ subprocess interpolation
│   ├── capture operators
│   └── structured command-output conversion
│
├── native shell state
│   ├── typed environment
│   ├── aliases
│   ├── history / jobs / navigation
│   └── context-managed resources where encountered
│
├── concrete Python objects
│   ├── scalar values
│   ├── sequences / iterables
│   ├── mappings
│   ├── sets
│   ├── Path objects
│   └── captured process/result objects
│
├── semantic-companion operations
│   ├── iteration
│   ├── comprehension
│   ├── selection
│   ├── membership / coverage
│   ├── unpacking
│   ├── accumulation / indexing
│   ├── any / all
│   ├── sorting
│   ├── frequency counting
│   ├── grouping
│   ├── grouped indexing
│   ├── normalization
│   └── lazy consumption
│
└── terminal domains
    ├── filesystem
    ├── subprocess output
    ├── structured data
    ├── environment state
    └── small pipelines
```

Rich, Jedi, Coconut, custom macros, events, and project-specific shell machinery are not required for T0.

---

# 5. Constraint analysis comes first

Every T0 task should begin by identifying the properties that must be preserved or established.

Useful constraint classes are:

```text
semantic constraints
    what meaning must be preserved?

representation constraints
    does order matter?
    do duplicates matter?
    is identity keyed?
    is uniqueness required?

operational constraints
    lookup?
    grouping?
    ranking?
    aggregation?
    streaming?

resource constraints
    bounded memory?
    repeated scans?
    subprocess crossings?

boundary constraints
    filesystem?
    process?
    structured serialization?
    environment?

failure constraints
    what can fail?
    how must failure remain observable?
```

Only after these are explicit should the learner select a representation.

The core derivation is:

```text
WHAT + CONTEXT + RESULT
          ↓
constraints
          ↓
required properties / invariants
          ↓
required operations
          ↓
type / structure
          ↓
algorithm
```

Examples:

| Required property or operation | Likely representation / operation |
| --- | --- |
| Preserve order | sequence / iterator |
| Preserve duplicates | sequence; do not convert to set |
| Unique values | set |
| Repeated membership | set or mapping |
| Keyed retrieval | dict / mapping |
| Count occurrences | `Counter` or mapping accumulation |
| Group values by key | `dict[K, list[V]]` / `defaultdict(list)` |
| One-pass bounded-memory consumption | iterator / generator |
| Stable ranking | `sorted(key=...)` |
| Filesystem semantics | `Path` |
| Any value satisfies predicate | `any` |
| Every value satisfies predicate | `all` |
| Required values are covered | set subset relation |

The representation is therefore a consequence of the contract rather than the starting point.

---

# 6. Decision-tree modeling

The constraint workflow naturally introduces decision-tree data modeling.

A representation decision can be expressed as a series of predicates that progressively reduce the admissible design space:

```text
Does order carry meaning?
├─ yes
│  ├─ random access required?
│  │  ├─ yes -> sequence / list
│  │  └─ no  -> iterable / iterator may suffice
│  └─ duplicates meaningful?
│     ├─ yes -> preserve sequence
│     └─ no  -> explicit deduplication may be admissible
└─ no
   ├─ keyed retrieval required?
   │  └─ yes -> mapping
   └─ unique membership required?
      └─ yes -> set
```

The tree can continue from the selected structure into API and failure semantics:

```text
mapping required
   ↓
missing-key semantics?
├─ absence is an error
│    -> mapping[key]
├─ absence is a normal query result
│    -> mapping.get(...)
└─ absence should construct mutable state
     -> defaultdict(...)
```

This introduces, with immediately observable consequences:

```text
classification
property extraction
branch predicates
state-space reduction
terminal choices
validation against constraints
```

The decision tree is itself data and may later be represented explicitly, but T0 does not require building a generic decision engine.

---

# 7. Minimal pipeline roles

Small terminal workflows can be decomposed into four composition roles:

```text
SOURCE
    produces values
        ↓
FILTER
    preserves selected values
        ↓
TRANSFORM
    changes representation or value
        ↓
SINK
    consumes values or performs an effect
```

These are semantic roles rather than tool categories.

For example:

```text
glob paths
    SOURCE
      ↓
select files above threshold
    FILTER
      ↓
project size and rank
    TRANSFORM
      ↓
print / write / invoke command
    SINK
```

The same external command may play different roles in different workflows, and Python expressions may realize any non-effectful role. Do not infer a role from a tool name alone.

This vocabulary is intentionally smaller than a full ETL or workflow model. It exists only to make composition visible at T0.

---

# 8. Atlas projection into terminal work

The seeded semantic patterns map directly onto ordinary terminal problems.

| Atlas pattern | Terminal projection |
| --- | --- |
| Incremental iteration | consume glob, process, or decoded-output values |
| Comprehension | project/filter files or structured records |
| Membership / set relations | capabilities, filenames, extensions, required fields |
| `any` / `all` | health and requirement predicates |
| Dictionary accumulation | build keyed summaries or indexes |
| Structural unpacking | decompose fixed-shape results |
| `sorted(key=...)` | rank files, records, or observations |
| `Counter` | summarize extensions, statuses, diagnostics, events |
| `defaultdict` | group observations by key |
| Selection | preserve values satisfying a predicate |
| Coverage | compare required and observed sets |
| Frequency counting | histogram terminal observations |
| Grouped index | build key -> values access structures |
| Tokenization / normalization | turn text output into canonical values |
| Lazy iteration | avoid unnecessary materialization |

The important habit is to name the semantic operation before reaching for syntax.

For example:

```text
Need:
    unique suffixes

Derive:
    order not meaningful
    uniqueness required

Choose:
    set

Operation:
    set construction / projection
```

Or:

```text
Need:
    files grouped by parent directory

Derive:
    keyed retrieval required
    multiple values per key

Choose:
    dict[Path, list[Path]]

Operation:
    grouped index construction
```

---

# 9. Filesystem objects as a primary T0 domain

Treat filesystem entities as objects rather than arbitrary filename strings whenever the boundary allows it.

Conceptually:

```text
filesystem occurrence
      ↓
Path object
      ↓
properties + operations
```

A glob result can therefore become the input to ordinary semantic-companion operations:

```xsh
files = gp`**/*.py`

[p for p in files if p.stat().st_size > 1000]
[p.name for p in files]
sorted(files, key=lambda p: p.stat().st_size)
any(p.stat().st_size == 0 for p in files)
```

The point is not the syntax itself. The same values repeatedly exercise:

```text
iteration
selection
projection
ranking
predicate aggregation
```

with a concrete object model.

The subject-first rule is useful here:

```text
subject
    filesystem path

required operations
    compose paths
    inspect suffix
    query existence
    read content

required properties
    preserve filesystem identity and path semantics

representation
    Path
```

The representation follows from the required properties and operations.

---

# 10. Process boundary as an effect boundary

Subprocess execution should be recognized as an external effect rather than as an undifferentiated text pipeline.

```text
external process
      ↓
effect boundary
      ↓
capture / representation conversion
      ↓
Python value
      ↓
semantic transform
```

This aligns with the companion's existing distinction:

```text
PURE CORE
domain value -> domain value

EFFECT ADAPTER
filesystem / OS / process -> raw occurrence

OBSERVATION PROJECTION
raw occurrence -> structured observation
```

T0 does not require a formal adapter layer. It does require recognizing the boundary so that command output, process status, decoding failures, and semantic transformation are not collapsed into one opaque shell expression.

The general shape is:

```text
command
  ↓
capture
  ↓
recognize data shape
  ↓
select representation
  ↓
select / project / index / group /
count / rank / aggregate / quantify
  ↓
useful Python object
```

---

# 11. Minimal complexity intuition

Complexity belongs in T0 only where it changes an interactive design choice.

The useful approximations are:

```text
list / sequence scan
    membership is generally O(n)

set
    membership is expected O(1)

mapping
    keyed lookup/update is expected O(1)

sorting
    O(n log n)

single-pass iterator processing
    O(n) consumption with potentially bounded auxiliary space
```

The operational question is more important than notation:

```text
repeatedly scanning the same values?
    -> consider constructing a set or mapping once

need order or multiplicity?
    -> preserve a sequence

need only one pass?
    -> avoid unnecessary materialization

crossing a subprocess boundary repeatedly?
    -> consider collecting/filtering locally before invoking another effect
```

Complexity should remain tied to a required property or observable cost, not memorized as trivia.

---

# 12. T0 control loop

A small terminal task should follow this sequence:

```text
1. State intent.
2. Identify WHAT: the subject being acted on.
3. Establish CONTEXT: scope and known constraints.
4. Declare RESULT: the postcondition that defines success.
5. Choose the minimum useful precision: exploratory, targeted, or surgical.
6. Identify required invariants / properties.
7. Identify required operations.
8. Select the smallest admissible representation.
9. Select the corresponding algorithmic idiom from the atlas.
10. Compose source / filter / transform / sink roles where needed.
11. Choose a realization only now.
12. Execute and preserve external effect boundaries.
13. Observe the resulting value, status, or failure.
14. Validate the RESULT against the original constraints.
```

The anti-pattern is:

```text
pick a command / type / library first
        ↓
force the problem into it
```

The preferred sequence is:

```text
what am I acting on?
        ↓
what result defines success?
        ↓
what must remain true?
        ↓
what operations must be supported?
        ↓
what representation preserves those properties?
        ↓
what algorithm establishes the result?
        ↓
which realization is appropriate here?
```

This makes proper workflow sequencing part of terminal fluency.

---

# 13. Completion contract

T0 succeeds when the learner can routinely perform this derivation:

```text
TASK := OP(WHAT | CONTEXT) -> RESULT
                ↓
constraints analysis
                ↓
required properties
                ↓
required operations
                ↓
representation
                ↓
algorithm
                ↓
realization
                ↓
execution
                ↓
observation
                ↓
RESULT validation
```

Concretely, the learner should be comfortable with:

```text
✓ subprocess / Python mode switching
✓ Python ↔ subprocess interpolation
✓ command capture and structured conversion
✓ typed environment state
✓ aliases, navigation, history, and jobs
✓ Path and glob objects

✓ distinguishing subject, context, operation, and result
✓ increasing constraint precision only when needed
✓ recognizing when order, multiplicity, uniqueness, or keyed identity matters
✓ choosing sequence, iterator, set, mapping, or Path from those constraints
✓ iteration and structural unpacking
✓ comprehension as selection / projection / index construction
✓ set membership and coverage
✓ mapping lookup and accumulation
✓ any / all predicates
✓ keyed sorting
✓ frequency counting
✓ grouped indexing
✓ lazy consumption when materialization is unnecessary

✓ recognizing source / filter / transform / sink roles
✓ preserving process / filesystem failure boundaries
✓ selecting tools as realizations rather than semantic authorities
✓ observing the resulting Python object rather than reverting immediately to text processing
✓ validating the result against the original task contract
```

No Rich, Jedi, Coconut, custom macros, event hooks, or domain-specific shell framework is necessary to satisfy this contract.

---

# 14. Adoption ladder

The resulting progression is:

```text
T0 — native Xonsh + data-shape fluency
    task → constraints → representation → algorithm → realization

T1 — Python observation
    Rich, traceback, inspect, pydoc, pytest

T2 — interaction / discovery
    completion, Jedi, terminal/editor integration

T3 — functional orchestration
    deliberate object pipelines and composition

T4 — Xonsh metaprogramming
    macros, callable aliases, decorators, events,
    typed custom environment variables

T5 — domain projections
    stdlib exploration, data tooling,
    project-specific shell operations
```

T3 does not introduce object transformation. T0 already establishes that semantic model. T3 introduces more deliberate composition over already-understood objects and operations.

---

# 15. Relationship to later workflow reasoning

The T0 sequence deliberately mirrors larger software-design reasoning without introducing those abstractions prematurely.

Small-scale terminal reasoning:

```text
intent
  ↓
WHAT + CONTEXT + RESULT
  ↓
constraints
  ↓
properties / invariants
  ↓
operations
  ↓
representation
  ↓
algorithm
  ↓
realization
  ↓
execution
  ↓
observation
```

Later design reasoning may expand the same discipline into:

```text
use case
  ↓
constraints / invariants
  ↓
contract
  ↓
variability
  ↓
ports / types
  ↓
implementation
  ↓
composition
  ↓
execution
  ↓
observation
```

The connection should remain conceptual during T0. The terminal profile is not intended to smuggle a fixed terminal ontology, tool matrix, PPF architecture, workflow engine, generic adapter framework, or domain model into the semantic companion.

The durable habits are:

> Identify the subject and required result before choosing the representation.
>
> Analyze constraints before selecting procedure.
>
> Treat tools as realizations of semantic operations, not as the semantic model itself.
