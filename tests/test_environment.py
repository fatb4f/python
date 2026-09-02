"""Repository-level environment contracts."""


def test_rich_inspection_is_available() -> None:
    from rich import inspect as rich_inspect

    assert callable(rich_inspect)
