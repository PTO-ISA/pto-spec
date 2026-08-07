from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from scripts.instruction_docs import check_tree, generate_tree, load_instruction_index


def asl_source(
    *,
    mnemonic: str = "TADD",
    surface: str = "tile",
    classification: list[str] | None = None,
) -> str:
    metadata = {
        "mnemonic": mnemonic,
        "surface": surface,
        "classification": classification or ["tile-tile-elementwise", "arithmetic"],
        "summary": "Add corresponding tile elements.",
        "assembly": ["TADD <shape>, Src0, Src1, ->Dst"],
        "block": ["BSTART.TEPL TADD", "B.DIM ...", "B.IOT ...", "BSTOP"],
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


if __name__ == "__main__":
    unittest.main()
