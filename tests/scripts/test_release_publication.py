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
from scripts.release_publication import Blocked, main


PTO = "1" * 40
NDF = "4" * 40
ASLREF = "5" * 40
RUN_ID = "12345"
ATTEMPT = 2
ENCODING = "a" * 64


def canonical_bytes(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()


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
        "release": "0.58.7",
        "publication_version": "0.58.7.0",
        "encoding_abi": "pto-isa-0.58.7-mode-function-v1",
        "encoding_projection_sha256": ENCODING,
        "content_sha256": "0" * 64 if stale else canonical_sha256(inputs),
        "canonical_inputs": [
            {"path": key, "sha256": value} for key, value in inputs.items()
        ],
        "release_selection": {
            "architecture_version": "0.58.7",
            "publication_version": "0.58.7.0",
            "blockers": [],
        },
    }
    entry = {
        "id": "PTO-AVS-TEST-001",
        "path": "tests/asl/test.asl",
        "sha256": "d" * 64,
    }
    matrix = canonical_bytes(
        {
            "commit": matrix_commit,
            "page": 0,
            "page_count": 1,
            "test_count": 1,
            "include": [entry],
        }
    )
    coverage = canonical_bytes(
        {
            "schema": "pto.asl-test-coverage.v1",
            "commit": matrix_commit,
            "status": "passed",
            "test_count": 1,
            "passed_count": 1,
            "results": [{**entry, "status": "passed"}],
        }
    )
    return write_zip(
        path,
        {
            "spec/release-manifest.json": json.dumps(manifest, sort_keys=True).encode(),
            "build/asl-test-matrix.json": matrix,
            "build/asl-test-coverage.json": coverage,
            "spec/evidence/asl-test-matrix.sha256": (
                f"{hashlib.sha256(matrix).hexdigest()}  build/asl-test-matrix.json\n"
            ).encode(),
        },
    )


def preflight_candidate() -> dict[str, object]:
    return {
        "schema": "pto.release-preflight.v2",
        "scope": "pto-spec",
        "commits": {"pto": PTO, "workflow": PTO},
        "identity": {
            "release": "0.58.7",
            "publication_version": "0.58.7.0",
            "encoding_abi": "pto-isa-0.58.7-mode-function-v1",
            "encoding_projection_sha256": ENCODING,
        },
        "dependencies": {"pto_ndf": NDF, "aslref": ASLREF},
    }


def preflight_archive(path: Path) -> str:
    return write_zip(path, {"candidate.json": canonical_bytes(preflight_candidate())})


def extract(archive: Path, destination: Path) -> Path:
    destination.mkdir(parents=True)
    with zipfile.ZipFile(archive) as zipped:
        zipped.extractall(destination)
    return destination


def certification_archive(path: Path, release: Path, preflight: Path) -> str:
    root = path.parent / "certification-fixture"
    release_root = extract(release, root / "release")
    preflight_root = extract(preflight, root / "preflight")
    pto = root / "pto"
    (pto / "spec").mkdir(parents=True)
    (pto / "tools/ndf").mkdir(parents=True)
    (pto / ".aslref-version").write_text(ASLREF + "\n")
    manifest = next(release_root.rglob("release-manifest.json"))
    (pto / "spec/release-manifest.json").write_bytes(manifest.read_bytes())

    def git_head(command: list[str], **_: object) -> str:
        return (NDF if command[2].endswith("tools/ndf") else PTO) + "\n"

    with mock.patch("scripts.release_artifacts.subprocess.check_output", side_effect=git_head):
        report = certify(
            pto_root=pto,
            release_evidence_root=release_root,
            preflight_root=preflight_root,
            pto_commit=PTO,
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
        "Release / uploaded artifact certification",
        "Release / validate",
    )
    jobs = [
        {
            "id": index,
            "name": f"Release verification / {name}",
            "status": "completed",
            "conclusion": "skipped" if skipped and index == len(suffixes) else "success",
        }
        for index, name in enumerate(suffixes, 1)
    ]
    return {"total_count": len(jobs), "jobs": jobs}


class ReleasePublicationTest(unittest.TestCase):
    def setUp(self) -> None:
        (Path.cwd() / "build").mkdir(exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(dir=Path.cwd() / "build")
        self.root = Path(self.temporary.name)
        self.api = self.root / "api"
        self.api.mkdir()
        release = self.api / "1.zip"
        preflight = self.api / "2.zip"
        certification = self.api / "3.zip"
        digests = {
            1: release_archive(release),
            2: preflight_archive(preflight),
        }
        digests[3] = certification_archive(certification, release, preflight)
        artifacts = [
            {"id": 1, "name": f"pto-release-evidence-{PTO}", "expired": False, "digest": f"sha256:{digests[1]}", "size_in_bytes": release.stat().st_size},
            {"id": 2, "name": f"pto-release-preflight-{PTO}", "expired": False, "digest": f"sha256:{digests[2]}", "size_in_bytes": preflight.stat().st_size},
            {"id": 3, "name": f"pto-release-artifact-certification-{PTO}-{RUN_ID}-{ATTEMPT}", "expired": False, "digest": f"sha256:{digests[3]}", "size_in_bytes": certification.stat().st_size},
        ]
        (self.api / "run.json").write_text(json.dumps(run_payload()))
        (self.api / "jobs.json").write_text(json.dumps(jobs_payload()))
        (self.api / "artifacts.json").write_text(json.dumps({"total_count": 3, "artifacts": artifacts}))
        with zipfile.ZipFile(release) as archive:
            manifest = archive.read("spec/release-manifest.json")
        for name, data in (("contents.json", manifest), ("aslref.json", (ASLREF + "\n").encode())):
            (self.api / name).write_text(json.dumps({"encoding": "base64", "content": base64.b64encode(data).decode()}))
        (self.api / "ndf.json").write_text(json.dumps({"sha": NDF, "type": "submodule"}))
        self.gh = self.root / "gh"
        self.gh.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "root=pathlib.Path(os.environ['MOCK_GH_DIR']); endpoint=sys.argv[2]\n"
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
            f"  sys.stdout.write(json.dumps({{'sha':'{PTO}'}}))\n"
            "else:\n"
            "  count=root/'run-count'; n=int(count.read_text())+1 if count.exists() else 1; count.write_text(str(n))\n"
            "  candidate=root/('run%d.json'%n); sys.stdout.write((candidate if candidate.exists() else root/'run.json').read_text())\n"
        )
        self.gh.chmod(0o755)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def invoke(self, *extra: str) -> tuple[int, Path]:
        output = self.root / "handoff"
        with mock.patch.dict(os.environ, {"MOCK_GH_DIR": str(self.api)}):
            result = main(["--run-id", RUN_ID, "--output", str(output), "--gh", str(self.gh), *extra])
        return result, output

    def test_success_writes_pto_only_v2_handoff(self) -> None:
        result, output = self.invoke()
        self.assertEqual(result, 0)
        handoff = json.loads((output / "publication-handoff.json").read_text())
        self.assertEqual(handoff["schema"], "pto.release-publication-handoff.v2")
        self.assertEqual(handoff["scope"], "pto-spec")
        self.assertEqual(handoff["candidate"]["components"], {"pto_spec": PTO, "pto_ndf": NDF, "aslref": ASLREF})
        self.assertEqual(set(handoff["artifacts"]), {"preflight", "release_evidence", "certification"})
        self.assertNotIn("site_tree_sha256", handoff)
        self.assertNotIn("model_closure_semantic_payload_sha256", handoff)
        self.assertFalse((output / "pto-spec-release-event-v2.json").exists())

    def test_published_metadata_produces_v2_event_from_certification(self) -> None:
        metadata = {
            "id": 77,
            "tag_name": "v0.58.7.0",
            "commit": PTO,
            "html_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.7.0",
            "published_at": "2026-09-05T03:00:00Z",
            "draft": False,
            "prerelease": False,
        }
        path = self.root / "published.json"
        path.write_text(json.dumps(metadata))
        (self.api / "release.json").write_text(json.dumps({key: value for key, value in metadata.items() if key != "commit"}))
        result, output = self.invoke("--release-metadata", str(path))
        self.assertEqual(result, 0)
        event = json.loads((output / "pto-spec-release-event-v2.json").read_text())
        handoff = json.loads((output / "publication-handoff.json").read_text())
        self.assertEqual(event["schema_version"], "2")
        self.assertEqual(event["release_artifact_certification_sha256"], handoff["release_artifact_certification_sha256"])

    def test_site_and_model_artifacts_do_not_participate(self) -> None:
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"].extend([
            {"id": 90, "name": f"pto-site-preview-{PTO}", "expired": True},
            {"id": 91, "name": f"pto-model-closure-{PTO}-bad", "expired": True},
        ])
        artifacts["total_count"] = len(artifacts["artifacts"])
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, _ = self.invoke()
        self.assertEqual(result, 0)

    def test_missing_certification_is_rejected(self) -> None:
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"].pop()
        artifacts["total_count"] = 2
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_different_commit_release_evidence_is_rejected(self) -> None:
        archive = self.api / "1.zip"
        digest = release_archive(archive, matrix_commit="f" * 40)
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][0].update(
            {"digest": f"sha256:{digest}", "size_in_bytes": archive.stat().st_size}
        )
        with zipfile.ZipFile(archive) as zipped:
            manifest = zipped.read("spec/release-manifest.json")
        (self.api / "contents.json").write_text(
            json.dumps(
                {
                    "encoding": "base64",
                    "content": base64.b64encode(manifest).decode(),
                }
            )
        )
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_unsafe_archive_member_is_rejected(self) -> None:
        archive = self.api / "2.zip"
        digest = write_zip(archive, {"../escape": b"bad"})
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][1].update(
            {"digest": f"sha256:{digest}", "size_in_bytes": archive.stat().st_size}
        )
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())
        self.assertFalse((self.root / "escape").exists())

    def test_forged_certification_is_rejected(self) -> None:
        archive = self.api / "3.zip"
        with zipfile.ZipFile(archive) as zipped:
            report = json.loads(zipped.read("report.json"))
        report["candidate"]["components"]["pto_ndf"] = "f" * 40
        digest = write_zip(archive, {"report.json": (json.dumps(report, indent=2, sort_keys=True) + "\n").encode()})
        artifacts = json.loads((self.api / "artifacts.json").read_text())
        artifacts["artifacts"][2].update({"digest": f"sha256:{digest}", "size_in_bytes": archive.stat().st_size})
        (self.api / "artifacts.json").write_text(json.dumps(artifacts))
        result, output = self.invoke()
        self.assertEqual(result, 1)
        self.assertFalse(output.exists())

    def test_skipped_gate_and_changed_attempt_are_rejected(self) -> None:
        (self.api / "jobs.json").write_text(json.dumps(jobs_payload(skipped=True)))
        self.assertEqual(self.invoke()[0], 1)
        (self.api / "jobs.json").write_text(json.dumps(jobs_payload()))
        (self.api / "run2.json").write_text(json.dumps(run_payload(attempt=ATTEMPT + 1)))
        self.assertEqual(self.invoke()[0], 1)


class ReleaseArtifactCertificationTest(unittest.TestCase):
    def setUp(self) -> None:
        (Path.cwd() / "build").mkdir(exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(dir=Path.cwd() / "build")
        self.root = Path(self.temporary.name)
        release = self.root / "release.zip"
        preflight = self.root / "preflight.zip"
        release_archive(release)
        preflight_archive(preflight)
        self.release = extract(release, self.root / "release")
        self.preflight = extract(preflight, self.root / "preflight")
        self.pto = self.root / "pto"
        (self.pto / "spec").mkdir(parents=True)
        (self.pto / "tools/ndf").mkdir(parents=True)
        (self.pto / ".aslref-version").write_text(ASLREF + "\n")
        (self.pto / "spec/release-manifest.json").write_bytes(next(self.release.rglob("release-manifest.json")).read_bytes())

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def certify(self, *, ndf: str = NDF) -> dict[str, object]:
        def git_head(command: list[str], **_: object) -> str:
            return (ndf if command[2].endswith("tools/ndf") else PTO) + "\n"

        with mock.patch("scripts.release_artifacts.subprocess.check_output", side_effect=git_head):
            return certify(
                pto_root=self.pto,
                release_evidence_root=self.release,
                preflight_root=self.preflight,
                pto_commit=PTO,
                run_id=RUN_ID,
                run_attempt=ATTEMPT,
            )

    def test_pto_only_artifacts_are_certified_offline(self) -> None:
        report = self.certify()
        self.assertEqual(report["schema"], "pto.release-artifact-certification.v2")
        self.assertEqual(report["scope"], "pto-spec")
        self.assertEqual(set(report["artifacts"]), {"preflight", "release_evidence"})
        self.assertEqual(set(report["candidate"]["components"]), {"pto_spec", "pto_ndf", "aslref"})
        self.assertEqual(
            set(report["evidence_sha256"]),
            {
                "preflight/candidate.json",
                "release_evidence/spec/release-manifest.json",
                "release_evidence/build/asl-test-matrix.json",
                "release_evidence/build/asl-test-coverage.json",
                "release_evidence/spec/evidence/asl-test-matrix.sha256",
            },
        )

    def test_dependency_and_asl_evidence_mismatch_fail_closed(self) -> None:
        with self.assertRaisesRegex(Blocked, "NDF dependency"):
            self.certify(ndf="f" * 40)
        coverage = next(self.release.rglob("asl-test-coverage.json"))
        payload = json.loads(coverage.read_text())
        payload["results"] = []
        coverage.write_text(json.dumps(payload))
        with self.assertRaisesRegex(Blocked, "ASL release evidence is incomplete"):
            self.certify()


if __name__ == "__main__":
    unittest.main()
