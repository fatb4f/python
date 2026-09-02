# T2+ — Functionalize

Coconut is an optional composition notation over Python values. It belongs
between native composition and shell extension because it changes how values
are expressed, not how the shell runtime behaves.

```text
external process
    ↓ capture / decode
Python values
    ↓ Coconut composition
transform / filter / project / reduce
    ↓
Python value, Rich rendering, or explicit effect boundary
```

## Admission pressure

Introduce Coconut only when a repeated transformation is materially clearer
as one or more of:

- pipeline notation;
- function composition;
- partial application;
- higher-order transformation.

Do not adopt it merely because the syntax is available, and do not translate
ordinary readable Python or Unix pipelines without demonstrated benefit.

## Evaluation

For a candidate composition:

1. retain the native version as the behavioral reference;
2. state the semantic operations and boundaries;
3. express the Coconut alternative;
4. compare readability, failure visibility, debugging, and interoperability;
5. retain it only if the loop improves.

Coconut remains externally managed until repeated, retained uses establish a
repository-level dependency contract.
