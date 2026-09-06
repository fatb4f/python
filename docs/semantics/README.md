# Semantic practice

PPF is the horizontal semantic practice used throughout Python Immersion. It
supplies a small vocabulary for asking what a computational thing is before a
representation, library, pattern, or shell mechanism is selected.

## Status

```text
Source:
    normalized from fatb4f/ppf docs/theory/drafts/01.md and 02.md

Role in fatb4f/python:
    active learning semantic model

Epistemic status:
    adopted learning vocabulary,
    not automatically architectural authority for other projects
```

The normalized source revision is
`53af6aa42aec6fc104bbf2abe7410d125c7540cb`.

## Core vocabulary

```text
DATA · RULE · OPERATION · POLICY · BOUNDARY · COMPOSITION · STATE
```

These are questions, not boxes that every task must fill:

- **DATA:** what representation carries the subject?
- **RULE:** what constraints, predicates, preconditions, or invariants govern
  it?
- **OPERATION:** what query, transformation, decision, command, or construction
  is actually required?
- **POLICY:** what choice can vary independently of mechanism?
- **BOUNDARY:** where does representation, runtime, or authority change?
- **COMPOSITION:** how do operations combine?
- **STATE:** what information persists or evolves?

Factory, higher-order function, adapter, orchestrator, strategy, pipeline,
state machine, and similar names are derived shapes. They are introduced only
when primitive conditions create the corresponding decision pressure.

## Documents

- [PPF learning model](ppf.md) normalizes the source vocabulary and relations.
- [Task deconstruction](task-deconstruction.md) reduces a task into admissible
  choices before realization.
- [Typed Python explorer](typed-python-explorer.md) specializes candidate
  reduction into a thin PowerShell-like typed inspection/query surface for
  Python objects and constructs.
- [Derived patterns](patterns.md) records reusable shapes without becoming a
  conventional pattern catalog.

Apply these documents continuously across the
[capability progression](../xonsh/README.md). Xonsh provides a realization and
observation environment; it does not own the semantic model.
