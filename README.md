# Progressive Python curriculum

A frozen, standalone learning repository derived from the Exercism Python
exercise corpus. The content is physically organized into a prerequisite-aware
sequence rather than the original unordered track-maintenance layout.

## Repository contract

- `stages/` is the canonical curriculum.
- Each stage contains its concept documents and exercises in one navigable tree.
- `curriculum/sequence.json` is the machine-readable ordering contract.
- `curriculum/source-manifest.json` records the frozen source snapshot.
- `tools/path.py` validates structure, selects work, runs tests, and tracks progress.
- Upstream contribution, synchronization, generator, and maintainer automation has
  been removed.

## Start

```bash
python -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
python tools/path.py verify
python tools/path.py next
```

With `just`:

```bash
just verify
just next
just test hello-world
just mark hello-world
just status
```

## Learning loop

1. Open the path printed by `next`.
2. Read a concept document or implement the selected exercise.
3. For exercises, run `python tools/path.py test <slug>`.
4. Explain the result and mark it complete.
5. Repeat until the stage exit conditions hold without hints.

See [`curriculum/README.md`](curriculum/README.md) for the complete sequence and
[`NOTICE.md`](NOTICE.md) for provenance.
