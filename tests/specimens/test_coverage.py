from specimens.semantics.coverage import covers_required


def test_complete_coverage() -> None:
    assert covers_required({"a", "b"}, ["b", "a"])


def test_incomplete_coverage() -> None:
    assert not covers_required({"a", "b"}, ["a"])


def test_order_and_multiplicity_are_irrelevant() -> None:
    required = {"a", "b"}

    assert covers_required(required, ["a", "a", "b"])
    assert covers_required(required, ["b", "a"])


def test_empty_required_set_is_covered() -> None:
    assert covers_required(set(), [])
    assert covers_required(set(), ["anything"])


def test_nonempty_required_set_is_not_covered_by_empty_observations() -> None:
    assert not covers_required({"required"}, [])
