# Operational CPython intelligence prototype plan

This plan postpones a custom Textual editor and motion grammar. It first
operationalizes the CPython provider architecture as a small headless Python
package and validates that boundary through mature modal editors.

The initial client is Neovim. A later client for a Steel-enabled Helix fork is
the portability test: both editors must consume the same protocol without
owning Python semantic logic.

This builds on the provider boundaries in [overview.md](overview.md) and the
editor-independent command model in
[terminal-native-development.md](../terminal-native-development.md).

## Architecture

```text
repository + unsaved candidate + uv realization
                        │
                        ▼
                python-intel core
       tokenize / AST / symtable / compile / dis
           environment / Ruff / ty / pytest
                        │
                        ▼
             versioned JSON observations
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
        Neovim client       Helix/Steel client
          first                  later
```

CPython remains the semantic authority. Editors contribute buffers, cursor
positions, selections, and presentation surfaces.

## Headless core

Implement the first provider set around immutable source identity:

```text
source identity
├─ tokenize       lexical occurrence
├─ ast            syntax and source ranges
├─ symtable       scope and binding classification
├─ compile        compiler admission
├─ dis            lowering and instruction positions
└─ environment    interpreter and uv realization
```

Normalize results into narrow, versioned contracts. The initial conceptual
types are:

```python
DocumentCandidate(
    project_root,
    path,
    source_digest,
    source,
)

InspectionRequest(
    request_id,
    operation,
    candidate,
    position,
    interpreter,
)

SemanticInspection(
    occurrence,
    syntax,
    binding,
    compilation,
    lowering,
    qualification_scope,
)

ProcessObservation(
    command,
    cwd,
    environment,
    stdout,
    stderr,
    exit_code,
    duration,
)
```

The core follows these boundaries:

- Accept unsaved source through standard input; source providers must not need
  to mutate the project file.
- Run version-sensitive providers through the project's `uv`-selected
  interpreter.
- Keep imports, project execution, tests, and other effectful operations in
  isolated child processes.
- Preserve raw provider output when applicable while exposing normalized JSON
  to clients.
- Do not introduce a persistent graph, daemon, scheduler, or generalized claim
  engine in the prototype.

## Protocol and commands

Start with an asynchronous, one-request-per-process JSON protocol:

```text
editor
  → JSON request on stdin
  → python-intel subprocess
  → one versioned JSON response
```

The first source-safe operations are:

```text
inspect/why
inspect/ast
inspect/scope
inspect/compile
project/environment
```

Effectful operations use a visibly separate command family:

```text
execute/file
test/focused
diagnose/ruff
diagnose/type
```

Every response contains its schema version, request ID, document path, source
digest, provider and interpreter identities, outcome, structured payload,
errors, and duration.

Add a long-lived JSON Lines server, cancellation protocol, and progressive
responses only if process startup becomes a measured interaction problem.

## Neovim client

Build a thin Lua client that launches the headless executable asynchronously.
Do not implement semantic analysis in Lua or depend on Neovim's LSP state.

Initial commands are:

```text
:PyWhy       inspect the occurrence beneath the cursor
:PyAst       show its AST ownership
:PyScope     show binding and namespace facts
:PyCompile   compile the current unsaved buffer
:PyRun       execute the file through uv
:PyTest      run the focused test
```

Use native Neovim projections:

```text
floating window    :PyWhy and semantic details
quickfix           compiler, Ruff, ty, and test locations
extmarks           source-correlated annotations
terminal/output    unmodified execution and test output
status             pending, current, stale, or failed
```

The client must:

- capture the buffer number, `changedtick`, source digest, path, and cursor
  position with each request;
- reject a response when the buffer revision or source digest no longer
  matches;
- batch annotations instead of issuing one RPC operation per occurrence; and
- leave existing editing, undo, motions, Tree-sitter, and LSP behavior
  untouched.

## Helix/Steel portability check

After the Neovim workflow is useful, implement the same operations in the
Steel-enabled Helix fork.

The portability check succeeds when:

- no Python provider logic is copied into Steel;
- the same request and response fixtures work for both clients;
- differences are limited to buffer acquisition, task invocation, and UI
  projection; and
- neither client is required to run or test the headless core.

Only after this check should a standalone Textual client be reconsidered.

## Delivery sequence

1. Implement candidate identity, interpreter discovery, and the versioned
   request and response envelope.
2. Add AST, `symtable`, compilation, and `dis` adapters with source-position
   correlation.
3. Provide the one-shot CLI and deterministic JSON fixtures.
4. Implement Neovim `:PyWhy`, `:PyScope`, and `:PyCompile`.
5. Add uv-owned execution, focused pytest, Ruff, and ty projections.
6. Implement the Helix/Steel client against the unchanged protocol.
7. Evaluate whether recurring client needs justify a daemon, shared index,
   Textual client, or PyO3 acceleration.

Defer SCIP, PyO3, Pyodide, an evidence graph, automated qualification,
regrtest orchestration, and custom editor implementation until the operational
workflow demonstrates demand.

## Test plan

- Unit-test token, AST, scope, compiler, and instruction normalization.
- Test local, global, nonlocal, free, cell, parameter, imported, and shadowed
  bindings.
- Verify invalid syntax and illegal scope declarations retain partial evidence
  from earlier applicable stages.
- Golden-test JSON schemas, deterministic ordering, errors, paths, Unicode
  ranges, and interpreter provenance.
- Test requests using unsaved source that differs from the filesystem.
- Verify project code cannot execute during source-only inspection.
- Test Neovim stale-response rejection using changed buffer revisions.
- Run identical protocol fixtures through the eventual Neovim and Helix/Steel
  adapters.

## Assumptions

- Neovim is the first client because it offers the lowest-risk integration
  surface.
- Neovim is a prototype and projection, not a product dependency or semantic
  authority.
- The Helix/Steel fork is the second-client portability test.
- CPython 3.14 and `uv` are the initial semantic and environment authorities.
- A custom terminal editor becomes justified only after the intelligence
  workflow itself is proven.
