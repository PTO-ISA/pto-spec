from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def function_body(path: str, name: str) -> str:
    text = (ROOT / path).read_text(encoding="utf-8")
    start = re.search(rf"^func\s+{re.escape(name)}\s*\(", text, re.MULTILINE)
    if start is None:
        raise AssertionError(f"missing {name} in {path}")
    following = re.search(r"^func\s+", text[start.end() :], re.MULTILINE)
    end = len(text) if following is None else start.end() + following.start()
    return text[start.start() : end]


class TileMemorySingleSnapshotTests(unittest.TestCase):
    def test_load_paths_decode_the_recorded_raw_value(self) -> None:
        load_store = function_body(
            "asl/tile/model/memory/load-store.asl", "TLOAD"
        )
        gather = function_body(
            "asl/tile/model/memory/gather-scatter.asl", "MGATHER"
        )
        masked = function_body(
            "asl/tile/model/memory/gather-scatter.asl", "MGATHER_MASK"
        )
        compare_swap = function_body(
            "asl/tile/model/memory/atomics.asl", "MGATHER_CAS"
        )

        for name, body in (
            ("TLOAD", load_store),
            ("MGATHER", gather),
            ("MGATHER_MASK", masked),
            ("MGATHER_CAS", compare_swap),
        ):
            with self.subTest(name=name):
                self.assertNotIn("LoadTileMemoryElement(", body)
                self.assertIn("DecodeTileMemoryElementRaw(", body)


if __name__ == "__main__":
    unittest.main()
