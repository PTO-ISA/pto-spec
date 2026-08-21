#!/usr/bin/env python3
"""Regression checks for the PTO/Linx v0.58 Tile engine contract."""

from __future__ import annotations

import json
import importlib.machinery
import importlib.util
import subprocess
import unittest
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class TileEngineContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.tile = json.loads(
            (ROOT / "spec/catalog/tile-operations.json").read_text(encoding="utf-8")
        )
        cls.commands = json.loads(
            (ROOT / "spec/catalog/command-forms.json").read_text(encoding="utf-8")
        )

    def test_exact_execution_engine_partition(self) -> None:
        operations = self.tile["operations"]
        self.assertEqual(
            Counter(operation["engine"] for operation in operations),
            Counter({"VEC": 35, "SFU": 52, "TLSU": 10, "CUBE": 12}),
        )
        self.assertTrue(
            all(
                operation["engine"] in {"VEC", "SFU"}
                for operation in operations
                if operation["family"] == "TEPL"
            )
        )
        self.assertTrue(
            all(
                operation["engine"] == operation["family"]
                for operation in operations
                if operation["family"] in {"TLSU", "CUBE"}
            )
        )

    def test_vec_is_elementwise_only(self) -> None:
        vec = {
            operation["name"]: operation["classification"]
            for operation in self.tile["operations"]
            if operation["engine"] == "VEC"
        }
        self.assertEqual(len(vec), 35)
        self.assertTrue(
            set(vec.values())
            <= {"elementwise-tile-tile", "tile-scalar-and-immediate"}
        )

    def test_histogram_replaces_random_without_changing_other_tepl_encodings(self) -> None:
        operations = {row["name"]: row for row in self.tile["operations"]}
        self.assertEqual(operations["THISTOGRAM"]["selector"], "0x068")
        self.assertNotIn("TRANDOM", operations)
        self.assertIn("TRANDOM", self.tile["deleted_names"])
        self.assertIn(
            ["0x069", "0x069"], self.tile["reserved"]["tepl_selector_ranges"]
        )
        self.assertFalse((ROOT / "docs/instructions/tile/TRANDOM.md").exists())
        self.assertFalse((ROOT / "docs/instructions/tile/TSORT32.md").exists())
        self.assertTrue(
            (ROOT / "docs/status/legacy/instructions/tile/TRANDOM.md").is_file()
        )
        self.assertTrue(
            (ROOT / "docs/status/legacy/instructions/tile/TSORT32.md").is_file()
        )

    def test_mgather_cas_uses_public_function_eight(self) -> None:
        operation = next(
            row for row in self.tile["operations"] if row["name"] == "MGATHER_CAS"
        )
        command = next(
            row
            for row in self.commands["forms"]
            if row["mnemonic"] == "BSTART.MGATHER.CAS"
        )
        self.assertEqual(operation["function"], 8)
        self.assertEqual(
            command["encoding"],
            [
                {
                    "index": 0,
                    "mask": "0x07ffffff",
                    "match": "0x00811181",
                    "width_bits": 32,
                }
            ],
        )
        self.assertEqual(command["form_id"], "bstart_mgather_cas_32_fd8c8a3b720a")

    def test_linx_only_tlsu_functions_are_reserved(self) -> None:
        self.assertEqual(
            self.tile["reserved"]["tlsu_functions"], [[9, 12], [14, 31]]
        )
        self.assertFalse(
            any("encoding_variants" in form for form in self.commands["forms"]),
            "Linx-only TLSU forms must not become accepted PTO command variants",
        )

    def test_shared_io_and_tepl_aliases_match_linx_v058_common_subset(self) -> None:
        forms = {form["form_id"]: form for form in self.commands["forms"]}
        mnemonics = {form["mnemonic"] for form in forms.values()}
        self.assertNotIn("C.B.IOS", mnemonics)
        shared = forms["b_ios_32_4ba5ef98fdaa"]
        self.assertEqual(shared["mnemonic"], "B.IOS")
        self.assertEqual(
            shared["encoding"],
            [
                {
                    "index": 0,
                    "mask": "0xf00871ff",
                    "match": "0x00001013",
                    "width_bits": 32,
                }
            ],
        )
        scalar = forms["b_ior_32_c3ea71404eb3"]
        self.assertEqual(len(scalar["constraints"]), 4)
        self.assertTrue(
            all(constraint["values"] == list(range(24)) for constraint in scalar["constraints"])
        )
        destination = forms["b_iot_32_efa0fe3fe49a"]
        tsize = next(
            constraint
            for constraint in destination["constraints"]
            if constraint["field"] == "TSize"
        )
        self.assertEqual(tsize["values"], list(range(1, 8)))
        tepl = forms["bstart_tepl_32_d022db6dacb3"]
        self.assertEqual(
            tepl["accepted_assembly_mnemonics"],
            ["BSTART.TEPL", "BSTART.VEC", "BSTART.SFU"],
        )
        self.assertEqual(
            tepl["canonical_assembly_by_engine"],
            {"SFU": "BSTART.SFU", "VEC": "BSTART.VEC"},
        )

    def test_generated_asl_exposes_engine_without_renaming_tepl_carrier(self) -> None:
        generated = subprocess.run(
            [str(ROOT / "scripts/generate-asl-decoders")],
            cwd=ROOT,
            check=True,
            capture_output=True,
            text=True,
        ).stdout
        self.assertIn("TileDecode_TEPL", generated)
        self.assertIn("TileEngine_VEC", generated)
        self.assertIn("TileEngine_SFU", generated)
        self.assertIn("TileEngine_TLSU", generated)
        self.assertIn("TileEngine_CUBE", generated)
        self.assertIn("pure func TileEngineOfOperation(", generated)

    def test_tsize_is_per_pe_and_legacy_shared_tmov_is_absent(self) -> None:
        state = (ROOT / "asl/tile/state.asl").read_text(encoding="utf-8")
        memory = (ROOT / "asl/tile/memory.asl").read_text(encoding="utf-8")
        self.assertIn("when 1 => return 128;", state)
        self.assertIn("when 7 => return 8192;", state)
        self.assertNotIn("func TMOVLocalToShared", memory)
        self.assertNotIn("func TMOVSharedToLocal", memory)

    def test_tmatmul_uses_standard_m_n_k_bundle_dimensions(self) -> None:
        page = (ROOT / "docs/instructions/tile/TMATMUL.md").read_text(
            encoding="utf-8"
        )
        for expected in ("B.DIM LB0 M", "B.DIM LB1 N", "B.DIM LB2 K"):
            self.assertIn(expected, page)
        for stale in ("B.DIM LB0 N", "B.DIM LB1 M", "B.DIM LB2 Col"):
            self.assertNotIn(stale, page)
        self.assertIn("<LB0:M, LB1:N, LB2:K", page)

    def test_comparison_accepts_both_historical_operation_map_keys(self) -> None:
        path = ROOT / "scripts/generate-executable-model-comparison"
        loader = importlib.machinery.SourceFileLoader("comparison_generator", str(path))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        self.assertIsNotNone(spec)
        module = importlib.util.module_from_spec(spec)
        loader.exec_module(module)
        self.assertEqual(module.snapshot_operation_name({"name": "TADD"}), "TADD")
        self.assertEqual(
            module.snapshot_operation_name({"canonical_name": "TADD"}), "TADD"
        )
        with self.assertRaises(ValueError):
            module.snapshot_operation_name({"family": "TEPL"})
        self.assertEqual(module.snapshot_selector_value({"selector": "0x068"}), 0x068)
        self.assertEqual(
            module.snapshot_selector_value({"selector": None, "function": 8}), 8
        )
        with self.assertRaises(ValueError):
            module.snapshot_selector_value({"name": "TADD"})


if __name__ == "__main__":
    unittest.main()
