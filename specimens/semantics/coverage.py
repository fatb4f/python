"""Decide whether observed values cover a required set.

DATA: required unique strings and observed strings.
RULE: every required value must occur; order and multiplicity are irrelevant.
OPERATION: decide whether the coverage rule holds.
REPRESENTATION: materialize observations as a set for a subset comparison.
This is one transparent realization of the contract, not a canonical solution.
"""

from collections.abc import Iterable, Set


def covers_required(required: Set[str], observed: Iterable[str]) -> bool:
    """Return whether every required value occurs among the observations."""
    return required <= set(observed)
