## Classification

The **Python Language Services** index defines a coherent **front-end and compilation observation plane**:

```text
source bytes
    ↓
tokenize / token / keyword
    ↓
ast
    ↓
symtable
    ↓
compile / py_compile / compileall
    ↓
code object
    ↓
dis
```

The index explicitly groups modules for tokenization, parsing, syntax analysis, bytecode disassembly, and related language-processing facilities. It is narrower than CPython’s complete operational model because it does not include import loading, environment discovery, runtime frames, or package metadata. ([Python documentation][1])

## Provider taxonomy

| Stage                  | Standard-library provider | Authoritative observation                             |
| ---------------------- | ------------------------- | ----------------------------------------------------- |
| Lexical classification | `token`, `keyword`        | Token and keyword identities                          |
| Tokenization           | `tokenize`                | Lexical occurrences and source positions              |
| Indentation validation | `tabnanny`                | Ambiguous whitespace diagnostics                      |
| Syntax                 | `ast`                     | Python language primitives                            |
| Binding and scope      | `symtable`                | Identifier classification and namespace relationships |
| Source browsing        | `pyclbr`                  | Approximate functions/classes hierarchy               |
| Compilation            | `compile`, `py_compile`   | Source-to-code-object validity                        |
| Repository compilation | `compileall`              | Corpus-wide compilation qualification                 |
| Lowered execution form | `dis`                     | Bytecode instructions and source positions            |
| Pickle format analysis | `pickletools`             | Pickle virtual-machine instructions                   |

The major architectural addition relative to the earlier `ast`/`asttokens` model is **`symtable`**.

---

# `symtable` is the missing semantic-binding layer

The compiler constructs symbol tables from the AST immediately before generating bytecode. Their responsibility is to determine the scope of each identifier. The public `symtable` API exposes those compiler-generated tables. ([Python documentation][2])

```text
AST
    identifies language constructs

symtable
    identifies binding and scope semantics

dis
    identifies compiled execution operations
```

This gives a more complete compiler pipeline:

```text
source occurrence
    ↓
token occurrence
    ↓
AST node
    ↓
symbol occurrence / namespace classification
    ↓
code object
    ↓
bytecode instruction
```

## Relevance to imports

For:

```python
import package.submodule as service
```

the providers establish different facts:

```yaml
ast:
  kind: Import
  imported_module: package.submodule
  alias: service

symtable:
  identifier: service
  imported: true
  local: true
  referenced: true

importlib:
  requested_module: package.submodule
  resolvable: true | false
```

`Symbol.is_imported()` establishes that a binding was introduced through an import statement. Other symbol predicates expose whether the identifier is local, global, free, assigned, referenced, annotated, a parameter, or a namespace. ([Python documentation][2])

The important constraint is:

> `symtable` models the **binding produced by an import**, not whether the imported module can be located or loaded.

Therefore:

```text
ty unresolved-import
        │
        ├─ AST: which import operation?
        ├─ asttokens: which exact source occurrence?
        ├─ symtable: which binding and scope?
        └─ importlib: does the external module resolve and load?
```

## Two distinct diagnostic subjects

Consider:

```python
from package.service import Client as ApiClient

def execute():
    return ApiClient()
```

There are at least two semantic identities:

```text
Import target:
    package.service.Client

Local symbol:
    ApiClient
```

The first belongs to the import-resolution model. The second belongs to the compiler’s symbol-table model.

A normalized join could be:

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

This permits separate conclusions:

```text
module resolution failed
binding was nevertheless declared by source
binding is referenced downstream
failure propagates to N dependent occurrences
```

That is useful for ranking diagnostic impact.

---

# `symtable` also defines compiler scopes absent from a basic AST walk

Python 3.14 symbol tables distinguish module, function, class, annotation, type-alias, type-parameter, and type-variable-related scopes. They also expose nested tables, locals, globals, nonlocals, free variables, comprehension iteration variables, comprehension cells, and namespace-producing symbols. ([Python documentation][2])

This matters for diagnostics involving:

- undefined names;
- shadowed imports;
- closure capture;
- invalid `nonlocal`;
- annotation-only names;
- generic type parameters;
- imported symbols hidden by assignments;
- comprehension scope;
- class-versus-method name lookup.

The ontology should therefore separate:

```text
NameOccurrence
    lexical occurrence of an identifier

BindingOccurrence
    operation that introduces a name

Symbol
    compiler classification of that name in a scope

ResolutionClaim
    analyzer claim about the object represented by the name

RuntimeBinding
    value actually present during execution
```

## Recommended symbol projection

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

Do not expose hard-coded symbol-table type strings as the durable contract. Python’s documentation recommends using `SymbolTableType` members because exact string values may change. ([Python documentation][2])

---

# Revised source-semantic stack

```text
                 ┌────────────────────────┐
source bytes ───►│ tokenize               │
                 │ lexical occurrences    │
                 └────────────┬───────────┘
                              ▼
                 ┌────────────────────────┐
                 │ ast                    │
                 │ language primitives    │
                 └────────────┬───────────┘
                              │
                 ┌────────────▼───────────┐
                 │ asttokens              │
                 │ source-node join       │
                 └────────────┬───────────┘
                              │
                 ┌────────────▼───────────┐
                 │ symtable               │
                 │ scope and binding      │
                 └────────────┬───────────┘
                              │
                 ┌────────────▼───────────┐
                 │ compile / py_compile   │
                 │ compiler qualification │
                 └────────────┬───────────┘
                              │
                 ┌────────────▼───────────┐
                 │ dis                    │
                 │ bytecode projection    │
                 └────────────────────────┘
```

`asttokens` is third-party because the standard library does not directly provide a complete token-to-AST ownership index. `symtable`, however, supplies compiler-authored semantic information that should not be reconstructed from AST heuristics.

---

# Diagnostic coverage by provider

| Failure class             | `tokenize` |               `ast` |      `symtable` |           compile |              `dis` |            `importlib` |
| ------------------------- | ---------: | ------------------: | --------------: | ----------------: | -----------------: | ---------------------: |
| Invalid token             |    Primary |                   — |               — |          Confirms |                  — |                      — |
| Ambiguous indentation     | Supporting |            May fail |               — |          May fail |                  — |                      — |
| Invalid syntax            | Supporting |             Primary |               — |          Confirms |                  — |                      — |
| Illegal scope declaration |          — |           May parse | Primary/compile |           Primary |                  — |                      — |
| Undefined/static name     | Occurrence |           Structure |   Binding model |      Often passes |           Lowering |                      — |
| Unresolved module         | Occurrence |    Import primitive |   Local binding |            Passes |      Import opcode |                Primary |
| Missing imported member   | Occurrence | From-list primitive |   Local binding |            Passes | Import-from opcode |        Primary/runtime |
| Wrong execution context   |          — |                   — |               — |    Usually passes |      Same bytecode | `runpy`/import runtime |
| Stale bytecode            |          — |                   — |               — | Artifact producer |    Artifact reader |     Import cache logic |

This matrix exposes why an unresolved import cannot be classified by compiler success alone:

```text
parse succeeds
symbol table succeeds
compilation succeeds
bytecode contains IMPORT_NAME
runtime finder returns no ModuleSpec
```

That is a valid and expected transition sequence.

---

# `py_compile` and `compileall`

## `py_compile`: file-level compiler qualification

`py_compile.compile()` compiles a source file and writes a `.pyc` artifact. It can raise a structured `PyCompileError`, select optimization levels, and control bytecode invalidation through timestamp, checked-hash, or unchecked-hash modes. ([Python documentation][3])

Use it when the assertion concerns the **real file compilation and cache-writing path**:

```yaml
probe:
  provider: cpython.py-compile
  subject: src/package/module.py

assert:
  compilation: success
  pyc_created: true
  invalidation_mode: checked-hash
```

For a side-effect-free syntax/compiler probe, prefer:

```python
compile(source, filename, "exec")
```

`py_compile` writes an artifact and therefore introduces filesystem, permissions, symlink, cache-path, and invalidation concerns. Those effects are valuable only when the diagnostic hypothesis concerns the actual installation or bytecode-cache lifecycle. ([Python documentation][3])

## `compileall`: repository-level qualification

`compileall` recursively compiles files and directories and is intended to produce cached bytecode for Python libraries. Its CLI can recursively process directory trees or files and, without arguments, can operate over directories from `sys.path`. ([Python documentation][4])

Architecturally:

```text
py_compile
    one-file compiler probe

compileall
    corpus-wide compiler qualification
```

`compileall` is useful as an evaluation gate:

```yaml
evaluation:
  claim: repository-is-cpython-compilable
  provider: cpython.compileall
  scope: repository
  expected:
    failures: 0
```

It should not be used as an import-resolution test. Compilation does not require external imported modules to exist.

---

# `dis`: lowering evidence, not runtime evidence

`dis` observes the compiled bytecode representation. For an import statement it can establish that the compiler emitted operations such as module import, from-list handling, and local binding.

Conceptually:

```text
from package import Client
```

becomes a sequence resembling:

```text
LOAD_CONST
LOAD_CONST
IMPORT_NAME
IMPORT_FROM
STORE_NAME
```

This proves that:

- the source compiled;
- the compiler recognized the import primitive;
- the operation was lowered into bytecode;
- source positions can be related to instructions.

It does **not** prove that executing `IMPORT_NAME` will locate or initialize the module. The language-services index classifies `dis` as the bytecode disassembly and analysis provider. ([Python documentation][1])

A normalized instruction projection could be:

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

Then:

```text
AST ImportFrom
    ↕
IMPORT_NAME + IMPORT_FROM instructions
    ↕
runtime import events
```

This establishes source-to-execution continuity.

---

# `token`, `keyword`, and `tokenize`

These form the lexical contract:

```text
token
    token-kind vocabulary

keyword
    keyword classification

tokenize
    concrete lexical occurrences
```

They should generally be exposed through one adapter:

```python
class TokenOccurrence(BaseModel):
    document_id: DocumentId
    index: int

    kind: str
    exact_kind: str
    text: str

    range: SourceRange
    physical_line: str
```

The AST provider should consume the same immutable source revision, but it should not be allowed to replace token observations. AST construction intentionally discards comments, formatting, redundant parentheses, and other lexical information.

---

# `tabnanny`: narrow diagnostic precedent

`tabnanny` processes `tokenize` output and reports ambiguous indentation. Its API is primarily script-oriented, is documented as potentially unstable, and writes diagnostics to standard output through its high-level `check()` function. Its lower-level `process_tokens()` raises `NannyNag` when it detects ambiguity. ([Python documentation][5])

This is a useful precedent for the proposed architecture:

```text
generic observation provider:
    tokenize

specialized diagnostic method:
    tabnanny ambiguity evaluator

diagnostic event:
    ambiguous-indentation
```

Do not make the adapter depend on its printed output. Wrap the lower-level processing and normalize the exception:

```python
class IndentationAmbiguityObservation(BaseModel):
    document_id: DocumentId
    line: int
    message: str
    offending_line: str
```

Because the API is explicitly unstable, the adapter boundary should be versioned and tested against supported Python releases. ([Python documentation][5])

---

# `pyclbr`: inexpensive approximate structural provider

`pyclbr` extracts limited information about functions, classes, methods, nesting, and inheritance directly from Python source without importing the target module. This makes it safe for untrusted source, but it cannot inspect extension modules or non-Python implementations. ([Python documentation][6])

Its appropriate classification is:

```text
provider:
    source-browser approximation

authority:
    non-authoritative

effects:
    no target-module execution
```

Possible use:

```text
pyclbr
    ↓
cheap candidate definition graph
    ↓
AST/RustPython qualification
    ↓
runtime/PyO3 enrichment
```

It is useful for:

- fast repository browsing;
- definition inventories;
- nested class/function outlines;
- approximate inheritance edges;
- pre-filtering source files before deeper analysis.

It should not replace the AST semantic model because its information is intentionally limited.

---

# `pickletools`: mostly outside this diagnostic plane

`pickletools` analyzes pickle opcodes, not Python source bytecode. It belongs in the language-services index because pickle has its own stack-machine instruction format.

For the current diagnostic architecture, it is relevant only when examining:

- serialized Python artifacts;
- unsafe or malformed pickle payloads;
- persistent caches that use pickle;
- protocol compatibility;
- serialized diagnostic stores.

It is not part of the normal:

```text
source → AST → symbol table → bytecode → runtime
```

pipeline.

---

# Canonical provider grouping

```text
python.language.lexical
├── token
├── keyword
├── tokenize
└── tabnanny

python.language.syntax
├── ast
└── asttokens

python.language.binding
└── symtable

python.language.browser
└── pyclbr

python.language.compilation
├── compile
├── py_compile
└── compileall

python.language.lowering
└── dis

python.serialization.pickle
└── pickletools
```

## Authority ordering

```text
Lexical occurrence:
    tokenize

Syntax primitive:
    CPython AST

Source-node correlation:
    asttokens adapter

Binding and scope:
    CPython symtable

Compilation validity:
    CPython compile

Bytecode lowering:
    CPython code object / dis

Import resolution:
    CPython importlib

Runtime behavior:
    actual isolated execution
```

One authoritative provider should own each semantic dimension.

---

# Revised end-to-end model

```text
ty / Ruff diagnostic
        │
        ▼
diagnostic source range
        │
        ▼
tokenize occurrence
        │
        ▼
ASTTokens source-node correlation
        │
        ▼
AST language primitive
        │
        ▼
symtable binding and scope
        │
        ▼
compile qualification
        │
        ▼
dis instruction projection
        │
        ▼
importlib / runtime transition observations
        │
        ▼
differential evaluation
```

For unresolved imports specifically:

```text
ImportFrom AST node
    +
exact asttokens occurrence
    +
symtable imported binding
    +
IMPORT_NAME / IMPORT_FROM instructions
    +
importlib resolution outcome
    +
runtime initialization outcome
    ↓
high-fidelity ImportResolutionProblem
```

## Core conclusion

The `language.html` index identifies a nearly complete **compiler-front-end diagnostic stack**. The most consequential module for the current model is `symtable`, because it fills the semantic gap between AST structure and bytecode generation:

```text
ast
    what operation is expressed?

asttokens
    where exactly is it expressed?

symtable
    what bindings and scopes does it create?

compile/dis
    how is it admitted and lowered?

importlib/runtime
    what happens when it executes?
```

That sequence supplies the canonical Python-native semantic spine against which ty, Ruff, pytest, RustPython, PyO3 introspection, and runtime tracing observations can be compared.

[1]: https://docs.python.org/3/library/language.html "Python Language Services — Python 3.14.7 documentation"
[2]: https://docs.python.org/3/library/symtable.html "symtable — Access to the compiler’s symbol tables — Python 3.14.7 documentation"
[3]: https://docs.python.org/3/library/py_compile.html "py_compile — Compile Python source files — Python 3.14.7 documentation"
[4]: https://docs.python.org/3/library/compileall.html "compileall — Byte-compile Python libraries — Python 3.14.7 documentation"
[5]: https://docs.python.org/3/library/tabnanny.html "tabnanny — Detection of ambiguous indentation — Python 3.14.7 documentation"
[6]: https://docs.python.org/3/library/pyclbr.html "pyclbr — Python module browser support — Python 3.14.7 documentation"
