"""Cross between digit-free source text and canonical run-length text.

DATA: ordered source symbols and an encoded frame representation.
RULE: source symbols cannot be digits; encoded digits are counts of at least two.
OPERATION: encode adjacent runs and decode frames.
BOUNDARY: source and encoded grammars are distinct and validated explicitly.
INVARIANT: decode(encode(value)) equals every value admitted by the source grammar.
"""

from itertools import groupby


def encode(text: str) -> str:
    """Encode digit-free source text using counts only for repeated symbols."""
    if any(character.isdigit() for character in text):
        raise ValueError("source symbols must not be digits")

    frames: list[str] = []
    for symbol, group in groupby(text):
        count = sum(1 for _ in group)
        frames.append(symbol if count == 1 else f"{count}{symbol}")
    return "".join(frames)


def decode(encoded: str) -> str:
    """Decode canonical run-length frames, rejecting malformed input."""
    symbols: list[str] = []
    index = 0

    while index < len(encoded):
        character = encoded[index]

        if character.isdigit() and not character.isascii():
            raise ValueError("encoded counts must use ASCII digits")

        if character.isascii() and character.isdigit():
            count_start = index
            while (
                index < len(encoded)
                and encoded[index].isascii()
                and encoded[index].isdigit()
            ):
                index += 1

            if index == len(encoded):
                raise ValueError("encoded count must be followed by a symbol")

            count = int(encoded[count_start:index])
            if count < 2:
                raise ValueError("encoded counts must be at least two")

            symbol = encoded[index]
            if symbol.isdigit():
                raise ValueError("encoded symbols must not be digits")
            symbols.append(symbol * count)
            index += 1
            continue

        symbols.append(character)
        index += 1

    return "".join(symbols)
