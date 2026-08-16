#!/usr/bin/env python3
"""Semantic checks for lightweight PR and exact-head release workflows."""

from __future__ import annotations

import re


JOB_HEADER = re.compile(r"^  ([a-z][a-z0-9-]*):\s*$", re.MULTILINE)
STEP_HEADER = re.compile(r"^      - .*$", re.MULTILINE)
UPLOAD_ARTIFACT_SHA = "ea165f8d65b6e75b540449e92b4886f43607fa02"
CACHE_ACTION_SHA = "55cc8345863c7cc4c66a329aec7e433d2d1c52a9"
INVALID_STEP_USES = "<invalid-step-uses>"
YAML_ANCHOR_OR_ALIAS = re.compile(
    r"^[ \t]*(?:-[ \t]+)?(?:[A-Za-z0-9_-]+:[ \t]+)?"
    r"[&*][^ \t#\[\]{},]+(?:[ \t]+|$)",
    re.MULTILINE,
)

PR_GATES = (
    "./scripts/check-asl-layout",
    "./scripts/check-ndf",
    "./scripts/check-asl-tests",
    "./scripts/check-release-event-schema",
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


def _step_blocks(job: str) -> list[str]:
    matches = list(STEP_HEADER.finditer(job))
    return [
        job[match.start() : matches[index + 1].start()]
        if index + 1 < len(matches)
        else job[match.start() :]
        for index, match in enumerate(matches)
    ]


def _direct_mapping_values(step: str, mapping: str, key: str) -> list[str]:
    """Return direct scalar values below one step-level mapping."""

    lines = step.splitlines()
    header = f"        {mapping}:"
    headers = [index for index, line in enumerate(lines) if line == header]
    if len(headers) != 1:
        return []
    values: list[str] = []
    for line in lines[headers[0] + 1 :]:
        stripped = line.lstrip(" ")
        if not stripped or stripped.startswith("#"):
            continue
        indentation = len(line) - len(stripped)
        if indentation <= 8:
            break
        if indentation != 10:
            continue
        field, separator, value = stripped.partition(":")
        if separator and field == key:
            values.append(value.strip())
    return values


def _step_uses(step: str) -> str | None:
    values: list[str] = []
    for line in step.splitlines():
        match = re.fullmatch(r"(?:      - |        )uses:[ \t]*(.*)", line)
        if match is None:
            continue
        raw = match.group(1).strip()
        if not raw:
            return None
        if raw[0] in ("'", '"'):
            if "\\" in raw:
                return INVALID_STEP_USES
            quoted = re.fullmatch(
                r"(?P<quote>['\"])(?P<value>[^'\"]+)(?P=quote)(?:[ \t]+#.*)?",
                raw,
            )
            if quoted is None:
                return None
            values.append(quoted.group("value"))
        else:
            values.append(re.sub(r"[ \t]+#.*$", "", raw).strip())
    return values[0] if len(values) == 1 else None


def _standalone_run_position(job: str, command: str) -> int | None:
    """Return the offset of an exact one-line GitHub Actions run command."""

    match = re.search(
        rf"^(?:      - run:|        run:)\s*{re.escape(command)}\s*$",
        job,
        re.MULTILINE,
    )
    return match.start() if match else None


def _script_line_positions(job: str, command: str) -> list[int]:
    """Return offsets for exact commands inside one multi-line run script."""

    return [
        match.start()
        for match in re.finditer(
            rf"^[ ]{{10}}{re.escape(command)}[ \t]*$", job, re.MULTILINE
        )
    ]


def _job_needs(job: str) -> set[str]:
    list_match = re.search(r"^    needs:\s*\[([^]]+)\]\s*$", job, re.MULTILINE)
    if list_match:
        return {item.strip() for item in list_match.group(1).split(",")}
    scalar_match = re.search(r"^    needs:\s*([a-z][a-z0-9-]*)\s*$", job, re.MULTILINE)
    return {scalar_match.group(1)} if scalar_match else set()


def _has_exact_checkout(job: str) -> bool:
    return bool(
        re.search(r"actions/checkout@[0-9a-f]{40}", job)
        and re.search(
            r"^\s+ref:\s*\$\{\{\s*inputs\.commit\s*\}\}\s*$",
            job,
            re.MULTILINE,
        )
    )


def _has_timeout(job: str) -> bool:
    return bool(re.search(r"^    timeout-minutes:\s*[1-9][0-9]*\s*$", job, re.MULTILINE))


def _validate_toolchain_cache(job: str, name: str) -> list[str]:
    errors: list[str] = []
    steps = _step_blocks(job)
    cache_steps = [
        step
        for step in steps
        if (_step_uses(step) or "").startswith("actions/cache@")
    ]
    valid_cache_steps = [
        step
        for step in cache_steps
        if _step_uses(step) == f"actions/cache@{CACHE_ACTION_SHA}"
    ]
    if len(cache_steps) != 1 or len(valid_cache_steps) != 1:
        errors.append(f"{name} must use the commit-pinned verified ASLRef cache action")
        return errors
    cache_step = valid_cache_steps[0]
    paths = _direct_mapping_values(cache_step, "with", "path")
    keys = _direct_mapping_values(cache_step, "with", "key")
    required_key_terms = (
        "runner.os",
        "runner.arch",
        "ocaml-5.2.1",
        ".aslref-version",
        "scripts/setup-aslref",
        "scripts/prepare-aslref",
    )
    if paths != [".cache/herdtools7"] or len(keys) != 1 or any(
        term not in keys[0] for term in required_key_terms
    ):
        errors.append(
            f"{name} cache must bind the ASLRef path, platform, OCaml version, pin, and setup scripts"
        )
    setup_position = _standalone_run_position(job, "make setup")
    cache_position = job.find(cache_step)
    if setup_position is None or setup_position <= cache_position:
        errors.append(f"{name} must verify the pinned ASLRef checkout after cache restore")
    return errors


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
    if YAML_ANCHOR_OR_ALIAS.search(workflow):
        errors.append("release workflow must not use YAML anchors or aliases")
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

    job_names = (
        "identity",
        "pr-contract",
        "matrix-plan",
        "strict-model",
        "asl-page",
        "release-evidence",
        "validate",
    )
    jobs = {name: _job_block(workflow, name) for name in job_names}
    for name, job in jobs.items():
        if not job:
            errors.append(f"release workflow is missing the {name} job")
        elif not _has_timeout(job):
            errors.append(f"{name} must have an explicit timeout")

    identity = jobs["identity"]
    if not re.search(r"\[\[.*\^\[0-9a-f\]\{40\}\$.*\]\]", identity):
        errors.append(
            "identity must reject any commit that is not 40 lowercase hexadecimal characters"
        )
    if not _has_exact_checkout(identity) or "git rev-parse HEAD" not in identity:
        errors.append("identity must check out and prove the exact commit input")

    for name in ("pr-contract", "matrix-plan", "strict-model"):
        if _job_needs(jobs[name]) != {"identity"}:
            errors.append(f"{name} must start directly after identity")
        if not _has_exact_checkout(jobs[name]):
            errors.append(f"{name} must check out the exact commit input")

    pr_contract = jobs["pr-contract"]
    if "git rev-parse HEAD" not in pr_contract or "make pr-check" not in pr_contract:
        errors.append("pr-contract must prove the exact head and run make pr-check")
    if _standalone_run_position(
        pr_contract,
        "python3 scripts/manual_semantic_audit.py",
    ) is None:
        errors.append(
            "pr-contract must prove formal mnemonic implementation closure"
        )

    matrix_plan = jobs["matrix-plan"]
    if (
        "outputs:" not in matrix_plan
        or "GITHUB_OUTPUT" not in matrix_plan
        or matrix_plan.count("print-asl-test-matrix") != 1
        or "--output-dir" not in matrix_plan
        or "pages:" not in matrix_plan
    ):
        errors.append(
            "matrix-plan must export every page with one print-asl-test-matrix discovery"
        )
    if re.search(r"(?:^|\s)--page(?:\s|=)", matrix_plan):
        errors.append("matrix-plan must not regenerate pages in a serial loop")
    build_directory_positions = _script_line_positions(matrix_plan, "mkdir -p build")
    matrix_discovery_position = matrix_plan.find("./scripts/print-asl-test-matrix")
    if (
        len(build_directory_positions) != 1
        or matrix_discovery_position < 0
        or build_directory_positions[0] >= matrix_discovery_position
    ):
        errors.append(
            "matrix-plan must create build before redirecting the ASL plan index"
        )
    if "planned-asl-test-pages" not in matrix_plan or not re.search(
        r"actions/upload-artifact@[0-9a-f]{40}", matrix_plan
    ):
        errors.append("matrix-plan must upload the exact planned ASL matrix pages")

    strict_model = jobs["strict-model"]
    if not re.search(r"ocaml/setup-ocaml@[0-9a-f]{40}", strict_model):
        errors.append("strict-model must use a commit-pinned OCaml setup action")
    if "dune-cache: true" not in strict_model:
        errors.append("strict-model must enable the pinned OCaml dune cache")
    errors.extend(_validate_toolchain_cache(strict_model, "strict-model"))
    if (
        _standalone_run_position(strict_model, "make setup") is None
        or "make toolchain-check check" not in strict_model
    ):
        errors.append(
            "strict-model must run setup, toolchain canaries, and the normative model"
        )

    page = jobs["asl-page"]
    if _job_needs(page) != {"matrix-plan"}:
        errors.append("ASL pages must start from the completed matrix-plan")
    if not _has_exact_checkout(page):
        errors.append("ASL pages must check out the exact commit input")
    if not re.search(r"fail-fast:\s*false", page):
        errors.append("ASL pages must record every result with fail-fast disabled")
    if not re.search(
        r"page:\s*\$\{\{\s*fromJSON\(needs\.matrix-plan\.outputs\.pages\)\s*\}\}",
        page,
    ):
        errors.append("ASL jobs must consume the exact pages exported by matrix-plan")
    if "print-asl-test-matrix" in page or re.search(r"^\s*cmp\s+", page, re.MULTILINE):
        errors.append("ASL pages must execute the downloaded exact page without rediscovery")
    if "dune-cache: true" not in page:
        errors.append("ASL pages must enable the pinned OCaml dune cache")
    errors.extend(_validate_toolchain_cache(page, "ASL pages"))
    setup_position = _standalone_run_position(page, "make setup")
    jobs_command = 'ASL_TEST_JOBS="${PTO_ASL_TEST_JOBS:-$(getconf _NPROCESSORS_ONLN)}"'
    runner_command = (
        './scripts/run-asl-page --matrix "build/planned-asl-test-pages/page-${{ matrix.page }}.json" '
        '-j "$ASL_TEST_JOBS"'
    )
    reporter_command = (
        './scripts/report-asl-page-results --matrix "build/planned-asl-test-pages/'
        'page-${{ matrix.page }}.json" --results build/asl-test-results'
    )
    jobs_positions = _script_line_positions(page, jobs_command)
    runner_positions = _script_line_positions(page, runner_command)
    reporter_positions = _script_line_positions(page, reporter_command)
    execution_position = runner_positions[0] if len(runner_positions) == 1 else -1
    if (
        setup_position is None
        or execution_position < 0
        or setup_position > execution_position
    ):
        errors.append(
            "each ASL page must prepare pinned ASLRef before parallel test execution"
        )
    if len(runner_positions) != 1:
        errors.append(
            "ASL pages must invoke exactly one run-asl-page command for every independent point"
        )
    if len(runner_positions) != 1:
        errors.append("ASL pages must use -j configurable parallelism")
    if len(jobs_positions) != 1:
        errors.append(
            "ASL page parallelism must default to the machine core count with a PTO_ASL_TEST_JOBS override"
        )
    if len(reporter_positions) != 1 or (
        execution_position >= 0 and reporter_positions[0] <= execution_position
    ):
        errors.append(
            "ASL pages must report every ASL page result after parallel execution"
        )
    execution_status_positions = _script_line_positions(page, "execution_status=$?")
    report_status_positions = _script_line_positions(page, "report_status=$?")
    execution_gate_positions = _script_line_positions(
        page, 'test "$execution_status" = 0'
    )
    report_gate_positions = _script_line_positions(page, 'test "$report_status" = 0')
    set_plus_positions = _script_line_positions(page, "set +e")
    set_minus_positions = _script_line_positions(page, "set -e")
    execution_status_file = (
        "printf '%s\\n' \"$execution_status\" > build/asl-page-execution.status"
    )
    exact_execution_block = "\n".join(
        f"          {line}"
        for line in (
            "set +e",
            jobs_command,
            runner_command,
            "execution_status=$?",
            "set -e",
            execution_status_file,
        )
    )
    exact_report_block = "\n".join(
        f"          {line}"
        for line in (
            "set +e",
            reporter_command,
            "report_status=$?",
            "set -e",
            "test -f build/asl-page-execution.status",
            "read -r execution_status < build/asl-page-execution.status",
            'test "$execution_status" = 0',
            'test "$report_status" = 0',
        )
    )
    if exact_execution_block not in page or exact_report_block not in page:
        errors.append(
            "ASL pages must use separate contiguous fail-closed execution and report blocks"
        )
    if not (
        len(set_plus_positions) == 2
        and len(execution_status_positions) == 1
        and execution_position >= 0
        and set_plus_positions[0] < execution_position < execution_status_positions[0]
    ):
        errors.append(
            "ASL pages must capture the parallel execution status fail-closed"
        )
    if not (
        len(report_status_positions) == 1
        and len(reporter_positions) == 1
        and reporter_positions[0] < report_status_positions[0]
    ):
        errors.append("ASL pages must capture the page report status fail-closed")
    if len(execution_gate_positions) != 1:
        errors.append("ASL pages must explicitly require the execution status to pass")
    if len(report_gate_positions) != 1:
        errors.append("ASL pages must explicitly require the report status to pass")
    if not (
        len(set_minus_positions) == 2
        and len(execution_gate_positions) == 1
        and len(report_gate_positions) == 1
        and len(report_status_positions) == 1
        and len(reporter_positions) == 1
        and report_status_positions[0] < set_minus_positions[1]
        and execution_status_positions[0] < set_minus_positions[0]
        and set_minus_positions[0] < reporter_positions[0]
        and set_minus_positions[1]
        < execution_gate_positions[0]
        < report_gate_positions[0]
    ):
        errors.append(
            "ASL pages must restore fail-fast mode before checking execution and report statuses"
        )
    report_steps = [step for step in _step_blocks(page) if reporter_command in step]
    if len(report_steps) != 1 or "        if: always()" not in report_steps[0]:
        errors.append("ASL page reporting must be a distinct always-run step")
    if re.search(r"\bxargs\b|\brun-asl-test\b", page):
        errors.append(
            "ASL pages must use the repository page runner instead of shell-level xargs"
        )
    page_steps = _step_blocks(page)
    if any(_step_uses(step) == INVALID_STEP_USES for step in page_steps):
        errors.append("ASL page uses values must not contain YAML escapes")
    upload_steps = [
        step
        for step in page_steps
        if (_step_uses(step) or "").startswith("actions/upload-artifact@")
    ]
    result_uploads = (
        [
            step
            for step in upload_steps
            if _step_uses(step) == f"actions/upload-artifact@{UPLOAD_ARTIFACT_SHA}"
        ]
        if len(upload_steps) == 1
        else []
    )
    result_names = (
        _direct_mapping_values(result_uploads[0], "with", "name")
        if len(result_uploads) == 1
        else []
    )
    result_paths = (
        _direct_mapping_values(result_uploads[0], "with", "path")
        if len(result_uploads) == 1
        else []
    )
    if result_names != ["asl-test-results-${{ matrix.page }}"] or result_paths != [
        "build/asl-test-results/*/result.json"
    ]:
        errors.append("ASL pages must upload only per-ID result.json artifacts")

    evidence = jobs["release-evidence"]
    evidence_needs = _job_needs(evidence)
    for dependency in ("pr-contract", "matrix-plan", "strict-model", "asl-page"):
        if dependency not in evidence_needs:
            errors.append(f"release-evidence is missing its {dependency} dependency")
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
        errors.append("release-evidence must upload the exact matrix and its checksum")

    validate = jobs["validate"]
    if "name: Release / validate" not in validate or "if: always()" not in validate:
        errors.append(
            "final release gate must be named Release / validate and always run"
        )
    needs = _job_needs(validate)
    for job in job_names[:-1]:
        if job not in needs:
            errors.append(f"final release gate is missing its {job} dependency")
    for variable in (
        "IDENTITY_RESULT",
        "PR_CONTRACT_RESULT",
        "MATRIX_PLAN_RESULT",
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
