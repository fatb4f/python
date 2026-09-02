# Handoff Seed — Python-Intel Dynamic Semantic Extension

## Status

Technical-planning seed. Not a GitHub slice manifest. The project handoff bundle requires real parent/adjacent issue coordinates for `runtime.slice.v0`; create those only after selecting the implementation repository and parent issue.

## Planning directive

Build a prototype-level, eval-driven extension of Astral's Rust-native Python semantic engine into CPython compiler/runtime evidence.

**Do not build a second workflow engine.** The principal new component is a causal semantic bridge:

```text
Python source
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

Dynamic orchestration should therefore look like **semantic query/probe lowering**, with Rust retaining authority and CPython/regrtest acting as the execution plant.

---

# 1. Authority boundary

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

CPython checkout
    reference compiler/runtime, dynamic sensors, regrtest machinery

Python-side tooling
    actuator / sensor / optional projection only
```

Do not place control-plane authority in Marimo, Pydantic Graph, pytest, generated Python, or regrtest.

---

# 2. Upstream reuse

## Astral — fork and wrap

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
ty_project        if project-level integration needs it
```

Astral internal APIs are unstable. Add a narrow anti-corruption crate; do not make Astral-local Salsa IDs or internal semantic types durable python-intel identities.

Do **not** re-engineer:

- Python parser/AST;
- static scope/symbol/reference graph;
- type inference;
- import/module resolution;
- incremental static database.

## CPython — pin and use as the plant

Keep a pinned CPython tree initially. Prefer subprocess use of native machinery over importing `test.libregrtest` internals as a production API.

High-value surfaces:

```text
compile / code objects / dis / co_positions
sys.monitoring
sys.audit
traceback / inspect

Lib/test/libregrtest/runtests.py
Lib/test/libregrtest/result.py
Lib/test/libregrtest/run_workers.py
Lib/test/libregrtest/save_env.py
Lib/test/libregrtest/parallel_case.py
Lib/test/bisect_cmd.py
Lib/test/support/isolation.py
```

Regrtest already provides custom test directories, worker/process supervision, randomization, reruns, timeout/crash handling, process/thread stress, environment detection, refleak, bisection, and structured JSON worker/result boundaries.

## Optional provider/specimen machinery

Defer unless an eval needs it:

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

# 3. Core semantic model

The semantic model must causally join Astral constructs to CPython primitives. Do not collapse source/compiler/runtime objects into a single identity.

## StaticSubject

Astral-backed, provider-neutral projection:

```text
StaticSubject
├── repository_revision
├── path
├── source_range
├── syntax_kind
├── scope
├── symbol?
└── static_facts...
```

Examples: function, call, attribute, import, branch/condition, binding, reference, scope.

Astral remains authoritative for static interpretation. CPython AST/symtable are correlation/differential tools, not a duplicate static engine.

## CompilerRealization

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

## ExecutionOccurrence

```text
ExecutionOccurrence
├── probe_attempt
├── process
├── thread
├── frame
├── code_object
├── instruction_offset?
└── event_sequence?
```

## DynamicObservation

Normalize provider outputs into semantic observation families:

```text
CompilerObservation
MonitoringObservation
ExceptionObservation
AuditObservation
ImportRuntimeObservation
EnvironmentObservation
ValueObservation
SampleObservation
ResourceObservation
```

Preserve evidence strength. For example, py-spy sampling is not equivalent to exact `sys.monitoring` events.

## Causal spine

```text
SourceOccurrence
    --realized-as-->
CompilerRealization
    --instantiated-as-->
ExecutionOccurrence
    --observed-by-->
Observation
```

This spine is the primary new engineering contribution.

---

# 4. Correlation strategy

Exploit existing CPython positional machinery rather than inventing correlation from zero:

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
neutral SourceOccurrence
          ↓
Astral occurrence
```

P0 durable source identity:

```text
RepositoryRevision + Path + SourceRange
```

Astral-local IDs may be cached only as transient accelerators.

Must be engineered/evaluated:

- source coordinate normalization and encoding;
- exact vs bounded/inferred/unresolved joins;
- ambiguity representation rather than guessed 1:1 matches;
- code-object identity/digest;
- lambdas/comprehensions/nested code objects;
- revision lineage and provenance.

---

# 5. Semantic query → dynamic probe lowering

Treat orchestration as a small query compiler.

Example query:

```text
Was this Astral CallExpr executed, and what callable was invoked?
```

Possible lowering:

```text
1. resolve StaticSubject
2. establish CompilerRealization
3. select relevant CALL monitoring primitive
4. execute specimen under isolated CPython/regrtest
5. filter events by code/instruction realization
6. normalize RuntimeObservation
7. bind it causally to StaticSubject
8. admit/evaluate through ctrl qualification
```

Generic path:

```text
SemanticQuery
    ↓
DynamicProbePlan
    ↓
existing ProbeSpec + CPython provider lowering
    ↓
JSON/argv request
    ↓
CPython/regrtest
    ↓
JSON result + observation sidecar
    ↓
Rust normalization
    ↓
causal join
    ↓
SemanticReport
```

Progressive probing can initially be ordinary Rust algorithms. Add a generic DAG/scheduler only after shared dynamic scheduling becomes an observed requirement.

---

# 6. Existing ctrl ProbeSpec

Do not introduce a replacement `ExperimentSpec`.

The active generic probe contract already covers:

```text
fixture
obligations
argv stimulus
exit-code oracle
timeout
capture claims
```

Preferred P0:

```text
#ProbeSpec
    ↓
python-intel CPython adapter
    ↓
CPython/regrtest
    ↓
structured observation
    ↓
existing observation/evidence/qualification path
```

Keep CPython-specific controls behind adapter arguments at first. Add a narrow provider binding only if evals prove argv/config insufficient. Do not pollute generic `#ProbeSpec` with compiler/runtime-specific fields prematurely.

---

# 7. Regrtest role

Use regrtest for execution mechanics:

```text
selection/filtering
random seeds/order
rerun/fail-fast/forever
process workers
parallel-thread stress
timeout/crash handling
environment contamination
resource gates/refleak
bisection
result algebra
worker JSON transport
```

Regrtest does **not** own:

```text
semantic dependency policy
static↔dynamic identity
cross-probe causal reasoning
qualification/evidence semantics
```

Those remain Rust/ctrl concerns.

---

# 8. Rust-facing semantic API

Generalize Astral's report-producing pattern instead of inserting a second controller framework.

Conceptual provider model:

```text
PythonSemanticDb
├── AstralProvider
│   └── static queries
└── CPythonProvider
    └── compiler/runtime observation queries
```

Possible caller-level queries:

```text
symbol_at(subject)
references(symbol)
inferred_type(subject)

compile_observation(subject)
execution_observation(subject)
monitoring_observation(subject)
```

A CPython query crosses a process boundary, but that is an implementation detail beneath the semantic API.

Candidate report:

```text
SemanticReport
├── subject
├── static_observations[]
├── compiler_realizations[]
├── dynamic_observations[]
├── attempts[]
├── causal_bindings[]
└── evaluation/verdict?
```

Keep observation distinct from admitted evidence where `ctrl` requires it.

---

# 9. SCIP decision

**Defer SCIP from P0.**

Astral already provides enough static indexing to prove source→compiler→runtime joins. SCIP does not solve code-object, instruction, execution, frame, attempt, or cross-revision runtime identity.

Preserve compatibility with provider-neutral durable source identity:

```text
RepositoryRevision
Path
SourceRange
SymbolDescriptor?
```

Add SCIP later as a projection/interchange layer when external SCIP consumers, offline repository indexes, multiple language providers, or revision-scale navigation justify it:

```text
Astral semantic state
    ├── native python-intel queries
    └── SCIP projection
```

SCIP should not become semantic authority.

---

# 10. Thin P0 realization

Provisional shape:

```text
vendor/
├── astral/                 pinned fork
└── cpython/                pinned checkout/fork

crates/
├── python-intel-core/
│   ├── identities
│   ├── subjects
│   ├── observations
│   └── causal bindings
├── python-intel-astral/
│   └── narrow adapter
├── python-intel-cpython/
│   ├── request lowering
│   ├── process invocation
│   ├── result/sidecar decode
│   └── normalization
└── python-intel-query/
    └── semantic query/progressive probe algorithms

probes/
├── test_compile.py
├── test_monitoring.py
├── test_environment.py
└── test_import_runtime.py
```

Preserve existing repository/package conventions when implementation target is selected.

---

# 11. Required architecture evals

## E1 — Static occurrence → compiler realization

```text
Astral occurrence
    ↓
CPython compile
    ↓
code/instruction realization
    ↓
causal binding to source
```

Pass when relation is deterministic or explicitly ambiguous and does not use Astral-local IDs as durable identity.

## E2 — Static call/control subject → runtime event

```text
Astral CallExpr/branch
    ↓
CompilerRealization
    ↓
sys.monitoring
    ↓
matching event
    ↓
DynamicObservation bound to original subject
```

Pass when provenance includes interpreter + attempt + code/instruction coordinates and round-trips to the static subject.

## E3 — Environment mutation

```text
specimen
    ↓
regrtest isolation
    ↓
mutation
    ↓
EnvironmentObservation
    ↓
qualified expected/forbidden result
```

Use `save_env` as the reference pattern.

## E4 — Dynamic failure progression/minimization

```text
failing probe
    ↓
rerun/randomize as applicable
    ↓
bisection/minimization
    ↓
smaller reproducer
```

Pass when Rust owns why escalation occurs and regrtest owns execution mechanics.

---

# 12. Candidate implementation slices

These are planning candidates, not `runtime.slice.v0` manifests.

### A. Upstream pin + adapter boundary

Pin Astral/CPython revisions; establish license notices; compile one Astral adapter query; invoke pinned CPython/regrtest from Rust.

### B. Neutral identities + observation algebra

Define only the identities/relations needed for E1/E2. Avoid broad speculative ontology.

### C. Compiler realization join

Implement source range → code object/instruction relation and prove E1, including explicit ambiguity.

### D. Monitoring join

Lower one static subject query into `sys.monitoring`, normalize event output, and prove E2.

### E. Regrtest campaign semantics

Expose isolation/rerun/randomization/minimization through provider lowering and prove E3/E4.

Do not schedule SCIP, full Birdseye/snoop, py-spy, resource/leak expansion, or feedback control before these succeed.

---

# 13. Initial non-goals

Do not introduce without an eval proving need:

- new generic `ExperimentSpec`;
- generic DAG/workflow engine;
- Python-side orchestration authority;
- Marimo/Pydantic Graph as controller;
- SCIP indexing;
- mandatory LibCST representation;
- full Birdseye/snoop integration;
- production imports of `test.libregrtest` internals;
- duplicate parser/type/import engine;
- Python-owned persistent evidence ledger;
- python-control feedback logic;
- multi-language generalization.

---

# 14. Open technical decisions for planning

Resolve with small evals:

1. **Coordinate contract** — exact agreement between Astral ranges, CPython AST positions, and `co_positions()`.
2. **Code-object identity** — reconstructable/digest identity; never runtime `id(code)` across runs.
3. **Ambiguous lowering** — exact/bounded/inferred/unresolved relation semantics.
4. **Observation transport** — stdout JSON vs inherited descriptor/file vs sidecar while retaining native regrtest result channel.
5. **Regrtest request boundary** — begin with `python -m test --testdir ...`; patch worker JSON only if necessary.
6. **ProbeSpec projection** — adapter argv/config first vs narrow CPython provider binding.
7. **Cache key** — repository revision + interpreter identity + semantic subject + probe semantics, only after repeated-query evals justify persistence.
8. **Evidence strength** — exact monitoring, transformed/value instrumentation, and sampled py-spy observations must remain distinguishable.

---

# 15. Planning completion test

The implementation plan is sufficiently specified when E1–E4 can each answer:

```text
Given Astral semantic subject S and requested dynamic property D:

1. What durable identity represents S?
2. What compiler realization connects S to CPython execution?
3. Which CPython primitive observes D?
4. How is the semantic request lowered into ProbeSpec/provider invocation?
5. How is the CPython/regrtest response normalized into Rust?
6. What causal relation binds it back to S?
7. How is it admitted/evaluated through existing ctrl contracts?
8. How are ambiguity and failure represented without guessing?
```

If these have concrete answers, implementation can begin without another controller framework.

---

# 16. Upstream anchors

## Astral/Ruff

- root `Cargo.toml`: workspace/crate decomposition;
- `crates/ty_python_semantic`: internal unstable semantic API;
- `crates/ruff_db`: internal unstable incremental database API;
- MIT license.

## CPython

- `Lib/test/libregrtest/runtests.py`: structured run/worker configuration and JSON request;
- `Lib/test/libregrtest/result.py`: structured `TestResult` and JSON serialization;
- `Lib/test/libregrtest/run_workers.py`: process supervision/result transport;
- `Lib/test/libregrtest/cmdline.py`: workers, parallel threads, randomization, rerun, timeout, environment checking, refleak, bisection, `--testdir`;
- `Lib/test/libregrtest/save_env.py`: contamination semantics;
- `Lib/test/support/isolation.py`: subprocess isolation pattern;
- `Lib/test/bisect_cmd.py`: minimization pattern.

## ctrl

- active generic `#ProbeSpec` already participates in qualification workflow;
- fixture/process-realization/capture-claim machinery already exists;
- CPython is a provider/realization of that model, not a competing experiment-contract family.
