"""Recognize normalized tokens and count their occurrences.

DATA: text crossing into normalized token values.
RULE: tokens are Unicode alphanumerics with at most one internal ASCII apostrophe.
OPERATION: recognize, case-fold, and accumulate token occurrences.
POLICY: punctuation and underscores are boundaries; digits remain token content.
REPRESENTATION: an iterator exposes recognition and Counter owns accumulation.
"""

from collections import Counter
from collections.abc import Iterator


def tokenize(text: str) -> Iterator[str]:
    """Yield case-folded tokens under the module's explicit token policy."""
    normalized = text.casefold()
    token: list[str] = []
    has_apostrophe = False

    for index, character in enumerate(normalized):
        if character.isalnum():
            token.append(character)
            continue

        next_is_alphanumeric = (
            index + 1 < len(normalized) and normalized[index + 1].isalnum()
        )
        if (
            character == "'"
            and token
            and not has_apostrophe
            and next_is_alphanumeric
        ):
            token.append(character)
            has_apostrophe = True
            continue

        if token:
            yield "".join(token)
            token.clear()
            has_apostrophe = False

    if token:
        yield "".join(token)


def count_tokens(text: str) -> Counter[str]:
    """Return occurrence counts for tokens recognized in *text*."""
    return Counter(tokenize(text))
