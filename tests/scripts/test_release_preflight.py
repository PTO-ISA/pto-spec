from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from scripts.release_preflight import _git_head, approved_release_identity, validate_preflight


ROOT = Path(__file__).resolve().parents[2]
PTO = "a" * 40
WORKFLOW = PTO
IDENTITY = {
    "release": "0.58.7",
    "publication_version": "0.58.7.0",
    "encoding_abi": "pto-isa-0.58.7-mode-function-v1",
    "encoding_projection_sha256": "d" * 64,
}


class Fixture:
    def __init__(self, root: Path) -> None:
        self.pto = root / "pto"
        (self.pto / "spec").mkdir(parents=True)
        (self.pto / "scripts").mkdir()
        (self.pto / "tools/ndf").mkdir(parents=True)
        (self.pto / "specification.toml").write_text(
            "[release]\narchitecture_version='0.58.7'\n"
            "publication_version='0.58.7.0'\n"
            "encoding_abi='pto-isa-0.58.7-mode-function-v1'\n",
            encoding="utf-8",
        )
        self.manifest = {
            **IDENTITY,
            "release_selection": {"blockers": []},
        }
        self.write_manifest()
        (self.pto / ".aslref-version").write_text("f" * 40 + "\n", encoding="utf-8")

    def write_manifest(self) -> None:
        (self.pto / "spec/release-manifest.json").write_text(
            json.dumps(self.manifest), encoding="utf-8"
        )

    def validate(self) -> tuple[dict[str, object], mock.Mock]:
        run_command = mock.Mock()
        with mock.patch("scripts.release_preflight._git_head", side_effect=[PTO, "1" * 40]):
            result = validate_preflight(
                pto_root=self.pto,
                pto_commit=PTO,
                workflow_commit=WORKFLOW,
                run_command=run_command,
            )
        return result, run_command


class ReleasePreflightTest(unittest.TestCase):
    def test_dirty_checkout_cannot_reuse_a_clean_commit_identity(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for args in (
                ("init", "-q"),
                ("config", "user.email", "agent@example.invalid"),
                ("config", "user.name", "fixture"),
                ("config", "commit.gpgsign", "false"),
            ):
                subprocess.run(["git", "-C", str(root), *args], check=True, capture_output=True)
            source = root / "source.txt"
            source.write_text("reviewed\n")
            subprocess.run(["git", "-C", str(root), "add", "source.txt"], check=True)
            subprocess.run(["git", "-C", str(root), "commit", "-qm", "fixture"], check=True)
            self.assertEqual(len(_git_head(root)), 40)
            source.write_text("unreviewed\n")
            with self.assertRaisesRegex(ValueError, "checkout is dirty"):
                _git_head(root)

    def test_preflight_records_only_pto_identity_and_local_pins(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            result, run_command = fixture.validate()
        self.assertEqual(set(result), {"schema", "scope", "commits", "identity", "dependencies"})
        self.assertEqual(result["schema"], "pto.release-preflight.v2")
        self.assertEqual(result["scope"], "pto-spec")
        self.assertEqual(result["commits"], {"pto": PTO, "workflow": WORKFLOW})
        self.assertEqual(result["identity"], IDENTITY)
        self.assertEqual(result["dependencies"], {"pto_ndf": "1" * 40, "aslref": "f" * 40})
        run_command.assert_called_once_with(
            [str(fixture.pto / "scripts/check-release-manifest")], check=True
        )

    def test_workflow_must_equal_pto_candidate(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            with self.assertRaisesRegex(ValueError, "workflow commit differs"):
                validate_preflight(
                    pto_root=fixture.pto, pto_commit=PTO,
                    workflow_commit="b" * 40, run_command=mock.Mock(),
                )

    def test_checkout_must_equal_pto_candidate(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            with mock.patch("scripts.release_preflight._git_head", return_value="b" * 40):
                with self.assertRaisesRegex(ValueError, "PTO checkout differs"):
                    validate_preflight(
                        pto_root=fixture.pto, pto_commit=PTO,
                        workflow_commit=WORKFLOW, run_command=mock.Mock(),
                    )

    def test_manifest_selection_blockers_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            fixture.manifest["release_selection"] = {"blockers": ["open issue"]}
            fixture.write_manifest()
            with self.assertRaisesRegex(ValueError, "manifest selection contains blockers"):
                approved_release_identity(fixture.pto)

    def test_cli_failure_diagnostic_gives_agent_next_action(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            diagnostics = root / "diagnostics.json"
            result = subprocess.run(
                [str(ROOT / "scripts/check-release-preflight"),
                 "--pto-root", str(root / "pto"),
                 "--pto-commit", PTO, "--workflow-commit", "b" * 40,
                 "--output", str(root / "candidate.json"),
                 "--diagnostics", str(diagnostics)],
                cwd=ROOT, text=True, capture_output=True, check=False,
            )
            report = json.loads(diagnostics.read_text())
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(report["ok"])
        self.assertIn("commit the fix", report["next_action"])


if __name__ == "__main__":
    unittest.main()
