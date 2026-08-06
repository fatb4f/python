## Classification

CPython’s `Lib/` tree is not merely a collection of utilities. For this architecture, it is a **reference operational-model corpus**:

```text
Python source / environment / invocation
                    │
                    ▼
              CPython Lib providers
   ┌────────────────┼────────────────────┐
   │                │                    │
source model    import model       execution model
ast/tokenize    importlib/runpy     dis/inspect/trace
   │                │                    │
   └────────────────┼────────────────────┘
                    ▼
        normalized diagnostic observations
                    ▼
       differential troubleshooting model
```

`asttokens` is one source-correlation implementation. `Lib/` contains the broader set of Python-native primitives needed to model the complete lifecycle.

## Provider map

| Diagnostic dimension       | CPython `Lib/` providers                                                       | Observation                                                                 |
| -------------------------- | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| Lexical structure          | `tokenize.py`, `token.py`                                                      | Tokens, comments, encodings, operators, exact source ranges                 |
| Syntax structure           | `ast.py`                                                                       | AST nodes, grammar version, source locations, optimized AST                 |
| Import semantics           | `importlib/_bootstrap.py`, `_bootstrap_external.py`, `util.py`, `machinery.py` | Name resolution, finder selection, `ModuleSpec`, loading and initialization |
| Import graph approximation | `modulefinder.py`, `pkgutil.py`                                                | Discovered dependencies, packages, missing modules                          |
| Module execution           | `runpy.py`                                                                     | `python -m`, package `__main__`, module namespace and execution contract    |
| Compiled semantics         | `dis.py`, `opcode.py`                                                          | Bytecode instructions, offsets, source positions, compiler flags            |
| Runtime objects            | `inspect.py`                                                                   | Modules, functions, frames, tracebacks, signatures, source ownership        |
| Runtime execution          | `trace.py`, `bdb.py`, `pdb.py`, `profile.py`                                   | Calls, returns, lines, exceptions and execution counts                      |
| Environment layout         | `sysconfig`, `site.py`, `venv`                                                 | Prefixes, installation schemes and package search locations                 |
| Distribution ownership     | `importlib.metadata`                                                           | Distribution, files, requirements, entry points and package mappings        |
| Error rendering            | `traceback.py`, `linecache.py`                                                 | Exception chains and source-correlated tracebacks                           |

The architectural implication is:

> CPython `Lib/` can supply most of the Python-semantic provider adapters before a Rust-native implementation is necessary.

---

# Unresolved imports become a lifecycle, not a rule code

The most important material is `Lib/importlib`.

## Actual import state machine

```text
Import occurrence
    │
    ├─ resolve relative name
    │
    ├─ identify/import parent
    │
    ├─ obtain parent.__path__
    │
    ├─ search meta-path finders
    │
    ├─ produce ModuleSpec
    │
    ├─ create module
    │
    ├─ place initializing module in sys.modules
    │
    ├─ execute loader
    │
    ├─ initialize module
    │
    ├─ bind child on parent
    │
    └─ satisfy from-list/member request
```

`_find_and_load_unlocked()` distinguishes several operational failure states:

- a parent module cannot be imported;
- the parent exists but is not a package;
- no finder produces a `ModuleSpec`;
- loading or initialization fails;
- the module is explicitly `None` in `sys.modules`;
- child binding onto the parent fails;
- a from-list request triggers a secondary submodule import.

These are different causes that can all surface as an unresolved-import-like diagnostic.

A useful normalized transition model is therefore:

```python
class ImportTransition(str, Enum):
    RESOLVE_NAME = "resolve-name"
    RESOLVE_PARENT = "resolve-parent"
    ACQUIRE_PARENT_PATH = "acquire-parent-path"
    FIND_SPEC = "find-spec"
    CREATE_MODULE = "create-module"
    LOAD_MODULE = "load-module"
    INITIALIZE_MODULE = "initialize-module"
    BIND_CHILD = "bind-child"
    RESOLVE_FROM_MEMBER = "resolve-from-member"
```

And each probe produces:

```python
class TransitionObservation(BaseModel):
    transition: ImportTransition
    status: Literal["pass", "fail", "indeterminate", "not-applicable"]
    inputs: dict[str, JsonValue]
    outputs: dict[str, JsonValue]
    exception: ExceptionObservation | None
    side_effects: list[StateMutation]
```

## `find_spec()` is not a pure existence check

For a dotted module name, `importlib.util.find_spec()` imports the parent package before searching for the child. It can therefore:

- execute parent package code;
- mutate `sys.modules`;
- raise an initialization exception;
- fail because the parent lacks `__path__`;
- return an existing module’s `__spec__`;
- return `None`.

Thus this is incorrect:

```text
find_spec("a.b") == harmless static lookup
```

The proper contract is:

```text
find_spec("a.b")
    = effectful runtime resolution probe
```

The implementation explicitly imports the parent and obtains its package path before invoking the finder machinery.

That should be reflected in capability declarations:

```yaml
provider: cpython.importlib.find-spec
effects:
  - import-parent
  - execute-parent-initializer
  - read-sys-meta-path
  - read-sys-modules
  - mutate-sys-modules
isolation: subprocess-recommended
```

---

# `runpy` models the invocation differential

`runpy.py` is particularly relevant to the earlier distinction between:

```bash
uv run app.py
uv run python -m package.app
uv run python -c "import package.app"
```

These are not equivalent operational contexts.

`runpy` explicitly models:

- locating a module through import machinery;
- importing its parent package;
- obtaining its `ModuleSpec`;
- rejecting namespace packages or packages without an executable `__main__`;
- obtaining the code object from the loader;
- assigning `__name__`, `__file__`, `__cached__`, `__loader__`, `__package__` and `__spec__`;
- executing the code in an appropriate namespace.

This gives an invocation-context model:

```python
class InvocationContext(BaseModel):
    mode: Literal[
        "script-path",
        "module",
        "command-string",
        "import",
        "pytest",
    ]

    argv0: str
    cwd: Path
    sys_path: list[Path]

    module_name: str | None
    package_name: str | None
    module_spec: ModuleSpecObservation | None

    executable: Path
    prefix: Path
    base_prefix: Path
```

The diagnostic evaluator can then compare:

```text
same source occurrence
+ different InvocationContext
→ different import outcome
```

This is often the root cause of:

```text
ty unresolved import
but python app.py succeeds
```

or the inverse.

---

# `modulefinder` is a ready-made differential provider

`modulefinder.py` already performs a form of import-graph analysis. It uses import machinery and bytecode disassembly, tracks discovered modules and records bad modules.

Its explicit limitation is architecturally useful: it cannot fully account for packages that mutate `__path__` dynamically.

That makes it ideal as a **non-authoritative approximation provider**:

```text
modulefinder observation
        versus
actual CPython import observation
        ↓
static/runtime discrepancy
```

Example classification:

```yaml
claim:
  kind: module-resolvable

providers:
  modulefinder:
    result: false
    authority: approximate-static

  importlib-runtime:
    result: true
    authority: runtime

verdict:
  category: dynamic-package-path
  confidence: high
```

Do not use `modulefinder` as the canonical graph. Use it to seed hypotheses and expose divergences.

---

# Source-to-runtime correlation

The full source bridge now becomes:

```text
source bytes
    ↓
tokenize
    ↓
token occurrence
    ↓
ast.parse
    ↓
semantic syntax node
    ↓
asttokens
    ↓
exact node/token/text correlation
    ↓
compile
    ↓
code object
    ↓
dis
    ↓
instruction occurrence
    ↓
inspect / frame observation
    ↓
runtime occurrence
```

## Responsibilities

### `tokenize`

`tokenize` preserves lexical details that AST nodes intentionally discard:

- comments;
- physical lines;
- encodings;
- exact operators;
- line continuations;
- lexical start and end coordinates.

It is designed to follow Python tokenization while additionally emitting comments and an encoding token.

### `ast`

`ast.parse()` is implemented through `compile(..., PyCF_ONLY_AST)` and can select a feature grammar, type-comment handling and optimized AST generation.

### `asttokens`

`asttokens` then joins the AST node to the exact token and source-text interval.

### `dis`

`dis` projects code objects into executable instruction occurrences and can expose instruction offsets and source positions. It accepts code objects, functions, generators, coroutines, source strings and tracebacks.

This enables a durable cross-plane identity:

```python
class PythonOccurrence(BaseModel):
    document: DocumentIdentity

    source_range: SourceRange
    token_range: TokenRange | None
    ast_path: ASTPath | None

    code_identity: CodeIdentity | None
    instruction_offset: int | None
    frame_identity: FrameIdentity | None
```

The join chain is approximately:

```text
diagnostic span
 → token interval
 → AST node
 → code object position table
 → instruction
 → runtime frame
```

---

# Runtime evidence plane

`inspect.py` is the live-object adapter layer. It exposes friendlier projections over internal structures such as:

- code objects;
- frames;
- tracebacks;
- modules;
- functions;
- generators and coroutines;
- source ownership;
- signatures and closure variables.

`trace.py` supplies a basic event collector for:

- line execution counts;
- called functions;
- caller/callee edges;
- tracing;
- coverage-like evidence.

For the proposed architecture:

```text
inspect
    = state snapshot provider

trace / sys.settrace
    = legacy execution-event provider

sys.monitoring
    = preferred low-overhead interpreter-event provider

py-spy / PyStack
    = out-of-process runtime provider
```

`trace.py` should not become the final high-performance backend. It is useful as the prototype implementation and behavioural oracle for a later `sys.monitoring`/PyO3 provider.

---

# Environment and package ownership

An unresolved import cannot be classified reliably without environment provenance.

## `sysconfig`

`sysconfig` exposes:

- current interpreter configuration;
- platform identity;
- installation schemes;
- standard-library paths;
- pure-Python and platform-specific package paths;
- scripts and include directories;
- virtual-environment layouts.

It also explicitly accounts for downstream distributors modifying installation schemes.

## `importlib.metadata`

`importlib.metadata` exposes:

- installed distributions;
- package metadata;
- versions;
- requirements;
- files;
- entry points;
- package-to-distribution mappings.

Together they support:

```text
module name
    ↓
candidate distribution ownership
    ↓
installed distribution
    ↓
installed files
    ↓
expected site-packages location
    ↓
actual interpreter search paths
```

This differentiates:

| Observation                                                           | Candidate cause                         |
| --------------------------------------------------------------------- | --------------------------------------- |
| Distribution absent                                                   | Dependency not installed                |
| Distribution installed under another prefix                           | Wrong interpreter or environment        |
| Distribution contains expected module but path absent from `sys.path` | Search-path configuration               |
| Module discoverable but initialization fails                          | Runtime package defect                  |
| Package found but requested member absent                             | Export/API mismatch                     |
| Stub found but runtime module absent                                  | Static/runtime artifact divergence      |
| Runtime module found but checker rejects it                           | Checker environment or model divergence |

---

# Recommended normalized provider hierarchy

```text
CPython reference providers
│
├── source
│   ├── cpython.tokenize
│   ├── cpython.ast
│   └── asttokens.source-correlation
│
├── compile
│   ├── cpython.compile
│   ├── cpython.dis
│   └── cpython.symtable
│
├── import
│   ├── cpython.importlib.resolve-name
│   ├── cpython.importlib.find-spec
│   ├── cpython.importlib.load
│   ├── cpython.runpy.execute-module
│   └── cpython.modulefinder.approximate-graph
│
├── runtime
│   ├── cpython.inspect
│   ├── cpython.trace
│   └── cpython.sys-monitoring
│
└── environment
    ├── cpython.sysconfig
    ├── cpython.site
    └── cpython.importlib-metadata
```

Each provider should expose a versioned adapter-owned projection rather than leaking CPython objects:

```python
class ProviderObservation(BaseModel):
    schema_version: Literal["diagnostics.provider-observation.v0"]

    provider: ProviderIdentity
    subject: SubjectIdentity
    operation: str

    inputs: dict[str, JsonValue]
    outcome: Literal["success", "failure", "indeterminate"]
    outputs: dict[str, JsonValue]

    exceptions: list[ExceptionObservation]
    mutations: list[StateMutation]
    environment: EnvironmentIdentity
```

---

# Prototype implementation order

## Tier 0 — subprocess probes

Use isolated Python commands:

```text
ast.parse
tokenize
compile
importlib.util.find_spec
runpy
importlib.metadata
sysconfig
```

Serialize only adapter projections to JSON.

## Tier 1 — in-process source kernel

```text
ASTTokens
+ AST walker
+ diagnostic-span intersection
+ normalized SourceOccurrence
```

## Tier 2 — import-transition probes

Instrument each stage independently:

```text
resolve-name
parent import
parent path
find-spec
loader identification
module execution
member binding
```

Run effectful probes in disposable subprocesses.

## Tier 3 — differential evaluation

Compare:

```text
ty/Ruff
modulefinder
find_spec
actual import
runpy execution
distribution metadata
```

## Tier 4 — runtime event enrichment

Add:

```text
sys.monitoring
inspect snapshots
tracebacks
py-spy / PyStack
```

## Tier 5 — Rust/PyO3 boundary

Move only high-volume operations:

- token/span joins;
- AST occurrence indexing;
- graph construction;
- observation normalization;
- event ingestion;
- differential evaluation.

Keep CPython itself as the semantic oracle.

---

## Core conclusion

`Lib/` is the strongest basis for the operational model because it contains the executable Python-level realization of the lifecycle being diagnosed:

```text
source
→ token
→ AST
→ compile
→ module resolution
→ loading
→ initialization
→ execution
→ frame/exception
→ environment attribution
```

The correct architecture is not to reimplement these semantics immediately in Rust. It is:

```text
CPython Lib reference implementation
        ↓ thin adapters
versioned semantic observations
        ↓ differential evaluation
diagnostic troubleshooting workflow
        ↓
pytest fixtures / probes / assertions
        ↓
optional Rust/PyO3 acceleration
```

`asttokens` remains valuable, but it is now one adapter within a much larger CPython-native provider plane.
