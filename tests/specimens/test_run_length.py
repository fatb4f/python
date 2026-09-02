from itertools import product

import pytest

from specimens.semantics.run_length import decode, encode


@pytest.mark.parametrize(
    ("source", "encoded"),
    [
        ("", ""),
        ("A", "A"),
        ("AB", "AB"),
        ("AAABB", "3A2B"),
        ("  A", "2 A"),
        ("A" * 12, "12A"),
    ],
)
def test_encode_and_decode(source: str, encoded: str) -> None:
    assert encode(source) == encoded
    assert decode(encoded) == source


def test_round_trip_for_admissible_source_strings() -> None:
    alphabet = ("A", "b", " ")
    sources = (
        "".join(symbols)
        for length in range(6)
        for symbols in product(alphabet, repeat=length)
    )

    for source in sources:
        assert decode(encode(source)) == source


@pytest.mark.parametrize("source", ["1", "A2", "１２"])
def test_source_digits_are_rejected(source: str) -> None:
    with pytest.raises(ValueError, match="source symbols must not be digits"):
        encode(source)


@pytest.mark.parametrize("encoded", ["0A", "1A", "2", "１２A"])
def test_malformed_encoded_frames_are_rejected(encoded: str) -> None:
    with pytest.raises(ValueError):
        decode(encoded)
