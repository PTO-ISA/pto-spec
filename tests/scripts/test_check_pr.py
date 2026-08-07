from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/check-pr"
WORKFLOW = ROOT / ".github/workflows/asl.yml"


class PullRequestCheckTest(unittest.TestCase):
    def test_publication_hygiene_accepts_the_approved_ndf_reference(self) -> None:
        result = subprocess.run(
            ["python3", "scripts/check-publication-hygiene"],
            cwd=ROOT,
            text=True,
            capture_output=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_command_contract_is_lightweight(self) -> None:
        result = subprocess.run(
            [str(SCRIPT), "--list"],
            cwd=ROOT,
            check=True,
            text=True,
            capture_output=True,
        )

        commands = result.stdout.splitlines()
        self.assertEqual(
            commands,
            [
                "./scripts/check-ndf",
                "./scripts/check-release-workflow",
                "./scripts/check-repository --structure-only",
                "./scripts/check-asl-test-shards",
                "python3 -m unittest discover -s tests/scripts -p test_*.py",
                "python3 scripts/instruction_docs.py --check",
                "python3 scripts/check-publication-hygiene",
                "git diff --check",
            ],
        )
        lowered = "\n".join(commands).lower()
        for forbidden in (
            "opam",
            "setup-aslref",
            "scripts/aslref",
            "toolchain-check",
            "release-verify",
            "test-shard-",
        ):
            self.assertNotIn(forbidden, lowered)

    def test_pull_request_workflow_has_one_lightweight_job(self) -> None:
        workflow = WORKFLOW.read_text(encoding="utf-8")

        self.assertIn("name: PR", workflow)
        self.assertIn("name: PR / validate", workflow)
        self.assertIn("run: make pr-check", workflow)
        self.assertEqual(workflow.count("runs-on:"), 1)
        for forbidden in (
            "setup-ocaml",
            "opam",
            "asl-shard",
            "strict-model",
            "test-shard-",
        ):
            self.assertNotIn(forbidden, workflow)


if __name__ == "__main__":
    unittest.main()
