#!/usr/bin/env python3
"""Certify same-run PTO release artifacts from downloaded directories."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
from typing import Any

from scripts.release_publication import (
    Blocked,
    COMMIT,
    canonical_json,
    exact_dict,
    sha256_file,
    validate_manifest,
    validate_preflight,
)


SCHEMA = "pto.release-artifact-certification.v2"


def _commit(value: str, label: str) -> str:
    if COMMIT.fullmatch(value) is None:
        raise Blocked(f"{label} must be a 40-character lowercase commit")
    return value


def _git_commit(root: Path, label: str) -> str:
    try:
        return subprocess.check_output(
            ["git", "-C", str(root), "rev-parse", "HEAD"],
            text=True,
            stderr=subprocess.PIPE,
        ).strip()
    except (OSError, subprocess.CalledProcessError) as error:
        raise Blocked(f"cannot resolve the exact {label} commit") from error


def certify(
    *,
    pto_root: Path,
    release_evidence_root: Path,
    preflight_root: Path,
    pto_commit: str,
    run_id: str,
    run_attempt: int,
) -> dict[str, Any]:
    """Validate one exact same-run PTO artifact set without GitHub API access."""

    pto_commit = _commit(pto_commit, "PTO commit")
    if not run_id.isdigit() or int(run_id) <= 0:
        raise Blocked("run ID must be a positive integer")
    if isinstance(run_attempt, bool) or run_attempt <= 0:
        raise Blocked("run attempt must be a positive integer")
    roots = {
        "release_evidence": release_evidence_root.resolve(),
        "preflight": preflight_root.resolve(),
    }
    if any(not root.is_dir() for root in roots.values()):
        raise Blocked("both downloaded artifact roots must be directories")
    if _git_commit(pto_root, "checked-out candidate") != pto_commit:
        raise Blocked("checked-out candidate differs from the requested PTO commit")

    exact_manifest = (pto_root / "spec/release-manifest.json").read_bytes()
    manifest, release_files = validate_manifest(
        roots["release_evidence"], pto_commit, exact_manifest
    )
    preflight_name = f"pto-release-preflight-{pto_commit}"
    preflight, preflight_files = validate_preflight(
        roots["preflight"], manifest, pto_commit, preflight_name
    )
    dependencies = exact_dict(preflight.get("dependencies"), "preflight dependencies")
    if (
        pto_root / ".aslref-version"
    ).read_text(encoding="utf-8").strip() != dependencies.get("aslref"):
        raise Blocked(
            "release preflight ASLRef dependency differs from the exact candidate pin"
        )
    pto_ndf = _git_commit(pto_root / "tools/ndf", "candidate NDF submodule")
    if pto_ndf != dependencies.get("pto_ndf"):
        raise Blocked(
            "release preflight PTO NDF dependency differs from the exact candidate submodule"
        )

    components = {
        "pto_spec": pto_commit,
        "pto_ndf": pto_ndf,
        "aslref": str(dependencies["aslref"]),
    }
    evidence = {
        **{f"preflight/{path}": digest for path, digest in preflight_files.items()},
        **{
            f"release_evidence/{path}": digest
            for path, digest in release_files.items()
        },
    }
    return {
        "schema": SCHEMA,
        "scope": "pto-spec",
        "run": {"id": run_id, "attempt": run_attempt},
        "candidate": {
            "architecture_version": manifest["release"],
            "publication_version": manifest["publication_version"],
            "encoding_abi": manifest["encoding_abi"],
            "encoding_projection_sha256": manifest["encoding_projection_sha256"],
            "components": components,
        },
        "artifacts": {
            "preflight": preflight_name,
            "release_evidence": f"pto-release-evidence-{pto_commit}",
        },
        "evidence_sha256": dict(sorted(evidence.items())),
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--pto-root", required=True, type=Path)
    result.add_argument("--release-evidence-root", required=True, type=Path)
    result.add_argument("--preflight-root", required=True, type=Path)
    result.add_argument("--pto-commit", required=True)
    result.add_argument("--run-id", required=True)
    result.add_argument("--run-attempt", required=True, type=int)
    result.add_argument("--output", required=True, type=Path)
    result.add_argument("--diagnostics", required=True, type=Path)
    return result


def main(argv: list[str] | None = None) -> int:
    arguments = parser().parse_args(argv)
    try:
        report = certify(
            pto_root=arguments.pto_root.resolve(),
            release_evidence_root=arguments.release_evidence_root,
            preflight_root=arguments.preflight_root,
            pto_commit=arguments.pto_commit,
            run_id=arguments.run_id,
            run_attempt=arguments.run_attempt,
        )
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        arguments.output.write_text(canonical_json(report, pretty=True), encoding="utf-8")
        diagnostics = {
            "schema": "pto.release-artifact-certification-diagnostics.v2",
            "ok": True,
        }
    except (Blocked, KeyError, OSError, ValueError, json.JSONDecodeError) as error:
        diagnostics = {
            "schema": "pto.release-artifact-certification-diagnostics.v2",
            "ok": False,
            "error": str(error),
            "next_action": (
                "Fix the uploaded artifact mismatch before starting one new release verification."
            ),
        }
        result = 1
    else:
        result = 0
    arguments.diagnostics.parent.mkdir(parents=True, exist_ok=True)
    arguments.diagnostics.write_text(
        canonical_json(diagnostics, pretty=True), encoding="utf-8"
    )
    if result:
        print(f"release artifact certification failed: {diagnostics['error']}")
    else:
        print(f"release artifact certification passed: {sha256_file(arguments.output)}")
    return result


if __name__ == "__main__":
    raise SystemExit(main())
