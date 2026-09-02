# Handoff Seed v4 — Python-Intel Streaming Execution Graph and Semantic Policy

## Status and document authority

Technical-planning seed for the dynamic semantic extension.

This document **does not supersede the adjacent `python-intel-prototype-plan.md` delivery sequence**. The prototype plan remains authoritative for implementation phases and may defer regrtest orchestration. This seed defines the semantic model, provider boundaries, and evals required for the later dynamic extension.

If the prototype plan and this seed differ:

```text
prototype plan      → delivery order / near-term implementation authority
this handoff seed   → dynamic semantic architecture / later extension authority
ctrl contracts      → qualification/evidence authority
```

The first implementation should prove the static→compiler→runtime causal join with the smallest CPython harness available. Once the prototype-plan gate permits regrtest integration, live parent/worker streams and Rust execution-graph reconstruction become the primary dynamic architecture.

---

# 1. Planning directive

Extend Astral's Rust-native Python semantic model into CPython compiler/runtime evidence.

Do **not** build a second workflow engine or duplicate static analysis.

The principal new component is a Rust-owned causal semantic and execution graph:

```text
Python source snapshot
    ↓
Astral parse/static semantics
    ↓
StaticSubject
    ↓ realized-as
CPython CompilerRealization
    ↓ executed-as
RuntimeEvent
    ↓ occurred-in
Frame / Thread / Process / Test / Attempt / Campaign
    ↓
ctrl evidence / qualification
```

Dynamic orchestration is best modeled as **semantic query/probe lowering over an observed execution graph**. Rust owns graph reconstruction, query planning, intent validation, effects, and causal joins. CPython supplies compiler/runtime observations. Regrtest supplies campaign mechanics and orchestration facts. Steel may compute policy over immutable Rust semantic snapshots but cannot execute effects.

---

# 2. Authority boundary

```text
ctrl / CUE
    obligations, generic ProbeSpec, evidence, qualification policy

python-intel Rust
    semantic queries
    multi-stream ingestion and execution-graph reconstruction
    static↔dynamic causal relations
    probe lowering
    provider observation projection
    Steel capability host and intent validation
    observation normalization
    correlation/evaluation

Astral fork
    parsing, source/static semantics, types, imports, references,
    indexing and incremental state

CPython
    reference compiler/runtime and dynamic sensors

regrtest
    campaign execution backend and orchestration fact producer:
    selection, dispatch, isolation, rerun, randomization, workers,
    timeout/crash handling, environment checks, case-set bisection

Steel VM
    candidate semantic query/probe-policy language over immutable Rust facts;
    returns inert PolicyDecision / ProbeIntent values only

Python-side tooling
    actuator / sensor / bounded JSON serialization only
```

Do not place semantic authority or effect execution in Marimo, Pydantic Graph, pytest, generated Python, regrtest, JSONata, or Steel.

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

## 3.4 jsonata-core — observation projection candidate

E5 evaluates `jsonata-core` as a Rust-native mechanism for selecting and transforming provider JSON before canonical observation validation.

The currently evaluated release is `jsonata-core` 2.2.7, licensed MIT. Use its Rust parser, evaluator, and `JValue` API directly; do not enable or route through the optional Python/PyO3 binding.

JSONata is not an orchestrator, validator, causal-relation engine, or evidence authority. It remains an adapter-scoped candidate dependency until E5 passes. Pin the exact crate version and source revision only in the selected implementation repository.

## 3.5 Steel — semantic query/policy candidate

E7 evaluates `steel-core` as an embedded Rust-native Scheme VM for programmable semantic queries and progressive probe policy.

The currently evaluated release is `steel-core` 0.8.2, licensed `MIT OR Apache-2.0`. Use the embeddable library, typed `IntoSteelVal`/`FromSteelVal` boundary, and registered Rust functions/types; do not invoke the `steel-interpreter` CLI.

Steel operates at **decision frequency**, after Rust has reconstructed and validated semantic facts. It must not ingest the monitoring hot path, own the execution graph, launch CPython, mutate evidence, or bypass ctrl/CUE qualification.

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

Static semantics also depend on the document's project context. Define a provider-neutral `ProjectSemanticEnvironmentIdentity` over the project root, relevant configuration, import-resolution inputs, dependency realization, and target Python version.

Candidate cache-key spine:

```text
(document_uri / canonical_path,
 content_digest,
 source_range,
 syntax_kind,
 subject_discriminator,
 project_semantic_environment_identity,
 semantic_query_version,
 python_runtime_identity,
 probe_realization_digest)
```

The subject discriminator must distinguish different semantic subjects that share a source range. The probe realization digest covers effective fixture, argv, environment policy, interpreter flags, and provider semantics rather than only a schema version.

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

## 5.3 ExecutionGraph

Rust reconstructs what actually occurred rather than predicting a workflow DAG:

```text
Campaign
└── RegrtestRunOccurrence
    └── AttemptOccurrence
        └── TestInvocation
            └── WorkerSlotOccurrence?
                └── ProcessOccurrence
                    └── ThreadOccurrence
                        └── FrameOccurrence
                            └── RuntimeEvent[]
```

In CPython 3.14 multiprocess regrtest, `WorkerThread` is a persistent scheduling slot, while each `_runtest()` dispatch launches a fresh worker subprocess for one test module. Do not model a scheduling slot as one persistent OS process. Sequential mode executes in the regrtest parent without a worker subprocess. `--parallel-threads` introduces concurrent unittest executions within one process.

Repeated execution of the same instruction in the same frame remains distinct through event identity:

```text
StreamEventIdentity = (run_id, stream_id, ordinal)
```

`stream_id` is Rust-assigned and unique within the run. `ordinal` is strictly monotonic within that stream.

## 5.4 StreamEvent and partial order

All producers use one envelope:

```text
StreamEvent
├── schema_version
├── run_id
├── attempt_id
├── stream_id
├── ordinal
├── producer_kind
├── process_occurrence_id?
├── parent_process_occurrence_id?
├── thread_occurrence_id?
├── frame_occurrence_id?
├── event_kind
├── causal_predecessors[]
├── monotonic_time?          # diagnostic only
└── payload
```

Event families:

```text
RegrtestEvent
├── run_start / run_finished
├── test_selected / test_dispatched / test_result
├── worker_slot_started / worker_slot_stopped
├── worker_process_started / worker_process_stopped
├── rerun_started
└── reduction_candidate_started

RuntimeEvent
├── test_start / test_end
├── py_start / py_return
├── call
├── branch_left / branch_right
├── raise
└── exception_handled

ProcessEvent
├── spawn
├── exec
└── exit
```

Within a stream, ordinal order is exact. Across streams, Rust constructs a partial order only from explicit causal edges such as:

```text
test_dispatched  --happens-before--> worker handshake / test_start
process spawn    --happens-before--> child stream start
test_end         --happens-before--> parent test_result
attempt outcome  --motivates-------> rerun/reduction attempt
```

Timestamps support visualization and diagnostics but never establish semantic ordering across concurrent streams.

## 5.5 DynamicObservation

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

## 5.6 Causal spine

```text
StaticSubject
    --realized-as-->
CompilerRealization
    --executed-as-->
RuntimeEvent
    --occurred-in-->
Frame / Thread / Process / TestInvocation / Attempt / Campaign
    --normalized-as-->
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

Use a provider-assigned object ordinal:

```text
RuntimeObjectIdentity
├── attempt_id
├── process_id
└── object_ordinal
```

The provider may use `id()` only as an internal lookup accelerator while tracking object lifetime so address reuse cannot collapse distinct objects. Prefer weak references. If an object cannot be weak-referenced, either emit event-local opaque identity or explicitly record that strong retention perturbed object lifetime; never silently retain arbitrary objects or serialize raw `id()` as identity.

Do not use `repr()` as durable identity.

Callable inspection must not execute specimen code. Dispatch on exact known runtime types, use static attribute inspection where required, guard against monitoring recursion, and fall back to `OpaqueCallable` rather than invoking arbitrary `__getattribute__`, descriptors, properties, or `repr()`.

Do not infer `BoundMethod` solely from the CALL callback's `arg0`; an explicit unbound call can present the same function/first-argument shape. Preserve an inferred/indeterminate classification unless descriptor and call-site evidence establishes the relation.

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

# 8. Live multi-producer event streaming

Regrtest's JSON result channel is **not** sufficient for rich semantic observations.

`TestResult` communicates test execution state. Environment contamination details from `save_env` are primarily warnings plus the coarse `ENV_CHANGED` state. Monitoring events likewise have no generic place in `TestResult`.

Therefore add a dedicated live observation protocol without altering regrtest's existing result channel.

## 8.1 Local IPC transport

Use a local IPC abstraction:

```text
Unix                     Windows
Unix-domain socket       named pipe
           \             /
            Rust collector
                 ↑
       one connection per producer stream
```

Frames use a bounded `u32` length prefix followed by UTF-8 JSON containing one `StreamEvent`. No producer shares framing state with regrtest stdout/stderr or `TestResult` JSON.

Rust launches the pinned regrtest parent with the endpoint and a one-time bootstrap capability. After validating the handshake, Rust assigns the run, stream, and process-occurrence identities.

Before each worker spawn, the parent requests or derives a scoped one-time producer ticket and passes only the endpoint, ticket, parent dispatch reference, and required run metadata to the worker. The worker removes the ticket from its environment after connecting.

## 8.2 Narrow regrtest hooks

Patch the pinned regrtest fork with fact-only hooks at:

```text
run / attempt start and finish
selection and randomized order
test dispatch
worker-slot start and stop
worker-process spawn and exit
test-result receipt
rerun start
reduction/bisection candidate start and finish
```

These hooks emit facts already known by regrtest; they do not decide campaign policy or semantic causality.

Parent lifecycle events are low volume and emit synchronously. Worker `sys.monitoring` callbacks enqueue bounded JSON-safe records without blocking; a dedicated writer thread drains them to IPC. Queue overflow emits a loss marker and changes stream completeness to `partial`.

## 8.3 Stream lifecycle and durability

```text
producer handshake
    ↓
stream_start
    ↓
StreamEvent ordinal 0..N
    ↓
stream_end(last_ordinal)
    ↓
bounded collector acknowledgement
```

Disconnect, crash, duplicate ordinal, ordinal gap, malformed frame, queue overflow, or absent `stream_end` becomes explicit completeness metadata. A clean stream is complete only after its terminal ordinal is acknowledged.

Rust structurally validates each frame, binds it to the authenticated producer context, and appends it to a collector-owned framed spool before semantic admission. The spool is durability and replay infrastructure, not semantic transport or authority. Replay ignores an incomplete trailing frame, records truncation, and must reconstruct the same accepted graph and partial-stream diagnostics.

JSON identifiers and integers outside the exactly representable `f64` integer range (`-(2^53-1)` through `2^53-1`) must use versioned string encodings. In particular, do not expose 64-bit identities or high-resolution timestamps to `jsonata-core::JValue` as lossy numbers.

## 8.4 Trust and completeness

Worker `sys.monitoring` callbacks run cooperatively with the observed Python process. The specimen can inspect or disable monitoring state or interfere with callbacks. Streaming reduces post-receipt tampering but does not make worker evidence adversarially trustworthy.

```text
ObservationTrust
├── cooperative_in_process
├── externally_observed
└── unknown

ObservationCompleteness
├── complete
├── partial
├── missing
├── malformed
└── tamper_suspected
```

Do not interpret a missing event as proof of non-execution unless the sensor's completeness requirements were independently established.

Parent orchestration facts, cooperative worker observations, propagated descendant observations, and future externally observed facts retain distinct trust strengths. Adversarial specimens require a future external observer/sandbox evaluation.

## 8.5 Descendant-process coverage

P0 requires the regrtest parent and its directly launched per-test processes. Instrumented specimen descendants may join the same graph only through an explicit propagation hook that obtains a fresh child ticket and carries the parent process/event reference; never reuse or broadly inherit the worker ticket.

```text
regrtest parent → per-test process → instrumented specimen child → grandchild
```

An uninstrumented or uncooperative descendant remains an explicit coverage gap. Future OS-level or sampled providers may add observations at a different trust/evidence strength, but their absence does not make the cooperative stream complete.

## 8.6 Privacy and retention

Environment observations default to resource names and change kinds (`added`, `removed`, `changed`) with values redacted. Capturing selected values requires explicit ctrl/CUE capture policy.

Do not obtain diagnostic text by calling arbitrary object `repr()`. Sanitize and bound provider descriptions, payload strings, frame size, stream event counts, spool size, and admitted artifacts. Only explicitly admitted/captured material enters durable evidence or caches.

## 8.7 Result reconciliation

Never infer semantic success from process exit alone:

```text
Process/RegrtestResult
        +
accepted producer streams
        ↓
Rust reconciliation
        ↓
Validated provider result
```

Possible states include:

```text
execution failed before observation
execution passed but required observation missing
events accepted but worker/finalization failed
stream partial or malformed
stream complete and valid
```

Live streaming plus graph reconstruction is required before regrtest-backed E2/E3 are considered implementable.

## 8.8 Declarative observation projection

JSON Pointer and JSONata serve different purposes:

```text
JSON Pointer
    exact structural capture

JSONata
    provider-record filtering and transformation
```

Canonical flow:

```text
structurally validated StreamEvent or finite bounded event batch
        ↓
JSON Pointer captures / restricted JSONata projections
        ↓
ObservationCandidate[]
        ↓ Rust/CUE canonical validation
DynamicObservation[]
        ↓ Rust causal admission
CausalBinding[]
        ↓ ctrl qualification
Evidence
```

Provisional adapter-owned contract:

```text
AdapterObservationProjection
├── schema_version
├── id
├── language: "jsonata"
├── expression
├── input_schema_version
├── output_observation_kind
└── output_cardinality: "one" | "many"
```

JSONata evaluates individual payloads or finite bounded event batches; it is not a stateful stream processor. Validation includes the provider-specific fields required by the projection, so a missing required field cannot masquerade as an empty match. P0 injects one immutable, host-derived `$subject` binding; producer-echoed subject hints are not authoritative.

JSONata never receives live Python objects. The CPython sensor first converts runtime callables/values into bounded JSON-safe provider descriptors using the non-invoking inspection rules in section 6; JSONata may only select or reshape those descriptors.

Projection output is candidate data, not a causal assertion. Rust independently checks source/code identities and establishes or rejects causal relations after canonical schema validation.

For `many` projections, evaluator `undefined` means zero candidates only after input-schema validation succeeds. `null`, wrong cardinality, malformed input, and invalid output remain explicit projection failures rather than silent coercions.

Projection provenance records the projection ID, expression digest, engine/version, input event/batch identity, evaluator profile, and outcome.

Use a restricted adapter-owned evaluator profile:

- direct Rust `jsonata-core`; no Python feature or binding;
- no registered host functions;
- reject `$eval`, `$now`, `$millis`, and `$random` in P0;
- finite input/output size, wall-time, stack-depth, and sequence-length limits;
- explicit diagnostics for parse, forbidden-function, evaluation, resource, cardinality, and output-validation failures.

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
4. allocate run/attempt/stream identities and producer tickets
5. execute specimen in CPython
6. validate and spool live StreamEvent frames
7. admit orchestration/runtime events into the partial-order execution graph
8. project bounded CALL candidates with JSONata or exact JSON Pointer capture
9. validate canonical observation candidates
10. correlate event to code/instruction/source realization
11. canonicalize the JSON-safe callable descriptor
12. compare normalized callable to static target
13. expose a frozen semantic snapshot to Rust or Steel policy
14. validate returned ProbeIntent values through Rust + ctrl/CUE
15. execute only the resulting qualified DynamicProbePlan
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
live parent/worker StreamEvent frames
    ↓
Rust structural validation + collector spool
    ↓
ExecutionGraph admission + adapter projection/capture
    ↓
Rust/CUE canonical observation validation
    ↓
causal join
    ↓
optional Steel PolicyDecision
    ↓ Rust + ctrl/CUE validation
SemanticReport
```

The direct harness is a degenerate single-process execution graph. Regrtest later adds parent orchestration and per-test worker streams without changing the semantic or policy authority boundaries.

---

# 10. Existing ctrl ProbeSpec

Do not introduce a replacement `ExperimentSpec`.

The generic probe contract already covers fixture/obligation/stimulus/oracle/timeout/capture-claim concerns.

Keep JSON Pointer as the capture-claim mechanism for exact structural paths. JSONata projections remain CPython-adapter configuration for E5; do not add a generic `projections[]` field to `#ProbeSpec` unless the eval demonstrates a provider-neutral requirement.

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
live StreamEvent ingestion + collector spool
    ↓
ExecutionGraph + existing observation/evidence/qualification path
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

Therefore the later E4 regrtest-phase scope is:

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
    └── compiler/runtime/execution-graph queries
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
executions_of(subject)
runtime_calls(subject)
descendants(execution_node)
exceptions_under(execution_node)
```

Candidate report:

```text
SemanticReport
├── subject
├── static_observations[]
├── compiler_realizations[]
├── execution_graph_projection
├── dynamic_observations[]
├── attempts[]
├── causal_bindings[]
└── evaluation/verdict?
```

Keep observation distinct from admitted evidence where `ctrl` requires it.

---

# 14. Embedded Steel semantic policy

Steel is a candidate programmable query/policy layer over immutable Rust-owned facts. It returns inert values; it never launches a probe.

## 14.1 Typed boundary

```text
PolicySpec
├── policy_id
├── source_digest
├── entrypoint
├── steel_engine_version
├── capability_set_version
└── resource_budget

PolicySnapshot
├── snapshot_id
├── subject_handles[]
├── static_db_revision
├── execution_graph_revision
└── admitted_observation_handles[]

PolicyDecision
├── Request(ProbeIntent[])
├── Finish(reason)
└── Defer(reason)

ProbeIntent
├── subject
├── observation_kind
├── typed_parameters
└── reason
```

Rust exposes opaque immutable handles and a deliberately small capability surface:

```text
compiler-realizations
executions-of
runtime-calls
observed-callables
descendants
exceptions-under
ambiguous?
has-observation?
probe-cost
```

Steel receives inert constructors such as `request-observation`, `request-rerun`, `request-stress`, `request-bisect-cases`, `finish`, and `defer`. Constructors only build `PolicyDecision` values.

Rust converts the result through `FromSteelVal`, then validates subject existence, observation kind, parameters, cardinality, duplicate intents, staleness, and aggregate probe cost. ctrl/CUE then qualifies the validated intents before Rust lowers any `DynamicProbePlan`.

## 14.2 Capability and resource boundary

E7 uses a fresh `Engine::new_raw()` for each evaluation and registers only an audited policy module. Do not expose filesystem, network, process, thread, dynamic-library, time, randomness, async, mutable-reference, or execution capabilities.

Budgets cover policy source size, wall time, host-call count, graph visits, returned rows, output intents, and diagnostic size. `InterruptHandler` provides bytecode timeout but checks at VM safe points and cannot preempt a running native Rust function. Every registered Rust query must therefore be synchronous, non-blocking, side-effect-free, and independently bounded.

Parse, compile, timeout, host-query, conversion, budget, or validation failure yields `PolicyEvaluationFailed` and launches no probe. A fixed Rust fallback policy runs only when explicitly configured.

Do not claim Steel is a sandbox or hard memory boundary. P0 assumes trusted/project-controlled policy source. Untrusted policy requires future process isolation and an independently enforced memory limit.

Steel contracts and macros may improve policy ergonomics, but they remain implementation-safety tools. Rust types and ctrl/CUE remain authoritative.

## 14.3 Replay and frequency

Record the policy digest, Steel version, capability-set version, snapshot ID, budgets, normalized decision, and Rust/ctrl validation outcome. Identical inputs must reproduce the same normalized decision.

Steel runs at decision frequency over a frozen `PolicySnapshot`. It never receives raw monitoring streams or participates in event decoding, graph admission, or hot-path correlation.

---

# 15. SCIP decision

Defer SCIP from P0.

Astral already provides enough static indexing to prove source→compiler→runtime joins. SCIP does not solve code-object, instruction, execution, frame, attempt, content-snapshot, or runtime occurrence identity.

Preserve future compatibility by using provider-neutral source identity with mandatory content digest.

Add SCIP later as an index/projection layer when external consumers, multi-language providers, offline revision indexes, or repository-scale navigation justify it.

---

# 16. Thin prototype realization

The prototype plan remains delivery authority. The dynamic seed should fit behind it.

Suggested eventual components:

```text
crates/
├── python-intel-core/
│   ├── source_snapshot
│   ├── identities
│   ├── subjects
│   ├── observations
│   ├── execution_graph
│   ├── callable_identity
│   └── causal_bindings
├── python-intel-astral/
│   └── narrow adapter
├── python-intel-cpython/
│   ├── request lowering
│   ├── direct harness invocation
│   ├── stream bootstrap and transport
│   ├── frame decode and spool
│   ├── adapter projection
│   └── normalization
├── python-intel-policy/
│   └── optional Steel host after E7
└── python-intel-query/
    └── semantic query/progressive probe algorithms

python probe harness/
├── compile probe
├── monitoring probe
├── environment probe
└── import-runtime probe
```

Regrtest integration remains gated, but its first admitted slice is the narrow streaming and execution-graph eval rather than campaign automation.

---

# 17. Required architecture evals

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
RuntimeEvent(stream ID + ordinal)
    ↓
Frame → Thread → Process → TestInvocation → Attempt
    ↓
normalized CallableIdentity
    ↓
comparison with static target
```

Pass when:

- event provenance includes interpreter + attempt + stream/event ordinal + code/instruction coordinates;
- applicable records carry event-level source snapshot identity across multi-module execution;
- event round-trips to the content-addressed static subject;
- observed callable is normalized as Python function, builtin, bound method, callable instance, or opaque fallback;
- callable normalization does not invoke specimen-controlled attribute access or representation;
- comparison result is explicit (`match`, `mismatch`, `compatible`, `indeterminate`, `not-comparable`);
- rich event data arrives through the dedicated live stream, not regrtest `TestResult`;
- the report records cooperative sensor trust and completeness rather than treating event absence as proof.

## E3 — Environment mutation with structured detail

```text
specimen
    ↓
CPython harness/regrtest isolation
    ↓
state mutation
    ↓
structured EnvironmentObservation stream event
    ↓
qualified expected/forbidden result
```

Pass only when the actual mutation detail is structured and attributable. `ENV_CHANGED` alone is insufficient. Environment values are redacted by default and appear only under explicit capture policy.

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

## E5 — Declarative observation projection

P0 adapter evaluation; it does not depend on the later regrtest phase.

```text
validated finite monitoring-event batch
    + host-derived $subject
    + CUE-declared AdapterObservationProjection
    ↓
jsonata-core parse/evaluate under restricted profile
    ↓
ObservationCandidate[]
    ↓ Rust/CUE canonical validation
DynamicObservation[]
    ↓ Rust causal admission
CausalBinding[]
```

Pass when:

- a versioned projection selects CALL records and transforms offsets, positions, and JSON-safe callable descriptors;
- identical batch, subject, expression, engine version, and evaluator profile produce identical output;
- zero, one, and multiple candidates preserve declared cardinality and ambiguity;
- Rust independently verifies source/code correlation before creating causal bindings;
- expression/engine provenance survives into the attempt report;
- invalid syntax, forbidden functions, resource exhaustion, unsafe numeric encodings, undefined/null behavior, malformed input, wrong cardinality, and schema mismatch produce explicit diagnostics;
- JSON Pointer capture behavior remains unchanged.

## E6 — Multi-stream regrtest execution graph

P0 transport/graph evaluation; it proves the runtime context consumed by E2 and E3.

```text
regrtest parent stream
    + per-test process streams
    + process results
    ↓ Rust framing, validation, and spool
accepted StreamEvent set
    ↓ causal admission
partially ordered ExecutionGraph
```

Run at least two tests across two regrtest scheduling slots, with deliberately interleaved delivery. Pass when:

- parent facts identify selection, dispatch, scheduling slot, per-test process start, test result, rerun relation, and process exit;
- worker/runtime facts identify test start/end, thread/frame occurrences, and representative `PY_START`, `CALL`, branch, and exception events;
- `(run_id, stream_id, ordinal)` is unique, contiguous where the producer claims completeness, and replay-stable;
- dispatch→test-start, process-start→stream-start, test-end→test-result, and process-exit relations create explicit happens-before edges;
- unrelated events across streams remain unordered even when timestamps are available;
- sequential mode, worker-process mode, and `--parallel-threads` do not conflate scheduling slots, processes, or threads;
- invalid or reused bootstrap tickets, gaps, duplicates, malformed frames, unknown predecessors, overflow markers, disconnects, and missing stream-end acknowledgements yield explicit partial/incomplete state;
- a worker crash preserves its accepted prefix and reconciles it with the authoritative process result; and
- replaying the collector spool reconstructs the same normalized graph and diagnostics.

E6 does not prove adversarial tamper resistance or OS-level process completeness.

## E7 — Embedded Steel query/probe policy

P0 policy evaluation after E6 supplies a frozen execution-graph snapshot.

```text
PolicySpec + immutable PolicySnapshot
    ↓ capability-restricted Steel evaluation
PolicyDecision
    ↓ Rust conversion and validation
ProbeIntent[]
    ↓ ctrl/CUE qualification
DynamicProbePlan or no effect
```

Pass when:

- a small policy can query subject, compiler realization, runtime calls, and ambiguity through opaque handles;
- before a required CALL observation it returns a typed observation intent, and after the streamed observation it returns `Finish` or a narrower intent;
- the VM has no direct probe, filesystem, network, process, thread, clock, randomness, or mutable-evidence capability;
- identical policy source, capability version, snapshot, and budgets produce the same normalized decision;
- malformed or stale handles, invalid result types, duplicate/excessive intents, excessive graph traversal, timeout, and host-query failure produce `PolicyEvaluationFailed` and launch no effect;
- every native Rust capability is finite and independently bounded because VM interruption cannot preempt a running native function; and
- the report records policy/engine/capability digests, budgets, decision, and both Rust and ctrl/CUE validation outcomes.

E7 does not qualify untrusted policy execution. That requires process isolation and an independently enforced memory limit.

---

# 18. Candidate planning slices

These are planning candidates, not final repository slice manifests.

### A. Source snapshot + Astral adapter boundary

- mandatory content digest;
- dirty/unsaved source support;
- one static subject query.

### B. Compiler realization join

- code-object identity;
- instruction/source mapping;
- E1.

### C. Live observation stream and collector spool

- local IPC bootstrap and one-use producer tickets;
- run/attempt/process/stream identities and ordinals;
- framed versioned JSON events;
- bounded producer queues and explicit loss markers;
- collector validation, acknowledgement, durable spool, and replay;
- event-level source/code identity;
- trust/completeness and privacy metadata;
- process-result reconciliation.

### D. Execution graph reconstruction

- regrtest parent and per-test process lifecycle hooks;
- scheduling-slot/process distinction;
- explicit happens-before edges and unresolved predecessors;
- incomplete/crashed stream representation;
- E6.

### E. Declarative observation projection

- adapter-owned projection contract;
- restricted `jsonata-core` evaluator;
- canonical candidate validation;
- projection provenance and failure diagnostics;
- E5.

### F. Monitoring + callable identity

- one CALL query;
- non-invoking callable normalization;
- E2.

### G. Environment observation

- structured, redacted mutation capture;
- E3.

### H. Embedded semantic policy

Only after the Rust graph/query boundary exists:

- audited Steel capability module;
- frozen snapshots and typed `PolicyDecision` conversion;
- deterministic budgets, provenance, and fail-closed evaluation;
- no direct effects;
- E7.

### I. Regrtest backend/campaign integration

Only after prototype-plan gate permits it:

- regrtest invocation;
- rerun/randomization;
- case-set bisection with stability predicate;
- E4.

---

# 19. Initial non-goals

Do not introduce without an eval proving need:

- new generic `ExperimentSpec`;
- generic DAG/workflow engine;
- Python-side orchestration authority;
- a timestamp-sorted global event order;
- a sidecar as the primary semantic transport;
- JSONata as orchestration, validation, causal-admission, or qualification authority;
- JSONata as a global replacement for exact JSON Pointer captures;
- generic `ProbeSpec.projections` before E5 proves provider-neutral need;
- regrtest orchestration before the prototype plan gate;
- using regrtest `TestResult` as rich semantic payload;
- generic source minimization via `bisect_cmd`;
- SCIP indexing;
- mandatory LibCST representation;
- full Birdseye/snoop integration;
- duplicate parser/type/import engine;
- Python-owned persistent evidence ledger;
- Steel in the monitoring hot path;
- Steel ownership of facts, graph admission, validation, causal binding, or effect execution;
- treating in-process Steel evaluation as an untrusted-code sandbox;
- Steel policy as a replacement for `ProbeSpec` or ctrl/CUE qualification;
- python-control feedback logic;
- multi-language generalization.

---

# 20. Open technical decisions

Resolve with small evals:

1. **Digest algorithm/versioning** — content digest representation and normalization of source bytes.
2. **Coordinate contract** — Astral ranges vs CPython AST/`co_positions()` byte/line/column semantics.
3. **Code-object identity** — reconstructable digest, never runtime `id(code)` across runs.
4. **Frame occurrence identity** — ensure recursive/repeated frames remain distinct within an attempt.
5. **Event stream semantics** — framing version, stream boundaries, acknowledgements, predecessor references, and ordering guarantees under threads/free-threaded execution.
6. **Ambiguous lowering** — exact/bounded/inferred/unresolved relation vocabulary.
7. **Collector lifecycle** — local endpoint security, one-use ticket handoff, queue/backpressure limits, crash/truncation handling, spool durability, and replay schema.
8. **Callable normalization** — exact data available at monitoring callback time and whether additional frame/stack inspection is required.
9. **Static/dynamic target comparison** — rules for decorators, descriptors, monkeypatching, bound methods, dynamic dispatch, and opaque callables.
10. **Prototype-plan gate** — exact milestone after which regrtest becomes an allowed backend.
11. **Cache key** — include document/source snapshot, semantic-subject discriminator, project semantic environment, runtime identity, and full query/probe realization semantics.
12. **Evidence strength** — exact monitoring vs transformed/value instrumentation vs sampled evidence.
13. **Projection envelope** — provider schema/version compatibility and canonical output-kind registry.
14. **JSONata evaluator profile** — concrete finite resource limits and language/version compatibility policy.
15. **Projection promotion gate** — criteria for keeping projections adapter-scoped versus extending generic `ProbeSpec`.
16. **Trust escalation** — external observation/sandbox requirements for adversarial specimens.
17. **Privacy policy** — value-capture allowlists, redaction markers, truncation, and raw-artifact retention.
18. **Graph identity** — durable/replayable identity for run, attempt, test invocation, scheduling slot, process, thread, frame, and event occurrences.
19. **Causal admission** — behavior for missing, late, cyclic, or cross-run predecessor references.
20. **Steel capability ABI** — opaque handle lifetime, capability-set versioning, query cardinality, and normalized result vocabulary.
21. **Steel resource policy** — source, wall-time, host-call, graph-visit, result-row, intent-count, and diagnostic limits.
22. **Steel failure policy** — whether an explicitly configured fixed Rust fallback is ever appropriate.
23. **Untrusted policy boundary** — process isolation, memory enforcement, and artifact provenance required before accepting third-party Steel source.

---

# 21. Planning completion test

The dynamic implementation plan is sufficiently specified when the initial joins can answer:

```text
Given Astral semantic subject S and requested dynamic property D:

1. Which content-addressed source snapshot contains S?
2. What durable/static identity represents S?
3. What compiler realization connects S to CPython execution?
4. Which CPython primitive observes D?
5. How is the request lowered into the current prototype execution boundary?
6. Which producer stream carries the observation independently of process/regrtest result state?
7. How are stream identity, ordinal, lifecycle, loss, and replay represented?
8. Which explicit causal edges place the event in the run/attempt/test/process/thread/frame graph without inventing a global order?
9. What trust/completeness and privacy constraints apply to the raw observation?
10. Is the observation captured exactly or projected from a finite event batch into candidates?
11. How is projection/capture provenance represented?
12. How is the candidate normalized and validated into Rust?
13. If D is a call, what normalized callable identity was observed?
14. What causal relation binds the observation back to S?
15. If programmable policy is used, which immutable facts and bounded capabilities can it access, and what inert intent did it return?
16. How are that intent and the underlying observation admitted/evaluated through existing ctrl contracts?
17. How are ambiguity, opacity, concurrency, partial evidence, and failure represented without guessing?
```

If E1, E2, E3, and E6 have concrete answers, the causal semantic architecture is established. E5 qualifies declarative adapter projection but does not replace causal validation. E7 qualifies optional embedded policy but does not grant execution authority. E4 qualifies campaign reduction rather than gating the initial graph prototype.
