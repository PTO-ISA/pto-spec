from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class HardwareNumericProfileTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.profile = json.loads(
            (ROOT / "spec/hardware-conformance-profile.json").read_text(
                encoding="utf-8"
            )
        )

    def test_matrix_profile_matches_accepted_ordinary_and_mx_types(self) -> None:
        matrix = self.profile["matrix"]
        self.assertNotIn("ordinary_type_table", matrix)
        self.assertEqual(
            matrix["ordinary"]["floating_input_types"],
            [
                "FP32",
                "TF32",
                "HF32",
                "FP16",
                "BF16",
                "HiF8",
                "E4M3",
                "E5M2",
                "E3M2",
                "E2M3",
                "E2M1X2",
                "E1M2X2",
            ],
        )
        self.assertEqual(
            matrix["ordinary"]["accumulator_by_class"],
            {"floating": "FP32", "signed": "S32", "unsigned": "U32"},
        )
        self.assertEqual(
            matrix["mx"]["allowed_operand_types"],
            ["FP16", "BF16", "E4M3", "E5M2", "E2M1X2", "E1M2X2"],
        )
        self.assertNotIn("HiF4X2", matrix["mx"]["allowed_operand_types"])
        self.assertNotIn("allowed_operand_pairs", matrix["mx"])

    def test_b_fpatr_profile_and_asl_have_no_identity_fallback(self) -> None:
        postprocess = self.profile["matrix"]["postprocess"]
        self.assertEqual(
            [row["code"] for row in postprocess["modes"]],
            [
                0,
                1,
                2,
                3,
                4,
                5,
                12,
                13,
                16,
                17,
                18,
                19,
                20,
                23,
                24,
                25,
                26,
                27,
                28,
                32,
                33,
                34,
                35,
                36,
                37,
                38,
                39,
            ],
        )
        implementation = (
            ROOT / "asl/arch/profile/matrix-postprocess.asl"
        ).read_text(encoding="utf-8")
        body = implementation.split(
            "implementation func TileProfileMatrixPostProcessWithFlags", 1
        )[1].split(
            "implementation func TileProfileMatrixPostProcess(", 1
        )[0]
        self.assertIn("MatrixPostQuantBaseWithFlags", body)
        self.assertIn("MatrixActivationWithFlags", body)
        self.assertNotIn("return (value, Zeros{5});", body)

    def test_current_release_owns_the_current_numeric_profile(self) -> None:
        self.assertEqual(self.profile["isa_release"], "0.58.2")
        self.assertEqual(
            self.profile["profile_id"],
            "pto-hardware-numeric-0.58.2-ieee-v1",
        )
        generator = (ROOT / "scripts/generate-release-manifest").read_text(
            encoding="utf-8"
        )
        self.assertIn(
            'NUMERIC_PROFILE_ID = "pto-hardware-numeric-0.58.2-ieee-v1"',
            generator,
        )
        self.assertIn('NUMERIC_PROFILE_RELEASE = "0.58.2"', generator)


if __name__ == "__main__":
    unittest.main()
