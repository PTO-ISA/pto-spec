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
from typing import Callable, Mapping, Sequence, TextIO

from scripts.asl_tests import (
    DEFAULT_TIMEOUT_SECONDS,
    EMPTY_VALIDATION_SHARD,
    AslExecutionPoint,
    PreparedAslInputs,
    _repository,
    execute_test_point,
    matrix,
    validate_test_coverage,
)
from scripts.asl_units import generate_source_order


MatrixEntry = Mapping[str, object]
Result = Mapping[str, object]
PointRunner = Callable[[AslExecutionPoint, PreparedAslInputs], int]


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
        for field in (
            "display_name",
            "source",
            "kind",
            "validation_entrypoint",
            "validation_sha256",
        ):
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


def execution_point(entry: MatrixEntry) -> AslExecutionPoint:
    """Validate and convert one exact matrix entry for direct execution."""

    required = ("id", "display_name", "path", "source", "kind", "sha256")
    values: dict[str, str] = {}
    for field in required:
        value = entry.get(field)
        if not isinstance(value, str) or not value:
            raise ValueError(f"matrix entry contains invalid {field}")
        values[field] = value
    validation_entrypoint = entry.get("validation_entrypoint")
    if validation_entrypoint is not None and (
        not isinstance(validation_entrypoint, str) or not validation_entrypoint
    ):
        raise ValueError("matrix entry contains invalid validation_entrypoint")
    validation_sha256 = entry.get("validation_sha256")
    if not isinstance(validation_sha256, str) or not validation_sha256:
        raise ValueError("matrix entry contains invalid validation_sha256")
    return AslExecutionPoint(
        test_id=values["id"],
        display_name=values["display_name"],
        path=Path(values["path"]),
        source=Path(values["source"]),
        kind=values["kind"],
        sha256=values["sha256"],
        validation_entrypoint=validation_entrypoint,
        validation_sha256=validation_sha256,
    )


def _run_checked(
    command: list[str],
    *,
    root: Path,
    timeout_seconds: int,
) -> subprocess.CompletedProcess[str]:
    completed = subprocess.run(
        command,
        cwd=root,
        text=True,
        capture_output=True,
        timeout=timeout_seconds,
        check=False,
    )
    if completed.returncode != 0:
        raise ValueError(
            f"page preparation command failed with exit {completed.returncode}: "
            + " ".join(command)
            + "\n"
            + completed.stdout
            + completed.stderr
        )
    return completed


def prepare_page_inputs(
    root: Path,
    entries: Sequence[MatrixEntry],
    *,
    timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS,
) -> PreparedAslInputs:
    """Prepare immutable decoder, model, and validation inputs once per page."""

    points = [execution_point(entry) for entry in entries]
    for point in points:
        path = root / point.path
        if not path.is_file():
            raise ValueError(f"matrix test file is missing: {point.path}")
        observed_hash = hashlib.sha256(path.read_bytes()).hexdigest()
        if observed_hash != point.sha256:
            raise ValueError(
                f"test file hash mismatch for {point.test_id}: "
                f"expected {point.sha256}, observed {observed_hash}"
            )
    shared = root / "build/asl-page-inputs"
    if shared.exists():
        shutil.rmtree(shared)
    shared.mkdir(parents=True)
    order_path = shared / "asl-source-order.txt"
    decoder_path = shared / "decoders.asl"
    model_path = shared / "pto-spec.asl"
    order_path.write_text(
        "\n".join(generate_source_order(root)) + "\n", encoding="utf-8"
    )
    decoder = _run_checked(
        [
            sys.executable,
            str(root / "scripts/generate-asl-decoders"),
            "--kind",
            "decoder",
        ],
        root=root,
        timeout_seconds=timeout_seconds,
    )
    decoder_path.write_text(decoder.stdout, encoding="utf-8")
    _run_checked(
        [
            str(root / "scripts/assemble-asl"),
            "--order",
            str(order_path),
            "--decoder",
            str(decoder_path),
            "--output",
            str(model_path),
        ],
        root=root,
        timeout_seconds=timeout_seconds,
    )

    expected_hashes: dict[str | None, str] = {}
    for point in points:
        previous = expected_hashes.setdefault(
            point.validation_entrypoint, point.validation_sha256
        )
        if previous != point.validation_sha256:
            raise ValueError(
                "matrix entries disagree on validation hash for "
                f"{point.validation_entrypoint or '<none>'}"
            )
    validation_paths: dict[str | None, Path] = {}
    for index, (entrypoint, expected_hash) in enumerate(expected_hashes.items()):
        if entrypoint is None:
            text = EMPTY_VALIDATION_SHARD
        else:
            generated = _run_checked(
                [
                    sys.executable,
                    str(root / "scripts/generate-asl-decoders"),
                    "--kind",
                    "validation-shard",
                    "--entrypoint",
                    entrypoint,
                ],
                root=root,
                timeout_seconds=timeout_seconds,
            )
            text = generated.stdout
        observed_hash = hashlib.sha256(text.encode()).hexdigest()
        if observed_hash != expected_hash:
            raise ValueError(
                "validation shard hash mismatch for "
                f"{entrypoint or '<none>'}: expected {expected_hash}, "
                f"observed {observed_hash}"
            )
        path = shared / f"validation-{index}.asl"
        path.write_text(text, encoding="utf-8")
        validation_paths[entrypoint] = path
    return PreparedAslInputs(
        model_path=model_path,
        validation_paths=validation_paths,
    )


def execute_matrix(
    root: Path,
    entries: Sequence[MatrixEntry],
    *,
    jobs: int,
    point_runner: PointRunner | None = None,
    output: TextIO = sys.stdout,
) -> list[dict[str, object]]:
    """Execute each ID independently and load exactly one result per invocation."""

    if jobs <= 0:
        raise ValueError("jobs must be positive")
    result_root = root / "build/asl-test-results"
    if result_root.exists():
        shutil.rmtree(result_root)
    result_root.mkdir(parents=True)

    planned = _matrix_by_id(entries)
    points = {test_id: execution_point(entry) for test_id, entry in planned.items()}
    prepared = prepare_page_inputs(root, entries)
    if point_runner is None:

        def point_runner(point: AslExecutionPoint, inputs: PreparedAslInputs) -> int:
            return execute_test_point(root, point, prepared=inputs)

    def run_one(test_id: str) -> int:
        assert point_runner is not None
        return point_runner(points[test_id], prepared)

    loaded: list[dict[str, object]] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        futures = {pool.submit(run_one, test_id): test_id for test_id in planned}
        completions = (
            (futures[future], future.result())
            for future in concurrent.futures.as_completed(futures)
        )
        for test_id, returncode in completions:
            entry = planned[test_id]
            path = result_root / test_id / "result.json"
            if not path.is_file():
                display_name = str(entry.get("display_name") or test_id)
                print(
                    f"FAIL {display_name} [{test_id}] missing result",
                    file=output,
                    flush=True,
                )
                if returncode == 0:
                    raise ValueError(
                        f"runner returned success without result for {test_id}"
                    )
                continue
            value = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(value, dict):
                raise ValueError(f"result for {test_id} is not a JSON object")
            status = "PASS" if value.get("status") == "passed" else "FAIL"
            display_name = str(value.get("display_name") or test_id)
            duration = value.get("duration_seconds", "-")
            print(
                f"{status} {display_name} [{test_id}] {duration}s",
                file=output,
                flush=True,
            )
            loaded.append(value)

    loaded.sort(key=lambda value: str(value.get("id", "")))
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
        default=int(os.environ.get("PTO_ASL_TEST_JOBS", str(os.cpu_count() or 1))),
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
        default=int(os.environ.get("PTO_ASL_TEST_JOBS", str(os.cpu_count() or 1))),
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
