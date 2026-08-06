# Schema-Driven Diagnostic Feedback System

CPython's semantic tools, PEP 669, pytest, and numerical control models can be
combined into a closed-loop diagnostic system. Each layer has a distinct role:

```text
React Flow
    exploratory workflow authoring and evidence visualization
        ↓
pytest
    experiment materialization, isolation, execution, and qualification
        ↓
CPython transforms + PEP 669 sensors
    semantic and runtime evidence
        ↓
belief estimator + policy selector
    update hypotheses and choose a legal discrete probe
        ↓
python-control
    simulate numeric projections and evaluate candidate policies
        ↓
pytest
    verify verdicts, convergence, cost, and model accuracy
```

The canonical artifact is the semantic evidence graph. `python-control` consumes
a fixed-dimensional numerical projection of that graph; it does not replace the
graph, transform registry, workflow legality model, or provenance store.

## Responsibilities

| Component | Responsibility |
| --- | --- |
| React Flow | Explore workflows and display episode evidence |
| CPython tools | Run semantic and implementation transforms |
| PEP 669 | Produce low-overhead runtime event measurements |
| pytest | Materialize experiments and evaluate complete diagnostic episodes |
| Belief estimator | Update a posterior over latent diagnostic hypotheses |
| Policy selector | Choose the next legal categorical probe |
| `python-control` | Simulate numeric models and score fixed policies |
| Hypothesis | Generate and shrink adversarial worlds and legal actions |
| Polyfactory | Produce structurally valid nominal examples |
| mutmut | Measure whether owned tests detect implementation defects |
| Rust/Steel | Accelerate stable projections and reusable workflows |

## Closed-loop model

The target state and diagnostic belief are different objects:

```text
target:       z[k+1] = f(z[k], u[k], w[k])
measurement:  y[k+1] = h(z[k+1], u[k], v[k])
belief:       b[k+1] = update(b[k], u[k], y[k+1])
policy:       u[k+1] = select(b[k+1], legal_actions)
```

Where:

- `z` is the program, interpreter, environment, and latent fault state;
- `u` is one selected transform, probe, fixture, or experiment;
- `y` is admitted evidence;
- `b` is the estimator's belief over hypotheses;
- `w` represents environment drift and target nondeterminism;
- `v` represents incomplete, delayed, or noisy observations.

The fault state will often remain static. Effectful probes may change target
state, which is why perturbation must be recorded separately from uncertainty.

### Semantic mapping

| Control-system concept | Diagnostic architecture |
| --- | --- |
| Plant | Program, interpreter, and environment under diagnosis |
| Target state | Latent fault and mutable target condition |
| Control input | One legal discrete probe |
| Measurement | Analyzer diagnostic, CPython observation, event, or exception |
| Disturbance | Nondeterminism, side effects, and environment drift |
| Sensor | AST, `symtable`, `dis`, `importlib`, or PEP 669 provider |
| Estimator | Belief updater |
| Controller | Next-probe policy |
| Reference | Desired operational contract |
| Cost | Latency, risk, perturbation, and resource consumption |
| Closed-loop response | Belief and cost trajectory over an episode |

### Numerical projection

A useful state retains the complete fixed hypothesis posterior, not merely its
entropy. Equal entropy can represent different beliefs that require different
next probes.

```python
state = [
    probability_module_absent,
    probability_environment_divergence,
    probability_parent_not_package,
    probability_analyzer_divergence,
    cumulative_probe_cost,
    cumulative_target_perturbation,
    remaining_probe_budget,
]
```

A discrete-time `NonlinearIOSystem` can simulate a fixed encoded action sequence:

```python
import control as ct


def target_update(t, target_state, encoded_probe, params):
    return params["target_transition"](
        target_state,
        encoded_probe,
    )


def target_output(t, target_state, encoded_probe, params):
    return params["observation_model"](
        target_state,
        encoded_probe,
    )


diagnostic_target = ct.nlsys(
    target_update,
    target_output,
    states=["target_fault", "target_perturbation"],
    inputs=["probe_encoding"],
    outputs=["normalized_measurement"],
    dt=True,
    name="diagnostic_target",
)
```

Predicted information gain and probe cost belong to the estimator/policy model,
not to the plant's measured output.

### Discrete action selection

Diagnostic probes are categorical. `control.optimal` uses continuous SciPy
optimization, so an unconstrained one-hot encoding can produce an invalid blend
of probes. The initial policy layer should therefore:

1. derive legal actions from the semantic graph;
2. enumerate candidate probes or short candidate sequences;
3. simulate or score each candidate;
4. select exactly one discrete action;
5. execute it through the coordinator;
6. update the belief and replan.

A POMDP, mixed-integer solver, or learned discrete policy may later own action
selection. `python-control` remains useful for simulating and comparing fixed
candidate trajectories.

The finite-horizon cost is additive:

```text
J = sum[k=0..N-1](
      w_h * H(b[k])
    + w_c * C(u[k])
    + w_p * P(u[k])
    )
    + w_f * H(b[N])
```

`H` is residual hypothesis uncertainty, `C` is execution cost, and `P` is
perturbation risk. Cases-generator properties such as `can_error`, `escapes`,
or `may_deopt` may contribute provenance-backed risk features, but they are not
calibrated risk probabilities by themselves.

### Simulation and local analysis

Recorded episodes can qualify numerical models and compare policies:

```text
recorded probe sequence
    + initial target/belief state
        ↓
numeric simulation
        ↓
predicted trajectory
        versus
observed trajectory
```

For `input_output_response()`, inputs must contain a sample for every time point.
An explicit discrete-step helper is often clearer for event-indexed episodes:

```python
def replay_discrete(model, initial_state, encoded_probes, params):
    state = initial_state
    states = [state]
    outputs = []

    for step, probe in enumerate(encoded_probes):
        outputs.append(model.output(step, state, probe, params))
        state = model.dynamics(step, state, probe, params)
        states.append(state)

    return states, outputs
```

Controllability and observability matrix tests apply only to a linear model or a
local linearization. They do not establish global reachability, distinguishability,
or convergence for a branching diagnostic workflow.

## Contract spine

Choose one authoritative schema direction. A practical flow is:

```text
canonical CUE or JSON Schema
        ↓ pinned datamodel-code-generator
generated Pydantic admission models
        ↓ explicit serialization schema
React Flow / pytest / Rust consumers
```

The conversion is not bidirectionally lossless. Pydantic validation and
serialization schemas can differ, custom validators may not project completely,
and CUE-to-JSON-Schema conversion may narrow or lose semantics. Generated files
are reproducible build outputs and should be checked by regeneration diffs,
imports, round trips, and cross-validator conformance cases.

### JSON-safe domain models

Cross-process graph artifacts must contain JSON values rather than arbitrary
Python objects.

```python
from typing import Annotated, Literal

from pydantic import BaseModel, Field, JsonValue, model_validator


class SourceArtifact(BaseModel):
    artifact_id: str
    filename: str
    content_base64: str
    digest_algorithm: Literal["sha256"] = "sha256"
    digest: str

    @model_validator(mode="after")
    def validate_digest(self):
        import base64
        import hashlib

        source_bytes = base64.b64decode(self.content_base64, validate=True)
        actual = hashlib.sha256(source_bytes).hexdigest()
        if self.digest != actual:
            raise ValueError("digest does not match source content")
        return self


class DiagnosticSeed(BaseModel):
    provider: Literal["ty", "ruff", "cpython", "pytest"]
    rule: str
    source_artifact_id: str
    message: str


class TransformRequest(BaseModel):
    transform_id: str
    subject_id: str
    parameters: dict[str, JsonValue] = Field(default_factory=dict)
    isolation: Literal[
        "same-process",
        "worker-process",
        "fresh-interpreter",
    ]


class Observation(BaseModel):
    provider: str
    operation: str
    outcome: Literal["success", "failure", "indeterminate"]
    values: dict[str, JsonValue] = Field(default_factory=dict)


class ExpectedVerdict(BaseModel):
    category: str
    confidence_minimum: Annotated[float, Field(ge=0, le=1)]


class DiagnosticCase(BaseModel):
    case_id: str
    source: SourceArtifact
    initial_diagnostic: DiagnosticSeed
    allowed_transforms: list[str]
    expected: ExpectedVerdict
    max_probes: int = Field(gt=0)
    max_cost: float = Field(ge=0)
    max_effectful_probes: int = Field(ge=0)
```

Frequently used observations should become discriminated domain models instead
of accumulating weakly typed keys in `values`.

### Generation layers

#### Structural generation

```text
authoritative schema
    ↓ datamodel-code-generator
generated Pydantic classes
```

Pin the generator version. CI should regenerate into a temporary directory,
compare the result with the checked-in artifact, import it, and execute validation
and serialization round trips.

#### Nominal data generation

Polyfactory supplies structurally valid examples:

```python
from polyfactory.factories.pydantic_factory import ModelFactory


class DiagnosticCaseFactory(ModelFactory[DiagnosticCase]):
    __model__ = DiagnosticCase
```

Seed the factory explicitly when deterministic fixtures are required. Factory
output establishes structural validity; it does not establish semantic validity.

#### Adversarial behavioral generation

Hypothesis should generate source forms, package layouts, environment differences,
event sequences, and legal controller actions. It then shrinks failures to a
minimal source, topology, or action trace.

```python
from hypothesis import given, strategies as st


module_names = st.from_regex(
    r"[a-z_][a-z0-9_]*(\.[a-z_][a-z0-9_]*){0,3}",
    fullmatch=True,
)


@given(module_name=module_names)
def test_find_spec_transform_is_total(module_name, transform_runner):
    request = TransformRequest(
        transform_id="python.import.find-spec",
        subject_id=module_name,
        parameters={"module": module_name},
        isolation="fresh-interpreter",
    )

    result = transform_runner.execute(request)
    Observation.model_validate(result)
```

## Stateful workflow generation

A state machine should select only legal transforms and make budget exhaustion
an explicit outcome rather than an accidental invariant failure.

```python
from hypothesis import strategies as st
from hypothesis.stateful import (
    RuleBasedStateMachine,
    invariant,
    precondition,
    rule,
)


MAX_PROBES = 10


class DiagnosticMachine(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self.observations: list[Observation] = []
        self.terminated = False
        self.probe_count = 0

    @precondition(
        lambda self: not self.terminated and self.probe_count < MAX_PROBES
    )
    @rule(data=st.data())
    def execute_legal_transform(self, data):
        legal = legal_transforms(self.observations)
        if not legal:
            self.terminated = True
            return

        transform = data.draw(st.sampled_from(legal), label="transform")
        observation = execute_model_transform(
            transform,
            observations=self.observations,
        )
        self.observations.append(Observation.model_validate(observation))
        self.probe_count += 1
        self.terminated = derive_termination(self.observations)

    @invariant()
    def episode_remains_valid(self):
        assert self.probe_count <= MAX_PROBES
        assert legal_observation_sequence(self.observations)

    def teardown(self):
        assert self.terminated or self.probe_count == MAX_PROBES
```

Stable external dependencies should be injected through a machine factory or
constructor. Stateful rules should not depend directly on arbitrary pytest
fixtures or parametrized arguments.

## Pytest as the executable qualification layer

One collected pytest item represents one complete adaptive episode:

```text
pytest item
    DiagnosticCase × Policy × Interpreter × Environment

episode
    probe[0] → evidence[0] → belief[1]
    probe[1] → evidence[1] → belief[2]
    ...
    verdict
```

The next probe depends on prior evidence, so probes should not be generated as
new pytest items during test execution. Collection-time parametrization creates
the episode matrix; the test body owns the sequential feedback loop.

```python
def test_diagnostic_policy(
    diagnostic_case,
    policy,
    transform_runner,
):
    state = policy.initial_state(diagnostic_case)
    trajectory = []

    while not policy.terminated(state):
        legal = legal_transforms_for_case(diagnostic_case, state)
        request = policy.select_probe(state, legal_actions=legal)
        assert request.transform_id in legal

        result = transform_runner.execute(request)
        state = policy.update(state, result)
        trajectory.append((request, result, state))

    assert state.root_cause == diagnostic_case.expected.category
    assert state.total_cost <= diagnostic_case.max_cost
    assert state.false_eliminations == 0
```

### Collection-time episode matrix

Case, controller, interpreter, and environment variants must be known during
collection. Use ordinary parametrization or `pytest_generate_tests`:

```python
def pytest_generate_tests(metafunc):
    if "diagnostic_episode" not in metafunc.fixturenames:
        return

    episodes = load_episode_specs(metafunc.config)
    metafunc.parametrize(
        "diagnostic_episode",
        episodes,
        ids=lambda episode: episode.episode_id,
    )
```

`request.getfixturevalue()` may resolve an existing runtime fixture, but it
cannot create new parametrized fixture variants after collection. Environment
and interpreter identities therefore belong in the collected episode spec.

Evaluate each `(case, controller, environment)` as a separate item. Aggregate
accuracy, median probe count, timeout rate, and mutation score in a report after
the per-case results have been preserved.

### Probe materialization

The durable artifact is a typed `ProbeSpec`; pytest is its execution backend.

```python
class AssertionSpec(BaseModel):
    path: str
    operator: Literal[
        "equals",
        "contains",
        "exists",
        "matches",
        "less-than",
    ]
    expected: JsonValue | None = None


class ProbeSpec(BaseModel):
    probe_id: str
    fixture_dependencies: list[str]
    request: TransformRequest
    assertions: list[AssertionSpec]
```

```python
def execute_probe(probe, request, transform_runner):
    dependencies = {
        name: request.getfixturevalue(name)
        for name in probe.fixture_dependencies
    }
    observation = transform_runner.execute(
        probe.request,
        dependencies=dependencies,
    )

    for assertion in probe.assertions:
        evaluate_assertion(observation, assertion)

    return observation
```

Keep generated Python thin:

```python
import pytest


@pytest.mark.parametrize("probe", load_probe_specs())
def test_generated_probe(probe, request, transform_runner):
    execute_probe(probe, request, transform_runner)
```

### PEP 669 monitoring isolation

Monitoring callbacks must be installed in the interpreter that executes the
target. A fixture in the parent pytest process cannot monitor a fresh child
interpreter.

```text
pytest parent
    ↓ construct request and event configuration
child interpreter
    ↓ reserve monitoring tool ID
    ↓ register callbacks and enable requested events
    ↓ execute target
    ↓ normalize and serialize events
pytest parent
    ↓ admit child result and event stream
    ↓ release environment
```

The callback should enqueue minimal event seeds. Disassembly, optimization,
subprocess execution, and belief updates remain outside the callback.

### Plugin lifecycle

| Pytest extension point | Diagnostic purpose |
| --- | --- |
| `pytest_addoption` | Select corpus, policy, interpreter, and budgets |
| `pytest_generate_tests` | Generate the episode matrix |
| `pytest_collection_modifyitems` | Filter, mark, or order episodes |
| fixtures | Construct environments, runners, and sensors |
| test body or custom `Item.runtest()` | Execute an episode |
| `pytest_runtest_makereport` wrapper | Attach evidence to phase reports |
| `pytest_sessionfinish` | Emit aggregate qualification output |

Use a custom `Item.runtest()` or `pytest_pyfunc_call` when a plugin must replace
normal Python test execution. A plain `pytest_runtest_call` implementation should
not accidentally execute an episode in addition to the normal item.

Custom diagnostic hooks should be declared with hookspec markers and invoked
through pytest's plugin manager. Reporting and React Flow streaming can then
implement them independently.

## Mutation testing and corpus growth

mutmut should target owned transforms, decoders, estimators, policies, and
evaluators. It should not mutate generated models, caches, environments, or
corpus data.

Useful mutation classes include:

- invert a resolution result;
- discard an import alias;
- confuse Unicode character and UTF-8 byte columns;
- terminate an episode one observation too early;
- treat `indeterminate` as `success`;
- reverse probe ranking;
- ignore isolation or source-revision identity.

A surviving mutant is evidence requiring triage, not automatically proof of a
missing test:

```text
surviving mutant
    ↓ triage
    ├─ equivalent
    ├─ unreachable or out of contract
    ├─ duplicate
    ├─ invalid mutation
    └─ qualification gap
            ↓
       CorpusExtensionCandidate
            ↓ review and promotion
       property / fixture / assertion / corpus case
```

This avoids encoding equivalent mutants or tool artifacts as false domain
requirements.

### Promotion rule

A workflow is eligible for promotion when:

```text
curated cases pass
+ generated properties pass
+ legal stateful episodes satisfy invariants
+ deterministic replay passes
+ required mutation score is met
+ every critical survivor is triaged
```

## Thin vertical slice: unresolved imports

Start with:

### Contracts

- `ImportDiagnosticCase`
- `PackageLayout`
- `InterpreterEnvironment`
- `ImportOccurrence`
- `TransformRequest`
- `ImportObservation`
- `ImportVerdict`

### Generated worlds

Polyfactory supplies nominal cases and explicit seeded examples. Hypothesis
varies:

- absolute and relative imports;
- modules versus packages;
- regular and namespace packages;
- aliases and missing members;
- project and system interpreter paths;
- stub/runtime divergence;
- legal probe sequences.

### Episode qualification

pytest verifies:

- import lifecycle transition ordering;
- correct root-cause verdict;
- bounded probe count and effectful-probe budget;
- fresh-interpreter isolation;
- source digest consistency;
- deterministic evidence replay.

mutmut targets the transition classifier, environment comparator, observation
decoder, policy termination predicate, and assertion evaluator.

## Architectural placement

```text
authoritative schemas
        ↓
generated admission contracts
        ↓
nominal and adversarial diagnostic worlds
        ↓
pytest episode matrix
        ↓
CPython transforms + child-owned PEP 669 sensors
        ↓
semantic evidence graph
        ↓ feature projection
belief estimator + candidate policy simulation
        ↓ one legal TransformRequest
execution coordinator
        ↓
React Flow evidence path
        ↓
pytest verdict and aggregate qualification
        ↓
mutation triage and reviewed corpus growth
```

The core principle is:

> React Flow discovers and displays workflows; schemas define admissible
> artifacts; pytest executes and qualifies episodes; CPython and PEP 669 produce
> evidence; a belief model selects legal probes; `python-control` evaluates
> numerical projections; and mutation testing identifies candidate qualification
> gaps.
