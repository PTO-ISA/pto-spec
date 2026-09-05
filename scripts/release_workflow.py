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


def _diagnostic_status(name: str, run_sha256: str) -> dict[str, object]:
    return {
        "name": name,
        "if": "always()",
        "shell": "bash",
        "env": {
            "PTO_COMMIT": "${{ inputs.commit }}",
            "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
            "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
            "RUN_ID": "${{ github.run_id }}",
            "RUN_ATTEMPT": "${{ github.run_attempt }}",
            "JOB_STATUS": "${{ job.status }}",
            "STEPS_JSON": "${{ toJSON(steps) }}",
        },
        "run-sha256": run_sha256,
    }


def _release_jobs() -> dict[str, object]:
    return {
        "release-preflight": {
            "name": "Release / candidate preflight",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "30",
            "outputs": {
                "artifact-digest": "${{ steps.preflight-artifact.outputs.artifact-digest }}"
            },
            "steps": [
                {
                    "name": "Validate exact component inputs",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "WORKFLOW_COMMIT": "${{ github.workflow_sha }}",
                    },
                    "run-sha256": "5d3fe8e746e1e3c791cfb1cdf96d55544a2d33c6131a70e08b9687bfb861031c",
                },
                {
                    "name": "Check out exact PTO-SPEC candidate",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "ref": "${{ inputs.commit }}",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                        "submodules": "recursive",
                    },
                },
                {
                    "name": "Check out exact LLVM candidate",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "LinxISA/llvm-project",
                        "ref": "${{ inputs.llvm_commit }}",
                        "path": "build/closure/llvm-project",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                    },
                },
                {
                    "name": "Check out exact ASL-MODEL candidate",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "PTO-ISA/asl-model",
                        "ref": "${{ inputs.asl_model_commit }}",
                        "path": "build/closure/asl-model",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                    },
                },
                {
                    "name": "Record exact input tuple for diagnostics",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "WORKFLOW_COMMIT": "${{ github.workflow_sha }}",
                    },
                    "run-sha256": "653f4c368ac7db0a19392e2419d54d0ac6e7da22f897b384555959065911589c",
                },
                {
                    "name": "Resolve ASL-MODEL dependency pins",
                    "id": "model-pins",
                    "shell": "bash",
                    "run-sha256": "eeb99129d7758196e663d4ddbef70eda58d765e5f3321c8b403aef6ea23016f9",
                },
                {
                    "name": "Check out ASL-MODEL pinned NDF",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "PTO-ISA/normative_language",
                        "ref": "${{ steps.model-pins.outputs.ndf }}",
                        "path": "build/closure/asl-model/tools/ndf",
                        "fetch-depth": "1",
                        "persist-credentials": "false",
                    },
                },
                {
                    "name": "Check out ASL-MODEL imported PTO graph baseline",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "PTO-ISA/pto-spec",
                        "ref": "${{ steps.model-pins.outputs.pto }}",
                        "path": "build/closure/asl-model/vendor/pto-spec",
                        "fetch-depth": "1",
                        "persist-credentials": "false",
                        "submodules": "false",
                    },
                },
                {
                    "name": "Restore NDF preflight builds",
                    "uses": f"actions/cache@{CACHE_ACTION_SHA}",
                    "with": {
                        "path": "tools/ndf/target\nbuild/closure/asl-model/tools/ndf/target",
                        "key": "pto-release-preflight-${{ runner.os }}-${{ runner.arch }}-${{ steps.model-pins.outputs.pto_ndf }}-${{ steps.model-pins.outputs.ndf }}-${{ hashFiles('tools/ndf/Cargo.lock', 'build/closure/asl-model/tools/ndf/Cargo.lock') }}",
                    },
                },
                {
                    "name": "Build exact NDF impact",
                    "shell": "bash",
                    "env": {"PTO_COMMIT": "${{ inputs.commit }}"},
                    "run-sha256": "118b4bc9f6c35ad5156d3fd7fdbde48193432318e6d8789e0487bf591f4fdd2a",
                },
                {
                    "name": "Validate identity, LLVM header, and affected AVS mapping",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "WORKFLOW_COMMIT": "${{ github.workflow_sha }}",
                    },
                    "run-sha256": "396fcd4359f3fdaf3ca0401776c75743fedb218001087f1e7ec81d72f8e3eb43",
                },
                {
                    "name": "Upload immutable preflight tuple and impact",
                    "id": "preflight-artifact",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-release-preflight-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-preflight/candidate.json\nbuild/release-preflight/ndf-impact.json",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
                _diagnostic_status(
                    "Synthesize preflight diagnostic status",
                    "afc735b544903f5afb64e582a588ea534d6e03a51139f5a8843ef01cdf791e60",
                ),
                {
                    "name": "Upload preflight diagnostics",
                    "if": "always()",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-release-preflight-diagnostics-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-diagnostics/preflight.json\nbuild/release-preflight/input-tuple.json\nbuild/release-preflight/diagnostics.json\nbuild/release-preflight/ndf-impact.json",
                        "if-no-files-found": "error",
                        "retention-days": "30",
                    },
                },
            ],
        },
        "full-validation": {
            "name": "Release / full validation",
            "needs": "release-preflight",
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
                _diagnostic_status(
                    "Synthesize evidence diagnostic status",
                    "f61119f5fe399dd92ba3d2bcfd0c4baf10bb16a36b782bc146c50ec71ce80871",
                ),
                {
                    "name": "Upload evidence diagnostics",
                    "if": "always()",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-evidence-diagnostics-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-diagnostics/evidence.json",
                        "if-no-files-found": "error",
                        "retention-days": "30",
                    },
                },
            ],
        },
        "release-site": {
            "name": "Release / static site validity",
            "needs": "release-preflight",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "45",
            "outputs": {
                "artifact-digest": "${{ steps.site-preview.outputs.artifact-digest }}"
            },
            "steps": [
                checkout_step("${{ inputs.commit }}"),
                {
                    "name": "Set up Node.js",
                    "uses": f"actions/setup-node@{SETUP_NODE_ACTION_SHA}",
                    "with": {"node-version": "22"},
                },
                {
                    "name": "Enable the locked package manager",
                    "run-sha256": "c33c9a67a3d846a5acb1336aecd50a61a05b445f03812d36427443e618b4c24f",
                },
                {
                    "name": "Install exact site dependencies",
                    "run-sha256": "aff9ceeba433670fa1ce05da644f09bdbc274c678106c74c89a12cd7c57fa234",
                },
                {
                    "name": "Validate the exact static site artifact",
                    "shell": "bash",
                    "env": {
                        "COMMIT": "${{ inputs.commit }}",
                        "PTO_SITE_RELEASE_COMMIT": "${{ inputs.commit }}",
                    },
                    "run-sha256": "d85c41260c3c8b95b7b2c394507edc9763987f4985f18b6cce5ef236860f9905",
                },
                {
                    "name": "Install the browser test runtime",
                    "run-sha256": "23449948affe7c2113b3e1c885e9ca0705068e87d6c1cbcebe06cab3ca2cde06",
                },
                {
                    "name": "Exercise release site browser paths",
                    "run-sha256": "4b59b15e682bff8ca74bc5c25b948029766bf72cead0eb27a9e4b2a218368d5a",
                },
                {
                    "name": "Enforce Lighthouse quality budgets",
                    "run-sha256": "715b0a71ccc3e1b71907c2746198b3a09a5bf913ef7c005844611118a1aff7d4",
                },
                {
                    "name": "Upload immutable site preview",
                    "id": "site-preview",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-site-preview-${{ inputs.commit }}",
                        "path": "docs/site/build",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
                {
                    "name": "Synthesize site diagnostic status",
                    "if": "always()",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "RUN_ID": "${{ github.run_id }}",
                        "RUN_ATTEMPT": "${{ github.run_attempt }}",
                        "JOB_STATUS": "${{ job.status }}",
                        "STEPS_JSON": "${{ toJSON(steps) }}",
                    },
                    "run-sha256": "48bb14cd4658dcb87c3cc8448c09a0518aa71a5f1e576b266491dc409abb89f6",
                },
                {
                    "name": "Upload site diagnostics",
                    "if": "always()",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-site-diagnostics-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-diagnostics/site.json\ndocs/site/playwright-report\ndocs/site/test-results\ndocs/site/.lighthouseci",
                        "if-no-files-found": "error",
                        "retention-days": "30",
                    },
                },
            ],
        },
        "model-closure": {
            "name": "Release / LLVM-to-ASL model closure",
            "needs": "release-preflight",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "360",
            "outputs": {
                "semantic-payload-sha256": "${{ steps.closure.outputs.semantic-payload-sha256 }}",
                "artifact-digest": "${{ steps.closure-artifact.outputs.artifact-digest }}",
            },
            "steps": [
                {
                    "name": "Validate exact component inputs",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "WORKFLOW_COMMIT": "${{ github.workflow_sha }}",
                    },
                    "run-sha256": "5d3fe8e746e1e3c791cfb1cdf96d55544a2d33c6131a70e08b9687bfb861031c",
                },
                {
                    "name": "Check out exact PTO-SPEC candidate",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "ref": "${{ inputs.commit }}",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                        "submodules": "recursive",
                    },
                },
                {
                    "name": "Check out exact LLVM candidate",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "LinxISA/llvm-project",
                        "ref": "${{ inputs.llvm_commit }}",
                        "path": "build/closure/llvm-project",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                    },
                },
                {
                    "name": "Check out exact ASL-MODEL candidate",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "PTO-ISA/asl-model",
                        "ref": "${{ inputs.asl_model_commit }}",
                        "path": "build/closure/asl-model",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                    },
                },
                {
                    "name": "Download exact release preflight",
                    "uses": f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-release-preflight-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-preflight",
                    },
                },
                {
                    "name": "Resolve ASL-MODEL dependency pins",
                    "id": "model-pins",
                    "shell": "bash",
                    "run-sha256": "5e2549ac3ae71261e3ce4e0a773b3662291793da531be81461a800d92c3284d9",
                },
                {
                    "name": "Check out ASL-MODEL pinned NDF",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "PTO-ISA/normative_language",
                        "ref": "${{ steps.model-pins.outputs.ndf }}",
                        "path": "build/closure/asl-model/tools/ndf",
                        "fetch-depth": "1",
                        "persist-credentials": "false",
                    },
                },
                {
                    "name": "Check out ASL-MODEL pinned PTO graph",
                    "uses": f"actions/checkout@{CHECKOUT_ACTION_SHA}",
                    "with": {
                        "repository": "PTO-ISA/pto-spec",
                        "ref": "${{ steps.model-pins.outputs.pto }}",
                        "path": "build/closure/asl-model/vendor/pto-spec",
                        "fetch-depth": "1",
                        "persist-credentials": "false",
                        "submodules": "false",
                    },
                },
                {
                    "name": "Revalidate downloaded tuple before expensive builds",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "WORKFLOW_COMMIT": "${{ github.workflow_sha }}",
                    },
                    "run-sha256": "440b3f4d56e9295062bc78961bc7b8fab50df4bc1e0709dd0eec50c45414f995",
                },
                {
                    "name": "Set up pinned OCaml",
                    "uses": "ocaml/setup-ocaml@15d660006c1d3110d77c34b7faa3bddefe8b82f0",
                    "with": {"ocaml-compiler": "5.2.1", "dune-cache": "true"},
                },
                {
                    "name": "Fingerprint LLVM build environment",
                    "id": "llvm-build-cache",
                    "shell": "bash",
                    "run-sha256": "8eb5ddfb7290618097a74f11b19394eee8e055285f2005786375a25d687a96af",
                },
                {
                    "name": "Restore exact ASLRef build",
                    "uses": f"actions/cache@{CACHE_ACTION_SHA}",
                    "with": {
                        "path": ".cache/herdtools7",
                        "key": "pto-aslref-${{ runner.os }}-${{ runner.arch }}-ocaml-5.2.1-${{ hashFiles('.aslref-origin', '.aslref-version', 'scripts/prepare-aslref') }}",
                    },
                },
                {
                    "name": "Restore exact LLVM build",
                    "uses": f"actions/cache@{CACHE_ACTION_SHA}",
                    "with": {
                        "path": "build/closure/llvm-build",
                        "key": "pto-llvm-release-${{ runner.os }}-${{ runner.arch }}-${{ inputs.llvm_commit }}-${{ steps.llvm-build-cache.outputs.sha256 }}",
                    },
                },
                {
                    "name": "Restore PTO NDF build",
                    "uses": f"actions/cache@{CACHE_ACTION_SHA}",
                    "with": {
                        "path": "tools/ndf/target",
                        "key": "pto-ndf-${{ runner.os }}-${{ runner.arch }}-${{ steps.model-pins.outputs.pto_ndf }}-${{ hashFiles('tools/ndf/Cargo.lock') }}",
                    },
                },
                {
                    "name": "Restore ASL-MODEL NDF build",
                    "uses": f"actions/cache@{CACHE_ACTION_SHA}",
                    "with": {
                        "path": "build/closure/asl-model/tools/ndf/target",
                        "key": "asl-model-ndf-${{ runner.os }}-${{ runner.arch }}-${{ steps.model-pins.outputs.ndf }}-${{ hashFiles('build/closure/asl-model/tools/ndf/Cargo.lock') }}",
                    },
                },
                {
                    "name": "Prepare exact ASL and LLVM tools",
                    "shell": "bash",
                    "run-sha256": "51e9512bc9568b9e5a246b7c3efc0d18871a28e35c63c73d9fb47258bb89b1fe",
                },
                {
                    "name": "Run twice and validate exact closure",
                    "id": "closure",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "WORKFLOW_COMMIT": "${{ github.workflow_sha }}",
                        "RUN_ID": "${{ github.run_id }}",
                        "RUN_ATTEMPT": "${{ github.run_attempt }}",
                    },
                    "run-sha256": "ddd52454d53a85fe99723cdec50b2f2a8f48f372e98fa8763fcf64ed75052def",
                },
                {
                    "name": "Upload immutable model closure evidence",
                    "id": "closure-artifact",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-model-closure-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-preflight/candidate.json\n"
                        "build/release-preflight/ndf-impact.json\n"
                        "build/model-closure-run-1/evidence\n"
                        "build/model-closure-run-2/evidence",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
                {
                    "name": "Synthesize model diagnostic status",
                    "if": "always()",
                    "shell": "bash",
                    "env": {
                        "PTO_COMMIT": "${{ inputs.commit }}",
                        "LLVM_COMMIT": "${{ inputs.llvm_commit }}",
                        "ASL_MODEL_COMMIT": "${{ inputs.asl_model_commit }}",
                        "RUN_ID": "${{ github.run_id }}",
                        "RUN_ATTEMPT": "${{ github.run_attempt }}",
                        "JOB_STATUS": "${{ job.status }}",
                        "STEPS_JSON": "${{ toJSON(steps) }}",
                    },
                    "run-sha256": "85fe0e9863e17e43b209eb5b9c376eedb96b2316e0f9e116de31e0eed5f28ef5",
                },
                {
                    "name": "Upload model diagnostics",
                    "if": "always()",
                    "uses": f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}",
                    "with": {
                        "name": "pto-model-diagnostics-${{ inputs.commit }}-${{ inputs.llvm_commit }}-${{ inputs.asl_model_commit }}",
                        "path": "build/release-diagnostics/model.json\nbuild/release-preflight\nbuild/model-closure-run-1/evidence\nbuild/model-closure-run-2/evidence",
                        "if-no-files-found": "error",
                        "retention-days": "30",
                    },
                },
            ],
        },
        "validate": {
            "name": "Release / validate",
            "if": "always()",
            "needs": ["release-preflight", "full-validation", "release-evidence", "release-site", "model-closure"],
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "10",
            "steps": [
                {
                    "name": "Require every exact-head release gate",
                    "shell": "bash",
                    "env": {
                        "FULL_VALIDATION_RESULT": "${{ needs.full-validation.result }}",
                        "RELEASE_PREFLIGHT_RESULT": "${{ needs.release-preflight.result }}",
                        "RELEASE_PREFLIGHT_ARTIFACT_DIGEST": "${{ needs.release-preflight.outputs.artifact-digest }}",
                        "RELEASE_EVIDENCE_RESULT": "${{ needs.release-evidence.result }}",
                        "RELEASE_SITE_RESULT": "${{ needs.release-site.result }}",
                        "MODEL_CLOSURE_RESULT": "${{ needs.model-closure.result }}",
                        "SITE_ARTIFACT_DIGEST": "${{ needs.release-site.outputs.artifact-digest }}",
                        "MODEL_CLOSURE_ARTIFACT_DIGEST": "${{ needs.model-closure.outputs.artifact-digest }}",
                        "MODEL_CLOSURE_SEMANTIC_PAYLOAD_SHA256": "${{ needs.model-closure.outputs.semantic-payload-sha256 }}",
                    },
                    "run-sha256": "38227e4114a775327ff1e112c11a6bd11670d6b316cb9c33a65aed2d9fa7fbb5",
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
                        },
                        "llvm_commit": {
                            "description": "Exact reviewed LinxISA LLVM commit for PTO 0.58.5",
                            "required": "true",
                            "type": "string",
                        },
                        "asl_model_commit": {
                            "description": "Exact reviewed PTO ASL-MODEL commit and AVS corpus",
                            "required": "true",
                            "type": "string",
                        },
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
