# Pre-implementation analysis

## Question

Can the existing Python Immersion semantic/Ops model cover both current UQAM course objective sets without introducing a second learning architecture?

## Conclusion

Yes. The current model already contains the required control loop:

```text
task
  -> semantic decomposition
  -> constraints
  -> admissible representations
  -> smallest adequate realization
  -> execution
  -> observation
  -> validation
  -> revision
```

The missing capability is not another progression model. It is a typed projection from external objectives into semantic capabilities, operational tasks, realizations, and evidence.

## Existing contract fit

### Semantic axis

The PPF vocabulary already supplies the cross-language semantic authority:

- `DATA` — values, collections, records, object state, file content;
- `RULE` — predicates, invariants, validation conditions, typing/correction constraints;
- `OPERATION` — select, transform, branch, iterate, invoke, parse, aggregate, effect;
- `POLICY` — choice among otherwise admissible realizations;
- `BOUNDARY` — process, filesystem, compiler/runtime, serialization, I/O;
- `COMPOSITION` — ordered value/effect flow and decomposition;
- `STATE` — bindings, accumulators, object state, external state, learned model state.

Both course plans can be normalized onto these facets.

### Ops axis

The existing Ops families already span the required progression:

```text
O0 CROSS                 runtime/process/I/O boundaries
O1 OBSERVE               type, representation, status, metadata, failure
O2 SELECT + TRANSFORM    expressions, parsing, filtering, mapping, aggregation
O3 COMPOSE               functions, methods, reusable value flows
O4 CONTROL               predicates, branching, iteration, assertions
O5 AUTOMATE              files, serialization, repeatable data/process work
O6 QUALIFY               preconditions, postconditions, tests, robustness
O7 INSTRUMENT            timing/provenance/failure context when required
O8 PROJECT               integrated applications and data tools
```

No course-specific Ops family is required.

### Capability axis

The Xonsh tiers remain orthogonal:

```text
T0 CROSS -> T1 OBSERVE -> T2 COMPOSE -> T3 EXTEND
```

Neither course requires T3. T3 remains an optional shell-engineering outcome earned only by repeated interaction friction.

## Course objective normalization

### INF1120

The current objective set is principally:

```text
problem analysis / requirements
  -> algorithms + pseudocode
  -> Java representation and execution
  -> scalar types / expressions / conversion / I/O
  -> predicates + selection
  -> loops
  -> methods / parameters / returns / decomposition
  -> classes / objects / references / encapsulation
  -> arrays / traversal
  -> exceptions
  -> text files
  -> testing / reliability / understandability / modifiability
```

This projects naturally into representation, control, composition, state, boundaries, and qualification.

### INF1035

The current objective set is principally:

```text
physical/binary/computational representation
  -> Python values and expressions
  -> conditions + boolean logic
  -> loops
  -> functions
  -> files + exceptions
  -> lists + tuples
  -> strings + CSV
  -> dictionaries + sets + JSON
  -> NumPy
  -> Pandas
  -> Matplotlib
  -> scikit-learn
```

This projects naturally into the same semantic surface, then extends into structured/scientific representations and project-level library composition.

## Shared operational core

The overlap is substantial enough that the default learning unit should be a semantic task with multiple realizations rather than separate language tutorials.

Example:

```text
TASK
    consume observations and retain valid values until termination

DATA
    observations + accumulator

RULE
    validity predicate + termination predicate

OPERATION
    iterate -> select -> accumulate

POLICY
    reject invalid observations

STATE
    accumulator + termination state
```

Possible realizations:

```text
Python
    bool + for/while + list + function

Java
    boolean + for/while + array/collection + method
```

The learning claim is stronger when the semantic contract survives the representation change.

## Java integration model

Java should be introduced as another explicit execution authority:

```text
source representation
    -> javac
    -> compiler observation
    -> class/runtime representation
    -> java execution
    -> behavior/failure observation
```

The shell owns process composition, not Java semantics. The JDK owns compiler/runtime behavior. Java source owns the submitted program semantics. The shared learning model owns task decomposition and qualification.

The compiler boundary is particularly useful because it exposes a typed external boundary early:

- source text is not runtime behavior;
- compilation success is not semantic correctness;
- process status, stdout, and stderr are separate observations;
- runtime behavior supplies additional evidence;
- tests and predicates qualify the result.

## Object/property/method inspection pipeline

The planned PowerShell-like structured pipeline remains useful, but it is not required for the first implementation slice.

The reusable semantic shape is:

```text
structured subjects
  -> enumerate members/records
  -> filter by predicate
  -> project properties
  -> sort/group/aggregate
  -> inspect or invoke selected subjects
```

Python introspection and Java reflection can eventually supply adapters over a common member record, but that abstraction should be admitted only after repeated cross-runtime inspection demonstrates stable common fields and meaningful differences.

Initial Java observation should prefer direct mechanisms such as `javac`, `java`, `javap`, and focused reflection specimens before introducing a shared member IR.

## Deliverable boundary

Assessment concerns must be modeled separately from the learning/runtime environment.

```text
private learning / engineering environment
    user authority
        |
        v
candidate deliverable
        |
        v
submission boundary
    authorship/originality
    required format
    required behavior
    correction constraints
    submission procedure
```

The contract must not contain a generic `allowed_tools` authority for external course material. Tool choice belongs to the learning/engineering environment unless a concrete submitted artifact must satisfy an independently applicable deliverable condition.

## Contract-first implementation order

The smallest admissible implementation sequence is:

```text
1. objective/source contract
2. semantic capability + task relation
3. realization relation
4. evidence + coverage relation
5. term-qualified INF1120/INF1035 projection
6. manually authored operational specimens
7. observe repetition/friction
8. only then evaluate generators, adapters, query DSLs, or UI projections
```

This preserves the repository escalation rule:

```text
manual understanding
  -> repeated use
  -> observed friction
  -> smallest useful abstraction
  -> evaluation
  -> retain or remove
```

## First implementation slice

The first executable slice should demonstrate one shared semantic task through both Python and Java with explicit process/runtime observations and validation.

Candidate scope:

```text
semantic capability
    predicate + iteration + state + validation

Python realization
    function over a sequence

Java realization
    method over an array or collection

observations
    values, branch/loop behavior, result, failure

evidence
    explain + realize + observe + validate + transfer
```

No DSL, generator, Java reflection adapter, scientific library integration, or course schedule automation is required to prove the architecture.
