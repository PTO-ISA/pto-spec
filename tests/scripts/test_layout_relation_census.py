from __future__ import annotations

import unittest

from scripts.layout_relation_census import BIAS, census, _census_texts, _fixture


class LayoutRelationCensusTest(unittest.TestCase):
    def test_common_helper_layout_mutation_is_rejected_end_to_end(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        candidate["asl/tile/model/legality/common.asl"] = candidate[
            "asl/tile/model/legality/common.asl"
        ].replace(
            "TileLayout_CUBE_M32;",
            "TileLayout_CUBE_M32 || layout == TileLayout_CUBE_N8;",
        )
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(
            any("unauthorized common-helper layout change" in error for error in result["errors"])
        )

    def test_bias_cross_role_equality_mutation_is_rejected_end_to_end(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        candidate["asl/tile/model/legality/matrix.asl"] = candidate[
            "asl/tile/model/legality/matrix.asl"
        ].replace("_Tiles[[bias]].layout == _Tiles[[left]].layout", "TRUE")
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(
            any("required Bias layout equality missing" in error for error in result["errors"])
        )

    def test_real_candidate_records_gmov_and_bias_deltas_per_owner(self) -> None:
        result = census("ef2d23cdee03e74057099dc69943e8b909809ce0", "HEAD")
        self.assertTrue(result["pass"], result["errors"])
        self.assertRegex(result["candidate_head"], r"^[0-9a-f]{40}$")
        self.assertEqual(result["candidate_identity"], "immutable-asl-tree")
        self.assertEqual(
            result["original_durable_provenance"],
            "fbdfc56bef714a98a080461d926d54dcfbaf851e",
        )
        self.assertEqual(
            result["candidate_only_authorized_against"],
            "ef2d23cdee03e74057099dc69943e8b909809ce0",
        )
        changed = result["changed_records"]
        gmov = [row for row in changed if row["mnemonic"] == "GMOV"]
        self.assertEqual(len(gmov), 1)
        self.assertEqual(
            {layout for layouts in gmov[0]["L0"].values() for layout in layouts},
            {"RowMajor"},
        )
        self.assertEqual(
            {layout for layouts in gmov[0]["L1"].values() for layout in layouts},
            {"RowMajor", "CUBE_M16", "CUBE_M32"},
        )

        bias = [row for row in changed if row["mnemonic"] in BIAS]
        self.assertEqual(len(bias), 8)
        self.assertEqual({row["mnemonic"] for row in bias}, set(BIAS))
        for row in bias:
            self.assertEqual(
                {layout for layouts in row["L0"].values() for layout in layouts},
                {"RowMajor"},
            )
            self.assertEqual(
                {layout for layouts in row["L1"].values() for layout in layouts},
                {"CUBE_M16", "CUBE_M32"},
            )
            self.assertEqual(row["R0"], [])
            self.assertEqual(row["R1"], ["Bias.layout == ML == D.layout"])

        expected = set(BIAS) | set(result["exact_34"]) | {"GMOV"}
        self.assertTrue({row["mnemonic"] for row in changed} <= expected)
