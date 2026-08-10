from __future__ import annotations

import runpy
import unittest
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


if __name__ == "__main__":
    unittest.main()
