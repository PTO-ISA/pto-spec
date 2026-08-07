from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from scripts.instruction_docs import (
    check_catalog_projection,
    check_tree,
    check_version_neutrality,
    generate_tree,
    load_instruction_index,
    render_nav,
)


def asl_source(
    *,
    mnemonic: str = "TADD",
    surface: str = "tile",
    classification: list[str] | None = None,
    catalog_records: list[dict[str, object]] | None = None,
) -> str:
    metadata = {
        "mnemonic": mnemonic,
        "surface": surface,
        "classification": classification or ["tile-tile-elementwise", "arithmetic"],
        "summary": "Add corresponding tile elements.",
        "assembly": ["TADD <shape>, Src0, Src1, ->Dst"],
        "block": ["BSTART.TEPL TADD", "B.DIM ...", "B.IOT ...", "BSTOP"],
        "catalog_records": catalog_records
        or [{"mnemonic": mnemonic, "semantic_handler": "ExecuteTileBinary"}],
        "catalog_indices": list(range(len(catalog_records or [{}]))),
    }
    encoded = json.dumps(metadata, ensure_ascii=False, sort_keys=True)
    return (
        f"// PTO-INSTRUCTION: {encoded}\n"
        "// DOC-BEGIN: decode\n"
        "readonly func DecodeTADD() => boolean\n"
        "begin\n"
        "    return TRUE;\n"
        "end;\n"
        "// DOC-END: decode\n"
        "// DOC-BEGIN: operation\n"
        "func ExecuteTADD()\n"
        "begin\n"
        "    return;\n"
        "end;\n"
        "// DOC-END: operation\n"
    )


class InstructionDocsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_asl(
        self,
        relative: str = "tile/tile-tile-elementwise/arithmetic/TADD.asl",
        **kwargs: object,
    ) -> Path:
        path = self.root / "asl" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(asl_source(**kwargs), encoding="utf-8")
        return path

    def test_load_instruction_index_reads_mnemonic_and_regions(self) -> None:
        self.write_asl()

        records = load_instruction_index(self.root)

        self.assertEqual([record.mnemonic for record in records], ["TADD"])
        self.assertEqual(records[0].classification, ("tile-tile-elementwise", "arithmetic"))
        self.assertIn("func ExecuteTADD()", records[0].regions["operation"])
        self.assertEqual(records[0].catalog_records[0]["mnemonic"], "TADD")

    def test_check_tree_rejects_missing_markdown_page(self) -> None:
        self.write_asl()

        errors = check_tree(self.root)

        self.assertIn(
            "missing Markdown page for TADD: docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md",
            errors,
        )

    def test_check_tree_rejects_page_without_asl(self) -> None:
        page = self.root / "docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md"
        page.parent.mkdir(parents=True, exist_ok=True)
        page.write_text("# TADD\n", encoding="utf-8")

        errors = check_tree(self.root)

        self.assertIn(
            "missing ASL source for docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md",
            errors,
        )

    def test_check_tree_rejects_non_mirrored_metadata_path(self) -> None:
        self.write_asl("tile/matrix/TADD.asl")

        errors = check_tree(self.root)

        self.assertIn(
            "TADD metadata classification tile-tile-elementwise/arithmetic does not match ASL path tile/matrix/TADD.asl",
            errors,
        )

    def test_space_in_mnemonic_uses_safe_mirrored_filename(self) -> None:
        self.write_asl(
            "block/execution/BSTART_CALL.asl",
            mnemonic="BSTART CALL",
            surface="block",
            classification=["execution"],
        )

        generate_tree(self.root)

        self.assertTrue(
            (self.root / "docs/instructions/block/execution/BSTART_CALL.md").exists()
        )
        self.assertEqual(check_tree(self.root), [])

    def test_load_instruction_index_rejects_duplicate_mnemonic(self) -> None:
        self.write_asl()
        self.write_asl("tile/tile-tile-elementwise/logical/TADD.asl")

        with self.assertRaisesRegex(ValueError, "duplicate instruction mnemonic TADD"):
            load_instruction_index(self.root)

    def test_generate_tree_embeds_exact_asl_and_check_detects_drift(self) -> None:
        source = self.write_asl()

        generate_tree(self.root)
        page = self.root / "docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md"
        rendered = page.read_text(encoding="utf-8")
        self.assertIn(f"source={source.relative_to(self.root)}", rendered)
        self.assertIn("func ExecuteTADD()", rendered)
        self.assertEqual(check_tree(self.root), [])

        page.write_text(rendered.replace("return TRUE;", "return FALSE;"), encoding="utf-8")
        self.assertIn("stale generated Markdown page for TADD", check_tree(self.root))

    def test_generate_tree_emits_complete_tile_block(self) -> None:
        self.write_asl()

        generate_tree(self.root)
        rendered = (
            self.root / "docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md"
        ).read_text(encoding="utf-8")

        self.assertIn("## Block composition", rendered)
        self.assertLess(rendered.index("BSTART.TEPL TADD"), rendered.index("BSTOP"))

    def test_generate_tree_preserves_supplementary_markdown(self) -> None:
        self.write_asl()
        page = self.root / "docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md"
        page.parent.mkdir(parents=True, exist_ok=True)
        page.write_text(
            "# Legacy TADD\n\nThis paragraph explains why TADD exists.\n",
            encoding="utf-8",
        )

        generate_tree(self.root)
        first = page.read_text(encoding="utf-8")
        generate_tree(self.root)
        second = page.read_text(encoding="utf-8")

        self.assertIn("This paragraph explains why TADD exists.", first)
        self.assertIn("<!-- SUPPLEMENTARY-BEGIN -->", first)
        self.assertEqual(first, second)

    def test_render_nav_is_stable_by_surface_and_classification(self) -> None:
        self.write_asl()
        self.write_asl(
            "scalar/alu/ADD.asl",
            mnemonic="ADD",
            surface="scalar",
            classification=["alu"],
        )
        self.write_asl(
            "block/lifecycle/BSTOP.asl",
            mnemonic="BSTOP",
            surface="block",
            classification=["lifecycle"],
        )

        nav = render_nav(load_instruction_index(self.root))

        self.assertEqual(
            nav,
            "nav:\n"
            "  - Scalar:\n"
            "      - ALU:\n"
            "          - ADD: instructions/scalar/alu/ADD.md\n"
            "  - Block:\n"
            "      - Lifecycle:\n"
            "          - BSTOP: instructions/block/lifecycle/BSTOP.md\n"
            "  - Tile:\n"
            "      - Tile Tile Elementwise:\n"
            "          - Arithmetic:\n"
            "              - TADD: instructions/tile/tile-tile-elementwise/arithmetic/TADD.md\n",
        )

    def test_generate_tree_writes_mkdocs_navigation(self) -> None:
        self.write_asl()

        generate_tree(self.root)

        generated_nav = self.root / "docs/mkdocs/generated-nav.yml"
        mkdocs_config = self.root / "docs/mkdocs/mkdocs.yml"
        self.assertEqual(
            generated_nav.read_text(encoding="utf-8"),
            render_nav(load_instruction_index(self.root)),
        )
        self.assertIn(
            "instructions/tile/tile-tile-elementwise/arithmetic/TADD.md",
            mkdocs_config.read_text(encoding="utf-8"),
        )

    def test_version_neutrality_reports_only_active_normative_surfaces(self) -> None:
        active_asl = self.root / "asl/tile/state.asl"
        active_asl.parent.mkdir(parents=True, exist_ok=True)
        active_asl.write_text("// PTO ISA 0.58 fixes this rule.\n", encoding="utf-8")
        active_doc = self.root / "docs/instructions/tile/TADD.md"
        active_doc.parent.mkdir(parents=True, exist_ok=True)
        active_doc.write_text("PTO ISA 0.58.0\n", encoding="utf-8")
        historical = self.root / "docs/architecture-decisions/0052.md"
        historical.parent.mkdir(parents=True, exist_ok=True)
        historical.write_text("PTO ISA 0.58.0\n", encoding="utf-8")

        errors = check_version_neutrality(self.root)

        self.assertEqual(
            errors,
            [
                "asl/tile/state.asl:1: active normative surface contains release version 0.58",
                "docs/instructions/tile/TADD.md:1: active normative surface contains release version 0.58.0",
            ],
        )

    def test_catalog_projection_requires_exact_asl_records(self) -> None:
        scalar_record = {
            "form_id": "add-form",
            "mnemonic": "ADD",
            "semantic_handler": "ScalarBinary",
        }
        self.write_asl(
            "scalar/alu/ADD.asl",
            mnemonic="ADD",
            surface="scalar",
            classification=["alu"],
            catalog_records=[scalar_record],
        )
        catalog_path = self.root / "spec/catalog/scalar-forms.json"
        catalog_path.parent.mkdir(parents=True, exist_ok=True)
        catalog_path.write_text(
            json.dumps({"forms": [scalar_record]}, sort_keys=True), encoding="utf-8"
        )
        for name, member in (
            ("command-forms.json", "forms"),
            ("tile-operations.json", "operations"),
        ):
            (catalog_path.parent / name).write_text(
                json.dumps({member: []}, sort_keys=True), encoding="utf-8"
            )

        self.assertEqual(check_catalog_projection(self.root), [])

        catalog_path.write_text(
            json.dumps(
                {
                    "forms": [
                        {
                            "form_id": "add-form",
                            "mnemonic": "ADD",
                            "semantic_handler": "WrongHandler",
                        }
                    ]
                },
                sort_keys=True,
            ),
            encoding="utf-8",
        )
        self.assertEqual(
            check_catalog_projection(self.root),
            ["scalar catalog projection differs from mnemonic ASL records"],
        )


if __name__ == "__main__":
    unittest.main()
