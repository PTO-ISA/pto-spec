#!/usr/bin/env python3
"""Semantic checks for lightweight PR and exact-head release workflows."""

from __future__ import annotations

import re


JOB_HEADER = re.compile(r"^  ([a-z][a-z0-9-]*):\s*$", re.MULTILINE)

PR_GATES = (
    "./scripts/check-asl-layout",
    "./scripts/check-ndf",
    "./scripts/check-asl-tests",
    "python3 scripts/project_asl_catalogs.py --root . --check",
    "python3 scripts/instruction_docs.py --check",
    "python3 scripts/check-publication-hygiene",
)


def _job_block(workflow: str, name: str) -> str:
    matches = list(JOB_HEADER.finditer(workflow))
    for index, match in enumerate(matches):
        if match.group(1) != name:
            continue
        end = matches[index + 1].start() if index + 1 < len(matches) else len(workflow)
        return workflow[match.start() : end]
    return ""


def _event_block(workflow: str) -> str:
    match = re.search(
        r"^on:\s*\n(?P<body>.*?)(?=^[a-z][a-z0-9_-]*:\s*$)",
        workflow,
        re.MULTILINE | re.DOTALL,
    )
    return match.group("body") if match else ""


def _standalone_run_position(job: str, command: str) -> int | None:
    """Return the offset of an exact one-line GitHub Actions run command."""

    match = re.search(
        rf"^(?:      - run:|        run:)\s*{re.escape(command)}\s*$",
        job,
        re.MULTILINE,
    )
    return match.start() if match else None


def validate_pr_workflow(workflow: str) -> list[str]:
    """Return violations of the intentionally lightweight PR contract."""

    errors: list[str] = []
    for gate in PR_GATES:
        if gate not in workflow:
            errors.append(f"PR workflow must run lightweight gate {gate}")
    lowered = workflow.lower()
    forbidden = (
        "aslref",
        "setup-ocaml",
        "make setup",
        "run-asl-test",
        "assemble-asl",
        "toolchain-check",
        "release-check",
    )
    if any(token in lowered for token in forbidden):
        errors.append("PR workflow must not install or execute ASLRef")
    return errors


def validate_release_workflow(workflow: str) -> list[str]:
    """Return fail-closed contract violations for release verification."""

    errors: list[str] = []
    events = _event_block(workflow)
    if "workflow_dispatch:" not in events or any(
        re.search(rf"^  {event}:\s*$", events, re.MULTILINE)
        for event in ("push", "pull_request", "schedule", "workflow_call")
    ):
        errors.append("release verification must be manually dispatched only")
    if not re.search(r"^      commit:\s*$", events, re.MULTILINE) or not re.search(
        r"^        required:\s*true\s*$", events, re.MULTILINE
    ):
        errors.append("workflow_dispatch must require a commit input")

    plan = _job_block(workflow, "plan")
    if not re.search(r"\[\[.*\^\[0-9a-f\]\{40\}\$.*\]\]", plan):
        errors.append(
            "plan must reject any commit that is not 40 lowercase hexadecimal characters"
        )
    if not re.search(
        r"^\s+ref:\s*\$\{\{\s*inputs\.commit\s*\}\}\s*$", plan, re.MULTILINE
    ):
        errors.append("plan checkout must use the exact commit input")
    if "git rev-parse HEAD" not in plan or "make pr-check" not in plan:
        errors.append(
            "plan must prove the checked-out exact head and run the PR contract"
        )
    if (
        "outputs:" not in plan
        or "GITHUB_OUTPUT" not in plan
        or "print-asl-test-matrix" not in plan
        or "pages:" not in plan
    ):
        errors.append(
            "plan must derive and export every page from print-asl-test-matrix"
        )
    if "planned-asl-test-pages" not in plan or not re.search(
        r"actions/upload-artifact@[0-9a-f]{40}", plan
    ):
        errors.append("plan must upload the exact planned ASL matrix pages")

    strict_model = _job_block(workflow, "strict-model")
    if not re.search(r"ocaml/setup-ocaml@[0-9a-f]{40}", strict_model):
        errors.append("strict-model must use a commit-pinned OCaml setup action")
    if (
        _standalone_run_position(strict_model, "make setup") is None
        or "make toolchain-check check" not in strict_model
    ):
        errors.append(
            "strict-model must run setup, toolchain canaries, and the normative model"
        )

    page = _job_block(workflow, "asl-page")
    if not re.search(r"fail-fast:\s*false", page):
        errors.append("ASL pages must record every result with fail-fast disabled")
    if not re.search(
        r"page:\s*\$\{\{\s*fromJSON\(needs\.plan\.outputs\.pages\)\s*\}\}", page
    ):
        errors.append("ASL jobs must consume the exact page matrix exported by plan")
    if "print-asl-test-matrix" not in page:
        errors.append("each ASL page must regenerate its print-asl-test-matrix page")
    setup_position = _standalone_run_position(page, "make setup")
    execution_position = page.find("run-asl-test --id")
    if (
        setup_position is None
        or execution_position < 0
        or setup_position > execution_position
    ):
        errors.append(
            "each ASL page must prepare pinned ASLRef before parallel test execution"
        )
    if not re.search(r"^\s*cmp\s+", page, re.MULTILINE):
        errors.append(
            "each ASL page must compare its regenerated page with the plan artifact"
        )
    if "run-asl-test --id" not in page:
        errors.append(
            "ASL pages must invoke run-asl-test --id for every independent point"
        )
    if len(re.findall(r"\brun-asl-test\b", page)) != 1 or len(
        re.findall(r"\bxargs\b", page)
    ) != 1:
        errors.append(
            "ASL pages must contain exactly one xargs invocation and one run-asl-test invocation"
        )
    if not re.search(
        r"^[ \t]*\|[ \t]+xargs[ \t]+-P[ \t]+4[ \t]+-n[ \t]+1[ \t]+"
        r"\./scripts/run-asl-test[ \t]+--id[ \t]*$",
        page,
        re.MULTILINE,
    ):
        errors.append(
            "ASL pages must execute independent points with four-way memory-safe parallelism"
        )
    if "asl-test-results" not in page or not re.search(
        r"actions/upload-artifact@[0-9a-f]{40}", page
    ):
        errors.append("ASL pages must upload per-ID result.json artifacts")

    evidence = _job_block(workflow, "release-evidence")
    if "run-asl-release-suite" not in evidence or "--aggregate-only" not in evidence:
        errors.append(
            "release-evidence must run fail-closed aggregate-only result validation"
        )
    if "planned-asl-test-pages" not in evidence or "asl-test-results" not in evidence:
        errors.append(
            "release-evidence must consume the planned matrix and every result artifact"
        )
    if "git diff --exit-code" not in evidence:
        errors.append(
            "release-evidence must prove regenerated exact-head evidence is clean"
        )
    if not re.search(r"actions/upload-artifact@[0-9a-f]{40}", evidence):
        errors.append(
            "release-evidence must upload evidence with a commit-pinned action"
        )
    if (
        "build/asl-test-matrix.json" not in evidence
        or "spec/evidence/asl-test-matrix.sha256" not in evidence
    ):
        errors.append(
            "release-evidence must upload the exact matrix and its checksum"
        )

    validate = _job_block(workflow, "validate")
    if "name: Release / validate" not in validate or "if: always()" not in validate:
        errors.append(
            "final release gate must be named Release / validate and always run"
        )
    needs_match = re.search(r"needs:\s*\[([^]]+)\]", validate)
    needs = (
        {item.strip() for item in needs_match.group(1).split(",")}
        if needs_match
        else set()
    )
    for job in ("plan", "strict-model", "asl-page", "release-evidence"):
        if job not in needs:
            errors.append(f"final release gate is missing its {job} dependency")
    for variable in (
        "PLAN_RESULT",
        "STRICT_MODEL_RESULT",
        "ASL_PAGE_RESULT",
        "RELEASE_EVIDENCE_RESULT",
    ):
        if not re.search(rf'test\s+"\${variable}"\s+=\s+success', validate):
            errors.append(
                f"final release gate must explicitly require {variable} = success"
            )

    lowered = workflow.lower()
    if any(
        term in lowered for term in ("gh release", "create-release", "git push --tags")
    ):
        errors.append("verification workflow must not create a tag or release")
    obsolete_terms = (
        "ASL_TEST_" + "SHARD",
        "test-" + "shard-",
        "check-asl-test-" + "shards",
    )
    if any(term in workflow for term in obsolete_terms):
        errors.append("release workflow must not use hand-maintained ASL shards")
    return errors
