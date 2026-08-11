# Exercism–pytest–CPython companion layer

This plan keeps the frozen Exercism curriculum intact while adding a small,
trackable workspace for learner-authored tests and selected CPython katas.

The follow-on [semantics laboratory plan](semantics-laboratory-plan.md) layers
typeshed contract audits, property probes derived from `library-fuzzers`, and a
test-process adapter over this same workspace after the relevant Exercism
stages.

The mandatory progression is deliberately short:

```text
pure function
    ↓
behavioral contract
    ↓
CLI/library boundary
    ↓
filesystem adapter
    ↓
subprocess observation
```

`test.support`, `libregrtest`, workers, and orchestration remain optional
reference material rather than curriculum milestones.

## Daily exercise loop

The existing Exercism command surface remains the source of truth:

```text
just next
solve the exercise
just test <slug>
just init-test <slug>       # only when an additive test is useful
write learner-authored pytest cases
just test <slug>
just mark <slug>
```

The supplied `unittest.TestCase` tests continue to run through pytest. Learner
tests should add information rather than duplicate examples: boundaries,
invalid inputs, equivalence classes, failure modes, invariants, metamorphic
relations, or regressions.

Use the following pytest gradient:

```text
assert → parametrize → raises → tmp_path → capsys → monkeypatch → subprocess
```

The initial allocation is approximately 70% Exercism implementation, 20%
learner-authored pytest, and 10% CPython reading or reconstruction.

## Frozen-corpus boundary

The files under `stages/`, `curriculum/sequence.json`, and
`curriculum/source-manifest.json` remain unchanged. Learner tests live in an
overlay so `python tools/path.py verify` continues to validate the frozen
source snapshot.

```text
workbook/
├── README.md
├── specimens.json
├── labs/
│   ├── json-cli/
│   ├── py-compile-cli/
│   ├── zipapp-cli/
│   ├── update-file/
│   └── process-observation/
└── tests/
    └── <kind>/<slug>/learner_test.py
```

The learner-test command creates the overlay file on demand and never
overwrites an existing file. The normal exercise test command runs both the
canonical tests and that exercise's overlay test, using the exercise directory
as its working directory so the solution module imports normally.

## CPython specimen access

CPython is not vendored. A specimen command reads catalogued files directly
from a configured zip archive without extracting it:

```text
explicit --archive path
    ↓
PYTHON_CURRICULUM_CPYTHON_ARCHIVE
    ↓
/tmp/cpython-3.14.zip when present
```

If no archive is available, the command reports the required configuration.
Only catalogued `Lib/` and `Tools/` paths are addressable.

Five-minute seam readings:

```text
Lib/zipfile/__main__.py
Lib/unittest/__main__.py
```

These demonstrate package entrypoints. For larger modules, read only the
`main()` seam and its calls rather than attempting to understand the whole
implementation:

```text
Lib/ast.py
Lib/tokenize.py
Lib/dis.py
Lib/timeit.py
```

## Guided lab ladder

Each lab contains a short contract, editable `lab.py`, baseline pytest tests,
and a prompt to add at least one useful test. Labs are run independently and do
not affect `next`, `mark`, or the core-item count.

### `json-cli` — after Stage 04

Reconstruct a small `main(argv)` around JSON parsing and formatting. Cover
stdin, a UTF-8 input file, formatting options, invalid JSON, stderr, and a
non-zero return value. Compare the boundary with `Lib/json/tool.py`.

### `py-compile-cli` — after Stage 05

Translate `py_compile` success and failure into a CLI contract. Cover valid
source, syntax failure, multiple paths, diagnostics, and quiet mode. Compare
with `Lib/py_compile.py::main`.

### `zipapp-cli` — after Stage 06

Parse a small set of archive options and delegate to
`zipapp.create_archive()`. Test archive creation and invalid requests without
reimplementing zipapp semantics. Compare with `Lib/zipapp.py::main`.

### `update-file` — after Stage 07

Implement candidate promotion with the classified outcomes `created`,
`updated`, and `same`. Test unchanged content, changed content, missing targets,
the `create` policy, replacement, and temporary-file handling. Compare with
`Tools/build/update_file.py`.

### `process-observation` — after Stage 09

Build the smallest shell-free subprocess adapter:

```python
@dataclass(frozen=True)
class ProcessObservation:
    returncode: int
    stdout: str
    stderr: str
```

Test a successful command, a failing command, and captured stderr using
`sys.executable -c ...`. Defer timeout policy, environment rewriting, worker
protocols, and isolation frameworks.

## Supporting commands

The companion tooling should add only these operations:

```text
python tools/path.py init-test <exercise>
python tools/path.py specimens
python tools/path.py specimen <id> [--archive PATH]
python tools/path.py labs
python tools/path.py lab <id> [pytest arguments]
```

Matching `just` recipes provide the short daily interface. Lab completion is
kept as a companion checklist rather than folded into the canonical curriculum
progress file.

## Acceptance checks

The implementation is complete when:

```text
python -m pytest tests/test_path.py
python tools/path.py verify
python tools/path.py init-test pangram
python tools/path.py test pangram --collect-only
python tools/path.py specimen json-tool --archive <cpython-3.14.zip>
python tools/path.py labs
python tools/path.py lab process-observation --collect-only
```

`verify` must continue to report the original 67 concepts, 20 concept
exercises, 140 practice exercises, and 128 core items. Existing documentation
or unrelated worktree changes are outside this companion layer.
