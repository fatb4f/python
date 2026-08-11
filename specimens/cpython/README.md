# CPython seam specimens

This learner-owned area is for occasional, small reconstructions of CPython's
library/CLI boundaries. CPython remains a reference corpus rather than the main
workload.

Begin with tiny `Lib/*/__main__.py` seams, then progress through `json.tool`,
`py_compile.main`, `zipapp.main`, `Tools/build/update_file.py`, and minimal
subprocess observation. For large modules, study only the CLI/library seam.

Place each reconstruction under `specimens/cpython/<seam>/` and its behavioral
tests under `tests/specimens/<seam>/`. Prefer this learner-facing entry point:

```python
def main(argv: list[str] | None = None) -> int:
    ...
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

Do not add controller, worker, scheduler, or `libregrtest` infrastructure here.
