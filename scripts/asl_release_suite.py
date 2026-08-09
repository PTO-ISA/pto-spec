#!/usr/bin/env python3
"""Run and aggregate the exact independent-ASL release matrix."""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Callable, Mapping, Sequence

from scripts.asl_tests import _repository, matrix, validate_test_coverage


MatrixEntry = Mapping[str, object]
Result = Mapping[str, object]
Runner = Callable[[list[str], Path], int]


def require_exact_head(requested: str, actual: str, status: str) -> None:
    if requested != actual:
        raise ValueError(
            f"requested release commit {requested} is not exact HEAD {actual}"
        )
    if status:
        raise ValueError(
            "exact-head release verification requires a clean committed tree:\n"
            f"{status.rstrip()}"
        )


def _matrix_by_id(entries: Sequence[MatrixEntry]) -> dict[str, MatrixEntry]:
    planned: dict[str, MatrixEntry] = {}
    for entry in entries:
        test_id = entry.get("id")
        if not isinstance(test_id, str) or not test_id:
            raise ValueError("planned matrix contains an invalid test ID")
        if test_id in planned:
            raise ValueError(f"planned matrix contains duplicate ID {test_id}")
        planned[test_id] = entry
    if not planned:
        raise ValueError("planned matrix is empty")
    return planned


def aggregate_results(
    commit: str,
    entries: Sequence[MatrixEntry],
    results: Sequence[Result],
) -> dict[str, object]:
    """Require exact set/hash/pass equality and return deterministic coverage."""

    planned = _matrix_by_id(entries)
    observed: dict[str, Result] = {}
    for result in results:
        test_id = result.get("id")
        if not isinstance(test_id, str) or not test_id:
            raise ValueError("result contains an invalid test ID")
        if test_id in observed:
            raise ValueError(f"duplicate result for {test_id}")
        if test_id not in planned:
            raise ValueError(f"unplanned result for {test_id}")
        observed[test_id] = result
    missing = sorted(set(planned) - set(observed))
    if missing:
        raise ValueError(f"missing result for {', '.join(missing)}")

    rows: list[dict[str, str]] = []
    for test_id, entry in sorted(planned.items()):
        result = observed[test_id]
        if result.get("path") != entry.get("path"):
            raise ValueError(f"path mismatch for {test_id}")
        if result.get("sha256") != entry.get("sha256"):
            raise ValueError(f"hash mismatch for {test_id}")
        for field in ("display_name", "source", "kind"):
            if result.get(field) != entry.get(field):
                raise ValueError(f"{field} mismatch for {test_id}")
        if result.get("status") != "passed":
            raise ValueError(
                f"result did not pass for {test_id}: {result.get('status')}"
            )
        rows.append(
            {
                "id": test_id,
                "path": str(entry["path"]),
                "sha256": str(entry["sha256"]),
                "status": "passed",
            }
        )
    return {
        "schema": "pto.asl-test-coverage.v1",
        "commit": commit,
        "status": "passed",
        "test_count": len(rows),
        "passed_count": len(rows),
        "results": rows,
    }


def _default_runner(command: list[str], cwd: Path) -> int:
    return subprocess.run(command, cwd=cwd, check=False).returncode


def execute_matrix(
    root: Path,
    entries: Sequence[MatrixEntry],
    *,
    jobs: int,
    runner: Runner = _default_runner,
) -> list[dict[str, object]]:
    """Execute each ID independently and load exactly one result per invocation."""

    if jobs <= 0:
        raise ValueError("jobs must be positive")
    result_root = root / "build/asl-test-results"
    if result_root.exists():
        shutil.rmtree(result_root)
    result_root.mkdir(parents=True)

    planned = _matrix_by_id(entries)

    def run_one(test_id: str) -> int:
        command = [str(root / "scripts/run-asl-test"), "--id", test_id]
        return runner(command, root)

    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        returncodes = dict(zip(planned, pool.map(run_one, planned), strict=True))

    loaded: list[dict[str, object]] = []
    for test_id in planned:
        path = result_root / test_id / "result.json"
        if not path.is_file():
            if returncodes[test_id] != 0:
                continue
            raise ValueError(f"runner returned success without result for {test_id}")
        value = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(value, dict):
            raise ValueError(f"result for {test_id} is not a JSON object")
        loaded.append(value)
    return loaded


def load_matrix_pages(directory: Path, commit: str) -> list[dict[str, object]]:
    def page_number(path: Path) -> int:
        try:
            return int(path.stem.removeprefix("page-"))
        except ValueError as error:
            raise ValueError(f"invalid planned matrix page name: {path}") from error

    paths = sorted(directory.glob("page-*.json"), key=page_number)
    if not paths:
        raise ValueError(f"no planned matrix pages found below {directory}")
    entries: list[dict[str, object]] = []
    expected_count: int | None = None
    expected_pages = list(range(len(paths)))
    observed_pages: list[int] = []
    for path in paths:
        value = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(value, dict) or value.get("commit") != commit:
            raise ValueError(f"planned matrix page has wrong commit: {path}")
        page = value.get("page")
        page_count = value.get("page_count")
        test_count = value.get("test_count")
        include = value.get("include")
        if not isinstance(page, int) or page_count != len(paths):
            raise ValueError(f"planned matrix page numbering mismatch: {path}")
        if not isinstance(test_count, int) or not isinstance(include, list):
            raise ValueError(f"planned matrix page schema mismatch: {path}")
        if expected_count is None:
            expected_count = test_count
        elif expected_count != test_count:
            raise ValueError("planned matrix pages disagree on test_count")
        if any(not isinstance(entry, dict) for entry in include):
            raise ValueError(f"planned matrix page contains a non-object entry: {path}")
        observed_pages.append(page)
        entries.extend(include)
    if sorted(observed_pages) != expected_pages:
        raise ValueError("planned matrix pages are missing or duplicated")
    if expected_count != len(entries):
        raise ValueError("planned matrix pages do not contain the declared test set")
    _matrix_by_id(entries)
    return entries


def load_results(directory: Path) -> list[dict[str, object]]:
    values: list[dict[str, object]] = []
    for path in sorted(directory.rglob("result.json")):
        value = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(value, dict):
            raise ValueError(f"result is not a JSON object: {path}")
        values.append(value)
    return values


def load_matrix_page(path: Path, commit: str) -> tuple[int, list[dict[str, object]]]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict) or value.get("commit") != commit:
        raise ValueError(f"planned matrix page has wrong commit: {path}")
    page = value.get("page")
    include = value.get("include")
    if not isinstance(page, int) or not isinstance(include, list):
        raise ValueError(f"planned matrix page schema mismatch: {path}")
    if any(not isinstance(entry, dict) for entry in include):
        raise ValueError(f"planned matrix page contains a non-object entry: {path}")
    entries = list(include)
    _matrix_by_id(entries)
    return page, entries


def _matrix_document(commit: str, entries: Sequence[MatrixEntry]) -> bytes:
    document = {
        "commit": commit,
        "page": 0,
        "page_count": 1,
        "test_count": len(entries),
        "include": list(entries),
    }
    return (json.dumps(document, separators=(",", ":"), sort_keys=True) + "\n").encode()


def _write_evidence(
    root: Path,
    entries: Sequence[MatrixEntry],
    coverage: Mapping[str, object],
) -> None:
    build = root / "build"
    build.mkdir(parents=True, exist_ok=True)
    matrix_bytes = _matrix_document(str(coverage["commit"]), entries)
    matrix_path = build / "asl-test-matrix.json"
    matrix_path.write_bytes(matrix_bytes)
    (build / "asl-test-coverage.json").write_text(
        json.dumps(coverage, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    evidence = root / "spec/evidence/asl-test-matrix.sha256"
    evidence.parent.mkdir(parents=True, exist_ok=True)
    evidence.write_text(
        f"{hashlib.sha256(matrix_bytes).hexdigest()}  build/asl-test-matrix.json\n",
        encoding="utf-8",
    )


def page_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument(
        "-j",
        "--jobs",
        type=int,
        default=int(
            os.environ.get("PTO_ASL_TEST_JOBS", str(os.cpu_count() or 1))
        ),
    )
    arguments = parser.parse_args(argv)
    root = arguments.root.resolve()
    if arguments.jobs <= 0:
        print("error: jobs must be positive", file=sys.stderr)
        return 2
    try:
        actual = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()
        page, entries = load_matrix_page(arguments.matrix.resolve(), actual)
        results = execute_matrix(root, entries, jobs=arguments.jobs)
        coverage = aggregate_results(actual, entries, results)
    except (
        OSError,
        ValueError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(
        f"ASL page {page} passed: {coverage['test_count']} independent points "
        f"with -j {arguments.jobs}"
    )
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--commit", required=True)
    parser.add_argument(
        "--jobs",
        type=int,
        default=int(
            os.environ.get("PTO_ASL_TEST_JOBS", str(os.cpu_count() or 1))
        ),
    )
    parser.add_argument("--aggregate-only", action="store_true")
    parser.add_argument("--matrix-pages", type=Path)
    parser.add_argument("--results", type=Path)
    arguments = parser.parse_args(argv)
    root = arguments.root.resolve()
    try:
        actual = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=root,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()
        status = subprocess.run(
            ["git", "status", "--porcelain=v1", "--untracked-files=all"],
            cwd=root,
            text=True,
            capture_output=True,
            check=True,
        ).stdout
        require_exact_head(arguments.commit, actual, status)
        if arguments.aggregate_only:
            if arguments.matrix_pages is None or arguments.results is None:
                raise ValueError(
                    "--aggregate-only requires --matrix-pages and --results"
                )
            entries = load_matrix_pages(
                (root / arguments.matrix_pages).resolve(), actual
            )
            results = load_results((root / arguments.results).resolve())
        else:
            units, points, requirements = _repository(root)
            coverage_errors = validate_test_coverage(points, units, requirements)
            if coverage_errors:
                raise ValueError("\n".join(coverage_errors))
            entries = matrix(points)
            results = execute_matrix(root, entries, jobs=arguments.jobs)
        coverage = aggregate_results(actual, entries, results)
        _write_evidence(root, entries, coverage)
        generated = subprocess.run(
            [str(root / "scripts/generate-release-manifest")],
            cwd=root,
            check=False,
        )
        if generated.returncode != 0:
            raise ValueError("release manifest generation failed")
    except (
        OSError,
        ValueError,
        json.JSONDecodeError,
        subprocess.CalledProcessError,
    ) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(
        f"ASL release suite passed: {coverage['test_count']} independent points at {actual}"
    )
    return 0
