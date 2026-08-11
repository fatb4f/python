Yes. Two are especially high-signal, and one contains an adapter pattern that is almost exactly the operational shape we have been converging on.

## Ranking

| Repo                            |  Value | Role                                                         |
| ------------------------------- | -----: | ------------------------------------------------------------ |
| **python/typeshed**             | **A+** | declarative stdlib/API contract + static-analysis oracle     |
| **python/library-fuzzers**      | **A+** | adversarial input generation + corpora + invariant discovery |
| **nvim-neotest/neotest-python** | **A-** | test discovery/execution/result adapter reference            |
| **nose-devs/nose2**             | **B-** | evented test-runner architecture to mine, not adopt          |

The important distinction is that I would **not add all four as dependencies**. They represent different kinds of reusable authority:

```text
typeshed          -> semantic data / declared contract
library-fuzzers   -> executable adversarial evidence generators
neotest-python    -> adapter architecture specimen
nose2             -> event/control architecture specimen
```

### 1. `typeshed` is much more useful than merely "stubs"

Typeshed describes the external type-level surface of the stdlib and builtins and explicitly exists for static analysis, type checking, inference, and completion.

More interestingly, its own test infrastructure already does something very close to the diagnostics workflow we were discussing:

```text
                 CPython runtime
                      ↑
                  stubtest
                      ↑
typeshed .pyi ────────────────┐
      │                       │
      ├── ty                  │
      ├── pyright             │
      ├── mypy                │
      └── pyrefly             │
                              ↓
                     normalized findings
```

Current typeshed has dedicated tests for **ty, mypy, pyright and pyrefly**, plus `stubtest_stdlib.py`, which compares the static stdlib declarations against actual runtime objects.

That gives us at least three excellent workflows.

**Declared-vs-realized API conformance**

```text
stdlib/foo.pyi
     ↓
declared symbols/signatures/types
     ↓
CPython runtime inspection
     ↓
stubtest
     ↓
API mismatch observations
```

This is an almost ideal teaching example for:

> specification → realization → observation → discrepancy

And it requires no PyO3 layer.

**Differential type-checker probing**

Take one tiny source fixture and evaluate it against:

```text
              fixture.py
                  │
        ┌─────────┼─────────┐
        ↓         ↓         ↓
       ty       mypy     pyright ...
        │         │         │
        └──── diagnostics ──┘
                  ↓
            normalize
                  ↓
          compare semantics
```

Typeshed even gives us a shared controlled semantic substrate, eliminating a lot of "maybe the checker shipped different stubs" noise.

That would complement Ruff's `diagnostics:db` very well:

```text
Ruff          -> lint-rule semantics
ty            -> inferred/type semantics
typeshed      -> declared library semantics
CPython       -> runtime semantics
pytest        -> executable assertions
```

**Stub-derived probe generation** is another interesting later step: parse `.pyi` files and derive candidate API probes—imports, attribute existence, signatures, protocols, overload scenarios. Typeshed should be treated as a _claim source_, though, not absolute runtime truth. Its own `stubtest` documentation explicitly accounts for platform/version-dependent differences, allowlists, and false positives.

That distinction fits the epistemic model unusually well.

---

## 2. `library-fuzzers` gives us the missing adversarial axis

This one is extremely valuable.

It's not just fuzzing code: the repository contains **fuzz targets, seed corpora, fuzz dictionaries, coverage instrumentation, and the target inventory** used to fuzz Python stdlib modules through OSS-Fuzz.

Its current target set spans modules including:

```text
ast
binascii
configparser
csv
difflib
email
html
http.client
json
plistlib
re
tarfile
tomllib
xml
zipfile
zoneinfo
...
```

and explicitly includes Hypothesis-driven targets for `tarfile` and `zipfile`.

The `zipfile` target is particularly instructive. It doesn't merely generate arbitrary bytes; it generates structurally valid archives and asserts a **round-trip invariant**:

```text
generated archive
       ↓
 serialize
       ↓
 deserialize
       ↓
observed ZipInfo[]
       ↓
       ==
       ↓
original ZipInfo[]
```

and then exposes the Hypothesis target as `FuzzerRunOne` for the fuzzing infrastructure.

That gives a beautiful progression for the learning/workflow repository:

```text
example test
    ↓
property
    ↓
Hypothesis strategy
    ↓
adversarial exploration
    ↓
failure
    ↓
shrunk counterexample
    ↓
regression test
    ↓
CPython regrtest candidate
```

This is probably the cleanest bridge from the curriculum's existing:

```text
pytest → Hypothesis
```

into serious production-grade testing.

A thin P0 doesn't even require OSS-Fuzz. We can simply harvest:

- target architecture;
- strategies;
- corpora;
- dictionaries;
- invariants;
- known input domains.

Then run them through ordinary pytest/Hypothesis locally.

OSS-Fuzz can remain the later heavy realization.

---

## 3. `neotest-python` contains a **very relevant adapter architecture**

I expected this to be mostly editor glue. It isn't.

Its architecture is effectively:

```text
test source
    ↓
discover positions
    ↓
select position
    ↓
build invocation
    ↓
subprocess
    ├────────→ streamed results
    ↓
final results
    ↓
normalized observation
```

The Lua side uses Tree-sitter to discover test positions, constructs a subprocess spec, streams JSON results, optionally constructs a DAP invocation, and converts execution back to Neotest results.

Even better, the Python subprocess boundary is explicit:

```python
def main(argv: List[str]) -> int:
    ...
    results, exit_code = adapter.run(args.args, stream)
    ...
    return exit_code
```

and writes both incremental JSON and final JSON.

That is remarkably close to the learner pattern we just established:

```text
function
   ↓
contract
   ↓
adapter
   ↓
side effect
   ↓
process observation
```

It even has a tiny normalized result algebra:

```text
status: skipped | passed | failed
errors: [{message, line}]
short: str
```

with an adapter interface returning results plus process status.

I would **study/reconstruct this architecture**, not couple the Python tooling core to Neotest.

It also suggests a natural eventual Neovim surface:

```text
Tree-sitter
    ↓
test identity
    ↓
our Python execution adapter
    ↓
structured result
    ├── terminal
    ├── pytest report
    ├── quickfix
    └── neotest
```

So Neotest becomes a **projection**, not semantic authority.

---

## 4. `nose2` is useful primarily as an architecture specimen

I wouldn't introduce nose2 into the test stack. The project itself explicitly recommends considering pytest for new projects.

But its plugin/event model is worth studying.

Plugins can participate in:

- collection;
- selection;
- observation;
- reporting;
- outcome modification;
- exception interpretation;
- test loading.

More importantly, nose2 passes **mutable event objects** through hooks, and handlers can mark an event as handled to intercept/control downstream behavior.

Conceptually:

```text
                 event
                   ↓
collector → selector → executor → observer → reporter
              ↑         ↑          ↑
            plugins   plugins    plugins
```

That is useful comparative material for designing an execution observation bus.

But I would extract the idea rather than the implementation. For our prototype-level architecture, immutable observations plus explicit transformations are probably easier to reason about than nose2's mutable event bus.

---

# Combined operational stack

These repositories substantially extend the earlier "CPython repo alone" map:

```text
                         ┌───────────────┐
                         │   typeshed    │
                         │ declared API  │
                         └───────┬───────┘
                                 │
                       static conformance
                                 │
       ┌───────────────┐         ↓
       │    CPython    │ ←── stubtest / ty
       │ realization   │
       └───────┬───────┘
               │
        runtime behavior
               │
     ┌─────────┴──────────┐
     ↓                    ↓
pytest/unittest       library-fuzzers
examples/regression   adversarial search
     │                    │
     └─────────┬──────────┘
               ↓
           observations
               ↓
      normalized test result
               ↑
        neotest-python
        adapter pattern
               ↓
      terminal / editor / CI
```

There are now **four distinct kinds of evidence** available without inventing much infrastructure:

```text
static declaration    typeshed
static inference      ty / Ruff
runtime examples      pytest / unittest / regrtest
adversarial behavior  Hypothesis / library-fuzzers
```

## The first workflows I'd actually build

Rather than importing four more projects into a monorepo, I'd make three tiny exercises/workflows:

1. **`stdlib-contract-audit`**
   `typeshed → ty/stubtest → CPython → normalized discrepancies`

2. **`stdlib-property-probe`**
   `library-fuzzer invariant → Hypothesis → CPython → minimized regression fixture`

3. **`test-process-adapter`**
   reconstruct the Neotest shape in clean Python:
   `TestSelector → Invocation → streamed Observation → TestResult → exit code`

Then optionally use nose2 as a **comparative architecture reading exercise**: implement one observation plugin, then reconstruct the same mechanism explicitly with plain functions/dataclasses.

That would turn these repositories into parts of the learning progression rather than another pile of tooling:

```text
types
  ↓
contracts
  ↓
examples
  ↓
process adapters
  ↓
properties
  ↓
adversarial exploration
  ↓
normalized observations
  ↓
diagnostics / editor projection
```

**`typeshed + CPython + library-fuzzers` in particular looks like a remarkably comprehensive Python semantics laboratory.** The addition of Neotest's adapter pattern then supplies a very clean operational boundary for exposing it.
