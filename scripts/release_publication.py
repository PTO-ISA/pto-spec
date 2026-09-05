#!/usr/bin/env python3
"""Build a deterministic publication handoff from exact hosted evidence."""

from __future__ import annotations

import argparse
import base64
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import zipfile
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.model_closure import canonical_sha256, validate_run_envelope, validate_semantic_payload  # noqa: E402
from scripts.release_event import canonical_release_event  # noqa: E402


REPOSITORY = "PTO-ISA/pto-spec"
WORKFLOW_PATH = ".github/workflows/release.yml"
COMMIT = re.compile(r"[0-9a-f]{40}")
SHA256 = re.compile(r"[0-9a-f]{64}")
FINAL_JOB_SUFFIXES = (
    "Release / candidate preflight",
    "Full validation / health",
    "Release / fail-closed evidence aggregation",
    "Release / static site validity",
    "Release / LLVM-to-ASL model closure",
    "Release / validate",
)
MAX_ARCHIVE_FILES = 20_000
MAX_ARCHIVE_BYTES = 1024 * 1024 * 1024
MAX_UNCOMPRESSED_BYTES = 2 * 1024 * 1024 * 1024


class Blocked(ValueError):
    """One deterministic publication prerequisite was not proved."""


class MachineParser(argparse.ArgumentParser):
    def error(self, message: str) -> None:
        raise Blocked(message)


def canonical_json(value: object, *, pretty: bool = False) -> str:
    if pretty:
        return json.dumps(value, indent=2, sort_keys=True) + "\n"
    return json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def exact_dict(value: object, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise Blocked(f"{label} must be an object")
    return value


class GitHub:
    def __init__(self, executable: str, repository: str) -> None:
        self.executable = executable
        self.repository = repository

    def _call(self, endpoint: str) -> bytes:
        try:
            result = subprocess.run(
                [self.executable, "api", endpoint],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        except FileNotFoundError as error:
            raise Blocked(f"GitHub CLI is unavailable: {self.executable}") from error
        except subprocess.CalledProcessError as error:
            detail = error.stderr.decode("utf-8", "replace").strip()
            raise Blocked(f"GitHub API request failed for {endpoint}: {detail}") from error
        return result.stdout

    def json(self, endpoint: str) -> object:
        try:
            return json.loads(self._call(endpoint).decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            raise Blocked(f"GitHub API returned invalid JSON for {endpoint}") from error

    def run(self, run_id: str) -> dict[str, Any]:
        return exact_dict(
            self.json(f"repos/{self.repository}/actions/runs/{run_id}"), "workflow run"
        )

    def jobs(self, run_id: str, attempt: int) -> list[dict[str, Any]]:
        jobs: list[dict[str, Any]] = []
        page = 1
        while True:
            payload = exact_dict(
                self.json(
                    f"repos/{self.repository}/actions/runs/{run_id}/attempts/{attempt}/jobs"
                    f"?per_page=100&page={page}"
                ),
                "jobs response",
            )
            rows = payload.get("jobs")
            if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
                raise Blocked("jobs response must contain an array of jobs")
            jobs.extend(rows)
            total = payload.get("total_count")
            if not isinstance(total, int) or isinstance(total, bool) or total < len(jobs):
                raise Blocked("jobs response has an invalid total_count")
            if len(jobs) == total:
                return jobs
            if not rows:
                raise Blocked("jobs pagination ended before total_count")
            page += 1

    def artifacts(self, run_id: str) -> list[dict[str, Any]]:
        artifacts: list[dict[str, Any]] = []
        page = 1
        while True:
            suffix = "?per_page=100" if page == 1 else f"?per_page=100&page={page}"
            payload = exact_dict(
                self.json(f"repos/{self.repository}/actions/runs/{run_id}/artifacts{suffix}"),
                "artifacts response",
            )
            rows = payload.get("artifacts")
            if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
                raise Blocked("artifacts response must contain an array of artifacts")
            artifacts.extend(rows)
            total = payload.get("total_count")
            if not isinstance(total, int) or isinstance(total, bool) or total < len(artifacts):
                raise Blocked("artifacts response has an invalid total_count")
            if len(artifacts) == total:
                return artifacts
            if not rows:
                raise Blocked("artifact pagination ended before total_count")
            page += 1

    def artifact_zip(self, artifact_id: int) -> bytes:
        return self._call(f"repos/{self.repository}/actions/artifacts/{artifact_id}/zip")

    def content(self, path: str, commit: str) -> bytes:
        payload = exact_dict(
            self.json(f"repos/{self.repository}/contents/{path}?ref={commit}"),
            f"repository content {path}",
        )
        if payload.get("encoding") != "base64" or not isinstance(payload.get("content"), str):
            raise Blocked(f"repository content {path} is not inline base64")
        try:
            return base64.b64decode(payload["content"], validate=False)
        except (ValueError, TypeError) as error:
            raise Blocked(f"repository content {path} has invalid base64") from error

    def submodule_commit(self, path: str, commit: str) -> str:
        payload = exact_dict(
            self.json(f"repos/{self.repository}/contents/{path}?ref={commit}"),
            f"repository submodule {path}",
        )
        sha = payload.get("sha")
        if not isinstance(sha, str) or COMMIT.fullmatch(sha) is None:
            raise Blocked(f"repository submodule {path} has no exact commit")
        return sha


def validate_run(run: dict[str, Any], run_id: str, repository: str) -> tuple[str, int]:
    if str(run.get("id")) != run_id:
        raise Blocked("workflow run ID does not match the requested run")
    if run.get("event") != "workflow_dispatch":
        raise Blocked("release verification must be manually dispatched")
    if run.get("path") != WORKFLOW_PATH:
        raise Blocked(f"workflow path must be {WORKFLOW_PATH}")
    repo = exact_dict(run.get("repository"), "workflow repository")
    if repo.get("full_name") != repository:
        raise Blocked(f"workflow repository must be {repository}")
    if run.get("status") != "completed" or run.get("conclusion") != "success":
        raise Blocked("workflow run must be terminal and successful")
    commit = run.get("head_sha")
    attempt = run.get("run_attempt")
    if not isinstance(commit, str) or COMMIT.fullmatch(commit) is None:
        raise Blocked("workflow head_sha must be one exact lowercase commit")
    if not isinstance(attempt, int) or isinstance(attempt, bool) or attempt < 1:
        raise Blocked("workflow run_attempt must be a positive integer")
    return commit, attempt


def validate_jobs(jobs: list[dict[str, Any]]) -> list[dict[str, object]]:
    if not jobs:
        raise Blocked("release run has no jobs")
    bad = sorted(
        str(job.get("name", "<unnamed>"))
        for job in jobs
        if job.get("status") != "completed" or job.get("conclusion") != "success"
    )
    if bad:
        raise Blocked("release run contains non-success jobs: " + ", ".join(bad))
    names = [str(job.get("name", "")) for job in jobs]
    wrong_counts = [
        suffix for suffix in FINAL_JOB_SUFFIXES
        if sum(name.endswith(suffix) for name in names) != 1
    ]
    if wrong_counts:
        raise Blocked("release run must contain exactly one of each required final job: " + ", ".join(wrong_counts))
    return [
        {"id": job.get("id"), "name": str(job.get("name")), "conclusion": "success"}
        for job in sorted(jobs, key=lambda item: (str(item.get("name")), int(item.get("id", 0))))
    ]


def select_artifacts(rows: list[dict[str, Any]], commit: str) -> dict[str, dict[str, Any]]:
    prefixes = {
        "preflight": f"pto-release-preflight-{commit}-",
        "release_evidence": f"pto-release-evidence-{commit}",
        "site": f"pto-site-preview-{commit}",
        "model": f"pto-model-closure-{commit}-",
    }
    selected: dict[str, dict[str, Any]] = {}
    for role, prefix in prefixes.items():
        matches = [
            row
            for row in rows
            if row.get("name") == prefix
            or (role in {"model", "preflight"} and str(row.get("name", "")).startswith(prefix))
        ]
        if len(matches) != 1:
            raise Blocked(f"expected exactly one {role} artifact for commit {commit}")
        row = matches[0]
        if row.get("expired") is not False:
            raise Blocked(f"{role} artifact is expired or has unknown expiry state")
        artifact_id = row.get("id")
        digest = row.get("digest")
        size = row.get("size_in_bytes")
        if not isinstance(artifact_id, int) or isinstance(artifact_id, bool) or artifact_id <= 0:
            raise Blocked(f"{role} artifact ID is invalid")
        if not isinstance(digest, str) or not digest.startswith("sha256:") or SHA256.fullmatch(digest[7:]) is None:
            raise Blocked(f"{role} artifact is missing its GitHub SHA-256 digest")
        if not isinstance(size, int) or isinstance(size, bool) or size <= 0 or size > MAX_ARCHIVE_BYTES:
            raise Blocked(f"{role} artifact size is invalid or exceeds the download limit")
        selected[role] = row
    known_ids = {row["id"] for row in selected.values()}
    final_name = re.compile(
        r"(?:pto-release-evidence-[0-9a-f]{40}|"
        r"pto-site-preview-[0-9a-f]{40}|"
        r"pto-model-closure-[0-9a-f]{40}-[0-9a-f]{40}-[0-9a-f]{40}|"
        r"pto-release-preflight-[0-9a-f]{40}-[0-9a-f]{40}-[0-9a-f]{40})"
    )
    unknown = sorted(
        str(row.get("name", ""))
        for row in rows
        if final_name.fullmatch(str(row.get("name", ""))) is not None
        and row.get("id") not in known_ids
    )
    if unknown:
        raise Blocked("release run contains unknown or different-commit final artifacts: " + ", ".join(unknown))
    return selected


def safe_extract(data: bytes, destination: Path) -> list[Path]:
    try:
        archive = zipfile.ZipFile(io.BytesIO(data))
    except (zipfile.BadZipFile, OSError) as error:
        raise Blocked("downloaded artifact is not a valid ZIP archive") from error
    with archive:
        members = archive.infolist()
        if len(members) > MAX_ARCHIVE_FILES:
            raise Blocked("artifact archive contains too many members")
        if sum(item.file_size for item in members) > MAX_UNCOMPRESSED_BYTES:
            raise Blocked("artifact archive exceeds the uncompressed size limit")
        seen: set[str] = set()
        files: list[Path] = []
        for item in members:
            raw = item.filename
            path = PurePosixPath(raw)
            mode = item.external_attr >> 16
            if (
                not raw
                or "\\" in raw
                or path.is_absolute()
                or any(part in ("", ".", "..") for part in path.parts)
                or (path.parts and re.fullmatch(r"[A-Za-z]:", path.parts[0]) is not None)
                or stat.S_ISLNK(mode)
            ):
                raise Blocked(f"unsafe archive member path: {raw!r}")
            normalized = path.as_posix().rstrip("/")
            if normalized in seen:
                raise Blocked(f"duplicate archive member path: {normalized}")
            seen.add(normalized)
            target = destination.joinpath(*path.parts)
            if item.is_dir():
                target.mkdir(parents=True, exist_ok=True)
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            with archive.open(item) as source, target.open("xb") as output:
                shutil.copyfileobj(source, output)
            files.append(target)
        return files


def unique_suffix(root: Path, suffix: str) -> Path:
    matches = sorted(path for path in root.rglob("*") if path.is_file() and path.as_posix().endswith(suffix))
    if len(matches) != 1:
        raise Blocked(f"artifact must contain exactly one {suffix}")
    return matches[0]


def json_file(path: Path, label: str) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise Blocked(f"{label} is not valid UTF-8 JSON") from error


def validate_manifest(
    root: Path, commit: str, hosted_manifest: bytes
) -> tuple[dict[str, Any], dict[str, str]]:
    manifest_path = unique_suffix(root, "spec/release-manifest.json")
    matrix_path = unique_suffix(root, "build/asl-test-matrix.json")
    coverage_path = unique_suffix(root, "build/asl-test-coverage.json")
    digest_path = unique_suffix(root, "spec/evidence/asl-test-matrix.sha256")
    manifest = exact_dict(json_file(manifest_path, "release manifest"), "release manifest")
    if manifest_path.read_bytes() != hosted_manifest:
        raise Blocked("release manifest artifact differs from the exact candidate commit")
    if manifest.get("schema_version") != 1:
        raise Blocked("release manifest schema_version must be 1")
    for key in ("content_sha256", "encoding_projection_sha256"):
        if not isinstance(manifest.get(key), str) or SHA256.fullmatch(manifest[key]) is None:
            raise Blocked(f"release manifest {key} is invalid")
    inputs = manifest.get("canonical_inputs")
    if not isinstance(inputs, list) or not inputs:
        raise Blocked("release manifest canonical_inputs must be non-empty")
    projection: dict[str, str] = {}
    for item in inputs:
        row = exact_dict(item, "canonical input")
        path, digest = row.get("path"), row.get("sha256")
        if not isinstance(path, str) or not path or path in projection:
            raise Blocked("release manifest canonical input paths must be unique text")
        if not isinstance(digest, str) or SHA256.fullmatch(digest) is None:
            raise Blocked("release manifest canonical input digest is invalid")
        projection[path] = digest
    if list(projection) != sorted(projection):
        raise Blocked("release manifest canonical inputs must be sorted")
    if canonical_sha256(projection) != manifest["content_sha256"]:
        raise Blocked("release manifest content digest is stale")
    selection = exact_dict(manifest.get("release_selection"), "release selection")
    if selection.get("architecture_version") != manifest.get("release") or selection.get("publication_version") != manifest.get("publication_version"):
        raise Blocked("release selection identity does not match the manifest")
    if selection.get("blockers") != []:
        raise Blocked("release selection contains blockers")
    matrix = exact_dict(json_file(matrix_path, "ASL test matrix"), "ASL test matrix")
    coverage = exact_dict(json_file(coverage_path, "ASL test coverage"), "ASL test coverage")
    if matrix.get("commit") != commit or coverage.get("commit") != commit:
        raise Blocked("ASL release evidence belongs to a different commit")
    entries = matrix.get("include")
    results = coverage.get("results")
    if (
        matrix.get("page") != 0
        or matrix.get("page_count") != 1
        or not isinstance(entries, list)
        or not entries
        or matrix.get("test_count") != len(entries)
        or coverage.get("schema") != "pto.asl-test-coverage.v1"
        or coverage.get("status") != "passed"
        or not isinstance(results, list)
        or coverage.get("test_count") != len(entries)
        or coverage.get("passed_count") != len(entries)
        or len(results) != len(entries)
    ):
        raise Blocked("ASL release evidence is incomplete or not fully passed")
    planned: dict[str, dict[str, Any]] = {}
    for entry in entries:
        row = exact_dict(entry, "ASL matrix entry")
        test_id = row.get("id")
        if not isinstance(test_id, str) or not test_id or test_id in planned:
            raise Blocked("ASL matrix test identities must be unique text")
        planned[test_id] = row
    observed: dict[str, dict[str, Any]] = {}
    for result in results:
        row = exact_dict(result, "ASL coverage result")
        test_id = row.get("id")
        if not isinstance(test_id, str) or test_id in observed:
            raise Blocked("ASL coverage result identities must be unique text")
        observed[test_id] = row
    if set(planned) != set(observed):
        raise Blocked("ASL matrix and coverage result sets differ")
    for test_id, entry in planned.items():
        result = observed[test_id]
        if result.get("path") != entry.get("path") or result.get("sha256") != entry.get("sha256") or result.get("status") != "passed":
            raise Blocked(f"ASL coverage result is stale or failed for {test_id}")
    digest_line = digest_path.read_text(encoding="utf-8").strip()
    expected_line = f"{sha256_file(matrix_path)}  build/asl-test-matrix.json"
    if digest_line != expected_line:
        raise Blocked("ASL matrix checksum evidence is stale")
    paths = (manifest_path, matrix_path, coverage_path, digest_path)
    return manifest, {path.relative_to(root).as_posix(): sha256_file(path) for path in paths}


def validate_site(root: Path, manifest: dict[str, Any], commit: str) -> tuple[dict[str, Any], dict[str, str]]:
    site_path = unique_suffix(root, "pto-site-publication.json")
    site = exact_dict(json_file(site_path, "site publication manifest"), "site publication manifest")
    expected = {
        "schema": "pto.site-publication.v1",
        "architecture_version": manifest.get("release"),
        "publication_version": manifest.get("publication_version"),
        "tag": f"v{manifest.get('publication_version')}",
        "source_commit": commit,
        "release_eligible": True,
        "publication_state": "release",
    }
    for key, value in expected.items():
        if site.get(key) != value:
            raise Blocked(f"site publication manifest {key} mismatch")
    files = sorted(path for path in root.rglob("*") if path.is_file() and path != site_path)
    tree = hashlib.sha256()
    for path in files:
        relative = path.relative_to(root).as_posix()
        tree.update(relative.encode("utf-8"))
        tree.update(b"\0")
        tree.update(bytes.fromhex(sha256_file(path)))
        tree.update(b"\n")
    if site.get("file_count") != len(files) or site.get("content_bytes") != sum(path.stat().st_size for path in files) or site.get("site_tree_sha256") != tree.hexdigest():
        raise Blocked("site artifact tree is incomplete or stale")
    return site, {site_path.relative_to(root).as_posix(): sha256_file(site_path)}


def validate_preflight(
    root: Path,
    manifest: dict[str, Any],
    commit: str,
    artifact_name: str,
) -> tuple[dict[str, Any], bytes, dict[str, str]]:
    suffix = artifact_name.removeprefix(f"pto-release-preflight-{commit}-")
    parts = suffix.split("-")
    if len(parts) != 2 or any(COMMIT.fullmatch(part) is None for part in parts):
        raise Blocked("preflight artifact name does not encode exact LLVM and ASL-MODEL commits")
    candidate_path = unique_suffix(root, "candidate.json")
    impact_path = unique_suffix(root, "ndf-impact.json")
    candidate = exact_dict(json_file(candidate_path, "release preflight candidate"), "release preflight candidate")
    if set(candidate) != {"schema", "commits", "identity", "baselines", "dependencies", "selection", "impact"} or candidate.get("schema") != "pto.release-preflight.v1":
        raise Blocked("release preflight candidate schema or fields are invalid")
    if candidate_path.read_bytes() != canonical_json(candidate).encode("utf-8"):
        raise Blocked("release preflight candidate is not canonical JSON")
    commits = exact_dict(candidate.get("commits"), "preflight commits")
    expected_commits = {"pto": commit, "llvm": parts[0], "asl_model": parts[1], "workflow": commit}
    if commits != expected_commits:
        raise Blocked("release preflight commits do not match the hosted artifact identity")
    identity = exact_dict(candidate.get("identity"), "preflight identity")
    expected_identity = {
        "release": manifest.get("release"),
        "publication_version": manifest.get("publication_version"),
        "encoding_abi": manifest.get("encoding_abi"),
        "encoding_projection_sha256": manifest.get("encoding_projection_sha256"),
    }
    if identity != expected_identity:
        raise Blocked("release preflight identity does not match the release manifest")
    dependencies = exact_dict(candidate.get("dependencies"), "preflight dependencies")
    if set(dependencies) != {"pto_ndf", "asl_model_ndf", "aslref"} or any(
        not isinstance(value, str) or COMMIT.fullmatch(value) is None for value in dependencies.values()
    ):
        raise Blocked("release preflight dependencies are incomplete or invalid")
    baselines = exact_dict(candidate.get("baselines"), "preflight baselines")
    if set(baselines) != {"model_graph_import", "impact_adoption"} or any(
        not isinstance(value, str) or COMMIT.fullmatch(value) is None
        for value in baselines.values()
    ):
        raise Blocked("release preflight baselines are incomplete or invalid")
    selection = exact_dict(candidate.get("selection"), "preflight selection")
    mandatory = selection.get("mandatory_case_ids")
    if not isinstance(mandatory, list) or not mandatory or mandatory != sorted(set(mandatory)) or any(not isinstance(value, str) or not value for value in mandatory):
        raise Blocked("release preflight mandatory cases are incomplete or invalid")
    impact = exact_dict(candidate.get("impact"), "preflight impact")
    impact_bytes = impact_path.read_bytes()
    if impact.get("sha256") != sha256_bytes(impact_bytes):
        raise Blocked("release preflight NDF impact digest is stale")
    json.loads(impact_bytes.decode("utf-8"))
    affected = impact.get("affected_pto_ids")
    mapping = impact.get("avs_cases_by_pto_id")
    if not isinstance(affected, list) or affected != sorted(set(affected)) or not isinstance(mapping, dict) or sorted(mapping) != affected:
        raise Blocked("release preflight affected PTO identities or AVS mapping are invalid")
    if any(
        not isinstance(cases, list)
        or not cases
        or any(not isinstance(case, str) or not case for case in cases)
        or cases != sorted(set(cases))
        for cases in mapping.values()
    ):
        raise Blocked("release preflight contains an empty or invalid AVS mapping")
    paths = (candidate_path, impact_path)
    return candidate, impact_bytes, {path.relative_to(root).as_posix(): sha256_file(path) for path in paths}


def validate_model(
    root: Path,
    manifest: dict[str, Any],
    preflight: dict[str, Any],
    preflight_impact: bytes,
    commit: str,
    run_id: str,
    attempt: int,
    artifact_name: str,
) -> tuple[dict[str, str], dict[str, str], str]:
    suffix = artifact_name.removeprefix(f"pto-model-closure-{commit}-")
    parts = suffix.split("-")
    if len(parts) != 2 or any(COMMIT.fullmatch(part) is None for part in parts):
        raise Blocked("model artifact name does not encode exact LLVM and ASL-MODEL commits")
    llvm_commit, asl_model_commit = parts
    model_candidate_path = unique_suffix(root, "candidate.json")
    model_impact_path = unique_suffix(root, "ndf-impact.json")
    if model_candidate_path.read_bytes() != canonical_json(preflight).encode("utf-8") or model_impact_path.read_bytes() != preflight_impact:
        raise Blocked("model artifact preflight evidence differs from the standalone preflight artifact")
    payload_paths = sorted(root.rglob("closure-semantic-payload.json"))
    envelope_paths = sorted(root.rglob("closure-run-envelope.json"))
    if len(payload_paths) != 2 or len(envelope_paths) != 2:
        raise Blocked("model artifact must contain two semantic payloads and two run envelopes")
    payloads = [json_file(path, "model semantic payload") for path in payload_paths]
    if canonical_sha256(payloads[0]) != canonical_sha256(payloads[1]):
        raise Blocked("the two model closure semantic payloads differ")
    payload = exact_dict(payloads[0], "model semantic payload")
    lock = exact_dict(payload.get("closure_lock"), "model closure lock")
    repos = exact_dict(lock.get("repositories"), "model closure repositories")
    pto = exact_dict(repos.get("pto_spec"), "PTO-SPEC closure repository")
    ndf = exact_dict(repos.get("normative_language"), "NDF closure repository")
    aslref = exact_dict(repos.get("aslref"), "ASLRef closure repository")
    expected = {
        "release": str(manifest.get("release")),
        "publication_version": str(manifest.get("publication_version")),
        "encoding_abi": str(manifest.get("encoding_abi")),
        "encoding_projection_sha256": str(manifest.get("encoding_projection_sha256")),
        "pto_commit": commit,
        "pto_tree": str(pto.get("tree")),
        "llvm_repository": "https://github.com/LinxISA/llvm-project.git",
        "llvm_commit": llvm_commit,
        "asl_model_commit": asl_model_commit,
        "ndf_commit": str(ndf.get("commit")),
        "ndf_tree": str(ndf.get("tree")),
        "aslref_commit": str(aslref.get("commit")),
        "workflow_commit": commit,
    }
    preflight_commits = exact_dict(preflight.get("commits"), "preflight commits")
    if llvm_commit != preflight_commits.get("llvm") or asl_model_commit != preflight_commits.get("asl_model"):
        raise Blocked("model closure commits differ from release preflight")
    preflight_dependencies = exact_dict(preflight.get("dependencies"), "preflight dependencies")
    if expected["ndf_commit"] != preflight_dependencies.get("asl_model_ndf") or expected["aslref_commit"] != preflight_dependencies.get("aslref"):
        raise Blocked("model closure dependencies differ from release preflight")
    preflight_impact_row = exact_dict(preflight.get("impact"), "preflight impact")
    payload_impact = exact_dict(payload.get("ndf_impact"), "model NDF impact")
    if payload_impact.get("sha256") != preflight_impact_row.get("sha256") or payload_impact.get("affected_pto_ids") != preflight_impact_row.get("affected_pto_ids"):
        raise Blocked("model closure NDF impact differs from release preflight")
    errors = validate_semantic_payload(payload, expected)
    for index, envelope_path in enumerate(envelope_paths, 1):
        envelope = json_file(envelope_path, "model run envelope")
        errors.extend(validate_run_envelope(envelope, payload, expected, expected_run_id=f"{run_id}-{index}", expected_run_attempt=str(attempt)))
    if errors:
        raise Blocked("model closure evidence failed validation: " + "; ".join(sorted(set(errors))))
    tuple_ = {
        "pto_spec": commit,
        "llvm": llvm_commit,
        "asl_model": asl_model_commit,
        "pto_ndf": str(preflight_dependencies["pto_ndf"]),
        "asl_model_ndf": expected["ndf_commit"],
        "aslref": expected["aslref_commit"],
    }
    files = [model_candidate_path, model_impact_path] + payload_paths + envelope_paths
    return tuple_, {path.relative_to(root).as_posix(): sha256_file(path) for path in files}, canonical_sha256(payload)


def release_metadata(arguments: argparse.Namespace, github: GitHub, tag: str, commit: str) -> dict[str, Any] | None:
    if arguments.release_metadata is None and arguments.release_tag is None:
        return None
    supplied = (
        exact_dict(json_file(arguments.release_metadata, "release metadata"), "release metadata")
        if arguments.release_metadata is not None
        else None
    )
    requested_tag = arguments.release_tag or (supplied.get("tag_name") if supplied else None)
    if requested_tag != tag:
        raise Blocked(f"release tag must be {tag}")
    hosted = exact_dict(github.json(f"repos/{arguments.repository}/releases/tags/{tag}"), "hosted release metadata")
    resolved = exact_dict(github.json(f"repos/{arguments.repository}/commits/{tag}"), "release tag commit")
    payload = {**hosted, "commit": resolved.get("sha")}
    if supplied is not None:
        fields = ("id", "tag_name", "commit", "html_url", "published_at", "draft", "prerelease")
        expected = {**hosted, "commit": resolved.get("sha")}
        if any(supplied.get(field) != expected.get(field) for field in fields):
            raise Blocked("supplied release metadata differs from the hosted published release")
    if payload.get("tag_name") != tag or payload.get("commit") != commit:
        raise Blocked("published release metadata does not match the verified candidate")
    if payload.get("draft") is not False or payload.get("prerelease") is not False or not payload.get("published_at"):
        raise Blocked("release metadata must describe a published stable non-draft release")
    return payload


def prepare(arguments: argparse.Namespace) -> dict[str, object]:
    if not arguments.run_id.isdigit() or int(arguments.run_id) <= 0:
        raise Blocked("--run-id must be a positive numeric GitHub Actions run ID")
    if arguments.repository != REPOSITORY:
        raise Blocked(f"--repository must be {REPOSITORY}")
    output = arguments.output.resolve()
    build = (ROOT / "build").resolve()
    if output == build or build not in output.parents:
        raise Blocked("--output must name a new directory below the repository build directory")
    if output.exists():
        raise Blocked("--output already exists; choose a new explicit build directory")
    github = GitHub(arguments.gh, arguments.repository)
    first_run = github.run(arguments.run_id)
    commit, attempt = validate_run(first_run, arguments.run_id, arguments.repository)
    jobs = validate_jobs(github.jobs(arguments.run_id, attempt))
    selected = select_artifacts(github.artifacts(arguments.run_id), commit)
    output.parent.mkdir(parents=True, exist_ok=True)
    temp = Path(tempfile.mkdtemp(prefix=f".{output.name}-", dir=output.parent))
    try:
        artifact_rows: dict[str, dict[str, object]] = {}
        roots: dict[str, Path] = {}
        for role in sorted(selected):
            row = selected[role]
            data = github.artifact_zip(row["id"])
            downloaded = sha256_bytes(data)
            if not isinstance(row.get("size_in_bytes"), int) or isinstance(row.get("size_in_bytes"), bool) or row["size_in_bytes"] != len(data):
                raise Blocked(f"{role} downloaded ZIP size does not match GitHub artifact metadata")
            if downloaded != str(row["digest"])[7:]:
                raise Blocked(f"{role} downloaded ZIP digest does not match GitHub artifact metadata")
            zip_path = temp / "artifacts" / f"{role}.zip"
            zip_path.parent.mkdir(parents=True, exist_ok=True)
            zip_path.write_bytes(data)
            root = temp / "evidence" / role
            root.mkdir(parents=True)
            safe_extract(data, root)
            roots[role] = root
            artifact_rows[role] = {
                "id": row["id"], "name": row["name"], "github_digest": row["digest"],
                "download_sha256": downloaded, "size_in_bytes": row.get("size_in_bytes"),
            }
        manifest, release_files = validate_manifest(
            roots["release_evidence"], commit,
            github.content("spec/release-manifest.json", commit),
        )
        preflight, preflight_impact, preflight_files = validate_preflight(
            roots["preflight"], manifest, commit, str(selected["preflight"]["name"])
        )
        dependencies = exact_dict(preflight.get("dependencies"), "preflight dependencies")
        pinned_aslref = github.content(".aslref-version", commit).decode("utf-8").strip()
        if pinned_aslref != dependencies.get("aslref"):
            raise Blocked("release preflight ASLRef dependency differs from the exact candidate pin")
        if github.submodule_commit("tools/ndf", commit) != dependencies.get("pto_ndf"):
            raise Blocked("release preflight PTO NDF dependency differs from the exact candidate submodule")
        site, site_files = validate_site(roots["site"], manifest, commit)
        tuple_, model_files, semantic_digest = validate_model(
            roots["model"], manifest, preflight, preflight_impact, commit,
            arguments.run_id, attempt, str(selected["model"]["name"])
        )
        tag = f"v{manifest['publication_version']}"
        published = release_metadata(arguments, github, tag, commit)
        second_run = github.run(arguments.run_id)
        second_commit, second_attempt = validate_run(second_run, arguments.run_id, arguments.repository)
        if second_commit != commit or second_attempt != attempt or second_run.get("updated_at") != first_run.get("updated_at"):
            raise Blocked("workflow run identity changed while evidence was being prepared")
        handoff: dict[str, object] = {
            "schema": "pto.release-publication-handoff.v1",
            "state": "ready",
            "authority": "hosted-verification-snapshot-recheck-required-before-publication",
            "next_action": "re-read this exact hosted run and artifact identities immediately before any separate publication action",
            "repository": arguments.repository,
            "workflow": {"path": WORKFLOW_PATH, "event": "workflow_dispatch", "run_id": arguments.run_id, "run_attempt": attempt, "commit": commit, "updated_at": first_run.get("updated_at")},
            "candidate": {"architecture_version": manifest["release"], "publication_version": manifest["publication_version"], "tag": tag, "encoding_abi": manifest["encoding_abi"], "encoding_projection_sha256": manifest["encoding_projection_sha256"], "components": tuple_},
            "required_jobs": jobs,
            "artifacts": artifact_rows,
            "evidence_sha256": {**{f"preflight/{k}": v for k, v in preflight_files.items()}, **{f"release_evidence/{k}": v for k, v in release_files.items()}, **{f"site/{k}": v for k, v in site_files.items()}, **{f"model/{k}": v for k, v in model_files.items()}},
            "model_closure_semantic_payload_sha256": semantic_digest,
            "site_tree_sha256": site["site_tree_sha256"],
            "release_event": None,
        }
        if published is not None:
            event = {
                "schema_version": "1", "repository": arguments.repository, "tag": tag,
                "commit": commit, "release_id": published.get("id"), "release_url": published.get("html_url"),
                "release_manifest_sha256": sha256_file(unique_suffix(roots["release_evidence"], "spec/release-manifest.json")),
                "model_closure_semantic_payload_sha256": semantic_digest, "published_at": published.get("published_at"),
            }
            event_path = temp / "pto-spec-release-event-v1.json"
            event_path.write_text(canonical_release_event(event) + "\n", encoding="utf-8")
            handoff["release_event"] = {"path": event_path.name, "sha256": sha256_file(event_path)}
        handoff_path = temp / "publication-handoff.json"
        handoff_path.write_text(canonical_json(handoff, pretty=True), encoding="utf-8")
        checksummed = sorted(path for path in temp.rglob("*") if path.is_file())
        checksum_lines = [f"{sha256_file(path)}  {path.relative_to(temp).as_posix()}" for path in checksummed]
        (temp / "SHA256SUMS").write_text("\n".join(checksum_lines) + "\n", encoding="utf-8")
        os.replace(temp, output)
        return {"state": "ready", "run_id": arguments.run_id, "run_attempt": attempt, "commit": commit, "output": str(output), "handoff": str(output / "publication-handoff.json"), "next_action": handoff["next_action"]}
    except Exception:
        shutil.rmtree(temp, ignore_errors=True)
        raise


def parser() -> argparse.ArgumentParser:
    result = MachineParser(description=__doc__)
    result.add_argument("--run-id", required=True)
    result.add_argument("--output", required=True, type=Path)
    result.add_argument("--repository", default=REPOSITORY)
    result.add_argument("--gh", default="gh")
    release = result.add_mutually_exclusive_group()
    release.add_argument("--release-metadata", type=Path)
    release.add_argument("--release-tag")
    return result


def main(argv: list[str] | None = None) -> int:
    try:
        arguments = parser().parse_args(argv)
        result = prepare(arguments)
    except (Blocked, OSError, ValueError, KeyError, TypeError) as error:
        print(canonical_json({"state": "blocked", "errors": [str(error)], "next_action": "fix the reported prerequisite and run one fresh explicit preparation command"}).rstrip())
        return 1
    print(canonical_json(result).rstrip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
