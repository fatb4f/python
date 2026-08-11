# Semantic pattern atlas

This atlas is a compact recognition aid, not an API inventory. Every entry uses
the same schema so a language construct, stdlib capability, algorithm, and
helper can be compared at the same semantic level.

## Entry schema

| Field | Meaning |
| --- | --- |
| Name | The idiom, capability, algorithm, or helper name. |
| Kind | One of `builtin`, `stdlib`, `algorithm`, or `helper`. |
| Semantic meaning / contract | The behavior the entry expresses. |
| Canonical shape | A compact data-flow or recognition shape. |
| Minimal example | A small example independent of exercise answers. |
| Boundary / misuse | A limit, ambiguity, or common inappropriate use. |
| Underlying mechanism | The Python construct or protocol doing the work. |
| Algorithmic interpretation | The computational idea represented. |
| Complexity, when relevant | The meaningful cost choice, not trivia. |
| Helper projection | A plausible `verb_noun` operation using the pattern. |
| Domain projection, when relevant | How the pattern may later acquire domain names. |
| Evaluation slice | The initial worksheet that exercises the entry. |

`Kind` is restricted to:

```text
builtin | stdlib | algorithm | helper
```

## Built-in idioms

### Comprehension

- **Name:** Comprehension
- **Kind:** `builtin`
- **Semantic meaning / contract:** Project and optionally filter values while
  constructing a concrete collection.
- **Canonical shape:** `iterable -> expression + optional predicate -> collection`
- **Minimal example:** `[word.upper() for word in words if word]`
- **Boundary / misuse:** Prefer an explicit loop when several state changes or
  failure branches make the expression hard to read.
- **Underlying mechanism:** Iteration plus list, set, or dict construction.
- **Algorithmic interpretation:** Map, filter, or index construction.
- **Complexity, when relevant:** Usually linear in consumed input, plus the
  cost of the expression and membership operations.
- **Helper projection:** `normalize_words`, `select_items`, `index_items`
- **Domain projection, when relevant:** `select_applicable_obligations`
- **Evaluation slice:** Strain; Word Count

### Membership and set relations

- **Name:** Membership and set relations
- **Kind:** `builtin`
- **Semantic meaning / contract:** Ask whether values occur or whether one
  unique-value collection covers another.
- **Canonical shape:** `values -> set -> membership / subset relation`
- **Minimal example:** `required <= set(observed)`
- **Boundary / misuse:** Set conversion discards order and duplicates; do not
  use it when either carries meaning.
- **Underlying mechanism:** `set`, `in`, `<=`, and hashing.
- **Algorithmic interpretation:** Deduplication and coverage testing.
- **Complexity, when relevant:** Construction is expected linear; membership
  is average constant time per lookup.
- **Helper projection:** `collect_letters`, `require_fields`
- **Domain projection, when relevant:** `covers_required_capabilities`
- **Evaluation slice:** Pangram

### `any` and `all`

- **Name:** Existential and universal predicates
- **Kind:** `builtin`
- **Semantic meaning / contract:** State whether at least one or every consumed
  value satisfies a truth test.
- **Canonical shape:** `iterable of claims -> any/all -> bool`
- **Minimal example:** `all(name.strip() for name in names)`
- **Boundary / misuse:** Both short-circuit; predicate side effects may not run
  for every item. `all([])` is true and `any([])` is false.
- **Underlying mechanism:** Truth testing and incremental iteration.
- **Algorithmic interpretation:** Existential or universal quantification.
- **Complexity, when relevant:** At most linear, often less because of
  short-circuiting.
- **Helper projection:** `has_errors`, `all_fields_present`
- **Domain projection, when relevant:** `all_obligations_satisfied`
- **Evaluation slice:** Pangram; Strain

### Dictionary accumulation

- **Name:** Dictionary accumulation
- **Kind:** `builtin`
- **Semantic meaning / contract:** Maintain a key-addressed summary while
  consuming values.
- **Canonical shape:** `items -> derived key -> updated mapping entry`
- **Minimal example:** `counts[word] = counts.get(word, 0) + 1`
- **Boundary / misuse:** Missing-key policy is part of the contract; avoid
  silently inventing defaults when absence should be an error.
- **Underlying mechanism:** Mapping lookup, assignment, and hashing.
- **Algorithmic interpretation:** Frequency counting, grouping, or indexing.
- **Complexity, when relevant:** Expected linear consumption with average
  constant-time lookup and update.
- **Helper projection:** `count_words`, `index_items`, `group_students`
- **Domain projection, when relevant:** `index_observations_by_probe`
- **Evaluation slice:** Word Count; Grade School

### Unpacking

- **Name:** Structural unpacking
- **Kind:** `builtin`
- **Semantic meaning / contract:** Decompose a value whose structure is already
  known into meaningful local names.
- **Canonical shape:** `structured value -> named parts`
- **Minimal example:** `name, score = record`
- **Boundary / misuse:** The arity must match unless starred unpacking is used;
  avoid hiding ambiguous positional formats behind clever unpacking.
- **Underlying mechanism:** The iteration protocol and assignment targets.
- **Algorithmic interpretation:** Structural decomposition.
- **Complexity, when relevant:** Proportional to the consumed structure.
- **Helper projection:** `decode_record`, `split_result`
- **Domain projection, when relevant:** `separate_stdout_stderr`
- **Evaluation slice:** Word Count; Run-Length Encoding

### Iteration

- **Name:** Incremental iteration
- **Kind:** `builtin`
- **Semantic meaning / contract:** Consume values one at a time without
  requiring knowledge of the producer's representation.
- **Canonical shape:** `iterable -> iterator -> successive values`
- **Minimal example:** `for item in items: observe(item)`
- **Boundary / misuse:** Iterators may be single-use and lazy; repeated passes
  or indexing are not guaranteed.
- **Underlying mechanism:** `iter`, `next`, `__iter__`, and `__next__`.
- **Algorithmic interpretation:** Stream consumption and state transition.
- **Complexity, when relevant:** Typically linear in consumed values with
  potentially constant auxiliary space.
- **Helper projection:** `collect_items`, `encode_runs`
- **Domain projection, when relevant:** `observe_events`
- **Evaluation slice:** All five slices

### `sorted(key=...)`

- **Name:** Keyed sorting
- **Kind:** `builtin`
- **Semantic meaning / contract:** Produce a new ranked list while preserving
  the input collection.
- **Canonical shape:** `items -> key(item) -> ordered list`
- **Minimal example:** `sorted(records, key=lambda record: record.score)`
- **Boundary / misuse:** A full sort is unnecessary for a small top-k result;
  remember that sorting returns a list and key comparability is required.
- **Underlying mechanism:** Stable Timsort with one computed key per item.
- **Algorithmic interpretation:** Ranking and lexicographic ordering.
- **Complexity, when relevant:** `O(n log n)` time and `O(n)` output storage.
- **Helper projection:** `rank_students`, `rank_results`
- **Domain projection, when relevant:** `rank_diagnostics`
- **Evaluation slice:** Grade School

### String joining

- **Name:** String joining
- **Kind:** `builtin`
- **Semantic meaning / contract:** Assemble text fragments with an explicit
  separator in one semantic operation.
- **Canonical shape:** `text fragments -> separator.join -> text`
- **Minimal example:** `", ".join(names)`
- **Boundary / misuse:** Every fragment must already be text; convert values at
  the boundary rather than relying on implicit conversion.
- **Underlying mechanism:** `str.join` consuming an iterable of strings.
- **Algorithmic interpretation:** Linear sequence serialization.
- **Complexity, when relevant:** Linear in total output size, unlike repeated
  immutable-string concatenation that can become quadratic.
- **Helper projection:** `encode_runs`, `format_report`
- **Domain projection, when relevant:** `serialize_observation`
- **Evaluation slice:** Run-Length Encoding

## Standard-library capabilities

### `string.ascii_lowercase`

- **Name:** `string.ascii_lowercase`
- **Kind:** `stdlib`
- **Semantic meaning / contract:** Provide the explicit ASCII lowercase
  alphabet independent of locale and Unicode classification.
- **Canonical shape:** `fixed alphabet -> required symbol set`
- **Minimal example:** `set(string.ascii_lowercase)`
- **Boundary / misuse:** It models ASCII English letters, not every Unicode
  lowercase character or human alphabet.
- **Underlying mechanism:** A stable module constant.
- **Algorithmic interpretation:** Define the finite universe for coverage.
- **Complexity, when relevant:** Fixed-size construction for this alphabet.
- **Helper projection:** `collect_required_letters`
- **Domain projection, when relevant:** `required_capability_names`
- **Evaluation slice:** Pangram

### `collections.Counter`

- **Name:** `collections.Counter`
- **Kind:** `stdlib`
- **Semantic meaning / contract:** Count hashable occurrences and expose the
  result as a mapping with count-oriented operations.
- **Canonical shape:** `items -> Counter -> item frequencies`
- **Minimal example:** `Counter("mississippi")`
- **Boundary / misuse:** Missing keys read as zero and zero/negative counts can
  remain present; that differs from a strict ordinary dictionary contract.
- **Underlying mechanism:** A `dict` subclass specialized for counts.
- **Algorithmic interpretation:** Frequency table construction.
- **Complexity, when relevant:** Expected `O(n)` construction and `O(k)` stored
  distinct keys.
- **Helper projection:** `count_words`, `count_events`
- **Domain projection, when relevant:** `count_diagnostics_by_code`
- **Evaluation slice:** Word Count

### `collections.defaultdict`

- **Name:** `collections.defaultdict`
- **Kind:** `stdlib`
- **Semantic meaning / contract:** Create a missing mapping value from a
  configured factory during indexed access.
- **Canonical shape:** `key -> default factory -> mutable grouped index`
- **Minimal example:** `groups = defaultdict(list); groups[key].append(value)`
- **Boundary / misuse:** Reading `groups[missing]` mutates the mapping. Use
  `.get()` when a query must not create state.
- **Underlying mechanism:** `dict.__missing__` and a `default_factory`.
- **Algorithmic interpretation:** Grouping or adjacency-list construction.
- **Complexity, when relevant:** Expected linear construction with average
  constant-time access.
- **Helper projection:** `group_students`, `group_results`
- **Domain projection, when relevant:** `group_events_by_stream`
- **Evaluation slice:** Grade School

### `itertools.filterfalse`

- **Name:** `itertools.filterfalse`
- **Kind:** `stdlib`
- **Semantic meaning / contract:** Lazily yield values for which a predicate is
  false.
- **Canonical shape:** `iterable + predicate -> lazily rejected values`
- **Minimal example:** `filterfalse(str.isalpha, tokens)`
- **Boundary / misuse:** The result is a one-pass iterator, not a list; predicate
  side effects occur only as values are consumed.
- **Underlying mechanism:** Lazy iteration with behavior supplied as a value.
- **Algorithmic interpretation:** Complementary selection.
- **Complexity, when relevant:** Linear in consumed input and constant
  auxiliary iterator space.
- **Helper projection:** `discard_items`, `select_nonmatching`
- **Domain projection, when relevant:** `select_non_applicable_rules`
- **Evaluation slice:** Strain

### `itertools.groupby`

- **Name:** `itertools.groupby`
- **Kind:** `stdlib`
- **Semantic meaning / contract:** Yield consecutive runs that share a key.
- **Canonical shape:** `adjacent values -> key equality -> run iterators`
- **Minimal example:** `[(key, list(run)) for key, run in groupby("AAABB")]`
- **Boundary / misuse:** It groups adjacent runs, not all equal values globally;
  each group iterator shares and advances the source iterator.
- **Underlying mechanism:** Lazy iteration with retained previous-key state.
- **Algorithmic interpretation:** Run grouping and transition detection.
- **Complexity, when relevant:** Linear in consumed input with bounded internal
  state, excluding materialized groups.
- **Helper projection:** `encode_runs`, `group_adjacent`
- **Domain projection, when relevant:** `frame_repeated_events`
- **Evaluation slice:** Run-Length Encoding

### `re.finditer`

- **Name:** `re.finditer`
- **Kind:** `stdlib`
- **Semantic meaning / contract:** Lazily produce match objects for successive
  non-overlapping pattern occurrences.
- **Canonical shape:** `text + pattern -> match stream -> captured fields`
- **Minimal example:** `re.finditer(r"[A-Za-z]+", text)`
- **Boundary / misuse:** A regex is a compact grammar with its own boundary
  rules; do not use it when ordinary splitting or iteration states the contract
  more clearly.
- **Underlying mechanism:** The regular-expression engine and `Match` objects.
- **Algorithmic interpretation:** Token recognition and framed parsing.
- **Complexity, when relevant:** Pattern-dependent; simple linear scans are
  typical, while pathological patterns can backtrack heavily.
- **Helper projection:** `parse_words`, `decode_runs`
- **Domain projection, when relevant:** `parse_diagnostic_line`
- **Evaluation slice:** Word Count; Run-Length Encoding

## Algorithmic idioms

### Coverage

- **Name:** Coverage testing
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Determine whether every required unique
  value occurs among observed values.
- **Canonical shape:** `required set + observed set -> subset predicate`
- **Minimal example:** `{1, 2} <= {1, 2, 3}`
- **Boundary / misuse:** Coverage says nothing about order, multiplicity, or
  proximity.
- **Underlying mechanism:** Set construction and subset comparison.
- **Algorithmic interpretation:** Finite-universe satisfaction.
- **Complexity, when relevant:** Expected `O(r + o)` time and space for required
  and observed values.
- **Helper projection:** `covers_required`, `collect_letters`
- **Domain projection, when relevant:** `satisfies_required_checks`
- **Evaluation slice:** Pangram

### Tokenization

- **Name:** Tokenization and normalization
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Divide raw text into meaningful units and
  convert equivalent surface forms to a canonical representation.
- **Canonical shape:** `text -> token boundaries -> normalized tokens`
- **Minimal example:** `[part.casefold() for part in text.split() if part]`
- **Boundary / misuse:** Token boundary and normalization policy are domain
  decisions; Unicode, apostrophes, punctuation, and empty tokens need explicit
  treatment.
- **Underlying mechanism:** String methods, iteration, or a recognizer such as
  `re.finditer`.
- **Algorithmic interpretation:** Lexical scanning and canonicalization.
- **Complexity, when relevant:** Usually linear in input length plus output
  storage.
- **Helper projection:** `parse_words`, `normalize_tokens`
- **Domain projection, when relevant:** `parse_event_fields`
- **Evaluation slice:** Word Count

### Frequency counting

- **Name:** Frequency counting
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Associate each distinct value with its
  occurrence count.
- **Canonical shape:** `items -> keyed accumulation -> counts`
- **Minimal example:** `{"red": 2, "blue": 1}`
- **Boundary / misuse:** Decide whether zero counts, negative adjustments,
  insertion order, or non-hashable items matter.
- **Underlying mechanism:** Dictionary accumulation or `Counter`.
- **Algorithmic interpretation:** Histogram construction.
- **Complexity, when relevant:** Expected `O(n)` time and `O(k)` space for `k`
  distinct values.
- **Helper projection:** `count_words`, `count_items`
- **Domain projection, when relevant:** `count_failures_by_kind`
- **Evaluation slice:** Word Count

### Selection

- **Name:** Predicate selection
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Preserve values according to behavior
  supplied as a predicate.
- **Canonical shape:** `iterable -> predicate -> selected iterable`
- **Minimal example:** `[value for value in values if predicate(value)]`
- **Boundary / misuse:** State whether ordering, laziness, input mutation, and
  predicate exception behavior are part of the contract.
- **Underlying mechanism:** Comprehension, `filter`, or `filterfalse`.
- **Algorithmic interpretation:** Filter and complementary partition.
- **Complexity, when relevant:** `O(n)` predicate calls and output-proportional
  storage for a concrete result.
- **Helper projection:** `select_items`
- **Domain projection, when relevant:** `select_applicable_obligations`
- **Evaluation slice:** Strain

### Grouped index

- **Name:** Grouping and indexing
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Build a mapping from a derived key to all
  values sharing that key.
- **Canonical shape:** `items -> key -> grouped index`
- **Minimal example:** `{grade: [names...]}`
- **Boundary / misuse:** Define duplicate, missing-key, ordering, and mutation
  behavior rather than inheriting accidental container behavior.
- **Underlying mechanism:** Dictionary-of-collections or `defaultdict`.
- **Algorithmic interpretation:** Bucket construction.
- **Complexity, when relevant:** Expected `O(n)` construction before any
  per-bucket ordering.
- **Helper projection:** `group_students`, `group_results`
- **Domain projection, when relevant:** `group_observations_by_source`
- **Evaluation slice:** Grade School

### Ranking

- **Name:** Keyed ranking
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Order values by one or more explicit
  comparison dimensions.
- **Canonical shape:** `items -> key tuple -> stable ordered result`
- **Minimal example:** `sorted(rows, key=lambda row: (row.grade, row.name))`
- **Boundary / misuse:** A full order is more work than min/max or bounded top-k;
  avoid relying on unrelated object comparison.
- **Underlying mechanism:** `sorted(key=...)` and stable sorting.
- **Algorithmic interpretation:** Lexicographic ranking.
- **Complexity, when relevant:** `O(n log n)` for a full sort.
- **Helper projection:** `rank_students`, `rank_results`
- **Domain projection, when relevant:** `rank_candidate_diagnoses`
- **Evaluation slice:** Grade School

### Run grouping

- **Name:** Adjacent run grouping
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Collapse consecutive equal values into a
  value plus run-length representation.
- **Canonical shape:** `adjacent equal values -> run -> count + value`
- **Minimal example:** `"AAABB" -> [(3, "A"), (2, "B")]`
- **Boundary / misuse:** Equal values separated by another value belong to
  different runs.
- **Underlying mechanism:** Previous-value state or `itertools.groupby`.
- **Algorithmic interpretation:** Transition detection and run-length encoding.
- **Complexity, when relevant:** `O(n)` time with bounded transition state.
- **Helper projection:** `encode_run`, `encode_runs`
- **Domain projection, when relevant:** `coalesce_repeated_events`
- **Evaluation slice:** Run-Length Encoding

### Framed parsing

- **Name:** Framing and incremental interpretation
- **Kind:** `algorithm`
- **Semantic meaning / contract:** Recover logical records from a compact
  sequence by recognizing boundaries and interpreting each frame.
- **Canonical shape:** `encoded text -> frame boundaries -> decoded values`
- **Minimal example:** `"12A3B" -> [(12, "A"), (3, "B")]`
- **Boundary / misuse:** The encoding must be unambiguous about count digits,
  literal digits, invalid frames, and end-of-input behavior.
- **Underlying mechanism:** Index state, a small parser, or `re.finditer`.
- **Algorithmic interpretation:** Sequential state machine and deserialization.
- **Complexity, when relevant:** Linear in encoded plus decoded output size for
  an unambiguous single-pass grammar.
- **Helper projection:** `decode_runs`, `parse_frames`
- **Domain projection, when relevant:** `frame_stream_chunks`
- **Evaluation slice:** Run-Length Encoding

### Round-trip invariant

- **Name:** Round-trip invariant
- **Kind:** `algorithm`
- **Semantic meaning / contract:** A representation conversion followed by its
  inverse preserves every value admitted by the stated domain.
- **Canonical shape:** `value -> encode -> decode -> equivalent value`
- **Minimal example:** `decode(encode(value)) == value`
- **Boundary / misuse:** The claim applies only to the supported input domain;
  canonicalization may make the reverse direction intentionally unequal.
- **Underlying mechanism:** Paired transformations and an equivalence relation.
- **Algorithmic interpretation:** Bidirectional representation correctness.
- **Complexity, when relevant:** Includes both transformations and intermediate
  representation storage.
- **Helper projection:** `encode_runs` plus `decode_runs`
- **Domain projection, when relevant:** `serialize_observation` plus
  `parse_observation`
- **Evaluation slice:** Run-Length Encoding

## Helper patterns

### `collect_letters`

- **Name:** `collect_letters`
- **Kind:** `helper`
- **Semantic meaning / contract:** Normalize relevant text characters and
  return their unique ASCII letter values without mutating the input.
- **Canonical shape:** `text -> normalized characters -> set[str]`
- **Minimal example:** `collect_letters("Cab!") == {"a", "b", "c"}`
- **Boundary / misuse:** Its contract must say whether non-ASCII letters are
  ignored or merely retained; it does not preserve order or counts.
- **Underlying mechanism:** String normalization, comprehension, and `set`.
- **Algorithmic interpretation:** Projection, filtering, and deduplication.
- **Complexity, when relevant:** `O(n)` time and up to `O(k)` unique-letter
  storage.
- **Helper projection:** This is already a concrete `verb_noun` helper.
- **Domain projection, when relevant:** `collect_observed_capabilities`
- **Evaluation slice:** Pangram

### `parse_words`

- **Name:** `parse_words`
- **Kind:** `helper`
- **Semantic meaning / contract:** Convert input text into normalized word
  tokens according to an explicit punctuation and apostrophe policy.
- **Canonical shape:** `text -> recognized spans -> normalized list[str]`
- **Minimal example:** `parse_words("One, two") == ["one", "two"]`
- **Boundary / misuse:** Token grammar is the contract; it should not be hidden
  inside an unexplained regex.
- **Underlying mechanism:** String operations or `re.finditer`.
- **Algorithmic interpretation:** Tokenization and canonicalization.
- **Complexity, when relevant:** Usually `O(n)` time plus token storage.
- **Helper projection:** This is the parsing half of `count_words`.
- **Domain projection, when relevant:** `parse_event_tokens`
- **Evaluation slice:** Word Count

### `count_words`

- **Name:** `count_words`
- **Kind:** `helper`
- **Semantic meaning / contract:** Return a frequency mapping for the normalized
  tokens produced from text.
- **Canonical shape:** `text -> parse_words -> mapping[str, int]`
- **Minimal example:** `count_words("red red blue") == {"red": 2, "blue": 1}`
- **Boundary / misuse:** Keep token recognition separate enough that counting
  policy and parsing policy can be stated independently.
- **Underlying mechanism:** Dictionary accumulation or `Counter`.
- **Algorithmic interpretation:** Parse followed by frequency reduction.
- **Complexity, when relevant:** Expected `O(n)` over input and tokens.
- **Helper projection:** Compose `parse_words` with a counting primitive.
- **Domain projection, when relevant:** `count_diagnostics`
- **Evaluation slice:** Word Count

### `select_items`

- **Name:** `select_items`
- **Kind:** `helper`
- **Semantic meaning / contract:** Return items that satisfy a supplied
  predicate while preserving encounter order and leaving the input unchanged.
- **Canonical shape:** `items + predicate -> selected list`
- **Minimal example:** `select_items([1, 2, 3], is_even) == [2]`
- **Boundary / misuse:** Do not generalize it into a shared utility merely
  because other slices contain filters; specify lazy versus concrete output.
- **Underlying mechanism:** Function-as-value plus iteration or comprehension.
- **Algorithmic interpretation:** Stable selection.
- **Complexity, when relevant:** `O(n)` predicate calls and selected-output
  storage.
- **Helper projection:** Configure complementary behavior locally for keep and
  discard only when that makes their contracts clearer.
- **Domain projection, when relevant:** `select_errors`
- **Evaluation slice:** Strain

### `group_students`

- **Name:** `group_students`
- **Kind:** `helper`
- **Semantic meaning / contract:** Build a grade-keyed collection from student
  records under an explicit duplicate policy.
- **Canonical shape:** `student records -> grade key -> grouped index`
- **Minimal example:** `[("Ada", 2), ("Lin", 1)] -> {1: ["Lin"], 2: ["Ada"]}`
- **Boundary / misuse:** Group construction should not accidentally expose the
  class's mutable internal containers.
- **Underlying mechanism:** Dictionary accumulation or `defaultdict`.
- **Algorithmic interpretation:** Grouped indexing.
- **Complexity, when relevant:** Expected `O(n)` before ordering.
- **Helper projection:** Keep it slice-local and separate from retained school
  state when useful.
- **Domain projection, when relevant:** `group_results_by_probe`
- **Evaluation slice:** Grade School

### `rank_students`

- **Name:** `rank_students`
- **Kind:** `helper`
- **Semantic meaning / contract:** Return student names ordered by grade and
  then name without mutating the underlying roster.
- **Canonical shape:** `grouped students -> (grade, name) key -> ordered names`
- **Minimal example:** `[(2, "Zoe"), (1, "Ada")] -> ["Ada", "Zoe"]`
- **Boundary / misuse:** Sorting an internal list in place can make a query
  mutate state; return a fresh ordered value when that is the contract.
- **Underlying mechanism:** Stable `sorted(key=...)` and projection.
- **Algorithmic interpretation:** Lexicographic ranking.
- **Complexity, when relevant:** `O(n log n)` for a full roster.
- **Helper projection:** Compose grouping state with a pure ordering query.
- **Domain projection, when relevant:** `rank_diagnoses`
- **Evaluation slice:** Grade School

### `encode_run`

- **Name:** `encode_run`
- **Kind:** `helper`
- **Semantic meaning / contract:** Convert one value and its positive run length
  into the exercise's compact text representation.
- **Canonical shape:** `count + value -> encoded fragment`
- **Minimal example:** `encode_run(3, "A") == "3A"`
- **Boundary / misuse:** State how a count of one is represented and whether
  zero, negative counts, or digit values are admitted.
- **Underlying mechanism:** Conditional formatting and text construction.
- **Algorithmic interpretation:** Single-frame serialization.
- **Complexity, when relevant:** Proportional to the fragment length.
- **Helper projection:** Join encoded fragments in `encode_runs`.
- **Domain projection, when relevant:** `encode_event_frame`
- **Evaluation slice:** Run-Length Encoding

### `decode_runs`

- **Name:** `decode_runs`
- **Kind:** `helper`
- **Semantic meaning / contract:** Parse encoded run frames and reconstruct the
  represented text under an explicit grammar.
- **Canonical shape:** `encoded text -> parsed count/value frames -> text`
- **Minimal example:** `decode_runs("3A2B") == "AAABB"`
- **Boundary / misuse:** Invalid-frame and literal-digit behavior must be
  defined rather than inferred from a permissive implementation.
- **Underlying mechanism:** Sequential parsing or `re.finditer`, repetition,
  and joining.
- **Algorithmic interpretation:** Framed parsing and expansion.
- **Complexity, when relevant:** Linear in encoded input plus decoded output.
- **Helper projection:** Pair with `encode_run`/`encode_runs` for a round-trip
  contract.
- **Domain projection, when relevant:** `decode_stream_frames`
- **Evaluation slice:** Run-Length Encoding
