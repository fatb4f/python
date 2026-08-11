#!/usr/bin/env python3
"""Inspect, validate, run, and track the standalone Python curriculum."""
from __future__ import annotations

import argparse
import hashlib
import json
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SEQUENCE_PATH = ROOT / "curriculum" / "sequence.json"
MANIFEST_PATH = ROOT / "curriculum" / "source-manifest.json"
DEFAULT_PROGRESS = ROOT / ".learning-progress.json"
LEARNER_TESTS_ROOT = ROOT / "tests" / "exercism"
CORE_TIERS = {"core"}


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"missing file: {path}") from exc
    except json.JSONDecodeError as exc:
        raise SystemExit(f"invalid JSON in {path}: {exc}") from exc


def load_sequence() -> dict[str, Any]:
    return load_json(SEQUENCE_PATH)


def load_progress(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {"schema": "python.progress.v1", "completed": []}
    data = load_json(path)
    if not isinstance(data.get("completed"), list):
        raise SystemExit(f"invalid progress file: {path}")
    return data


def save_progress(path: Path, progress: dict[str, Any]) -> None:
    path.write_text(json.dumps(progress, indent=2) + "\n", encoding="utf-8")


def all_items(sequence: dict[str, Any], include_all: bool = True) -> list[dict[str, Any]]:
    items = [item for stage in sequence["stages"] for item in stage["items"]]
    return items if include_all else [item for item in items if item["tier"] in CORE_TIERS]


def resolve_item(sequence: dict[str, Any], token: str) -> dict[str, Any]:
    items = all_items(sequence)
    exact = [item for item in items if item["id"] == token]
    if exact:
        return exact[0]
    matches = [item for item in items if item["slug"] == token]
    if len(matches) == 1:
        return matches[0]
    if not matches:
        raise SystemExit(f"unknown curriculum item: {token}")
    raise SystemExit("ambiguous slug; use one of: " + ", ".join(i["id"] for i in matches))


def item_label(item: dict[str, Any]) -> str:
    difficulty = f" d{item['difficulty']}" if "difficulty" in item else ""
    return f"{item['id']} [{item['tier']}{difficulty}] -> {item['path']}"


def hash_tree(path: Path, excluded: set[str] | None = None) -> str:
    excluded = excluded or set()
    digest = hashlib.sha256()
    for file in sorted(p for p in path.rglob("*") if p.is_file()):
        rel = file.relative_to(path).as_posix()
        if rel in excluded:
            continue
        digest.update(rel.encode())
        digest.update(b"\0")
        digest.update(file.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def command_verify(sequence: dict[str, Any]) -> int:
    manifest = load_json(MANIFEST_PATH)
    items = all_items(sequence)
    ids = [item["id"] for item in items]
    paths = [item["path"] for item in items]
    failures: list[str] = []

    if len(ids) != len(set(ids)):
        failures.append("duplicate curriculum item IDs")
    if len(paths) != len(set(paths)):
        failures.append("duplicate curriculum paths")

    manifest_by_id = {entry["id"]: entry for entry in manifest["entries"]}
    if set(ids) != set(manifest_by_id):
        failures.append("sequence and source manifest item sets differ")

    for item in items:
        path = ROOT / item["path"]
        if not path.is_dir():
            failures.append(f"missing item path: {item['path']}")
            continue
        entry = manifest_by_id[item["id"]]
        mutable = set(entry.get("mutable", []))
        for rel in mutable:
            if not (path / rel).is_file():
                failures.append(f"missing solution file: {item['id']}:{rel}")
        actual_immutable_files = sum(
            1 for p in path.rglob("*")
            if p.is_file() and p.relative_to(path).as_posix() not in mutable
        )
        if actual_immutable_files != entry["immutable_files"]:
            failures.append(f"immutable file count drift: {item['id']}")
        if hash_tree(path, mutable) != entry["sha256"]:
            failures.append(f"immutable content drift: {item['id']}")

    stage_for_concept = {
        item["slug"]: int(stage["id"])
        for stage in sequence["stages"]
        for item in stage["concepts"]
    }
    stage_for_concept["comprehensions"] = 4
    for stage in sequence["stages"]:
        stage_num = int(stage["id"])
        for item in stage["concept_exercises"] + stage["practice_exercises"]:
            refs = item.get("concepts", []) + item.get("practices", []) + item.get("prerequisites", [])
            late = sorted(ref for ref in refs if stage_for_concept.get(ref, -1) > stage_num)
            if late:
                failures.append(f"{item['id']} appears before concepts {late}")

    if failures:
        print("verification failed:", *failures, sep="\n- ", file=sys.stderr)
        return 1
    counts = manifest["included"]
    core = len(all_items(sequence, include_all=False))
    print(
        f"ok: {counts['concepts']} concepts, {counts['concept_exercises']} concept exercises, "
        f"{counts['practice_exercises']} practice exercises; {core} core items"
    )
    return 0


def command_list(sequence: dict[str, Any], stage_filter: str | None, include_all: bool) -> int:
    for stage in sequence["stages"]:
        if stage_filter and stage_filter not in {stage["id"], stage["slug"]}:
            continue
        print(f"\n{stage['id']} {stage['name']}")
        for item in stage["items"]:
            if include_all or item["tier"] in CORE_TIERS:
                print("  " + item_label(item))
    return 0


def command_next(sequence: dict[str, Any], progress_path: Path, include_all: bool) -> int:
    completed = set(load_progress(progress_path)["completed"])
    for item in all_items(sequence, include_all):
        if item["id"] not in completed:
            print(item_label(item))
            return 0
    print("curriculum complete")
    return 0


def command_show(sequence: dict[str, Any], token: str) -> int:
    item = resolve_item(sequence, token)
    print(json.dumps(item, indent=2))
    return 0


def command_mark(sequence: dict[str, Any], progress_path: Path, token: str, undo: bool) -> int:
    item = resolve_item(sequence, token)
    progress = load_progress(progress_path)
    completed = set(progress["completed"])
    (completed.discard if undo else completed.add)(item["id"])
    progress["completed"] = sorted(completed)
    save_progress(progress_path, progress)
    print(f"{'unmarked' if undo else 'completed'}: {item['id']}")
    return 0


def command_status(sequence: dict[str, Any], progress_path: Path, include_all: bool) -> int:
    completed = set(load_progress(progress_path)["completed"])
    items = all_items(sequence, include_all)
    done = sum(item["id"] in completed for item in items)
    print(f"{done}/{len(items)} complete ({100 * done / len(items) if items else 100:.1f}%)")
    for stage in sequence["stages"]:
        stage_items = [i for i in stage["items"] if include_all or i["tier"] in CORE_TIERS]
        stage_done = sum(i["id"] in completed for i in stage_items)
        print(f"{stage['id']} {stage_done}/{len(stage_items)} {stage['name']}")
    return 0


def is_test_file(path: Path) -> bool:
    return path.suffix == ".py" and (
        path.name.startswith("test_") or path.name.endswith("_test.py")
    )


def exercise_items(sequence: dict[str, Any]) -> list[dict[str, Any]]:
    return [item for item in all_items(sequence) if item["kind"] != "concept"]


def learner_test_paths(item: dict[str, Any]) -> list[Path]:
    directory = LEARNER_TESTS_ROOT / item["slug"]
    if not directory.is_dir():
        return []
    return sorted(path for path in directory.glob("*.py") if is_test_file(path))


def exercise_for_path(sequence: dict[str, Any], path: Path) -> dict[str, Any] | None:
    resolved = path.resolve()
    for item in exercise_items(sequence):
        exercise_path = (ROOT / item["path"]).resolve()
        learner_path = (LEARNER_TESTS_ROOT / item["slug"]).resolve()
        if resolved.is_relative_to(exercise_path) or resolved.is_relative_to(learner_path):
            return item
    return None


def resolve_test_path(token: str) -> Path:
    path = Path(token)
    resolved = (path if path.is_absolute() else ROOT / path).resolve()
    if not resolved.is_relative_to(ROOT):
        raise SystemExit(f"test path is outside the repository: {token}")
    if not resolved.is_file():
        raise SystemExit(f"test file does not exist: {token}")
    if not is_test_file(resolved):
        raise SystemExit(f"not a pytest test file: {token}")
    return resolved


def run_pytest(cwd: Path, targets: list[str], pytest_args: list[str]) -> int:
    command = [sys.executable, "-m", "pytest", *targets, *pytest_args]
    print("$", shlex.join(command), flush=True)
    return subprocess.call(command, cwd=cwd)


def command_test(sequence: dict[str, Any], token: str, pytest_args: list[str]) -> int:
    item = resolve_item(sequence, token)
    if item["kind"] == "concept":
        raise SystemExit("concept documents do not have tests")
    path = ROOT / item["path"]
    tests = sorted(path.glob("*_test.py")) + learner_test_paths(item)
    if not tests:
        raise SystemExit(f"no test module found in {path}")
    return run_pytest(path, [str(test) for test in tests], pytest_args)


def command_test_file(sequence: dict[str, Any], token: str, pytest_args: list[str]) -> int:
    test_path = resolve_test_path(token)
    item = exercise_for_path(sequence, test_path)
    cwd = ROOT / item["path"] if item else ROOT
    return run_pytest(cwd, [str(test_path)], pytest_args)


def command_test_node(sequence: dict[str, Any], token: str, pytest_args: list[str]) -> int:
    path_token, separator, node_suffix = token.partition("::")
    if not separator or not node_suffix:
        raise SystemExit("test node must include a file and ::node suffix")
    test_path = resolve_test_path(path_token)
    item = exercise_for_path(sequence, test_path)
    cwd = ROOT / item["path"] if item else ROOT
    return run_pytest(cwd, [f"{test_path}::{node_suffix}"], pytest_args)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--progress", type=Path, default=DEFAULT_PROGRESS)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("verify")
    listing = sub.add_parser("list")
    listing.add_argument("--stage")
    listing.add_argument("--all", action="store_true", dest="include_all")
    nxt = sub.add_parser("next")
    nxt.add_argument("--all", action="store_true", dest="include_all")
    show = sub.add_parser("show")
    show.add_argument("item")
    mark = sub.add_parser("mark")
    mark.add_argument("item")
    mark.add_argument("--undo", action="store_true")
    status = sub.add_parser("status")
    status.add_argument("--all", action="store_true", dest="include_all")
    test = sub.add_parser("test")
    test.add_argument("item")
    test.add_argument("pytest_args", nargs=argparse.REMAINDER)
    test_file = sub.add_parser("test-file")
    test_file.add_argument("path")
    test_file.add_argument("pytest_args", nargs=argparse.REMAINDER)
    test_node = sub.add_parser("test-node")
    test_node.add_argument("node")
    test_node.add_argument("pytest_args", nargs=argparse.REMAINDER)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    sequence = load_sequence()
    if args.command == "verify":
        return command_verify(sequence)
    if args.command == "list":
        return command_list(sequence, args.stage, args.include_all)
    if args.command == "next":
        return command_next(sequence, args.progress, args.include_all)
    if args.command == "show":
        return command_show(sequence, args.item)
    if args.command == "mark":
        return command_mark(sequence, args.progress, args.item, args.undo)
    if args.command == "status":
        return command_status(sequence, args.progress, args.include_all)
    if args.command == "test":
        return command_test(sequence, args.item, args.pytest_args)
    if args.command == "test-file":
        return command_test_file(sequence, args.path, args.pytest_args)
    if args.command == "test-node":
        return command_test_node(sequence, args.node, args.pytest_args)
    raise AssertionError(args.command)


if __name__ == "__main__":
    raise SystemExit(main())
