# Progressive Python curriculum

A thin Python learning environment built from a frozen snapshot of the Exercism
Python track. Python behavior stays in the foreground, uv owns the environment,
and each observer remains visible before repository automation is introduced.

## Repository contract

- `stages/` is the canonical, frozen Exercism curriculum.
- `curriculum/sequence.json` defines its prerequisite-aware order.
- `tools/path.py` selects work, validates the snapshot, and runs exercise tests.
- `tests/exercism/<slug>/` holds additive learner-authored pytest tests.
- `specimens/cpython/` holds occasional CPython seam reconstructions.

## Start

Install `uv`, then prepare and inspect the curriculum through the native
project commands:

```sh
uv sync --locked
uv run --frozen --no-sync python tools/path.py verify
uv run --frozen --no-sync python tools/path.py next
```

The repository targets conventional CPython 3.14.x. uv creates one root
`.venv`; `uv.lock` resolves pytest, pytest-subtests, Ruff, and ty for the entire
curriculum.

## Learning loop

1. Select an exercise with `tools/path.py`, then enter its directory.
2. Execute the solution and run pytest, Ruff, and ty as separate observers.
3. Escalate a focused behavioral failure through pytest into pdb when needed.
4. Add a learner-authored pytest test only when it contributes a boundary,
   invalid input, uncovered equivalence class, regression, or metamorphic
   relationship.
5. Occasionally read or reconstruct one small CPython library/CLI seam.
6. Explain the observed behavior, mark the item complete, and repeat.

For the first exercises, keep the process boundaries explicit:

```sh
cd stages/00-orientation/exercises/practice/hello-world

uv run --frozen --no-sync python hello_world.py
uv run --frozen --no-sync pytest hello_world_test.py
uv run --frozen --no-sync ruff check hello_world.py
uv run --frozen --no-sync ty check hello_world.py

uv run --frozen --no-sync pytest \
  'hello_world_test.py::HelloWorldTest::test_say_hi' -x --pdb
```

Python provides direct execution and runtime probes, pytest observes behavior,
Ruff reports lint and static-rule diagnostics, and ty reports type diagnostics.
`pytest --pdb` is a causal escalation from a failure into its live frame; Ruff
and ty remain independent observers rather than pytest subprocesses.

The initial allocation is approximately 70% Exercism, 20% learner-authored
testing/evaluation, and 10% CPython reading or reconstruction. Progress in this
order before introducing later orchestration:

```text
function -> behavioral contract -> CLI adapter -> side effect -> process observation
```

After completing selected exercises, use the [Python semantic companion](docs/semantic-companion/README.md)
for a second pass through semantic decomposition, observation, and pattern recognition.

## Repository projections

After the manual commands, working-directory behavior, targets, output, and
exit statuses are understood, install `just` and use the repository's shorter
exercise-selection projections:

The useful full-suite boundary is one exercise, because the repository contains
160 intentionally unfinished exercises. Do not use a bare repository-wide
`pytest` run as the normal feedback loop.

```sh
just test hello-world
just test-file stages/00-orientation/exercises/practice/hello-world/hello_world_test.py
just test-node 'stages/00-orientation/exercises/practice/hello-world/hello_world_test.py::HelloWorldTest::test_say_hi'
```

`just test <slug>` runs both the supplied `*_test.py` suite and any files under
`tests/exercism/<slug>/`. The runner uses the matching exercise directory as its
working directory, so learner tests import the solution module exactly as the
supplied suite does.

The supplied Exercism suites use `unittest.TestCase`; pytest collects and runs
them unchanged. After roughly 10–15 exercises, make that interoperability an
explicit checkpoint: inspect one supplied class, select one node with
`just test-node`, and explain which responsibilities belong to unittest and
which belong to pytest.

Keep the initial pytest surface to `assert`, `parametrize`, `raises`, `tmp_path`,
`capsys`, `monkeypatch`, and subprocess observation. Avoid fixture frameworks,
hooks, and plugins until a concrete exercise needs them.

Do not add `just ruff`, `just ty`, a combined `just check`, or pytest wrappers
for the static tools during this phase. Those are later projections of an
already-understood manual loop.

## Editors and terminal equivalents

Helix is the preferred thin structural editor for the terminal-native model;
it does not need to own the Python environment or command loop. The existing
managed Neovim configuration remains an optional adapter and uses uv.nvim for
interactive Python execution plus the same later `just` recipes for tests.

On the configured workstation, `Alt-p` in WezTerm opens the `python-learning`
workspace with Helix on the left and a login shell on the right. The
project-local Helix language configuration intentionally disables Python
language servers during the manual-observer phase; run Ruff and ty explicitly
in the terminal.

| Intent | Neovim | Terminal |
|---|---|---|
| Run file | `<leader>pr` | `uv run --frozen --no-sync python <file>` |
| Run selection | Visual `<leader>ps` | pipe code to `uv run --frozen --no-sync python -` |
| Run function | `<leader>pf` | `uv run --frozen --no-sync python -c '<import-and-call>'` |
| Run relevant tests | `<leader>tr` | current test file, otherwise `just test <slug>` |
| Run test file | `<leader>tf` | `just test-file <path>` |
| Run exercise suite | `<leader>ta` | `just test <slug>` |

Test mappings show the unmodified command output in a Neovim terminal. The
optional `:UvPytest <slug-or-path-or-node> [pytest-args]` command runs the same
just workflows and provides a quickfix presentation for comparison. Neither
path is workflow authority, and future diagnostics or test UIs must continue to
consume the same editor-independent uv/just commands.

No combined observer runner, Iron, separate REPL, Xonsh, controller, workers,
`libregrtest`, advanced Hypothesis, or mandatory diagnostic UI is part of this
initial environment.

See [`curriculum/README.md`](curriculum/README.md) for the complete sequence and
[`docs/terminal-native-development.md`](docs/terminal-native-development.md) for
the development-environment progression. See [`NOTICE.md`](NOTICE.md) for
provenance.
