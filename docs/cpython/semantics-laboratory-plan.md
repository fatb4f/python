# Exercism semantics laboratory plan

This plan layers typeshed, CPython, selected `library-fuzzers` ideas, and the
`neotest-python` adapter shape into the frozen Exercism curriculum. It extends
the [CPython companion layer](companion-plan.md); it does not create a second
curriculum or change the canonical Exercism sequence.

## Boundary and learning contract

The existing repository boundaries remain authoritative:

- `stages/` and `curriculum/` stay frozen and retain their current counts.
- `workbook/` contains optional labs, learner tests, source catalogs, and
  promoted regression fixtures.
- `python tools/path.py next` and `mark` continue to describe Exercism progress
  only.
- Companion completion is reported separately and never blocks the next core
  Exercism item.
- External repositories are pinned evidence sources, not runtime dependencies
  or vendored subtrees.

The learning progression is:

```text
example assertion
    ↓
learner-authored boundary test
    ↓
declared and runtime contracts
    ↓
process invocation and observation
    ↓
property and generated examples
    ↓
shrunk counterexample and regression
    ↓
combined evidence report
```

## Curriculum placement

| Gate | Existing curriculum outcome | Companion work | Required? |
|---|---|---|---|
| Stage 00 | Run tests and read failures | Identify input, action, observation, and expected result in one supplied test | No new lab |
| Stages 01–03 | Values, text, sequences, iteration | Add one boundary or equivalence-class case to selected learner-test overlays | Optional practice |
| Stage 04 | Model structured data | Complete existing `json-cli`; represent a result as plain JSON-compatible data | Companion lab |
| Stage 05 | Design narrow functions and orchestration | Complete existing `py-compile-cli`; separate contract, adapter, and side effect | Companion lab |
| Stage 06 | Handle failures and resources | Complete existing `zipapp-cli`; distinguish domain failure from process failure | Companion lab |
| Stage 07 | Model state and finite outcomes | Complete existing `update-file`; introduce frozen dataclasses for observations | Companion lab |
| Stage 08 | Use typing and interfaces as contracts | Read a small `.pyi` specimen and classify its claims; do not run a full checker matrix yet | Optional preview |
| Stage 09 | Use stdlib abstractions and explicit adapters | Complete `process-observation`, then `test-process-adapter` and `stdlib-contract-audit` | Primary insertion point |
| Stage 10 | State invariants and compare approaches | Complete `stdlib-property-probe`; shrink and promote one failing example | Primary insertion point |
| Stage 11 | Integrate components and isolate side effects | Run one semantics-laboratory capstone and emit text plus JSON reports | Stretch capstone |

Earlier learner tests should prepare vocabulary without teaching Hypothesis
syntax prematurely. Good prompts include:

- Stage 01: numeric boundaries and invalid ranges;
- Stage 02: normalization and case-equivalence examples;
- Stage 03: `reverse(reverse(value)) == value`;
- Stage 04: order-independent lookup and counting behavior;
- Stage 07: state transitions and class invariants;
- Stage 09: encode/decode or parse/format round trips;
- Stage 10: invariants independent of a particular implementation.

## Shared observation boundary

The labs share transport concepts, not one flattened result type. A small
envelope records provenance and routing fields:

```python
@dataclass(frozen=True)
class Evidence:
    source: str
    subject: str
    status: str
    message: str
    payload: Mapping[str, object]
```

Each domain retains its own payload:

- process: argv, return code, stdout, stderr, and timing;
- test: selector, passed/failed/skipped/error, location, and failure details;
- API contract: declared claim, runtime observation, discrepancy kind, Python
  version, and platform;
- property: strategy/provenance, invariant, minimized example, seed when
  available, and replay fixture.

The first implementation should use only the fields exercised by a lab. Add
fields when a concrete report or projection needs them, not in anticipation of
a universal diagnostics framework.

## Lab 1: `test-process-adapter`

Place this immediately after the existing Stage 09 `process-observation` lab.
Reconstruct the operational shape of `neotest-python` in ordinary Python:

```text
TestSelector
    ↓
Invocation
    ↓
subprocess producing JSON Lines
    ↓
streamed test observations
    ↓
final TestResult collection + process exit code
```

Start with a deterministic fixture runner rather than a pytest plugin. The
learner implements selector validation, shell-free argv construction, JSON-line
decoding, incremental delivery, and final exit-code reconciliation. Baseline
tests cover pass, fail, skip, malformed output, and disagreement between a test
result and process status.

Keep discovery, Tree-sitter, DAP, editor integration, timeout policy, and
environment rewriting out of the first lab. A later stretch task may translate
the normalized result to a Neotest-shaped JSON object; Neotest remains a
projection, not a semantic authority or Python dependency.

## Lab 2: `stdlib-contract-audit`

Place this after Stage 09, with the Stage 08 `type-hinting` material listed as a
recommended prerequisite when the learner includes extension items.

Use a tiny, pinned typeshed specimen and a matching CPython runtime object:

```text
typeshed `.pyi` claim
    ↓
extract selected symbol/signature facts
    ↓
inspect the running CPython object
    ↓
classify match, mismatch, unsupported, or indeterminate
    ↓
emit an API-contract observation
```

The first exercise audits a deliberately small symbol set and includes one
synthetic mismatch, so it is deterministic across supported Python versions.
It teaches that a stub is a version- and platform-qualified claim rather than
runtime truth. Record the typeshed commit, Python implementation/version,
platform, and any allowlist decision in every report.

Stretch work may run `stubtest` and one type checker against a small fixture.
Differential `ty`/mypy/pyright/pyrefly execution belongs after the single-tool
contract is understood. Checker output remains a checker-specific payload even
when it uses the shared evidence envelope.

## Lab 3: `stdlib-property-probe`

Place this after Stage 10, where invariants are already an explicit curriculum
outcome. Use ordinary pytest and Hypothesis locally; OSS-Fuzz is not required.

The exercise progression is:

```text
two concrete examples
    ↓
state a round-trip or metamorphic invariant
    ↓
implement a bounded Hypothesis strategy
    ↓
observe and shrink a seeded failure
    ↓
save the minimal value as a readable regression fixture
    ↓
replay it without Hypothesis
```

Begin with a small stdlib domain whose equality semantics are unambiguous. Add
a structured archive target only as a stretch task. For every idea adapted
from `python/library-fuzzers`, catalog the source path, pinned commit, license,
invariant, input constraints, and local changes. Do not commit Hypothesis's
runtime database, fuzz output, coverage data, or crash caches.

The promotion rule is explicit: generated failures become ordinary regression
tests only when the invariant is valid, the example is minimal enough to
explain, and the expected behavior is stable for the declared Python versions.

## Stage 11 capstone

The stretch capstone combines the labs without erasing their evidence types:

```text
selected stdlib subject
        │
        ├── typeshed claim audit
        ├── runtime example tests
        └── property probe
                 ↓
          process adapter
                 ↓
       evidence collection
          ├── text summary
          └── versioned JSON
```

The learner must explain which source supports each conclusion and which
conclusions remain qualified by version, platform, generator bounds, or tool
behavior. A successful capstone is reproducible from pinned inputs and reports
partial/unsupported evidence without converting it into a pass.

## Repository shape

Build on the companion workspace proposed in `companion-plan.md`:

```text
workbook/
├── README.md
├── labs.json
├── sources.json
├── labs/
│   ├── test-process-adapter/
│   ├── stdlib-contract-audit/
│   ├── stdlib-property-probe/
│   └── semantics-capstone/
├── specimens/
│   ├── typeshed/
│   └── library-fuzzers/
├── regressions/
└── tests/
    └── <kind>/<slug>/learner_test.py
```

`sources.json` records upstream repository, commit, license, source path,
retrieval mode, and local purpose. Store only small teaching specimens when
their licenses and provenance are preserved. Prefer configured archives or
checkouts for larger upstream sources.

Use the generic `labs`, `lab`, `specimens`, and `specimen` commands already
proposed by the companion plan. Do not add one command per evidence source.
The lab catalog should declare its stage gate, optional dependencies, source
specimens, test path, and completion criteria.

Keep the base Exercism requirements unchanged. Put Hypothesis and any static
checker used by a stretch lab in a separate companion requirements group or
file. Do not add Neotest, nose2, all four type checkers, or OSS-Fuzz to the
Python environment.

## Delivery sequence

### P0 — Companion seam

Implement the existing overlay, lab catalog, generic lab runner, specimen
catalog, and tests from `companion-plan.md`. Confirm that canonical verification
counts do not change.

### P1 — Adapter boundary

Implement `process-observation`, then `test-process-adapter`. Establish the
smallest evidence envelope and versioned JSON-line fixture protocol from actual
lab needs.

### P2 — Declared-versus-runtime evidence

Add the typeshed source entry, a small licensed specimen, the deterministic
contract-audit lab, and provenance-qualified output. Add full `stubtest` or a
checker only as stretch work.

### P3 — Adversarial evidence

Add the companion Hypothesis dependency, one bounded property lab, a seeded
failure, the regression-promotion exercise, and `library-fuzzers` provenance.

### P4 — Integration and projections

Add the Stage 11 capstone, stable text and JSON renderers, and an optional
Neotest-shaped projection. Use nose2 only for a reading/comparison prompt about
mutable event interception versus explicit immutable transformations.

## Acceptance checks

Each phase preserves all earlier checks. The completed layer should satisfy:

```text
python tools/path.py verify
python tools/path.py labs
python tools/path.py lab test-process-adapter
python tools/path.py lab stdlib-contract-audit
python tools/path.py lab stdlib-property-probe
python tools/path.py lab semantics-capstone
python -m pytest tests/test_path.py
```

Additional assertions:

- canonical source hashes and the 128 core-item count are unchanged;
- the base Exercism environment can still run without companion extras;
- every external specimen has a pinned source and license record;
- JSON protocols have a schema version and deterministic fixture coverage;
- property failures can be replayed from a normal regression test;
- unsupported versions or platforms produce qualified observations, not false
  passes;
- no generated fuzz, coverage, cache, or runtime files are tracked.
