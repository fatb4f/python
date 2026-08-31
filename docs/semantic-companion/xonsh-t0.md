# Xonsh T0 — constraint-driven terminal projection

## Status

**Role:** optional semantic-companion realization profile  
**Scope:** native Xonsh fluency, Python data-shape recognition, and small terminal algorithms  
**Authority:** `reference.md` remains the semantic pattern atlas; this profile supplies a concrete terminal evaluation domain

This document does not define a parallel DSA curriculum and does not make Xonsh an architectural dependency of the repository.

Its purpose is narrower:

> Use ordinary terminal work to repeatedly derive Python types, structures, and algorithms from required properties and required operations.

The intended learning inversion is:

```text
not

known container / API
        ↓
search for somewhere to use it

but

intent
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
effect boundary
  ↓
execution
  ↓
observation
  ↓
evaluation
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

# 2. Tier 0 contract

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

# 3. Constraint analysis comes first

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
constraints
   ↓
required properties
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

# 4. Decision-tree modeling

The constraint workflow naturally introduces decision-tree data modeling.

A representation decision can be expressed as a series of predicates that progressively reduce the admissible design space:

```text
Does order carry meaning?
├─ yes
│  ├─ random access required?
│  │  ├─ yes → sequence / list
│  │  └─ no  → iterable / iterator may suffice
│  └─ duplicates meaningful?
│     ├─ yes → preserve sequence
│     └─ no  → explicit deduplication may be admissible
└─ no
   ├─ keyed retrieval required?
   │  └─ yes → mapping
   └─ unique membership required?
      └─ yes → set
```

The tree can continue from the selected structure into API and failure semantics:

```text
mapping required
   ↓
missing-key semantics?
├─ absence is an error
│    → mapping[key]
├─ absence is a normal query result
│    → mapping.get(...)
└─ absence should construct mutable state
     → defaultdict(...)
```

This is useful because it introduces, with immediately observable consequences:

```text
classification
feature / property extraction
branch predicates
state-space reduction
terminal choices
validation against constraints
```

The decision tree is itself data and may later be represented explicitly, but T0 does not require building a generic decision engine.

---

# 5. Atlas projection into terminal work

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
| Grouped index | build key → values access structures |
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

# 6. Filesystem objects as a primary T0 domain

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

---

# 7. Process boundary as an effect boundary

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

# 8. Minimal complexity intuition

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
    → consider constructing a set or mapping once

need order or multiplicity?
    → preserve a sequence

need only one pass?
    → avoid unnecessary materialization

crossing a subprocess boundary repeatedly?
    → consider collecting/filtering locally before invoking another effect
```

Complexity should remain tied to a required property or observable cost, not memorized as trivia.

---

# 9. T0 control loop

A small terminal task should follow this sequence:

```text
1. State intent.
2. Enumerate constraints.
3. Identify required invariants / properties.
4. Identify required operations.
5. Select the smallest admissible representation.
6. Select the corresponding algorithmic idiom from the atlas.
7. Identify the external effect boundary, if any.
8. Execute the operation.
9. Observe the resulting value, status, or failure.
10. Evaluate whether the original constraints were satisfied.
```

This makes proper workflow sequencing part of terminal fluency.

The anti-pattern is:

```text
pick a command / type / library first
        ↓
force the problem into it
```

The preferred sequence is:

```text
what must remain true?
        ↓
what operations must be supported?
        ↓
what representation preserves those properties?
        ↓
what is the smallest procedure that establishes the result?
```

---

# 10. Completion contract

T0 succeeds when the learner can routinely perform this derivation:

```text
external or local value
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
execution
      ↓
observation
```

Concretely, the learner should be comfortable with:

```text
✓ subprocess / Python mode switching
✓ Python ↔ subprocess interpolation
✓ command capture and structured conversion
✓ typed environment state
✓ aliases, navigation, history, and jobs
✓ Path and glob objects

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

✓ preserving process / filesystem failure boundaries
✓ observing the resulting Python object rather than reverting immediately to text processing
```

No Rich, Jedi, Coconut, custom macros, event hooks, or domain-specific shell framework is necessary to satisfy this contract.

---

# 11. Adoption ladder

The resulting progression is:

```text
T0 — native Xonsh + data-shape fluency
    constraints → representation → algorithm

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

# 12. Relationship to later workflow reasoning

The T0 sequence deliberately mirrors larger software-design reasoning without introducing those abstractions prematurely.

Small-scale terminal reasoning:

```text
intent
  ↓
constraints
  ↓
properties
  ↓
operations
  ↓
representation
  ↓
algorithm
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

The connection should remain conceptual during T0. The terminal profile is not intended to smuggle PPF architecture, workflow engines, generic adapters, or domain frameworks into the semantic companion.

The durable habit is simply:

> Analyze constraints before selecting representation, and select representation before selecting procedure.
