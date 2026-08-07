#!/usr/bin/env python3
"""Semantic checks for the exact-head manual release verification workflow."""

from __future__ import annotations

import re


JOB_HEADER = re.compile(r"^  ([a-z][a-z0-9-]*):\s*$", re.MULTILINE)


def _job_block(workflow: str, name: str) -> str:
    matches = list(JOB_HEADER.finditer(workflow))
    for index, match in enumerate(matches):
        if match.group(1) != name:
            continue
        end = matches[index + 1].start() if index + 1 < len(matches) else len(workflow)
        return workflow[match.start() : end]
    return ""


def _event_block(workflow: str) -> str:
    match = re.search(r"^on:\s*\n(?P<body>.*?)(?=^[a-z][a-z0-9_-]*:\s*$)", workflow, re.MULTILINE | re.DOTALL)
    return match.group("body") if match else ""


def validate_release_workflow(workflow: str) -> list[str]:
    """Return fail-closed contract violations for a release workflow."""

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
        errors.append("plan must reject any commit that is not 40 lowercase hexadecimal characters")
    if not re.search(r"^\s+ref:\s*\$\{\{\s*inputs\.commit\s*\}\}\s*$", plan, re.MULTILINE):
        errors.append("plan checkout must use the exact commit input")
    if "git rev-parse HEAD" not in plan or "make pr-check" not in plan:
        errors.append("plan must prove the checked-out exact head and run the PR contract")
    if "outputs:" not in plan or "GITHUB_OUTPUT" not in plan or "print-asl-test-shard-names" not in plan:
        errors.append("plan must export the repository-derived shard matrix")

    strict_model = _job_block(workflow, "strict-model")
    if not re.search(r"ocaml/setup-ocaml@[0-9a-f]{40}", strict_model):
        errors.append("strict-model must use a commit-pinned OCaml setup action")
    if "make setup" not in strict_model or "make toolchain-check check" not in strict_model:
        errors.append("strict-model must run setup, toolchain canaries, and the normative model")

    shard = _job_block(workflow, "asl-shard")
    if not re.search(r"fail-fast:\s*false", shard):
        errors.append("ASL shards must record every result with fail-fast disabled")
    if not re.search(r"shard:\s*\$\{\{\s*fromJSON\(needs\.plan\.outputs\.shards\)\s*\}\}", shard):
        errors.append("ASL jobs must consume the exact shard matrix exported by plan")
    if 'test-shard-${{ matrix.shard }}' not in shard:
        errors.append("ASL matrix entries must execute their exact shard target")

    evidence = _job_block(workflow, "release-evidence")
    if "make release-prepare" not in evidence:
        errors.append("release-evidence must reproduce and check release artifacts")
    if not re.search(r"actions/upload-artifact@[0-9a-f]{40}", evidence):
        errors.append("release-evidence must upload evidence with a commit-pinned action")

    validate = _job_block(workflow, "validate")
    if "name: Release / validate" not in validate or "if: always()" not in validate:
        errors.append("final release gate must be named Release / validate and always run")
    needs_match = re.search(r"needs:\s*\[([^]]+)\]", validate)
    needs = {item.strip() for item in needs_match.group(1).split(",")} if needs_match else set()
    for job in ("plan", "strict-model", "asl-shard", "release-evidence"):
        if job not in needs:
            errors.append(f"final release gate is missing its {job} dependency")
    for variable in ("PLAN_RESULT", "STRICT_MODEL_RESULT", "ASL_SHARD_RESULT", "RELEASE_EVIDENCE_RESULT"):
        if not re.search(rf'test\s+"\${variable}"\s+=\s+success', validate):
            errors.append(f"final release gate must explicitly require {variable} = success")

    lowered = workflow.lower()
    if any(term in lowered for term in ("gh release", "create-release", "git push --tags")):
        errors.append("verification workflow must not create a tag or release")
    return errors
