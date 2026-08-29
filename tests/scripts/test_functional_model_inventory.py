from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "tests/fixtures/functional-model-inventory"
GENERATOR = ROOT / "scripts/generate-functional-model-inventory"
SCHEMA = ROOT / "spec/schemas/pto-mir-v1.schema.json"


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
                "--mir-output",
                str(output.with_name("mir.json")),
                "--readiness-output",
                str(output.with_name("readiness.json")),
                "--schema",
                str(SCHEMA),
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
            self.assertEqual(document["declaration_count"], 5)
            self.assertEqual(
                document["declaration_counts"], {"D_Func": 1, "D_GlobalStorage": 4}
            )
            names = [row["constructor"] for row in document["constructor_inventory"]]
            self.assertEqual(names, sorted(names))
            self.assertEqual(document["unsupported"], [])

            mir = json.loads(first.with_name("mir.json").read_text(encoding="utf-8"))
            self.assertEqual(mir["schema"], "pto-mir-v1")
            self.assertEqual(mir["schema_version"], 1)
            self.assertGreater(len(mir["nodes"]), document["constructor_count"])
            atom_kinds = {
                node["atom_kind"] for node in mir["nodes"] if node["kind"] == "atom"
            }
            self.assertTrue(
                {"bitvector", "boolean", "integer", "rational", "string"}.issubset(
                    atom_kinds
                )
            )

            readiness = json.loads(
                first.with_name("readiness.json").read_text(encoding="utf-8")
            )
            self.assertEqual(readiness["statistics"]["declaration_count"], 5)
            self.assertEqual(readiness["statistics"]["unsupported"], [])

    def test_unknown_constructor_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "inventory.json"
            result = self.run_generator(
                FIXTURES / "unknown-constructor.serialized", output
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("S_Future", result.stderr)
            self.assertIn("absent from pinned AST.mli", result.stderr)
            self.assertFalse(output.exists())

    def assert_rejected(self, fixture: str, diagnostic: str) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "inventory.json"
            result = self.run_generator(FIXTURES / fixture, output)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(diagnostic, result.stderr)
            self.assertFalse(output.exists())
            self.assertFalse(output.with_name("mir.json").exists())

    def test_unknown_primitive_is_rejected(self) -> None:
        self.assert_rejected(
            "unknown-primitive.serialized", "unsupported primitive binding"
        )

    def test_uncovered_impdef_is_rejected(self) -> None:
        self.assert_rejected(
            "uncovered-impdef.serialized", "uncovered impdef binding"
        )

    def test_unknown_external_helper_is_rejected(self) -> None:
        self.assert_rejected(
            "unknown-helper.serialized", "unsupported external helper"
        )

    def test_malformed_serialization_is_rejected(self) -> None:
        self.assert_rejected("malformed.serialized", "expected ']'")

    def test_trailing_syntax_is_rejected(self) -> None:
        self.assert_rejected("trailing.serialized", "trailing syntax")

    def test_schema_mismatch_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
            schema["x-pto-schema-version"] = 2
            mismatch = root / "mismatch.schema.json"
            mismatch.write_text(json.dumps(schema), encoding="utf-8")
            output = root / "inventory.json"
            result = self.run_generator(
                FIXTURES / "valid.serialized",
                output,
                "--schema",
                str(mismatch),
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("schema version mismatch", result.stderr)
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
