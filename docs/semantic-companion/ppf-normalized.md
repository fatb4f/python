# PPF normalized semantic extract

## Status and provenance

**Role:** source-faithful semantic reference for the Python learning repository  
**Source:** `fatb4f/ppf` `docs/theory/drafts/01.md` and `docs/theory/drafts/02.md` on `main`  
**Normalization:** removes repetition, groups equivalent statements, and preserves the source terminology and direction of dependency  
**Authority:** this document is an extract of the PPF theory drafts; it does not promote PPF implementation details into the Python curriculum

Source documents:

- [`fatb4f/ppf/docs/theory/drafts/01.md`](https://github.com/fatb4f/ppf/blob/main/docs/theory/drafts/01.md)
- [`fatb4f/ppf/docs/theory/drafts/02.md`](https://github.com/fatb4f/ppf/blob/main/docs/theory/drafts/02.md)

The two drafts share one central framing:

> Design begins with domain meaning and variability, then resolves contracts, implementations, composition, execution, and observation. Python functions, dataclasses, protocols, factories, adapters, HOFs, and orchestrators are implementation elements whose arrangement is selected by the actual design forces.

---

# 1. Core semantic model

The first draft begins with this dependency:

```text
DOMAIN
  │ defines nouns, invariants, lifecycle, failure semantics
  ▼
VARIABILITY AXIS
  ├─ construction varies ───────► factory / builder / provider
  ├─ algorithm varies ──────────► strategy / HOF / policy function
  ├─ representation varies ─────► adapter / mapper / serializer
  ├─ control flow varies ───────► orchestrator / state machine / workflow
  ├─ effects vary ──────────────► port + adapter / dependency injection
  └─ lifecycle varies ──────────► context manager / supervisor / pool
  ▼
CONTRACTS
  ▼
IMPLEMENTATIONS
  ▼
COMPOSITION
  ▼
EXECUTION
  ▼
OBSERVATION + TESTS
```

The named layer contracts are:

```text
Operation function
    performs one semantic verb

Higher-order function
    accepts/returns operation functions
    adds reusable execution policy

Factory
    selects or constructs an implementation

Orchestrator
    controls when and in what order operations execute

Adapter
    translates an abstract operation into a concrete external effect

Domain model
    defines what states and transitions are valid
```

---

# 2. Minimal ontology

The second draft normalizes application structure into seven practical concepts:

```text
1. DATA
2. RULE
3. OPERATION
4. POLICY
5. BOUNDARY
6. COMPOSITION
7. STATE
```

The expanded ontology is:

```text
SYSTEM
├── DATA
│   ├── Value
│   ├── Entity
│   ├── Configuration
│   └── Result
│
├── RULE
│   ├── Type constraint
│   ├── Invariant
│   ├── Precondition
│   └── Postcondition
│
├── OPERATION
│   ├── Query        Data → Data
│   ├── Transform    Data → Data
│   ├── Decision     Data → Choice
│   ├── Command      Data → Effect
│   └── Constructor  Config → Capability
│
├── STATE
│   ├── Current state
│   ├── Event
│   └── Transition   State × Event → State
│
├── VARIATION
│   ├── Policy
│   ├── Strategy
│   ├── Implementation
│   └── Configuration
│
├── COMPOSITION
│   ├── Sequence
│   ├── Pipeline
│   ├── Branch
│   ├── Parallel group
│   └── Dependency graph
│
├── BOUNDARY
│   ├── Port
│   ├── Adapter
│   ├── Serializer
│   └── External resource
│
└── CONTROL
    ├── Factory
    ├── Dispatcher
    ├── Orchestrator
    ├── State machine
    ├── Supervisor
    └── Reconciler
```

The important relations are:

```text
Data
  ──constrained-by──► Rule
  ──consumed-by─────► Operation
  ──produced-by─────► Operation

Operation
  ──selected-by─────► Policy
  ──constructed-by──► Factory
  ──wrapped-by──────► HOF
  ──ordered-by──────► Orchestrator
  ──implemented-by──► Adapter

State
  ──changed-by──────► Transition
  ──observed-by─────► Query
  ──driven-by───────► Event

Orchestrator
  ──executes────────► Operation
  ──evaluates───────► Result
  ──advances────────► State
```

Specializations compress to:

```text
Factory
  = Operation + Policy
  = choose/construct implementation

HOF
  = Operation over Operations
  = add reusable execution policy

Adapter
  = Boundary Operation
  = translate abstract capability into concrete effect

Orchestrator
  = Composition + State
  = control execution across multiple operations

State machine
  = State + Rules + Transition Operation

Reconciler
  = Observe + Decide + Act + Repeat
```

---

# 3. Domain tuple

A domain can be represented as:

```text
Domain :=
(
  Data,
  Invariants,
  Operations,
  States,
  Transitions,
  Policies,
  Effects
)
```

The source example is document processing:

```text
Data
    RawDocument
    ParsedDocument
    ValidatedDocument

Invariants
    schema is recognized
    identifiers are unique

Operations
    parse
    normalize
    validate
    persist

States
    received
    parsed
    valid
    rejected
    persisted

Transitions
    received ─parse────► parsed
    parsed ─validate───► valid
    parsed ─failure────► rejected
    valid ─persist─────► persisted

Policies
    parser selection
    validation profile
    rejection severity

Effects
    read file
    write database
    publish event
```

Pattern selection then follows from the tuple:

```text
multiple parsers
  ─► Strategy or factory

multiple storage systems
  ─► Port + adapter

ordered parse/validate/persist
  ─► Pipeline or orchestrator

explicit processing statuses
  ─► State machine

cross-cutting retries/tracing
  ─► HOF/decorator
```

---

# 4. Design-resolution DAG

Start from the use case, not from a pattern name.

```text
S0: DEFINE USE CASE

produce:
    Input
    Output
    Errors
    Invariants
    Side effects

    ↓ contract explicit

S1: CLASSIFY VARIABILITY
```

Questions:

```text
Q1: Do implementations vary?
Q2: Does object construction vary?
Q3: Does algorithm/policy vary?
Q4: Does execution order vary?
Q5: Do external systems vary?
Q6: Does resource lifecycle matter?
```

Resolution:

```text
construction varies
    ─► factory / builder / provider

algorithm varies
    ─► strategy / HOF / policy function

control flow varies
    ─► pipeline / DAG executor / state machine / workflow / reconciler

external effect varies
    ─► port + adapter / adapter factory / repository

lifecycle varies
    ─► context manager / pool / task group / supervisor

nothing varies
    ─► direct function
```

The source explicitly prefers the smallest structure justified by variability.

---

# 5. Operation hierarchy

The first draft defines a useful function hierarchy.

```text
L0: PRIMITIVE EFFECT
    read_file
    write_file
    execute_process
    send_http
    begin_transaction

L1: ADAPTER OPERATION
    load_repository
    save_document
    run_assessor
    publish_artifact

    concrete technology known

L2: DOMAIN OPERATION
    admit_evidence
    calculate_price
    classify_document
    resolve_revision

    domain language
    no workflow ownership

L3: HIGHER-ORDER POLICY
    retry(operation)
    timeout(operation)
    trace(operation)
    authorize(operation)
    cache(operation)
    compensate(operation)

    accepts or returns operations

L4: ORCHESTRATION
    qualify_repository
    process_order
    execute_workflow
    reconcile_target

    controls sequence, branching and lifecycle

L5: ENTRYPOINT
    CLI command
    HTTP handler
    scheduled job
    event consumer

    translates external input
    invokes one use case
```

Dependency direction:

```text
L5 ─► L4 ─► L3 ─► L2 ─► ports
                              ▲
                              │
                         L1 adapters
                              │
                              ▼
                         L0 effects
```

Forbidden edges in the source include:

```text
L2 domain operation ─X─► CLI arguments
L2 domain operation ─X─► concrete database client
L1 adapter          ─X─► workflow decisions
L0 primitive        ─X─► domain policy
Factory             ─X─► business workflow execution
HOF                 ─X─► hidden global configuration
```

---

# 6. Operation, HOF, factory, orchestrator, adapter

## Operation

```text
one semantic verb
one owned effect or transformation
explicit input
explicit output
explicit failures
no hidden sequencing
```

Granularity warning:

```text
function contains:
    "and then"
    multiple unrelated external effects
    retry decisions
    branching workflow states
    compensation logic

    └─► probably an orchestrator
```

## HOF

```text
input:
    operation function
    policy/configuration

output:
    operation function with preserved semantic contract

owns:
    reusable execution policy

does not own:
    domain-specific workflow order
```

Typical shape:

```text
base operation
  ↓
validation wrapper
  ↓
authorization wrapper
  ↓
retry wrapper
  ↓
timeout wrapper
  ↓
tracing wrapper
  ↓
callable operation
```

## Factory

Minimal semantic form:

```text
Factory := discriminator/configuration → implementation/capability
```

or:

```python
Factory = Callable[[Config], Capability]
```

A factory can return:

```text
object
function
closure
adapter
resource
dependency bundle
execution plan
```

It is not fundamentally OOP.

## Orchestrator

Owns:

```text
order
branching
concurrency
rollback
termination
```

It invokes operations rather than absorbing their low-level effects.

## Adapter

Owns translation from an abstract capability into a concrete external effect. It should not own workflow decisions.

---

# 7. Factory selection and Python preference

Factory decision:

```text
Need to create something?
  │
  ├─ no ─► use an operation function
  │
  └─ yes
      │
      ├─ stable obvious constructor
      │   └─► direct construction
      │
      ├─ config selects implementation
      │   └─► factory function
      │
      ├─ alternate semantic constructor
      │   └─► classmethod factory
      │
      ├─ subclass decides product
      │   └─► factory method
      │
      ├─ related compatible products
      │   └─► abstract factory
      │
      ├─ ordered construction steps
      │   └─► builder
      │
      ├─ configured template copy
      │   └─► prototype / copy
      │
      └─ dynamic discovery
          └─► registry + factory
```

Python preference order from the source:

```text
1. direct constructor
2. factory function
3. classmethod alternate constructor
4. callable dependency/provider
5. registry + factory
6. abstract factory object
7. class-heavy GoF implementation
```

Reason:

```text
Python functions are first-class
  ↓
behavior does not require a class
  ↓
many Strategy / Command / Factory Method examples collapse into callables
  ↓
classes remain useful when state, lifecycle or multiple related methods exist
```

---

# 8. Classic pattern → Python primitive projection

The drafts repeatedly translate class-heavy patterns into smaller Python structures.

| Pattern | Minimal semantics | Python-first projection |
| --- | --- | --- |
| Factory Method | Inject construction decision | constructor callable / factory function / `@classmethod` |
| Abstract Factory | Compatible family of constructors | dependency bundle or dataclass of callables |
| Builder | Staged construction | validated transforms / config accumulation |
| Prototype | Derive value from existing value | `copy`, `deepcopy`, `dataclasses.replace` |
| Strategy | Select algorithm | function / closure / `Protocol` |
| Template Method | Fixed flow, variable steps | HOF with injected functions |
| Command | Reify requested operation | function or dataclass payload + handler |
| Observer | Notify subscribers | callback collection / event stream |
| Iterator | Incremental traversal | generator |
| Visitor | Add operations over variants | `match` / `singledispatch` |
| Chain of Responsibility | Ordered conditional handlers | sequence of functions |
| Decorator | Wrap operation | HOF / Python decorator |
| Adapter | Translate contracts | wrapper function/object implementing a contract |
| Facade | Simplified capability surface | module or service function |
| State | Behavior depends on current state | tagged data + transition function |
| Mediator | Central coordination | orchestration function / event router |
| Composite | Uniform recursive structure | recursive dataclass |

The second draft summarizes the data-oriented substrate as:

```text
algebraic data types
+ pure functions
+ function values
+ explicit state transitions
+ effect adapters
+ composition functions
```

Python realization:

```text
dataclass / NamedTuple / TypedDict
    product data types

Enum / Literal / union
    sum data types

function
    operation

Callable
    strategy / capability

Protocol
    behavioral contract

match
    variant dispatch

generator
    iterator

decorator / HOF
    execution-policy composition

context manager
    lifecycle protocol

module
    namespace / facade / singleton-like instance
```

---

# 9. Dataclasses and algorithms are not patterns

The source is explicit:

```text
Dataclass
    representation of data/state

Algorithm/function
    transformation or decision

Design pattern
    recurring arrangement of:
        data
        operations
        ownership
        variability
        control flow
        effects
```

Therefore:

```text
dataclasses + algorithms
  ≠ design patterns

dataclasses + algorithms
  + explicit variability
  + composition
  + control ownership
  + effect boundaries
  = data-oriented realization of design patterns
```

An algorithm performs work. A pattern determines:

```text
where it lives
how it is selected
how it is composed
who invokes it
how it is replaced
how failures propagate
```

---

# 10. Common domain projections

The first draft applies the same vocabulary across domains.

| Domain | Main concerns / projections |
| --- | --- |
| Parsing / serialization | factory for format selection; strategy for parser; composite for recursive syntax; visitor/`singledispatch` for traversal; generator for streaming; pipeline for normalization |
| Storage / repositories | factory for backend; repository boundary; adapter for SQL/API; unit of work for transaction; context manager/pool for lifecycle; cache/decorator for read policy |
| HTTP / CLI boundaries | dispatcher; middleware/decorator; application service; adapter/mapper; composition root/factory |
| Plugins | registry; factory; `Protocol`; strategy; adapter |
| Data pipelines / ETL | pipeline; HOF/combinator; generator; adapter factory; result/dead-letter sink; DAG executor |
| Validation / policy | predicate functions; composite rule sets; factory/registry; HOF; decision strategy; reconciler |
| Resource management | factory/provider; context manager; pool; retry/circuit-breaker HOF; supervisor |
| UI product families | abstract factory; composite; observer/callback; command; builder |
| Workflow / automation | builder/factory; orchestrator; state machine; process manager; saga; reconciler |

The point of these examples is not to prescribe the named patterns. It is to show that recurring forces map to recurring responsibility structures.

---

# 11. Runtime execution DAG

The first draft defines an explicit runtime sequence:

```text
R0 RECEIVE
    parse transport representation
    → request DTO

R1 NORMALIZE
    canonicalize values
    apply defaults

R2 VALIDATE CONTRACT
    structural validation
    invariant validation

R3 RESOLVE IMPLEMENTATIONS
    factory selects adapters and strategies
    → dependency bundle

R4 COMPOSE POLICIES
    retry
    timeout
    trace
    authorize
    → executable operations

R5 BUILD PLAN
    project request into steps/dependencies
    → execution plan / DAG

R6 ORCHESTRATE
    schedule ready nodes
    invoke operations
    collect results
    update workflow state

R7 JUDGE
    evaluate output against invariants
    accepted / repair / reject

R8 PUBLISH
    persist result
    emit evidence
    return response
```

Failure paths remain explicit: parse failure, rejection, configuration failure, planning failure, retryable/compensable/repairable/terminal execution failure, or terminal rejection.

---

# 12. Python implementation DAG

The first draft projects the semantics into a staged Python implementation:

```text
P0 DEFINE TYPES
    models.py / errors.py
    immutable dataclasses, enums, identifiers, result types

P1 DEFINE PORTS
    ports.py
    Protocols and callable aliases

P2 IMPLEMENT PURE OPERATIONS
    normalization, validation, projection, policy decisions

P3 IMPLEMENT ADAPTERS
    filesystem, subprocess, sqlite, http

P4 IMPLEMENT FACTORIES
    implementation selection

P5 IMPLEMENT HOFs
    retry, timeout, tracing, validation

P6 IMPLEMENT ORCHESTRATOR
    one function per use case
    explicit sequence and state transitions

P7 COMPOSITION ROOT
    read config
    call factories
    wrap operations
    construct dependency bundle / use cases

P8 ENTRYPOINT
    parse external request
    invoke use case
    map result to external response

P9 TEST MATRIX
    unit
    contract
    orchestration
    integration
    thin end-to-end slice
```

The proposed minimal topology is correspondingly:

```text
src/package/
├── models.py
├── errors.py
├── ports.py
├── operations.py
├── policies.py
├── combinators.py
├── factories.py
├── workflows.py
├── bootstrap.py
├── cli.py
└── adapters/
    ├── memory.py
    ├── filesystem.py
    ├── subprocess.py
    └── sqlite.py

tests/
├── unit/
├── contract/
├── orchestration/
└── integration/
```

This is a source projection, not a mandatory repository layout for `fatb4f/python`.

---

# 13. Learning execution DAG

The source also gives a staged learning sequence:

```text
K0 FUNCTIONS
    parameters, returns, exceptions, pure/effectful

K1 TYPES
    dataclass, Enum, union, Protocol, Callable

K2 FIRST-CLASS FUNCTIONS
    function arguments/returns, closure, partial

K3 HOFs
    decorators, wrappers, composition

K4 FACTORIES
    constructor, factory function, classmethod, registry

K5 ADAPTERS
    Protocol implementation, translation boundary, dependency injection

K6 ORCHESTRATION
    application service, explicit states, dependency ordering

K7 LIFECYCLE
    context manager, generator, async task group

K8 WORKFLOW
    state machine, retry, compensation, reconciliation
```

Each stage in the draft is paired with an exercise and a gate. The recurring learning rule is to establish the primitive behavior first, then introduce the responsibility structure that solves a concrete variation or control problem.

---

# 14. Pattern-selection constraints

The first draft gives explicit positive and negative rules.

## Factory

Use when:

```text
implementation identity varies
construction requires policy
caller should not know concrete type
```

Do not use when:

```text
constructor is stable
only one implementation exists
factory merely renames the constructor
```

## HOF

Use when:

```text
behavior wraps another behavior
policy is reusable
input/output contract remains stable
```

Do not use when:

```text
wrapper controls an entire business workflow
mutation and hidden state dominate
execution order must be externally visible
```

## Orchestrator

Use when:

```text
multiple operations form one use case
order or branching matters
failure changes subsequent behavior
execution produces workflow state
```

Do not use when:

```text
one operation is sufficient
a simple pipeline expresses the flow
the function only forwards arguments
```

## Adapter

Use when:

```text
external representation differs
technology should remain replaceable
testing requires a fake implementation
```

---

# 15. Practical classification rule

The second draft provides a direct language-to-structure classifier:

```text
"The system contains..."
    ─► Data

"The value must..."
    ─► Invariant

"The system calculates..."
    ─► Algorithm / operation

"The implementation depends on..."
    ─► Factory / strategy

"Before and after every operation..."
    ─► HOF / decorator

"The system calls A, then B..."
    ─► Pipeline / orchestrator

"When state X receives event Y..."
    ─► State machine

"The same operation must support backend Z..."
    ─► Port / adapter

"The system repeatedly drives X toward Y..."
    ─► Reconciler
```

This classifier is particularly useful as a semantic-companion bridge because it begins from the requirement sentence rather than the implementation construct.

---

# 16. Thin prototype realization

The first draft ends with a deliberately small vertical slice:

```text
request
  ↓
validate_request
  ↓
repository factory
  ↓
repository adapter
  ↓
traced(save_document)
  ↓
orchestrator
  ↓
result
```

Required artifacts in the source:

```text
1 request dataclass
1 result dataclass
1 repository Protocol
2 repository adapters:
    memory
    filesystem
1 factory function
2 pure operations:
    normalize
    validate
1 HOF:
    trace
1 orchestration function:
    execute_use_case
1 CLI entrypoint
```

Acceptance behavior:

```text
valid request
    normalized
    validated
    adapter selected
    document saved
    result returned

invalid request
    validation error
    no adapter effect

unknown adapter
    configuration error
    no workflow execution

adapter failure
    typed operational failure
    trace retained
```

---

# 17. Canonical compression

The two drafts compress to the following source-faithful vocabulary:

```text
Domain
    defines valid meaning

Data
    represents values and state

Rule
    constrains values and transitions

Operation
    performs one semantic verb

Algorithm
    implements an operation

Factory
    chooses what implementation/capability exists
    Config → Capability

Strategy
    is a selected algorithm

HOF
    modifies how an operation behaves
    Operation → Operation

Adapter
    determines how abstract capability reaches a concrete effect

Orchestrator
    determines when operations run
    State × Operations → State

State machine
    determines which transition is legal

Reconciler
    observes, decides, acts, and repeats toward desired state
```

Pattern selection remains variation-driven:

```text
construction ─► factory
algorithm ────► strategy / HOF
representation ► adapter
sequence ─────► orchestrator
transition ───► state machine
convergence ──► reconciler
lifecycle ────► context manager / supervisor
```

And the key distinction from the second draft remains:

```text
dataclasses + algorithms
    are implementation substrate

pattern
    is the recurring arrangement of operations
    around variability, ownership, composition,
    control flow, and effect boundaries
```
