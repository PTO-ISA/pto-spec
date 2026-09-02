#!/usr/bin/env python3
"""Validate PTO 0.58.5 compiler-to-ASL model closure evidence."""

from __future__ import annotations

from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tomllib
from typing import Any


SEMANTIC_SCHEMA = "pto-closure-semantic-payload-v1"
ENVELOPE_SCHEMA = "pto-closure-run-envelope-v1"
LOCK_SCHEMA = "pto-closure-lock-v1"
SHA256 = re.compile(r"[0-9a-f]{64}")
COMMIT = re.compile(r"[0-9a-f]{40}")
UTC_TIMESTAMP = re.compile(
    r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z"
)


def canonical_json(value: object) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"))


def canonical_sha256(value: object) -> str:
    return hashlib.sha256(canonical_json(value).encode("utf-8")).hexdigest()


def invocation_path(path: Path) -> Path:
    """Make a command path absolute without dereferencing a driver symlink."""

    return path.absolute()


def _exact_object(
    value: object, label: str, fields: tuple[str, ...], errors: list[str]
) -> dict[str, Any]:
    if not isinstance(value, dict):
        errors.append(f"{label} must be an object")
        return {}
    missing = sorted(set(fields) - set(value))
    extra = sorted(set(value) - set(fields))
    errors.extend(f"{label} is missing {field}" for field in missing)
    errors.extend(f"{label} has additional field {field}" for field in extra)
    return value


def _digest(value: object, label: str, errors: list[str]) -> None:
    if not isinstance(value, str) or SHA256.fullmatch(value) is None:
        errors.append(f"{label} must be 64 lowercase hexadecimal characters")


def _commit(value: object, label: str, errors: list[str]) -> None:
    if not isinstance(value, str) or COMMIT.fullmatch(value) is None:
        errors.append(f"{label} must be 40 lowercase hexadecimal characters")


def _text(value: object, label: str, errors: list[str]) -> None:
    if not isinstance(value, str) or not value:
        errors.append(f"{label} must be non-empty text")


def _sorted_strings(
    value: object, label: str, errors: list[str], *, allow_empty: bool = True
) -> list[str]:
    if (
        not isinstance(value, list)
        or any(not isinstance(item, str) or not item for item in value)
    ):
        errors.append(f"{label} must be an array of non-empty strings")
        return []
    if not allow_empty and not value:
        errors.append(f"{label} must not be empty")
    if value != sorted(set(value)):
        errors.append(f"{label} must be sorted and unique")
    return value


def _repository(
    value: object,
    label: str,
    errors: list[str],
    *,
    expected_repository: str,
    expected_commit: str | None = None,
    expected_tree: str | None = None,
) -> None:
    row = _exact_object(value, label, ("repository", "commit", "tree"), errors)
    if row.get("repository") != expected_repository:
        errors.append(f"{label}.repository must be {expected_repository!r}")
    _commit(row.get("commit"), f"{label}.commit", errors)
    _commit(row.get("tree"), f"{label}.tree", errors)
    if expected_commit is not None and row.get("commit") != expected_commit:
        errors.append(f"{label}.commit does not match the release candidate")
    if expected_tree is not None and row.get("tree") != expected_tree:
        errors.append(f"{label}.tree does not match the release candidate")


def validate_lock(lock: object, expected: dict[str, str]) -> list[str]:
    errors: list[str] = []
    row = _exact_object(
        lock,
        "closure lock",
        (
            "schema",
            "identity",
            "repositories",
            "tools",
            "target",
            "model",
            "corpus",
            "obligations",
        ),
        errors,
    )
    if row.get("schema") != LOCK_SCHEMA:
        errors.append(f"closure lock schema must be {LOCK_SCHEMA!r}")

    identity = _exact_object(
        row.get("identity"),
        "closure lock identity",
        ("release", "publication_version", "encoding_abi", "encoding_projection_sha256"),
        errors,
    )
    for field in ("release", "publication_version", "encoding_abi"):
        if identity.get(field) != expected[field]:
            errors.append(f"closure lock identity {field} mismatch")
    _digest(identity.get("encoding_projection_sha256"), "encoding projection", errors)
    if identity.get("encoding_projection_sha256") != expected["encoding_projection_sha256"]:
        errors.append("closure lock identity encoding projection mismatch")

    repositories = _exact_object(
        row.get("repositories"),
        "closure lock repositories",
        ("pto_spec", "llvm", "asl_model", "normative_language", "aslref"),
        errors,
    )
    _repository(
        repositories.get("pto_spec"),
        "PTO-SPEC repository",
        errors,
        expected_repository="https://github.com/PTO-ISA/pto-spec.git",
        expected_commit=expected["pto_commit"],
        expected_tree=expected["pto_tree"],
    )
    _repository(
        repositories.get("llvm"),
        "LLVM repository",
        errors,
        expected_repository=expected["llvm_repository"],
        expected_commit=expected["llvm_commit"],
    )
    _repository(
        repositories.get("asl_model"),
        "ASL-MODEL repository",
        errors,
        expected_repository="https://github.com/PTO-ISA/asl-model.git",
        expected_commit=expected["asl_model_commit"],
    )
    _repository(
        repositories.get("normative_language"),
        "normative_language repository",
        errors,
        expected_repository="https://github.com/PTO-ISA/normative_language.git",
        expected_commit=expected["ndf_commit"],
        expected_tree=expected.get("ndf_tree"),
    )
    _repository(
        repositories.get("aslref"),
        "ASLRef repository",
        errors,
        expected_repository="https://github.com/herd/herdtools7.git",
        expected_commit=expected["aslref_commit"],
    )

    tools = _exact_object(
        row.get("tools"), "closure lock tools", ("clang", "llvm_mc", "ld_lld", "aslref"), errors
    )
    for name in ("clang", "llvm_mc", "ld_lld", "aslref"):
        tool = _exact_object(tools.get(name), f"tool {name}", ("path", "sha256"), errors)
        _text(tool.get("path"), f"tool {name}.path", errors)
        _digest(tool.get("sha256"), f"tool {name}.sha256", errors)

    target = _exact_object(row.get("target"), "closure lock target", ("triple",), errors)
    _text(target.get("triple"), "closure lock target triple", errors)
    model = _exact_object(
        row.get("model"),
        "closure lock model",
        ("abi", "worker_protocol", "backend", "profile"),
        errors,
    )
    if model.get("abi") != "pto-asl-model-experimental-v2":
        errors.append("closure lock model ABI mismatch")
    if model.get("worker_protocol") != "pto-asl-worker-v1":
        errors.append("closure lock worker protocol mismatch")
    _text(model.get("backend"), "closure lock model backend", errors)
    _text(model.get("profile"), "closure lock model profile", errors)

    corpus = _exact_object(row.get("corpus"), "closure lock corpus", ("sha256", "case_ids"), errors)
    _digest(corpus.get("sha256"), "closure lock corpus digest", errors)
    _sorted_strings(corpus.get("case_ids"), "closure lock case IDs", errors, allow_empty=False)
    obligations = _exact_object(
        row.get("obligations"),
        "closure lock obligations",
        ("affected_pto_ids", "selected", "sha256"),
        errors,
    )
    _sorted_strings(obligations.get("affected_pto_ids"), "affected PTO IDs", errors)
    selected = _sorted_strings(
        obligations.get("selected"), "selected obligations", errors, allow_empty=False
    )
    _digest(obligations.get("sha256"), "selected obligation digest", errors)
    if obligations.get("sha256") != canonical_sha256(selected):
        errors.append("selected obligation digest mismatch")
    return sorted(set(errors))


def validate_semantic_payload(payload: object, expected: dict[str, str]) -> list[str]:
    errors: list[str] = []
    row = _exact_object(
        payload,
        "semantic payload",
        (
            "schema",
            "closure_lock",
            "closure_lock_sha256",
            "ndf_impact",
            "obligations",
            "cases",
            "case_manifests",
        ),
        errors,
    )
    if row.get("schema") != SEMANTIC_SCHEMA:
        errors.append(f"semantic payload schema must be {SEMANTIC_SCHEMA!r}")
    lock = row.get("closure_lock")
    errors.extend(validate_lock(lock, expected))
    _digest(row.get("closure_lock_sha256"), "closure lock digest", errors)
    if isinstance(lock, dict) and row.get("closure_lock_sha256") != canonical_sha256(lock):
        errors.append("closure lock digest mismatch")

    impact = _exact_object(
        row.get("ndf_impact"), "NDF impact", ("sha256", "affected_pto_ids"), errors
    )
    _digest(impact.get("sha256"), "NDF impact digest", errors)
    affected = _sorted_strings(impact.get("affected_pto_ids"), "NDF affected PTO IDs", errors)

    lock_obligations = lock.get("obligations", {}) if isinstance(lock, dict) else {}
    if affected != lock_obligations.get("affected_pto_ids"):
        errors.append("NDF affected PTO IDs do not match the closure lock")

    obligations = _exact_object(
        row.get("obligations"),
        "semantic payload obligations",
        ("selected", "completed", "passed", "failed"),
        errors,
    )
    obligation_sets = {
        name: _sorted_strings(obligations.get(name), f"obligations.{name}", errors)
        for name in ("selected", "completed", "passed", "failed")
    }
    if obligation_sets["selected"] != lock_obligations.get("selected"):
        errors.append("selected obligations do not match the closure lock")
    if not (
        obligation_sets["selected"]
        == obligation_sets["completed"]
        == obligation_sets["passed"]
    ):
        errors.append("selected, completed, and passed obligation sets must be equal")
    if obligation_sets["failed"]:
        errors.append("failed obligation set must be empty")

    cases = _exact_object(
        row.get("cases"),
        "semantic payload cases",
        ("selected", "completed", "passed", "failed", "skipped", "timeout", "unknown"),
        errors,
    )
    case_sets = {
        name: _sorted_strings(cases.get(name), f"cases.{name}", errors)
        for name in ("selected", "completed", "passed", "failed", "skipped", "timeout", "unknown")
    }
    lock_cases = lock.get("corpus", {}).get("case_ids") if isinstance(lock, dict) else None
    if case_sets["selected"] != lock_cases:
        errors.append("selected cases do not match the closure lock")
    if not (case_sets["selected"] == case_sets["completed"] == case_sets["passed"]):
        errors.append("selected, completed, and passed case sets must be equal")
    for name in ("failed", "skipped", "timeout", "unknown"):
        if case_sets[name]:
            errors.append(f"{name} case set must be empty")

    manifests = row.get("case_manifests")
    if not isinstance(manifests, list):
        errors.append("case_manifests must be an array")
        manifests = []
    manifest_ids: list[str] = []
    for index, manifest_value in enumerate(manifests):
        manifest = _exact_object(
            manifest_value, f"case_manifests[{index}]", ("case_id", "sha256"), errors
        )
        _text(manifest.get("case_id"), f"case_manifests[{index}].case_id", errors)
        _digest(manifest.get("sha256"), f"case_manifests[{index}].sha256", errors)
        if isinstance(manifest.get("case_id"), str):
            manifest_ids.append(manifest["case_id"])
    if manifest_ids != sorted(set(manifest_ids)):
        errors.append("case manifests must be sorted by unique case ID")
    if manifest_ids != case_sets["selected"]:
        errors.append("case manifest IDs must equal selected cases")
    return sorted(set(errors))


def validate_run_envelope(
    envelope: object,
    payload: object,
    expected: dict[str, str],
    *,
    expected_run_id: str | None = None,
    expected_run_attempt: str | None = None,
) -> list[str]:
    errors: list[str] = []
    row = _exact_object(
        envelope,
        "run envelope",
        ("schema", "semantic_payload_sha256", "workflow", "run", "runner", "artifact_sha256", "attestation"),
        errors,
    )
    if row.get("schema") != ENVELOPE_SCHEMA:
        errors.append(f"run envelope schema must be {ENVELOPE_SCHEMA!r}")
    _digest(row.get("semantic_payload_sha256"), "semantic payload digest", errors)
    if row.get("semantic_payload_sha256") != canonical_sha256(payload):
        errors.append("run envelope semantic payload digest mismatch")
    workflow = _exact_object(
        row.get("workflow"), "run envelope workflow", ("repository", "path", "commit"), errors
    )
    if workflow.get("repository") != "PTO-ISA/pto-spec":
        errors.append("run envelope workflow repository mismatch")
    if workflow.get("path") != ".github/workflows/release.yml":
        errors.append("run envelope workflow path mismatch")
    _commit(workflow.get("commit"), "run envelope workflow commit", errors)
    if workflow.get("commit") != expected["workflow_commit"]:
        errors.append("run envelope workflow commit mismatch")
    run = _exact_object(row.get("run"), "run envelope run", ("id", "attempt", "timestamp"), errors)
    _text(run.get("id"), "run envelope run ID", errors)
    if not isinstance(run.get("attempt"), int) or isinstance(run.get("attempt"), bool) or run.get("attempt", 0) < 1:
        errors.append("run envelope attempt must be a positive integer")
    timestamp = run.get("timestamp")
    if not isinstance(timestamp, str) or UTC_TIMESTAMP.fullmatch(timestamp) is None:
        errors.append("run envelope timestamp must be whole-second UTC")
    else:
        try:
            datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            errors.append("run envelope timestamp must be valid")
    if expected_run_id is not None and run.get("id") != expected_run_id:
        errors.append("run envelope run ID mismatch")
    if expected_run_attempt is not None and run.get("attempt") != int(expected_run_attempt):
        errors.append("run envelope run attempt mismatch")
    runner = _exact_object(
        row.get("runner"), "run envelope runner", ("image", "builder_identity"), errors
    )
    _text(runner.get("image"), "run envelope runner image", errors)
    _text(runner.get("builder_identity"), "run envelope builder identity", errors)
    _digest(row.get("artifact_sha256"), "run envelope artifact digest", errors)
    if row.get("attestation") is not None:
        errors.append("bootstrap release closure must not accept external attestation")
    return sorted(set(errors))


def _git(root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        ["git", "-C", str(root), *arguments],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return completed.stdout.strip()


def _ndf_commit(root: Path) -> str:
    text = (root / "ndf.lock").read_text(encoding="utf-8")
    matches = re.findall(r"^\s+revision:\s+([0-9a-f]{40})\s*$", text, re.MULTILINE)
    if len(matches) != 1:
        raise ValueError("ndf.lock must contain exactly one 40-hex revision")
    return matches[0]


def repository_expectations(
    root: Path,
    *,
    pto_commit: str,
    llvm_repository: str,
    llvm_commit: str,
    asl_model_commit: str,
    workflow_commit: str,
) -> dict[str, str]:
    specification = tomllib.loads((root / "specification.toml").read_text(encoding="utf-8"))
    release = specification["release"]
    manifest = json.loads((root / "spec/release-manifest.json").read_text(encoding="utf-8"))
    if manifest.get("release") != release["architecture_version"]:
        raise ValueError("release manifest architecture version mismatch")
    if manifest.get("publication_version") != release["publication_version"]:
        raise ValueError("release manifest publication version mismatch")
    if manifest.get("encoding_abi") != release["encoding_abi"]:
        raise ValueError("release manifest encoding ABI mismatch")
    if _git(root, "rev-parse", "HEAD") != pto_commit:
        raise ValueError("checked-out PTO-SPEC head does not match candidate commit")
    ndf_commit = _ndf_commit(root)
    ndf_root = root / "tools/ndf"
    if _git(ndf_root, "rev-parse", "HEAD") != ndf_commit:
        raise ValueError("checked-out normative_language does not match ndf.lock")
    return {
        "release": release["architecture_version"],
        "publication_version": release["publication_version"],
        "encoding_abi": release["encoding_abi"],
        "encoding_projection_sha256": manifest["encoding_projection_sha256"],
        "pto_commit": pto_commit,
        "pto_tree": _git(root, "rev-parse", "HEAD^{tree}"),
        "llvm_repository": llvm_repository,
        "llvm_commit": llvm_commit,
        "asl_model_commit": asl_model_commit,
        "ndf_commit": ndf_commit,
        "ndf_tree": _git(ndf_root, "rev-parse", "HEAD^{tree}"),
        "aslref_commit": (root / ".aslref-version").read_text(encoding="utf-8").strip(),
        "workflow_commit": workflow_commit,
    }
