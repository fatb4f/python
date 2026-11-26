# Workstation security: Phase 1 contract

This specimen describes intended identities, authority, protected asset roles,
and the unverified recovery prerequisite. It does not create accounts, change
sudoers, establish asset ownership, or inspect or enforce the live system.
Paths and ownership are unresolved. `_404` retains its existing administrative
role during qualification; the root entry does not prescribe root's live login
configuration. Service identities do not have interactive login in this model.

The baseline admits no operator transition to `developer` or `chatgpt`. The
command-grant fixture demonstrates a possible future shape only; it is not an
authorized grant. Blocking obvious shell and interpreter names does not prove
that a program cannot run commands, interpret input, or confer wider authority.
Any actual grant requires separate review of the executable, arguments,
environment, writable dependencies, and effective privileges.

Recovery is explicitly unverified and provisioning is disallowed in this
revision. A later contract revision must require independent administrative
access and rollback tests before provisioning can be admitted.

The existing [Xonsh migration plan](../../docs/xonsh/implementation.md)
describes a different login arrangement. Reconcile the plans before migration;
this specimen does not change the execution environment.

## Validation

From the repository root, run `just test`. The fixture tests require `cue` on
`PATH` and are reported as skipped if it is absent. For an explicit CUE check:

```sh
cd specimens/workstation-security
cue vet -c identity.cue authority.cue assets.cue recovery.cue fixtures/baseline.json -d '#Contract'
cue vet -c identity.cue authority.cue assets.cue recovery.cue fixtures/command-grant.json -d '#CommandGrant'
```

Both commands must succeed. The pytest fixture table runs each negative case
separately and requires rejection at the expected field. These tests validate
the contract model, not Linux permissions, sudo, sandboxing, or recovery.
