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
            any("unclassified layout delta" in error or "required Bias layout equality missing" in error for error in result["errors"])
        )

    def test_bias_conditional_relation_mutation_is_rejected_end_to_end(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        candidate["asl/tile/TMATMUL_BIAS.asl"] = candidate[
            "asl/tile/TMATMUL_BIAS.asl"
        ].replace("matching D and Local A when present", "matching D when present")
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(
            any("required Bias conditional-A relation missing" in error for error in result["errors"])
        )

    def test_inventory_unknown_role_is_rejected_end_to_end(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        candidate["asl/tile/TADD.asl"] = candidate["asl/tile/TADD.asl"].replace(
            '"source1","role":"source-right"', '"source9","role":"unknown-layout-role"'
        )
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(any("inventory changed" in error for error in result["errors"]))

    def test_inventory_missing_role_is_rejected_end_to_end(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        candidate["asl/tile/TADD.asl"] = candidate["asl/tile/TADD.asl"].replace(
            ',{"field":"source1","role":"source-right"}', ""
        )
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(any("inventory changed" in error for error in result["errors"]))

    def test_duplicate_authoritative_owner_is_rejected_end_to_end(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        candidate["asl/tile/TADD-duplicate.asl"] = candidate["asl/tile/TADD.asl"]
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(any("duplicate authoritative mnemonic owner" in error for error in result["errors"]))

    def test_real_candidate_records_gmov_and_bias_deltas_per_form(self) -> None:
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
        self.assertEqual({row["form"] for row in gmov}, {"direct", "bundle"})
        for row in gmov:
            self.assertEqual(set(row["L0"]), {"destination0", "source0"})
            self.assertEqual(set(row["L1"]), {"destination0", "source0"})
            self.assertEqual(set(row["L0"]["destination0"]), {"RowMajor"})
            self.assertEqual(set(row["L1"]["destination0"]), {"RowMajor", "CUBE_M16", "CUBE_M32"})
            self.assertEqual(set(row["L1"]["source0"]), {"RowMajor", "CUBE_M16", "CUBE_M32"})
            self.assertEqual(row["R0"], row["R1"])
            self.assertIn("destination0.layout == source0.layout", row["R1"])
            self.assertNotIn("scalar0", row["L1"])

        bias = [row for row in changed if row["mnemonic"] in BIAS]
        self.assertEqual(len(bias), 8)
        self.assertEqual({row["mnemonic"] for row in bias}, set(BIAS))
        for row in bias:
            bias_role = "source2" if row["mnemonic"] in {"TMATMUL_BIAS", "TGEMV_BIAS"} else "source4"
            self.assertEqual(set(row["L0"][bias_role]), {"RowMajor"})
            self.assertEqual(set(row["L1"][bias_role]), {"CUBE_M16", "CUBE_M32"})
            self.assertIn("Bias.layout == ML == D.layout", row["R1"])
            self.assertIn("Local A present => A.layout == ML", row["R1"])
            self.assertEqual(row["R0"], ["destination0.layout == source0.layout"])
            self.assertNotIn("primary", " ".join(row["L1"]).lower())

        relation_deltas = [row for row in result["delta"] if "relation" in row]
        self.assertEqual(len(relation_deltas), 16)
        self.assertTrue(all(row["classification"] != "UNCLASSIFIED" for row in relation_deltas))
        self.assertTrue(all(row["owner_decision"] != "none" for row in relation_deltas))
        self.assertTrue(all(row["classification"] != "UNCLASSIFIED" for row in result["delta"]))
        self.assertTrue(all(row["owner_decision"] != "none" for row in result["delta"]))
        self.assertEqual(
            {row["relation"] for row in relation_deltas},
            {"Bias.layout == ML == D.layout", "Local A present => A.layout == ML"},
        )

        expected = set(BIAS) | set(result["exact_34"]) | {"GMOV"}
        self.assertEqual({row["mnemonic"] for row in changed}, expected)
        self.assertEqual(len([row for row in changed if row["mnemonic"] in result["exact_34"]]), 68)
        self.assertEqual(len(gmov), 2)
        self.assertEqual(len(bias), 8)
        exact = [row for row in changed if row["mnemonic"] in result["exact_34"]]
        for row in exact:
            self.assertTrue(all(set(values) == {"RowMajor"} for values in row["L0"].values()))
            self.assertTrue(all(set(values) == {"RowMajor", "CUBE_M16", "CUBE_M32"} for values in row["L1"].values()))
            self.assertEqual(row["R0"], row["R1"])
            self.assertNotIn("scalar0", row["L1"])
        self.assertEqual(result["inventory"], sorted(result["inventory"], key=lambda row: (row["mnemonic"], row["form"], row["role"])))
        self.assertNotIn("operation", {row["role"] for row in result["inventory"]})
        bias_bundle = [row for row in result["inventory"] if row["mnemonic"] == "TMATMUL_BIAS" and row["form"] == "bundle"]
        self.assertTrue(bias_bundle)
        self.assertTrue(all(row["owner"] == "asl/block/execution/BSTART.TMATMUL.BIAS.asl" for row in bias_bundle))
        self.assertFalse(result["tile_location_normative_refs"])
        changed_keys = {(row["mnemonic"], row["form"]) for row in changed}
        for row in result["operation_signatures"]:
            key = (row["mnemonic"], row["form"])
            if row["mnemonic"] not in expected:
                self.assertEqual(row["L0"], row["L1"])
                self.assertEqual(row["R0"], row["R1"])
                self.assertNotIn(key, changed_keys)
