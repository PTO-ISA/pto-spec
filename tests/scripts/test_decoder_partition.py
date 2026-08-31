from __future__ import annotations

import subprocess
import unittest
from pathlib import Path

from scripts.asl_validation_shards import (
    partition_generated_asl,
    render_validation_shard,
    validation_index,
)


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "scripts/generate-asl-decoders"


class DecoderPartitionTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        completed = subprocess.run(
            [str(GENERATOR), "--kind", "decoder"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        if completed.returncode != 0:
            raise AssertionError(
                "decoder-only generation failed:\n"
                + completed.stdout[-4000:]
                + completed.stderr[-4000:]
            )
        cls.decoder = completed.stdout

    def test_decoder_only_output_preserves_complete_identity_counts(self) -> None:
        self.assertIn("constant PTO_SCALAR_FORM_COUNT = 466;", self.decoder)
        self.assertIn("constant PTO_COMMAND_FORM_COUNT = 76;", self.decoder)
        self.assertIn("constant PTO_TILE_OPERATION_COUNT = 108;", self.decoder)
        self.assertIn("pure func DecodeScalarForm", self.decoder)
        self.assertIn("pure func DecodeCommandForm", self.decoder)
        self.assertIn("pure func DecodeTileOperation", self.decoder)

    def test_decoder_only_output_contains_no_validation_witness_bodies(self) -> None:
        forbidden = (
            "func Validate",
            "Totality()",
            "Aliases()",
            "CatalogDecode()",
        )
        for marker in forbidden:
            with self.subTest(marker=marker):
                self.assertFalse(
                    marker in self.decoder,
                    f"decoder-only output contains validation marker {marker!r}",
                )

    def test_partition_preserves_validation_call_closure(self) -> None:
        generated = """// generated
constant PTO_FORM_COUNT = 1;

pure func DecodeForm(value: bits(1)) => integer
begin
    return 0;
end;

func ValidateLeaf()
begin
    assert DecodeForm('0') == 0;
end;

func ValidateRoot()
begin
    ValidateLeaf();
end;
"""

        partitioned = partition_generated_asl(generated)
        shard = render_validation_shard(partitioned, "ValidateRoot")

        self.assertIn("pure func DecodeForm", partitioned.decoder)
        self.assertNotIn("func Validate", partitioned.decoder)
        self.assertIn("func ValidateLeaf", shard)
        self.assertIn("func ValidateRoot", shard)
        self.assertLess(
            shard.index("func ValidateLeaf"), shard.index("func ValidateRoot")
        )

    def test_partition_rejects_unknown_validation_entrypoint(self) -> None:
        partitioned = partition_generated_asl(
            """func ValidateKnown()
begin
end;
"""
        )

        with self.assertRaisesRegex(ValueError, "unknown validation entrypoint"):
            render_validation_shard(partitioned, "ValidateMissing")

    def test_validation_index_records_exact_function_hashes(self) -> None:
        partitioned = partition_generated_asl(
            """func ValidateKnown()
begin
end;
"""
        )

        index = validation_index(partitioned)

        self.assertIn('"name": "ValidateKnown"', index)
        self.assertIn('"dependencies": []', index)

    def test_scalar_bru_validation_uses_current_barg_state(self) -> None:
        shards = {}
        for entrypoint in ("ValidateScalarBRUAlias_JR",):
            completed = subprocess.run(
                [
                    str(GENERATOR),
                    "--kind",
                    "validation-shard",
                    "--entrypoint",
                    entrypoint,
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr[-4000:])
            shards[entrypoint] = completed.stdout

        combined = "\n".join(shards.values())
        for retired in (
            "_BundleTarget",
            "_BundleFallthrough",
            "_BundleReturnTarget",
            ".bundle_target",
            ".bundle_fallthrough",
            ".bundle_return_target",
        ):
            self.assertNotIn(retired, combined)
        self.assertIn(
            "_TrapContexts[[0]].barg.bpcn",
            shards["ValidateScalarBRUAlias_JR"],
        )

    def test_histogram_owns_consumed_filter_definedness(self) -> None:
        case_start = self.decoder.index("when TileOperation_THISTOGRAM =>")
        case_end = self.decoder.index(
            "\n        when ",
            case_start + len("when TileOperation_THISTOGRAM =>"),
        )
        histogram_case = self.decoder[case_start:case_end]

        self.assertNotIn(
            "TileSourceContentsDefined(operands.source1)",
            histogram_case,
        )
        self.assertIn(
            "TileOperandsLegal_THISTOGRAM(",
            histogram_case,
        )

    def test_timg2col_owns_referenced_source_definedness(self) -> None:
        case_start = self.decoder.index("when TileOperation_TIMG2COL =>")
        case_end = self.decoder.index(
            "\n        when ",
            case_start + len("when TileOperation_TIMG2COL =>"),
        )
        image_to_column_case = self.decoder[case_start:case_end]

        self.assertNotIn(
            "TileSourceContentsDefined(operands.source0)",
            image_to_column_case,
        )
        self.assertIn(
            "TileOperandsLegal_TIMG2COL(",
            image_to_column_case,
        )

    def test_matrix_legality_owns_cube_source_definedness(self) -> None:
        operations = (
            "TGEMV",
            "TGEMV_ACC",
            "TGEMV_BIAS",
            "TGEMV_MX",
            "TGEMV_MX_ACC",
            "TGEMV_MX_BIAS",
            "TMATMUL",
            "TMATMUL_ACC",
            "TMATMUL_BIAS",
            "TMATMUL_MX",
            "TMATMUL_MX_ACC",
            "TMATMUL_MX_BIAS",
        )
        for operation in operations:
            with self.subTest(operation=operation):
                marker = f"when TileOperation_{operation} =>"
                case_start = self.decoder.index(marker)
                case_end = self.decoder.find(
                    "\n        when ",
                    case_start + len(marker),
                )
                if case_end == -1:
                    case_end = self.decoder.index(
                        "\n    end;",
                        case_start + len(marker),
                    )
                matrix_case = self.decoder[case_start:case_end]
                self.assertNotIn("TileSourceContentsDefined(", matrix_case)
                self.assertIn(
                    f"TileOperandsLegal_{operation}(",
                    matrix_case,
                )


if __name__ == "__main__":
    unittest.main()
