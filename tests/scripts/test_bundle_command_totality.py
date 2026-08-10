from __future__ import annotations

import runpy
import unittest
from copy import deepcopy
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-bundle-command-totality"),
    run_name="pto_generate_bundle_command_totality_test",
)


class BundleCommandTotalityTest(unittest.TestCase):
    def test_representability_fails_closed_for_incomplete_operand_policy(self) -> None:
        # Negative fixture: an accepted control loses its raw-value policy.
        # The evidence generator must reject the catalog rather than report
        # representability from field-name membership alone.
        resolvers = GENERATOR["BRIDGE_RESOLVERS"]
        incomplete = dict(resolvers["flag0"])
        incomplete.pop("raw_value_policy")
        with patch.dict(resolvers, {"flag0": incomplete}):
            with self.assertRaisesRegex(
                ValueError, "missing concrete bridge resolver/default for operand flag0"
            ):
                GENERATOR["build_evidence"]()

    def test_representability_rejects_more_than_three_gpr_inputs(self) -> None:
        original_load_json = GENERATOR["load_json"]
        tile_catalog = original_load_json(GENERATOR["TILE_CATALOG"])
        synthetic = deepcopy(tile_catalog["operations"][0])
        synthetic["name"] = "SYNTHETIC_FOUR_GPR"
        synthetic["operands"] = [
            {"field": field, "role": field}
            for field in ("address", "scalar0", "scalar1", "flag0")
        ]
        tile_catalog["operations"].append(synthetic)

        def load_json(path):
            if path == GENERATOR["TILE_CATALOG"]:
                return tile_catalog
            return original_load_json(path)

        with patch.dict(GENERATOR["build_evidence"].__globals__, {"load_json": load_json}):
            with self.assertRaisesRegex(ValueError, "more than three GPR inputs"):
                GENERATOR["build_evidence"]()

    def test_representability_rejects_duplicate_gpr_fields(self) -> None:
        original_load_json = GENERATOR["load_json"]
        tile_catalog = original_load_json(GENERATOR["TILE_CATALOG"])
        synthetic = deepcopy(tile_catalog["operations"][0])
        synthetic["name"] = "SYNTHETIC_DUPLICATE_FLAG0"
        synthetic["operands"] = [
            {"field": "flag0", "role": "descending"},
            {"field": "flag0", "role": "descending-alias"},
        ]
        tile_catalog["operations"].append(synthetic)

        def load_json(path):
            if path == GENERATOR["TILE_CATALOG"]:
                return tile_catalog
            return original_load_json(path)

        with patch.dict(GENERATOR["build_evidence"].__globals__, {"load_json": load_json}):
            with self.assertRaisesRegex(ValueError, "duplicate GPR operand fields"):
                GENERATOR["build_evidence"]()

    def test_real_operations_record_architectural_gpr_slots(self) -> None:
        evidence = GENERATOR["build_evidence"]()
        rows = {
            row["operation"]: row
            for row in evidence["bundle_tile_bridge"]["operation_matrix"]
        }
        self.assertEqual(
            rows["TCI"]["gpr_input_slots"], {"scalar0": "RegSrc0", "flag0": "RegSrc1"}
        )
        self.assertEqual(
            rows["TTRI"]["gpr_input_slots"], {"diagonal": "RegSrc0", "flag0": "RegSrc1"}
        )
        self.assertEqual(rows["TSORT"]["gpr_input_slots"], {"flag0": "RegSrc0"})
        self.assertEqual(
            rows["TMRGSORT"]["gpr_input_slots"], {"flag0": "RegSrc0"}
        )


if __name__ == "__main__":
    unittest.main()
