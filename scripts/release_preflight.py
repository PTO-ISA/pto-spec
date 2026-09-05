#!/usr/bin/env python3
"""Cheap, fail-closed validation for an exact release candidate tuple."""

from __future__ import annotations

import hashlib
import importlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tomllib
from typing import Any, Callable


COMMIT = re.compile(r"[0-9a-f]{40}\Z")
SHA256 = re.compile(r"[0-9a-f]{64}\Z")


def _object(value: object, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ValueError(f"{label} must be an object")
    return value


def _read_json(path: Path, label: str) -> dict[str, Any]:
    return _object(json.loads(path.read_text(encoding="utf-8")), label)


def _commit(value: object, label: str) -> str:
    if not isinstance(value, str) or COMMIT.fullmatch(value) is None:
        raise ValueError(f"{label} must be a 40-character lowercase commit")
    return value


def _git_head(root: Path) -> str:
    dirty = subprocess.run(
        ["git", "-C", str(root), "status", "--porcelain=v1", "--untracked-files=all"],
        check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    ).stdout.strip()
    if dirty:
        raise ValueError(f"release checkout is dirty: {root}; freeze the intended commits first")
    return subprocess.run(
        ["git", "-C", str(root), "rev-parse", "HEAD"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout.strip()


def approved_release_identity(root: Path) -> dict[str, str]:
    """Return the checked-in approved identity after cross-owner validation."""

    specification = tomllib.loads(
        (root / "specification.toml").read_text(encoding="utf-8")
    )
    release = _object(specification.get("release"), "specification release")
    manifest = _read_json(root / "spec/release-manifest.json", "release manifest")
    selection = _read_json(
        root / "spec/model-closure-selection.json", "model closure selection"
    )
    identity = {
        "release": release.get("architecture_version"),
        "publication_version": release.get("publication_version"),
        "encoding_abi": release.get("encoding_abi"),
        "encoding_projection_sha256": manifest.get("encoding_projection_sha256"),
    }
    if any(not isinstance(value, str) or not value for value in identity.values()):
        raise ValueError("approved release identity has a missing or invalid field")
    if manifest.get("release") != identity["release"]:
        raise ValueError("release manifest architecture identity mismatch")
    if manifest.get("publication_version") != identity["publication_version"]:
        raise ValueError("release manifest publication identity mismatch")
    if manifest.get("encoding_abi") != identity["encoding_abi"]:
        raise ValueError("release manifest encoding ABI mismatch")
    if selection.get("schema") != "pto.model-closure-selection.v1":
        raise ValueError("model closure selection schema mismatch")
    if selection.get("release") != identity["release"]:
        raise ValueError("model closure selection release mismatch")
    if SHA256.fullmatch(identity["encoding_projection_sha256"]) is None:
        raise ValueError("approved encoding projection digest is invalid")
    return identity  # type: ignore[return-value]


def model_dependency_pins(asl_model_root: Path) -> dict[str, str]:
    text = (asl_model_root / "ndf.lock").read_text(encoding="utf-8")
    rows = dict(
        re.findall(
            r"^  ([a-z-]+):\n(?:    [^\n]+\n)*?    revision: ([0-9a-f]{40})$",
            text,
            re.MULTILINE,
        )
    )
    if set(rows) != {"ndf", "pto-spec"}:
        raise ValueError("ASL-MODEL ndf.lock dependency set mismatch")
    return rows


def affected_pto_ids(document: object) -> list[str]:
    report_document = _object(document, "NDF impact")
    if (
        report_document.get("schema_version") != "0.1"
        or report_document.get("command") != "impact pto-release"
        or report_document.get("ok") is not True
        or report_document.get("diagnostics") != []
    ):
        raise ValueError("NDF impact command did not produce a clean v0.1 result")
    report = _object(report_document.get("data"), "NDF impact data")
    if report.get("schema_version") != "1":
        raise ValueError("NDF PTO release impact report schema mismatch")
    changes = report.get("changes")
    targets = report.get("conformance_targets")
    if not isinstance(changes, list) or not isinstance(targets, list):
        raise ValueError("NDF impact changes or conformance targets are missing")
    conformance_targets = {
        item.get("target_uri")
        for item in targets
        if isinstance(item, dict)
        and isinstance(item.get("consumer_uri"), str)
        and item["consumer_uri"].startswith("ndf://asl-model/")
        and isinstance(item.get("target_uri"), str)
    }
    affected: set[str] = set()
    for item in changes:
        if not isinstance(item, dict) or not isinstance(item.get("uri"), str):
            raise ValueError("NDF impact contains a malformed change")
        uri = item["uri"]
        if uri in conformance_targets or (
            uri.startswith("ndf://pto-spec/PTO-INST-")
            and item.get("kind") in {"added", "modified", "moved"}
        ):
            affected.add(uri.removeprefix("ndf://pto-spec/"))
    return sorted(affected)


def _case_mapping(
    asl_model_root: Path,
    affected: list[str],
    case_loader: Callable[[Path], dict[str, tuple[Path, dict[str, object]]]] | None = None,
) -> dict[str, list[str]]:
    mapping = {pto_id: [] for pto_id in affected}
    case_paths = sorted((asl_model_root / "avs/cases").glob("*/case.yaml"))
    if not case_paths:
        raise ValueError("ASL-MODEL AVS case corpus is empty")
    seen: set[str] = set()
    if case_loader is None:
        source_root = str(asl_model_root / "src")
        if source_root not in sys.path:
            sys.path.insert(0, source_root)
        case_loader = importlib.import_module("pto_asl_model.closure")._load_cases
    validated_cases = case_loader(asl_model_root / "avs/cases")
    for path in case_paths:
        case = _read_json(path, f"AVS case {path}")
        case_id = case.get("case_id")
        pto_ids = case.get("pto_ids")
        if not isinstance(case_id, str) or not case_id or case_id in seen:
            raise ValueError(f"ASL-MODEL AVS case has invalid identity: {path}")
        seen.add(case_id)
        if case_id not in validated_cases:
            raise ValueError(f"ASL-MODEL AVS case was not loaded: {case_id}")
        if not isinstance(pto_ids, list) or any(
            not isinstance(pto_id, str) for pto_id in pto_ids
        ):
            raise ValueError(f"ASL-MODEL AVS case has invalid pto_ids: {case_id}")
        for pto_id in mapping:
            if pto_id in pto_ids:
                mapping[pto_id].append(case_id)
    missing = sorted(pto_id for pto_id, cases in mapping.items() if not cases)
    if missing:
        raise ValueError(
            "affected PTO identities have no explicit ASL-MODEL AVS case: "
            + ", ".join(missing)
        )
    return mapping


def validate_preflight(
    *,
    pto_root: Path,
    llvm_root: Path,
    asl_model_root: Path,
    pto_commit: str,
    llvm_commit: str,
    asl_model_commit: str,
    workflow_commit: str,
    impact_path: Path,
    case_mapping: Callable[[Path, list[str]], dict[str, list[str]]] = _case_mapping,
    run_command: Callable[..., Any] = subprocess.run,
) -> dict[str, Any]:
    commits = {
        "pto": _commit(pto_commit, "PTO commit"),
        "llvm": _commit(llvm_commit, "LLVM commit"),
        "asl_model": _commit(asl_model_commit, "ASL-MODEL commit"),
        "workflow": _commit(workflow_commit, "workflow commit"),
    }
    if commits["workflow"] != commits["pto"]:
        raise ValueError("workflow commit differs from the PTO candidate")
    for name, root in (
        ("pto", pto_root),
        ("llvm", llvm_root),
        ("asl_model", asl_model_root),
    ):
        if _git_head(root) != commits[name]:
            raise ValueError(f"{name} checkout differs from the candidate tuple")

    identity = approved_release_identity(pto_root)
    model_lock = _read_json(asl_model_root / "pto-lock.json", "ASL-MODEL PTO lock")
    model_identity = {
        "release": model_lock.get("architecture_version"),
        "publication_version": model_lock.get("publication_version"),
        "encoding_abi": model_lock.get("encoding_abi"),
        "encoding_projection_sha256": model_lock.get(
            "encoding_projection_sha256"
        ),
    }
    if model_identity != identity:
        raise ValueError("ASL-MODEL release identity differs from PTO-SPEC")
    pins = model_dependency_pins(asl_model_root)
    model_graph_baseline = _commit(pins["pto-spec"], "ASL-MODEL graph baseline")
    model_ndf = _commit(pins["ndf"], "ASL-MODEL NDF commit")
    if _git_head(asl_model_root / "tools/ndf") != model_ndf:
        raise ValueError("ASL-MODEL NDF checkout differs from ndf.lock")
    if _git_head(asl_model_root / "vendor/pto-spec") != model_graph_baseline:
        raise ValueError("ASL-MODEL imported PTO graph differs from ndf.lock")

    run_command([str(pto_root / "scripts/check-release-manifest")], check=True)

    generator = llvm_root / "llvm/utils/pto/generate_pto_isa_identity.py"
    header = llvm_root / "llvm/include/llvm/BinaryFormat/PTOISA.h"
    run_command(
        [
            "python3",
            str(generator),
            "--manifest",
            str(pto_root / "spec/release-manifest.json"),
            "--output",
            str(header),
            "--check",
        ],
        check=True,
    )

    impact = _read_json(impact_path, "NDF impact")
    affected = affected_pto_ids(impact)
    mapping = case_mapping(asl_model_root, affected)
    selection = _read_json(
        pto_root / "spec/model-closure-selection.json", "model closure selection"
    )
    baseline = _commit(
        selection.get("adoption_baseline_commit"), "adoption baseline commit"
    )
    mandatory = selection.get("mandatory_case_ids")
    if (
        not isinstance(mandatory, list)
        or not mandatory
        or mandatory != sorted(set(mandatory))
        or any(not isinstance(case_id, str) for case_id in mandatory)
    ):
        raise ValueError("model closure selection has invalid mandatory cases")
    available_cases = {
        path.parent.name for path in (asl_model_root / "avs/cases").glob("*/case.yaml")
    }
    missing_mandatory = sorted(set(mandatory) - available_cases)
    if missing_mandatory:
        raise ValueError(
            "mandatory ASL-MODEL AVS cases are missing: "
            + ", ".join(missing_mandatory)
        )
    pto_ndf = _commit(_git_head(pto_root / "tools/ndf"), "PTO pinned NDF commit")
    aslref = _commit(
        (pto_root / ".aslref-version").read_text(encoding="utf-8").strip(),
        "PTO pinned ASLRef commit",
    )
    impact_sha256 = hashlib.sha256(impact_path.read_bytes()).hexdigest()
    return {
        "schema": "pto.release-preflight.v1",
        "commits": commits,
        "identity": identity,
        "baselines": {
            "model_graph_import": model_graph_baseline,
            "impact_adoption": baseline,
        },
        "dependencies": {
            "pto_ndf": pto_ndf,
            "asl_model_ndf": model_ndf,
            "aslref": aslref,
        },
        "selection": {"mandatory_case_ids": mandatory},
        "impact": {
            "sha256": impact_sha256,
            "affected_pto_ids": affected,
            "avs_cases_by_pto_id": mapping,
        },
    }


def canonical_bytes(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
