# Guided evaluation slices

These worksheets operate on completed Exercism solutions. They provide
questions, observation commands, and local probe contracts, but no solutions or
answer tests. Any test, probe, or breakpoint created while following a slice is
local learner activity and should remain uncommitted.

Run `just` and path-based Ruff/ty commands from the repository root. Run
interpreter discovery from the exercise directory.

## 1. Pangram: coverage as a set relation

**Exercise:**
`stages/02-text-processing/exercises/practice/pangram`

**Recognition shape:**

```text
text
    -> normalized characters
    -> unique observed letters
    -> required alphabet subset test
    -> bool
```

### 1. Establish behavior

```sh
just test pangram
```

Choose one passing node for later runtime observation. Before reading the
implementation again, state what the function promises about case,
punctuation, digits, and the English alphabet.

### 2. Describe semantics

Identify where the implementation performs normalization, filtering,
deduplication, membership, or universal quantification. Describe the algorithm
as coverage, not merely as “using a set.” Compare these two shapes without
rewriting the solution yet:

```text
required letters <= observed letters
all(required letter occurs in observed text)
```

Explain what order and duplicate counts cease to mean after set construction.

### 3. Discover API

```sh
cd stages/02-text-processing/exercises/practice/pangram
uv run --frozen --no-sync python
```

```python
import inspect
import string
import pangram

dir(string)
type(string.ascii_lowercase)
repr(string.ascii_lowercase)
dir(set)
help(set.issubset)
inspect.signature(pangram.is_pangram)
```

Explain why `string.ascii_lowercase` expresses a different contract from
`str.isalpha()` over arbitrary Unicode text.

### 4. Extract helper

Extract or identify a slice-local helper named:

```python
def collect_letters(text: str) -> set[str]: ...
```

State whether it retains non-ASCII letters, whether it mutates its input, and
whether order or multiplicity is represented. Keep it in the exercise solution;
do not move it into a shared module.

### 5. Add a local behavioral probe

Create a local/uncommitted pytest test showing that a non-ASCII lookalike cannot
replace a missing ASCII letter. For example, replace ASCII `a` with `à` in an
otherwise complete alphabet and claim that the result is not a pangram.

Place the local test under `tests/exercism/pangram/`, run it with the supplied
suite, and leave it uncommitted:

```sh
just test pangram
```

### 6. Observe statically

```sh
uv run --frozen --no-sync ruff check \
  stages/02-text-processing/exercises/practice/pangram/pangram.py
uv run --frozen --no-sync ty check \
  stages/02-text-processing/exercises/practice/pangram/pangram.py
```

Classify each finding as structural suspicion or type-relationship
inconsistency. Do not treat an empty report as behavioral evidence.

### 7. Inspect representation

From the exercise interpreter:

```python
import ast
import dis
import inspect
import textwrap
from pangram import collect_letters

source = textwrap.dedent(inspect.getsource(collect_letters))
print(ast.dump(ast.parse(source), indent=2))
dis.dis(collect_letters)
```

Locate the iteration, predicate, and set construction in both representations.

### 8. Observe successful execution

Temporarily put `breakpoint()` immediately before the helper returns. Run one
passing supplied test with `-s`, predict the returned set, step once, and compare
the actual local state:

```sh
cd stages/02-text-processing/exercises/practice/pangram
uv run --frozen --no-sync python -m pytest -q -s \
  pangram_test.py::PangramTest::test_mixed_case_and_punctuation
```

Remove the breakpoint afterward.

### 9. Refactor

Switch between an `all(...)` formulation and a set-relation formulation, or
between a direct expression and `collect_letters`, while keeping all supplied
and local tests green. Explain which form states the coverage contract more
directly.

### 10. Record pattern

Record or review the atlas entries for membership/set relations, coverage,
`string.ascii_lowercase`, and `collect_letters`. Be able to restate the slice as:

```text
normalization + deduplication + subset predicate
```

## 2. Word Count: parse, normalize, accumulate

**Exercise:**
`stages/04-mappings-sets-comprehensions/exercises/practice/word-count`

**Recognition shape:**

```text
text
    -> word boundaries
    -> normalized tokens
    -> keyed accumulation
    -> frequency mapping
```

### 1. Establish behavior

```sh
just test word-count
```

Describe the supplied contract for case, punctuation, apostrophes, numbers,
underscores, and whitespace before describing the implementation.

### 2. Describe semantics

Separate the solution into two algorithms:

```text
tokenization / normalization
frequency counting
```

Identify string operations, iteration, dictionary lookup/update, and any
comprehension. Explain why “parse then count” is a more reusable description
than “use a regex” or “use a dictionary.”

### 3. Discover API

```sh
cd stages/04-mappings-sets-comprehensions/exercises/practice/word-count
uv run --frozen --no-sync python
```

```python
import collections
import inspect
import re
import word_count

dir(collections)
help(collections.Counter)
type(collections.Counter("aba"))
repr(collections.Counter("aba"))
dir(re)
help(re.finditer)
inspect.signature(re.finditer)
inspect.signature(word_count.count_words)
```

Compare the ontology of the two relevant modules: `re` discovers token spans;
`collections.Counter` reduces hashable values to counts.

### 4. Extract helper

Extract or identify:

```python
def parse_words(text: str) -> list[str]: ...
```

Keep `count_words` as the composition of parsing and counting. State the
apostrophe rule, case normalization rule, return ordering assumptions, and
failure behavior. Do not extract a generic parser outside this slice.

### 5. Add a local behavioral probe

Create a local/uncommitted pytest test claiming that punctuation-only input
produces an empty mapping. This isolates the boundary between recognizing no
tokens and counting recognized tokens.

Place it under `tests/exercism/word-count/` and run:

```sh
just test word-count
```

### 6. Observe statically

```sh
uv run --frozen --no-sync ruff check \
  stages/04-mappings-sets-comprehensions/exercises/practice/word-count/word_count.py
uv run --frozen --no-sync ty check \
  stages/04-mappings-sets-comprehensions/exercises/practice/word-count/word_count.py
```

Pay particular attention to whether the annotated token and count types agree
with the operations performed on them.

### 7. Inspect representation

Inspect `parse_words` with the common AST/`dis` recipe from the companion
README. Locate calls, iteration, normalization, and list construction. Then
inspect `count_words` and identify where control crosses from parsing to
reduction.

### 8. Observe successful execution

Place a temporary `breakpoint()` after tokenization but before counting. Run:

```sh
cd stages/04-mappings-sets-comprehensions/exercises/practice/word-count
uv run --frozen --no-sync python -m pytest -q -s \
  word_count_test.py::WordCountTest::test_with_apostrophes
```

Predict the next token and the corresponding mapping update, step, and inspect
both the token stream and counts. Remove the breakpoint afterward.

### 9. Refactor

Compare explicit dictionary accumulation with `Counter(parse_words(text))`.
Preserve the exercise's required return behavior and tests. Choose the form that
makes parse-versus-count responsibilities clearest, not the shortest form.

### 10. Record pattern

Record or review tokenization, dictionary accumulation, `Counter`, `re.finditer`,
`parse_words`, and `count_words`. Restate the slice as:

```text
raw occurrence -> normalized symbol -> frequency observation
```

## 3. Strain: behavior as an input

**Exercise:**
`stages/05-functions-functional-tools/exercises/practice/strain`

**Recognition shape:**

```text
items + predicate
    -> evaluate behavior for each item
    -> keep matching or complementary values
    -> ordered result
```

### 1. Establish behavior

```sh
just test strain
```

State the claims about result type, order, empty input, and the relationship
between `keep` and `discard`.

### 2. Describe semantics

Identify the conceptual transition:

```text
function call -> function as value -> behavior as parameter
```

Describe `keep` as selection and `discard` as complementary selection. Decide
whether the implementation is eager or lazy and whether it changes the input.

### 3. Discover API

```sh
cd stages/05-functions-functional-tools/exercises/practice/strain
uv run --frozen --no-sync python
```

```python
import inspect
import itertools
import strain

dir(itertools)
help(itertools.filterfalse)
inspect.signature(itertools.filterfalse)
type(lambda value: bool(value))
repr(str.isalpha)
inspect.signature(str.isalpha)
inspect.signature(strain.keep)
inspect.signature(strain.discard)
```

Explain how a built-in method, lambda, and named function can all occupy the
predicate position despite having different representations.

### 4. Extract helper

Within this slice only, identify the invariant selection operation as:

```python
def select_items(items, predicate): ...
```

Give it an accurate generic annotation appropriate to the completed solution.
State ordering, result concreteness, input mutation, predicate exceptions, and
whether each item is evaluated once. Do not create a repository utility module.

### 5. Add a local behavioral probe

Create a local/uncommitted pytest test that calls both `keep` and `discard` on a
source list and then proves the source list is unchanged. This adds a defensive
behavioral claim without duplicating the supplied result examples.

Place it under `tests/exercism/strain/` and run:

```sh
just test strain
```

### 6. Observe statically

```sh
uv run --frozen --no-sync ruff check \
  stages/05-functions-functional-tools/exercises/practice/strain/strain.py
uv run --frozen --no-sync ty check \
  stages/05-functions-functional-tools/exercises/practice/strain/strain.py
```

Use ty's output to reason about the relationship among item type, predicate
parameter, predicate return, and result element type.

### 7. Inspect representation

Inspect `select_items` or `keep` with AST and `dis`. Locate where the predicate
object is loaded and called, and where the branch determines whether an item is
included.

### 8. Observe successful execution

Place a temporary `breakpoint()` immediately after one predicate call. Run:

```sh
cd stages/05-functions-functional-tools/exercises/practice/strain
uv run --frozen --no-sync python -m pytest -q -s \
  strain_test.py::StrainTest::test_keep_z
```

Predict whether the current item will be appended, step, and compare the item,
predicate result, and accumulated output. Remove the breakpoint afterward.

### 9. Refactor

Move between an explicit loop, comprehension, and slice-local configured helper
while preserving order and non-mutation. Compare `discard` with
`itertools.filterfalse` but do not adopt laziness accidentally if the exercise
requires a list.

### 10. Record pattern

Record or review comprehension, selection, `filterfalse`, and `select_items`.
Restate the slice as:

```text
stable traversal + behavior parameter + inclusion decision
```

## 4. Grade School: grouped state and defensive queries

**Exercise:**
`stages/07-classes-modeling/exercises/practice/grade-school`

**Recognition shape:**

```text
student occurrence
    -> duplicate policy
    -> grade-keyed retained state
    -> ordered defensive projection
```

### 1. Establish behavior

```sh
just test grade-school
```

List the state the `School` must retain and the invariants enforced across
calls: uniqueness, grade association, addition outcomes, and roster ordering.

### 2. Describe semantics

Identify grouping, membership, indexing, and ranking separately. Explain why a
class is justified here: the result of the next operation depends on prior
operations and multiple related queries observe the same retained identity.

Distinguish pure value work from mutation:

```text
add student -> state transition
grade/roster -> observation projection
sort names -> pure ordering operation
```

### 3. Discover API

```sh
cd stages/07-classes-modeling/exercises/practice/grade-school
uv run --frozen --no-sync python
```

```python
import collections
import inspect
import grade_school

help(collections.defaultdict)
groups = collections.defaultdict(list)
type(groups)
repr(groups)
dir(groups)
inspect.signature(grade_school.School)
inspect.signature(grade_school.School.add_student)
inspect.signature(grade_school.School.roster)
```

Probe the difference between `groups[missing]` and `groups.get(missing)` and
explain which one mutates a `defaultdict`.

### 4. Extract helpers

Name the pure operations when they improve the state boundary:

```python
def group_students(records): ...
def rank_students(records): ...
```

Keep them local to the exercise. State duplicate policy, ordering, returned
container ownership, and whether query results may mutate retained state.

### 5. Add a local behavioral probe

Create a local/uncommitted pytest test that retrieves a grade list, mutates the
returned list, and then proves a subsequent `grade` or `roster` call is
unchanged. The probe makes the defensive-copy boundary explicit.

Place it under `tests/exercism/grade-school/` and run:

```sh
just test grade-school
```

### 6. Observe statically

```sh
uv run --frozen --no-sync ruff check \
  stages/07-classes-modeling/exercises/practice/grade-school/grade_school.py
uv run --frozen --no-sync ty check \
  stages/07-classes-modeling/exercises/practice/grade-school/grade_school.py
```

Use ty to check the relation among grade keys, stored name collections, method
returns, and the history of addition results.

### 7. Inspect representation

Inspect a pure ranking helper and `School.add_student` separately with AST and
`dis`. Compare the representation of a value transformation with attribute or
mapping mutation.

### 8. Observe successful execution

Place a temporary `breakpoint()` at the duplicate decision inside
`add_student`. Run:

```sh
cd stages/07-classes-modeling/exercises/practice/grade-school
uv run --frozen --no-sync python -m pytest -q -s \
  grade_school_test.py::GradeSchoolTest::test_cannot_add_same_student_to_multiple_grades_in_the_roster
```

Before stepping, predict the membership result, whether state will change, and
the next value appended to the addition history. Inspect locals and retained
attributes after the step. Remove the breakpoint afterward.

### 9. Refactor

Move sorting out of mutation paths or replace accidental internal-list exposure
with fresh projections while preserving every supplied and local test. Compare
an ordinary dictionary with `defaultdict`, including the missing-query mutation
boundary.

### 10. Record pattern

Record or review dictionary accumulation, grouped index, ranking,
`defaultdict`, `group_students`, and `rank_students`. Restate the slice as:

```text
validated occurrence -> indexed state -> defensive ordered observation
```

## 5. Run-Length Encoding: runs, frames, and sequential state

**Exercise:**
`stages/09-standard-library/exercises/practice/run-length-encoding`

**Recognition shape:**

```text
adjacent equal values
    -> run
    -> count/value frame
    -> encoded text
    -> parsed frames
    -> reconstructed values
```

### 1. Establish behavior

```sh
just test run-length-encoding
```

State the encoding contract for single values, multi-digit counts, whitespace,
empty input, and the round-trip relation.

### 2. Describe semantics

Describe encoding as adjacent run grouping and decoding as framed parsing.
Identify the state that must survive from one character to the next: current
value, current count, or pending count digits. Explain why this is sequential
state even when implemented inside a pure function.

### 3. Discover API

```sh
cd stages/09-standard-library/exercises/practice/run-length-encoding
uv run --frozen --no-sync python
```

```python
import inspect
import itertools
import re
import run_length_encoding

help(itertools.groupby)
groups = itertools.groupby("AAABB")
type(groups)
repr(groups)
help(re.finditer)
inspect.signature(re.finditer)
inspect.signature(run_length_encoding.encode)
inspect.signature(run_length_encoding.decode)
```

Consume one `groupby` group and observe that group iterators share the source.
Compare that incremental behavior with the match objects yielded by
`re.finditer`.

### 4. Extract helpers

Identify concrete slice-local operations such as:

```python
def encode_run(count: int, value: str) -> str: ...
def decode_runs(encoded: str) -> str: ...
```

State the count-one rule, input grammar, multi-digit behavior, invalid-frame
policy, and round-trip domain. Do not generalize these into a stream-framing
package.

### 5. Add a local behavioral probe

Create a local/uncommitted pytest test for a run of at least 100 identical
characters. Assert its multi-digit encoded representation and that decoding it
returns the original input. This extends the existing finite examples without
inventing a new input grammar.

Place it under `tests/exercism/run-length-encoding/` and run:

```sh
just test run-length-encoding
```

### 6. Observe statically

```sh
uv run --frozen --no-sync ruff check \
  stages/09-standard-library/exercises/practice/run-length-encoding/run_length_encoding.py
uv run --frozen --no-sync ty check \
  stages/09-standard-library/exercises/practice/run-length-encoding/run_length_encoding.py
```

Check whether count state remains numeric, fragments remain textual, and the
declared helper returns match the values passed to `join` or repetition.

### 7. Inspect representation

Inspect `encode_run` and the main sequential encode/decode loop with AST and
`dis`. Locate comparison, branch, repeated update, iteration, and joining
operations. Relate each instruction group to a source-level state transition
rather than treating bytecode as a stable API.

### 8. Observe successful execution

Place a temporary `breakpoint()` at a run boundary during encoding. Run:

```sh
cd stages/09-standard-library/exercises/practice/run-length-encoding
uv run --frozen --no-sync python -m pytest -q -s \
  run_length_encoding_test.py::RunLengthEncodingTest::test_encode_string_with_no_single_characters
```

Predict the completed frame, next current value, next count, and accumulated
fragments. Step and compare locals. Repeat once at a decoding boundary if the
two state machines differ materially. Remove all breakpoints afterward.

### 9. Refactor

Compare a direct previous-value loop with `itertools.groupby` for encoding and
a direct parser with `re.finditer` for decoding. Preserve the exact grammar and
round-trip tests. Use fragment accumulation plus `join` rather than repeated
immutable-string growth when the latter obscures cost.

### 10. Record pattern

Record or review iteration, joining, `groupby`, `re.finditer`, run grouping,
framed parsing, round-trip invariants, `encode_run`, and `decode_runs`. Restate
the slice as:

```text
state transition + boundary recognition + reversible representation
```

This is a preview of later stream framing, not an instruction to build a
runtime abstraction.
