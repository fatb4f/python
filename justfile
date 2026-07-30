python := "python"

verify:
    {{python}} tools/path.py verify

next *args:
    {{python}} tools/path.py next {{args}}

list *args:
    {{python}} tools/path.py list {{args}}

show item:
    {{python}} tools/path.py show {{item}}

test item *args:
    {{python}} tools/path.py test {{item}} {{args}}

mark item:
    {{python}} tools/path.py mark {{item}}

status *args:
    {{python}} tools/path.py status {{args}}
