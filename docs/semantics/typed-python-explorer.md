# Typed Python explorer

> **Status:** prototype design note
> **Scope:** connect task deconstruction to a thin, queryable Python exploration
> surface. This document does not replace
> [task deconstruction](task-deconstruction.md); it specializes its candidate
> reduction model for Python learning and terminal operations.

## Working model

The practical reasoning sequence is:

```text
TASK
  │
  ▼
1. DOMAIN / PRIMITIVE DECOMPOSITION
  │
  ├─ OS / environment
  ├─ filesystem
  ├─ process
  ├─ protocol / network
  ├─ serialization
  ├─ collection
  ├─ database
  └─ other domain primitives
  │
  ▼
2. DATA / REPRESENTATION CONSTRAINTS
  │
  ├─ order
  ├─ uniqueness
  ├─ multiplicity
  ├─ identity / keying
  ├─ mutability
  ├─ boundedness
  ├─ eager / lazy behavior
  ├─ random access
  └─ ownership / lifecycle
  │
  ▼
3. REQUIRED OPERATIONS
  │
  ├─ lookup
  ├─ membership
  ├─ traversal
  ├─ grouping
  ├─ sorting / ranking
  ├─ aggregation
  ├─ transformation
  └─ mutation
  │
  ▼
ALGORITHM CONSTRAINTS
  │
  ▼
admissible representations + algorithms
  │
  ▼
REALIZATION
```

The ordering is intentional. Do not ask "list or set?" before establishing
whether order, multiplicity, membership behavior, identity, or mutation carry
meaning.

This is a working projection of the more general derivation in
`task-deconstruction.md`:

```text
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
```

## Decision tree as candidate reduction

The decision tree is not a cookbook. It is a human projection of constraint
application over candidate sets.

```text
candidate constructs S₀
        │
        ├─ preserves order?
        ▼
       S₁
        │
        ├─ allows multiplicity?
        ▼
       S₂
        │
        ├─ random access required?
        ▼
       S₃
        │
        ├─ mutation required?
        ▼
       S*
```

Each predicate removes candidates that no longer satisfy the task contract:

```text
S₀ ⊒ S₁ ⊒ S₂ ⊒ ... ⊒ S*
```

Policy chooses among the remaining valid candidates; it does not make an
invalid candidate admissible.

## CUE / lattice role

CUE is a natural fit when the repeated decision tree becomes worth encoding.
The desired shape is declarative:

```text
task facts
    +
construct facts
    ↓
constraint evaluation / unification
    ↓
admissible candidates
```

The tree then becomes one view of the underlying lattice rather than the
primary representation.

Do not formalize this prematurely. The current task-deconstruction model is
sufficient until repeated use demonstrates value in an executable candidate
lattice.

## Typed Python search surface

A useful companion is a PowerShell-like query surface over Python objects and
types.

PowerShell's strength is that object structure can be inspected and then
filtered/projected as data. The Python equivalent should preserve that
interaction model:

```text
object / type / module
        ↓
inspect members
        ↓
filter by structural properties
        ↓
project selected fields
```

Conceptual examples:

```text
members pathlib.Path
| where kind == method
| where name contains "read"
| select name, signature
```

```text
types
| has __iter__
| has __len__
| not has append
```

Eventually the same query model could operate across a catalog:

```text
constructs
| where iterable
| where mutable
| where random_access
| select name, module, methods
```

The objective is not SQL syntax specifically. The objective is a typed,
filterable object relation with a terminal-friendly projection.

## Two information layers

Keep structural facts separate from semantic capability claims.

### Runtime / structural facts

These can be obtained cheaply from Python itself:

```text
dir()
inspect.getmembers()
inspect.signature()
typing.get_type_hints()
MRO / bases
callability
member names and kinds
```

Examples:

```text
list has __iter__
list has __getitem__
list has append
```

### Semantic capability facts

These are stronger statements and should not be inferred casually from member
presence alone:

```text
list preserves order
list admits duplicates
list supports positional identity
set enforces uniqueness
mapping provides keyed identity
```

If the explorer grows into an executable candidate lattice, these semantic
claims should have explicit provenance and may be modeled declaratively in
CUE.

## `pydoc` role

`pydoc` is useful as a human documentation projection, not as the structured
query substrate.

```text
Python object / module
        ↓
pydoc
        ↓
human-oriented text / HTML
```

Parsing rendered `pydoc` output back into typed records would reverse the
information flow.

Prefer:

```text
structured inspection
        ↓
normalized records
        ↓
filter / select / query
        ↓
Rich or pydoc-style detail projection
```

A query result can therefore drill into a pydoc-like view without treating
pydoc output as authority.

## Thin prototype

Do not begin with Typeshed ingestion, a database, or a full Python knowledge
model.

Prototype the interaction first using runtime reflection.

A minimal normalized record is sufficient:

```text
Member
    owner
    name
    kind
    callable
    signature?
    annotations?
    inherited?
```

Possible terminal interaction:

```text
pm list
pm pathlib.Path
pm pathlib.Path --methods
pm pathlib.Path --where 'name ~= read'
pm list --has __getitem__
```

The exact command name and syntax are intentionally provisional.

### P0 evaluation

The prototype succeeds if it demonstrates that terminal-native typed
inspection materially improves these activities:

```text
1. discover the structural surface of an unfamiliar Python object
2. narrow members by property rather than visually scanning documentation
3. compare candidate types against required operations
4. move from a candidate to detailed documentation quickly
5. reinforce the task-decomposition reasoning model during normal Xonsh use
```

If the runtime-only surface proves useful, expand only where observed gaps
require it.

## Possible later expansion

A static/catalog layer may eventually combine:

```text
runtime reflection
Typeshed
Griffe or equivalent static API model
explicit semantic capability facts
```

with a normalized relation such as:

```text
construct
    id
    module
    name
    kind

member
    construct
    name
    kind
    signature
    return_type

property
    construct
    property
    value
    provenance
```

That relation could be materialized in DuckDB and queried through Ibis, but
those are candidate realizations rather than requirements of the learning
model.

## Integration with task deconstruction

The long-term intersection is:

```text
TASK CONSTRAINTS ─────┐
                     ├──► candidate reduction
PYTHON TYPE FACTS ────┘
```

The explorer should therefore teach reasoning rather than encode memorized
answers.

Instead of:

```text
"use a set for membership"
```

prefer:

```text
required:
    uniqueness
    efficient membership
    multiplicity not meaningful

query:
    which Python constructs remain admissible?
```

This makes the candidate lattice executable while preserving the semantic
practice established by `task-deconstruction.md`.

## Non-goals

The initial prototype should not attempt to become:

```text
a replacement for pydoc
an IDE/LSP
an exhaustive Python ontology
a static analyzer
a full Typeshed index
a general-purpose query engine
a hard-coded decision cookbook
```

The smallest useful experiment is a reflection-backed typed explorer used in
real terminal work. Larger machinery must be justified by observed learning or
operational value.
