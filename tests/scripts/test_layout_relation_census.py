from __future__ import annotations

import unittest

from scripts.layout_relation_census import (
    BASELINE_OBJECT,
    BIAS,
    _complete_fixture_keys,
    _catalog_operand_rows,
    _census_texts,
    _fixture,
    _inventory,
    _load_baseline_fixture,
    _metadata_map,
    census,
    source_paths,
    _ref_texts,
)


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

    def test_bundle_owner_mutation_changes_only_bundle_signature(self) -> None:
        baseline = _fixture()
        baseline["asl/block/execution/BSTART.TMATMUL.BIAS.asl"] += (
            "// authoritative bundle layout contract: Local A and D use CUBE_M16 or CUBE_M32; "
            "Local B uses CUBE_N8.\n"
        )
        candidate = dict(baseline)
        candidate["asl/block/execution/BSTART.TMATMUL.BIAS.asl"] = candidate[
            "asl/block/execution/BSTART.TMATMUL.BIAS.asl"
        ].replace("CUBE_M32", "CUBE_M16")
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        direct = next(row for row in result["operation_signatures"]
                      if row["mnemonic"] == "TMATMUL_BIAS" and row["form"] == "direct")
        bundle = next(row for row in result["operation_signatures"]
                      if row["mnemonic"] == "TMATMUL_BIAS" and row["form"] == "bundle")
        self.assertEqual(direct["L0"], direct["L1"])
        self.assertNotEqual(bundle["L0"], bundle["L1"])

    def test_missing_bundle_owner_fails_closed(self) -> None:
        baseline = _fixture()
        candidate = dict(baseline)
        del candidate["asl/block/execution/BSTART.VEC.asl"]
        result = _census_texts(
            baseline, candidate, "fixture-baseline", "fixture-candidate", enforce_closure=False
        )
        self.assertFalse(result["pass"])
        self.assertTrue(any("bundle owner" in error or "bundle contract root" in error
                            for error in result["errors"]))

    def test_complete_baseline_fixture_has_exact_authoritative_keys(self) -> None:
        paths = source_paths(BASELINE_OBJECT, BASELINE_OBJECT)
        source_map = _ref_texts(BASELINE_OBJECT, paths)
        metadata, errors = _metadata_map(source_map)
        self.assertFalse(errors)
        inventory, errors = _inventory(metadata)
        self.assertFalse(errors)
        fixture, errors, payload = _load_baseline_fixture(inventory, BASELINE_OBJECT)
        self.assertIsNotNone(payload)
        self.assertFalse(errors)
        self.assertIsNotNone(fixture)
        raw_rows = _catalog_operand_rows(inventory)
        raw_keys = _complete_fixture_keys(inventory)
        self.assertEqual(len(raw_rows), len(set(raw_rows)))
        self.assertEqual(len(raw_keys), len(set(raw_keys)))
        self.assertEqual(len(raw_keys), 624)
        self.assertEqual(len(payload["inventory"]), len(raw_rows))
        self.assertEqual(
            {(row["mnemonic"], row["form"], row["role"]) for row in payload["inventory"]},
            set(raw_keys),
        )
        self.assertEqual(len(fixture or {}), 234)

        expected_roles = {
            ("TCMP", "destination0"): "predicate",
            ("TCMPS", "destination0"): "predicate",
            ("TSEL", "source0"): "predicate",
            ("TSELS", "source0"): "predicate",
            ("MGATHER", "source0"): "indices",
            ("MGATHER_MASK", "source0"): "indices",
            ("MGATHER_MASK", "source1"): "mask",
            ("MSCATTER", "source1"): "indices",
            ("MSCATTER_MASK", "source1"): "indices",
            ("MSCATTER_MASK", "source2"): "mask",
            ("TPERMUTE", "source2"): "indices",
            ("TCOLARGMIN", "destination0"): "index",
            ("TCOLARGMAX", "destination0"): "index",
            ("TROWARGMIN", "destination0"): "index",
            ("TROWARGMAX", "destination0"): "index",
        }
        for mnemonic, field in expected_roles:
            # Match by metadata mnemonic while retaining the exact catalog
            # role text as evidence for predicate/mask/index inclusion.
            owners = [
                operand["role"]
                for _path, meta in metadata
                if meta.get("mnemonic") == mnemonic
                for operand in meta["catalog_records"][0]["operands"]
                if isinstance(operand, dict) and operand.get("field") == field
            ]
            self.assertTrue(owners, (mnemonic, field))
            self.assertTrue(any(expected_roles[(mnemonic, field)] in role.lower() for role in owners),
                            (mnemonic, field, owners))

    def test_real_mgather_mask_relation_mutation_is_rejected(self) -> None:
        paths = source_paths(BASELINE_OBJECT, "working-tree")
        baseline = _ref_texts(BASELINE_OBJECT, paths)
        candidate = _ref_texts("working-tree", paths)
        path = "asl/tile/model/legality/memory-schema.asl"
        removed = "           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&\n"
        self.assertIn(removed, candidate[path])
        candidate[path] = candidate[path].replace(removed, "", 1)
        result = _census_texts(
            baseline, candidate, BASELINE_OBJECT, "real-mutated-mgather-mask",
            enforce_closure=False,
        )
        self.assertFalse(result["pass"])
        self.assertTrue(any("MGATHER_MASK" in error and "unclassified relation delta" in error
                            for error in result["errors"]), result["errors"])

    def test_real_tpermute_relation_mutation_is_rejected(self) -> None:
        paths = source_paths(BASELINE_OBJECT, "working-tree")
        baseline = _ref_texts(BASELINE_OBJECT, paths)
        candidate = _ref_texts("working-tree", paths)
        path = "asl/tile/model/legality/layout-rearrangement.asl"
        removed = "       destination_tile.layout != left.layout ||\n"
        self.assertIn(removed, candidate[path])
        candidate[path] = candidate[path].replace(removed, "", 1)
        result = _census_texts(
            baseline, candidate, BASELINE_OBJECT, "real-mutated-tpermute",
            enforce_closure=False,
        )
        self.assertFalse(result["pass"])
        self.assertTrue(any("TPERMUTE" in error and "unclassified relation delta" in error
                            for error in result["errors"]), result["errors"])

    def test_real_relation_spot_checks_are_unchanged(self) -> None:
        result = census(BASELINE_OBJECT, "working-tree")
        self.assertTrue(result["pass"], result["errors"])
        signatures = {(row["mnemonic"], row["form"]): row for row in result["operation_signatures"]}
        expected = {
            ("MGATHER_MASK", "destination0"): {
                "destination0.layout == source0.layout",
                "destination0.layout == source1.layout",
            },
            ("TPERMUTE", "destination0"): {
                "destination0.layout == source0.layout",
                "destination0.layout == source1.layout",
                "destination0.layout == source2.layout",
            },
            ("TSEL", "source0"): {"source0.layout == source1.layout"},
            ("TSELS", "source0"): {"source0.layout == source1.layout"},
            ("TCMP", "destination0"): {"destination0.layout == source0.layout"},
            ("TCMPS", "destination0"): {"destination0.layout == source0.layout"},
            ("TCOLARGMIN", "destination0"): {"destination0.layout == source0.layout"},
            ("TCOLARGMAX", "destination0"): {"destination0.layout == source0.layout"},
            ("TROWARGMIN", "destination0"): {"destination0.layout == source0.layout"},
            ("TROWARGMAX", "destination0"): {"destination0.layout == source0.layout"},
        }
        for (mnemonic, role), relations in expected.items():
            for form in ("direct", "bundle"):
                self.assertTrue(relations <= set(signatures[(mnemonic, form)]["R1"]),
                                (mnemonic, form, signatures[(mnemonic, form)]["R1"]))
                self.assertEqual(signatures[(mnemonic, form)]["R0"], signatures[(mnemonic, form)]["R1"])

    def test_real_receipt_has_no_empty_layout_bearing_sets_and_form_roots(self) -> None:
        result = census(BASELINE_OBJECT, "working-tree")
        self.assertTrue(result["pass"], result["errors"])
        for signature in result["operation_signatures"]:
            for side in ("L0", "L1"):
                self.assertTrue(all(values for values in signature[side].values()),
                                (signature["mnemonic"], signature["form"], side))
        rows = result["reachability"]["after"]["operation_reachability"]
        for mnemonic in ("TADD", "GMOV", "TMATMUL_BIAS"):
            direct = next(row for row in rows if row["mnemonic"] == mnemonic and row["form"] == "direct")
            bundle = next(row for row in rows if row["mnemonic"] == mnemonic and row["form"] == "bundle")
            self.assertNotEqual(direct["roots"], bundle["roots"])
            self.assertTrue(set(bundle["roots"]) > set(direct["roots"]))
            self.assertNotEqual(direct["owner"], bundle["owner"])

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
