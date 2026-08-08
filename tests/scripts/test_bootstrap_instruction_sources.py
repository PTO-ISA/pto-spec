from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from scripts.bootstrap_instruction_sources import bootstrap_instruction_sources
from scripts.instruction_docs import check_catalog_projection, load_instruction_index


class BootstrapInstructionSourcesTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        (self.root / "spec/catalog").mkdir(parents=True)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_catalogs(self) -> None:
        scalar = {
            "forms": [
                {
                    "form_id": "add-form",
                    "mnemonic": "ADD",
                    "asm": "add SrcL, SrcR, ->RegDst",
                    "semantic_family": "ALU",
                    "semantic_handler": "ScalarBinary",
                }
            ]
        }
        command = {
            "forms": [
                {
                    "form_id": "bstop-form",
                    "mnemonic": "BSTOP",
                    "asm": "BSTOP",
                    "semantic_group": "Bundle Split",
                    "semantic_handler": "ExecuteBundleStop",
                    "semantic_summary": "Commit and close the current bundle.",
                }
            ]
        }
        tile = {
            "operations": [
                {
                    "name": "TADD",
                    "family": "TEPL",
                    "semantic_handler": "ExecuteTileBinary",
                }
            ]
        }
        for name, value in (
            ("scalar-forms.json", scalar),
            ("command-forms.json", command),
            ("tile-operations.json", tile),
        ):
            (self.root / "spec/catalog" / name).write_text(
                json.dumps(value), encoding="utf-8"
            )
        tile_page = self.root / "docs/tile/TADD.md"
        tile_page.parent.mkdir(parents=True)
        tile_page.write_text(
            "---\n"
            + json.dumps(
                {
                    "bundle": "BSTART.TEPL TADD\nB.DIM LB0\nB.IOT",
                    "xlsx": {
                        "category": "Tile-Tile Elementwise\n逐元素双输入",
                        "subcategory": "算术计算",
                    },
                }
            )
            + "\n---\n# TADD\n",
            encoding="utf-8",
        )

    def test_bootstrap_creates_mirrored_executable_contract_sources(self) -> None:
        self.write_catalogs()

        bootstrap_instruction_sources(self.root)

        paths = {record.source_path.as_posix() for record in load_instruction_index(self.root)}
        self.assertEqual(
            paths,
            {
                "asl/block/lifecycle/BSTOP.asl",
                "asl/scalar/alu/ADD.asl",
                "asl/tile/tile-tile-elementwise/arithmetic/TADD.asl",
            },
        )
        scalar = (self.root / "asl/scalar/alu/ADD.asl").read_text(encoding="utf-8")
        self.assertIn("ScalarOperation_ADD", scalar)
        self.assertIn("ScalarHandler_ScalarBinary", scalar)
        tile = (
            self.root / "asl/tile/tile-tile-elementwise/arithmetic/TADD.asl"
        ).read_text(encoding="utf-8")
        self.assertIn("TileOperation_TADD", tile)
        self.assertIn("TileHandler_ExecuteTileBinary", tile)
        self.assertIn('"catalog_indices":[0]', tile)
        self.assertEqual(check_catalog_projection(self.root), [])


if __name__ == "__main__":
    unittest.main()
