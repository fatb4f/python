python := "uv run --frozen --no-sync python"

sync:
    uv sync --locked

test *args:
    {{python}} -m pytest tests {{args}}
