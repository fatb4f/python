# Curriculum contract

This repository is a frozen, standalone transformation of the Exercism Python
track. The ordered stage tree is canonical; there is no upstream synchronization
layer.

## Progression rule

Within each stage:

1. Read the concept material in sequence order.
2. Complete core exercises before reinforcement or stretch work.
3. Run the exercise tests after each small implementation step.
4. Mark an item complete only when its tests pass and you can explain the solution.
5. Advance when the stage exit conditions are stable without hints.

The stages form a prerequisite-aware DAG projection. Items inside a stage are
ordered for learning ergonomics, not asserted to be strict dependencies unless
metadata states otherwise.

## Stages

| ID | Stage | Core items | All items |
|---:|---|---:|---:|
| 00 | [Orientation and feedback loop](../stages/00-orientation/README.md) | 4 | 4 |
| 01 | [Scalar types, expressions, and control flow](../stages/01-scalars-control-flow/README.md) | 14 | 27 |
| 02 | [Strings and text processing](../stages/02-text-processing/README.md) | 9 | 15 |
| 03 | [Sequences, iteration, and generators](../stages/03-sequences-iteration/README.md) | 20 | 42 |
| 04 | [Mappings, sets, and comprehensions](../stages/04-mappings-sets-comprehensions/README.md) | 17 | 21 |
| 05 | [Functions and functional composition](../stages/05-functions-functional-tools/README.md) | 9 | 14 |
| 06 | [Exceptions and resource boundaries](../stages/06-errors-resources/README.md) | 5 | 5 |
| 07 | [Classes and domain modeling](../stages/07-classes-modeling/README.md) | 12 | 20 |
| 08 | [Protocols and Python idioms](../stages/08-protocols-idioms/README.md) | 12 | 16 |
| 09 | [Standard-library problem solving](../stages/09-standard-library/README.md) | 8 | 22 |
| 10 | [Recursion and smaller data structures and algorithms](../stages/10-recursion-dsa/README.md) | 11 | 29 |
| 11 | [Integrated capstones](../stages/11-capstones/README.md) | 7 | 12 |

## Control surface

```bash
just verify
just next
just show <slug>
just test <slug>
just mark <slug>
just status
```

Use `--all` with `list`, `next`, or `status` to include reinforcement,
extension, preview, and stretch items.
