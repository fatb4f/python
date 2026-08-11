# Learner-authored Exercism tests

Add tests here only when they contribute information that the supplied Exercism
suite does not already express. Useful additions include boundary cases, invalid
inputs, uncovered equivalence classes, regressions, and metamorphic relationships.

Use one directory per exercise slug:

```text
tests/exercism/<slug>/test_<subject>.py
```

Import the exercise module exactly as the supplied suite does. The repository
runner executes these tests from the matching exercise directory, so no path
manipulation or custom import fixture is needed.

Run the supplied and learner-authored tests together with:

```sh
just test <slug>
```
