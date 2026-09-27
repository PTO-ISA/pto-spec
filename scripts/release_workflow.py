#!/usr/bin/env python3
"""Semantic checks for lightweight PR and exact-head release workflows."""

from __future__ import annotations

from scripts.workflow_contract import (
    CACHE_ACTION_SHA,
    CHECKOUT_ACTION_SHA,
    DOWNLOAD_ARTIFACT_SHA,
    SETUP_NODE_ACTION_SHA,
    UPLOAD_ARTIFACT_SHA,
    checkout_step,
    flow_list as _flow_list,
    mapping as _mapping,
    parse_workflow,
    run_lines as _run_lines,
    steps as _steps,
    validate_exact_workflow,
)


PR_GATES = ("./scripts/check-pr --source",)
PR_TOOLING_COMMAND = "./scripts/check-pr --tooling"


def _expected_source_run_bodies() -> list[tuple[str, ...]]:
    return [PR_GATES]


def _expected_tooling_run_bodies() -> list[tuple[str, ...]]:
    return [
        (PR_TOOLING_COMMAND,),
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
        {
            "name": "Validate source, projection, and publication contracts",
            "run": "\n".join(bodies[0]),
        },
    ]


def _expected_tooling_steps() -> list[dict[str, object]]:
    bodies = _expected_tooling_run_bodies()
    return [
        _checkout_step(),
        {
            "name": "Run script tests",
            "run": bodies[0][0],
        },
    ]


def _expected_validate_steps() -> list[dict[str, object]]:
    return [
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
    }
    for step in all_steps:
        if "uses" not in step:
            continue
        action = step["uses"]
        if not isinstance(action, str) or action not in allowed_actions:
            errors.append(
                "PR workflow has malformed or unrecognized uses; actions must be commit-pinned"
            )

    source_lines = _run_lines(source_contract)
    tooling_lines = _run_lines(tooling_tests)
    for command in PR_GATES:
        if source_lines.count(command) != 1:
            errors.append(f"source-contract must execute {command} exactly once")
    if tooling_lines.count(PR_TOOLING_COMMAND) != 1:
        errors.append("tooling-tests must execute the script unit tests exactly once")
    if source_lines != list(PR_GATES):
        errors.append("source-contract contains an unexpected active line or command order")
    expected_tooling_lines = [PR_TOOLING_COMMAND]
    if tooling_lines != expected_tooling_lines:
        errors.append("tooling-tests contains an unexpected active line or command order")

    # The cargo-dependent NDF parity check lives in the full-validation lane.
    # The pull-request workflow must stay runnable without a Rust toolchain,
    # so it must not derive, build, or cache the NDF compiler here.
    cache_steps = [
        step
        for step in all_steps
        if isinstance(step.get("uses"), str)
        and str(step["uses"]).startswith("actions/cache@")
    ]
    if cache_steps:
        errors.append(
            "the PR workflow must not cache the cargo-dependent NDF tool build"
        )
    steps = _steps(tooling_tests)
    revision_steps = [step for step in steps if step.get("id") == "ndf-revision"]
    if revision_steps:
        errors.append(
            "tooling-tests must not derive the NDF submodule SHA in the PR lane"
        )

    if _flow_list(validate.get("needs")) != {"source-contract", "tooling-tests"}:
        errors.append("final PR gate must require both worker jobs")
    if validate.get("name") != "PR / validate" or validate.get("if") != "always()":
        errors.append("final PR gate must be named PR / validate and always run")
    validate_lines = _run_lines(validate)
    for variable in ("SOURCE_CONTRACT_RESULT", "TOOLING_TESTS_RESULT"):
        if f'test "${variable}" = success' not in validate_lines:
            errors.append(f"final PR gate must explicitly require {variable} = success")
    return errors

def validate_release_workflow(workflow: str) -> list[str]:
    """Validate the exact, PTO-only manual release authority workflow."""

    import hashlib

    expected_sha256 = "11233792721ca420898f90372ec2e06c4832efd499cf438aa0acdb78b8e0bda7"
    actual_sha256 = hashlib.sha256(workflow.encode("utf-8")).hexdigest()
    errors: list[str] = []
    if actual_sha256 != expected_sha256:
        errors.append(
            "release workflow must match the exact reviewed PTO-only release contract"
        )
    lowered = workflow.lower()
    for forbidden in (
        "llvm_commit",
        "asl_model_commit",
        "release-site",
        "model-closure",
        "pto-site-preview",
        "pto-model-closure",
        "linxisa/llvm-project",
        "pto-isa/asl-model",
    ):
        if forbidden in lowered:
            errors.append(f"release workflow must not contain cross-repository or site lane: {forbidden}")
    if any(term in lowered for term in ("gh release", "create-release", "git push")):
        errors.append("release verification must not create a tag or release")
    return errors
