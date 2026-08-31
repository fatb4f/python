# Python semantic companion

This companion is a second pass over selected Exercism exercises. Exercism
continues to provide the problem and behavioral specification; these documents
provide a vocabulary for recognizing how the completed program is expressed,
observed, and changed.

The companion is deliberately documentation-only. It adds no exercise
solutions, answer tests, helper package, command wrapper, progress state, or
runtime. A worksheet may ask the learner to create a local test or temporary
probe, but that work remains local and uncommitted.

`tests/exercism/` normally supports durable learner-authored tests; tests
created specifically for these semantic-companion worksheets are temporary
probes and should not be committed unless independently promoted as a durable
behavioral claim.

## Intended outcome

The learner should be able to describe the same code at several levels:

```text
language construct
    -> built-in idiom
    -> stdlib primitive
    -> algorithmic idiom
    -> verb_noun helper
    -> helper composition
    -> configured behavior or justified state
    -> later domain pattern
```

The initial repertoire is small. It covers set relations, token counting,
predicate selection, grouped state, and sequential framing. These patterns are
enough to make later pipelines and diagnostics systems look like compositions
of familiar Python mechanisms rather than new framework concepts.

## When to use it

Use a slice only after completing its Exercism exercise and understanding the
provided tests. The slices are optional checkpoints; they do not affect
`next`, `mark`, or curriculum completion.

The initial order is:

```text
Pangram
set relation
    -> Word Count
       data reduction
        -> Strain
           behavior as input
            -> Grade School
               indexed state
                -> Run-Length Encoding
                   sequential state
```

See [slices.md](slices.md) for the worksheets and [reference.md](reference.md)
for the seeded atlas.

### Optional terminal projection

[Xonsh T0](xonsh-t0.md) projects the same semantic vocabulary into ordinary
terminal work. It does not add another curriculum or semantic authority.
Instead, filesystem objects, subprocess results, structured output, and shell
state provide a concrete domain for repeatedly deriving types, structures, and
algorithms from constraints, required properties, and required operations.

Its core sequence is:

```text
intent
  -> constraints analysis
  -> required properties
  -> required operations
  -> representation
  -> algorithm
  -> execution
  -> observation
```

Use it as an optional realization profile when terminal immersion is useful;
continue to use `reference.md` for the meanings and boundaries of the seeded
patterns.

## Worksheet control loop

Every slice follows the same ten steps.

1. **Establish behavior.** Run the completed exercise and read its tests as
   behavioral claims.
2. **Describe semantics.** Name the built-in idioms and algorithmic pattern in
   the implementation.
3. **Discover API.** Explore relevant modules, types, and functions with
   `dir`, `help`, `type`, `repr`, and `inspect.signature`.
4. **Extract helper.** Give one operation a `verb_noun` name, annotation, and
   explicit behavioral contract.
5. **Add a local behavioral probe.** Create one focused, local/uncommitted
   pytest edge case that adds information.
6. **Observe statically.** Run Ruff and ty independently and interpret their
   findings separately.
7. **Inspect representation.** Inspect the helper's AST and bytecode with
   `ast` and `dis`.
8. **Observe successful execution.** Enter a successful call with pdb or a
   temporary `breakpoint()`, predict the next state, step, and inspect locals.
9. **Refactor.** Change structure while preserving the claimed behavior.
10. **Record pattern.** Capture the reusable semantic shape with the atlas
    schema.

This produces the observation hierarchy:

```text
behavior
    -> semantics
    -> API surface
    -> explicit contract
    -> behavioral probe
    -> static representation
    -> compiled representation
    -> runtime state
    -> behavior-preserving transformation
    -> reusable semantic pattern
```

## Keep the observers distinct

Each observer answers a different question.

| Observer | Question |
| --- | --- |
| pytest | Does observable behavior satisfy the claim? |
| Ruff | What syntactic or structural pattern looks suspicious? |
| ty | What relationship between values and types is inconsistent? |
| AST | What source structure did Python derive? |
| `dis` | How did CPython lower the function into instructions? |
| pdb | Through which runtime state transitions did the call proceed? |

Do not combine these into one check command. A passing test does not answer a
type question, and clean static output does not establish runtime behavior.

### Common command shapes

Run repository commands from the repository root:

```sh
just test <exercise-slug>
just test-node '<exercise-test-path>::<test-class>::<test-name>'

uv run --frozen --no-sync ruff check <solution-path>
uv run --frozen --no-sync ty check <solution-path>
```

For interactive discovery, enter the exercise directory first so its solution
module imports exactly as it does under the supplied tests:

```sh
cd <exercise-directory>
uv run --frozen --no-sync python
```

Then inspect a subject without trying to memorize its entire namespace:

```python
import inspect
import module_name

dir(module_name)
dir(module_name.subject)
help(module_name.subject)
type(module_name.subject)
repr(module_name.subject)
inspect.signature(module_name.subject)
```

Inspect source structure and bytecode for the extracted helper:

```python
import ast
import dis
import inspect
import textwrap

source = textwrap.dedent(inspect.getsource(subject))
print(ast.dump(ast.parse(source), indent=2))
dis.dis(subject)
```

For a successful runtime observation, temporarily place `breakpoint()` at a
state transition inside the helper and run one focused passing test with output
capture disabled:

```sh
uv run --frozen --no-sync python -m pytest -q -s \
  '<test-file>::<test-class>::<passing-test>'
```

At the pdb prompt:

```text
p locals()
# predict the values after the next source line
n
p locals()
# explain the transition, then continue
c
```

Remove the temporary breakpoint after the observation. A bug is not required;
the point is to learn how correct execution changes state.

## Contracts before abstractions

A useful helper has a name and a claim. Record at least:

- accepted inputs and returned value;
- whether it mutates an input or retained state;
- ordering and normalization promises;
- meaningful boundary behavior;
- failures that are part of the contract.

Similar helpers across slices are intentionally not deduplicated into shared
utilities. Duplication is permitted until a later learning step explicitly
studies abstraction pressure.

```text
concrete operation
    -> named helper
    -> repeated shape
    -> recognized abstraction pressure
    -> later higher-order function or generalization study
```

`collect_letters`, `parse_words`, and `select_items` therefore remain
slice-local ideas. The atlas may reveal their relationships, but it does not
authorize a generic helper module.

## Architectural vocabulary

Use this distinction when a later exercise reaches an external boundary:

```text
PURE CORE
domain value -> domain value

EFFECT ADAPTER
filesystem / OS / process -> raw occurrence

OBSERVATION PROJECTION
raw occurrence -> structured observation
```

The initial five slices are almost entirely core transformations. Grade School
introduces retained in-memory state, and Run-Length Encoding previews framing,
but neither requires an effect adapter. Process execution, streaming IO, and
diagnostics belong to later work.

## Completion evidence

A slice is complete when the learner can explain its implementation in terms
of syntax, built-in idiom, algorithm, relevant stdlib capability, helper
contract, pytest claim, static diagnostics, compiled representation, runtime
state transition, and preserved behavior after refactoring.

The explanation is the completion record. The repository does not track it.

## Explicitly deferred

- shared abstractions and generic helper libraries;
- runtime and process laboratories;
- evidence models and diagnostics architecture;
- PPF or domain integration;
- async or concurrency abstractions;
- orchestration and combined observer commands;
- automatic worksheet execution or completion tracking;
- editor- or LSP-specific workflow authority.
