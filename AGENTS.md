# Python Immersion repository instructions

Treat the current repository as the source of truth for repository-grounded work. Inspect current `main` before making architectural claims or mutations.

## Task categories

Classify durable work into one or more of these categories:

```text
semantic learning model
Python runtime / tooling
Xonsh / Ops environment
project realization
repository implementation
engineering tracking
```

Use the narrowest existing document, specimen, test, or contract as authority. Preserve the repository's escalation rule:

```text
manual understanding
  -> repeated use
  -> observed friction
  -> smallest useful abstraction
  -> evaluation
  -> retain or remove
```

## Engineering issue tracking

Engineering work that should persist across conversations, evaluation cycles, migration stages, or implementation phases uses the repository GitHub Issues model.

Before creating, updating, closing, reopening, or correlating a managed tracker issue, read in order:

1. `contracts/state/tracker.cue` — typed tracker and GitHub projection contract;
2. `.github/ISSUES/AGENTS.md` — issue projection and reconciliation procedure;
3. the narrow document, specimen, test, or contract that owns the work semantics.

GitHub Issues is operational tracking state, not semantic authority.

Keep `engineering-intent` separate from `evidence-derived` issues. Planned work does not establish an observation as fact; an observed failure does not become durable tracker state until the relevant repository authority admits it.

Track one primary entity per issue and use explicit tracker-key dependencies rather than inferring coupling from titles, paths, issue numbers, or conversation proximity.

Correlate managed issues by `python-issue-key`, never by title or GitHub issue number.

## Executable handoff issues

Issues whose complete body is a `runtime.slice.v0` handoff are executable child slices, not tracker-state documents. Keep their JSON body valid and governed by the handoff schema. The parent managed tracker issue owns durable orchestration state and references child slice issue numbers as operational references.

Do not append tracker markers to a JSON-only handoff body unless the handoff schema is explicitly extended to carry them.
