# T2 — Compose

T2 combines already-understood Python values and process results without
hiding representation or effect boundaries.

## Native composition

Use ordinary Python and Xonsh facilities first:

- expressions, comprehensions, iteration, and functions;
- Path and environment values;
- captured subprocess output and structured decoders;
- ordinary pipes where text is the correct boundary representation;
- aliases for stable, understood commands.

Example shape:

```xsh
import json

raw = $(some-command --json)
records = json.loads(raw)
active = [record for record in records if record['active']]
rprint(sorted(active, key=lambda record: record['name']))
```

The process produces text, decoding crosses into Python objects, selection and
ranking operate on values, and Rich renders the result. Those roles remain
distinct even when the interactive syntax is compact.

## Derived pipeline pattern

When values genuinely flow through ordered operations, the
[source/filter/transform/sink pattern](../semantics/patterns.md#source-filter-transform-sink)
may describe the composition. It is not mandatory task-decomposition
vocabulary.

## Adoption gate

Stay at T2 while native composition remains clear. Repetition alone does not
justify Coconut or shell extension; identify the exact transformation or
interaction friction first.
