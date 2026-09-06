# Python Immersion

Python Immersion is a small incubator for learning through semantic practice,
an inspectable Python/Xonsh environment, and real computational projects.

The repository has two independent learning axes:

```text
PPF semantic practice
    what kind of computational thing is this?

Python + Xonsh capability
    how does this computational environment behave?
```

They meet in one feedback loop:

```text
task
  -> semantic decomposition
  -> representation and realization
  -> inspection
  -> execution and observation
  -> revised semantic model
```

See [the learning contract](docs/learning.md) for the complete architecture and
[the migration plan](docs/python-immersion-plan.md) for the staged transition
from the repository's historical Exercism origin.

## Start

The repository targets CPython 3.14. Install `uv` and `just`, then prepare and
validate the current environment:

```sh
just sync
just test
```

Rich is the initial runtime observation dependency. Xonsh and Coconut remain
external, user-managed runtimes until repeated executable examples justify a
repository-level dependency.

## Learning model

The horizontal semantic vocabulary is:

```text
DATA · RULE · OPERATION · POLICY · BOUNDARY · COMPOSITION · STATE
```

The vertical capability progression is:

```text
T0 CROSS
  -> T1 OBSERVE
  -> T2 COMPOSE
  -> T3 EXTEND

T2+ FUNCTIONALIZE is an optional branch from T2.
PROJECT -> ENGINEER is an independent scope and maturity progression.
```

Start with the [Ops learning guide](docs/ops/README.md). It owns progression
through concrete terminal operations while composing
[semantic practice](docs/semantics/README.md), the
[Xonsh capability progression](docs/xonsh/README.md), and
[stdlib exploration](docs/python/stdlib-exploration.md) as supporting models.

## Repository shape

- `docs/` owns the learning contract, Ops progression, and capability references.
- `specimens/` contains small semantic specimens with explicit contracts.
- `tests/` contains their behavioral claims and environment checks.
- `projects/` and `experiments/` appear only when real work earns those
  surfaces; no placeholder topology is maintained.

Candidate project substrates include DuckDB, Ibis, BigQuery, Marimo, Arrow,
Rich, and OpenTelemetry. They are possibilities, not curriculum requirements.

## Escalation rule

```text
manual understanding
  -> repeated use
  -> observed friction
  -> smallest useful abstraction
  -> evaluation
  -> retain or remove
```

The same rule governs shell extensions, Coconut, static tooling, project
scaffolding, and future domain libraries.
