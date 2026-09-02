# Handoff Seed v2 — Python-Intel Dynamic Semantic Extension

## Status and document authority

Technical-planning seed for the dynamic semantic extension.

This document **does not supersede the adjacent `python-intel-prototype-plan.md` delivery sequence**. The prototype plan remains authoritative for implementation phases and may defer regrtest orchestration. This seed defines the semantic model, provider boundaries, and evals required for the later dynamic extension.

If the prototype plan and this seed differ:

```text
prototype plan      → delivery order / near-term implementation authority
this handoff seed   → dynamic semantic architecture / later extension authority
ctrl contracts      → qualification/evidence authority
```

The first implementation should prove the static→compiler→runtime causal join with the smallest CPython harness available. Regrtest is a later execution backend unless the prototype plan is explicitly revised.

---

# 1. Planning directive

Extend Astral's Rust-native Python semantic model into CPython compiler/runtime evidence.

Do **not** build a second workflow engine or duplicate static analysis.

The principal new component is a causal semantic bridge:

```text
Python source snapshot
    ↓
Astral parse/static semantics
    ↓
StaticSubject
    ↓ realized-as
CPython CompilerRealization
    ↓ instantiated-as
ExecutionOccurrence
    ↓ observed-by
DynamicObservation
    ↓
ctrl evidence / qualification
```

Dynamic orchestration is best modeled as **semantic query/probe lowering**. Rust owns query planning and causal joins. CPython supplies compiler/runtime observations. Regrtest later supplies hardened campaign execution mechanics.

---

# 2. Authority boundary

```text
ctrl / CUE
    obligations, generic ProbeSpec, evidence, qualification policy

python-intel Rust
    semantic queries
    static↔dynamic causal relations
    probe lowering
    observation normalization
    correlation/evaluation

Astral fork
    parsing, source/static semantics, types, imports, references,
    indexing and incremental state

CPython
    reference compiler/runtime and dynamic sensors

regrtest
    later campaign execution backend: isolation, rerun, randomization,
    workers, timeout/crash handling, environment checks, case-set bisection

Python-side tooling
    actuator / sensor / optional projection only
```

Do not place semantic control authority in Marimo, Pydantic Graph, pytest, generated Python, or regrtest.

---

# 3. Upstream reuse

## 3.1 Astral — fork and wrap

Use a pinned Ruff monorepo fork. Candidate high-value crates:

```text
ruff_db
ruff_source_file
ruff_text_size
ruff_python_parser
ruff_python_ast
ruff_python_index
ruff_python_semantic

ty_python_core
ty_module_resolver
ty_site_packages
ty_python_semantic
ty_project        if project integration requires it
```

Add a narrow anti-corruption crate. Do not make Astral-local Salsa IDs or internal semantic types durable python-intel identities.

Do not re-engineer:

- Python parser/AST;
- static scope/symbol/reference graph;
- type inference;
- import/module resolution;
- incremental static database.

## 3.2 CPython — compiler/runtime plant

P0/P1 dynamic work may use a thin purpose-built CPython probe harness invoked directly from Rust.

High-value primitives:

```text
compile / code objects / dis / co_positions
sys.monitoring
sys.audit
traceback / inspect
```

Later regrtest integration can reuse:

```text
Lib/test/libregrtest/runtests.py
Lib/test/libregrtest/result.py
Lib/test/libregrtest/run_workers.py
Lib/test/libregrtest/save_env.py
Lib/test/libregrtest/parallel_case.py
Lib/test/bisect_cmd.py
Lib/test/support/isolation.py
```

Do not assume regrtest's `TestResult` is a generic observation transport. It is a test-result/control channel, not a payload channel for monitoring events, environment deltas, values, or other rich semantic observations.

## 3.3 Optional provider/specimen machinery

Defer unless an eval requires it:

```text
executing / ASTTokens   frame/instruction → AST correlation pattern
LibCST                  source-preserving transformations
Birdseye pattern        expression-value instrumentation
snoop pattern           line/local/expression observation UX
py-spy                   external sampled stack evidence
pytest                   sibling project-behavior backend
Marimo/Pydantic Graph    visualization/projection
python-control           later feedback-policy analysis
```

---

# 4. Durable source identity

Source identity must include **content**, not only repository revision + path + range.

Repository revisions do not uniquely identify dirty working trees or unsaved editor buffers.

Use a content-addressed source snapshot:

```text
SourceSnapshot
├── repository_revision?     # absent/qualified for dirty or unsaved content
├── document_uri / path
├── content_digest           # REQUIRED
└── encoding / coordinate contract
```

A static subject is scoped to that snapshot:

```text
StaticSubject
├── source_snapshot
│   ├── repository_revision?
│   ├── path / document_uri
│   └── content_digest
├── source_range
├── syntax_kind
├── scope
├── symbol?
└── static_facts...
```

The `content_digest` must participate in:

- `StaticSubject` identity;
- static↔compiler correlation keys;
- dynamic observation cache keys;
- code-realization cache keys;
- replay/provenance envelopes.

Candidate cache-key spine:

```text
(content_digest,
 source_range,
 semantic_query_version,
 python_runtime_identity,
 probe_semantics_version)
```

Repository revision remains useful provenance but is insufficient as source identity.

---

# 5. Core causal semantic model

## 5.1 StaticSubject

Astral-backed provider-neutral projection.

Examples:

```text
FunctionDef
CallExpr
AttributeExpr
Import
Branch/condition
Binding
Reference
Scope
```

Astral remains authoritative for static interpretation. CPython AST/symtable may be used for correlation/differential qualification, not as a duplicate hot-path static engine.

## 5.2 CompilerRealization

The required bridge:

```text
CompilerRealization
├── python_runtime_identity
├── source_subject
├── code_object_identity?
├── instruction_region?
├── source_positions
├── nested_code_objects?
└── relation
```

Candidate relations:

```text
realized_as
contains
lowers_to
creates
loads
calls
branches_to
handles
```

Support many-to-many mappings. One source construct can lower to several instructions; one code object contains many constructs.

## 5.3 ExecutionOccurrence

Repeated execution of the same instruction in the same frame must remain distinguishable.

Do not identify an execution occurrence only by attempt/process/thread/frame/code/offset.

Use an attempt-local provider stream occurrence:

```text
ExecutionOccurrence
├── attempt_id
├── process_id
├── thread_id
├── frame_occurrence_id
├── code_object_identity
├── instruction_offset?
├── event_kind
├── stream_id
└── event_ordinal          # REQUIRED; monotonic within stream
```

Identity:

```text
(attempt_id, stream_id, event_ordinal)
```

`stream_id` scopes ordering to a producer stream so the model does not claim a total order across concurrent threads/processes unless one is actually established.

Optional timestamps may aid diagnostics but are not occurrence identity.

## 5.4 DynamicObservation

Normalize provider outputs into semantic observation families:

```text
CompilerObservation
MonitoringObservation
ExceptionObservation
AuditObservation
ImportRuntimeObservation
EnvironmentObservation
CallableObservation
ValueObservation
SampleObservation
ResourceObservation
```

Preserve evidence strength. A py-spy sample is not equivalent to an exact `sys.monitoring` event.

## 5.5 Causal spine

```text
StaticSubject
    --realized-as-->
CompilerRealization
    --instantiated-as-->
ExecutionOccurrence
    --observed-by-->
DynamicObservation
```

---

# 6. Callable identity normalization

A CALL observation is incomplete if it only proves that a call instruction executed. E2 must normalize the **observed callable** and compare it to the static target when comparison is meaningful.

Use a tagged union with explicit fallbacks:

```text
CallableIdentity
├── PythonFunction
│   ├── module?
│   ├── qualname
│   ├── code_object_identity
│   └── source_subject?
│
├── BuiltinCallable
│   ├── module?
│   ├── qualname / name
│   └── owner_type?
│
├── BoundMethod
│   ├── function: CallableIdentity
│   └── receiver: RuntimeObjectIdentity
│
├── CallableInstance
│   ├── type_identity
│   ├── runtime_object_identity
│   └── call_implementation?     # __call__ when resolvable
│
└── OpaqueCallable
    ├── type_identity?
    ├── runtime_object_identity
    └── provider_description?    # non-authoritative diagnostic text
```

`RuntimeObjectIdentity` is attempt/process-local unless a stronger stable identity is explicitly established.

Do not use `repr()` as durable identity.

Comparison outcome should be explicit:

```text
CallableTargetComparison
├── match
├── mismatch
├── compatible-but-not-identical
├── indeterminate
└── not-comparable
```

This avoids converting opaque dynamic callables into false mismatches.

---

# 7. Correlation strategy

Exploit CPython positional machinery rather than inventing correlation from zero:

```text
sys.monitoring event
    ├── code object
    └── instruction offset
          ↓
      co_positions()
          ↓
      source coordinates
          ↓
CPython AST / executing-style correlation
          ↓
content-addressed SourceOccurrence
          ↓
Astral occurrence
```

Must be engineered/evaluated:

- source coordinate normalization and encoding;
- content-digest propagation;
- exact vs bounded/inferred/unresolved joins;
- ambiguity representation rather than guessed 1:1 matches;
- code-object identity/digest;
- lambdas/comprehensions/nested code objects;
- revision lineage and provenance.

---

# 8. Dedicated dynamic observation sidecar

Regrtest's JSON result channel is **not** sufficient for rich semantic observations.

`TestResult` communicates test execution state. Environment contamination details from `save_env` are primarily warnings plus the coarse `ENV_CHANGED` state. Monitoring events likewise have no generic place in `TestResult`.

Therefore define a dedicated adapter-owned observation channel before E2/E3.

## 8.1 P0 transport

Prefer a file/sidecar boundary because it works through subprocess/regrtest nesting without coupling to libregrtest internals:

```text
Rust
  ├── attempt_id
  ├── creates observation_dir
  └── passes observation_dir + attempt metadata
          ↓
CPython probe harness / regrtest test
          ↓
writes versioned observation JSONL/JSON artifact
          ↓
process/regrtest exits
          ↓
Rust reads:
  1. process/regrtest result
  2. observation sidecar
          ↓
reconciles both
```

Suggested per-attempt layout:

```text
<observation_dir>/
└── <attempt_id>/
    ├── manifest.json
    ├── events.jsonl
    ├── environment.json
    └── artifacts/...
```

The exact file split should be eval-driven; a single JSONL stream is sufficient for the first monitoring probe.

## 8.2 Observation envelope

```text
DynamicObservationEnvelope
├── schema_version
├── attempt_id
├── provider
├── python_runtime_identity
├── source_content_digest
├── subject_hint?
├── stream_id
├── observations[] / JSONL events
└── artifacts[]
```

Each event carries its own `event_ordinal`.

## 8.3 Result reconciliation

Never infer semantic success from process exit alone:

```text
Process/RegrtestResult
        +
ObservationSidecar
        ↓
Rust reconciliation
        ↓
Normalized dynamic result
```

Possible states include:

```text
execution failed before observation
execution passed but required observation missing
observation emitted but worker/finalization failed
observation malformed
observation valid
```

This sidecar boundary is required before E2/E3 are considered implementable.

---

# 9. Semantic query → dynamic probe lowering

Treat orchestration as a small query compiler.

Example:

```text
Query:
    Was this Astral CallExpr executed, and what callable was invoked?
```

Possible lowering:

```text
1. resolve StaticSubject including content digest
2. establish CompilerRealization
3. select relevant CALL monitoring primitive
4. allocate attempt_id + sidecar stream
5. execute specimen in CPython
6. collect CALL event + observed callable identity
7. correlate event to code/instruction/source realization
8. compare normalized callable to static target
9. admit/evaluate through ctrl qualification
```

Generic path:

```text
SemanticQuery
    ↓
DynamicProbePlan
    ↓
existing ProbeSpec + provider lowering
    ↓
CPython harness
    ↓
ProcessResult + ObservationSidecar
    ↓
Rust normalization
    ↓
causal join
    ↓
SemanticReport
```

Regrtest may later replace/enclose the direct harness execution step without changing the semantic model.

---

# 10. Existing ctrl ProbeSpec

Do not introduce a replacement `ExperimentSpec`.

The generic probe contract already covers fixture/obligation/stimulus/oracle/timeout/capture-claim concerns.

Preferred provider layering:

```text
#ProbeSpec
    ↓
python-intel CPython provider lowering
    ↓
CPython direct harness          # prototype phase
    ↓ later
regrtest-backed campaign        # extension phase
    ↓
ProcessResult + ObservationSidecar
    ↓
existing observation/evidence/qualification path
```

Keep CPython-specific controls behind adapter parameters first. Add a narrow provider binding only if evals prove the generic contract insufficient.

---

# 11. Regrtest role and scope

Regrtest is a later execution/campaign substrate.

Reuse:

```text
selection/filtering
random seed/order
rerun/fail-fast/forever
process workers
parallel-thread stress
timeout/crash handling
environment contamination state
resource gates/refleak
unittest case-set bisection
result algebra
worker JSON transport
```

Do not overstate:

```text
regrtest TestResult != rich semantic observation transport
bisect_cmd != generic source/import/fixture minimizer
regrtest != semantic dependency controller
```

---

# 12. Failure progression and minimization

CPython's `test.bisect_cmd` specifically reduces **unittest case-name sets** by sampling subsets and rerunning them.

Therefore E4 P0 scope is:

```text
failing unittest case set
    ↓
confirm declared reproduction criterion
    ↓
reduce case-name set
    ↓
rerun candidate subset
    ↓
retain only if failure predicate remains satisfied
    ↓
reduced case set
```

Do not describe this as arbitrary source/import/statement minimization.

Generic reproducer minimization is a future Rust-owned extension inspired by the same pattern.

## 12.1 Flaky/stability criterion

Reduction must use a declared reproduction predicate, not one accidental failure.

Candidate contract:

```text
ReproductionCriterion
├── attempts
├── min_failures
├── seed_policy
├── timeout_policy
└── failure_signature
```

For deterministic failures the criterion may be one successful reproduction. For flaky failures, `attempts` and `min_failures` are explicit probe/campaign parameters.

A candidate subset is retained only if it satisfies the same declared failure predicate/signature.

No hard-coded statistical threshold belongs in the semantic model at P0.

---

# 13. Rust-facing semantic API

Generalize Astral's report-producing pattern rather than inserting a second controller framework.

```text
PythonSemanticDb
├── AstralProvider
│   └── static queries
└── CPythonProvider
    └── compiler/runtime observation queries
```

Possible queries:

```text
symbol_at(subject)
references(symbol)
inferred_type(subject)

compile_observation(subject)
execution_observation(subject)
monitoring_observation(subject)
callable_observation(subject)
```

Candidate report:

```text
SemanticReport
├── subject
├── static_observations[]
├── compiler_realizations[]
├── execution_occurrences[]
├── dynamic_observations[]
├── attempts[]
├── causal_bindings[]
└── evaluation/verdict?
```

Keep observation distinct from admitted evidence where `ctrl` requires it.

---

# 14. SCIP decision

Defer SCIP from P0.

Astral already provides enough static indexing to prove source→compiler→runtime joins. SCIP does not solve code-object, instruction, execution, frame, attempt, content-snapshot, or runtime occurrence identity.

Preserve future compatibility by using provider-neutral source identity with mandatory content digest.

Add SCIP later as an index/projection layer when external consumers, multi-language providers, offline revision indexes, or repository-scale navigation justify it.

---

# 15. Thin prototype realization

The prototype plan remains delivery authority. The dynamic seed should fit behind it.

Suggested eventual components:

```text
crates/
├── python-intel-core/
│   ├── source_snapshot
│   ├── identities
│   ├── subjects
│   ├── observations
│   ├── callable_identity
│   └── causal_bindings
├── python-intel-astral/
│   └── narrow adapter
├── python-intel-cpython/
│   ├── request lowering
│   ├── direct harness invocation
│   ├── sidecar decode
│   └── normalization
└── python-intel-query/
    └── semantic query/progressive probe algorithms

python probe harness/
├── compile probe
├── monitoring probe
├── environment probe
└── import-runtime probe
```

Regrtest integration is a subsequent backend/campaign slice unless the prototype plan is explicitly changed.

---

# 16. Required architecture evals

## E1 — Static occurrence → compiler realization

```text
content-addressed Astral occurrence
    ↓
CPython compile
    ↓
code/instruction realization
    ↓
causal binding to source snapshot
```

Pass when relation is deterministic or explicitly ambiguous, includes content digest, and does not use Astral-local IDs as durable identity.

## E2 — Static call subject → runtime CALL + callable identity

```text
Astral CallExpr
    ↓
CompilerRealization
    ↓
sys.monitoring CALL
    ↓
ExecutionOccurrence(event ordinal)
    ↓
normalized CallableIdentity
    ↓
comparison with static target
```

Pass when:

- event provenance includes interpreter + attempt + stream/event ordinal + code/instruction coordinates;
- event round-trips to the content-addressed static subject;
- observed callable is normalized as Python function, builtin, bound method, callable instance, or opaque fallback;
- comparison result is explicit (`match`, `mismatch`, `compatible`, `indeterminate`, `not-comparable`);
- rich event data arrives via the dedicated sidecar, not regrtest `TestResult`.

## E3 — Environment mutation with structured detail

```text
specimen
    ↓
CPython harness/regrtest isolation
    ↓
state mutation
    ↓
structured EnvironmentObservation sidecar
    ↓
qualified expected/forbidden result
```

Pass only when the actual mutation detail is structured and attributable. `ENV_CHANGED` alone is insufficient.

Use `save_env` as the reference catalogue/pattern, not as proof that regrtest transports the mutation payload.

## E4 — Regrtest unittest case-set reduction

Later regrtest phase only.

```text
failing unittest case set
    ↓
declared reproduction/stability criterion
    ↓
bisect/sample subsets
    ↓
retain subset only if criterion holds
    ↓
reduced unittest case set
```

Pass when the reduced set preserves the declared failure signature and stability predicate.

Generic minimal source reproducer generation is explicitly out of scope for E4.

---

# 17. Candidate planning slices

These are planning candidates, not final repository slice manifests.

### A. Source snapshot + Astral adapter boundary

- mandatory content digest;
- dirty/unsaved source support;
- one static subject query.

### B. Compiler realization join

- code-object identity;
- instruction/source mapping;
- E1.

### C. Observation sidecar protocol

- attempt identity;
- stream/event ordinals;
- versioned JSONL;
- process-result reconciliation.

### D. Monitoring + callable identity

- one CALL query;
- callable normalization;
- E2.

### E. Environment observation

- structured mutation capture;
- E3.

### F. Regrtest backend/campaign integration

Only after prototype-plan gate permits it:

- regrtest invocation;
- rerun/randomization;
- case-set bisection with stability predicate;
- E4.

---

# 18. Initial non-goals

Do not introduce without an eval proving need:

- new generic `ExperimentSpec`;
- generic DAG/workflow engine;
- Python-side orchestration authority;
- regrtest orchestration before the prototype plan gate;
- using regrtest `TestResult` as rich semantic payload;
- generic source minimization via `bisect_cmd`;
- SCIP indexing;
- mandatory LibCST representation;
- full Birdseye/snoop integration;
- duplicate parser/type/import engine;
- Python-owned persistent evidence ledger;
- python-control feedback logic;
- multi-language generalization.

---

# 19. Open technical decisions

Resolve with small evals:

1. **Digest algorithm/versioning** — content digest representation and normalization of source bytes.
2. **Coordinate contract** — Astral ranges vs CPython AST/`co_positions()` byte/line/column semantics.
3. **Code-object identity** — reconstructable digest, never runtime `id(code)` across runs.
4. **Frame occurrence identity** — ensure recursive/repeated frames remain distinct within an attempt.
5. **Event stream semantics** — stream boundaries and ordering guarantees under threads/free-threaded execution.
6. **Ambiguous lowering** — exact/bounded/inferred/unresolved relation vocabulary.
7. **Sidecar lifecycle** — atomic writes, crash/truncation handling, worker-specific paths, schema version.
8. **Callable normalization** — exact data available at monitoring callback time and whether additional frame/stack inspection is required.
9. **Static/dynamic target comparison** — rules for decorators, descriptors, monkeypatching, bound methods, dynamic dispatch, and opaque callables.
10. **Prototype-plan gate** — exact milestone after which regrtest becomes an allowed backend.
11. **Cache key** — include source content digest + runtime identity + query/probe semantics.
12. **Evidence strength** — exact monitoring vs transformed/value instrumentation vs sampled evidence.

---

# 20. Planning completion test

The dynamic implementation plan is sufficiently specified when the initial joins can answer:

```text
Given Astral semantic subject S and requested dynamic property D:

1. Which content-addressed source snapshot contains S?
2. What durable/static identity represents S?
3. What compiler realization connects S to CPython execution?
4. Which CPython primitive observes D?
5. How is the request lowered into the current prototype execution boundary?
6. Where is rich observation data written independently of process/regrtest result state?
7. How is each repeated runtime event uniquely represented?
8. How is the observation normalized into Rust?
9. If D is a call, what normalized callable identity was observed?
10. What causal relation binds the observation back to S?
11. How is it admitted/evaluated through existing ctrl contracts?
12. How are ambiguity, opacity, partial evidence, and failure represented without guessing?
```

If E1–E3 have concrete answers, the causal semantic architecture is established. E4 qualifies the later regrtest campaign backend rather than gating the initial prototype.
