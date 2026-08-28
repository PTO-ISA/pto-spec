from __future__ import annotations

import runpy
import unittest
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = runpy.run_path(
    str(ROOT / "scripts/generate-public-source-reconciliation"),
    run_name="pto_generate_public_source_reconciliation_test",
)


class PublicSourceReconciliationTests(unittest.TestCase):
    def test_public_tile_symbols_have_one_exact_disposition(self) -> None:
        artifact = GENERATOR["generate"]()
        inventory = artifact["public_tile_symbol_inventory"]
        self.assertEqual(inventory["partition_status"], "closed-exact")
        self.assertEqual(
            inventory["active_mapping_count"]
            + inventory["excluded_disposition_count"],
            inventory["count"],
        )

    def test_unaccounted_public_tile_symbol_fails_closed(self) -> None:
        symbols = set(GENERATOR["PUBLIC_TILE_SYMBOLS"])
        symbols.add("SYNTHETIC_UNACCOUNTED_PUBLIC_SYMBOL")
        with patch.dict(
            GENERATOR["generate"].__globals__,
            {"PUBLIC_TILE_SYMBOLS": symbols},
        ):
            with self.assertRaisesRegex(ValueError, "partition is not exact"):
                GENERATOR["generate"]()


if __name__ == "__main__":
    unittest.main()
