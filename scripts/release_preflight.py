#!/usr/bin/env python3
"""Cheap, fail-closed validation for an exact PTO-SPEC release candidate."""

from __future__ import annotations

import json
from pathlib import Path
import re
import subprocess
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
        raise ValueError(f"release checkout is dirty: {root}; freeze the intended commit first")
    return subprocess.run(
        ["git", "-C", str(root), "rev-parse", "HEAD"], check=True, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    ).stdout.strip()


def approved_release_identity(root: Path) -> dict[str, str]:
    """Return the checked-in approved PTO identity after owner validation."""
    specification = tomllib.loads((root / "specification.toml").read_text(encoding="utf-8"))
    release = _object(specification.get("release"), "specification release")
    manifest = _read_json(root / "spec/release-manifest.json", "release manifest")
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
    if SHA256.fullmatch(identity["encoding_projection_sha256"]) is None:
        raise ValueError("approved encoding projection digest is invalid")
    selection = _object(manifest.get("release_selection"), "manifest release selection")
    if selection.get("blockers") != []:
        raise ValueError("release manifest selection contains blockers")
    return identity  # type: ignore[return-value]


def affected_pto_ids(document: object) -> list[str]:
    """Return affected PTO instruction IDs for the standalone model tooling."""
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


def validate_preflight(
    *, pto_root: Path, pto_commit: str, workflow_commit: str,
    run_command: Callable[..., Any] = subprocess.run,
) -> dict[str, Any]:
    commits = {
        "pto": _commit(pto_commit, "PTO commit"),
        "workflow": _commit(workflow_commit, "workflow commit"),
    }
    if commits["workflow"] != commits["pto"]:
        raise ValueError("workflow commit differs from the PTO candidate")
    if _git_head(pto_root) != commits["pto"]:
        raise ValueError("PTO checkout differs from the candidate")
    identity = approved_release_identity(pto_root)
    run_command([str(pto_root / "scripts/check-release-manifest")], check=True)
    pto_ndf = _commit(_git_head(pto_root / "tools/ndf"), "PTO pinned NDF commit")
    aslref = _commit((pto_root / ".aslref-version").read_text(encoding="utf-8").strip(), "PTO pinned ASLRef commit")
    return {
        "schema": "pto.release-preflight.v2", "scope": "pto-spec",
        "commits": commits, "identity": identity,
        "dependencies": {"pto_ndf": pto_ndf, "aslref": aslref},
    }


def canonical_bytes(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()
