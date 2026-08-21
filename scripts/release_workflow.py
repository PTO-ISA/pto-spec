#!/usr/bin/env python3
"""Semantic checks for lightweight PR and exact-head release workflows."""

from __future__ import annotations

import re

from scripts.workflow_contract import (
    CACHE_ACTION_SHA,
    CHECKOUT_ACTION_SHA,
    DOWNLOAD_ARTIFACT_SHA,
    UPLOAD_ARTIFACT_SHA,
    checkout_step,
    flow_list as _flow_list,
    mapping as _mapping,
    parse_workflow,
    run_bodies as _run_bodies,
    run_lines as _run_lines,
    steps as _steps,
    validate_exact_workflow,
)


PR_SOURCE_TIMING_OUTPUTS = {
    "./scripts/check-asl-layout": "build/pr-timing/check-asl-layout.json",
    "./scripts/check-ndf": "build/pr-timing/check-ndf.json",
    "./scripts/check-adrs": "build/pr-timing/check-adrs.json",
    "./scripts/check-asl-tests": "build/pr-timing/check-asl-tests.json",
    "./scripts/check-release-event-schema": (
        "build/pr-timing/check-release-event-schema.json"
    ),
    "python3 scripts/project_asl_catalogs.py --root . --check": (
        "build/pr-timing/project-asl-catalogs.json"
    ),
    "python3 scripts/instruction_docs.py --check": (
        "build/pr-timing/instruction-docs.json"
    ),
    "python3 scripts/generate-mnemonic-avs.py --check": (
        "build/pr-timing/generate-mnemonic-avs.json"
    ),
    "python3 scripts/check-publication-hygiene": (
        "build/pr-timing/publication-hygiene.json"
    ),
    "./scripts/check-release-workflow": "build/pr-timing/release-workflow.json",
    "./scripts/check-repository --structure-only": (
        "build/pr-timing/repository-structure.json"
    ),
    "git diff --check": "build/pr-timing/diff.json",
}
PR_GATES = tuple(PR_SOURCE_TIMING_OUTPUTS)
PR_TOOLING_COMMAND = "python3 -m unittest discover -s tests/scripts -p 'test_*.py'"
PR_TOOLING_TIMING_OUTPUT = "build/pr-timing/tooling-tests.json"
PR_WORKER_TIMING_OUTPUTS = {
    "build/pr-timing/worker-source-contract.json",
    "build/pr-timing/worker-tooling-tests.json",
}


def _timing_line(output: str, command: str) -> str:
    return f"scripts/pr_timing.py run --output {output} -- {command}"


def _worker_start_line(worker: str) -> str:
    return (
        "scripts/pr_timing.py start --output "
        f"build/pr-timing/{worker}.started"
    )


def _worker_finish_line(worker: str) -> str:
    return (
        "scripts/pr_timing.py finish "
        f"--start build/pr-timing/{worker}.started "
        f"--output build/pr-timing/worker-{worker}.json "
        '--run-id "$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT" '
        f"--worker {worker}"
    )


def _expected_source_run_bodies() -> list[tuple[str, ...]]:
    return [
        (_worker_start_line("source-contract"),),
        (
            "mkdir -p build/pr-timing",
            *(
                _timing_line(output, command)
                for command, output in PR_SOURCE_TIMING_OUTPUTS.items()
            ),
        ),
        (_worker_finish_line("source-contract"),),
    ]


def _expected_tooling_run_bodies() -> list[tuple[str, ...]]:
    return [
        (_worker_start_line("tooling-tests"),),
        ('echo "sha=$(git -C tools/ndf rev-parse HEAD)" >> "$GITHUB_OUTPUT"',),
        (
            "mkdir -p build/pr-timing",
            _timing_line(PR_TOOLING_TIMING_OUTPUT, PR_TOOLING_COMMAND),
        ),
        (_worker_finish_line("tooling-tests"),),
    ]


def _checkout_step() -> dict[str, object]:
    return {
        "name": "Check out repository",
        "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
        "with": {"fetch-depth": "0", "submodules": "recursive"},
    }


def _expected_source_steps() -> list[dict[str, object]]:
    bodies = _expected_source_run_bodies()
    return [
        _checkout_step(),
        {"name": "Start source-contract timing", "run": bodies[0][0]},
        {
            "name": "Validate source, projection, and publication contracts",
            "run": "\n".join(bodies[1]),
        },
        {
            "name": "Finish source-contract timing",
            "if": "always()",
            "run": bodies[2][0],
        },
        {
            "name": "Retain source-contract timings",
            "if": "always()",
            "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
            "with": {
                "name": "pr-timing-source-contract",
                "path": "build/pr-timing/*.json",
                "if-no-files-found": "warn",
            },
        },
    ]


def _expected_tooling_steps() -> list[dict[str, object]]:
    bodies = _expected_tooling_run_bodies()
    return [
        _checkout_step(),
        {"name": "Start tooling-tests timing", "run": bodies[0][0]},
        {
            "name": "Resolve the exact NDF revision",
            "id": "ndf-revision",
            "run": bodies[1][0],
        },
        {
            "name": "Restore the NDF tool build",
            "id": "ndf-cache",
            "uses": f"actions/cache@{CACHE_ACTION_SHA}",
            "with": {
                "path": "tools/ndf/target",
                "key": (
                    "ndf-${{ runner.os }}-${{ runner.arch }}-"
                    "${{ steps.ndf-revision.outputs.sha }}-"
                    "${{ hashFiles('tools/ndf/Cargo.lock') }}"
                ),
            },
        },
        {
            "name": "Run script and NDF parity tests",
            "run": "\n".join(bodies[2]),
        },
        {
            "name": "Finish tooling-tests timing",
            "if": "always()",
            "run": bodies[3][0],
        },
        {
            "name": "Retain tooling-test timings",
            "if": "always()",
            "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
            "with": {
                "name": "pr-timing-tooling-tests",
                "path": "build/pr-timing/*.json",
                "if-no-files-found": "warn",
            },
        },
    ]


def _summary_line() -> str:
    return (
        "scripts/pr_timing.py summary --input "
        "build/pr-timing/worker-source-contract.json "
        "build/pr-timing/worker-tooling-tests.json --budget-seconds 600 "
        "--output build/pr-timing-summary.json "
        '--markdown-output "$GITHUB_STEP_SUMMARY"'
    )


def _expected_validate_steps() -> list[dict[str, object]]:
    return [
        {
            "name": "Check out timing summarizer",
            "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
        },
        {
            "name": "Merge worker timings",
            "uses": f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}",
            "with": {
                "pattern": "pr-timing-*",
                "path": "build/pr-timing",
                "merge-multiple": "true",
            },
        },
        {
            "name": "Publish observational timing summary",
            "run": _summary_line(),
        },
        {
            "name": "Require both correctness workers",
            "env": {
                "SOURCE_CONTRACT_RESULT": "${{ needs.source-contract.result }}",
                "TOOLING_TESTS_RESULT": "${{ needs.tooling-tests.result }}",
            },
            "run": (
                'test "$SOURCE_CONTRACT_RESULT" = success\n'
                'test "$TOOLING_TESTS_RESULT" = success'
            ),
        },
    ]


def _job_fields(job: dict[str, object]) -> dict[str, object]:
    return {key: value for key, value in job.items() if key != "steps"}


def _expected_pr_root_fields() -> dict[str, object]:
    return {
        "name": "PR",
        "on": {
            "push": {"branches": ["main"]},
            "pull_request": None,
        },
        "permissions": {"contents": "read"},
        "concurrency": {
            "group": "pr-${{ github.workflow }}-${{ github.ref }}",
            "cancel-in-progress": "true",
        },
    }


def validate_pr_workflow(workflow: str) -> list[str]:
    """Return violations of the intentionally lightweight PR contract."""

    root, errors = parse_workflow(workflow, label="PR workflow")
    if root is None:
        return errors
    expected_root_fields = _expected_pr_root_fields()
    if set(root) != {*expected_root_fields, "jobs"} or any(
        root.get(key) != value for key, value in expected_root_fields.items()
    ):
        errors.append(
            "PR workflow must use its exact top-level mapping for name, events, "
            "read-only permissions, concurrency, and jobs"
        )
    jobs = _mapping(root.get("jobs"))
    expected_jobs = {"source-contract", "tooling-tests", "validate"}
    if set(jobs) != expected_jobs:
        errors.append(
            "PR workflow jobs must be exactly source-contract, tooling-tests, and validate"
        )
    source_contract = _mapping(jobs.get("source-contract"))
    tooling_tests = _mapping(jobs.get("tooling-tests"))
    validate = _mapping(jobs.get("validate"))
    worker_contracts = (
        (
            "source-contract",
            source_contract,
            {
                "name": "PR / source-contract",
                "runs-on": "ubuntu-latest",
                "timeout-minutes": "15",
            },
            _expected_source_steps(),
        ),
        (
            "tooling-tests",
            tooling_tests,
            {
                "name": "PR / tooling-tests",
                "runs-on": "ubuntu-latest",
                "timeout-minutes": "15",
            },
            _expected_tooling_steps(),
        ),
    )
    for worker, job, expected_fields, expected_steps in worker_contracts:
        if _job_fields(job) != expected_fields:
            errors.append(f"{worker} must use its exact job mapping")
        if _steps(job) != expected_steps:
            errors.append(f"{worker} must use its exact ordered step mappings")
    expected_validate_fields = {
        "name": "PR / validate",
        "if": "always()",
        "needs": ["source-contract", "tooling-tests"],
        "runs-on": "ubuntu-latest",
        "timeout-minutes": "5",
    }
    if _job_fields(validate) != expected_validate_fields:
        errors.append("validate must use its exact job mapping")
    if _steps(validate) != _expected_validate_steps():
        errors.append("validate must use its exact ordered step mappings")
    all_steps = [
        step
        for job in (source_contract, tooling_tests, validate)
        for step in _steps(job)
    ]
    allowed_actions = {
        f"actions/checkout@{CHECKOUT_ACTION_SHA}",
        f"actions/cache@{CACHE_ACTION_SHA}",
        f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
        f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}",
    }
    for step in all_steps:
        if "uses" not in step:
            continue
        action = step["uses"]
        if not isinstance(action, str) or action not in allowed_actions:
            errors.append(
                "PR workflow has malformed or unrecognized uses; actions must be commit-pinned"
            )

    timed = re.compile(
        r"^scripts/pr_timing\.py run --output (?P<output>\S+) -- (?P<command>.+)$"
    )
    def timed_commands(job: dict[str, object]) -> list[tuple[str, str]]:
        commands: list[tuple[str, str]] = []
        for line in _run_lines(job):
            match = timed.fullmatch(line)
            if match:
                commands.append((match.group("output"), match.group("command")))
        return commands

    source_timed = timed_commands(source_contract)
    tooling_timed = timed_commands(tooling_tests)
    all_timed = source_timed + tooling_timed
    active_worker_lines = _run_lines(source_contract) + _run_lines(tooling_tests)
    if any(
        line in PR_GATES or line == PR_TOOLING_COMMAND for line in active_worker_lines
    ):
        errors.append("PR workflow contains an unwrapped checker command")
    for command, expected_output in PR_SOURCE_TIMING_OUTPUTS.items():
        if (
            source_timed.count((expected_output, command)) != 1
            or sum(actual == command for _, actual in source_timed) != 1
        ):
            errors.append(
                f"source-contract must execute {command} exactly once through the "
                f"timing wrapper with exact timing output {expected_output}"
            )
    if (
        tooling_timed.count((PR_TOOLING_TIMING_OUTPUT, PR_TOOLING_COMMAND)) != 1
        or sum(command == PR_TOOLING_COMMAND for _, command in tooling_timed) != 1
    ):
        errors.append(
            "tooling-tests must execute the script unit tests exactly once "
            "through the timing wrapper with its exact timing output"
        )
    if any(command not in PR_GATES for _, command in source_timed) or any(
        command != PR_TOOLING_COMMAND for _, command in tooling_timed
    ):
        errors.append("PR workflow must not execute unrecognized timed commands")
    timing_outputs = [output for output, _ in all_timed]
    if len(timing_outputs) != len(set(timing_outputs)):
        errors.append("PR workflow timing output paths must be unique")
    if any(output in PR_WORKER_TIMING_OUTPUTS for output in timing_outputs):
        errors.append("checker timing output must not collide with a worker timing output")
    if any(
        not output.startswith("build/pr-timing/") or not output.endswith(".json")
        for output in timing_outputs
    ):
        errors.append("every checker must use its exact timing output under build/pr-timing")
    if _run_bodies(source_contract) != _expected_source_run_bodies():
        errors.append("source-contract contains an unexpected active line or run-step body")
    if _run_bodies(tooling_tests) != _expected_tooling_run_bodies():
        errors.append("tooling-tests contains an unexpected active line or run-step body")

    for worker, job in (
        ("source-contract", source_contract),
        ("tooling-tests", tooling_tests),
    ):
        start = _worker_start_line(worker)
        finish = _worker_finish_line(worker)
        job_steps = _steps(job)
        start_indices = [
            index
            for index, step in enumerate(job_steps)
            if _run_lines({"steps": [step]}) == [start]
        ]
        finish_indices = [
            index
            for index, step in enumerate(job_steps)
            if _run_lines({"steps": [step]}) == [finish]
            and step.get("if") == "always()"
        ]
        operation_indices = [
            index
            for index, step in enumerate(job_steps)
            if any(timed.fullmatch(line) for line in _run_lines({"steps": [step]}))
            or step.get("uses") == f"actions/cache@{CACHE_ACTION_SHA}"
        ]
        if (
            len(start_indices) != 1
            or len(finish_indices) != 1
            or not operation_indices
            or not start_indices[0] < min(operation_indices)
            or not max(operation_indices) < finish_indices[0]
        ):
            errors.append(f"{worker} must emit exactly one elapsed run record")

    steps = _steps(tooling_tests)
    cache_steps = [
        step for step in steps if step.get("uses") == f"actions/cache@{CACHE_ACTION_SHA}"
    ]
    if len(cache_steps) != 1:
        errors.append("tooling-tests must use one commit-pinned NDF cache action")
    else:
        cache_with = _mapping(cache_steps[0].get("with"))
        path = cache_with.get("path")
        key = cache_with.get("key")
        required_key_terms = (
            "runner.os",
            "runner.arch",
            "steps.ndf-revision.outputs.sha",
            "hashFiles('tools/ndf/Cargo.lock')",
        )
        if path != "tools/ndf/target" or not isinstance(key, str) or any(
            term not in key for term in required_key_terms
        ):
            errors.append(
                "tooling-tests NDF cache must contain only tools/ndf/target "
                "and bind OS, architecture, submodule SHA, and Cargo.lock"
            )
    all_cache_steps = [
        step
        for step in all_steps
        if isinstance(step.get("uses"), str)
        and str(step["uses"]).startswith("actions/cache@")
    ]
    if len(all_cache_steps) != 1:
        errors.append("the NDF tool build must be the PR workflow's only cache")
    revision_steps = [step for step in steps if step.get("id") == "ndf-revision"]
    if len(revision_steps) != 1 or _run_lines({"steps": revision_steps}) != [
        'echo "sha=$(git -C tools/ndf rev-parse HEAD)" >> "$GITHUB_OUTPUT"'
    ]:
        errors.append("tooling-tests must derive the exact NDF submodule SHA")

    for name, job in (("source-contract", source_contract), ("tooling-tests", tooling_tests)):
        upload_steps = [
            step
            for step in _steps(job)
            if step.get("uses") == f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}"
        ]
        if len(upload_steps) != 1:
            errors.append(f"{name} must upload timing with the commit-pinned action")
        else:
            upload = upload_steps[0]
            upload_with = _mapping(upload.get("with"))
            if (
                upload.get("if") != "always()"
                or upload_with.get("name") != f"pr-timing-{name}"
                or upload_with.get("path") != "build/pr-timing/*.json"
            ):
                errors.append(f"{name} must always upload its exact timing artifact")

    if _flow_list(validate.get("needs")) != {"source-contract", "tooling-tests"}:
        errors.append("final PR gate must require both worker jobs")
    if validate.get("name") != "PR / validate" or validate.get("if") != "always()":
        errors.append("final PR gate must be named PR / validate and always run")
    validate_lines = _run_lines(validate)
    for variable in ("SOURCE_CONTRACT_RESULT", "TOOLING_TESTS_RESULT"):
        if f'test "${variable}" = success' not in validate_lines:
            errors.append(f"final PR gate must explicitly require {variable} = success")
    download_steps = [
        step
        for step in _steps(validate)
        if step.get("uses") == f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}"
    ]
    download_with = (
        _mapping(download_steps[0].get("with"))
        if len(download_steps) == 1
        else {}
    )
    if (
        download_with.get("pattern") != "pr-timing-*"
        or download_with.get("path") != "build/pr-timing"
        or download_with.get("merge-multiple") != "true"
    ):
        errors.append("final PR gate must download and merge the exact timing artifacts")
    summary_line = _summary_line()
    if len(download_steps) != 1 or validate_lines.count(summary_line) != 1:
        errors.append("final PR gate must merge timing artifacts into the job summary")

    return errors


def _release_jobs() -> dict[str, object]:
    return {
        "full-validation": {
            "name": "Release / full validation",
            "uses": "./.github/workflows/full-validation.yml",
            "with": {"commit": "${{ inputs.commit }}", "authority": "release"},
            "permissions": {"contents": "read"},
        },
        "release-evidence": {
            "name": "Release / fail-closed evidence aggregation",
            "needs": "full-validation",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "45",
            "steps": [
                checkout_step("${{ inputs.commit }}"),
                {
                    "name": "Download exact ASL test plan",
                    "uses": f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "full-validation-plan-release-${{ inputs.commit }}",
                        "path": "build/planned-asl-test-pages",
                    },
                },
                {
                    "name": "Download every per-ID result",
                    "uses": f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}",
                    "with": {
                        "pattern": "full-validation-results-release-${{ inputs.commit }}-*",
                        "path": "build/asl-test-results",
                        "merge-multiple": "true",
                    },
                },
                {
                    "name": "Aggregate exact set equality and regenerate release evidence",
                    "shell": "bash",
                    "env": {"COMMIT": "${{ inputs.commit }}"},
                    "run-sha256": "4f9d45685c49c0b640facd103a378bffb52db4e2a2972852d2a18a84e2ae8ef4",
                },
                {
                    "name": "Upload release evidence",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-release-evidence-${{ inputs.commit }}",
                        "path": "build/asl-test-matrix.json\n"
                        "build/asl-test-coverage.json\n"
                        "spec/evidence/asl-test-matrix.sha256\n"
                        "spec/release-manifest.json",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
            ],
        },
        "validate": {
            "name": "Release / validate",
            "if": "always()",
            "needs": ["full-validation", "release-evidence"],
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "10",
            "steps": [
                {
                    "name": "Require every exact-head release gate",
                    "shell": "bash",
                    "env": {
                        "FULL_VALIDATION_RESULT": "${{ needs.full-validation.result }}",
                        "RELEASE_EVIDENCE_RESULT": "${{ needs.release-evidence.result }}",
                    },
                    "run-sha256": "08951561d771359b1e744c956c4dc5082c0fe03d85dceca5881d0eca4efde269",
                }
            ],
        },
    }


def validate_release_workflow(workflow: str) -> list[str]:
    """Validate manual release authority and canonical evidence aggregation."""

    errors = validate_exact_workflow(
        workflow,
        label="release workflow",
        expected_root={
            "name": "Release verification",
            "on": {
                "workflow_dispatch": {
                    "inputs": {
                        "commit": {
                            "description": "Exact reviewed commit to verify (40 lowercase hexadecimal characters)",
                            "required": "true",
                            "type": "string",
                        }
                    }
                }
            },
            "permissions": {"contents": "read"},
            "concurrency": {
                "group": "release-verification-${{ inputs.commit }}",
                "cancel-in-progress": "false",
            },
        },
        expected_jobs=_release_jobs(),
    )
    lowered = workflow.lower()
    if any(term in lowered for term in ("gh release", "create-release", "git push")):
        errors.append("release verification must not create a tag or release")
    return errors
