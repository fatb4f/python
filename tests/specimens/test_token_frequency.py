from collections import Counter

from specimens.semantics.token_frequency import count_tokens, tokenize


def test_empty_text_has_no_tokens() -> None:
    assert count_tokens("") == Counter()


def test_tokens_are_case_folded_and_counted() -> None:
    assert count_tokens("Straße STRASSE") == Counter({"strasse": 2})


def test_surrounding_punctuation_is_a_boundary() -> None:
    assert list(tokenize("hello,world...again")) == ["hello", "world", "again"]


def test_one_internal_apostrophe_is_preserved() -> None:
    assert list(tokenize("don't 'quote' rock'n'roll")) == [
        "don't",
        "quote",
        "rock'n",
        "roll",
    ]


def test_digits_are_content_and_underscores_are_boundaries() -> None:
    assert count_tokens("api2_api2 v1") == Counter({"api2": 2, "v1": 1})


def test_unicode_alphanumeric_tokens_are_preserved() -> None:
    assert list(tokenize("naïve 東京 １２")) == ["naïve", "東京", "１２"]
