# PPF learning model

## Status and provenance

This document is normalized from `fatb4f/ppf` theory drafts `01.md` and `02.md`
at revision `53af6aa42aec6fc104bbf2abe7410d125c7540cb`.

Within Python Immersion it is active learning vocabulary. It is not a claim
that the source drafts or their implementation details are permanent
architectural authority for other projects.

The source direction is preserved:

```text
domain meaning and variability
    ↓
contracts and admissible choices
    ↓
implementation and composition
    ↓
execution
    ↓
observation and revision
```

Source documents:

- [`docs/theory/drafts/01.md`](https://github.com/fatb4f/ppf/blob/53af6aa42aec6fc104bbf2abe7410d125c7540cb/docs/theory/drafts/01.md)
- [`docs/theory/drafts/02.md`](https://github.com/fatb4f/ppf/blob/53af6aa42aec6fc104bbf2abe7410d125c7540cb/docs/theory/drafts/02.md)

## Minimal ontology

### DATA

Values, entities, configuration, and results carry domain meaning. Choosing a
container is not neutral: order, multiplicity, uniqueness, identity, mutability,
and lifetime are semantic properties when the contract observes them.

### RULE

Rules constrain admissible values and behavior:

```text
type constraint · invariant · precondition · postcondition · failure contract
```

A rule should state what must remain true without prematurely selecting the
mechanism that enforces it.

### OPERATION

An operation is one semantic verb:

```text
query          DATA -> DATA
transform      DATA -> DATA
decision       DATA -> CHOICE
command        DATA -> EFFECT
constructor    CONFIG -> CAPABILITY
```

Names should express domain intent before implementation technique.

### POLICY

Policy selects among valid alternatives. It is meaningful only when more than
one alternative remains admissible and the choice can vary independently of
the core operation.

### BOUNDARY

A boundary changes representation, runtime, ownership, or authority. Ports,
adapters, serializers, files, processes, services, and databases are possible
boundary realizations; they are not synonyms for the boundary itself.

### COMPOSITION

Composition relates operations through sequence, branching, pipelines,
dependency graphs, or other interaction structures. Use the smallest structure
that states the observed relationship.

### STATE

State is information that persists or evolves. Its contract includes valid
states, events, transitions, ownership, lifetime, and failure semantics.

## Relations

```text
Data
  ──constrained-by──► Rule
  ──consumed-by─────► Operation
  ──produced-by─────► Operation

Operation
  ──selected-by─────► Policy
  ──composed-with───► Operation
  ──crosses─────────► Boundary

State
  ──changed-by──────► Operation
  ──constrained-by──► Rule
  ──observed-by─────► Query
```

The useful domain tuple is:

```text
Domain :=
(
  Data,
  Rules,
  Operations,
  States,
  Transitions,
  Policies,
  Boundaries
)
```

This is a questioning aid, not a required runtime schema.

## Python preference order

Start with the smallest ordinary Python form that preserves the contract:

```text
value / collection
    ↓
function
    ↓
function accepting behavior or policy
    ↓
small object with justified state
    ↓
protocol or adapter at a real boundary
    ↓
orchestration only when composition and state require it
```

Do not begin with a named pattern. Let variability and boundaries create the
pressure from which a pattern can be derived.

## Learning questions

For each task ask:

1. What is the DATA and which properties carry meaning?
2. Which RULES define admissibility and success?
3. What OPERATION is actually required?
4. Does a POLICY vary, or is there only one justified choice?
5. Which BOUNDARIES change representation or authority?
6. How are operations COMPOSED?
7. What STATE persists, who owns it, and how does it change?
8. Which observation could falsify the current model?

Use [task deconstruction](task-deconstruction.md) to reduce these answers into
admissible representations and realizations. Use [derived patterns](patterns.md)
only after the primitive conditions are visible.
