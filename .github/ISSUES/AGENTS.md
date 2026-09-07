# Python Immersion GitHub Issues operating model

## Authority

GitHub Issues is an operational tracker projection. It is not semantic authority.

The shared tracker schema is:

```text
contracts/state/tracker.cue
```

Read that contract before creating, updating, resolving, reopening, suppressing, or correlating managed issues.

The narrow repository document, specimen, test, or contract remains authoritative for the meaning of the work. This file defines the procedural projection into GitHub Issues.

## Durable control state

Use managed issues for work that persists across conversations, evaluation runs, migration stages, or implementation phases.

```text
intent / admitted observation
        ↓
normalized typed state
        ↓
stable issue identity
        ↓
GitHub projection
        ↓
reconciliation
```

Do not create managed issues for transient conversational steps or implementation trivia.

## Origins

### `engineering-intent`

Use for desired repository changes: architecture, schemas, realizations, projections, adapters, integrations, qualification, migrations, documentation, or investigations.

### `evidence-derived`

Use only when a repository authority admits a continuing concern from an evaluation, test, or other observation. The generic tracker does not define universal evidence-derived issue classes; their meaning stays with the narrow authority that admitted them.

An issue never upgrades an observation into a fact merely by being opened.

## Primary entity

Every managed issue identifies exactly one primary entity:

```text
learning
runtime
environment
tooling
workflow
project
contract
adapter
```

Use explicit dependencies when work crosses entity or authority boundaries.

## Stable identity

Never correlate managed issues by title or GitHub issue number.

Engineering key:

```text
engineering:<entity-kind>:<entity-id>:<work-class>:<slug>
```

Evidence-derived key:

```text
evidence:<entity-kind>:<entity-id>:<issue-class>:<slug>
```

Before creation, search open and closed issues for the exact `python-issue-key` marker. Reconcile a matching issue rather than creating a duplicate.

## Required marker block

Every managed tracker issue body contains this block near the end:

```text
python-schema: python.tracker/v1
python-issue-key: <stable key>
python-origin: <engineering-intent|evidence-derived>
python-entity-kind: <kind>
python-entity-id: <id>
```

These markers are machine state. Do not casually edit them.

### `runtime.slice.v0` exception

A JSON-only `runtime.slice.v0` child issue is an executable handoff projection, not the durable tracker state. Preserve valid JSON. Its parent tracker carries the stable tracker identity and may reference the child issue. Do not append the marker block outside the JSON document.

## Managed labels

Labels are low-cardinality ergonomic projections only. They do not establish identity, authority, dependencies, or semantic truth.

Every managed issue projects:

```text
python
origin:<engineering|evidence>
entity:<tracked-entity-kind>
state:<tracker-state>
priority:<tracker-priority>
```

Engineering-intent issues also project:

```text
work:<engineering-work-class>
```

The managed namespace is the `python` ownership marker plus:

```text
origin:
entity:
state:
priority:
work:
```

Do not create labels for entity IDs, issue keys, document paths, run IDs, evidence IDs, project names, or other high-cardinality identity.

Reconciliation rules:

1. derive managed labels from typed tracker state;
2. compare managed labels as a set;
3. restore missing or altered managed labels from tracker state;
4. preserve every label outside the managed namespace;
5. never infer a tracker state change from a manual GitHub label edit.

`.github/ISSUES/labels.json` is only the operational label catalog used to provision the low-cardinality GitHub UI labels. It is not semantic authority.

GitHub Projects, milestones, assignees, and similar surfaces are optional metadata; tracker correctness must not depend on them.

## Engineering issue body

Use this shape for managed `engineering-intent` issues:

```markdown
## Contract

Primary entity, authoritative path(s), and authority boundary.

## Objective

One bounded engineering outcome.

## Scope

What this issue owns and explicitly does not own.

## Dependencies

Explicit tracker-key relationships only. Use `None` when empty.

## Acceptance

- [ ] Mechanically or observably checkable terminal condition.

## References

Relevant documents, contracts, tests, commits, upstream specifications, or child handoff issues.

---
python-schema: python.tracker/v1
python-issue-key: ...
python-origin: engineering-intent
python-entity-kind: ...
python-entity-id: ...
```

Acceptance describes terminal state, not implementation activity.

## Evidence-derived body

Also preserve:

- run/evaluation references;
- evidence references;
- the authority that admitted the issue;
- the admission decision;
- authority-specific resolution semantics.

Absence of a repeated observation is not automatically resolution.

## Lifecycle

Typed tracker states are:

```text
backlog
ready
in-progress
blocked
done
suppressed
```

GitHub open/closed state is only the external UI projection.

Close engineering work only when acceptance is satisfied or explicitly waived by the relevant authority. Close evidence-derived work only under its authority-specific resolution semantics.

## Decomposition

Create a separate tracker issue when any of these changes:

1. semantic authority;
2. primary entity;
3. independently reachable terminal state;
4. prerequisites;
5. mechanically checkable acceptance.

Executable implementation slices may be represented as `runtime.slice.v0` child issues when the handoff contract is appropriate. The parent tracker remains the orchestration surface.

## Procedure

When asked to plan or track durable Python Immersion work:

1. inspect current `main`;
2. read `contracts/state/tracker.cue`;
3. read this file;
4. inspect the narrow semantic/implementation authority;
5. classify origin, primary entity, work class, state, and priority;
6. search open and closed issues by exact `python-issue-key` marker;
7. reconcile a matching issue; create only for distinct stable identity;
8. reconcile managed labels while preserving unmanaged labels;
9. preserve explicit dependencies and terminal acceptance criteria;
10. keep `runtime.slice.v0` child bodies valid and separate from tracker markers;
11. report created/updated issue numbers and any uncovered tracker gaps.
