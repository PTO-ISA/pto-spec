from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import AslUnit, load_units, topological_order, validate_layout, validate_surface


def unit_source(
    *,
    unit_id: str = "PTO-ARCH-MEMORY-ORDERING",
    surface: str = "arch",
    classification: tuple[str, ...] = ("memory-model", "ordering"),
    depends_on: tuple[str, ...] = (),
    body: str = "constant ORDERING_TEST = 1;\n",
) -> str:
    metadata = json.dumps(
        {
            "id": unit_id,
            "surface": surface,
            "classification": list(classification),
            "depends_on": list(depends_on),
        },
        separators=(",", ":"),
    )
    return f"// PTO-UNIT: {metadata}\n{body}"


class AslUnitsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name) / "asl"
        for surface in ("arch", "block", "scalar", "tile"):
            (self.root / surface).mkdir(parents=True)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_unit(
        self,
        relative: str = "arch/memory-model/ordering.asl",
        **kwargs: object,
    ) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(unit_source(**kwargs), encoding="utf-8")
        return path

    def test_load_units_accepts_one_unit_per_matching_path(self) -> None:
        self.write_unit()

        unit = load_units(self.root)[0]

        self.assertEqual(unit.unit_id, "PTO-ARCH-MEMORY-ORDERING")
        self.assertEqual(unit.surface, "arch")
        self.assertEqual(unit.classification, ("memory-model", "ordering"))
        self.assertEqual(unit.source_path, Path("asl/arch/memory-model/ordering.asl"))

    def test_load_units_accepts_extended_instruction_metadata(self) -> None:
        path = self.root / "scalar/alu/ADD.asl"
        path.parent.mkdir(parents=True)
        metadata = {
            "id": "PTO-SCALAR-ALU-ADD",
            "surface": "scalar",
            "classification": ["alu"],
            "depends_on": ["PTO-ARCH-STATE-SCALAR-REGISTERS"],
            "mnemonic": "ADD",
        }
        path.write_text(
            f"// PTO-INSTRUCTION: {json.dumps(metadata, separators=(',', ':'))}\n"
            "func ADD()\nbegin\n    return;\nend;\n",
            encoding="utf-8",
        )

        unit = load_units(self.root)[0]

        self.assertEqual(unit.mnemonic, "ADD")
        self.assertEqual(unit.classification, ("alu",))

    def test_validate_layout_rejects_fifth_root(self) -> None:
        self.write_unit()
        (self.root / "numeric").mkdir()

        errors = validate_layout(self.root, load_units(self.root))

        self.assertIn("unexpected ASL root entry: numeric", errors)

    def test_validate_layout_rejects_root_file(self) -> None:
        self.write_unit()
        units = load_units(self.root)
        (self.root / "types.asl").write_text("constant X = 1;\n", encoding="utf-8")

        errors = validate_layout(self.root, units)

        self.assertIn("unexpected ASL root entry: types.asl", errors)

    def test_validate_layout_rejects_metadata_path_mismatch(self) -> None:
        self.write_unit(classification=("memory-model", "atomicity"))

        errors = validate_layout(self.root, load_units(self.root))

        self.assertIn(
            "asl/arch/memory-model/ordering.asl: classification does not match path: "
            "metadata memory-model/atomicity, path memory-model/ordering",
            errors,
        )

    def test_validate_layout_rejects_501_lines(self) -> None:
        body = "\n".join(f"constant LINE_{index} = {index};" for index in range(500)) + "\n"
        self.write_unit(body=body)

        errors = validate_layout(self.root, load_units(self.root))

        self.assertIn(
            "asl/arch/memory-model/ordering.asl: exceeds 500 physical lines: 501",
            errors,
        )

    def test_load_units_rejects_missing_metadata(self) -> None:
        path = self.root / "arch/state/missing.asl"
        path.parent.mkdir(parents=True)
        path.write_text("constant MISSING = 1;\n", encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "expected exactly one PTO metadata record, found 0"):
            load_units(self.root)

    def test_load_units_rejects_duplicate_metadata(self) -> None:
        path = self.write_unit()
        path.write_text(path.read_text(encoding="utf-8") + unit_source(), encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "expected exactly one PTO metadata record, found 2"):
            load_units(self.root)

    def test_validate_layout_rejects_duplicate_ids(self) -> None:
        self.write_unit()
        self.write_unit("arch/memory-model/atomicity.asl", classification=("memory-model", "atomicity"))

        errors = validate_layout(self.root, load_units(self.root))

        self.assertTrue(any(error.startswith("duplicate ASL unit ID PTO-ARCH-MEMORY-ORDERING") for error in errors))

    def test_validate_layout_rejects_missing_dependency(self) -> None:
        self.write_unit(depends_on=("PTO-ARCH-MISSING",))

        errors = validate_layout(self.root, load_units(self.root))

        self.assertIn(
            "asl/arch/memory-model/ordering.asl: unknown ASL dependency PTO-ARCH-MISSING",
            errors,
        )

    def test_topological_order_is_deterministic_and_includes_synthetic_node(self) -> None:
        units = (
            AslUnit(
                unit_id="PTO-SCALAR-ADD",
                surface="scalar",
                classification=("alu",),
                depends_on=("generated:decoders",),
                source_path=Path("asl/scalar/alu/ADD.asl"),
                mnemonic="ADD",
                line_count=10,
            ),
            AslUnit(
                unit_id="PTO-ARCH-BASE",
                surface="arch",
                classification=("overview", "architecture"),
                depends_on=(),
                source_path=Path("asl/arch/overview/architecture.asl"),
                mnemonic=None,
                line_count=10,
            ),
        )

        order = topological_order(units)

        self.assertEqual(order, ("PTO-ARCH-BASE", "generated:decoders", "PTO-SCALAR-ADD"))

    def test_topological_order_rejects_cycle(self) -> None:
        first = AslUnit(
            "PTO-ARCH-FIRST",
            "arch",
            ("state", "first"),
            ("PTO-ARCH-SECOND",),
            Path("asl/arch/state/first.asl"),
            None,
            2,
        )
        second = AslUnit(
            "PTO-ARCH-SECOND",
            "arch",
            ("state", "second"),
            ("PTO-ARCH-FIRST",),
            Path("asl/arch/state/second.asl"),
            None,
            2,
        )

        with self.assertRaisesRegex(ValueError, "ASL dependency cycle"):
            topological_order((first, second), synthetic_nodes=())

    def test_validate_surface_rejects_obsolete_sibling_roots(self) -> None:
        self.write_unit()
        (self.root / "bundle").mkdir()
        (self.root / "types.asl").write_text("constant OLD = 1;\n", encoding="utf-8")

        units = load_units(self.root / "arch", source_prefix=Path("asl/arch"))

        errors = validate_surface(self.root, "arch", units)
        self.assertIn("unexpected ASL root entry: bundle", errors)
        self.assertIn("unexpected ASL root entry: types.asl", errors)

    def test_direct_checker_entrypoint_loads_repository_modules(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/check-asl-layout", "--help"],
            cwd=Path(__file__).resolve().parents[2],
            text=True,
            capture_output=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
