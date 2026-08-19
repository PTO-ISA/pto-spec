from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

from scripts.asl_units import load_units
from scripts.instruction_docs import load_instruction_index
from scripts.instruction_contracts import load_field_domains


ROOT = Path(__file__).resolve().parents[2]


class CommonV058ContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.scalar = json.loads(
            (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
        )
        cls.command = json.loads(
            (ROOT / "spec/catalog/command-forms.json").read_text(encoding="utf-8")
        )
        cls.tile = json.loads(
            (ROOT / "spec/catalog/tile-operations.json").read_text(encoding="utf-8")
        )
        cls.reservations = json.loads(
            (ROOT / "spec/catalog/extension-encoding-reservations.json").read_text(
                encoding="utf-8"
            )
        )

    def test_pto_formal_sources_do_not_depend_on_external_isa_references(self) -> None:
        paths = [
            *sorted((ROOT / "docs/status/decisions").glob("*.md")),
            *sorted((ROOT / "docs/status/open").glob("*.md")),
            *sorted((ROOT / "docs/status/plans").glob("*.md")),
            ROOT / "asl/arch/overview/encoding-ownership.asl",
        ]
        forbidden = (
            "davincioo",
            "linx",
            "docs/zh/isa",
            "manual-page-read",
            "linxisa",
            "public-source",
            "public source",
            "external source",
            "comparison source",
            "independent executable",
            "comparison executable",
            "executable isa comparison",
            "executable isa/model comparison",
            "comparison model",
            "pinned independent",
            "pinned public",
        )
        for path in paths:
            text = path.read_text(encoding="utf-8").lower()
            for token in forbidden:
                with self.subTest(path=path, token=token):
                    self.assertNotIn(token, path.as_posix().lower())
                    self.assertNotIn(token, text)

    def test_pto_asl_omits_external_source_identities(self) -> None:
        forbidden = (
            "davincioo",
            "linxisa",
            "docs/zh/isa",
            "manual-page-read",
        )
        for path in sorted((ROOT / "asl").rglob("*.asl")):
            text = path.read_text(encoding="utf-8").lower()
            for token in forbidden:
                with self.subTest(path=path, token=token):
                    self.assertNotIn(token, path.as_posix().lower())
                    self.assertNotIn(token, text)

    def test_deleted_names_are_not_active_or_reserved(self) -> None:
        active_names = {form["mnemonic"] for form in self.command["forms"]}
        reserved_names = {
            reservation["mnemonic"]
            for reservation in self.reservations["reservations"]
        }

        for deleted in ("B.IOD", "BSTART.PAR", "C.B.IOS"):
            self.assertNotIn(deleted, active_names)
            self.assertNotIn(deleted, reserved_names)

    def test_two_level_conditional_branches_are_reserved_not_active(self) -> None:
        conditional_branches = {
            "B.EQ",
            "B.NE",
            "B.LT",
            "B.GE",
            "B.LTU",
            "B.GEU",
            "B.Z",
            "B.NZ",
        }
        active_names = {form["mnemonic"] for form in self.scalar["forms"]}
        reserved_names = {
            reservation["mnemonic"]
            for reservation in self.reservations["reservations"]
        }

        self.assertTrue(conditional_branches.isdisjoint(active_names))
        self.assertTrue(conditional_branches <= reserved_names)

    def test_b_ios_reuses_the_former_b_iod_slot(self) -> None:
        forms = [form for form in self.command["forms"] if form["mnemonic"] == "B.IOS"]

        self.assertEqual(len(forms), 1)
        self.assertEqual(
            forms[0]["encoding"],
            [
                {
                    "index": 0,
                    "mask": "0xf00871ff",
                    "match": "0x00001013",
                    "width_bits": 32,
                }
            ],
        )

    def test_l_bstop_owns_the_documented_64_bit_stop_encoding(self) -> None:
        forms = [
            form for form in self.command["forms"] if form["mnemonic"] == "L.BSTOP"
        ]

        self.assertEqual(len(forms), 1)
        self.assertEqual(forms[0]["asm"], "L.BSTOP")
        self.assertEqual(forms[0]["semantic_handler"], "ExecuteBundleStop")
        self.assertEqual(
            forms[0]["encoding"],
            [
                {
                    "index": 0,
                    "mask": "0xffffffff",
                    "match": "0x0000000f",
                    "width_bits": 32,
                },
                {
                    "index": 1,
                    "mask": "0xffffffff",
                    "match": "0x00000001",
                    "width_bits": 32,
                },
            ],
        )

    def test_b_iot_has_no_mask_only_shared_form(self) -> None:
        forms = [form for form in self.command["forms"] if form["mnemonic"] == "B.IOT"]

        self.assertTrue(forms)
        for form in forms:
            fields = {field["name"] for field in form["fields"]}
            self.assertTrue(
                {"SrcTile0", "SrcTile1", "DstTile"}.intersection(fields),
                form["asm"],
            )

    def test_tload_tstore_keep_encoded_base_and_stride_schema(self) -> None:
        by_name = {operation["name"]: operation for operation in self.tile["operations"]}

        for name in ("TLOAD", "TSTORE"):
            operands = {
                operand["field"]: operand["role"]
                for operand in by_name[name]["operands"]
            }
            self.assertEqual(operands["address"], "base-address")
            self.assertEqual(operands["scalar0"], "row-stride-elements")

    def test_block_datatype_namespace_is_total_and_reserved_for_extension(self) -> None:
        domains = load_field_domains(load_units(ROOT / "asl"))
        domain = domains["PTO-FIELD-BLOCK-DATATYPE"]
        assigned = dict(domain.assigned)

        self.assertEqual(domain.width, 5)
        self.assertEqual(len(assigned), 25)
        self.assertEqual(assigned[0], "FP64")
        self.assertEqual(assigned[28], "U4X2")
        self.assertEqual(domain.reserved, (15, 21, 22, 23, 29, 30, 31))
        self.assertNotIn("NONE", assigned.values())
        self.assertNotIn("NULL", assigned.values())

    def test_five_bit_datatype_mapping_is_owned_by_arch(self) -> None:
        arch = (ROOT / "asl/arch/data-types/tile-data-types.asl").read_text(
            encoding="utf-8"
        )
        elements = (ROOT / "asl/tile/model/definedness/elements.asl").read_text(
            encoding="utf-8"
        )

        self.assertIn("type TileDataTypeEncoding of bits(5);", arch)
        self.assertIn("func TileDataTypeFromEncoding", arch)
        self.assertIn("func TileDataTypeToEncoding", arch)
        self.assertNotIn("func TileDataTypeFromEncoding", elements)
        self.assertNotIn("func TileDataTypeEncodingValid", elements)

    def test_tfma_remains_active_at_selector_01c(self) -> None:
        tfma = next(
            operation
            for operation in self.tile["operations"]
            if operation["name"] == "TFMA"
        )

        self.assertEqual(tfma["selector"], "0x01C")
        self.assertEqual((tfma["mode"], tfma["function"]), (0, 28))

    def test_every_instruction_has_a_specific_summary(self) -> None:
        generic = re.compile(
            r"Execute the .+ (?:scalar instruction|instruction|Tile operation|operation) contract\."
        )
        missing = [
            record.mnemonic
            for record in load_instruction_index(ROOT)
            if record.surface in {"scalar", "block", "tile"}
            and generic.fullmatch(record.summary)
        ]

        self.assertEqual(missing, [])

    def test_fused_bstart_call_descriptions_capture_atomic_call_contract(self) -> None:
        records = {
            record.mnemonic: record for record in load_instruction_index(ROOT)
        }

        expectations = {
            "BSTART.CALL": (
                "Atomically",
                "direct-call BARG",
                "independent return target",
                "to ra",
            ),
            "BSTART.ICALL": (
                "Atomically",
                "BARG.BPCN",
                "indirect-call BARG",
                "independent return target",
                "to ra",
            ),
        }
        for mnemonic, required_fragments in expectations.items():
            summary = records[mnemonic].summary
            for required in required_fragments:
                self.assertIn(required, summary, (mnemonic, summary))

    def test_dma_description_matches_the_normative_64_byte_copy(self) -> None:
        records = {
            record.mnemonic: record for record in load_instruction_index(ROOT)
        }
        summary = records["DMA"].summary

        for required in (
            "64-byte",
            "validates both ranges before effects",
            "snapshots the source",
            "overlap has memmove semantics",
            "fault leaves memory unchanged",
        ):
            self.assertIn(required, summary)
        self.assertNotIn("64-bit", summary)

    def test_davincioo_shared_memory_text_is_point_locally_superseded(self) -> None:
        warning = "> Superseded Shared-memory description:"
        cases = (
            (
                "docs/status/legacy/davincioo-arch/"
                "memory-ordering-and-exceptions.md",
                (
                    ("## Memory Paths", "Exactly-one issuer"),
                    ("## Address Interpretation", "Shared full load/store"),
                ),
            ),
            (
                "docs/status/legacy/davincioo-arch/assembly-syntax.md",
                (("## Shared GM Forms", "exactly-one GM -> Shared full load"),),
            ),
            (
                "docs/status/legacy/davincioo-arch/isa-overview.md",
                (("## Data Movement", "GM→Shared 由 exactly-one issuer"),),
            ),
        )

        for relative, sections in cases:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn('"status": "historical"', text, relative)
            self.assertNotIn('"status": "active"', text, relative)
            for heading, obsolete_text in sections:
                with self.subTest(path=relative, section=heading):
                    section_start = text.index(heading)
                    obsolete_start = text.index(obsolete_text, section_start)
                    warning_start = text.index(warning, section_start)
                    self.assertLess(warning_start, obsolete_start)


if __name__ == "__main__":
    unittest.main()
