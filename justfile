python := "uv run --frozen --no-sync python"

sync:
    uv sync --locked

verify:
    {{python}} tools/path.py verify

next *args:
    {{python}} tools/path.py next {{args}}

list *args:
    {{python}} tools/path.py list {{args}}

show item:
    {{python}} tools/path.py show {{item}}

test item *args:
    {{python}} tools/path.py test {{quote(item)}} {{args}}

test-file path *args:
    {{python}} tools/path.py test-file {{quote(path)}} {{args}}

test-node node *args:
    {{python}} tools/path.py test-node {{quote(node)}} {{args}}

mark item:
    {{python}} tools/path.py mark {{quote(item)}}

status *args:
    {{python}} tools/path.py status {{args}}
