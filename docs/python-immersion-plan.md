# Python Immersion architecture and staged pruning plan

## Summary

Replace the Exercism-centered topology with two independent learning axes:
horizontal PPF semantic practice and vertical Python/Xonsh capability adoption.
Promote task deconstruction and PPF into the semantic core, preserve three
neutral executable specimens, and delete the dependency-free Exercism corpus.

The repository becomes **Python Immersion**: a small incubator in which semantic
practice, an inspectable computational environment, and real projects reinforce
one another without recreating a fixed exercise track.

## Canonical learning contract

```text
                 SEMANTIC AXIS
                     PPF

 DATA · RULE · OPERATION · POLICY
 BOUNDARY · COMPOSITION · STATE
                       │
                       │ continuously applied
                       ▼

T0 CROSS → T1 OBSERVE → T2 COMPOSE → T2+ FUNCTIONALIZE
                                      ↓
                                  T3 EXTEND
                                      ↓
                                  T4 PROJECT
                                      ↓
                                  T5 ENGINEER
                       XONSH / PYTHON
```

The operating loop is:

```text
task
  ↓
semantic decomposition              PPF
  ↓
choose representation
  ↓
realize / manipulate                Python + Xonsh
  ↓
inspect                             Rich / pydoc / CPython
  ↓
execute
  ↓
observe                             runtime / pytest
  ↓
revise semantic model
  └───────────────────────────────↺
```

The layers have distinct responsibilities:

```text
SEMANTIC PRACTICE
    PPF
    What is this computational thing?

OBSERVATION / MANIPULATION ENVIRONMENT
    Python + Xonsh + Rich + pydoc + CPython
    How does it actually behave?

REAL COMPUTATION
    Projects and domain libraries
    What useful thing can be constructed from it?
```

One escalation rule applies throughout:

```text
manual understanding
       ↓
repeated use
       ↓
observed friction
       ↓
small abstraction
       ↓
evaluation
       ↓
retain only if it improves the loop
```

## Capability progression

### T0 — Cross

Establish Xonsh's basic computational model:

- subprocess and Python modes;
- `@(...)` interpolation and capture operators;
- path objects and glob results;
- typed environment values;
- structured process results;
- explicit process, serialization, and filesystem boundaries.

These are foundational crossings, not advanced shell features.

### T1 — Observe

Make observation a deliberate progression:

```text
subject
  ↓
type / repr
  ↓
dir / ?
  ↓
Rich inspect
  ↓
help / pydoc
  ↓
signature / source
  ↓
behavioral probe
```

The standard library is an exploration substrate here. Modules such as
`pathlib`, `inspect`, `ast`, `dis`, `tokenize`, `importlib`, `sqlite3`, and
`subprocess` can be inspected before they become implementation components.

### T2 — Compose

Compose values and processes with native Python and Xonsh facilities:

- Python expressions and ordinary pipelines;
- paths, environment values, and captured results;
- aliases and structured-output conversion;
- explicit composition without hiding representation or effect boundaries.

### T2+ — Functionalize

Introduce Coconut only after repeated transformation pressure shows that
composition, piping, partial application, or higher-order structure is clearer
than native syntax.

```text
Coconut
    changes how values are composed

Xonsh extension mechanisms
    change how the shell behaves
```

Coconut remains an expressive escalation rather than shell engineering.

### T3 — Extend

Extend shell behavior only after the underlying manual operation is stable:

- callable aliases;
- macros;
- events and hooks;
- completers;
- prompt-toolkit interaction;
- narrowly justified xontrib or run-control machinery.

Using an ordinary alias earlier in the progression does not imply that custom
callable-alias infrastructure belongs before T3.

### T4 — Project

Transition from the learning substrate to actual computational problems.
Potential project technologies include DuckDB, Ibis, BigQuery, Marimo, Rich,
Arrow, and OpenTelemetry, but none is a curriculum requirement.

The standard library has a second role at T4: its modules become implementation
components in concrete tools rather than merely subjects of inspection.

Do not create a document or empty scaffold for every prospective technology.
A project earns a repository surface when a real problem introduces it.

### T5 — Engineer

Create reusable frameworks or deeper infrastructure only when accumulated use
has demonstrated stable semantics, repeated friction, and a measurable benefit
from abstraction.

## PPF semantic practice

The mandatory working vocabulary is:

```text
DATA
    What representation carries the subject?

RULE
    What constraints or predicates govern it?

OPERATION
    What transformation is actually occurring?

POLICY
    What choice can vary independently of mechanism?

BOUNDARY
    Where does representation, runtime, or authority change?

COMPOSITION
    How do operations combine?

STATE
    What information persists or evolves?
```

Factory, higher-order function, adapter, orchestrator, strategy, pipeline, and
similar names are derived projections of these primitives. They are not the
primary vocabulary.

The normalized learning model must preserve this status:

```text
Source:
    normalized from fatb4f/ppf docs/theory/drafts/01.md and 02.md

Role in fatb4f/python:
    active learning semantic model

Epistemic status:
    adopted learning vocabulary,
    not automatically architectural authority for other projects
```

Record source revision
`53af6aa42aec6fc104bbf2abe7410d125c7540cb` when performing the rewrite.

## Task deconstruction

Promote the task model from the Xonsh T0 document into the semantic core:

```text
TASK := OP(WHAT | CONTEXT) -> RESULT
```

```text
WHAT
    the subject being observed or acted on

CONTEXT
    scope and constraints already known

OP
    the semantic operation required

RESULT
    the postcondition that defines success
```

The derivation order is:

```text
WHAT + CONTEXT + RESULT
          ↓
constraints
          ↓
required properties / invariants
          ↓
required operations
          ↓
representation
          ↓
algorithm
          ↓
realization
          ↓
validation
```

The semantic core owns:

- the exploratory → targeted → surgical precision ladder;
- semantic, representation, operational, resource, boundary, and failure
  constraints;
- constraint-driven reduction from candidate representations `R₀` through
  successively smaller sets to an admissible set `R*`;
- property and invariant derivation;
- complexity only where it changes a design choice;
- validation against the original result contract.

Xonsh T0 applies this model interactively; it does not own it.

## Target documentation topology

```text
docs/
├── learning.md
├── semantics/
│   ├── README.md
│   ├── ppf.md
│   ├── task-deconstruction.md
│   └── patterns.md
├── xonsh/
│   ├── README.md
│   ├── t0-cross.md
│   ├── t1-observe.md
│   ├── t2-compose.md
│   ├── t2-functionalize.md
│   ├── t3-extend.md
│   └── progression.md
└── python/
    └── stdlib-exploration.md
```

Responsibilities:

- `learning.md` owns the top-level contract and feedback loop.
- `semantics/README.md` introduces the horizontal semantic axis and its status.
- `semantics/ppf.md` contains the normalized active learning model.
- `semantics/task-deconstruction.md` owns constraint-driven task reduction.
- `semantics/patterns.md` derives reusable patterns from primitive conditions
  and decision pressure. It owns source/filter/transform/sink as one
  composition pattern and must not become a conventional pattern glossary.
- `xonsh/t0-cross.md` through `xonsh/t3-extend.md` own the vertical capability
  progression.
- `xonsh/progression.md` defines T4 project adoption and T5 engineering gates.
- `python/stdlib-exploration.md` distinguishes the stdlib's T1 observation role
  from its T4 implementation role.

## Staged pruning

### Phase A — Remove the legacy control plane

Make Exercism cease to be repository authority immediately:

- rewrite README and project metadata around Python Immersion;
- remove curriculum ordering and progress tracking;
- remove `tools/path.py`;
- remove `tests/exercism/`;
- replace Exercism-specific `just` recipes;
- remove the Exercism pytest marker;
- replace CI that validates curriculum topology;
- remove `.learning-progress.json` from `.gitignore`;
- remove Exercism-specific semantic slices;
- remove duplicate feedback and control architectures.

Replace the public command surface with:

```text
just sync
just test [pytest arguments]
```

There is no compatibility shim for `verify`, `next`, `list`, `show`, `mark`,
`status`, `test-file`, or `test-node`.

### Phase B — Extract useful specimens

Retain only three neutral examples, rewritten rather than copied with their
original exercise scaffolding:

```text
specimens/semantics/coverage.py
specimens/semantics/token_frequency.py
specimens/semantics/run_length.py

tests/specimens/test_coverage.py
tests/specimens/test_token_frequency.py
tests/specimens/test_run_length.py
```

The specimen contracts are:

- **Coverage:** required-set coverage where ordering and multiplicity are
  explicitly irrelevant.
- **Token frequency:** Unicode alphanumeric tokens, `casefold()` normalization,
  one internal apostrophe, punctuation and underscore boundaries, and
  `Counter` output.
- **Run length:** a digit-free source grammar, a distinct encoded grammar in
  which digits are count syntax, omitted singleton counts, multi-digit counts,
  explicit malformed-input rejection, and the invariant
  `decode(encode(value)) == value` for every admissible source string.

Rewrite their tests as native pytest. Do not preserve the original
`unittest.TestCase` suites, exercise metadata, learner stubs, or hidden-answer
structure. Give every specimen a short semantic header describing its
contract, constraints, representation choice, and dominant PPF primitives;
the specimens are not canonical Python implementations.

Do not retain Strain or Grade School. Strain contributes little beyond
comprehension syntax, while Grade School carries disproportionate state and API
baggage. Do not extract CPython probes because the repository currently
contains plans, not implemented probes.

### Phase C — Delete the unreferenced corpus

Before deletion, verify that active README, documentation, configuration, CI,
specimens, and tests have no meaningful dependency on `stages/`, `curriculum/`,
or Exercism-specific interfaces.

Then delete:

- the remaining frozen stage tree and curriculum metadata;
- inherited Exercism guides and images;
- obsolete semantic-companion documents after their retained material moves;
- `docs/terminal-native-development.md`;
- CPython diagnostic/intelligence plans, including all untracked handoff drafts;
- `docs/feedback-system.md` and `docs/llm/extra.md`;
- the empty CPython specimen placeholder;
- `.helix/languages.toml`, because the user chose to remove the obsolete
  repository-wide LSP and formatting override;
- `NOTICE.md`, after confirming that it contains only the obsolete fork
  narrative and no independent license terms required by retained material.

Keep the inherited MIT `LICENSE` unchanged. Git history remains the archive.

Deliver the phases as three small, reversible commits: control-plane removal,
specimen extraction, and corpus deletion.

## Dependencies and validation surface

Rename the project metadata to `python-immersion`. Keep Python 3.14,
`rich>=15.0.0` as the runtime dependency, and `pytest>=8.4,<9` as the sole
development dependency.

Remove pytest-subtests and the Exercism task marker. Minimize the current root
environment by removing Ruff and ty because no active validation contract uses
them; this is not an architectural rejection. Reintroduce either tool when
executable project code establishes a concrete repository-wide role.
Regenerate `uv.lock`. Xonsh and Coconut remain external runtimes rather than
root project dependencies.

Keep T0–T3 Xonsh documentation descriptive and manual initially. When repeated
executable examples emerge, extract minimal smoke specimens before considering
Xonsh as a test dependency.

The replacement CI workflow validates:

1. `uv lock --check`;
2. `uv sync --locked`;
3. CPython 3.14;
4. Rich import;
5. specimen compilation;
6. `just test`.

## Test plan

### Coverage specimen

- complete and incomplete coverage;
- reordered and duplicate observations;
- empty required and observed sets.

### Token-frequency specimen

- empty text;
- case folding;
- surrounding punctuation;
- internal apostrophes;
- digits and underscores;
- repeated tokens.

### Run-length specimen

- empty input;
- singleton and repeated symbols;
- whitespace and multi-digit counts;
- encode/decode round trips;
- digit-bearing source rejection;
- malformed encoded-frame rejection.

### Repository acceptance

- all local Markdown links resolve;
- active files contain no removed curriculum CLI or stage-path references;
- `uv lock --check`, `uv sync --locked`, `just test`, specimen compilation,
  Rich import, and `git diff --check` pass;
- `experiments/` and `projects/` remain absent until a real artifact earns
  either surface.
