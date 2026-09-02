# Learning contract

Python Immersion combines two independent axes:

```text
                 SEMANTIC AXIS
                     PPF

 DATA · RULE · OPERATION · POLICY
 BOUNDARY · COMPOSITION · STATE
                       │
                       │ continuously applied
                       ▼

T0 CROSS → T1 OBSERVE → T2 COMPOSE → T2+ FUNCTIONALIZE
                                      ↓
                                  T3 EXTEND
                                      ↓
                                  T4 PROJECT
                                      ↓
                                  T5 ENGINEER
                       XONSH / PYTHON
```

The semantic axis asks what kind of computational thing is present. The
capability axis asks how the environment behaves and which mechanisms can
realize the intended operation. Neither axis owns the other.

## Feedback loop

```text
task
  ↓
semantic decomposition              PPF
  ↓
choose representation
  ↓
realize / manipulate                Python + Xonsh
  ↓
inspect                             Rich / pydoc / CPython
  ↓
execute
  ↓
observe                             runtime / pytest
  ↓
revise semantic model
  └───────────────────────────────↺
```

The loop begins with a task rather than a library or pattern. Constraints
reduce the admissible representations and realizations. Direct inspection and
behavioral evidence then test whether the model was adequate.

## Three layers

```text
SEMANTIC PRACTICE
    PPF
    What is this computational thing?

OBSERVATION / MANIPULATION ENVIRONMENT
    Python + Xonsh + Rich + pydoc + CPython
    How does it actually behave?

REAL COMPUTATION
    Projects and domain libraries
    What useful thing can be constructed from it?
```

The standard library spans the last two layers. At T1 it is an object and API
exploration substrate. At T4 its modules become components of real tools.

## Operational spine

The [Ops learning guide](ops/README.md) owns progression through concrete
terminal work. It begins from a task, applies semantic deconstruction
horizontally, and adopts Xonsh/Python capabilities vertically only when the
operation requires them.

The semantic and capability documents remain reference models. The Ops guide
determines what to practice next.

## Capability tiers

| Tier | Contract |
| --- | --- |
| T0 Cross | Move deliberately between subprocess results, Python values, paths, environment state, and structured representations. |
| T1 Observe | Inspect runtime identity, representation, namespace, documentation, signature, source, and behavior. |
| T2 Compose | Combine native Python and Xonsh operations without hiding their boundaries. |
| T2+ Functionalize | Adopt Coconut only where demonstrated transformation pressure makes functional notation clearer. |
| T3 Extend | Change shell behavior with callable aliases, macros, events, completers, or interaction hooks. |
| T4 Project | Introduce libraries because an actual computational problem requires them. |
| T5 Engineer | Build reusable infrastructure only after repeated use and evaluation justify it. |

No tier requires abstractions from a later tier.

## Escalation rule

```text
manual understanding
       ↓
repeated use
       ↓
observed friction
       ↓
smallest useful abstraction
       ↓
evaluation
       ↓
retain or remove
```

This rule applies to Coconut, Xonsh extensions, static tools, explorers,
project scaffolding, and domain dependencies. Availability alone is not an
adoption reason.

## Completion evidence

Learning is demonstrated by an explanation and observable behavior, not by a
progress counter. For a task or specimen, be able to state:

- the DATA, RULE, OPERATION, POLICY, BOUNDARY, COMPOSITION, and STATE that are
  actually present;
- the result contract and relevant constraints;
- why the selected representation and realization remain admissible;
- what runtime or test evidence supports the claim;
- what observation would cause the model to be revised.

Start with the [Ops learning guide](ops/README.md). Use
[semantic practice](semantics/README.md), the
[Xonsh capability progression](xonsh/README.md), and
[standard-library exploration](python/stdlib-exploration.md) as the supporting
models it composes.
