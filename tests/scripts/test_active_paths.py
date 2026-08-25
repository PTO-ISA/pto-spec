from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-active-paths"


class ActivePathCheckTest(unittest.TestCase):
    def run_checker(self, root: Path, tracked: list[str]) -> subprocess.CompletedProcess[str]:
        tracked_list = root / "tracked.txt"
        tracked_list.write_text("\n".join(tracked) + "\n", encoding="utf-8")
        return subprocess.run(
            [str(CHECKER), "--root", str(root), "--tracked-list", str(tracked_list)],
            text=True,
            capture_output=True,
            check=False,
        )

    def test_checker_exists(self) -> None:
        self.assertTrue(CHECKER.is_file())

    def test_dangling_obsolete_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "asl").mkdir()
            (root / "asl/bundle").symlink_to(root / "absent", target_is_directory=True)

            result = self.run_checker(root, [])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("obsolete active path", result.stderr)

    def test_markdown_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs/arch").mkdir(parents=True)
            (root / "docs/arch/page.md").symlink_to(root / "absent.md")

            result = self.run_checker(root, ["docs/arch/page.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Markdown symlink", result.stderr)

    def test_tracked_obsolete_descendant_is_rejected_without_worktree_entry(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)

            result = self.run_checker(root, ["tests/asl/shards/hidden.asl"])

            self.assertNotEqual(result.returncode, 0)
        self.assertIn("obsolete tracked path", result.stderr)

    def test_legacy_documentation_tree_is_obsolete(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "docs/status/legacy/page.md"
            path.parent.mkdir(parents=True)
            path.write_text("# Historical page\n", encoding="utf-8")

            result = self.run_checker(root, ["docs/status/legacy/page.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("obsolete", result.stderr)

    def test_tracked_markdown_outside_owned_roots_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)

            result = self.run_checker(root, ["docs/loose.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("outside the ASL mirror", result.stderr)

    def test_professional_documentation_roots_are_owned(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            paths = [
                "docs/governance/adr-process.md",
                "docs/development/getting-started.md",
                "docs/releases/index.md",
                "docs/site/README.md",
            ]
            for value in paths:
                path = root / value
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("# Owned\n", encoding="utf-8")

            result = self.run_checker(root, paths)

            self.assertEqual(result.returncode, 0, result.stderr)

    def test_untracked_generated_site_markdown_is_ignored(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "docs/site/node_modules/package/README.md"
            path.parent.mkdir(parents=True)
            path.write_text("# Dependency\n", encoding="utf-8")

            result = self.run_checker(root, [])

            self.assertEqual(result.returncode, 0, result.stderr)

    def test_tracked_generated_site_path_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "docs/site/build/index.md"
            path.parent.mkdir(parents=True)
            path.write_text("# Generated\n", encoding="utf-8")

            result = self.run_checker(root, ["docs/site/build/index.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("generated site path must not be tracked", result.stderr)

    def test_unrecognized_documentation_root_remains_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "docs/notes/page.md"
            path.parent.mkdir(parents=True)
            path.write_text("# Unowned\n", encoding="utf-8")

            result = self.run_checker(root, ["docs/notes/page.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("outside the ASL mirror", result.stderr)

    def test_agent_entrypoint_rejects_superseded_normative_routes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / ".codex/skills/pto-asl").mkdir(parents=True)
            (root / "AGENTS.md").write_text(
                "Start from docs/status/legacy/root/coverage.md.\n",
                encoding="utf-8",
            )
            (root / ".codex/skills/pto-asl/SKILL.md").write_text(
                "Run scripts/check-catalogs and list tests in ASL_TESTS.\n",
                encoding="utf-8",
            )

            result = self.run_checker(
                root,
                ["AGENTS.md", ".codex/skills/pto-asl/SKILL.md"],
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("agent entrypoint routes to superseded contract", result.stderr)

    def test_agent_entrypoint_does_not_treat_non_normative_as_safe_routing(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "AGENTS.md").write_text(
                "Although non-normative, read docs/status/legacy/root/coverage.md.\n",
                encoding="utf-8",
            )

            result = self.run_checker(root, ["AGENTS.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("agent entrypoint routes to superseded contract", result.stderr)

    def test_agent_entrypoint_does_not_accept_excluded_substring_bypass(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "AGENTS.md").write_text(
                "Not excluded; read docs/status/legacy/root/coverage.md.\n",
                encoding="utf-8",
            )

            result = self.run_checker(root, ["AGENTS.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("agent entrypoint routes to superseded contract", result.stderr)

    def test_agent_openai_yaml_rejects_superseded_route(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / ".codex/skills/pto-asl/agents/openai.yaml"
            path.parent.mkdir(parents=True)
            path.write_text(
                'interface:\n  default_prompt: "Read docs/status/legacy/root.md"\n',
                encoding="utf-8",
            )

            result = self.run_checker(
                root,
                [".codex/skills/pto-asl/agents/openai.yaml"],
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("agent entrypoint routes to superseded contract", result.stderr)

    def test_agent_entrypoint_rejects_deleted_requirement_route(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "AGENTS.md").write_text(
                "Start from spec/requirements.json.\n",
                encoding="utf-8",
            )

            result = self.run_checker(root, ["AGENTS.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("agent entrypoint routes to superseded contract", result.stderr)


if __name__ == "__main__":
    unittest.main()
