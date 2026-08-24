#!/usr/bin/env python3
"""Semantic checks for lightweight PR and exact-head release workflows."""

from __future__ import annotations

from scripts.workflow_contract import (
    CACHE_ACTION_SHA,
    CHECKOUT_ACTION_SHA,
    DOWNLOAD_ARTIFACT_SHA,
    UPLOAD_ARTIFACT_SHA,
    checkout_step,
    flow_list as _flow_list,
    mapping as _mapping,
    parse_workflow,
    run_lines as _run_lines,
    steps as _steps,
    validate_exact_workflow,
)


PR_GATES = (
    "./scripts/check-asl-layout",
    "./scripts/check-ndf",
    "./scripts/check-adrs",
    "./scripts/check-asl-tests",
    "./scripts/check-release-event-schema",
    "python3 scripts/project_asl_catalogs.py --root . --check",
    "python3 scripts/instruction_docs.py --check",
    "python3 scripts/generate-mnemonic-avs.py --check",
    "python3 scripts/generate-bundle-operation-matrix.py --check",
    "python3 scripts/check-publication-hygiene",
    "./scripts/check-release-workflow",
    "./scripts/check-repository --structure-only",
    "git diff --check",
)
PR_TOOLING_COMMAND = "python3 -m unittest discover -s tests/scripts -p 'test_*.py'"


def _expected_source_run_bodies() -> list[tuple[str, ...]]:
    return [PR_GATES]


def _expected_tooling_run_bodies() -> list[tuple[str, ...]]:
    return [
        ('echo "sha=$(git -C tools/ndf rev-parse HEAD)" >> "$GITHUB_OUTPUT"',),
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
            "name": "Resolve the exact NDF revision",
            "id": "ndf-revision",
            "run": bodies[0][0],
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
            "run": bodies[1][0],
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
    expected_tooling_lines = [
        'echo "sha=$(git -C tools/ndf rev-parse HEAD)" >> "$GITHUB_OUTPUT"',
        PR_TOOLING_COMMAND,
    ]
    if tooling_lines != expected_tooling_lines:
        errors.append("tooling-tests contains an unexpected active line or command order")

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

    if _flow_list(validate.get("needs")) != {"source-contract", "tooling-tests"}:
        errors.append("final PR gate must require both worker jobs")
    if validate.get("name") != "PR / validate" or validate.get("if") != "always()":
        errors.append("final PR gate must be named PR / validate and always run")
    validate_lines = _run_lines(validate)
    for variable in ("SOURCE_CONTRACT_RESULT", "TOOLING_TESTS_RESULT"):
        if f'test "${variable}" = success' not in validate_lines:
            errors.append(f"final PR gate must explicitly require {variable} = success")
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
