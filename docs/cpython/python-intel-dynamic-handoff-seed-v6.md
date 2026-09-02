# Handoff Seed v6 — Python-Intel Semantic Analytics and Lazy Hydration

## Status and document authority

Technical-planning seed for the dynamic semantic extension.

This document **does not supersede the adjacent `python-intel-prototype-plan.md` delivery sequence**. The prototype plan remains authoritative for implementation phases and may defer regrtest orchestration. This seed defines the semantic model, provider boundaries, and evals required for the later dynamic extension.

If the prototype plan and this seed differ:

```text
prototype plan      → delivery order / near-term implementation authority
this handoff seed   → dynamic semantic architecture / later extension authority
ctrl contracts      → qualification/evidence authority
```

The first implementation should prove the static→compiler→runtime causal join with the smallest CPython harness available. Once the prototype-plan gate permits regrtest integration, live parent/worker streams and Rust execution-graph reconstruction become the primary dynamic architecture. `arrow-rs` is an eval-gated candidate for the physical representation of accepted execution facts. DataFusion is a later eval-gated candidate for bounded analytical projections over those facts. The observation log, logical relations, claims, qualification, and effect authority remain distinct regardless of storage/query engine choice.

---

# 1. Planning directive

Extend Astral's Rust-native Python semantic model into CPython compiler/runtime evidence.

Do **not** build a second workflow engine or duplicate static analysis.

The principal new component is a Rust-owned observation and semantic-analytics plane:

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
    ↓ stored-as candidate
Arrow RecordBatch families + Rust indexes
    ↓ projected-as
AnalyticalRelation / MaterializedSemanticView
    ↓ proposes
ClaimCandidate
    ↓ qualified-by
ctrl / CUE
    ↓
Qualified Claim / Evidence
```

The invariant is:

```text
Provider emits Observation
Projection creates AnalyticalRelation
Analysis proposes ClaimCandidate
ctrl/CUE qualification admits Claim/Evidence
```

Dynamic orchestration is best modeled as **semantic query/probe lowering over an observed execution graph**. Rust owns observation admission, graph reconstruction, physical-store admission, analytical definitions, incremental invalidation, query/probe planning, intent validation, effects, and causal joins. CPython supplies compiler/runtime observations. Regrtest supplies campaign mechanics and orchestration facts. VCS supplies revision deltas. Arrow may store accepted facts. DataFusion may execute bounded analytical plans. Steel may compute policy over immutable Rust semantic snapshots but cannot execute effects.

---

# 2. Authority boundary

```text
ctrl / CUE
    obligations, generic ProbeSpec, evidence, qualification policy

python-intel Rust
    semantic queries
    multi-stream ingestion and execution-graph reconstruction
    typed fact normalization and Arrow admission
    Rust indexes over the selected physical store
    bitemporal/evidence lineage
    analytical relation definitions and incremental refresh
    cost-based semantic query / hydration planning
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

arrow-rs
    candidate physical representation for accepted normalized facts and replay;
    no semantic, causal, policy, or qualification authority

DataFusion
    candidate execution engine for bounded analytical projections over Arrow;
    no observation, lineage, invalidation, claim, probe, or qualification authority

VCS / Git
    revision identity and changed-path input for Rust-owned CDC/invalidation;
    not semantic subject-continuity authority

Python-side tooling
    actuator / sensor / bounded JSON serialization only
```

Do not place semantic authority or effect execution in Marimo, Pydantic Graph, pytest, generated Python, regrtest, JSONata, Arrow, DataFusion, Git, or Steel.

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

## 3.4 jsonata-core — external-JSON observation projection candidate

E5 evaluates `jsonata-core` as a Rust-native mechanism for selecting and transforming untyped/external provider JSON before canonical observation validation. Native CPython/regrtest records use the typed decoder and bypass JSONata.

The currently evaluated release is `jsonata-core` 2.2.7, licensed MIT. Use its Rust parser, evaluator, and `JValue` API directly; do not enable or route through the optional Python/PyO3 binding.

JSONata is not an orchestrator, Arrow query layer, validator, causal-relation engine, or evidence authority. It remains an external-adapter-scoped candidate dependency until E5 passes. Pin the exact crate version and source revision only in the selected implementation repository.

## 3.5 arrow-rs — normalized execution-fact store candidate

E8 evaluates `arrow-rs` as the physical representation of accepted, normalized runtime and orchestration facts.

The v6 combined E8/E9 baseline is 58.3.0, licensed Apache-2.0 with Rust 1.85 minimum support. Although v5 evaluated the newer standalone Arrow 59.2.0, DataFusion 54.1.0 currently depends on Arrow 58.3.0. E8 must be rerun against the aligned 58.3.0 baseline before E9; no v5 performance result transfers across this dependency change. Prefer the narrow `arrow-array`, `arrow-schema`, and `arrow-ipc` crates with unnecessary default features disabled; do not add Parquet, CSV, JSON, FFI, or PyArrow features to E8.

Arrow operates **after** Rust authenticates a producer, validates framing/schema/identity/order, and converts payloads into canonical typed facts. Producers continue to send small row-oriented records. Arrow does not define the logical execution graph, admit causal relations, validate semantic observations, or become visible through the Steel capability API.

E8 is a promotion gate, not a dependency decision. Until it passes, the v4 framed accepted-event spool remains the replay reference and the Rust logical model must remain storage-independent.

## 3.6 DataFusion — analytical projection candidate

E9 evaluates DataFusion as an in-process Rust query engine over E8-compatible Arrow tables.

The currently evaluated release is 54.1.0, licensed Apache-2.0 with Rust 1.88 minimum support and an Arrow 58.3.0 dependency. Use one workspace-wide Arrow 58.3.0 type universe, in-memory Arrow providers, and the typed DataFrame/logical-expression API with default features disabled. Do not retain a second Arrow major, bridge versions through JSON/IPC inside the process, or enable Parquet, object stores, compression, Avro, user SQL, arbitrary UDFs, or external catalog access in E9.

DataFusion executes a Rust-supplied bounded logical plan. Rust defines relation grain, schemas, temporal semantics, lineage, allowed operators, resource limits, incremental-refresh boundaries, and result validation. DataFusion is not an event log, CDC system, streaming CEP engine, materialized-view manager, semantic optimizer, or qualification authority.

## 3.7 Steel — semantic query/policy candidate

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

## 5.5 Logical graph and candidate physical fact store

`ExecutionGraph` is the logical model. It is relational rather than an ownership tree, because one fact can participate in several typed relations:

```text
RuntimeEvent E17
├── happens-before → RuntimeEvent E21
├── occurred-in    → FrameOccurrence F4
├── executed-as    → CompilerRealization C8
└── observes       → StaticSubject S5
```

E8 evaluates an `ExecutionFactStore` whose Arrow-backed implementation uses immutable `RecordBatch` families plus Rust-owned indexes. The logical query API must also run against the simple row-native reference store used for differential tests.

Required table families:

```text
identity/context
├── runs / attempts / test_invocations / worker_slots
├── processes / threads / frames
├── source_snapshot_refs / static_subject_refs
└── compiler_realization_refs

causal spine
├── event_envelopes
└── causal_edges

typed payloads
├── regrtest_events / process_events
├── call_events / branch_events / exception_events
└── environment_events

semantic outputs
├── observations
└── causal_bindings
```

`event_envelopes` holds common event identity and context. Each typed payload row has one non-null `event_id` foreign key into that table. Do not create one sparse union containing every optional payload column.

Arrow schemas are versioned independently by table family. Within Arrow, exact integer and fixed-size binary types preserve identifiers that require string encoding on the JSON wire. Nullability has schema-defined meaning and is not interchangeable with missing rows or unknown relations.

Rust builders accumulate accepted facts and flush on bounded row/byte thresholds, lifecycle boundaries, or memory pressure. Batch boundaries are physical only: changing them must not change identities, graph relations, query results, or replay digests.

Rust maintains identity lookup, `(batch, row)` location, adjacency, source/realization correlation, and unresolved-predecessor indexes. Arrow arrays do not become the public semantic API, and graph algorithms do not scan every batch when an admitted index can answer the relation.

## 5.6 DynamicObservation

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

## 5.7 Causal spine

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

# 6. Semantic analytics model

## 6.1 Observation, relation, claim, and decision

Keep four durable concepts separate:

```text
ObservationLog
    immutable provider-emitted facts with provenance
        ↓ projection
AnalyticalRelation
    reproducible derived rows with definition + input lineage
        ↓ analysis
ClaimCandidate
    proposed semantic interpretation with supporting/contrary lineage
        ↓ ctrl/CUE qualification
QualifiedClaim / Evidence / Decision
```

An analytical query result is not automatically evidence. A materialized view may be discarded and rebuilt. An observation is append-only except for an explicit retraction/supersession record. A qualified claim remains owned by ctrl/CUE.

```text
ClaimCandidate
├── claim_candidate_id
├── claim_kind / subject / proposed_value
├── analytical_definition_id + version
├── supporting_lineage[]
├── contrary_lineage[]
├── missing_or_indeterminate_requirements[]
├── valid_scope / transaction_cutoff
└── proposed_at
```

`ClaimCandidate` contains no implicit admitted/qualified flag. Qualification produces a separate ctrl-owned artifact referencing the candidate and lineage.

## 6.2 Minimal base relations and grain

Do not begin with a warehouse-wide ontology. E9 starts with five logical base relations; Arrow schemas are physical realizations of these contracts rather than their authority.

```text
Subject
grain: one content-addressed semantic-subject version in one source snapshot

RepositoryRevision
grain: one immutable VCS commit/repository-tree identity

ProviderRun
grain: one provider execution attempt under one realized environment

Observation
grain: one immutable normalized provider-emitted assertion or event

CausalEdge
grain: one typed directed relation between two identified lineage entities
```

Minimum logical fields:

```text
Subject
├── subject_version_id
├── semantic_entity_id?       # continuity is explicit, never guessed
├── source_snapshot_id
├── repository_revision_id?
├── source_range / syntax_kind / symbol_key?
├── valid_from_revision_id?
├── valid_to_revision_id?     # half-open; null means latest known version
└── predecessor_subject_ids[]

RepositoryRevision
├── repository_revision_id
├── repository_identity
├── commit_digest / tree_digest
├── parent_revision_ids[]
└── authored_at? / committed_at?   # diagnostic, not revision order

ProviderRun
├── provider_run_id
├── provider_identity / version
├── probe_spec_digest?
├── repository_revision_id? / source_snapshot_ids[]
├── environment_identity
├── campaign / attempt / process references?
├── started_at / finished_at?
└── recorded_at

Observation
├── observation_id
├── provider_run_id
├── observation_kind
├── subject_version_id?
├── valid_revision_id? / valid_source_snapshot_id
├── observed_at?              # provider-reported diagnostic time
├── recorded_at               # collector transaction time
├── trust / completeness
├── typed_payload
└── supersedes / retracts observation_id?

CausalEdge
├── causal_edge_id
├── predecessor: LineageRef
├── successor: LineageRef
├── relation_kind
├── origin: provider_observed | rust_derived | rust_admitted
├── provider_run_id? / observation_id?
├── valid_revision_id? / valid_source_snapshot_id?
├── recorded_at
└── trust / completeness
```

`LineageRef` is a tagged stable identity for the five base relations and already admitted execution-graph nodes. Tags and relation kinds are closed, versioned Rust/CUE enums. Do not use arbitrary strings or Arrow row locations as identifiers.

Runtime events, test invocations, compiler realizations, diagnostics, references, processes, and environments remain typed observation payloads or E8 physical table families initially. Promote one into another logical base relation only when an eval proves independent identity, lifecycle, or query requirements.

## 6.3 Dimensions and slowly changing semantic identity

The five base relations admit a dimensional projection without making warehouse terminology authoritative:

```text
facts
├── Observation
├── CausalEdge
└── ProviderRun

dimensions
├── Subject
└── RepositoryRevision
```

`Subject` uses a Type-2-like history: changes create a new `subject_version_id`; old rows are never overwritten. `semantic_entity_id` groups versions only when Rust establishes continuity from explicit rename/move analysis or admitted lineage. Ambiguous splits, merges, copy operations, and delete/recreate cases retain multiple candidate predecessor edges rather than one guessed identity.

Validity follows the repository revision DAG, not wall-clock comparison. `valid_from_revision_id`/`valid_to_revision_id` are conveniences for a proven linear lineage only; general queries use revision ancestry and explicit predecessor relations. Dirty/unsaved snapshots have content identity and no fabricated repository revision interval.

## 6.4 Bitemporal observation semantics

Every observation distinguishes:

```text
valid axis
    repository revision or exact source snapshot about which the fact is asserted

transaction axis
    collector recorded_at plus provider_run/campaign identity describing when learned
```

`observed_at` and monotonic event time are diagnostics inside a run; they do not replace either axis. A late campaign may add an observation valid for an older revision without implying that the repository changed at recording time.

Corrections are append-only. A retraction or superseding observation names the prior observation, preserves both transaction histories, and requires downstream views to recompute affected rows. Never rewrite old observations in place.

## 6.5 Evidence lineage

Every analytical row and claim candidate carries a `LineageToken`:

```text
LineageToken
├── relation_definition_id + version + digest
├── input_snapshot / high-watermarks
├── input_observation_ids[] or lineage-set digest
├── supporting_edge_ids[]
├── provider_run_ids[]
├── source_snapshot / revision identities
├── engine + plan digest
└── computed_at
```

Small result sets carry exact sorted IDs. Larger results store a content-addressed lineage set and count; the set remains queryable and must not be replaced by a probabilistic summary for qualification. `computed_at`, engine, and physical-plan provenance are excluded from the canonical lineage-set digest, so equivalent executors can be compared without erasing their distinct execution provenance. A claim candidate separately records supporting, contrary, missing, and indeterminate inputs.

Lineage and analytics cannot widen capture authority. Redacted or omitted provider values remain redacted or omitted in relations, materialized views, explanations, and claim candidates; access/capture policy travels with the lineage set.

Canonical evidence explanation follows:

```text
QualifiedClaim
    → ClaimCandidate
    → AnalyticalRelation row
    → Observation / CausalEdge
    → ProviderRun / ProbeSpec
    → RepositoryRevision / SourceSnapshot / Environment
```

## 6.6 Initial analytical relations

E9 implements only three versioned Rust-defined relations:

```text
SemanticHistory
grain: one subject version × repository/source-snapshot validity × observation
output: subject lineage, observation kind/outcome/trust, provider run, valid/recorded axes

AnalyzerDisagreement
grain: one subject version × assertion kind × comparison scope
output: normalized competing assertions by provider, agreement state, contrary/missing lineage

TestChangeImpact
grain: one changed subject version × test identity × revision transition
output: static dependency path, observed runtime/causal path, evidence strength, affected/indeterminate
```

Each `AnalyticalRelationDefinition` declares ID/version/digest, input relation/schema versions, output schema, row grain, valid/transaction scope, permitted operators, deterministic ordering, lineage policy, and query budget class. Changing any semantic element creates a new definition version and invalidates dependent materializations.

All results use deterministic ordering, closed outcome vocabularies, explicit `unknown`/`not_applicable`, and lineage tokens. Analyzer absence is not disagreement. Missing runtime observation is not non-execution without completeness. Test impact distinguishes static candidate impact from dynamically observed impact.

Cube-like views are projections over these relations, not separately admitted truth. Measures such as observation count, execution count, failure count, confidence class, and elapsed time must declare aggregation semantics. Dimensions may include subject, revision, environment, Python version, provider, and test. Do not sum confidence or compare wall times across incompatible environments.

Repository UI, editor, agent, CI, and ctrl consumers use typed analytical results and lineage explanations. They do not query Arrow/DataFusion internals or redefine relation semantics client-side.

## 6.7 Git CDC and incremental materialized views

Git supplies revision/tree identity and changed paths. Rust owns the semantic CDC pipeline:

```text
RepositoryRevision delta
    ↓ changed paths/content snapshots
Astral incremental update
    ↓ changed/added/removed semantic subjects
Rust dependency + lineage invalidation
    ↓ affected observations and view partitions
selective static recomputation / dynamic re-observation intents
```

Initial refresh scope is one explicit `(base_revision, candidate_revision)` transition, including merge commits by tree diff against the caller-selected base. Git history order never establishes subject continuity.

A `MaterializedViewState` records definition digest, input schema versions, base/candidate revisions, per-relation high-watermarks, canonical output-row digests, physical segment digests, lineage-set digests, and refresh outcome. Rust computes invalidation and executes a full or partition refresh; DataFusion does not provide incremental-view semantics.

Incremental and clean full recomputation must produce the same canonical relation rows and semantic lineage-set digests; refresh time, engine, plan, and physical-segment provenance remain distinct diagnostics. Removed inputs create invalidation/retraction outputs rather than silently leaving stale rows.

## 6.8 Event sourcing and bounded pattern analysis

The accepted observation log is immutable evidence input; derived coverage, call graphs, failure topology, environment effects, and analytical relations are replayable projections. Never collapse:

```text
observation ≠ projection ≠ interpretation ≠ decision
```

E9 is bounded batch analytics over a frozen snapshot. It does not claim streaming SQL or complex-event processing. Future pattern detection may consume admitted event windows, but a detected `PossibleRetryLoop` or effect sequence is an analytical relation/claim candidate with window definition and lineage—not a new raw observation.

## 6.9 Cost-based semantic query and hydration planning

Logical semantic queries may require facts not yet observed:

```text
SemanticQuery
    ↓ logical requirements + evidence strength
Rust semantic optimizer
    ├── scan existing qualified/compatible observations
    ├── incrementally hydrate static relations
    └── propose dynamic ProbeIntent[]
            ↓ ctrl/CUE applicability + effect qualification
        DynamicProbePlan
            ↓ execute provider
        new Observation
            ↓ re-plan until satisfied, exhausted, or deferred
```

Candidate cost contract:

```text
HydrationCost
├── cpu_units
├── wall_time_ms_upper_bound
├── process_count
├── event_volume_upper_bound
├── perturbation_class
├── effects[]
├── specimen_execution
├── evidence_strength
└── cache_reuse_scope
```

Candidate physical alternatives are ordered only after filtering by required evidence strength, trust, completeness, environment/revision compatibility, and ctrl applicability. A cheaper sampled observation cannot satisfy a claim requiring exact monitoring evidence.

Default preference among admissible alternatives:

```text
compatible existing observation
    → cached/static hydration
    → compiler-only observation
    → focused test/probe
    → isolated single-process execution
    → regrtest campaign
```

Cost estimates and chosen/rejected alternatives are report data, not qualification authority. Steel may propose a `ProbeIntent`, but Rust performs physical planning and ctrl/CUE gates every effect.

---

# 7. Callable identity normalization

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

# 8. Correlation strategy

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

# 9. Live multi-producer event streaming

Regrtest's JSON result channel is **not** sufficient for rich semantic observations.

`TestResult` communicates test execution state. Environment contamination details from `save_env` are primarily warnings plus the coarse `ENV_CHANGED` state. Monitoring events likewise have no generic place in `TestResult`.

Therefore add a dedicated live observation protocol without altering regrtest's existing result channel.

## 9.1 Local IPC transport

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

## 9.2 Narrow regrtest hooks

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

## 9.3 Stream lifecycle and durability

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

During E8, every accepted fact is also normalized through typed builders into Arrow `RecordBatch` families. Arrow IPC is a dual-written candidate replay form, never the only copy:

```text
accepted framed record
        ├── framed reference spool
        └── typed normalization
                ↓
           RecordBatch families
                ↓
       versioned Arrow IPC segments
```

Because an Arrow IPC stream has one schema, each table family uses its own sequence of bounded immutable IPC segments. A run manifest records schema versions, segment order, row counts, checksums, and committed/truncated state. Closed segments are committed atomically. Recovery accepts only complete verified segments and reports an incomplete final segment without inventing rows.

Malformed/rejected wire frames remain bounded raw diagnostics and never enter Arrow. The framed spool remains the E8 replay reference until Arrow promotion is explicitly approved after the eval.

JSON identifiers and integers outside the exactly representable `f64` integer range (`-(2^53-1)` through `2^53-1`) must use versioned string encodings. In particular, do not expose 64-bit identities or high-resolution timestamps to `jsonata-core::JValue` as lossy numbers.

## 9.4 Trust and completeness

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

## 9.5 Descendant-process coverage

P0 requires the regrtest parent and its directly launched per-test processes. Instrumented specimen descendants may join the same graph only through an explicit propagation hook that obtains a fresh child ticket and carries the parent process/event reference; never reuse or broadly inherit the worker ticket.

```text
regrtest parent → per-test process → instrumented specimen child → grandchild
```

An uninstrumented or uncooperative descendant remains an explicit coverage gap. Future OS-level or sampled providers may add observations at a different trust/evidence strength, but their absence does not make the cooperative stream complete.

## 9.6 Privacy and retention

Environment observations default to resource names and change kinds (`added`, `removed`, `changed`) with values redacted. Capturing selected values requires explicit ctrl/CUE capture policy.

Do not obtain diagnostic text by calling arbitrary object `repr()`. Sanitize and bound provider descriptions, payload strings, frame size, stream event counts, spool size, and admitted artifacts. Only explicitly admitted/captured material enters durable evidence or caches.

## 9.7 Result reconciliation

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

## 9.8 Declarative observation projection

JSON Pointer and JSONata serve different purposes, but neither is required for native CPython event normalization:

```text
JSON Pointer
    exact structural capture

JSONata
    untyped/external provider JSON filtering and transformation
```

Native CPython/regrtest flow:

```text
authenticated + structurally validated StreamEvent
        ↓ Rust typed decoder and semantic validation
typed execution/observation fact
        ↓
row-native or Arrow-backed ExecutionFactStore
```

External JSON adapter flow:

```text
structurally validated external JSON record or finite batch
        ↓
JSON Pointer captures / restricted JSONata projections
        ↓
ObservationCandidate[]
        ↓ Rust/CUE canonical validation
DynamicObservation[]
        ↓ typed fact normalization
ExecutionFactStore
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

JSONata evaluates individual external-provider payloads or finite bounded batches; it is not a stateful stream processor or a query layer over Arrow. Validation includes the provider-specific fields required by the projection, so a missing required field cannot masquerade as an empty match. P0 injects one immutable, host-derived `$subject` binding; producer-echoed subject hints are not authoritative.

JSONata never receives live Python objects or Arrow arrays. An external provider first converts runtime callables/values into bounded JSON-safe descriptors using the non-invoking inspection rules in section 7; JSONata may only select or reshape those descriptors. Native CPython records bypass JSONata rather than converting Arrow data back into JSON.

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

# 10. Semantic query → dynamic probe lowering

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
7. decode accepted CPython records into typed facts
8. admit facts into the selected physical store and partial-order graph
9. correlate event to code/instruction/source realization
10. canonicalize the JSON-safe callable descriptor
11. compare normalized callable to static target
12. expose a storage-independent frozen semantic snapshot to Rust or Steel policy
13. validate returned ProbeIntent values through Rust + ctrl/CUE
14. execute only the resulting qualified DynamicProbePlan
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
typed normalization + ExecutionFactStore admission
    ↓
ExecutionGraph indexes + Rust/CUE observation validation
    ↓
causal join
    ↓
optional Steel PolicyDecision
    ↓ Rust + ctrl/CUE validation
SemanticReport
```

The direct harness is a degenerate single-process execution graph. Regrtest later adds parent orchestration and per-test worker streams without changing the semantic, physical-store abstraction, or policy authority boundaries. External JSON providers may insert the E5 projection path before typed normalization; native CPython records do not.

---

# 11. Existing ctrl ProbeSpec

Do not introduce a replacement `ExperimentSpec`.

The generic probe contract already covers fixture/obligation/stimulus/oracle/timeout/capture-claim concerns.

Keep JSON Pointer as the capture-claim mechanism for exact structural paths. JSONata projections remain external-JSON-adapter configuration for E5; do not add a generic `projections[]` field to `#ProbeSpec` unless the eval demonstrates a provider-neutral requirement.

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
typed normalization + ExecutionFactStore
    ↓
ExecutionGraph + existing observation/evidence/qualification path
```

Keep CPython-specific controls behind adapter parameters first. Add a narrow provider binding only if evals prove the generic contract insufficient.

---

# 12. Regrtest role and scope

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

# 13. Failure progression and minimization

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

## 13.1 Flaky/stability criterion

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

# 14. Rust-facing semantic API

Generalize Astral's report-producing pattern rather than inserting a second controller framework.

Keep physical storage behind one Rust-owned interface:

```text
ExecutionFactStore
├── RowNativeFactStore       # E6 reference and differential oracle
└── ArrowFactStore           # E8 candidate
```

Both implementations accept the same canonical typed facts and provide the same identity lookup, adjacency, bounded scan, and immutable snapshot semantics. Neither public query results nor durable semantic identities contain Arrow batch or row locations.

The semantic analytics API is likewise engine-independent:

```text
SemanticAnalyticsDb
├── append_observation / append_causal_edge
├── snapshot(valid_scope, transaction_cutoff)
├── query(AnalyticalQuery, QueryBudget)
├── explain_lineage(LineageToken)
├── refresh(MaterializedViewId, RevisionTransition)
└── plan_hydration(SemanticRequirement, HydrationBudget)

AnalyticalQuery
├── SemanticHistory(subject_or_entity, revision_scope)
├── AnalyzerDisagreement(subject_scope, assertion_kind)
└── TestChangeImpact(base_revision, candidate_revision, subject_scope)

AnalyticalResult<T>
├── definition_id / version / digest
├── snapshot_id
├── rows: T[]
├── row_lineage: LineageToken[]
├── completeness / diagnostics
└── physical_plan_digest
```

The Rust query builder accepts only typed predicates, dimensions, measures, ordering, and limits supported by the relation definition. DataFusion logical/physical plans remain internal artifacts and user-provided SQL is not a public interface.

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
execution_diff(baseline_attempt, candidate_attempt, subject?)
semantic_history(subject_or_entity, revision_scope)
analyzer_disagreement(subject_scope, assertion_kind)
test_change_impact(base_revision, candidate_revision, subject_scope)
explain_lineage(lineage_token)
plan_hydration(requirement, budget)
```

`execution_diff` is a Rust semantic query over normalized facts. Its initial projection reports newly/missing executed branches and calls, changed callable targets, new exceptions, environment mutation changes, and event-count deltas keyed by static subject where correlation exists. It does not require SQL or expose physical table schemas.

Candidate report:

```text
SemanticReport
├── subject
├── static_observations[]
├── compiler_realizations[]
├── execution_graph_projection
├── dynamic_observations[]
├── attempts[]
├── execution_diffs[]
├── analytical_results[]
├── claim_candidates[]
├── hydration_plan?
├── causal_bindings[]
└── evaluation/verdict?
```

Keep observation distinct from admitted evidence where `ctrl` requires it.

---

# 15. Embedded Steel semantic policy

Steel is a candidate programmable query/policy layer over immutable Rust-owned facts. It returns inert values; it never launches a probe.

## 15.1 Typed boundary

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
semantic-history
analyzer-disagreement
test-change-impact
ambiguous?
has-observation?
probe-cost
```

Steel receives inert constructors such as `request-observation`, `request-rerun`, `request-stress`, `request-bisect-cases`, `finish`, and `defer`. Constructors only build `PolicyDecision` values.

Rust converts the result through `FromSteelVal`, then validates subject existence, observation kind, parameters, cardinality, duplicate intents, staleness, and aggregate probe cost. ctrl/CUE then qualifies the validated intents before Rust lowers any `DynamicProbePlan`.

## 15.2 Capability and resource boundary

E7 uses a fresh `Engine::new_raw()` for each evaluation and registers only an audited policy module. Do not expose filesystem, network, process, thread, dynamic-library, time, randomness, async, mutable-reference, or execution capabilities.

Budgets cover policy source size, wall time, host-call count, graph visits, returned rows, output intents, and diagnostic size. `InterruptHandler` provides bytecode timeout but checks at VM safe points and cannot preempt a running native Rust function. Every registered Rust query must therefore be synchronous, non-blocking, side-effect-free, and independently bounded.

Parse, compile, timeout, host-query, conversion, budget, or validation failure yields `PolicyEvaluationFailed` and launches no probe. A fixed Rust fallback policy runs only when explicitly configured.

Do not claim Steel is a sandbox or hard memory boundary. P0 assumes trusted/project-controlled policy source. Untrusted policy requires future process isolation and an independently enforced memory limit.

Steel contracts and macros may improve policy ergonomics, but they remain implementation-safety tools. Rust types and ctrl/CUE remain authoritative.

## 15.3 Replay and frequency

Record the policy digest, Steel version, capability-set version, snapshot ID, budgets, normalized decision, and Rust/ctrl validation outcome. Identical inputs must reproduce the same normalized decision.

Steel runs at decision frequency over a frozen `PolicySnapshot`. It never receives raw monitoring streams, Arrow arrays, `RecordBatch` handles, or physical row locations and does not participate in event decoding, fact-store admission, graph admission, or hot-path correlation. Rust implements the stable capability API against the selected `ExecutionFactStore`.

---

# 16. SCIP decision

Defer SCIP from P0.

Astral already provides enough static indexing to prove source→compiler→runtime joins. SCIP does not solve code-object, instruction, execution, frame, attempt, content-snapshot, or runtime occurrence identity.

Preserve future compatibility by using provider-neutral source identity with mandatory content digest.

Add SCIP later as an index/projection layer when external consumers, multi-language providers, offline revision indexes, or repository-scale navigation justify it.

---

# 17. Thin prototype realization

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
│   ├── external JSON adapter projection
│   └── normalization
├── python-intel-facts/
│   ├── row-native reference store
│   └── Arrow candidate after E8
├── python-intel-analytics/
│   ├── relation definitions and lineage
│   ├── CDC / materialized-view refresh
│   ├── Rust reference executor
│   └── DataFusion candidate after E9
├── python-intel-policy/
│   └── optional Steel host after E7
└── python-intel-query/
    └── semantic query, hydration cost, and progressive probe algorithms

python probe harness/
├── compile probe
├── monitoring probe
├── environment probe
└── import-runtime probe
```

Regrtest integration remains gated, but its first admitted slice is the narrow streaming and execution-graph eval rather than campaign automation.

---

# 18. Required architecture evals

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

External/untyped JSON adapter evaluation; native CPython/regrtest records bypass it.

```text
validated finite external-provider JSON batch
    + host-derived $subject
    + CUE-declared AdapterObservationProjection
    ↓
jsonata-core parse/evaluate under restricted profile
    ↓
ObservationCandidate[]
    ↓ Rust/CUE canonical validation
DynamicObservation[]
    ↓ typed fact normalization
ExecutionFactStore
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
- native CPython events reach the same canonical observation type without JSONata or Arrow→JSON conversion;
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

## E8 — Arrow-backed execution fact store and replay

Run after E6 establishes the accepted-event and logical-graph reference behavior. E8 has higher implementation priority than E5 and E7, but its number preserves the existing eval identities.

```text
accepted parent/worker records
        ├── RowNativeFactStore + framed reference spool
        └── typed Arrow builders
                ↓
          RecordBatch families
                ↓
        Rust indexes + Arrow IPC segments
                ↓
 storage-independent ExecutionGraph queries
```

Functional pass criteria:

- authenticated accepted records normalize losslessly into the table families from section 5.5; rejected records never enter Arrow;
- common envelope rows and typed payload rows preserve exact identities, null semantics, trust, completeness, and foreign-key integrity;
- changing builder flush thresholds and batch boundaries produces identical canonical facts, graph edges, observations, and query results;
- row-native ingestion, framed-spool replay, live Arrow ingestion, and Arrow-IPC replay produce the same normalized graph/diagnostic digest;
- each table family has an independent schema version and IPC segment sequence; the manifest detects missing, reordered, duplicated, corrupt, incompatible, and truncated segments;
- crash recovery preserves only complete verified segments, reports the incomplete suffix, and never invents a clean stream end;
- late/missing predecessors remain explicit unresolved relations and resolve identically in both stores;
- the same bounded Rust queries implement `executions_of`, `runtime_calls`, `descendants`, `exceptions_under`, and baseline/candidate differential counts without exposing Arrow to callers; and
- Steel policy decisions are identical against row-native and Arrow-backed snapshots.

Performance gate:

- use a deterministic fixture containing 1,000,000 mixed lifecycle, CALL, branch, exception, and environment events across multiple streams;
- compare allocator-observed retained-store peak memory, accepted-event ingestion throughput, and latency for identity lookup, subject execution scan, frame-descendant exception query, and baseline/candidate aggregation;
- perform one warm-up and five measured runs under the same optimized build and machine conditions;
- take the median of each query's five measurements and use the geometric mean of those four medians as the representative-query metric;
- promote Arrow only if all functional criteria pass and it achieves at least 25% lower retained peak memory **or** at least 25% lower representative-query metric, while accepted-event ingestion throughput is no more than 10% worse than the row-native reference; and
- record raw measurements and fixture/schema digests so the promotion result is reproducible.

Until this gate passes and promotion is recorded, Arrow remains optional dual-write evaluation infrastructure. E8 by itself excludes DataFusion, Parquet, worker-side Arrow generation, and direct Steel access to Arrow; E9 separately evaluates the aligned DataFusion/Arrow pair after the functional gate.

## E9 — Minimal semantic analytics and DataFusion differential

Run after E8 proves the functional Arrow schemas. E9 may use evaluation-only Arrow batches even if E8 has not promoted Arrow as the default store.

```text
five immutable base relations
        ↓ frozen bitemporal snapshot
Rust reference executor ─────┐
DataFusion executor ─────────┤
                             ↓
  three canonical analytical relations + lineage
```

Use two repository revisions with retained, changed, renamed/ambiguous, added, and removed subjects; at least two static providers; two Python environments; one complete and one partial runtime provider run; conflicting assertions; a late observation valid for the base revision; and a retraction/supersession pair.

Pass when:

- every base relation enforces the grain and minimum fields from section 6.2;
- valid revision/source-snapshot scope and transaction cutoff independently change results as specified;
- `SemanticHistory`, `AnalyzerDisagreement`, and `TestChangeImpact` produce deterministic canonical rows with exact outcome vocabularies;
- analyzer absence, `unknown`, `not_applicable`, contradiction, partial runtime coverage, and ambiguous subject continuity remain distinct;
- each result row explains through exact or content-addressed lineage to observations, causal edges, provider runs, probe digest, revision/source snapshot, and environment;
- retracted observations remain queryable historically but are excluded from a later transaction-cutoff view according to the relation definition;
- the Rust reference executor and DataFusion executor return identical canonical rows, ordering, null semantics, lineage-set digests, and semantic diagnostics while retaining distinct engine/physical-plan provenance;
- the resolved dependency graph contains one Arrow version line (58.3.0 for this eval) shared by E8 storage and DataFusion;
- DataFusion receives only Rust-built logical expressions over registered in-memory tables, with bounded input rows, output rows, memory, planning time, and execution time;
- no user SQL, arbitrary UDF, filesystem/object-store table, Parquet source, or network/catalog access exists; and
- analytical results remain relation rows/claim candidates and do not enter ctrl evidence without qualification.

E9 qualifies DataFusion only as a replaceable physical executor for the three relations. Rust remains the definition, temporal, lineage, and validation authority.

## E10 — Git CDC and incremental materialized views

Run after E9 defines canonical full-recomputation results.

```text
base revision + candidate revision
    ↓ Git tree delta + Astral semantic delta
invalidation set
    ↓ partition refresh
MaterializedViewState
    ↔ clean full recomputation oracle
```

Pass when:

- a linear revision transition, a merge commit with explicit selected base, dirty/unsaved candidate content, file rename, symbol edit, deletion, and copy/ambiguous continuity produce explicit delta classifications;
- changed subjects invalidate dependent observations and only the affected partitions of the three E9 relations;
- a late observation, supersession, retraction, provider-version change, environment change, and relation-definition change invalidate the correct transaction/view scope;
- incremental refresh and clean full recomputation produce identical sorted rows, canonical output-row digests, and semantic lineage-set digests;
- removed inputs yield explicit removed/retracted output rows or partition replacement rather than stale materialization;
- the view state records definition/schema digests, revision transition, input high-watermarks, output digests, refresh reason, and failure/partial state;
- interrupted refresh leaves the previous committed view readable and never exposes a partially committed replacement; and
- instrumentation proves unaffected partitions are reused rather than recomputed.

Git supplies tree changes only. Astral/Rust establish semantic subject deltas, continuity candidates, and dependency invalidation.

## E11 — Cost-based lazy semantic hydration

Run after E9 supplies query requirements and lineage-aware compatible-observation lookup.

```text
SemanticRequirement + evidence/trust/completeness constraints
    ↓ enumerate compatible physical alternatives
HydrationPlan with costs and rejection reasons
    ↓ ctrl/CUE qualifies effects
execute selected probe or return existing/partial/deferred result
    ↓ append observation + re-plan
```

Pass when:

- the planner considers compatible existing evidence, cached/static hydration, compiler observation, focused test, isolated execution, and regrtest campaign alternatives;
- revision/source snapshot, environment, provider version, trust, completeness, evidence strength, expiry, and claim requirements reject incompatible cached observations before cost comparison;
- every alternative reports normalized `HydrationCost`, expected output kind, prerequisites, ctrl applicability, and a stable rejection/selection reason;
- the cheapest admissible alternative is selected deterministically with an explicit stable tie-break order;
- no `ProbeIntent` or `HydrationPlan` executes an effect until Rust validation and ctrl/CUE qualification succeed;
- newly admitted observations cause bounded re-planning, while duplicate/no-progress results, exhausted budgets, cycles, and unsatisfied evidence requirements end as explicit `deferred`, `partial`, or `failed` outcomes;
- cost-estimation error is recorded by comparing estimates with actual CPU, wall time, process count, event volume, and perturbation class; and
- replaying the same semantic snapshot, statistics snapshot, requirements, budgets, and planner version yields the same plan.

E11 is a semantic/probe optimizer, not a generic workflow engine. Steel may propose intent but cannot choose an unqualified physical effect.

---

# 19. Candidate planning slices

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

### E. Arrow fact-store evaluation

After E6 defines the reference behavior:

- canonical typed-fact boundary and row-native oracle;
- versioned non-sparse `RecordBatch` families;
- Rust identity/adjacency/correlation indexes;
- dual-written per-family Arrow IPC segments and manifest;
- deterministic replay/differential query suite and promotion benchmark;
- E8.

### F. Declarative external-JSON observation projection

- adapter-owned projection contract;
- restricted `jsonata-core` evaluator;
- canonical candidate validation;
- projection provenance and failure diagnostics;
- no native CPython or Arrow round-trip;
- E5.

### G. Monitoring + callable identity

- one CALL query;
- non-invoking callable normalization;
- E2.

### H. Environment observation

- structured, redacted mutation capture;
- E3.

### I. Embedded semantic policy

Only after the Rust graph/query boundary exists:

- audited Steel capability module;
- frozen snapshots and typed `PolicyDecision` conversion;
- deterministic budgets, provenance, and fail-closed evaluation;
- no direct effects;
- E7.

### J. Regrtest backend/campaign integration

Only after prototype-plan gate permits it:

- regrtest invocation;
- rerun/randomization;
- case-set bisection with stability predicate;
- E4.

### K. Minimal semantic analytics

After the E8 functional schema gate:

- five base-relation contracts with explicit grain;
- bitemporal snapshot and append-only correction semantics;
- exact/content-addressed lineage tokens;
- three canonical Rust reference relations;
- bounded DataFusion differential executor;
- E9.

### L. Revision CDC and materialized views

After E9 fixes full-recomputation semantics:

- Git tree delta + Astral subject delta;
- dependency/lineage invalidation;
- transactional partition refresh and view-state manifest;
- incremental/full equivalence fixtures;
- E10.

### M. Lazy hydration optimizer

After compatible-observation lookup and ctrl applicability are available:

- typed semantic requirements and evidence constraints;
- normalized hydration costs and statistics snapshot;
- deterministic alternative enumeration/selection;
- bounded re-planning and no-progress termination;
- E11.

---

# 20. Initial non-goals

Do not introduce without an eval proving need:

- new generic `ExperimentSpec`;
- generic DAG/workflow engine;
- Python-side orchestration authority;
- a timestamp-sorted global event order;
- a sidecar as the primary semantic transport;
- worker-side Arrow construction or Arrow IPC transport;
- Arrow as semantic, causal-admission, query-policy, validation, or qualification authority;
- one sparse Arrow event table containing every event-family payload;
- Arrow batch/row locations in public identities, semantic reports, or Steel handles;
- DataFusion, Parquet, Arrow FFI/PyArrow, or long-lived analytical storage in E8;
- DataFusion as observation storage, schema/temporal/lineage authority, CDC engine, materialized-view manager, probe planner, or qualification authority;
- public user SQL, arbitrary DataFusion UDFs, external catalogs/object stores, or filesystem table discovery in E9;
- assuming DataFusion provides incremental materialized views, streaming SQL, or complex-event processing;
- a generic OLAP server/cube engine or a thirty-table semantic warehouse before E9;
- treating analytical relation rows or aggregates as automatically qualified evidence;
- in-place observation updates, deletion of retracted history, or wall-clock time as repository validity;
- accepting Git rename detection as semantic subject continuity without Astral/Rust admission;
- summing ordinal confidence classes or aggregating incompatible environment timings;
- generic live CEP/pattern-triggered execution before a separate bounded eval;
- JSONata as orchestration, validation, causal-admission, or qualification authority;
- JSONata as a global replacement for exact JSON Pointer captures;
- JSONata in the native CPython normalization or Arrow query path;
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

# 21. Open technical decisions

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
24. **Arrow identifier types** — exact fixed-size binary/integer representation for durable and run-scoped keys without JSON numeric loss.
25. **Arrow schema evolution** — compatible additions, explicit migrations, and fail-closed behavior for unsupported table-family versions.
26. **Arrow segment manifest** — checksum algorithm, atomic commit mechanism, compression policy, and garbage collection of incomplete evaluation artifacts.
27. **Fact-store index lifecycle** — incremental maintenance, unresolved-edge repair, snapshot freezing, and rebuilding indexes from IPC replay.
28. **Semantic entity continuity** — admitted evidence and ambiguity rules for rename, move, split, merge, copy, and delete/recreate histories.
29. **Temporal snapshot API** — revision-DAG scope, dirty/source-snapshot validity, transaction cutoff precision, and retention of late/retracted facts.
30. **Lineage-set storage** — content-addressing, deduplication, exact expansion limits, privacy filtering, and garbage collection.
31. **Analytical definition ABI** — relation schema/version evolution, canonical ordering, measure aggregation, and compatibility of materialized rows.
32. **DataFusion budgets** — concrete planning/execution time, memory-pool, spill-disabled, input/output row, join-cardinality, and cancellation limits.
33. **Materialized-view commit** — output segmentation, atomic manifest replacement, prior-version retention, and crash recovery.
34. **Semantic CDC dependency index** — representation and invalidation behavior for static, dynamic, environment, provider, and relation-definition dependencies.
35. **Hydration statistics** — provenance, expiry, environment stratification, uncertainty bounds, and feedback from estimated versus actual cost.
36. **Hydration cache compatibility** — exact revision/source, environment, provider, trust, completeness, and evidence-strength reuse rules.

---

# 22. Planning completion test

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
10. Is the observation a native typed fact, an exact capture, or a projection from an external JSON batch?
11. How is projection/capture provenance represented without routing native CPython or Arrow data through JSONata?
12. How is the candidate normalized and validated into Rust?
13. Which storage-independent typed-fact and query interfaces preserve the logical execution graph?
14. If Arrow is selected, which versioned table family stores the fact and how are batch boundaries prevented from changing semantics?
15. Can the framed spool, row-native store, live Arrow store, and Arrow IPC replay reproduce the same graph and diagnostics?
16. If D is a call, what normalized callable identity was observed?
17. What causal relation binds the observation back to S?
18. If programmable policy is used, which immutable facts and bounded capabilities can it access, and what inert intent did it return?
19. How are that intent and the underlying observation admitted/evaluated through existing ctrl contracts?
20. How are ambiguity, opacity, concurrency, partial evidence, and failure represented without guessing?
21. What is the explicit grain of each stored fact/dimension and analytical result?
22. What repository/source validity and transaction cutoff scope the observation?
23. Can every analytical row and claim candidate expand to exact observations, causal edges, provider runs, probes, revisions, snapshots, and environments?
24. Are subject changes represented as immutable versions with explicit admitted or ambiguous continuity?
25. Do semantic history, analyzer disagreement, and test/change impact distinguish absence, unknown, contradiction, partial coverage, and not-applicable?
26. Does incremental refresh produce the same rows and lineage as clean full recomputation after revision, provider, environment, late-observation, and retraction deltas?
27. Which existing/static/dynamic hydration alternatives satisfy the requested evidence strength, and why was each selected or rejected?
28. Which ctrl/CUE gate authorizes any selected physical probe, and how does bounded re-planning terminate?
```

If E1, E2, E3, and E6 have concrete answers, the causal semantic architecture is established. E8 determines whether Arrow is promoted from dual-write candidate to the default physical fact store. E9 qualifies the five-relation semantic-analytics plane and optional DataFusion executor. E10 qualifies revision CDC and incremental materialization against full recomputation. E11 qualifies cost-based lazy hydration without granting effect authority. E5 qualifies only external-JSON adapter projection. E7 qualifies optional embedded policy but grants neither storage nor execution authority. E4 qualifies campaign reduction rather than gating the initial graph prototype.
