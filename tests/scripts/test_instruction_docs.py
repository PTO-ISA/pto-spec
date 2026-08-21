from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from scripts.instruction_docs import (
    ROOT,
    check_catalog_projection,
    check_navigation,
    check_navigation_projection,
    check_normative_legacy_links,
    check_tree,
    check_version_neutrality,
    doc_path_for,
    generate_tree,
    load_doc_index,
    load_instruction_index,
    render_page,
    render_unit_page,
    render_nav,
)


def complete_contract(
    *,
    encoding_class: str = "selector-encoded-block-operation",
    standalone_opcode: bool = False,
    block_composition: list[str] | None = None,
) -> dict[str, object]:
    return {
        "encoding_class": encoding_class,
        "canonical_assembly": ["TADD <shape>, Src0, Src1, ->Dst"],
        "field_contracts": {},
        "operands": [
            {"field": "destination0", "role": "destination"},
            {"field": "source0", "role": "source-left"},
            {"field": "source1", "role": "source-right"},
        ],
        "defaults": ["B.DATR defaults to FP64 and NORM when omitted."],
        "legality": ["All bound Tiles have matching valid shapes."],
        "state_effects": ["Write destination0 atomically after preflight."],
        "memory_effects": ["none"],
        "ordering": ["none"],
        "exceptions": ["Illegal bindings reject before destination effects."],
        "examples": ["BSTART.VEC TADD, FP32; B.IOT ...; BSTOP"],
        "block_composition": block_composition
        or ["BSTART.VEC TADD, DataType", "B.IOT", "BSTOP"],
        "standalone_opcode": standalone_opcode,
    }


def asl_source(
    *,
    mnemonic: str = "TADD",
    surface: str = "tile",
    classification: list[str] | None = None,
    catalog_records: list[dict[str, object]] | None = None,
    contract: dict[str, object] | None = None,
) -> str:
    metadata = {
        "id": f"PTO-INST-{surface.upper()}-{mnemonic.replace('.', '-').replace(' ', '-').upper()}",
        "mnemonic": mnemonic,
        "surface": surface,
        "classification": classification or ["elementwise-tile-tile", "arithmetic"],
        "depends_on": [],
        "summary": "Add corresponding tile elements.",
        "assembly": ["TADD <shape>, Src0, Src1, ->Dst"],
        "block": ["BSTART.TEPL TADD", "B.DIM ...", "B.IOT ...", "BSTOP"],
        "catalog_records": catalog_records
        or [{"mnemonic": mnemonic, "semantic_handler": "ExecuteTileBinary"}],
        "catalog_indices": list(range(len(catalog_records or [{}]))),
    }
    if surface == "tile":
        metadata["engine"] = "VEC"
    if contract is not None:
        metadata["contract"] = contract
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


def unit_source(
    *,
    unit_id: str = "PTO-ARCH-STATE-PROGRAM-COUNTER",
    surface: str = "arch",
    classification: list[str] | None = None,
    body: str = "readonly func ReadPC() => bits(64)\nbegin\n    return Zeros{64};\nend;\n",
) -> str:
    metadata = {
        "id": unit_id,
        "surface": surface,
        "classification": classification or ["state", "program-counter"],
        "depends_on": [],
    }
    encoded = json.dumps(metadata, ensure_ascii=False, sort_keys=True)
    return f"// PTO-UNIT: {encoded}\n{body}"


class InstructionDocsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_asl(
        self,
        relative: str = "tile/elementwise-tile-tile/arithmetic/TADD.asl",
        **kwargs: object,
    ) -> Path:
        path = self.root / "asl" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(asl_source(**kwargs), encoding="utf-8")
        return path

    def write_unit(self, relative: str, source: str) -> Path:
        path = self.root / "asl" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source, encoding="utf-8")
        return path

    def test_load_instruction_index_reads_mnemonic_and_regions(self) -> None:
        self.write_asl()

        records = load_instruction_index(self.root)

        self.assertEqual([record.mnemonic for record in records], ["TADD"])
        self.assertEqual(records[0].classification, ("elementwise-tile-tile", "arithmetic"))
        self.assertIn("func ExecuteTADD()", records[0].regions["operation"])
        self.assertEqual(records[0].catalog_records[0]["mnemonic"], "TADD")

    def test_direct_script_entrypoint_loads_repository_modules(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/instruction_docs.py", "--help"],
            cwd=ROOT,
            text=True,
            capture_output=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)

    def test_check_tree_rejects_missing_markdown_page(self) -> None:
        self.write_asl()

        errors = check_tree(self.root)

        self.assertIn(
            "missing Markdown page for TADD: docs/tile/elementwise-tile-tile/arithmetic/TADD.md",
            errors,
        )

    def test_check_tree_rejects_page_without_asl(self) -> None:
        page = self.root / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
        page.parent.mkdir(parents=True, exist_ok=True)
        page.write_text("# TADD\n", encoding="utf-8")

        errors = check_tree(self.root)

        self.assertIn(
            "missing ASL source for docs/tile/elementwise-tile-tile/arithmetic/TADD.md",
            errors,
        )

    def test_check_tree_rejects_non_mirrored_metadata_path(self) -> None:
        self.write_asl("tile/matrix/TADD.asl")

        errors = check_tree(self.root)

        self.assertIn(
            "TADD metadata classification elementwise-tile-tile/arithmetic does not match ASL path tile/matrix/TADD.asl",
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
            (self.root / "docs/block/execution/BSTART_CALL.md").exists()
        )
        self.assertEqual(check_tree(self.root), [])

    def test_load_instruction_index_rejects_duplicate_mnemonic(self) -> None:
        self.write_asl()
        self.write_asl("tile/elementwise-tile-tile/logical/TADD.asl")

        with self.assertRaisesRegex(ValueError, "duplicate instruction mnemonic TADD"):
            load_instruction_index(self.root)

    def test_generate_tree_embeds_exact_asl_and_check_detects_drift(self) -> None:
        source = self.write_asl()

        generate_tree(self.root)
        page = self.root / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
        rendered = page.read_text(encoding="utf-8")
        self.assertIn(f"source={source.relative_to(self.root)}", rendered)
        self.assertIn("func ExecuteTADD()", rendered)
        self.assertEqual(check_tree(self.root), [])

        page.write_text(rendered.replace("return TRUE;", "return FALSE;"), encoding="utf-8")
        self.assertIn("stale generated Markdown page for TADD", check_tree(self.root))

    def test_generate_tree_projects_stable_ndf_identity(self) -> None:
        self.write_asl()

        generate_tree(self.root)
        page = self.root / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
        rendered = page.read_text(encoding="utf-8")

        self.assertIn("## Normative identity {#PTO-INST-TILE-TADD}", rendered)
        self.assertIn(
            "<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->",
            rendered,
        )
        self.assertIn("**Instruction class:** `elementwise-tile-tile`", rendered)
        self.assertIn("**Execution engine:** `VEC`", rendered)

    def test_generate_tree_emits_complete_tile_block(self) -> None:
        self.write_asl()

        generate_tree(self.root)
        rendered = (
            self.root / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
        ).read_text(encoding="utf-8")

        self.assertIn("## Block composition", rendered)
        self.assertLess(rendered.index("BSTART.TEPL TADD"), rendered.index("BSTOP"))

    def test_generate_tree_projects_encoding_and_fields_from_asl_metadata(self) -> None:
        self.write_asl(
            "block/operands/B.IOS.asl",
            mnemonic="B.IOS",
            surface="block",
            classification=["operands"],
            catalog_records=[
                {
                    "mnemonic": "B.IOS",
                    "form_id": "b_ios_32_example",
                    "encoding_kind": "L32",
                    "length_bits": 32,
                    "encoding": [
                        {
                            "match": "0x00001013",
                            "mask": "0xf00871ff",
                            "width_bits": 32,
                        }
                    ],
                    "constraints": [],
                    "fields": [
                        {
                            "name": "SharedTID",
                            "width": 8,
                            "signedness": "encoding-defined",
                            "pieces": [
                                {"instruction_lsb": 20, "value_lsb": 0, "width": 8}
                            ],
                        }
                    ],
                }
            ],
        )

        generate_tree(self.root)
        rendered = (
            self.root / "docs/block/operands/B.IOS.md"
        ).read_text(encoding="utf-8")

        self.assertIn("0x00001013 / 0xf00871ff", rendered)
        self.assertIn("| b_ios_32_example | SharedTID | 8 |", rendered)

    def test_generate_tree_projects_complete_catalog_contract_without_placeholders(self) -> None:
        self.write_asl(
            "tile/memory-and-data-movement/regular/TLOAD.asl",
            mnemonic="TLOAD",
            surface="tile",
            classification=["memory-and-data-movement", "regular"],
            catalog_records=[
                {
                    "name": "TLOAD",
                    "family": "TLSU",
                    "function": 0,
                    "semantic_handler": "TLOAD",
                    "semantic_summary": "Load the selected GM rectangle into a Tile destination.",
                    "operands": [
                        {"field": "destination0", "role": "destination"},
                        {"field": "address", "role": "base-address"},
                        {"field": "scalar0", "role": "row-stride-bytes"},
                    ],
                    "state_effects": ["destination0 payload and definedness"],
                    "legality_handler": "TileOperandsLegal_TLOAD",
                    "effect_contract": "TLOAD",
                    "fault_contract": "ExecuteTileInstruction",
                    "restart_contract": "CompleteBundleAtWithAcceptedApplicabilityRules",
                    "datr_contract": {
                        "allowed_nonzero_fields": ["Layout"],
                        "pad_union": "must-zero",
                    },
                }
            ],
        )

        generate_tree(self.root)
        rendered = (
            self.root / "docs/tile/memory-and-data-movement/regular/TLOAD.md"
        ).read_text(encoding="utf-8")

        self.assertIn("## Operands and results", rendered)
        self.assertIn("| address | base-address |", rendered)
        self.assertIn("`TileOperandsLegal_TLOAD`", rendered)
        self.assertIn("`CompleteBundleAtWithAcceptedApplicabilityRules`", rendered)
        self.assertIn("destination0 payload and definedness", rendered)
        self.assertNotIn("may be added here", rendered)

    def test_b_datr_renders_complete_datatype_encoding_closure(self) -> None:
        record = next(
            record
            for record in load_instruction_index(ROOT)
            if record.mnemonic == "B.DATR"
        )

        rendered = render_page(record)

        self.assertIn("## Encoding class", rendered)
        self.assertIn("`standalone-encoded`", rendered)
        self.assertIn("## Encoded field closure", rendered)
        self.assertIn(
            "| b_datr_32_c161a042ff38 | DataType | 5 | "
            "0–14, 16–20, 24–28, 31 | none | 15, 21–23, 29–30 |",
            rendered,
        )
        self.assertIn("code 31, not code zero, is DTYPE_NONE", rendered)
        self.assertIn("Encoded DataType zero selects FP64", rendered)
        self.assertNotIn("encoded operand or control", rendered)

    def test_encoded_field_dispositions_render_compact_assigned_and_reserved_ranges(self) -> None:
        contract = complete_contract(
            encoding_class="standalone-encoded",
            standalone_opcode=True,
            block_composition=["none"],
        )
        contract["operands"] = [
            {"field": "RegDst", "role": "absolute GPR destination"}
        ]
        self.write_asl(
            "block/operands/B.TEST.asl",
            mnemonic="B.TEST",
            surface="block",
            classification=["operands"],
            contract=contract,
            catalog_records=[
                {
                    "mnemonic": "B.TEST",
                    "form_id": "b_test_32",
                    "encoding": [
                        {"match": "0x0", "mask": "0x0", "width_bits": 32}
                    ],
                    "fields": [
                        {
                            "name": "RegDst",
                            "width": 5,
                            "signedness": "encoding-defined",
                            "pieces": [],
                        }
                    ],
                    "constraints": [
                        {
                            "field": "RegDst",
                            "operator": "one-of",
                            "values": list(range(24)),
                        }
                    ],
                }
            ],
        )

        generate_tree(self.root)
        rendered = (self.root / "docs/block/operands/B.TEST.md").read_text(
            encoding="utf-8"
        )

        self.assertIn("## Encoded field closure", rendered)
        self.assertIn("| b_test_32 | RegDst | 5 | 0–23 | none | 24–31 |", rendered)
        self.assertIn("Fault_IllegalInstruction", rendered)

    def test_excluded_field_value_owner_is_not_rendered_as_reserved(self) -> None:
        contract = complete_contract(
            encoding_class="standalone-encoded",
            standalone_opcode=True,
            block_composition=["none"],
        )
        contract["operands"] = [
            {"field": "BrType", "role": "block transfer selector"}
        ]
        self.write_asl(
            "block/encoding/C.BSTART.TEST.asl",
            mnemonic="C.BSTART.TEST",
            surface="block",
            classification=["encoding"],
            contract=contract,
            catalog_records=[
                {
                    "mnemonic": "C.BSTART.TEST",
                    "form_id": "compressed_start",
                    "encoding": [
                        {"match": "0x0", "mask": "0x0", "width_bits": 16}
                    ],
                    "fields": [
                        {
                            "name": "BrType",
                            "width": 3,
                            "signedness": "encoding-defined",
                            "pieces": [],
                        }
                    ],
                    "constraints": [
                        {"field": "BrType", "operator": "one-of", "values": [1, 5, 7]}
                    ],
                    "excluded_value_owners": [
                        {"field": "BrType", "value": 0, "owner": "C.BSTOP"}
                    ],
                }
            ],
        )

        generate_tree(self.root)
        rendered = (self.root / "docs/block/encoding/C.BSTART.TEST.md").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            "| compressed_start | BrType | 3 | 1, 5, 7 | 0 (C.BSTOP) | 2–4, 6 |",
            rendered,
        )
        self.assertNotIn("reserved values: 0", rendered)

    def test_selector_operation_declares_no_standalone_opcode_and_composition(self) -> None:
        self.write_asl(contract=complete_contract())

        generate_tree(self.root)
        rendered = (
            self.root / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
        ).read_text(encoding="utf-8")

        self.assertIn("`selector-encoded-block-operation`", rendered)
        self.assertIn("This operation has no standalone opcode.", rendered)
        self.assertIn("BSTART.VEC TADD, DataType", rendered)
        self.assertIn("## Defaults and encoded zero", rendered)
        self.assertIn("## State effects", rendered)
        self.assertIn("## Memory effects and ordering", rendered)
        self.assertIn("## Examples", rendered)

    def test_check_detects_removed_datatype_closure_row(self) -> None:
        generate_tree(ROOT)
        page = ROOT / "docs/block/attributes/B.DATR.md"
        original = page.read_text(encoding="utf-8")
        self.addCleanup(page.write_text, original, encoding="utf-8")
        datatype_row = next(
            line
            for line in original.splitlines(keepends=True)
            if "| DataType | 5 |" in line
        )
        page.write_text(original.replace(datatype_row, ""), encoding="utf-8")

        self.assertIn("stale generated Markdown page for B.DATR", check_tree(ROOT))

    def test_generate_tree_preserves_supplementary_markdown(self) -> None:
        self.write_asl()
        page = self.root / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
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

        nav = render_nav(load_instruction_index(self.root), Path("docs"))

        self.assertEqual(
            nav,
            "nav:\n"
            "  - Block:\n"
            "      - Lifecycle:\n"
            "          - BSTOP: block/lifecycle/BSTOP.md\n"
            "  - Scalar:\n"
            "      - ALU:\n"
            "          - ADD: scalar/alu/ADD.md\n"
            "  - Tile:\n"
            "      - Elementwise Tile Tile:\n"
            "          - Arithmetic:\n"
            "              - TADD: tile/elementwise-tile-tile/arithmetic/TADD.md\n",
        )

    def test_generate_tree_writes_mkdocs_navigation(self) -> None:
        self.write_asl()

        generate_tree(self.root)

        generated_nav = self.root / "docs/mkdocs/generated-nav.yml"
        mkdocs_config = self.root / "docs/mkdocs/mkdocs.yml"
        self.assertEqual(
            generated_nav.read_text(encoding="utf-8"),
            render_nav(load_doc_index(self.root), Path("docs"), self.root),
        )
        self.assertIn(
            "tile/elementwise-tile-tile/arithmetic/TADD.md",
            mkdocs_config.read_text(encoding="utf-8"),
        )
        self.assertEqual(check_navigation(self.root), [])
        self.assertEqual(check_navigation_projection(self.root), [])

    def test_decision_template_is_excluded_from_navigation(self) -> None:
        decisions = self.root / "docs/status/decisions"
        decisions.mkdir(parents=True)
        (decisions / "0000-template.md").write_text(
            "# ADR-0000: Decision template\n", encoding="utf-8"
        )
        (decisions / "0001-accepted.md").write_text(
            "# ADR-0001: Accepted decision\n", encoding="utf-8"
        )

        navigation = render_nav(load_doc_index(self.root), Path("docs"), self.root)

        self.assertNotIn("0000-template.md", navigation)
        self.assertNotIn("ADR-0000", navigation)
        self.assertIn(
            '          - "ADR-0001: Accepted decision": status/decisions/0001-accepted.md',
            navigation,
        )

    def test_navigation_merges_common_classification_prefixes(self) -> None:
        self.write_unit(
            "block/model/commit/effects.asl",
            unit_source(
                unit_id="PTO-BLOCK-MODEL-COMMIT-EFFECTS",
                surface="block",
                classification=["model", "commit", "effects"],
            ),
        )
        self.write_unit(
            "block/model/dispatch/decode.asl",
            unit_source(
                unit_id="PTO-BLOCK-MODEL-DISPATCH-DECODE",
                surface="block",
                classification=["model", "dispatch", "decode"],
            ),
        )

        nav = render_nav(load_doc_index(self.root), Path("docs"))

        self.assertEqual(nav.count("      - Model:\n"), 1)
        self.assertIn("          - Commit:\n", nav)
        self.assertIn("          - Dispatch:\n", nav)
        self.assertIn("              - Effects: block/model/commit/effects.md\n", nav)
        self.assertIn("              - Decode: block/model/dispatch/decode.md\n", nav)

    def test_navigation_renders_engine_acronyms_canonically(self) -> None:
        self.write_unit(
            "block/model/dispatch/shared-tlsu.asl",
            unit_source(
                unit_id="PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
                surface="block",
                classification=["model", "dispatch", "shared-tlsu"],
            ),
        )

        nav = render_nav(load_doc_index(self.root), Path("docs"))

        self.assertIn("              - Shared TLSU: block/model/dispatch/shared-tlsu.md", nav)

    def test_navigation_projection_rejects_stale_generated_files(self) -> None:
        self.write_asl()
        generate_tree(self.root)
        generated_nav = self.root / "docs/mkdocs/generated-nav.yml"
        generated_nav.write_text(
            generated_nav.read_text(encoding="utf-8")
            + "  - Retired: status/decisions/0045-retired.md\n",
            encoding="utf-8",
        )

        self.assertEqual(
            check_navigation_projection(self.root),
            ["stale generated MkDocs navigation: docs/mkdocs/generated-nav.yml"],
        )

    def test_version_neutrality_reports_only_active_normative_surfaces(self) -> None:
        active_asl = self.root / "asl/tile/state.asl"
        active_asl.parent.mkdir(parents=True, exist_ok=True)
        active_asl.write_text("// PTO ISA 0.58 fixes this rule.\n", encoding="utf-8")
        active_doc = self.root / "docs/tile/TADD.md"
        active_doc.parent.mkdir(parents=True, exist_ok=True)
        active_doc.write_text("PTO ISA 0.58.0\n", encoding="utf-8")
        historical = self.root / "docs/status/decisions/0052.md"
        historical.parent.mkdir(parents=True, exist_ok=True)
        historical.write_text("PTO ISA 0.58.0\n", encoding="utf-8")

        errors = check_version_neutrality(self.root)

        self.assertEqual(
            errors,
            [
                "asl/tile/state.asl:1: active normative surface contains release version 0.58",
                "docs/tile/TADD.md:1: active normative surface contains release version 0.58.0",
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


class FourSurfaceDocsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_unit(self, relative: str, body: str) -> Path:
        path = self.root / "asl" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")
        return path

    def test_doc_path_exactly_mirrors_asl_source(self) -> None:
        self.assertEqual(
            doc_path_for(Path("asl/arch/state/program-counter.asl")),
            Path("docs/arch/state/program-counter.md"),
        )
        self.assertEqual(
            doc_path_for(Path("asl/block/operands/B.IOR.asl")),
            Path("docs/block/operands/B.IOR.md"),
        )

    def test_generate_tree_covers_instruction_and_concept_units_exactly(self) -> None:
        self.write_unit(
            "arch/state/program-counter.asl",
            unit_source(),
        )
        self.write_unit(
            "block/operands/B.IOR.asl",
            asl_source(
                mnemonic="B.IOR",
                surface="block",
                classification=["operands"],
            ),
        )

        generate_tree(self.root)

        discovered = {
            path.relative_to(self.root)
            for surface in ("arch", "block", "scalar", "tile")
            for path in (self.root / "docs" / surface).rglob("*.md")
            if (self.root / "docs" / surface).exists()
        }
        self.assertEqual(
            discovered,
            {
                Path("docs/arch/state/program-counter.md"),
                Path("docs/block/operands/B.IOR.md"),
            },
        )
        self.assertEqual(check_tree(self.root), [])

    def test_concept_page_embeds_exact_source_and_declares_owner(self) -> None:
        source = self.write_unit(
            "arch/state/program-counter.asl",
            unit_source(),
        )
        unit = load_doc_index(self.root)[0]

        rendered = render_unit_page(
            unit,
            source.read_text(encoding="utf-8"),
        )

        self.assertTrue(
            rendered.startswith(
                "<!-- GENERATED FROM: asl/arch/state/program-counter.asl -->\n"
                "# Program Counter\n\n"
                "**Normative ASL source:** `asl/arch/state/program-counter.asl`"
            )
        )
        self.assertIn("readonly func ReadPC()", rendered)
        self.assertNotIn("<!-- ndf:", rendered)

    def test_check_tree_rejects_source_declaration_mismatch(self) -> None:
        self.write_unit("arch/state/program-counter.asl", unit_source())
        generate_tree(self.root)
        page = self.root / "docs/arch/state/program-counter.md"
        page.write_text(
            page.read_text(encoding="utf-8").replace(
                "asl/arch/state/program-counter.asl",
                "asl/arch/state/wrong.asl",
                1,
            ),
            encoding="utf-8",
        )

        self.assertIn(
            "stale generated Markdown page for PTO-ARCH-STATE-PROGRAM-COUNTER",
            check_tree(self.root),
        )

    def test_check_tree_rejects_orphan_active_page(self) -> None:
        page = self.root / "docs/arch/state/orphan.md"
        page.parent.mkdir(parents=True, exist_ok=True)
        page.write_text("# Orphan\n", encoding="utf-8")

        self.assertIn(
            "missing ASL source for docs/arch/state/orphan.md",
            check_tree(self.root),
        )

    def test_navigation_rejects_legacy_entry(self) -> None:
        config = self.root / "docs/mkdocs/mkdocs.yml"
        config.parent.mkdir(parents=True, exist_ok=True)
        config.write_text(
            "nav:\n  - Old: status/legacy/old.md\n",
            encoding="utf-8",
        )

        self.assertEqual(
            check_navigation(self.root),
            ["MkDocs navigation includes non-normative legacy material"],
        )

    def test_normative_asl_rejects_legacy_link(self) -> None:
        self.write_unit(
            "arch/state/program-counter.asl",
            unit_source(body="// See docs/status/legacy/old.md\n"),
        )

        self.assertEqual(
            check_normative_legacy_links(self.root),
            [
                "asl/arch/state/program-counter.asl: normative reference targets "
                "non-normative legacy material"
            ],
        )

if __name__ == "__main__":
    unittest.main()
