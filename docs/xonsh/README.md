# Xonsh capability progression

Xonsh is the vertical capability axis for applying the repository's
[semantic practice](../semantics/README.md) to ordinary terminal work. It is a
Python-aware process environment, not semantic authority.

The [Ops learning guide](../ops/README.md) owns the order of concrete practice.
These documents explain the capability available when an operation reaches a
given tier.

```text
T0 CROSS
  -> T1 OBSERVE
  -> T2 COMPOSE
  -> T3 EXTEND

T2+ FUNCTIONALIZE
  optional notation branch from T2; not a prerequisite for T3

PROJECT -> ENGINEER
  independent scope and maturity progression
```

## Documents

- [Workstation migration implementation plan](implementation.md)
- [T0 — Cross](t0-cross.md)
- [T1 — Observe](t1-observe.md)
- [T2 — Compose](t2-compose.md)
- [T2+ — Functionalize](t2-functionalize.md)
- [T3 — Extend](t3-extend.md)
- [Project and engineering progression](progression.md)

## Authority boundary

```text
repository files
    durable source, tests, and configuration

uv
    project interpreter and dependency realization

Python / libraries
    language and API behavior

Xonsh
    interactive Python/process crossing and composition
```

Closing the shell must lose no durable project semantics. Prompt state,
aliases, history, environment values, and terminal integration are not durable
project authority.

Xonsh remains externally installed during the manual-first phase. These guides
are descriptive rather than CI-executed. When repeated executable examples
emerge, extract the smallest smoke specimens first; only observed drift should
trigger evaluation of a repository-level Xonsh dependency.

## Runtime modes

The normal workstation shell and a project's Python runtime are intentionally
different environments:

```text
global Ops Xonsh
    isolated uv tool interpreter
    stdlib + explicitly installed shell/inspection dependencies

project-mode Xonsh or Python
    launched through the project uv environment
    project dependencies are importable
```

Use the global shell for terminal composition and cross project boundaries
through `uv run`. When a task requires persistent interactive access to project
Python objects, launch a project-mode Xonsh through `uv`; that process is a
project runtime, not the global shell authority.
