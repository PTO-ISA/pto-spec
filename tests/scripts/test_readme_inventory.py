from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts/generate-readme-inventory"
BEGIN = "<!-- PTO-INVENTORY-BEGIN -->"
END = "<!-- PTO-INVENTORY-END -->"


class ReadmeInventoryTest(unittest.TestCase):
    def run_generator(self, path: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(SCRIPT), "--readme", str(path), *arguments],
            cwd=ROOT, text=True, capture_output=True, check=False,
        )

    def test_generated_inventory_uses_live_catalogs_and_preserves_surrounding_text(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "README.md"
            path.write_text(f"before\n{BEGIN}\nstale\n{END}\nafter\n")
            result = self.run_generator(path)
            self.assertEqual(result.returncode, 0, result.stderr)
            text = path.read_text()
            self.assertTrue(text.startswith(f"before\n{BEGIN}\n"))
            self.assertTrue(text.endswith(f"{END}\nafter\n"))
            for filename, key, label in (
                ("scalar-forms.json", "forms", "Scalar instruction forms"),
                ("command-forms.json", "forms", "Active bundle and command forms"),
                ("tile-operations.json", "operations", "Direct Tile operations"),
            ):
                rows = json.loads((ROOT / "spec/catalog" / filename).read_text())[key]
                self.assertIn(f"| {label} | {len(rows):,} |", text)
            self.assertIn("development inventory", text)
            self.assertEqual(self.run_generator(path, "--check").returncode, 0)

    def test_stale_inventory_fails_without_rewriting_readme(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "README.md"
            original = f"{BEGIN}\nwrong\n{END}\n"
            path.write_text(original)
            result = self.run_generator(path, "--check")
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("generate-readme-inventory", result.stderr)
            self.assertEqual(path.read_text(), original)

    def test_ambiguous_or_missing_markers_are_rejected_without_edit(self):
        for text in ("no region", f"{BEGIN}\n{BEGIN}\n{END}", f"{END}\n{BEGIN}"):
            with self.subTest(text=text), tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / "README.md"
                path.write_text(text)
                result = self.run_generator(path)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(path.read_text(), text)


if __name__ == "__main__":
    unittest.main()
