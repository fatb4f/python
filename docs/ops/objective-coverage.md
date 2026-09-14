# Objective coverage over the Ops spine

Objective coverage is a projection over the existing Ops learning guide. It does not introduce a new progression.

## Projection rule

```text
external objective
    -> required semantic capability
    -> Ops family/families that exercise it
    -> operational task
    -> realization(s)
    -> evidence
    -> coverage state
```

## Coverage states

```text
uncovered
introduced
exercised
demonstrated
```

Suggested interpretation:

- `uncovered` — no admitted task/evidence currently supports the objective;
- `introduced` — the semantic capability has been observed/explained;
- `exercised` — at least one operational realization has been executed with observations;
- `demonstrated` — the required postconditions and evidence predicates have been satisfied.

Coverage state is derived from evidence; it is not inferred from calendar progress.

## Ops mapping

| Ops family | Objective coverage role |
| --- | --- |
| O0 CROSS | Observe and preserve process, I/O, compiler/runtime, path, and serialization boundaries. |
| O1 OBSERVE | Inspect type, representation, member surface, metadata, status, and failure. |
| O2 SELECT + TRANSFORM | Exercise scalar/collection operations, parsing, filtering, mapping, normalization, ranking, aggregation. |
| O3 COMPOSE | Exercise functions, methods, decomposition, reusable flows, object/library composition. |
| O4 CONTROL | Exercise predicates, branching, iteration, assertions, bounded control, input validation. |
| O5 AUTOMATE | Exercise files, structured serialization, process orchestration, repeatable data workflows. |
| O6 QUALIFY | Exercise preconditions, postconditions, expected behavior, tests, robustness, and deliverable-specific constraints. |
| O7 INSTRUMENT | Add timing, provenance, tracing, or richer failure context only where the task requires it. |
| O8 PROJECT | Integrate multiple capabilities into a durable application/data project. |

## Course projections

INF1120 and INF1035 objective sets should point into the same semantic/Ops graph wherever their requirements overlap.

Example:

```text
INF1120 selection + repetition
INF1035 boolean conditions + loops
        |
        v
semantic capability
    predicate + branch + iteration + state
        |
        v
O4 CONTROL
        |
        v
shared task
        |
    +---+---+
    |       |
 Python   Java
    |       |
    +---+---+
        v
validation evidence
```

This is preferable to duplicating exercises by course or language.

## Transfer evidence

`transfer` is optional but high-value evidence when a semantic operation has multiple relevant realizations.

Transfer is not "translate syntax". It must preserve the task contract while making runtime differences explicit.

Valid transfer questions include:

- Which representation carries the same semantic role?
- Which boundary moves from implicit to explicit?
- Which failures are compile-time, runtime, or data-validation failures?
- Which state is mutable, externally owned, or represented differently?
- Which properties of the task are invariant across realizations?

## Assessment boundary

Coverage of a learning objective and compliance of a submitted artifact are separate predicates.

```text
objective coverage
    semantic/behavioral capability evidence

submission compliance
    authorship/originality
    required format
    required behavior
    course correction rules
    submission procedure
```

A submitted artifact may be used as learning evidence, but the coverage system must not require assessed deliverables as its only evidence source.

## Escalation

Keep objective coverage manually inspectable at first. Generate reports, adapters, or query DSLs only after repeated use demonstrates concrete friction.
