from __future__ import annotations

import hashlib
import json
from pathlib import Path
import runpy
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
PREPARE = runpy.run_path(str(ROOT / "scripts/prepare-pr"))


class PreparePrTest(unittest.TestCase):
    def git(self, root: Path, *arguments: str) -> str:
        result = subprocess.run(
            ["git", *arguments], cwd=root, text=True, capture_output=True, check=True
        )
        return result.stdout.strip()

    def repository(self) -> tuple[tempfile.TemporaryDirectory[str], Path, str]:
        temporary = tempfile.TemporaryDirectory()
        root = Path(temporary.name)
        self.git(root, "init")
        self.git(root, "config", "user.email", "agent@example.invalid")
        self.git(root, "config", "user.name", "author-agent")
        (root / "README.md").write_text("base\n", encoding="utf-8")
        self.git(root, "add", ".")
        self.git(root, "commit", "-m", "base")
        base = self.git(root, "rev-parse", "HEAD")
        return temporary, root, base

    def test_report_has_exact_identity_classification_commands_and_next_action(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            script = root / "scripts/example"
            script.parent.mkdir()
            script.write_text("#!/bin/sh\n", encoding="utf-8")
            test_script = root / "tests/scripts/test_example.py"
            test_script.parent.mkdir(parents=True)
            test_script.write_text("import unittest\n", encoding="utf-8")
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "tooling")

            report = PREPARE["prepare"](root, base, "HEAD", False, None)

            self.assertEqual(report["schema_version"], "1")
            self.assertEqual(report["identity"]["base_tip"], base)
            self.assertEqual(report["identity"]["merge_base"], base)
            self.assertEqual(report["identity"]["head"], self.git(root, "rev-parse", "HEAD"))
            self.assertEqual(report["identity"]["head_tree"], self.git(root, "rev-parse", "HEAD^{tree}"))
            self.assertRegex(report["identity"]["diff_sha256"], r"^[0-9a-f]{64}$")
            self.assertEqual(report["changes"]["classifications"], ["tooling", "tests"])
            self.assertIn("python3 -m unittest", "\n".join(report["commands"]))
            self.assertEqual(report["review"]["status"], "review-required")
            self.assertEqual(report["merge_readiness"]["ready"], False)
            self.assertTrue(report["next_action"])
            self.assertFalse(report["release"]["required"])

    def test_dirty_worktree_is_rejected_unless_inspection_is_requested(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            (root / "README.md").write_text("dirty\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "working tree is dirty"):
                PREPARE["prepare"](root, base, "HEAD", False, None)

            report = PREPARE["prepare"](root, base, "HEAD", True, None)
            self.assertTrue(report["working_tree"]["dirty"])
            self.assertFalse(report["review_handoff"]["eligible"])
            self.assertEqual(report["review"]["status"], "blocked")
            self.assertIn("docs", report["changes"]["classifications"])

    def test_normative_change_requires_release_advice_and_compatibility_review(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            source = root / "asl/example.asl"
            source.parent.mkdir()
            source.write_text("// normative fixture\n", encoding="utf-8")
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "normative")

            report = PREPARE["prepare"](root, base, "HEAD", False, None)

            self.assertIn("normative", report["changes"]["classifications"])
            self.assertTrue(report["release"]["required"])
            self.assertEqual(report["compatibility"]["classification"], "unspecified")

    def test_json_cli_failure_is_machine_readable_and_nonzero(self) -> None:
        temporary, root, _ = self.repository()
        with temporary:
            target = root / "scripts/prepare-pr"
            target.parent.mkdir()
            shutil.copy2(ROOT / "scripts/prepare-pr", target)
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "tool")

            result = subprocess.run(
                [str(target), "--base", "missing-ref", "--json"],
                cwd=root,
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertNotEqual(result.returncode, 0)
            payload = json.loads(result.stdout)
            self.assertEqual(payload["status"], "blocked")
            self.assertTrue(payload["errors"])
            self.assertTrue(payload["next_action"])

    def test_release_validation_and_site_changes_get_bounded_commands(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            workflow = root / ".github/workflows/release.yml"
            workflow.parent.mkdir(parents=True)
            workflow.write_text("name: release\n", encoding="utf-8")
            site = root / "docs/site/src/example.ts"
            site.parent.mkdir(parents=True)
            site.write_text("export {};\n", encoding="utf-8")
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "release validation")

            report = PREPARE["prepare"](root, base, "HEAD", False, None)
            commands = "\n".join(report["commands"])

            self.assertTrue(report["release"]["required"])
            self.assertEqual(report["release"]["influence"], "validation")
            self.assertIn("tests.scripts.test_release_workflow", commands)
            self.assertIn("pnpm --dir docs/site typecheck", commands)
            self.assertIn("pnpm --dir docs/site test:unit", commands)
            self.assertIn("pnpm --dir docs/site build", commands)
            self.assertEqual(report["compatibility"]["classification"], "unspecified")

    def test_asl_change_reports_direct_test_ids_without_full_matrix(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            source = root / "asl/tile/EXAMPLE.asl"
            source.parent.mkdir(parents=True)
            source.write_text("// source\n", encoding="utf-8")
            test = root / "tests/asl/tile/example.asl"
            test.parent.mkdir(parents=True)
            test.write_text(
                '// PTO-TEST: {"id":"PTO-AVS-TILE-EXAMPLE-001","source":"asl/tile/EXAMPLE.asl"}\n',
                encoding="utf-8",
            )
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "ASL")

            report = PREPARE["prepare"](root, base, "HEAD", False, None)

            self.assertEqual(report["asl_validation"]["suggested_test_ids"], ["PTO-AVS-TILE-EXAMPLE-001"])
            self.assertNotIn("full matrix", "\n".join(report["commands"]).lower())

    def test_deleted_test_module_is_not_suggested(self) -> None:
        temporary, root, _ = self.repository()
        with temporary:
            test = root / "tests/scripts/test_removed.py"
            test.parent.mkdir(parents=True)
            test.write_text("import unittest\n", encoding="utf-8")
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "add test")
            base = self.git(root, "rev-parse", "HEAD")
            test.unlink()
            self.git(root, "add", "-A")
            self.git(root, "commit", "-m", "remove test")

            report = PREPARE["prepare"](root, base, "HEAD", False, None)

            self.assertNotIn("tests.scripts.test_removed", "\n".join(report["commands"]))

    def test_stale_or_unapproved_review_is_rejected(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            (root / "README.md").write_text("head\n", encoding="utf-8")
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "docs")
            report = PREPARE["prepare"](root, base, "HEAD", False, None)
            identity = report["identity"]
            review_path = Path(temporary.name).parent / f"{root.name}-review.json"

            review = {
                "schema_version": "1",
                "author": {"id": "author-agent", "role": "change_author"},
                "reviewer": {"id": "review-agent", "role": "independent_reviewer"},
                "identity": identity,
                "verdict": "approved",
                "findings": [],
                "compatibility": {"classification": "compatible", "reason": "documentation only"},
            }
            review_path.write_text(json.dumps(review), encoding="utf-8")
            accepted = PREPARE["prepare"](root, base, "HEAD", False, review_path)
            self.assertEqual(accepted["review"]["status"], "reviewed")
            self.assertFalse(accepted["merge_readiness"]["ready"])

            review["findings"] = ["unresolved defect"]
            review_path.write_text(json.dumps(review), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "approved review must have no findings"):
                PREPARE["prepare"](root, base, "HEAD", False, review_path)
            review["findings"] = []

            review["identity"] = {**identity, "diff_sha256": hashlib.sha256(b"stale").hexdigest()}
            review_path.write_text(json.dumps(review), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "review identity does not match"):
                PREPARE["prepare"](root, base, "HEAD", False, review_path)

            review["identity"] = {**identity, "base_tip": hashlib.sha256(b"advanced").hexdigest()[:40]}
            review_path.write_text(json.dumps(review), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "review identity does not match"):
                PREPARE["prepare"](root, base, "HEAD", False, review_path)

            review["identity"] = identity
            review["verdict"] = "changes_requested"
            review_path.write_text(json.dumps(review), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "review verdict is not approved"):
                PREPARE["prepare"](root, base, "HEAD", False, review_path)
            review_path.unlink()

    def test_review_rejects_placeholder_operational_ids(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            report = PREPARE["prepare"](root, base, "HEAD", False, None)
            review_path = Path(temporary.name).parent / f"{root.name}-placeholder-review.json"
            review_path.write_text(
                json.dumps(
                    {
                        "schema_version": "1",
                        "author": {"id": "<change-agent-operational-id>", "role": "change_author"},
                        "reviewer": {"id": "review-agent", "role": "independent_reviewer"},
                        "identity": report["identity"],
                        "verdict": "approved",
                        "findings": [],
                        "compatibility": {"classification": "compatible", "reason": "docs"},
                    }
                ),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "placeholder"):
                PREPARE["prepare"](root, base, "HEAD", False, review_path)
            review_path.unlink()

    def test_review_requires_distinct_operational_agent_ids(self) -> None:
        temporary, root, base = self.repository()
        with temporary:
            report = PREPARE["prepare"](root, base, "HEAD", False, None)
            review_path = Path(temporary.name).parent / f"{root.name}-review.json"
            review_path.write_text(
                json.dumps(
                    {
                        "schema_version": "1",
                        "author": {"id": "same-agent", "role": "change_author"},
                        "reviewer": {"id": "same-agent", "role": "independent_reviewer"},
                        "identity": report["identity"],
                        "verdict": "approved",
                        "findings": [],
                        "compatibility": {"classification": "compatible", "reason": "no normative change"},
                    }
                ),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "must be distinct"):
                PREPARE["prepare"](root, base, "HEAD", False, review_path)
            review_path.unlink()


if __name__ == "__main__":
    unittest.main()
