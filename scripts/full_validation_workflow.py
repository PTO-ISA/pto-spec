#!/usr/bin/env python3
"""Fail-closed structural contracts for hosted full-validation workflows."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
import re

from scripts.workflow_contract import (
    CACHE_ACTION_SHA,
    CHECKOUT_ACTION_SHA,
    DOWNLOAD_ARTIFACT_SHA,
    OCAML_ACTION_SHA,
    UPLOAD_ARTIFACT_SHA,
    checkout_step,
    mapping,
    parse_workflow,
    validate_exact_workflow,
)


CHECKOUT = f"actions/checkout@{CHECKOUT_ACTION_SHA}"
UPLOAD = f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}"
DOWNLOAD = f"actions/download-artifact@{DOWNLOAD_ARTIFACT_SHA}"
OCAML = f"ocaml/setup-ocaml@{OCAML_ACTION_SHA}"
CACHE = f"actions/cache@{CACHE_ACTION_SHA}"


def _full_jobs() -> dict[str, object]:
    exact_checkout = checkout_step("${{ inputs.commit }}")
    exact_head = {
        "name": "Prove exact checked-out head",
        "shell": "bash",
        "env": {"COMMIT": "${{ inputs.commit }}"},
        "run-sha256": "9897fdbe65b31ea0356602d44171a5b7afdd59f1f546fad4080c21b7c2091aaf",
    }
    ocaml = {
        "name": "Set up pinned OCaml",
        "uses": OCAML,
        "with": {"ocaml-compiler": "5.2.1", "dune-cache": "true"},
    }
    cache = {
        "name": "Restore verified ASLRef build cache",
        "uses": CACHE,
        "with": {
            "path": ".cache/herdtools7",
            "key": "aslref-${{ runner.os }}-${{ runner.arch }}-ocaml-5.2.1-"
            "${{ hashFiles('.aslref-origin', '.aslref-version', "
            "'scripts/setup-aslref', 'scripts/prepare-aslref') }}",
        },
    }
    setup = {
        "name": "Verify and prepare pinned ASLRef",
        "run-sha256": "fb2385030d3edb8b782d213985408b3c73e19210163bb35e52f1b73b0858bb44",
    }
    return {
        "identity": {
            "name": "Full validation / exact commit and authority",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "10",
            "steps": [
                {
                    "name": "Validate authority and exact commit",
                    "shell": "bash",
                    "env": {
                        "AUTHORITY": "${{ inputs.authority }}",
                        "COMMIT": "${{ inputs.commit }}",
                    },
                    "run-sha256": "7b17217effaf28af379658ce8d56081eccb5e913ef90351f21f5daa473d39d25",
                },
                exact_checkout,
                exact_head,
            ],
        },
        "pr-contract": {
            "name": "Full validation / lightweight repository contract",
            "needs": "identity",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "45",
            "steps": [
                exact_checkout,
                {
                    "name": "Prove exact head and run lightweight gates",
                    "shell": "bash",
                    "env": {"COMMIT": "${{ inputs.commit }}"},
                    "run-sha256": "967e96053d09ee4b4a4ae7b8a60318159ca5af877c8921b49a86cae5be45c569",
                },
                {
                    "name": "Verify formal mnemonic and reservation contracts",
                    "run-sha256": "053ac8d6b442451ba38609975a974070612c2e6c9590ecd9d6e39f766190b3bf",
                },
            ],
        },
        "matrix-plan": {
            "name": "Full validation / one-pass ASL matrix plan",
            "needs": "identity",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "45",
            "outputs": {"pages": "${{ steps.matrix.outputs.pages }}"},
            "steps": [
                exact_checkout,
                {
                    "name": "Export every exact ASL page in one discovery",
                    "id": "matrix",
                    "shell": "bash",
                    "env": {"COMMIT": "${{ inputs.commit }}"},
                    "run-sha256": "d66578a91469b34399825cad6fa37f7a2a913d453c6d93e348a6b8c70c5b80b0",
                },
                {
                    "name": "Upload exact ASL test plan",
                    "uses": UPLOAD,
                    "with": {
                        "name": "full-validation-plan-${{ inputs.authority }}-${{ inputs.commit }}",
                        "path": "build/planned-asl-test-pages",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
            ],
        },
        "strict-model": {
            "name": "Full validation / strict normative model",
            "needs": "identity",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "360",
            "steps": [
                exact_checkout,
                exact_head,
                ocaml,
                cache,
                setup,
                {
                    "name": "Validate toolchain canaries and normative model",
                    "run-sha256": "6da2f44b50d1f1938e27d03112dc248b3aeea558a635b6601ab32b9216d985dc",
                },
            ],
        },
        "asl-page": {
            "name": "Full validation / ASL page ${{ matrix.page }}",
            "needs": "matrix-plan",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "360",
            "strategy": {
                "fail-fast": "false",
                "max-parallel": "8",
                "matrix": {
                    "page": "${{ fromJSON(needs.matrix-plan.outputs.pages) }}"
                },
            },
            "steps": [
                exact_checkout,
                {
                    "name": "Download exact ASL test plan",
                    "uses": DOWNLOAD,
                    "with": {
                        "name": "full-validation-plan-${{ inputs.authority }}-${{ inputs.commit }}",
                        "path": "build/planned-asl-test-pages",
                    },
                },
                exact_head,
                ocaml,
                cache,
                setup,
                {
                    "name": "Execute independent ASL points with machine parallelism",
                    "id": "execute",
                    "shell": "bash",
                    "run-sha256": "589045a8a3e3887e42becf03e1bc6fc6ecbae9318056abe6cd7b1254b15b0553",
                },
                {
                    "name": "Report per-mnemonic results and enforce the page",
                    "if": "always()",
                    "shell": "bash",
                    "env": {"EXECUTION_OUTCOME": "${{ steps.execute.outcome }}"},
                    "run-sha256": "c21f88a7e65f66826ac1eadd82bb114ce081efef0861b1aa478c19cbf4a25b2c",
                },
                {
                    "name": "Upload per-ID ASL results",
                    "if": "always()",
                    "uses": UPLOAD,
                    "with": {
                        "name": "full-validation-results-${{ inputs.authority }}-${{ inputs.commit }}-${{ matrix.page }}",
                        "path": "build/asl-test-results/*/result.json",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
            ],
        },
        "health": {
            "name": "Full validation / health",
            "if": "always()",
            "needs": [
                "identity",
                "pr-contract",
                "matrix-plan",
                "strict-model",
                "asl-page",
            ],
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "45",
            "steps": [
                exact_checkout,
                {
                    "name": "Download exact ASL test plan",
                    "uses": DOWNLOAD,
                    "with": {
                        "name": "full-validation-plan-${{ inputs.authority }}-${{ inputs.commit }}",
                        "path": "build/planned-asl-test-pages",
                    },
                },
                {
                    "name": "Download every per-ID result",
                    "uses": DOWNLOAD,
                    "with": {
                        "pattern": "full-validation-results-${{ inputs.authority }}-${{ inputs.commit }}-*",
                        "path": "build/asl-test-results",
                        "merge-multiple": "true",
                    },
                },
                {
                    "name": "Aggregate exact health without release evidence mutation",
                    "shell": "bash",
                    "env": {
                        "AUTHORITY": "${{ inputs.authority }}",
                        "COMMIT": "${{ inputs.commit }}",
                        "IDENTITY_RESULT": "${{ needs.identity.result }}",
                        "PR_CONTRACT_RESULT": "${{ needs.pr-contract.result }}",
                        "MATRIX_PLAN_RESULT": "${{ needs.matrix-plan.result }}",
                        "STRICT_MODEL_RESULT": "${{ needs.strict-model.result }}",
                        "ASL_PAGE_RESULT": "${{ needs.asl-page.result }}",
                    },
                    "run-sha256": "b602dbf024463aae46d9d0878b5d03debd8a8fb0808125fedd899610bcd02f9b",
                },
                {
                    "name": "Upload one health summary",
                    "if": "always()",
                    "uses": UPLOAD,
                    "with": {
                        "name": "full-validation-health-${{ inputs.authority }}-${{ inputs.commit }}",
                        "path": "build/full-validation-health.json",
                        "if-no-files-found": "error",
                        "retention-days": "90",
                    },
                },
            ],
        },
    }


def _nightly_jobs() -> dict[str, object]:
    return {
        "resolve-main": {
            "name": "Nightly / prove workflow commit is latest main",
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "10",
            "outputs": {"commit": "${{ steps.resolve.outputs.commit }}"},
            "steps": [
                {
                    "name": "Check out caller workflow commit",
                    "uses": CHECKOUT,
                    "with": {
                        "ref": "${{ github.sha }}",
                        "fetch-depth": "0",
                        "persist-credentials": "false",
                        "submodules": "recursive",
                    },
                },
                {
                    "name": "Prove caller workflow commit is latest origin main",
                    "id": "resolve",
                    "shell": "bash",
                    "env": {"GITHUB_WORKFLOW_SHA": "${{ github.sha }}"},
                    "run-sha256": "0f663690bd9209722bad77088464b3852c4be3f9b0a175b1cadede76b44d2013",
                },
            ],
        },
        "full-validation": {
            "name": "Nightly / full validation",
            "needs": "resolve-main",
            "uses": "./.github/workflows/full-validation.yml",
            "with": {
                "commit": "${{ needs.resolve-main.outputs.commit }}",
                "authority": "nightly",
            },
            "permissions": {"contents": "read"},
        },
        "validate": {
            "name": "Nightly / health",
            "if": "always()",
            "needs": ["resolve-main", "full-validation"],
            "runs-on": "ubuntu-latest",
            "timeout-minutes": "10",
            "steps": [
                {
                    "name": "Require exact latest-main health",
                    "shell": "bash",
                    "env": {
                        "RESOLVE_MAIN_RESULT": "${{ needs.resolve-main.result }}",
                        "FULL_VALIDATION_RESULT": "${{ needs.full-validation.result }}",
                    },
                    "run-sha256": "59ce759843b56fe5b7df1d9909b81d80d324bafa97a7dd7a6bfe9b250e4a114e",
                }
            ],
        },
    }


def validate_full_validation_workflow(workflow: str) -> list[str]:
    """Validate the reusable exact-commit full model and health contract."""

    return validate_exact_workflow(
        workflow,
        label="full validation workflow",
        expected_root={
            "name": "Full validation",
            "on": {
                "workflow_call": {
                    "inputs": {
                        "commit": {"required": "true", "type": "string"},
                        "authority": {"required": "true", "type": "string"},
                    },
                }
            },
            "permissions": {"contents": "read"},
            "env": {"ASL_TEST_PAGE_COUNT": "8"},
        },
        expected_jobs=_full_jobs(),
    )


def validate_nightly_workflow(workflow: str) -> list[str]:
    """Validate scheduled/manual latest-main health without release authority."""

    errors = validate_exact_workflow(
        workflow,
        label="nightly workflow",
        expected_root={
            "name": "Nightly main health",
            "on": {
                "schedule": [{"cron": "17 2 * * *"}],
                "workflow_dispatch": None,
            },
            "permissions": {"contents": "read"},
            "concurrency": {
                "group": "nightly-main-health",
                "cancel-in-progress": "false",
            },
        },
        expected_jobs=_nightly_jobs(),
    )
    lowered = workflow.lower()
    if any(
        term in lowered
        for term in (
            "make release-prepare",
            "spec/evidence/",
            "gh release",
            "create-release",
            "git push",
        )
    ):
        errors.append("nightly workflow must not mutate or publish release evidence")
    return errors


def _scalar_values(value: object) -> Iterator[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for child in value.values():
            yield from _scalar_values(child)
    elif isinstance(value, list):
        for child in value:
            yield from _scalar_values(child)


def _field_values(value: object, field: str) -> Iterator[object]:
    if isinstance(value, dict):
        for key, child in value.items():
            if key == field:
                yield child
            yield from _field_values(child, field)
    elif isinstance(value, list):
        for child in value:
            yield from _field_values(child, field)


def _requests_write_permission(value: object) -> bool:
    if not isinstance(value, dict):
        return False
    for key, child in value.items():
        if key == "permissions":
            scalar = child
            if (
                isinstance(scalar, str)
                and re.search(r"\bwrite(?:-all)?\b", scalar)
            ) or (
                isinstance(child, dict)
                and any(item == "write" for item in child.values())
            ):
                return True
        if isinstance(child, dict) and _requests_write_permission(child):
            return True
        if isinstance(child, list) and any(
            _requests_write_permission(item) for item in child
        ):
            return True
    return False


def _contains_non_nightly_authority(value: object) -> bool:
    if not isinstance(value, dict):
        return False
    for key, child in value.items():
        if key == "authority" and child != "nightly":
            return True
        if isinstance(child, dict) and _contains_non_nightly_authority(child):
            return True
        if isinstance(child, list) and any(
            _contains_non_nightly_authority(item) for item in child
        ):
            return True
    return False


def validate_workflow_inventory(workflows: Mapping[str, str]) -> list[str]:
    """Reject release authority outside the one canonical release workflow."""

    errors: list[str] = []
    evidence_markers = (
        "pto-release-evidence-",
        "build/asl-test-matrix.json",
        "build/asl-test-coverage.json",
        "spec/evidence/asl-test-matrix.sha256",
        "spec/release-manifest.json",
    )
    publication_actions = (
        "actions/create-release@",
        "softprops/action-gh-release@",
        "ncipollo/release-action@",
    )
    for name, source in sorted(workflows.items()):
        root, parse_errors = parse_workflow(source, label=f"workflow {name}")
        if root is None:
            errors.extend(parse_errors)
            continue
        if name == "release.yml":
            continue
        scalars = tuple(_scalar_values(root))
        jobs = mapping(root.get("jobs"))
        run_values = tuple(_field_values(jobs, "run"))
        with_values = tuple(_field_values(jobs, "with"))
        permission_values = tuple(_field_values(root, "permissions"))
        active_run_lines = [
            line.strip()
            for run in run_values
            if isinstance(run, str)
            for line in run.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        ]
        uses_values = tuple(_field_values(jobs, "uses"))
        if any(not isinstance(run, str) for run in run_values):
            errors.append(f"{name}: run commands must be scalar strings")
        if any(not isinstance(action, str) for action in uses_values):
            errors.append(f"{name}: uses references must be scalar strings")
        if any(not isinstance(inputs, dict) for inputs in with_values):
            errors.append(f"{name}: with inputs must be mappings")
        if any(
            not isinstance(permission, str | dict)
            or (
                isinstance(permission, dict)
                and any(not isinstance(item, str) for item in permission.values())
            )
            for permission in permission_values
        ):
            errors.append(f"{name}: permissions must be a scalar or string mapping")
        if any(_contains_non_nightly_authority(mapping(raw_job)) for raw_job in jobs.values()):
            errors.append(f"{name}: release authority is reserved for release.yml")
        if any("make release-prepare" in line for line in active_run_lines):
            errors.append(f"{name}: release preparation is reserved for release.yml")
        if any(marker in scalar for marker in evidence_markers for scalar in scalars):
            errors.append(f"{name}: canonical release evidence is reserved for release.yml")
        if "Release / validate" in scalars:
            errors.append(f"{name}: Release / validate is reserved for release.yml")
        if any(
            term in line.lower()
            for line in active_run_lines
            for term in ("gh release", "git tag", "git push")
        ) or any(
            action.lower().startswith(publication_actions)
            for action in uses_values
            if isinstance(action, str)
        ):
            errors.append(f"{name}: tag or release publication is forbidden")
        if _requests_write_permission(root):
            errors.append(f"{name}: workflow permissions must not grant write access")
    return errors
