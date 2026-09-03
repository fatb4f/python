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
  -> T2+ FUNCTIONALIZE
  -> T3 EXTEND
  -> T4 PROJECT
  -> T5 ENGINEER
```

## Documents

- [Workstation migration implementation plan](implementation.md)
- [T0 — Cross](t0-cross.md)
- [T1 — Observe](t1-observe.md)
- [T2 — Compose](t2-compose.md)
- [T2+ — Functionalize](t2-functionalize.md)
- [T3 — Extend](t3-extend.md)
- [T4/T5 progression](progression.md)

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

Closing the shell must lose no project semantics. Prompt state, aliases,
history, environment values, and terminal integration are not durable project
authority.

Xonsh remains externally installed during the manual-first phase. These guides
are descriptive rather than CI-executed. When repeated executable examples
emerge, extract the smallest smoke specimens first; only observed drift should
trigger evaluation of a repository-level Xonsh dependency.
