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

    def test_tracked_markdown_outside_owned_roots_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)

            result = self.run_checker(root, ["docs/loose.md"])

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("outside the ASL mirror", result.stderr)


if __name__ == "__main__":
    unittest.main()
