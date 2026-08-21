#!/usr/bin/env python3
"""Record lightweight PR command timings and summarize their budget status."""

from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
import time
from pathlib import Path
from typing import Sequence


def percentile(samples: Sequence[float], rank: int) -> float:
    """Return the nearest-rank percentile for non-empty samples."""

    if not samples:
        raise ValueError("percentile requires at least one sample")
    if not 1 <= rank <= 100:
        raise ValueError("percentile rank must be between 1 and 100")
    ordered = sorted(samples)
    return ordered[math.ceil(rank * len(ordered) / 100) - 1]


def summarize(samples: Sequence[float], budget_seconds: float) -> dict[str, object]:
    """Return the exact timing summary consumed by CI and later evidence tasks."""

    return {
        "budget_seconds": budget_seconds,
        "p50_seconds": percentile(samples, 50),
        "p95_seconds": percentile(samples, 95),
        "sample_count": len(samples),
        "within_budget": percentile(samples, 95) <= budget_seconds,
    }


def summarize_records(
    records: Sequence[dict[str, object]], budget_seconds: float
) -> dict[str, object]:
    """Summarize one comparable critical-path sample per hosted run."""

    if not records or any(record.get("record_type") != "run" for record in records):
        raise ValueError("timing summaries accept only run records")
    durations_by_run: dict[str, dict[str, float]] = {}
    expected_workers = {"source-contract", "tooling-tests"}
    for record in records:
        run_id = record.get("run_id")
        worker = record.get("worker")
        duration = record.get("duration_seconds")
        if (
            not isinstance(run_id, str)
            or not run_id
            or worker not in expected_workers
            or not isinstance(duration, (int, float))
            or isinstance(duration, bool)
            or duration < 0
        ):
            raise ValueError("malformed run timing record")
        workers = durations_by_run.setdefault(run_id, {})
        if worker in workers:
            raise ValueError(f"duplicate {worker} timing for run {run_id}")
        workers[str(worker)] = float(duration)
    samples: list[float] = []
    for run_id, workers in durations_by_run.items():
        if set(workers) != expected_workers:
            raise ValueError(f"run {run_id} does not contain both worker timings")
        samples.append(max(workers.values()))
    return summarize(samples, budget_seconds)


def _write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _run_command(command: Sequence[str], output: Path) -> int:
    started = time.monotonic()
    try:
        result = subprocess.run(command, check=False)
        exit_code = result.returncode
        failure_category = "none" if exit_code == 0 else "command"
    except OSError as error:
        print(f"pr_timing.py: {error}", file=sys.stderr)
        exit_code = 127
        failure_category = "launch"
    elapsed = round(time.monotonic() - started, 3)
    _write_json(
        output,
        {
            "command": list(command),
            "duration_seconds": elapsed,
            "exit_code": exit_code,
            "failure_category": failure_category,
            "record_type": "command",
        },
    )
    return exit_code if exit_code >= 0 else 128 - exit_code


def _timing_files(inputs: Sequence[Path]) -> list[Path]:
    files: list[Path] = []
    for path in inputs:
        if path.is_dir():
            files.extend(sorted(path.rglob("*.json")))
        else:
            files.append(path)
    return files


def _summarize_files(
    inputs: Sequence[Path],
    budget_seconds: float,
    output: Path,
    markdown_output: Path | None,
) -> int:
    records = [
        json.loads(path.read_text(encoding="utf-8"))
        for path in _timing_files(inputs)
    ]
    summary = summarize_records(records, budget_seconds)
    _write_json(output, summary)
    if markdown_output is not None:
        with markdown_output.open("a", encoding="utf-8") as stream:
            stream.write("## Pull-request timing\n\n")
            stream.write(f"- Samples: {summary['sample_count']}\n")
            stream.write(f"- P50: {summary['p50_seconds']} seconds\n")
            stream.write(f"- P95: {summary['p95_seconds']} seconds\n")
            stream.write(f"- Budget: {summary['budget_seconds']} seconds\n")
            stream.write(f"- Within budget: {str(summary['within_budget']).lower()}\n")
            stream.write("- Enforcement: observational for the first 10 hosted runs\n")
    return 0


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="operation", required=True)

    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("--output", type=Path, required=True)
    run_parser.add_argument("command", nargs=argparse.REMAINDER)

    start_parser = subparsers.add_parser("start")
    start_parser.add_argument("--output", type=Path, required=True)

    finish_parser = subparsers.add_parser("finish")
    finish_parser.add_argument("--start", type=Path, required=True)
    finish_parser.add_argument("--output", type=Path, required=True)
    finish_parser.add_argument("--run-id", required=True)
    finish_parser.add_argument(
        "--worker", choices=("source-contract", "tooling-tests"), required=True
    )

    summary_parser = subparsers.add_parser("summary")
    summary_parser.add_argument("--input", type=Path, nargs="+", required=True)
    summary_parser.add_argument("--budget-seconds", type=float, required=True)
    summary_parser.add_argument("--output", type=Path, required=True)
    summary_parser.add_argument("--markdown-output", type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.operation == "run":
        command = args.command[1:] if args.command[:1] == ["--"] else args.command
        if not command:
            raise SystemExit("pr_timing.py run requires a command after --")
        return _run_command(command, args.output)
    if args.operation == "start":
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(f"{time.monotonic()}\n", encoding="utf-8")
        return 0
    if args.operation == "finish":
        started = float(args.start.read_text(encoding="utf-8"))
        _write_json(
            args.output,
            {
                "duration_seconds": round(time.monotonic() - started, 3),
                "record_type": "run",
                "run_id": args.run_id,
                "worker": args.worker,
            },
        )
        return 0
    return _summarize_files(
        args.input,
        args.budget_seconds,
        args.output,
        args.markdown_output,
    )


if __name__ == "__main__":
    raise SystemExit(main())
