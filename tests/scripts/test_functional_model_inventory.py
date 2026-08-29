from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "tests/fixtures/functional-model-inventory"
GENERATOR = ROOT / "scripts/generate-functional-model-inventory"


class FunctionalModelInventoryTest(unittest.TestCase):
    def run_generator(
        self, typed_ast: Path, output: Path, *extra: str
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                str(GENERATOR),
                "--typed-ast",
                str(typed_ast),
                "--ast-mli",
                str(FIXTURES / "AST.mli"),
                "--output",
                str(output),
                *extra,
            ],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_inventory_is_deterministic_and_sorted(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.json"
            second = Path(directory) / "second.json"
            one = self.run_generator(FIXTURES / "valid.serialized", first)
            two = self.run_generator(FIXTURES / "valid.serialized", second)
            self.assertEqual(one.returncode, 0, one.stderr)
            self.assertEqual(two.returncode, 0, two.stderr)
            self.assertEqual(first.read_bytes(), second.read_bytes())

            document = json.loads(first.read_text(encoding="utf-8"))
            self.assertEqual(document["schema"], "pto.functional-model-asl-constructs.v1")
            self.assertEqual(document["declaration_count"], 2)
            self.assertEqual(
                document["declaration_counts"], {"D_Func": 1, "D_GlobalStorage": 1}
            )
            names = [row["constructor"] for row in document["constructor_inventory"]]
            self.assertEqual(names, sorted(names))
            self.assertEqual(document["unsupported"], [])

    def test_unknown_constructor_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "inventory.json"
            result = self.run_generator(
                FIXTURES / "unknown-constructor.serialized", output
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("absent from pinned AST.mli: S_Future", result.stderr)
            self.assertFalse(output.exists())

    def test_check_rejects_stale_output(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "inventory.json"
            output.write_text("{}\n", encoding="utf-8")
            result = self.run_generator(
                FIXTURES / "valid.serialized", output, "--check"
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("stale generated artifact", result.stderr)


if __name__ == "__main__":
    unittest.main()
