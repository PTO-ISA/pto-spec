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
    def bridge_matrix(self, tile_catalog=None):
        catalog = tile_catalog or GENERATOR["load_json"](GENERATOR["TILE_CATALOG"])
        return GENERATOR["build_bridge_matrix"](catalog["operations"])

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
                self.bridge_matrix()

    def test_representability_rejects_more_than_three_gpr_inputs(self) -> None:
        tile_catalog = GENERATOR["load_json"](GENERATOR["TILE_CATALOG"])
        synthetic = deepcopy(tile_catalog["operations"][0])
        synthetic["name"] = "SYNTHETIC_FOUR_GPR"
        synthetic["operands"] = [
            {"field": field, "role": field}
            for field in ("address", "scalar0", "scalar1", "flag0")
        ]
        tile_catalog["operations"].append(synthetic)

        with self.assertRaisesRegex(ValueError, "more than three GPR inputs"):
            self.bridge_matrix(tile_catalog)

    def test_representability_rejects_duplicate_gpr_fields(self) -> None:
        tile_catalog = GENERATOR["load_json"](GENERATOR["TILE_CATALOG"])
        synthetic = deepcopy(tile_catalog["operations"][0])
        synthetic["name"] = "SYNTHETIC_DUPLICATE_FLAG0"
        synthetic["operands"] = [
            {"field": "flag0", "role": "descending"},
            {"field": "flag0", "role": "descending-alias"},
        ]
        tile_catalog["operations"].append(synthetic)

        with self.assertRaisesRegex(ValueError, "duplicate GPR operand fields"):
            self.bridge_matrix(tile_catalog)

    def test_representability_rejects_unknown_operand_field(self) -> None:
        original_load_json = GENERATOR["load_json"]
        tile_catalog = original_load_json(GENERATOR["TILE_CATALOG"])
        synthetic = deepcopy(tile_catalog["operations"][0])
        synthetic["name"] = "SYNTHETIC_UNKNOWN_FIELD"
        synthetic["operands"] = [{"field": "not_a_real_operand", "role": "source"}]
        tile_catalog["operations"].append(synthetic)

        def load_json(path):
            if path == GENERATOR["TILE_CATALOG"]:
                return tile_catalog
            return original_load_json(path)

        with patch.dict(GENERATOR["build_evidence"].__globals__, {"load_json": load_json}):
            with self.assertRaisesRegex(ValueError, "unknown bridge operand fields"):
                GENERATOR["build_evidence"]()

    def test_conditional_matrix_schema_is_dense_and_bounded(self) -> None:
        resolutions = GENERATOR["conditional_gpr_resolutions"](
            ["scalar_lrelu_param", "scalar_quant_param"]
        )
        self.assertEqual(
            [(row["field"], row["slot"]) for row in resolutions],
            [("scalar_quant_param", "RegSrc0"), ("scalar_lrelu_param", "RegSrc1")],
        )
        schema = GENERATOR["conditional_local_schema"](
            ["source0", "source1", "source2", "source3", "source4"]
        )
        self.assertEqual(schema["source_capacity"], 8)
        self.assertEqual(schema["destination_capacity"], 3)
        with self.assertRaisesRegex(ValueError, "duplicate conditional GPR fields"):
            GENERATOR["conditional_gpr_resolutions"](
                ["scalar_quant_param", "scalar_quant_param"]
            )

    def test_real_operations_record_architectural_gpr_slots(self) -> None:
        rows = {
            row["operation"]: row
            for row in self.bridge_matrix()
        }
        self.assertEqual(
            rows["TCI"]["gpr_input_slots"], {"scalar0": "RegSrc0", "flag0": "RegSrc1"}
        )
        self.assertEqual(
            rows["TTRI"]["gpr_input_slots"], {"diagonal": "RegSrc0", "flag0": "RegSrc1"}
        )


if __name__ == "__main__":
    unittest.main()
