"""Build deterministic closure evidence for the PTO management refactor."""

from __future__ import annotations

from collections import defaultdict
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tomllib

from scripts.adr_records import load_adrs, validate_adr_graph
from scripts.pr_timing import summarize_records


REQUIRED_SAMPLE_COUNT = 10
TIMING_BUDGET_SECONDS = 600.0
ACTIVE_ROOTS = (
    Path("asl"),
    Path("scripts"),
    Path("spec/catalog"),
    Path("tests/asl"),
)
IDENTITY_PATTERNS = {
    "PRD": re.compile(r"\bPRD-[0-9]{3}\b"),
    "PDR": re.compile(r"\bPDR-[0-9]{3}\b"),
    "PD": re.compile(r"\bPD-[0-9]{2}\b"),
}
REQUIRED_VERIFICATION_COMMANDS = (
    "make clean",
    "make pr-check",
    "make repo-check",
    "make setup",
    "python3 scripts/manual_semantic_audit.py",
    "make toolchain-check",
    "make check",
    "git diff --check",
    "git status --short",
)


def _git(root: Path, *arguments: str) -> str:
    return subprocess.check_output(
        ["git", *arguments], cwd=root, text=True, stderr=subprocess.DEVNULL
    ).strip()


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def collect_timing_records(root: Path) -> tuple[dict[str, object], ...]:
    records: list[dict[str, object]] = []
    for path in sorted(root.rglob("worker-*.json")) if root.exists() else []:
        try:
            value = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise ValueError(f"invalid timing record {path}: {error}") from error
        if not isinstance(value, dict):
            raise ValueError(f"invalid timing record {path}: expected object")
        records.append(value)
    return tuple(records)


def summarize_timing(records: tuple[dict[str, object], ...]) -> dict[str, object]:
    try:
        summary = summarize_records(records, TIMING_BUDGET_SECONDS)
    except ValueError as error:
        if "does not contain both" in str(error):
            raise ValueError("timing run must contain both worker timings") from error
        raise
    if summary["sample_count"] < REQUIRED_SAMPLE_COUNT:
        raise ValueError("closure requires at least 10 hosted timing samples")
    if summary["p95_seconds"] > TIMING_BUDGET_SECONDS:
        raise ValueError("hosted timing P95 exceeds 600 seconds")

    workers: dict[str, dict[str, float]] = defaultdict(dict)
    for record in records:
        workers[str(record["run_id"])][str(record["worker"])] = float(
            record["duration_seconds"]
        )
    runs = [
        {
            "run_id": run_id,
            "run_url": (
                "https://github.com/PTO-ISA/pto-spec/actions/runs/"
                + run_id.split("-", maxsplit=1)[0]
            ),
            "source_contract_seconds": values["source-contract"],
            "tooling_tests_seconds": values["tooling-tests"],
            "critical_path_seconds": max(values.values()),
        }
        for run_id, values in sorted(workers.items())
    ]
    workflow_runs = {run["run_id"].split("-", maxsplit=1)[0] for run in runs}
    if len(workflow_runs) < 5:
        raise ValueError("closure timing must cover at least 5 workflow run IDs")
    return {**summary, "workflow_run_count": len(workflow_runs), "runs": runs}


def _active_paths(root: Path) -> tuple[Path, ...]:
    paths: list[Path] = []
    for relative in ACTIVE_ROOTS:
        absolute = root / relative
        if absolute.is_file():
            paths.append(absolute)
        elif absolute.is_dir():
            paths.extend(path for path in absolute.rglob("*") if path.is_file())
    profile_hooks = root / "spec/profile-hooks.json"
    if profile_hooks.is_file():
        paths.append(profile_hooks)
    excluded = {
        root / "scripts/generate-management-system-refactor-closure",
        root / "scripts/management_refactor_closure.py",
    }
    return tuple(sorted(set(paths) - excluded))


def active_semantic_identity_count(root: Path, identity: str) -> int:
    pattern = IDENTITY_PATTERNS[identity]
    return sum(
        len(pattern.findall(path.read_text(encoding="utf-8", errors="replace")))
        for path in _active_paths(root)
    )


def _normalized_asl(text: str) -> str:
    return "\n".join(
        content
        for line in text.splitlines()
        if (content := line.split("//", 1)[0].strip())
    )


def semantic_surface_changed(
    root: Path, baseline_commit: str, head_commit: str
) -> bool:
    head = _git(root, "rev-parse", head_commit)
    changed = _git(root, "diff", "--name-only", baseline_commit, head, "--", "asl")
    for relative in filter(None, changed.splitlines()):
        try:
            before = _git(root, "show", f"{baseline_commit}:{relative}")
            after = _git(root, "show", f"{head}:{relative}")
        except subprocess.CalledProcessError:
            return True
        if _normalized_asl(before) != _normalized_asl(after):
            return True
    encoding_paths = (
        "spec/catalog/command-forms.json",
        "spec/catalog/extension-encoding-reservations.json",
        "spec/catalog/scalar-forms.json",
        "spec/catalog/system-registers.json",
        "spec/catalog/tile-operations.json",
        "spec/profile-hooks.json",
    )
    comparison = subprocess.run(
        [
            "git",
            "diff",
            "--quiet",
            baseline_commit,
            head,
            "--",
            *encoding_paths,
        ],
        cwd=root,
        check=False,
    )
    if comparison.returncode not in (0, 1):
        raise ValueError("cannot compare the encoding surface")
    return comparison.returncode == 1


def _verification(path: Path, head: str) -> dict[str, object]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("status") != "passed" or document.get("head_commit") != head:
        raise ValueError("verification evidence does not match the implementation head")
    commands = document.get("commands")
    if not isinstance(commands, list) or any(
        not any(str(command).startswith(required) for command in commands)
        for required in REQUIRED_VERIFICATION_COMMANDS
    ):
        raise ValueError("verification evidence is missing required commands")
    return document


def _nightly(event: dict[str, object] | None) -> tuple[str, str | None]:
    if event is None:
        return "awaiting-upstream", None
    commit = event.get("commit")
    if (
        event.get("result") != "success"
        or not isinstance(commit, str)
        or re.fullmatch(r"[0-9a-f]{40}", commit) is None
    ):
        raise ValueError("nightly event must be a successful exact-commit result")
    return "closed", commit


def build_document(
    root: Path,
    *,
    baseline_commit: str,
    implementation_head: str,
    timing_root: Path,
    verification_path: Path,
    nightly_event: dict[str, object] | None,
) -> dict[str, object]:
    head = _git(root, "rev-parse", implementation_head)
    timing = summarize_timing(collect_timing_records(timing_root))
    verification = _verification(verification_path, head)
    status, nightly_commit = _nightly(nightly_event)
    records = load_adrs(root / "docs/status/decisions")
    graph_errors = validate_adr_graph(records)
    if graph_errors:
        raise ValueError("ADR graph is not closed: " + "; ".join(graph_errors))
    adr_index = json.loads(
        (root / "spec/evidence/adr-index.json").read_text(encoding="utf-8")
    )
    readiness = json.loads(
        (root / "spec/evidence/architecture-readiness.json").read_text(
            encoding="utf-8"
        )
    )
    manifest = json.loads(
        (root / "spec/release-manifest.json").read_text(encoding="utf-8")
    )
    specification = tomllib.loads(
        (root / "specification.toml").read_text(encoding="utf-8")
    )
    codeowners = (
        (root / ".github/CODEOWNERS").read_text(encoding="utf-8").strip()
    )
    if codeowners != "* @zhoubot":
        raise ValueError("CODEOWNERS is not solely owned by zhoubot")
    if (root / "docs/status/legacy").exists():
        raise ValueError("legacy documentation tree is still active")
    legacy = adr_index["legacy_map"]
    legacy_counts = {
        "prd": sum(re.fullmatch(r"PRD-[0-9]{3}", key) is not None for key in legacy),
        "pdr": sum(re.fullmatch(r"PDR-[0-9]{3}", key) is not None for key in legacy),
        "pd": sum(re.fullmatch(r"PD-[0-9]{2}", key) is not None for key in legacy),
    }
    if legacy_counts != {"prd": 183, "pdr": 0, "pd": 12}:
        raise ValueError(f"legacy mapping is incomplete: {legacy_counts}")
    active_counts = {
        identity: active_semantic_identity_count(root, identity)
        for identity in ("PRD", "PDR", "PD")
    }
    if any(active_counts.values()):
        raise ValueError(f"active legacy identities remain: {active_counts}")
    sources = (
        "spec/evidence/adr-index.json",
        "spec/evidence/architecture-readiness.json",
        "spec/release-selection.json",
    )
    semantic_changed = semantic_surface_changed(root, baseline_commit, head)
    if semantic_changed:
        raise ValueError("management refactor changed the semantic surface")
    required_routes = (
        "README.md",
        "docs/development/getting-started.md",
        "docs/development/repository-layout.md",
        "docs/governance/adr-process.md",
        "docs/governance/validation.md",
        "docs/releases/index.md",
        "docs/status/open/index.md",
    )
    missing_routes = [relative for relative in required_routes if not (root / relative).is_file()]
    if missing_routes:
        raise ValueError(f"professional documentation route missing: {missing_routes[0]}")
    container_management_present = (root / ".devcontainer").exists()
    if container_management_present:
        raise ValueError("duplicate container-management layer is present")
    return {
        "schema": "pto.management-refactor-closure",
        "status": status,
        "baseline_commit": baseline_commit,
        "head_commit": head,
        "semantic_surface_changed": semantic_changed,
        "active_prd_count": active_counts["PRD"],
        "active_pdr_count": active_counts["PDR"],
        "active_pd_count": active_counts["PD"],
        "adr_schema_status": "closed",
        "adr_record_count": len(records),
        "legacy_mapping": {**legacy_counts, "total": len(legacy)},
        "readiness": {
            "status": readiness["summary"]["status"],
            "stage_counts": readiness["summary"]["stage_counts"],
        },
        "pr_timing": timing,
        "local_verification": verification,
        "nightly_health_commit": nightly_commit,
        "release_identity": {
            "architecture_version": specification["release"]["architecture_version"],
            "encoding_abi": manifest["encoding_abi"],
            "encoding_projection_sha256": manifest["encoding_projection_sha256"],
        },
        "codeowners": ["zhoubot"],
        "container_management_present": container_management_present,
        "legacy_tree_present": False,
        "sources": [
            {"path": relative, "sha256": _sha256(root / relative)}
            for relative in sources
        ],
    }


def render_document(document: dict[str, object]) -> str:
    return json.dumps(document, indent=2, sort_keys=True) + "\n"
