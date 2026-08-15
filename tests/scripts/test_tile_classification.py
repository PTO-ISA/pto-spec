from __future__ import annotations

import json
import subprocess
import unittest
from collections import Counter

from scripts.instruction_docs import ROOT, load_instruction_index


EXPECTED_CLASSES = {
    "elementwise-tile-tile": "TABS TADD TAND TCMP TCVT TDIV TEXP TFMA TLOG TMAX TMIN TMUL TNEG TNOT TOR TRECIP TRELU TREM TRSQRT TSEL TSHL TSHR TSQRT TSUB TXOR",
    "tile-scalar-and-immediate": "TADDS TANDS TCMPS TDIVS TEXPANDS TMAXS TMINS TMULS TORS TREMS TSELS TSHLS TSHRS TSUBS TXORS",
    "reduce-and-expand": "TCOLARGMAX TCOLARGMIN TCOLEXPAND TCOLEXPANDADD TCOLEXPANDDIV TCOLEXPANDEXPDIF TCOLEXPANDMAX TCOLEXPANDMIN TCOLEXPANDMUL TCOLEXPANDSUB TCOLMAX TCOLMIN TCOLPROD TCOLSUM TROWARGMAX TROWARGMIN TROWEXPAND TROWEXPANDADD TROWEXPANDDIV TROWEXPANDEXPDIF TROWEXPANDMAX TROWEXPANDMIN TROWEXPANDMUL TROWEXPANDSUB TROWMAX TROWMIN TROWPROD TROWSUM",
    "memory-and-data-movement": "GMOV MGATHER MGATHER_CAS MGATHER_MASK MSCATTER MSCATTER_MASK TLOAD TPREFETCH TSTORE",
    "matrix-and-matrix-vector": "TGEMV TGEMV_ACC TGEMV_BIAS TGEMV_MX TGEMV_MX_ACC TGEMV_MX_BIAS TMATMUL TMATMUL_ACC TMATMUL_BIAS TMATMUL_MX TMATMUL_MX_ACC TMATMUL_MX_BIAS",
    "layout-and-rearrangement": "TCONCAT TEXTRACT TFILLPAD TIMG2COL TINSERT TMOV TTRANS",
    "irregular-and-complex": "TCI TDEQUANT TGATHER THISTOGRAM TMRGSORT TPARTADD TPARTMAX TPARTMIN TPARTMUL TQUANT TSCATTER TSORT TTRI",
}

EXPECTED_CLASSES = {
    classification: frozenset(mnemonics.split())
    for classification, mnemonics in EXPECTED_CLASSES.items()
}

SFU_ELEMENTWISE = frozenset(
    {"TDIV", "TEXP", "TLOG", "TRECIP", "TREM", "TRSQRT", "TSQRT"}
)

EXPECTED_VEC = frozenset(
    "TABS TADD TADDS TAND TANDS TCMP TCMPS TCVT TEXPANDS TFMA "
    "TMAX TMAXS TMIN TMINS TMUL TMULS TNEG TNOT TOR TORS TRELU "
    "TSEL TSELS TSHL TSHLS TSHR TSHRS TSUB TSUBS TXOR TXORS".split()
)


class TileClassificationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.tile = [
            record
            for record in load_instruction_index(ROOT)
            if record.surface == "tile"
        ]

    def test_exact_pto_instruction_class_map(self) -> None:
        actual: dict[str, set[str]] = {}
        for record in self.tile:
            actual.setdefault(record.classification[0], set()).add(record.mnemonic)

        self.assertEqual(actual, EXPECTED_CLASSES)
        self.assertEqual(
            Counter(record.classification[0] for record in self.tile),
            {
                "elementwise-tile-tile": 25,
                "tile-scalar-and-immediate": 15,
                "reduce-and-expand": 28,
                "memory-and-data-movement": 9,
                "matrix-and-matrix-vector": 12,
                "layout-and-rearrangement": 7,
                "irregular-and-complex": 13,
            },
        )

    def test_engine_is_orthogonal_and_vec_is_elementwise_only(self) -> None:
        by_engine: Counter[str] = Counter()
        for record in self.tile:
            engine = record.engine
            self.assertIn(engine, {"VEC", "TLSU", "CUBE", "SFU"})
            by_engine[engine] += 1
            if engine == "VEC":
                self.assertIn(
                    record.classification[0],
                    {"elementwise-tile-tile", "tile-scalar-and-immediate"},
                )
            if record.mnemonic in SFU_ELEMENTWISE:
                self.assertEqual(engine, "SFU")

        self.assertEqual(by_engine, {"VEC": 31, "SFU": 56, "TLSU": 10, "CUBE": 12})

        actual_vec = {record.mnemonic for record in self.tile if record.engine == "VEC"}
        self.assertEqual(actual_vec, EXPECTED_VEC)
        tepl = {
            record.mnemonic
            for record in self.tile
            if record.catalog_records[0]["family"] == "TEPL"
        }
        actual_sfu = {record.mnemonic for record in self.tile if record.engine == "SFU"}
        self.assertEqual(actual_sfu, tepl - EXPECTED_VEC)

    def test_catalog_projection_carries_class_and_engine(self) -> None:
        catalog = json.loads(
            (ROOT / "spec/catalog/tile-operations.json").read_text(encoding="utf-8")
        )
        for operation in catalog["operations"]:
            self.assertEqual(operation["classification"], next(
                record.classification[0]
                for record in self.tile
                if record.mnemonic == operation["name"]
            ))
            self.assertEqual(operation["engine"], next(
                record.engine
                for record in self.tile
                if record.mnemonic == operation["name"]
            ))

    def test_tepl_carrier_aliases_preserve_encoding_and_canonicalize(self) -> None:
        block_records = {
            record.mnemonic: record
            for record in load_instruction_index(ROOT)
            if record.surface == "block"
        }
        command = block_records["BSTART.TEPL"]
        form = command.catalog_records[0]

        self.assertEqual(form["encoding"][0]["mask"], "0x000fffff")
        self.assertEqual(form["encoding"][0]["match"], "0x00019181")
        self.assertEqual(
            form["accepted_assembly_mnemonics"],
            ["BSTART.TEPL", "BSTART.VEC", "BSTART.SFU"],
        )
        self.assertEqual(
            form["canonical_assembly_by_engine"],
            {"VEC": "BSTART.VEC", "SFU": "BSTART.SFU"},
        )
        self.assertNotEqual(form["canonical_assembly_by_engine"]["VEC"], "BSTART.TEPL")
        self.assertNotEqual(form["canonical_assembly_by_engine"]["SFU"], "BSTART.TEPL")

        for mnemonic, engine in (("BSTART.VEC", "VEC"), ("BSTART.SFU", "SFU")):
            with self.subTest(mnemonic=mnemonic):
                alias = block_records[mnemonic]
                self.assertEqual(alias.alias_of, "BSTART.TEPL")
                self.assertEqual(alias.alias_engine, engine)
                self.assertEqual(alias.catalog_records, ())
                self.assertEqual(alias.display_catalog_records, command.catalog_records)
                self.assertTrue((ROOT / alias.markdown_path).is_file())
                rendered = (ROOT / alias.markdown_path).read_text(encoding="utf-8")
                self.assertIn("**Encoding owner:** `BSTART.TEPL`", rendered)
                self.assertIn(f"**Canonical engine:** `{engine}`", rendered)
                avs = (
                    ROOT
                    / "tests/asl/block/execution"
                    / mnemonic
                    / (
                        "block-decode-"
                        + mnemonic.lower().replace(".", "-")
                        + "-canonical-001.asl"
                    )
                )
                self.assertTrue(avs.is_file())
                self.assertIn(
                    f"InstructionContractAliasEngine_{mnemonic.replace('.', '_')}()",
                    avs.read_text(encoding="utf-8"),
                )

    def test_legacy_tile_classification_paths_are_absent(self) -> None:
        old = {
            "tile-tile-elementwise",
            "unary-tile-elementwise",
            "tile-scalar-elementwise",
            "reduction",
            "vector-tile-expansion",
            "matrix",
            "memory",
            "complex-layout",
        }
        active = {path.name for path in (ROOT / "asl/tile").iterdir() if path.is_dir()}
        self.assertTrue(old.isdisjoint(active))
        dispatch = ROOT / "asl/tile/model/dispatch"
        self.assertTrue(
            {
                "complex-layout.asl",
                "matrix.asl",
                "memory.asl",
                "reduction.asl",
                "tile-scalar-elementwise.asl",
                "tile-tile-elementwise.asl",
                "unary-tile-elementwise.asl",
                "vector-tile-expansion.asl",
            }.isdisjoint(path.name for path in dispatch.glob("*.asl"))
        )

    def test_active_tools_use_tlsu_terminology(self) -> None:
        comparison = (ROOT / "scripts/generate-executable-model-comparison").read_text(
            encoding="utf-8"
        )
        self.assertNotIn("engine_tma", comparison)
        self.assertNotIn("tma-and-cube-manifest-boundary", comparison)
        self.assertFalse((ROOT / "scripts/generate-instruction-reference").exists())

    def test_instruction_pages_label_tepl_as_an_encoding_carrier(self) -> None:
        vec_page = (
            ROOT / "docs/tile/elementwise-tile-tile/arithmetic/TADD.md"
        ).read_text(encoding="utf-8")
        self.assertIn("| Operation | Encoding carrier |", vec_page)
        self.assertNotIn("| Operation | Family |", vec_page)

    def test_decoder_validation_binds_engine_specific_alias_contracts(self) -> None:
        generated = subprocess.run(
            [
                str(ROOT / "scripts/generate-asl-decoders"),
                "--kind",
                "validation-shard",
                "--entrypoint",
                "ValidateCanonicalDecoders",
            ],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            check=True,
        ).stdout

        self.assertIn(
            "InstructionContractAcceptsTileOperation_BSTART_TEPL", generated
        )
        self.assertIn(
            "InstructionContractAcceptsTileOperation_BSTART_VEC", generated
        )
        self.assertIn(
            "InstructionContractAcceptsTileOperation_BSTART_SFU", generated
        )


if __name__ == "__main__":
    unittest.main()
