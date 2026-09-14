# UQAM objective operationalization

This architecture projects external UQAM course objectives into the existing Python Immersion semantic and operational model. It does not introduce a parallel academic learning framework.

Parent tracker: #6.

## Authority boundary

```text
fatb4f/factory course corpus
    external objective + evaluation evidence
              |
              v
objective projection
              |
              v
Python Immersion semantic model
DATA · RULE · OPERATION · POLICY · BOUNDARY · COMPOSITION · STATE
              |
              v
Ops task family
              |
              v
operational task contract
              |
      +-------+--------+
      |                |
      v                v
Python realization   Java realization
      |                |
      +-------+--------+
              v
observation / validation / transfer evidence
```

`fatb4f/python` remains authoritative for semantic decomposition, operational practice, capability escalation, realization selection, observation, validation, and qualification.

The UQAM corpus is an external source for:

- learning objectives to cover;
- evaluation and deliverable constraints;
- course-specific correction requirements where they apply to submitted work.

It is not authority over the user's private learning environment, shell, editor, LLMs, generators, test harnesses, or other tooling. Assessment constraints are modeled only at the deliverable/submission boundary.

## Core relation model

```text
Objective
    REQUIRES
SemanticCapability

OperationalTask
    EXERCISES
SemanticCapability

Realization
    REALIZES
OperationalTask

Evidence
    SUPPORTS
ObjectiveCoverage
```

The course sequence is therefore input data, not the organizing authority of the learning system.

## Operational contract

Every admitted exercise begins from the existing Ops model:

```text
TASK / G
    intended operation and success postcondition

CURRENT EVIDENCE + ASSUMPTIONS
    what is observed, inferred, or potentially stale

SEMANTICS
    DATA
    RULE
    OPERATION
    POLICY
    BOUNDARY
    COMPOSITION
    STATE

CONSTRAINTS
    properties that make a realization admissible

REALIZATION
    smallest adequate Python / Java / Xonsh / process / library operation

OBSERVATION + VALIDATION
    runtime evidence and predicates

REVISION
    claims confirmed, rejected, expired, or left unresolved
```

The new academic projection only adds an explicit coverage relation around this existing contract.

## Runtime boundary

Java is modeled as a runtime realization authority, not as a competing semantic model:

```text
Java source
  -> javac process boundary
  -> class/runtime representation
  -> java execution
  -> stdout/stderr/status or structured runtime observations
```

Python remains both a realization substrate and the primary inspection/composition environment. Xonsh remains the interactive process/Python crossing surface.

## Evidence model

Coverage evidence is intentionally behavioral rather than chapter-completion based:

- `explain` — state the semantic decomposition and constraints;
- `realize` — construct an admissible implementation;
- `observe` — inspect representation, runtime behavior, and failure modes;
- `validate` — establish postconditions with observable evidence;
- `transfer` — identify or realize the same semantic operation across another runtime or representation.

`transfer` is the main new learning evidence type because INF1120 and INF1035 overlap in control, decomposition, collections, boundaries, failure, and validation while differing in runtime realization.

## Repository surfaces

- `contracts/learning/objectives.cue` — generic objective/task/realization/coverage contract.
- `contracts/learning/uqam_a26.cue` — term-qualified external objective projection for INF1120 and INF1035.
- `docs/ops/objective-coverage.md` — how objective coverage composes with the Ops spine.
- `pre-implementation-analysis.md` — architecture qualification before code.
- `constraints-and-gaps.md` — explicit constraints, missing contracts, and implementation gates.

## Non-goals

- copying the UQAM weekly schedule into this repository;
- creating INF1120/INF1035-specific Xonsh capability tiers;
- treating Java or Python syntax as semantic authority;
- enforcing course tooling preferences outside a submitted deliverable boundary;
- generating assessed deliverables as the learning system's completion evidence;
- implementing an object-pipeline DSL before repeated operational friction justifies it.
