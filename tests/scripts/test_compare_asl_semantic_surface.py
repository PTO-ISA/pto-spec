from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import compare_ref_to_tree


class CompareAslSemanticSurfaceTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        subprocess.run(["git", "init", "-q"], cwd=self.root, check=True)
        subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=self.root, check=True)
        subprocess.run(["git", "config", "user.name", "Test"], cwd=self.root, check=True)
        old = self.root / "asl/architecture.asl"
        old.parent.mkdir(parents=True)
        old.write_text(
            "constant PTO_XLEN = 64;\n"
            "pure func AddOne(value: integer) => integer\n"
            "begin\n"
            "    return value + 1;\n"
            "end;\n"
            "impdef func ProfileHook(value: integer) => integer\n"
            "begin\n"
            "    return value;\n"
            "end;\n"
            "implementation func ProfileHook(value: integer) => integer\n"
            "begin\n"
            "    return value + 4;\n"
            "end;\n",
            encoding="utf-8",
        )
        subprocess.run(["git", "add", "asl"], cwd=self.root, check=True)
        subprocess.run(["git", "commit", "-qm", "baseline"], cwd=self.root, check=True)
        self.baseline = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=self.root, text=True).strip()
        old.unlink()
        new = self.root / "asl/arch/overview/architecture.asl"
        new.parent.mkdir(parents=True)
        metadata = json.dumps(
            {
                "id": "PTO-ARCH-OVERVIEW-ARCHITECTURE",
                "surface": "arch",
                "classification": ["overview", "architecture"],
                "depends_on": [],
            },
            separators=(",", ":"),
        )
        new.write_text(
            f"// PTO-UNIT: {metadata}\n"
            "constant PTO_XLEN = 64;\n"
            "pure func AddOne(value: integer) => integer\n"
            "begin\n"
            "    return value + 1;\n"
            "end;\n"
            "impdef func ProfileHook(value: integer) => integer\n"
            "begin\n"
            "    return value;\n"
            "end;\n"
            "implementation func ProfileHook(value: integer) => integer\n"
            "begin\n"
            "    return value + 4;\n"
            "end;\n",
            encoding="utf-8",
        )
        self.new = new

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def compare(self) -> list[str]:
        return compare_ref_to_tree(self.root, self.baseline, self.root / "asl", ("arch",))

    def test_pure_move_and_metadata_addition_preserve_symbols(self) -> None:
        self.assertEqual(self.compare(), [])

    def test_changed_expression_is_rejected(self) -> None:
        self.new.write_text(
            self.new.read_text(encoding="utf-8").replace("value + 1", "value + 2"),
            encoding="utf-8",
        )

        self.assertIn("changed ASL symbol body: AddOne", self.compare())

    def test_removed_declaration_is_rejected(self) -> None:
        self.new.write_text(
            "\n".join(
                line for line in self.new.read_text(encoding="utf-8").splitlines() if "PTO_XLEN" not in line
            )
            + "\n",
            encoding="utf-8",
        )

        self.assertIn("missing ASL symbol: PTO_XLEN", self.compare())

    def test_duplicate_symbol_is_rejected(self) -> None:
        duplicate = self.root / "asl/arch/state/duplicate.asl"
        duplicate.parent.mkdir(parents=True)
        duplicate.write_text("constant PTO_XLEN = 64;\n", encoding="utf-8")

        self.assertTrue(any(error.startswith("duplicate current ASL symbol PTO_XLEN") for error in self.compare()))

    def test_signature_change_is_rejected(self) -> None:
        self.new.write_text(
            self.new.read_text(encoding="utf-8").replace(
                "AddOne(value: integer) => integer", "AddOne(value: bits(64)) => integer"
            ),
            encoding="utf-8",
        )

        self.assertIn("changed ASL symbol signature: AddOne", self.compare())

    def test_changed_implementation_body_is_rejected_separately_from_impdef(self) -> None:
        self.new.write_text(
            self.new.read_text(encoding="utf-8").replace("return value + 4", "return value + 8"),
            encoding="utf-8",
        )

        self.assertIn("changed ASL symbol body: ProfileHook [implementation]", self.compare())


if __name__ == "__main__":
    unittest.main()
