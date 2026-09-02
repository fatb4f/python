# Derived semantic patterns

This document is a recognition aid, not a catalog of conventional software
patterns. A pattern belongs here only when its derivation can be shown:

```text
primitive conditions
        ↓
decision pressure
        ↓
derived pattern
```

A named pattern is never a substitute for stating DATA, RULE, OPERATION,
POLICY, BOUNDARY, COMPOSITION, and STATE.

## Coverage

```text
DATA
    required values and observed values

RULE
    every required unique value must be observed
    order and multiplicity do not carry meaning

OPERATION
    decide whether the rule holds
        ↓
set relation / coverage pattern
```

Canonical shape: `required <= set(observed)`.

Do not use this pattern when order, count, adjacency, or proximity is part of
the contract.

## Tokenization and frequency

```text
DATA
    raw text

RULE
    token boundary and normalization policy

OPERATIONS
    recognize -> normalize -> accumulate
        ↓
token-frequency pattern
```

Keep recognition policy distinct from accumulation. A `Counter` can express
frequency reduction, but it does not decide whether punctuation, Unicode,
apostrophes, digits, or case distinguish tokens.

## Adjacent run grouping

```text
DATA
    ordered symbols

RULE
    adjacency and multiplicity carry meaning

STATE
    current symbol and run length

OPERATION
    identify transitions
        ↓
run-grouping pattern
```

Equal values separated by another value are different runs. Global grouping
is therefore inadmissible.

## Framed encoding and round trips

```text
BOUNDARY
    source values <-> encoded representation

RULE
    source and encoded grammars are distinct and unambiguous

OPERATIONS
    encode and decode

INVARIANT
    decode(encode(value)) == value for every admitted source value
        ↓
framing + round-trip pattern
```

The reverse direction may intentionally canonicalize an encoding; state the
equivalence relation rather than assuming byte-for-byte equality.

## Source, filter, transform, sink

This is one derived composition pattern, not universal task-decomposition
authority:

```text
COMPOSITION
    values flow through ordered operations

OPERATION roles
    produce, select, project, consume/effect

BOUNDARY
    effects remain explicit at the terminal operation
        ↓
SOURCE -> FILTER -> TRANSFORM -> SINK
```

A single tool may play different roles in different compositions. Do not infer
a semantic role from a command or library name.

## Strategy-like structure

```text
OPERATION
    fixed semantic contract

POLICY
    multiple admissible algorithms vary independently
        ↓
strategy-like structure
```

In Python the smallest realization is often a function passed as a value. A
class hierarchy is not implied.

## Higher-order operation

```text
OPERATION
    behavior is accepted or returned as data

POLICY
    reusable execution behavior wraps the operation
        ↓
higher-order function
```

Examples of pressure include retry, timing, filtering, batching, or validation
that is genuinely reusable across operations.

## Factory-like structure

```text
OPERATION
    construct or resolve a capability

POLICY
    implementation choice varies

RULE
    selected capability must satisfy one contract
        ↓
factory-like structure
```

Use direct construction or a small function until lifecycle or variability
requires more.

## Adapter-like structure

```text
BOUNDARY
    representation or API changes

OPERATION
    semantic intent must remain stable across the crossing
        ↓
adapter-like structure
```

An adapter translates. It does not become semantic authority for the operation
it carries.

## Orchestrator-like structure

```text
COMPOSITION
    several operations have meaningful ordering or dependency

STATE
    progress or outcome evolves across them
        ↓
orchestrator-like structure
```

Ordinary sequential code remains preferred until ordering, branching,
recovery, or retained execution state creates real coordination pressure.

## Admission rule

Before adding a pattern, record:

1. the primitive conditions;
2. the decision pressure they create;
3. the smallest Python realization;
4. a boundary or misuse case;
5. evidence from a specimen or project that the shape recurs.

Without those five items, keep the observation local rather than expanding
this document.
