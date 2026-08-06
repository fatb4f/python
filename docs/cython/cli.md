Exactly. That makes the standard library not just an API provider plane, but an **executable diagnostic toolbox**.

Python 3.14 explicitly catalogs modules with CLIs, including `ast`, `tokenize`, `symtable`, `dis`, `py_compile`, `compileall`, `tabnanny`, `pyclbr`, `inspect`, `runpy`, `trace`, `sysconfig`, `site`, `pdb`, `profile`, `pickletools`, and others. ([Python documentation][1])

## Revised realization model

```text
repository/source/environment
             │
             ▼
    python -m <stdlib-provider>
             │
      ┌──────┴──────┐
      ▼             ▼
 raw process      generated
 evidence         artifacts
 stdout           .pyc
 stderr           traces
 exit code        reports
 duration
             │
             ▼
 adapter-owned decoder
             │
             ▼
 normalized observation
             │
             ▼
 diagnostic differential
```

This makes **subprocess execution the natural initial adapter boundary**, rather than something added later.

## Language-provider pipeline

```bash
python -m tokenize source.py
python -m ast --include-attributes --show-empty source.py
python -m symtable source.py
python -m py_compile source.py
python -m dis --show-offsets --show-positions source.py
```

These correspond almost directly to compiler stages:

```text
tokenize
    ↓
AST
    ↓
symbol table
    ↓
compilation
    ↓
bytecode lowering
```

`ast`, `symtable`, and `dis` all accept stdin when no file is supplied, making them particularly suitable for analyzing immutable source revisions without creating temporary source files. `symtable` gained its CLI in Python 3.13; Python 3.14 added grammar-version and optimization controls to `ast`, and source-position and specialization controls to `dis`. ([Python documentation][2])

## CLI provider matrix

| Provider           | Typical command                         | Observation                              |
| ------------------ | --------------------------------------- | ---------------------------------------- |
| Tokenizer          | `python -m tokenize -e file.py`         | Exact lexical token stream               |
| AST                | `python -m ast -a --show-empty file.py` | Syntax tree and source attributes        |
| Symbol table       | `python -m symtable file.py`            | Scope and binding structure              |
| Indentation        | `python -m tabnanny file.py`            | Ambiguous indentation                    |
| Compilation        | `python -m py_compile file.py`          | File-level compiler qualification        |
| Corpus compilation | `python -m compileall src/`             | Repository compilation gate              |
| Bytecode           | `python -m dis -O -P file.py`           | Lowered instructions and positions       |
| Structural browser | `python -m pyclbr file.py`              | Approximate class/function inventory     |
| Runtime trace      | `python -m trace ...`                   | Calls, lines and execution counts        |
| Introspection      | `python -m inspect ...`                 | Source/object inspection                 |
| Module execution   | `python -m runpy ...`                   | Module execution context                 |
| Environment        | `python -m sysconfig`                   | Interpreter build and path configuration |
| Search path        | `python -m site`                        | Site directories and user-site state     |
| Runtime debugger   | `python -m pdb ...`                     | Interactive execution state              |
| Profiling          | `python -m cProfile ...`                | Runtime call and timing evidence         |

`tokenize` can emit exact token names with `-e`; `dis` in Python 3.14 can emit instruction offsets, source positions, inline caches, and specialized bytecode. ([Python documentation][2])

## Adapter contract

The generic adapter can be almost entirely provider-independent:

```python
class CommandProviderSpec(BaseModel):
    provider_id: str
    interpreter: Path
    module: str
    arguments: list[str]

    input_mode: Literal["stdin", "file", "arguments"]
    expected_effects: set[str]

    timeout_seconds: float
    environment_policy: str
    decoder_id: str
```

Execution produces a common envelope:

```python
class ProcessObservation(BaseModel):
    schema_version: Literal["diagnostics.process-observation.v0"]

    provider_id: str
    command: list[str]
    cwd: str
    environment_id: str

    stdin_digest: str | None
    stdout: str
    stderr: str
    exit_code: int

    duration_ns: int
    timed_out: bool
    produced_artifacts: list[ArtifactObservation]
```

A provider-specific decoder then projects:

```text
ProcessObservation
       ↓
ASTObservation
SymbolTableObservation
BytecodeObservation
CompilationObservation
TraceObservation
EnvironmentObservation
```

## Important boundary: CLI output is evidence, not necessarily the schema

The CLI is an excellent:

- isolation boundary;
- execution boundary;
- environment-selection mechanism;
- reproducibility mechanism;
- raw-evidence producer;
- pytest target.

But most standard-library CLIs emit **human-readable text**, not stable JSON. For example, `ast` writes an `ast.dump()` representation, `symtable` dumps tables, and `dis` prints formatted instructions. These formats can change across Python releases as their underlying grammar, symbol-table types, and bytecode change. The `dis` documentation explicitly treats CPython bytecode as an implementation detail that may change between releases. ([Python documentation][2])

Therefore preserve two channels:

```text
raw evidence
    exact stdout/stderr/artifacts
    retained for replay and auditing

normalized evidence
    adapter-owned typed projection
    used by evaluation and joins
```

## CLI-first, API-backed

The most robust thin realization is:

```text
controller
    ↓ subprocess
provider CLI
    ↓
raw output artifact
    +
provider API projection
    ↓
normalized observation
```

The API projection may be generated by a tiny companion command:

```bash
python -m diagnostics_adapters.ast --format json source.py
python -m diagnostics_adapters.symtable --format json source.py
python -m diagnostics_adapters.dis --format json source.py
```

Each companion uses only the corresponding standard-library API:

```text
diagnostics_adapters.ast
    wraps ast.parse()

diagnostics_adapters.symtable
    wraps symtable.symtable()

diagnostics_adapters.dis
    wraps dis.get_instructions()
```

The native CLI remains an independent reference oracle:

```text
native CLI result
       versus
typed adapter result
       ↓
adapter conformance evaluation
```

This is stronger than parsing the native CLI’s formatted output into the durable schema.

## Pytest materialization

A common fixture can qualify every provider:

```python
@pytest.mark.parametrize(
    "provider",
    [
        "cpython.tokenize",
        "cpython.ast",
        "cpython.symtable",
        "cpython.compile",
        "cpython.dis",
    ],
)
def test_provider_accepts_source(
    provider: str,
    source_case: SourceCase,
    runner: ProviderRunner,
) -> None:
    observation = runner.execute(provider, stdin=source_case.source)

    assert observation.exit_code == 0
    assert not observation.timed_out
    assert observation.stderr == ""
```

Then semantic assertions operate on decoded projections:

```python
def test_import_pipeline(
    import_case: ImportCase,
    observations: ObservationSet,
) -> None:
    assert observations.ast.contains_import(import_case.target)
    assert observations.symbols.contains_imported_binding(
        import_case.bound_name
    )
    assert observations.compilation.succeeded
    assert observations.bytecode.contains("IMPORT_NAME")
```

Runtime resolution is added independently:

```python
assert observations.importlib.transition("find-spec").failed
```

The resulting differential is explicit:

```text
tokenization           pass
AST construction       pass
symbol binding         pass
compilation            pass
IMPORT_NAME lowering   pass
ModuleSpec discovery   fail
```

## Operational correction

The initial implementation tiers can now be simplified:

### Tier 0 — Native CLI corpus

Invoke documented `python -m` providers and retain:

- command;
- interpreter identity;
- stdin/source digest;
- stdout;
- stderr;
- exit status;
- generated artifacts.

### Tier 1 — Typed decoders

Create thin Pydantic projections over the corresponding standard-library APIs.

### Tier 2 — Differential fixtures

Compare:

```text
native CLI
typed API adapter
ty/Ruff diagnostic
runtime import
```

### Tier 3 — Workflow derivation

Map discrepancy patterns into:

- hypotheses;
- ordered probes;
- assertions;
- repair qualification.

### Tier 4 — Rust projection

Move high-volume decoding, joins, indexing, and evaluation into Rust only after the observation contracts stabilize.

## Resulting architecture

```text
              CPython executable providers
 ┌─────────────────────────────────────────────┐
 │ tokenize  ast  symtable  compile  dis       │
 │ pyclbr    tabnanny    trace    inspect      │
 │ runpy     sysconfig   site     modulefinder │
 └──────────────────────┬──────────────────────┘
                        │
             generic subprocess runner
                        │
          raw, replayable process evidence
                        │
              typed provider decoders
                        │
         normalized Python semantic model
                        │
      ty / Ruff / pytest differential joins
                        │
         troubleshooting workflow corpus
```

So the more accurate implementation principle is:

> **Use the standard-library CLIs as isolated executable probes, the corresponding APIs as structured semantic adapters, and pytest as the conformance and differential-evaluation plane.**

That produces a credible prototype almost entirely from CPython itself, before RustPython, PyO3, Steel, or a native event kernel is required.

[1]: https://docs.python.org/3.14/library/cmdline.html?utm_source=chatgpt.com "Modules command-line interface (CLI) — Python 3.14.6 documentation"
[2]: https://docs.python.org/3/library/dis.html?utm_source=chatgpt.com "dis — Disassembler for Python bytecode — Python 3.14.6 documentation"
