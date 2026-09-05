from __future__ import annotations

import base64
import hashlib
import json
import os
from pathlib import Path
import stat
import tempfile
import unittest
from unittest import mock
import zipfile

from scripts.model_closure import canonical_sha256
from scripts.release_artifacts import certify
from scripts.release_publication import Blocked
from scripts.release_publication import main


PTO = "1" * 40
LLVM = "2" * 40
MODEL = "3" * 40
NDF = "4" * 40
ASLREF = "5" * 40
RUN_ID = "12345"
ATTEMPT = 2
ENCODING = "a" * 64
IMPACT_DOCUMENT = {
    "schema_version": "0.1",
    "command": "impact pto-release",
    "ok": True,
    "diagnostics": [],
    "data": {"schema_version": "1", "changes": [], "conformance_targets": []},
}
IMPACT_BYTES = (
    json.dumps(IMPACT_DOCUMENT, sort_keys=True, separators=(",", ":")) + "\n"
).encode()
IMPACT_DATA_SHA256 = canonical_sha256(IMPACT_DOCUMENT["data"])


def write_zip(path: Path, files: dict[str, bytes]) -> str:
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(files.items()):
            info = zipfile.ZipInfo(name, (2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = (stat.S_IFREG | 0o644) << 16
            archive.writestr(info, data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def release_archive(path: Path, *, matrix_commit: str = PTO, stale: bool = False) -> str:
    inputs = {"asl/arch.asl": "b" * 64, "asl/scalar.asl": "c" * 64}
    manifest = {
        "schema_version": 1,
        "release": "0.58.5",
        "publication_version": "0.58.5.1",
        "encoding_abi": "pto-isa-0.58.5-mode-function-v1",
        "encoding_projection_sha256": ENCODING,
        "content_sha256": "0" * 64 if stale else canonical_sha256(inputs),
        "canonical_inputs": [{"path": key, "sha256": value} for key, value in inputs.items()],
        "release_selection": {
            "architecture_version": "0.58.5",
            "publication_version": "0.58.5.1",
            "blockers": [],
        },
    }
    entry = {"id": "PTO-AVS-TEST-001", "path": "tests/asl/test.asl", "sha256": "d" * 64}
    matrix = json.dumps(
        {"commit": matrix_commit, "page": 0, "page_count": 1, "test_count": 1, "include": [entry]},
        sort_keys=True, separators=(",", ":"),
    ) + "\n"
    coverage = json.dumps({
        "schema": "pto.asl-test-coverage.v1", "commit": matrix_commit, "status": "passed",
        "test_count": 1, "passed_count": 1,
        "results": [{"id": entry["id"], "path": entry["path"], "sha256": entry["sha256"], "status": "passed"}],
    }, sort_keys=True) + "\n"
    digest = hashlib.sha256(matrix.encode()).hexdigest()
    return write_zip(
        path,
        {
            "spec/release-manifest.json": json.dumps(manifest, sort_keys=True).encode(),
            "build/asl-test-matrix.json": matrix.encode(),
            "build/asl-test-coverage.json": coverage.encode(),
            "spec/evidence/asl-test-matrix.sha256": f"{digest}  build/asl-test-matrix.json\n".encode(),
        },
    )


def site_archive(path: Path) -> str:
    files = {".nojekyll": b"", "index.html": b"<html>PTO</html>\n"}
    tree = hashlib.sha256()
    for name, data in sorted(files.items()):
        tree.update(name.encode())
        tree.update(b"\0")
        tree.update(bytes.fromhex(hashlib.sha256(data).hexdigest()))
        tree.update(b"\n")
    site = {
        "schema": "pto.site-publication.v1",
        "architecture_version": "0.58.5",
        "publication_version": "0.58.5.1",
        "tag": "v0.58.5.1",
        "source_commit": PTO,
        "release_eligible": True,
        "publication_state": "release",
        "file_count": len(files),
        "content_bytes": len(files["index.html"]),
        "site_tree_sha256": tree.hexdigest(),
    }
    files["pto-site-publication.json"] = json.dumps(site, sort_keys=True).encode()
    return write_zip(path, files)


def semantic_payload() -> dict[str, object]:
    obligations = ["PTO-OBLIGATION-ADD"]
    cases = ["PTO-CLOSURE-ADD-001"]
    lock: dict[str, object] = {
        "schema": "pto-closure-lock-v1",
        "identity": {
            "release": "0.58.5",
            "publication_version": "0.58.5.1",
            "encoding_abi": "pto-isa-0.58.5-mode-function-v1",
            "encoding_projection_sha256": ENCODING,
        },
        "repositories": {
            "pto_spec": {"repository": "https://github.com/PTO-ISA/pto-spec.git", "commit": PTO, "tree": "6" * 40},
            "llvm": {"repository": "https://github.com/LinxISA/llvm-project.git", "commit": LLVM, "tree": "7" * 40},
            "asl_model": {"repository": "https://github.com/PTO-ISA/asl-model.git", "commit": MODEL, "tree": "8" * 40},
            "normative_language": {"repository": "https://github.com/PTO-ISA/normative_language.git", "commit": NDF, "tree": "9" * 40},
            "aslref": {"repository": "https://github.com/PTO-ISA/herdtools7.git", "commit": ASLREF, "tree": "a" * 40},
        },
        "tools": {name: {"path": f"/tools/{name}", "sha256": "d" * 64} for name in ("clang", "llvm_mc", "ld_lld", "aslref")},
        "target": {"triple": "linx64-linx-none-elf"},
        "model": {"abi": "pto-asl-model-experimental-v2", "worker_protocol": "pto-asl-worker-v1", "backend": "reference-array", "profile": "bounded-reference-v1"},
        "corpus": {"sha256": "e" * 64, "case_ids": cases},
        "obligations": {"affected_pto_ids": ["PTO-INST-ADD"], "selected": obligations, "sha256": canonical_sha256(obligations)},
    }
    return {
        "schema": "pto-closure-semantic-payload-v1",
        "closure_lock": lock,
        "closure_lock_sha256": canonical_sha256(lock),
        "ndf_impact": {"sha256": IMPACT_DATA_SHA256, "affected_pto_ids": ["PTO-INST-ADD"]},
        "obligations": {"selected": obligations, "completed": obligations, "passed": obligations, "failed": []},
        "cases": {"selected": cases, "completed": cases, "passed": cases, "failed": [], "skipped": [], "timeout": [], "unknown": []},
        "case_manifests": [{"case_id": cases[0], "sha256": "0" * 64}],
    }


def envelope(payload: object, number: int) -> dict[str, object]:
    return {
        "schema": "pto-closure-run-envelope-v1",
        "semantic_payload_sha256": canonical_sha256(payload),
        "workflow": {"repository": "PTO-ISA/pto-spec", "path": ".github/workflows/release.yml", "commit": PTO},
        "run": {"id": f"{RUN_ID}-{number}", "attempt": ATTEMPT, "timestamp": "2026-09-05T01:02:03Z"},
        "runner": {"image": "Linux-X64", "builder_identity": "github-hosted"},
        "artifact_sha256": str(number) * 64,
        "attestation": None,
    }


def preflight_candidate() -> dict[str, object]:
    return {
        "schema": "pto.release-preflight.v1",
        "commits": {"pto": PTO, "llvm": LLVM, "asl_model": MODEL, "workflow": PTO},
        "identity": {"release": "0.58.5", "publication_version": "0.58.5.1", "encoding_abi": "pto-isa-0.58.5-mode-function-v1", "encoding_projection_sha256": ENCODING},
        "baselines": {"model_graph_import": "6" * 40, "impact_adoption": "7" * 40},
        "dependencies": {"pto_ndf": NDF, "asl_model_ndf": NDF, "aslref": ASLREF},
        "selection": {"mandatory_case_ids": ["scalar_stop_pc"]},
        "impact": {"sha256": hashlib.sha256(IMPACT_BYTES).hexdigest(), "affected_pto_ids": ["PTO-INST-ADD"], "avs_cases_by_pto_id": {"PTO-INST-ADD": ["add"]}},
    }


def canonical_bytes(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()


def preflight_archive(path: Path) -> str:
    return write_zip(path, {"candidate.json": canonical_bytes(preflight_candidate()), "ndf-impact.json": IMPACT_BYTES})


def model_archive(path: Path) -> str:
    payload = semantic_payload()
    files: dict[str, bytes] = {
        "release-preflight/candidate.json": canonical_bytes(preflight_candidate()),
        "release-preflight/ndf-impact.json": IMPACT_BYTES,
    }
    for number in (1, 2):
        prefix = f"model-closure-run-{number}/evidence"
        files[f"{prefix}/closure-semantic-payload.json"] = json.dumps(payload, sort_keys=True).encode()
        files[f"{prefix}/closure-run-envelope.json"] = json.dumps(envelope(payload, number), sort_keys=True).encode()
    return write_zip(path, files)


def certification_archive(path: Path, archives: dict[str, Path]) -> str:
    root = path.parent / "certification-fixture"
    roots: dict[str, Path] = {}
    for role, archive in archives.items():
        destination = root / role
        destination.mkdir(parents=True)
        with zipfile.ZipFile(archive) as zipped:
            zipped.extractall(destination)
        roots[role] = destination
    pto = root / "pto"
    (pto / "spec").mkdir(parents=True)
    (pto / "tools/ndf").mkdir(parents=True)
    (pto / ".aslref-version").write_text(ASLREF + "\n")
    manifest = next(roots["release_evidence"].rglob("release-manifest.json"))
    (pto / "spec/release-manifest.json").write_bytes(manifest.read_bytes())

    def git_head(command: list[str], **_: object) -> str:
        return (NDF if command[2].endswith("tools/ndf") else PTO) + "\n"

    with mock.patch(
        "scripts.release_artifacts.subprocess.check_output", side_effect=git_head
    ):
        report = certify(
            pto_root=pto,
            release_evidence_root=roots["release_evidence"],
            preflight_root=roots["preflight"],
            site_root=roots["site"],
            model_root=roots["model"],
            pto_commit=PTO,
            llvm_commit=LLVM,
            asl_model_commit=MODEL,
            run_id=RUN_ID,
            run_attempt=ATTEMPT,
        )
    return write_zip(
        path,
        {"report.json": (json.dumps(report, indent=2, sort_keys=True) + "\n").encode()},
    )


def run_payload(*, attempt: int = ATTEMPT) -> dict[str, object]:
    return {
        "id": int(RUN_ID),
        "event": "workflow_dispatch",
        "path": ".github/workflows/release.yml",
        "repository": {"full_name": "PTO-ISA/pto-spec"},
        "status": "completed",
        "conclusion": "success",
        "head_sha": PTO,
        "run_attempt": attempt,
        "updated_at": "2026-09-05T02:00:00Z",
    }


def jobs_payload(*, skipped: bool = False) -> dict[str, object]:
    suffixes = (
        "Release / candidate preflight",
        "Full validation / health",
        "Release / fail-closed evidence aggregation",
        "Release / static site validity",
        "Release / LLVM-to-ASL model closure",
        "Release / uploaded artifact certification",
        "Release / validate",
    )
    jobs = [
        {"id": index, "name": f"Release verification / {name}", "status": "completed", "conclusion": "skipped" if skipped and index == len(suffixes) else "success"}
        for index, name in enumerate(suffixes, 1)
    ]
    return {"total_count": len(jobs), "jobs": jobs}


class ReleasePublicationTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(dir=Path.cwd() / "build")
        self.root = Path(self.temporary.name)
        self.api = self.root / "api"
        self.api.mkdir()
        release = self.api / "1.zip"
        site = self.api / "2.zip"
        model = self.api / "3.zip"
        preflight = self.api / "4.zip"
        certification = self.api / "5.zip"
        digests = {
            1: release_archive(release),
            2: site_archive(site),
            3: model_archive(model),
            4: preflight_archive(preflight),
        }
        digests[5] = certification_archive(certification, {
            "release_evidence": release,
            "site": site,
            "model": model,
            "preflight": preflight,
        })
        artifacts = [
            {"id": 1, "name": f"pto-release-evidence-{PTO}", "expired": False, "digest": f"sha256:{digests[1]}", "size_in_bytes": release.stat().st_size},
            {"id": 2, "name": f"pto-site-preview-{PTO}", "expired": False, "digest": f"sha256:{digests[2]}", "size_in_bytes": site.stat().st_size},
            {"id": 3, "name": f"pto-model-closure-{PTO}-{LLVM}-{MODEL}", "expired": False, "digest": f"sha256:{digests[3]}", "size_in_bytes": model.stat().st_size},
            {"id": 4, "name": f"pto-release-preflight-{PTO}-{LLVM}-{MODEL}", "expired": False, "digest": f"sha256:{digests[4]}", "size_in_bytes": preflight.stat().st_size},
            {"id": 5, "name": f"pto-release-artifact-certification-{PTO}-{RUN_ID}-{ATTEMPT}", "expired": False, "digest": f"sha256:{digests[5]}", "size_in_bytes": certification.stat().st_size},
        ]
        (self.api / "run.json").write_text(json.dumps(run_payload()))
        (self.api / "jobs.json").write_text(json.dumps(jobs_payload()))
        (self.api / "artifacts.json").write_text(json.dumps({"total_count": 5, "artifacts": artifacts}))
        with zipfile.ZipFile(release) as archive:
            manifest_bytes = archive.read("spec/release-manifest.json")
        (self.api / "contents.json").write_text(json.dumps({"encoding": "base64", "content": base64.b64encode(manifest_bytes).decode()}))
        (self.api / "aslref.json").write_text(json.dumps({"encoding": "base64", "content": base64.b64encode((ASLREF + "\n").encode()).decode()}))
        (self.api / "ndf.json").write_text(json.dumps({"sha": NDF, "type": "submodule"}))
        self.gh = self.root / "gh"
        self.gh.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "root=pathlib.Path(os.environ['MOCK_GH_DIR'])\n"
            "endpoint=sys.argv[2]\n"
            "if '/actions/artifacts/' in endpoint:\n"
            "  sys.stdout.buffer.write((root/(endpoint.split('/actions/artifacts/')[1].split('/')[0]+'.zip')).read_bytes())\n"
            "elif endpoint.endswith('/artifacts?per_page=100'):\n"
            "  sys.stdout.write((root/'artifacts.json').read_text())\n"
            "elif '/contents/' in endpoint:\n"
            "  name='aslref.json' if '/.aslref-version?' in endpoint else ('ndf.json' if '/tools/ndf?' in endpoint else 'contents.json')\n"
            "  sys.stdout.write((root/name).read_text())\n"
            "elif '/attempts/' in endpoint:\n"
            "  sys.stdout.write((root/'jobs.json').read_text())\n"
            "elif '/releases/tags/' in endpoint:\n"
            "  sys.stdout.write((root/'release.json').read_text())\n"
            "elif '/commits/' in endpoint:\n"
            "  sys.stdout.write(json.dumps({'sha':'1'*40}))\n"
            "else:\n"
            "  count=root/'run-count'\n"
            "  n=int(count.read_text())+1 if count.exists() else 1\n"
            "  count.write_text(str(n))\n"
            "  candidate=root/('run%d.json'%n)\n"
            "  sys.stdout.write((candidate if candidate.exists() else root/'run.json').read_text())\n"
        )
        self.gh.chmod(0o755)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def invoke(self, *extra: str) -> tuple[int, Path]:
        output = self.root / "handoff"
        with mock.patch.dict(os.environ, {"MOCK_GH_DIR": str(self.api)}):
            result = main(["--run-id", RUN_ID, "--output", str(output), "--gh", str(self.gh), *extra])
        return result, output

    def test_success_writes_ready_handoff_without_claiming_publication(self) -> None:
        result, output = self.invoke()
        self.assertEqual(result, 0)
        handoff = json.loads((output / "publication-handoff.json").read_text())
        self.assertEqual(handoff["state"], "ready")
        self.assertEqual(handoff["candidate"]["components"]["pto_ndf"], NDF)
        self.assertEqual(handoff["candidate"]["components"]["asl_model_ndf"], NDF)
        self.assertEqual(handoff["candidate"]["components"]["aslref"], ASLREF)
        self.assertIsNone(handoff["release_event"])
        self.assertFalse((output / "pto-spec-release-event-v1.json").exists())
        self.assertIn("publication-handoff.json", (output / "SHA256SUMS").read_text())
        self.assertEqual(
            handoff["artifacts"]["certification"]["name"],
            f"pto-release-artifact-certification-{PTO}-{RUN_ID}-{ATTEMPT}",
        )
        self.assertIn("certification/report.json", handoff["evidence_sha256"])
        self.assertEqual(
            handoff["artifact_certification"]["run"],
            {"id": RUN_ID, "attempt": ATTEMPT},
        )

    def test_published_metadata_produces_existing_stable_event_v1(self) -> None:
        metadata = self.root / "published.json"
        metadata.write_text(json.dumps({
            "id": 77, "tag_name": "v0.58.5.1", "commit": PTO, "html_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.5.1",
            "published_at": "2026-09-05T03:00:00Z", "draft": False, "prerelease": False,
        }))
        (self.api / "release.json").write_text(json.dumps({
            "id": 77, "tag_name": "v0.58.5.1", "html_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.5.1",
            "published_at": "2026-09-05T03:00:00Z", "draft": False, "prerelease": False,
        }))
        result, output = self.invoke("--release-metadata", str(metadata))
        self.assertEqual(result, 0)
        event = json.loads((output / "pto-spec-release-event-v1.json").read_text())
        self.assertEqual(event["release_id"], 77)
        self.assertEqual(event["commit"], PTO)

    def test_forged_supplied_release_metadata_is_rejected(self) -> None:
        metadata = self.root / "published.json"
        metadata.write_text(json.dumps({
            "id": 999, "tag_name": "v0.58.5.1", "commit": PTO,
            "html_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.5.1",
            "published_at": "2026-09-05T03:00:00Z", "draft": False, "prerelease": False,
        }))
        (self.api / "release.json").write_text(json.dumps({
            "id": 77, "tag_name": "v0.58.5.1", "html_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.5.1",
            "published_at": "2026-09-05T03:00:00Z", "draft": False, "prerelease": False,
        }))
        result, output = self.invoke("--release-metadata", str(metadata))
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_skipped_final_gate_blocks_before_artifact_download(self) -> None:
        (self.api / "jobs.json").write_text(json.dumps(jobs_payload(skipped=True)))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_changed_run_attempt_is_rejected_after_download(self) -> None:
        (self.api / "run2.json").write_text(json.dumps(run_payload(attempt=ATTEMPT + 1)))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_different_commit_release_evidence_is_rejected(self) -> None:
        archive = self.api / "1.zip"
        digest = release_archive(archive, matrix_commit="f" * 40)
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][0]["digest"] = f"sha256:{digest}"
        artifacts["artifacts"][0]["size_in_bytes"] = archive.stat().st_size
        with zipfile.ZipFile(archive) as zipped:
            manifest_bytes = zipped.read("spec/release-manifest.json")
        (self.api / "contents.json").write_text(json.dumps({"encoding": "base64", "content": base64.b64encode(manifest_bytes).decode()}))
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_stale_release_manifest_is_rejected(self) -> None:
        archive = self.api / "1.zip"
        digest = release_archive(archive, stale=True)
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][0]["digest"] = f"sha256:{digest}"
        artifacts["artifacts"][0]["size_in_bytes"] = archive.stat().st_size
        with zipfile.ZipFile(archive) as zipped:
            manifest_bytes = zipped.read("spec/release-manifest.json")
        (self.api / "contents.json").write_text(json.dumps({"encoding": "base64", "content": base64.b64encode(manifest_bytes).decode()}))
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_unsafe_archive_member_is_rejected(self) -> None:
        archive = self.api / "2.zip"
        digest = write_zip(archive, {"../escape": b"bad"})
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][1]["digest"] = f"sha256:{digest}"
        artifacts["artifacts"][1]["size_in_bytes"] = archive.stat().st_size
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())
        self.assertFalse((self.root / "escape").exists())

    def test_missing_certification_artifact_is_rejected(self) -> None:
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"] = [
            row for row in artifacts["artifacts"]
            if not row["name"].startswith("pto-release-artifact-certification-")
        ]
        artifacts["total_count"] = len(artifacts["artifacts"])
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_forged_certification_report_is_rejected(self) -> None:
        archive = self.api / "5.zip"
        with zipfile.ZipFile(archive) as zipped:
            report = json.loads(zipped.read("report.json"))
        report["site_tree_sha256"] = "f" * 64
        digest = write_zip(
            archive,
            {"report.json": (json.dumps(report, indent=2, sort_keys=True) + "\n").encode()},
        )
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][4]["digest"] = f"sha256:{digest}"
        artifacts["artifacts"][4]["size_in_bytes"] = archive.stat().st_size
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_different_run_certification_artifact_is_rejected(self) -> None:
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        forged = dict(artifacts["artifacts"][4])
        forged["id"] = 6
        forged["name"] = f"pto-release-artifact-certification-{PTO}-99999-{ATTEMPT}"
        artifacts["artifacts"].append(forged)
        artifacts["total_count"] += 1
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        (self.api / "6.zip").write_bytes((self.api / "5.zip").read_bytes())
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())


class ReleaseArtifactCertificationTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(dir=Path.cwd() / "build")
        self.root = Path(self.temporary.name)
        self.pto = self.root / "pto"
        (self.pto / "spec").mkdir(parents=True)
        (self.pto / "tools/ndf").mkdir(parents=True)
        (self.pto / ".aslref-version").write_text(ASLREF + "\n")
        builders = {
            "release_evidence": release_archive,
            "preflight": preflight_archive,
            "site": site_archive,
            "model": model_archive,
        }
        self.roots: dict[str, Path] = {}
        for role, builder in builders.items():
            archive = self.root / f"{role}.zip"
            builder(archive)
            destination = self.root / role
            destination.mkdir()
            with zipfile.ZipFile(archive) as zipped:
                zipped.extractall(destination)
            self.roots[role] = destination
        manifest = next(self.roots["release_evidence"].rglob("release-manifest.json"))
        (self.pto / "spec/release-manifest.json").write_bytes(manifest.read_bytes())

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def certify(self, **overrides: object) -> dict[str, object]:
        arguments: dict[str, object] = {
            "pto_root": self.pto,
            "release_evidence_root": self.roots["release_evidence"],
            "preflight_root": self.roots["preflight"],
            "site_root": self.roots["site"],
            "model_root": self.roots["model"],
            "pto_commit": PTO,
            "llvm_commit": LLVM,
            "asl_model_commit": MODEL,
            "run_id": RUN_ID,
            "run_attempt": ATTEMPT,
        }
        arguments.update(overrides)
        def git_head(command: list[str], **_: object) -> str:
            return (NDF if command[2].endswith("tools/ndf") else PTO) + "\n"

        with mock.patch(
            "scripts.release_artifacts.subprocess.check_output",
            side_effect=git_head,
        ):
            return certify(**arguments)  # type: ignore[arg-type]

    def test_same_run_downloaded_artifacts_are_certified_offline(self) -> None:
        report = self.certify()
        self.assertEqual(report["schema"], "pto.release-artifact-certification.v1")
        self.assertEqual(report["run"], {"id": RUN_ID, "attempt": ATTEMPT})
        self.assertEqual(
            report["candidate"]["components"]["llvm"],  # type: ignore[index]
            LLVM,
        )

    def test_omitted_hidden_site_file_is_rejected(self) -> None:
        (self.roots["site"] / ".nojekyll").unlink()
        with self.assertRaisesRegex(Blocked, "site artifact tree is incomplete"):
            self.certify()

    def test_different_component_tuple_is_rejected(self) -> None:
        with self.assertRaisesRegex(Blocked, "preflight commits"):
            self.certify(llvm_commit="f" * 40)

    def test_incomplete_asl_results_are_rejected(self) -> None:
        coverage = next(self.roots["release_evidence"].rglob("asl-test-coverage.json"))
        payload = json.loads(coverage.read_text())
        payload["results"] = []
        coverage.write_text(json.dumps(payload))
        with self.assertRaisesRegex(Blocked, "ASL release evidence is incomplete"):
            self.certify()

    def test_model_copy_of_preflight_must_match_standalone_artifact(self) -> None:
        candidate = next(self.roots["model"].rglob("candidate.json"))
        payload = json.loads(candidate.read_text())
        payload["selection"]["mandatory_case_ids"].append("forged")
        candidate.write_bytes(canonical_bytes(payload))
        with self.assertRaisesRegex(Blocked, "model artifact preflight evidence differs"):
            self.certify()


if __name__ == "__main__":
    unittest.main()
