from __future__ import annotations

import runpy
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import AslUnit


SCRIPT = Path(__file__).resolve().parents[2] / "scripts/generate-mnemonic-avs.py"


def instruction_unit(surface: str, mnemonic: str, record: dict[str, object]) -> AslUnit:
    classification = {
        "scalar": ("alu",),
        "block": ("operands",),
        "tile": ("memory", "regular"),
    }[surface]
    return AslUnit(
        unit_id=f"PTO-{surface.upper()}-{mnemonic.replace('.', '-').replace('_', '-')}",
        surface=surface,
        classification=classification,
        depends_on=(),
        source_path=Path("asl") / surface / Path(*classification) / f"{mnemonic}.asl",
        mnemonic=mnemonic,
        line_count=20,
        metadata={
            "id": f"PTO-{surface.upper()}-{mnemonic.replace('.', '-').replace('_', '-')}",
            "surface": surface,
            "classification": list(classification),
            "depends_on": [],
            "mnemonic": mnemonic,
            "summary": f"{mnemonic} contract",
            "assembly": [f"{mnemonic} operands"],
            "block": ["BSTART", "B.IOT", "BSTOP"] if surface == "tile" else [],
            "catalog_indices": [3],
            "catalog_records": [record],
        },
    )


class GenerateMnemonicAvsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.module = runpy.run_path(
            str(SCRIPT), run_name="generate_mnemonic_avs_module"
        )
        cls.render = staticmethod(cls.module["render_mnemonic_avs"])
        cls.render_concept = staticmethod(cls.module["render_concept_avs"])

    def test_scalar_decode_test_has_stable_identity_and_canonical_selectors(
        self,
    ) -> None:
        unit = instruction_unit(
            "scalar",
            "ADD",
            {
                "encoding": [{"index": 0, "match": "0x00000005", "width_bits": 32}],
                "fields": [
                    {
                        "name": "RegDst",
                        "width": 5,
                        "pieces": [{"instruction_lsb": 7, "value_lsb": 0, "width": 5}],
                    }
                ],
                "form_id": "add_32_fixture",
                "length_bits": 32,
                "semantic_family": "ALU",
                "semantic_handler": "ScalarBinary",
            },
        )

        path, document = self.render(unit)

        self.assertEqual(path.name, "PTO-AVS-SCALAR-ADD-DECODE-001.asl")
        self.assertEqual(document.count("func main() => integer"), 1)
        self.assertIn('"source":"asl/scalar/alu/ADD.asl"', document)
        self.assertIn("DecodeScalarForm", document)
        self.assertIn("ScalarOperationOfForm(3) == ScalarOperation_ADD", document)
        self.assertIn("ScalarHandlerOfForm(3) == ScalarHandler_ScalarBinary", document)
        self.assertIn("DecodeScalarOperandRaw", document)

    def test_block_decode_test_checks_canonical_form_handler_and_schema_selector(
        self,
    ) -> None:
        unit = instruction_unit(
            "block",
            "B.IOR",
            {
                "encoding": [{"index": 0, "match": "0x00000013", "width_bits": 32}],
                "fields": [],
                "form_id": "b_ior_32_fixture",
                "length_bits": 32,
                "semantic_handler": "BindBundleScalarIO",
            },
        )

        path, document = self.render(unit)

        self.assertEqual(path.name, "PTO-AVS-BLOCK-B-IOR-DECODE-001.asl")
        self.assertIn("DecodeCommandForm", document)
        self.assertIn(
            "CommandOperationOfForm(3) == CommandOperation_b_ior_32_fixture", document
        )
        self.assertIn(
            "CommandHandlerOfForm(3) == CommandHandler_BindBundleScalarIO", document
        )
        self.assertIn("InstructionContractMatches_B_IOR", document)

    def test_block_decode_witness_satisfies_operand_constraints(self) -> None:
        unit = instruction_unit(
            "block",
            "B.IOT",
            {
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfc00707f",
                        "match": "0x00005013",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "TSize",
                        "width": 3,
                        "pieces": [{"instruction_lsb": 9, "value_lsb": 0, "width": 3}],
                    }
                ],
                "constraints": [
                    {"field": "TSize", "operator": "one-of", "values": [1, 2, 3]}
                ],
                "form_id": "b_iot_32_fixture",
                "length_bits": 32,
                "semantic_handler": "BindBundleTileIO",
            },
        )

        _, document = self.render(unit)

        self.assertIn(
            "0000000000000000000000000000000000000000000000000101001000010011", document
        )
        self.assertNotIn(
            "0000000000000000000000000000000000000000000000000101000000010011", document
        )

    def test_tile_static_test_checks_selector_classification_and_block_composition(
        self,
    ) -> None:
        unit = instruction_unit(
            "tile",
            "TLOAD",
            {
                "family": "TLSU",
                "selector": "0x000",
                "semantic_handler": "TLOAD",
                "operands": [{"field": "destination0", "role": "destination"}],
            },
        )

        path, document = self.render(unit)

        self.assertEqual(path.name, "PTO-AVS-TILE-TLOAD-STATIC-INVARIANT-001.asl")
        self.assertIn("DecodeTileOperation(TileDecode_TLSU", document)
        self.assertIn("TileOperationOfIndex(3) == TileOperation_TLOAD", document)
        self.assertIn("TileHandlerOfIndex(3) == TileHandler_TLOAD", document)
        self.assertIn("// classification: memory/regular", document)
        self.assertIn("// block: BSTART | B.IOT | BSTOP", document)

    def test_regeneration_is_byte_identical(self) -> None:
        unit = instruction_unit(
            "scalar",
            "ADD",
            {
                "encoding": [{"index": 0, "match": "0x00000005", "width_bits": 32}],
                "fields": [],
                "form_id": "add_32_fixture",
                "length_bits": 32,
                "semantic_family": "ALU",
                "semantic_handler": "ScalarBinary",
            },
        )

        self.assertEqual(self.render(unit), self.render(unit))

    def test_non_mnemonic_unit_gets_one_static_compile_owner(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "asl/arch/state/program-counter.asl"
            source.parent.mkdir(parents=True)
            source.write_text("constant TEST_PC = 0;\n", encoding="utf-8")
            concept = AslUnit(
                unit_id="PTO-ARCH-STATE-PROGRAM-COUNTER",
                surface="arch",
                classification=("state", "program-counter"),
                depends_on=(),
                source_path=Path("asl/arch/state/program-counter.asl"),
                mnemonic=None,
                line_count=1,
            )

            path, document = self.render_concept(root, concept)

        self.assertEqual(
            path.name,
            "PTO-AVS-ARCH-STATE-PROGRAM-COUNTER-STATIC-INVARIANT-001.asl",
        )
        self.assertIn('"source":"asl/arch/state/program-counter.asl"', document)
        self.assertIn('"kind":"static-invariant"', document)
        self.assertEqual(document.count("func main() => integer"), 1)


if __name__ == "__main__":
    unittest.main()
