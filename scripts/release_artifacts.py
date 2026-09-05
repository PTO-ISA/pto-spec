#!/usr/bin/env python3
"""Certify same-run release artifacts from already downloaded directories."""

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
    validate_model,
    validate_preflight,
    validate_site,
)


SCHEMA = "pto.release-artifact-certification.v1"


def _commit(value: str, label: str) -> str:
    if COMMIT.fullmatch(value) is None:
        raise Blocked(f"{label} must be a 40-character lowercase commit")
    return value


def certify(
    *,
    pto_root: Path,
    release_evidence_root: Path,
    preflight_root: Path,
    site_root: Path,
    model_root: Path,
    pto_commit: str,
    llvm_commit: str,
    asl_model_commit: str,
    run_id: str,
    run_attempt: int,
) -> dict[str, Any]:
    """Validate one exact same-run artifact set without GitHub API access."""

    pto_commit = _commit(pto_commit, "PTO commit")
    llvm_commit = _commit(llvm_commit, "LLVM commit")
    asl_model_commit = _commit(asl_model_commit, "ASL-MODEL commit")
    if not run_id.isdigit() or int(run_id) <= 0:
        raise Blocked("run ID must be a positive integer")
    if isinstance(run_attempt, bool) or run_attempt <= 0:
        raise Blocked("run attempt must be a positive integer")
    roots = {
        "release_evidence": release_evidence_root.resolve(),
        "preflight": preflight_root.resolve(),
        "site": site_root.resolve(),
        "model": model_root.resolve(),
    }
    if any(not root.is_dir() for root in roots.values()):
        raise Blocked("all four downloaded artifact roots must be directories")
    try:
        checked_out_commit = subprocess.check_output(
            ["git", "-C", str(pto_root), "rev-parse", "HEAD"],
            text=True,
            stderr=subprocess.PIPE,
        ).strip()
    except (OSError, subprocess.CalledProcessError) as error:
        raise Blocked("cannot resolve the checked-out candidate commit") from error
    if checked_out_commit != pto_commit:
        raise Blocked("checked-out candidate differs from the requested PTO commit")

    exact_manifest = (pto_root / "spec/release-manifest.json").read_bytes()
    manifest, release_files = validate_manifest(
        roots["release_evidence"], pto_commit, exact_manifest
    )
    preflight_name = (
        f"pto-release-preflight-{pto_commit}-{llvm_commit}-{asl_model_commit}"
    )
    preflight, impact, preflight_files = validate_preflight(
        roots["preflight"], manifest, pto_commit, preflight_name
    )
    dependencies = exact_dict(preflight.get("dependencies"), "preflight dependencies")
    if (pto_root / ".aslref-version").read_text(encoding="utf-8").strip() != dependencies.get("aslref"):
        raise Blocked("release preflight ASLRef dependency differs from the exact candidate pin")
    try:
        pto_ndf = subprocess.check_output(
            ["git", "-C", str(pto_root / "tools/ndf"), "rev-parse", "HEAD"],
            text=True,
            stderr=subprocess.PIPE,
        ).strip()
    except (OSError, subprocess.CalledProcessError) as error:
        raise Blocked("cannot resolve the exact candidate NDF submodule commit") from error
    if pto_ndf != dependencies.get("pto_ndf"):
        raise Blocked("release preflight PTO NDF dependency differs from the exact candidate submodule")

    site, site_files = validate_site(roots["site"], manifest, pto_commit)
    model_name = f"pto-model-closure-{pto_commit}-{llvm_commit}-{asl_model_commit}"
    tuple_, model_files, semantic_digest = validate_model(
        roots["model"], manifest, preflight, impact, pto_commit,
        run_id, run_attempt, model_name,
    )
    expected_tuple = {
        "pto_spec": pto_commit,
        "llvm": llvm_commit,
        "asl_model": asl_model_commit,
    }
    if any(tuple_.get(key) != value for key, value in expected_tuple.items()):
        raise Blocked("certified model tuple differs from the requested artifact tuple")

    evidence = {
        **{f"preflight/{path}": digest for path, digest in preflight_files.items()},
        **{f"release_evidence/{path}": digest for path, digest in release_files.items()},
        **{f"site/{path}": digest for path, digest in site_files.items()},
        **{f"model/{path}": digest for path, digest in model_files.items()},
    }
    return {
        "schema": SCHEMA,
        "run": {"id": run_id, "attempt": run_attempt},
        "candidate": {
            "architecture_version": manifest["release"],
            "publication_version": manifest["publication_version"],
            "encoding_abi": manifest["encoding_abi"],
            "encoding_projection_sha256": manifest["encoding_projection_sha256"],
            "components": tuple_,
        },
        "artifacts": {
            "preflight": preflight_name,
            "release_evidence": f"pto-release-evidence-{pto_commit}",
            "site": f"pto-site-preview-{pto_commit}",
            "model": model_name,
        },
        "evidence_sha256": dict(sorted(evidence.items())),
        "model_closure_semantic_payload_sha256": semantic_digest,
        "site_tree_sha256": site["site_tree_sha256"],
    }


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--pto-root", required=True, type=Path)
    result.add_argument("--release-evidence-root", required=True, type=Path)
    result.add_argument("--preflight-root", required=True, type=Path)
    result.add_argument("--site-root", required=True, type=Path)
    result.add_argument("--model-root", required=True, type=Path)
    result.add_argument("--pto-commit", required=True)
    result.add_argument("--llvm-commit", required=True)
    result.add_argument("--asl-model-commit", required=True)
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
            site_root=arguments.site_root,
            model_root=arguments.model_root,
            pto_commit=arguments.pto_commit,
            llvm_commit=arguments.llvm_commit,
            asl_model_commit=arguments.asl_model_commit,
            run_id=arguments.run_id,
            run_attempt=arguments.run_attempt,
        )
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        arguments.output.write_text(canonical_json(report, pretty=True), encoding="utf-8")
        diagnostics = {"schema": "pto.release-artifact-certification-diagnostics.v1", "ok": True}
    except (Blocked, KeyError, OSError, ValueError, json.JSONDecodeError) as error:
        diagnostics = {
            "schema": "pto.release-artifact-certification-diagnostics.v1",
            "ok": False,
            "error": str(error),
            "next_action": "Fix the uploaded artifact mismatch before starting one new release verification.",
        }
        result = 1
    else:
        result = 0
    arguments.diagnostics.parent.mkdir(parents=True, exist_ok=True)
    arguments.diagnostics.write_text(canonical_json(diagnostics, pretty=True), encoding="utf-8")
    if result:
        print(f"release artifact certification failed: {diagnostics['error']}")
    else:
        print(f"release artifact certification passed: {sha256_file(arguments.output)}")
    return result
