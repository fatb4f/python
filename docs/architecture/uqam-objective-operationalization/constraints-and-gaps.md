# Constraint and gap analysis

## Hard constraints

### C1 — Existing semantic authority remains primary

The extension must consume the existing semantic model rather than define a competing ontology.

Required invariant:

```text
course objective
    -> semantic requirement
    -> operational task
```

not:

```text
course chapter
    -> new parallel learning framework
```

### C2 — Ops owns operational progression

Course chronology can influence which objectives are currently useful, but it must not redefine the Ops progression. O0–O8 remain the operational families.

### C3 — Xonsh capability tiers remain orthogonal

T0–T3 describe environment capability, not academic completion. No `INF1120 tier`, `INF1035 tier`, or equivalent should be introduced.

### C4 — Runtime authority stays explicit

Python, Java/JDK, Xonsh, subprocesses, and scientific libraries have distinct authority boundaries. A shared semantic task must not erase runtime-specific behavior.

### C5 — Durable semantics remain in repository artifacts

Closing an interactive shell must lose no authoritative learning/task semantics. Exercises, expected behavior, coverage relations, and validation claims belong in repository contracts/specimens/tests.

### C6 — External course material is objective/evaluation evidence

The external UQAM corpus may establish:

- objectives to cover;
- course-specific deliverable requirements;
- assessment weights/timing when relevant to planning;
- correction constraints that apply to submitted artifacts.

It does not establish general tooling authority over private learning or engineering work.

### C7 — Submission constraints are boundary-scoped

Authorship/originality, required format, required behavior, correction rules, and submission procedure must be represented as deliverable-boundary constraints rather than global runtime/tooling policy.

### C8 — No premature abstraction

A shared member IR, object-pipeline DSL, Java reflection adapter, generators, or codegen layer must be justified by repeated observed friction. Their conceptual usefulness is not sufficient for adoption.

### C9 — Coverage must be evidence-bearing

An objective is not `demonstrated` merely because a document was read or a chapter date passed. Coverage state must be supported by operational evidence.

### C10 — Cross-repository provenance remains explicit

The `fatb4f/factory` UQAM corpus is an external source reference. `fatb4f/python` must not silently copy it and then treat the copy as upstream authority.

## Current gaps

| ID | Gap | Consequence | Gate / proposed resolution |
| --- | --- | --- | --- |
| G1 | No typed external objective contract | Course goals can only be represented informally | Add `#Objective` + source/provenance reference |
| G2 | No typed semantic-capability relation | Objective-to-PPF mapping cannot be validated | Add `#SemanticCapability` / requirement references |
| G3 | Ops tasks are documented but not typed as reusable learning entities | Coverage cannot point to a stable task identity | Add `#OperationalTask` contract before generating tasks |
| G4 | No generic realization relation | Python/Java implementations can drift into separate curricula | Add `#Realization` with runtime and boundary semantics |
| G5 | No coverage evidence model | Completion risks becoming chapter/checklist based | Add `explain/realize/observe/validate/transfer` evidence |
| G6 | No `transfer` evidence primitive | Cross-language equivalence/difference is not directly captured | Add transfer to the learning evidence vocabulary |
| G7 | No explicit assessment-boundary contract | Tooling rules can leak incorrectly into private learning policy | Add boundary-scoped evaluation constraints; omit global `allowed_tools` |
| G8 | Cross-repository source references are untyped | Provenance can become path prose | Add repository/path/source-id reference fields |
| G9 | Java is absent from current realization vocabulary | INF1120 cannot be projected without ad-hoc handling | Add `java` / `jvm-process` runtime values without making Java semantic authority |
| G10 | No Java observation specimens | Compiler/runtime boundaries are conceptual only | First executable slice should use `javac`, `java`, status/stdout/stderr, then focused `javap`/reflection later |
| G11 | Object/property/method pipeline is planned but not stabilized | Premature common IR could hide Python/Java differences | Defer adapter/DSL until repeated inspection produces stable requirements |
| G12 | Scientific-data objective projection is not yet operationalized | INF1035 weeks 11–14 remain only topical labels | Add NumPy/Pandas/Matplotlib/sklearn realizations after core contracts prove stable |
| G13 | No mechanical coverage query | Human inspection required to know which objectives have evidence | Defer query/report generation until objective/task/evidence identities stabilize |
| G14 | No typed link from tracker issue to architecture contract | Parent issue can reference prose but not validate architecture state | Keep tracker operational; use explicit authoritative paths and markers per tracker contract |

## Constraint interactions

### Shared semantics vs runtime specificity

We want maximum reuse at the task level and minimum false equivalence at the runtime level.

```text
shared
    task semantics
    success predicates
    evidence kinds
    coverage relation

runtime-specific
    syntax
    type rules
    compiler/interpreter behavior
    exception hierarchy
    object model
    library contracts
    runtime metadata
```

The adapter boundary belongs between these sets.

### Objective coverage vs course chronology

The course schedule is useful as a planning signal, but coverage must remain graph-like:

```text
objective A -> semantic capability X
objective B -> semantic capability X
objective C -> semantic capability X + Y
```

One operational task may therefore cover requirements from both courses, and one objective may require multiple tasks.

### Deliverable integrity vs learning tooling

The system should preserve this separation:

```text
learning evidence
    proves capability

submitted deliverable
    proves compliance with the assessment boundary
```

They may overlap, but they are not the same artifact class.

## Admission gates before implementation

Implementation beyond scaffolding should wait until all of these are true:

- [ ] Objective/source identity is typed and provenance-bearing.
- [ ] Semantic capability requirements reference the existing PPF vocabulary rather than duplicating it.
- [ ] Operational task identity and postconditions are typed.
- [ ] Runtime realizations preserve explicit boundaries and failures.
- [ ] Coverage evidence includes transfer without requiring every objective to use transfer.
- [ ] Deliverable/evaluation constraints are boundary-scoped.
- [ ] INF1120 and INF1035 projections validate against the generic contract.
- [ ] At least one shared task can be expressed without adding a new semantic primitive.

## First-slice acceptance

A first implementation slice is architecture-valid when a single task can be shown as:

```text
external objectives from both courses
    -> shared semantic requirement
    -> one operational task contract
    -> Python realization
    -> Java realization
    -> observable validation
    -> evidence supporting both objective projections
```

The slice should be rejected if it requires course-specific semantics, hidden shell state, an untyped code generator, or a global tooling-policy field.
