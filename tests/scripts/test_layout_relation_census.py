from __future__ import annotations

import unittest

from scripts.layout_relation_census import _census_texts, _fixture


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
