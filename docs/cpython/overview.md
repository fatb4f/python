# CPython diagnostic provider architecture

## Classification

CPython's standard library is both an API surface and an executable reference
implementation of Python semantics. For diagnostic tooling, it provides most of
the source, compilation, import, runtime, and environment observations needed
before a native implementation is justified.

```text
Python source / environment / invocation
                    |
                    v
            CPython reference providers
   +----------------+----------------+
   |                |                |
source model    import model    execution model
ast/tokenize    importlib/runpy  dis/inspect/trace
   |                |                |
   +----------------+----------------+
                    |
                    v
        normalized diagnostic observations
                    |
                    v
       differential troubleshooting model
```

The language-service modules form a compiler-front-end observation plane. The
remaining providers extend that plane through module resolution, execution,
runtime state, and environment attribution.

```text
source bytes
    -> tokenize / token / keyword
    -> ast
    -> symtable
    -> compile / py_compile / compileall
    -> code object
    -> dis
    -> importlib / runtime
```

## Provider taxonomy

| Diagnostic dimension | CPython providers | Observation |
| --- | --- | --- |
| Lexical structure | `token`, `keyword`, `tokenize`, `tabnanny` | Tokens, keywords, comments, encodings, operators, ranges, and indentation ambiguity |
| Syntax structure | `ast` | AST nodes, grammar version, source locations, and optimized ASTs |
| Source correlation | `asttokens` (third-party) | Exact token and text ownership for AST nodes |
| Binding and scope | `symtable` | Identifier classification and namespace relationships |
| Source browsing | `pyclbr` | Approximate class and function inventory without importing the target |
| Compilation | `compile`, `py_compile`, `compileall` | Source validity, code objects, and bytecode artifacts |
| Lowered form | `dis`, `opcode` | Bytecode instructions, offsets, positions, and compiler flags |
| Import semantics | `importlib`, `runpy` | Name resolution, `ModuleSpec`, loading, initialization, and module execution |
| Import graph approximation | `modulefinder`, `pkgutil` | Discovered dependencies, packages, and missing modules |
| Runtime objects | `inspect` | Modules, functions, frames, tracebacks, signatures, and source ownership |
| Runtime execution | `trace`, `sys.monitoring`, `bdb`, `pdb`, `profile` | Calls, returns, lines, exceptions, counts, and timing |
| Environment layout | `sysconfig`, `site`, `venv` | Prefixes, installation schemes, and package search locations |
| Distribution ownership | `importlib.metadata` | Distributions, files, requirements, entry points, and package mappings |
| Error rendering | `traceback`, `linecache` | Exception chains and source-correlated tracebacks |
| Pickle analysis | `pickletools` | Pickle virtual-machine instructions and serialized artifact analysis |

One authoritative provider should own each semantic dimension:

```text
Lexical occurrence:       tokenize
Syntax primitive:         CPython AST
Source-node correlation:  asttokens adapter
Binding and scope:        CPython symtable
Compilation validity:     CPython compile
Bytecode lowering:        CPython code object / dis
Import resolution:        CPython importlib
Runtime behavior:         isolated execution
```

## Source and compiler services

### Source-to-runtime correlation

The providers form a joinable chain rather than competing representations:

```text
source bytes
    -> token occurrence
    -> AST node
    -> symbol and scope
    -> code object
    -> instruction occurrence
    -> runtime frame
```

Their responsibilities are distinct:

- `tokenize` preserves comments, physical lines, encodings, exact operators,
  continuations, and lexical coordinates that the AST intentionally discards.
- `ast` identifies language constructs and supports feature-grammar,
  type-comment, and optimization controls.
- `asttokens` joins AST nodes to exact token and source-text intervals. It is
  third-party because the standard library does not provide a complete
  token-to-AST ownership index.
- `symtable` exposes the compiler's binding and scope classifications.
- `compile` establishes whether source is admitted by the compiler and produces
  a code object without requiring imported modules to exist.
- `dis` relates code objects to lowered instructions, offsets, and source
  positions. Bytecode is an implementation detail and is not a stable schema.

A durable occurrence can carry identities from each plane without exposing
CPython objects directly:

```python
class PythonOccurrence(BaseModel):
    document: DocumentIdentity
    source_range: SourceRange
    token_range: TokenRange | None
    ast_path: ASTPath | None
    scope_id: ScopeId | None
    code_identity: CodeIdentity | None
    instruction_offset: int | None
    frame_identity: FrameIdentity | None
```

### Binding and scope

`symtable` fills the semantic gap between AST structure and bytecode generation.
For an import such as:

```python
from package.service import Client as ApiClient
```

the providers establish different facts:

```text
ast:        requested module, member, and alias
asttokens:  exact source occurrence
symtable:   local imported binding named ApiClient
dis:        IMPORT_NAME / IMPORT_FROM lowering
importlib:  whether package.service and Client resolve at runtime
```

The import target and local symbol are separate identities. A normalized join
should preserve that distinction:

```python
class ImportBinding(BaseModel):
    occurrence_id: SourceOccurrenceId
    requested_module: str
    requested_member: str | None
    bound_name: str
    scope_id: ScopeId
    is_imported: bool
    is_local: bool
    is_global: bool
    is_referenced: bool
```

Symbol tables also expose module, function, class, annotation, type-alias,
type-parameter, and type-variable-related scopes. That information supports
diagnostics for undefined names, shadowed imports, closures, `nonlocal`,
annotations, generics, comprehensions, and class-versus-method lookup.

```python
class SymbolObservation(BaseModel):
    schema_version: Literal["python.symbol-observation.v0"]
    scope_id: ScopeId
    name: str
    imported: bool
    assigned: bool
    referenced: bool
    annotated: bool
    local: bool
    global_: bool
    declared_global: bool
    nonlocal_: bool
    free: bool
    parameter: bool
    type_parameter: bool
    comprehension_iterator: bool
    comprehension_cell: bool
    introduces_namespace: bool
    child_scope_ids: list[ScopeId]
```

Use `SymbolTableType` members at the adapter boundary rather than persisting
their underlying strings, whose exact values may change.

### Compilation and lowering

Use `compile(source, filename, "exec")` for a side-effect-free compiler probe.
Use `py_compile` when the claim concerns the real file-compilation and cache
path: it writes a `.pyc`, can raise `PyCompileError`, selects optimization, and
supports timestamp or hash-based invalidation. Use `compileall` as a
corpus-wide compilation gate, not as an import-resolution test.

For an import statement, `dis` can prove that the compiler emitted operations
such as `IMPORT_NAME` and `IMPORT_FROM`. It cannot prove that executing those
instructions will locate or initialize the requested module.

```python
class InstructionOccurrence(BaseModel):
    code_id: CodeIdentity
    offset: int
    opcode: str
    argument: JsonValue | None
    source_range: SourceRange | None
    jump_target: int | None
    logical_operation: str | None
```

### Specialized source providers

- `tabnanny` is a narrow evaluator over `tokenize` output. Wrap its lower-level
  processing and normalize `NannyNag`; do not depend on its printed output or
  treat its unstable API as a durable contract.
- `pyclbr` is a safe, inexpensive source-browser approximation for Python
  classes, functions, nesting, and inheritance. It is useful for pre-filtering
  but is intentionally less authoritative than the AST.
- `pickletools` analyzes pickle opcodes, not Python bytecode. It belongs outside
  the normal source-to-runtime path unless serialized artifacts, persistent
  caches, or protocol compatibility are the diagnostic subject.

### Diagnostic coverage

| Failure class | `tokenize` | `ast` | `symtable` | compile | `dis` | `importlib` |
| --- | --- | --- | --- | --- | --- | --- |
| Invalid token | Primary | - | - | Confirms | - | - |
| Ambiguous indentation | Supporting | May fail | - | May fail | - | - |
| Invalid syntax | Supporting | Primary | - | Confirms | - | - |
| Illegal scope declaration | - | May parse | Primary | Primary | - | - |
| Undefined or static name | Occurrence | Structure | Binding model | Often passes | Lowering | - |
| Unresolved module | Occurrence | Import primitive | Local binding | Passes | Import opcode | Primary |
| Missing imported member | Occurrence | From-list primitive | Local binding | Passes | Import-from opcode | Runtime |
| Wrong execution context | - | - | - | Usually passes | Same bytecode | `runpy` / runtime |
| Stale bytecode | - | - | - | Artifact producer | Artifact reader | Cache logic |

The expected sequence for an unresolved module is therefore:

```text
tokenization pass
    -> AST construction pass
    -> symbol binding pass
    -> compilation pass
    -> IMPORT_NAME lowering pass
    -> ModuleSpec discovery fail
```

## Import and invocation services

### Import lifecycle

An unresolved import is a lifecycle failure, not a single existence check:

```text
import occurrence
    -> resolve relative name
    -> identify and import parent
    -> acquire parent.__path__
    -> search meta-path finders
    -> produce ModuleSpec
    -> create module
    -> place initializing module in sys.modules
    -> execute loader
    -> initialize module
    -> bind child on parent
    -> satisfy from-list or member request
```

Different failures can look like the same unresolved-import diagnostic: the
parent may fail to import, may not be a package, no finder may produce a spec,
loading or initialization may fail, `sys.modules` may explicitly contain
`None`, child binding may fail, or a from-list may trigger a failing secondary
import.

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


class TransitionObservation(BaseModel):
    transition: ImportTransition
    status: Literal["pass", "fail", "indeterminate", "not-applicable"]
    inputs: dict[str, JsonValue]
    outputs: dict[str, JsonValue]
    exception: ExceptionObservation | None
    side_effects: list[StateMutation]
```

### `find_spec()` is effectful

For a dotted name, `importlib.util.find_spec()` imports the parent before
searching for the child. It can execute package initialization, mutate
`sys.modules`, fail because the parent lacks `__path__`, return an existing
module's `__spec__`, raise an initialization exception, or return `None`.

Treat it as an effectful runtime probe and prefer subprocess isolation:

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

### Invocation context

Script, module, command-string, direct import, and test-runner invocations have
different package, `sys.path`, and namespace behavior. `runpy` models module
location, parent import, package `__main__` handling, code retrieval, namespace
initialization, and execution.

```python
class InvocationContext(BaseModel):
    mode: Literal["script-path", "module", "command-string", "import", "pytest"]
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

Comparing the same source occurrence under multiple invocation contexts can
explain why a static checker, `python file.py`, and `python -m package.module`
produce different import results.

### Approximate import graphs

`modulefinder` combines import machinery and bytecode analysis to discover
modules and record missing ones. It cannot fully account for packages that
mutate `__path__` dynamically, so it should seed hypotheses and reveal
static/runtime discrepancies rather than serve as the canonical import graph.

```text
modulefinder observation
        versus
isolated CPython import observation
        -> static/runtime discrepancy
```

## Runtime and environment evidence

`inspect` is the live-object snapshot provider for modules, functions, code
objects, frames, tracebacks, signatures, source ownership, generators, and
coroutines. Runtime event providers have different roles:

```text
inspect         state snapshots
trace           prototype calls, lines, counts, and tracing
sys.monitoring  preferred low-overhead interpreter events
py-spy/PyStack  out-of-process runtime observations
```

`trace` is useful as a prototype and behavioral oracle, but it should not be
the final high-volume backend.

Environment provenance is required to classify import failures:

- `sysconfig` identifies interpreter configuration, platform, installation
  schemes, prefixes, standard-library paths, site-package paths, scripts, and
  virtual-environment layouts.
- `site` exposes active site and user-site search paths.
- `importlib.metadata` maps modules to installed distributions, versions,
  requirements, files, and entry points.

Together they distinguish common causes:

| Observation | Candidate cause |
| --- | --- |
| Distribution absent | Dependency not installed |
| Distribution under another prefix | Wrong interpreter or environment |
| Expected module exists but its path is absent from `sys.path` | Search-path configuration |
| Module is discoverable but initialization fails | Runtime package defect |
| Package exists but requested member does not | Export or API mismatch |
| Stub exists but runtime module does not | Static/runtime artifact divergence |
| Runtime module resolves but the checker rejects it | Checker environment or model divergence |

## Adapter and evidence model

### CLI-first isolation, API-backed normalization

Documented standard-library CLIs provide an inexpensive subprocess boundary for
source, compiler, runtime, and environment probes. Representative commands
include:

```bash
python -m tokenize -e source.py
python -m ast --include-attributes --show-empty source.py
python -m symtable source.py
python -m py_compile source.py
python -m dis --show-offsets --show-positions source.py
python -m sysconfig
python -m site
```

The executable provider model is:

```text
repository/source/environment
        -> python -m <stdlib-provider>
        -> stdout / stderr / exit code / artifacts / duration
        -> adapter-owned projection
        -> normalized observation
        -> diagnostic differential
```

Most standard-library CLIs emit human-readable text, not stable JSON. Preserve
their exact output for replay and auditing, but build durable projections with
the corresponding APIs. A thin companion command can serialize structured
results from `ast.parse()`, `symtable.symtable()`, or
`dis.get_instructions()` while the native CLI remains an independent oracle.

```text
native CLI result
        versus
typed API adapter result
        -> adapter conformance evaluation
```

Use one generic subprocess contract:

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

Then project raw evidence into one versioned, adapter-owned semantic envelope:

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

This boundary keeps Python-version-specific AST, symbol-table, and bytecode
details out of the durable diagnostic schema.

### Canonical provider hierarchy

```text
CPython reference providers
|
+-- source
|   +-- cpython.tokenize
|   +-- cpython.ast
|   +-- cpython.symtable
|   +-- asttokens.source-correlation
|
+-- compile
|   +-- cpython.compile
|   +-- cpython.py-compile
|   +-- cpython.compileall
|   +-- cpython.dis
|
+-- import
|   +-- cpython.importlib.resolve-name
|   +-- cpython.importlib.find-spec
|   +-- cpython.importlib.load
|   +-- cpython.runpy.execute-module
|   +-- cpython.modulefinder.approximate-graph
|
+-- runtime
|   +-- cpython.inspect
|   +-- cpython.trace
|   +-- cpython.sys-monitoring
|
+-- environment
    +-- cpython.sysconfig
    +-- cpython.site
    +-- cpython.importlib-metadata
```

## Prototype implementation order

1. **Native probe corpus:** run documented `python -m` providers and retain
   interpreter identity, command, input digest, output, exit status, duration,
   and generated artifacts.
2. **Typed source adapters:** add API-backed projections for tokens, AST nodes,
   symbols, compilation, and instructions, joined through immutable source
   identities.
3. **Import-transition probes:** isolate name resolution, parent import, parent
   path, spec discovery, loader selection, module execution, and member binding.
4. **Differential fixtures:** compare native CLIs, typed adapters, static-checker
   diagnostics, `modulefinder`, actual imports, invocation modes, and package
   metadata.
5. **Runtime enrichment:** add `sys.monitoring`, `inspect` snapshots,
   tracebacks, and out-of-process runtime providers.
6. **Native acceleration:** move high-volume decoding, joins, indexing, graph
   construction, event ingestion, and evaluation into Rust/PyO3 only after the
   observation contracts stabilize. Keep CPython as the semantic oracle.

Pytest should qualify both execution and semantic projections. For example, a
source-import fixture can assert that tokenization, AST construction, symbol
binding, compilation, and bytecode lowering succeed independently of a failing
runtime import transition.

## Conclusion

The standard library supplies an executable operational model for the complete
diagnostic lifecycle:

```text
source
    -> token
    -> AST
    -> binding and scope
    -> compilation and bytecode
    -> module resolution and initialization
    -> execution, frames, and exceptions
    -> environment attribution
```

Use standard-library CLIs as isolated raw-evidence producers, their APIs as
structured semantic adapters, and differential tests as the qualification
plane. `asttokens`, static analyzers, runtime tracers, and eventual native
acceleration then become complementary providers around a CPython-authored
semantic spine.

## References

- [Python language services](https://docs.python.org/3.14/library/language.html)
- [`ast` — Abstract syntax trees](https://docs.python.org/3.14/library/ast.html)
- [`symtable` — Access to the compiler's symbol tables](https://docs.python.org/3.14/library/symtable.html)
- [`py_compile` — Compile Python source files](https://docs.python.org/3.14/library/py_compile.html)
- [`compileall` — Byte-compile Python libraries](https://docs.python.org/3.14/library/compileall.html)
- [`dis` — Disassembler for Python bytecode](https://docs.python.org/3.14/library/dis.html)
- [`tabnanny` — Detection of ambiguous indentation](https://docs.python.org/3.14/library/tabnanny.html)
- [`pyclbr` — Python module browser support](https://docs.python.org/3.14/library/pyclbr.html)
- [Modules with command-line interfaces](https://docs.python.org/3.14/library/cmdline.html)
