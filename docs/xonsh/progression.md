# Project and engineering progression

Project scope and engineering maturity are independent of the Xonsh capability
tiers. A project may begin with T0–T2 shell capabilities, and shell extension
is never a prerequisite.

## Project

An actual computational problem may introduce a library or service:

```text
problem
    ↓ semantic decomposition
required operations and boundaries
    ↓ admissible-set reduction
library enters because it solves part of the task
```

Candidate substrates include DuckDB, Ibis, BigQuery, Marimo, Arrow, Rich,
OpenTelemetry, and the standard library. The list is intentionally open-ended.
No candidate is a curriculum requirement, and no empty project or technology
document is created in advance.

Each project owns its dependency boundary and behavioral evidence. The root
environment should not accumulate every prospective library.

## Engineer

Engineering begins only when several real uses establish stable semantics and
repeated friction. A framework, explorer, plugin, xontrib, shared package, or
orchestration layer must earn its existence through evidence.

```text
manual use
    ↓ repeated examples
stable contract
    ↓ observed friction
small abstraction
    ↓ evaluation against direct operation
retain, revise, or remove
```

Engineering must preserve escape hatches to direct Python, Xonsh, and library
interfaces. The abstraction may organize evidence; it must not silently become
semantic authority.

## Static-tooling gate

Ruff, ty, and other qualification tools are candidates under the same rule.
Reintroduce a tool when executable project code establishes the checks,
configuration, and failure semantics that make it an active repository
contract—not because the tool was present in an earlier topology.
