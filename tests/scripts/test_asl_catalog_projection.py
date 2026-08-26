from __future__ import annotations

import json
import io
import tempfile
import unittest
from contextlib import redirect_stderr
from dataclasses import replace
from pathlib import Path

from scripts.asl_units import load_units
from scripts.project_asl_catalogs import CATALOG_PATHS, project_catalogs


REPO = Path(__file__).resolve().parents[2]


class AslCatalogProjectionTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.units = load_units(REPO / "asl")

    def test_projection_is_byte_identical_to_committed_catalogs(self) -> None:
        projected = project_catalogs(self.units)
        self.assertEqual(set(projected), set(CATALOG_PATHS))
        for path in CATALOG_PATHS:
            with self.subTest(path=path):
                self.assertEqual(projected[path], (REPO / path).read_bytes())

    def test_extension_reservations_are_owned_by_arch_asl(self) -> None:
        owners = [
            unit
            for unit in self.units
            if unit.metadata.get("catalog_projection", {}).get("catalog")
            == "extension-encoding-reservations"
        ]

        self.assertEqual(len(owners), 1)
        reservations = owners[0].metadata["catalog_projection"]["reservations"]
        self.assertEqual(
            {item["mnemonic"] for item in reservations},
            {
                "BSTART.VPAR",
                "BSTART.VSEQ",
                "C.BSTART.VPAR",
                "C.BSTART.VSEQ",
                "B.TEXT",
                "B.EQ",
                "B.NE",
                "B.LT",
                "B.GE",
                "B.LTU",
                "B.GEU",
                "B.Z",
                "B.NZ",
                "BSTART.FP.FIXUP",
                "BSTART.STD.FIXUP",
                "BSTART.SYS.FIXUP",
                "BSTART.MPAR",
                "BSTART.MSEQ",
                "C.BSTART.MPAR",
                "C.BSTART.MSEQ",
                "HL.BSTART.CALL",
                "HL.BSTART.FP.COND",
                "HL.BSTART.FP.FALL",
                "HL.BSTART.FP.CALL",
                "HL.BSTART.FP.DIRECT",
                "HL.BSTART.STD.CALL",
                "HL.BSTART.STD.FALL",
                "HL.BSTART.STD.COND",
                "HL.BSTART.STD.DIRECT",
                "HL.BSTART.SYS.FALL",
                "L.BSTART.FP.COND",
                "L.BSTART.FP.DIRECT",
                "L.BSTART.FP.CALL",
                "L.BSTART.FP.FALL",
                "L.BSTART.STD.DIRECT",
                "L.BSTART.STD.CALL",
                "L.BSTART.STD.COND",
                "L.BSTART.STD.FALL",
                "L.BSTART.SYS.FALL",
                "V.*",
                "BSTART.TEPL selector 0x065",
                "BSTART.TEPL selector 0x06E",
                "BSTART.TEPL selector 0x071",
                "BSTART.TEPL selector 0x072",
                "BSTART.TEPL selector 0x073",
                "BSTART.TEPL selector 0x074",
            },
        )
        vector_root = next(item for item in reservations if item["mnemonic"] == "V.*")
        self.assertEqual(vector_root["length_bits"], 64)
        self.assertEqual(vector_root["encoding"][0]["mask"], "0x0000007f")
        self.assertEqual(vector_root["encoding"][0]["match"], "0x0000007f")
        self.assertIn(
            Path("spec/catalog/extension-encoding-reservations.json"),
            CATALOG_PATHS,
        )

    def test_projection_is_deterministic_under_input_reordering(self) -> None:
        self.assertEqual(
            project_catalogs(self.units), project_catalogs(tuple(reversed(self.units)))
        )

    def test_tile_class_and_engine_are_derived_from_unit_metadata(self) -> None:
        tile_owner = next(unit for unit in self.units if unit.surface == "tile")
        source_record = tile_owner.metadata["catalog_records"][0]
        self.assertNotIn("classification", source_record)
        self.assertNotIn("engine", source_record)

        projected = json.loads(
            project_catalogs(self.units)[Path("spec/catalog/tile-operations.json")]
        )
        operation = projected["operations"][tile_owner.metadata["catalog_indices"][0]]
        self.assertEqual(operation["classification"], tile_owner.classification[0])
        self.assertEqual(operation["engine"], tile_owner.metadata["engine"])

    def test_duplicate_catalog_slot_is_rejected(self) -> None:
        owner = next(
            unit for unit in self.units if unit.metadata.get("catalog_indices")
        )
        duplicate = replace(
            owner,
            unit_id=f"{owner.unit_id}-DUPLICATE",
            source_path=Path("asl/scalar/alu/DUPLICATE.asl"),
        )
        with self.assertRaisesRegex(ValueError, "duplicate catalog slot"):
            project_catalogs((*self.units, duplicate))

    def test_missing_catalog_slot_is_rejected(self) -> None:
        owner = next(
            unit
            for unit in self.units
            if unit.surface == "scalar" and unit.metadata.get("catalog_indices") == [0]
        )
        with self.assertRaisesRegex(ValueError, "missing catalog slot"):
            project_catalogs(tuple(unit for unit in self.units if unit is not owner))

    def test_conflicting_record_ownership_is_rejected(self) -> None:
        owner = next(
            unit for unit in self.units if unit.metadata.get("catalog_indices")
        )
        metadata = dict(owner.metadata)
        records = [dict(record) for record in metadata["catalog_records"]]
        identity = "mnemonic" if "mnemonic" in records[0] else "name"
        records[0][identity] = "CONFLICT"
        metadata["catalog_records"] = records
        conflict = replace(
            owner,
            unit_id=f"{owner.unit_id}-CONFLICT",
            source_path=Path("asl/scalar/alu/CONFLICT.asl"),
            metadata=metadata,
        )
        with self.assertRaisesRegex(ValueError, "conflicting catalog record"):
            project_catalogs((*self.units, conflict))

    def test_cli_check_rejects_stale_projection(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            (root / "asl").mkdir()
            (root / "spec/catalog").mkdir(parents=True)
            for path in CATALOG_PATHS:
                target = root / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(json.dumps({"stale": True}), encoding="utf-8")
            # A missing ASL authority is itself fail-closed and must not accept stale files.
            from scripts.project_asl_catalogs import main

            errors = io.StringIO()
            with redirect_stderr(errors):
                self.assertNotEqual(main(["--root", str(root), "--check"]), 0)
            self.assertIn("missing catalog projection envelope", errors.getvalue())


if __name__ == "__main__":
    unittest.main()
