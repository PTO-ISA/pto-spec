from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def function_body(path: str, name: str) -> str:
    text = (ROOT / path).read_text(encoding="utf-8")
    function = r"(?:(?:pure|readonly)\s+)*func\s+"
    start = re.search(
        rf"^{function}{re.escape(name)}\s*\(", text, re.MULTILINE
    )
    if start is None:
        raise AssertionError(f"missing {name} in {path}")
    following = re.search(rf"^{function}", text[start.end() :], re.MULTILINE)
    end = len(text) if following is None else start.end() + following.start()
    return text[start.start() : end]


class TileMemorySingleSnapshotTests(unittest.TestCase):
    def test_load_wrappers_reuse_one_raw_value_for_events_and_decode(self) -> None:
        cases = (
            (
                "TLOAD",
                "asl/tile/model/memory/load-store.asl",
                "asl/tile/model/memory/load-store.asl",
                "TLOADToValue",
                "raw",
                1,
                "RecordTileLoadEvent(",
            ),
            (
                "MGATHER",
                "asl/tile/model/memory/gather-scatter.asl",
                "asl/tile/model/memory/gather-scatter-values.asl",
                "MGATHERToValue",
                "raw",
                2,
                "RecordIndexedLoadEvent(",
            ),
            (
                "MGATHER_MASK",
                "asl/tile/model/memory/gather-scatter.asl",
                "asl/tile/model/memory/gather-scatter-values.asl",
                "MGATHER_MASKToValue",
                "raw",
                2,
                "RecordIndexedLoadEvent(",
            ),
            (
                "MGATHER_CAS",
                "asl/tile/model/memory/atomics.asl",
                "asl/tile/model/memory/atomics.asl",
                "MGATHER_CASToValue",
                "old_raw",
                1,
                "RecordIndexedAtomicEvent(",
            ),
        )

        for (
            name,
            wrapper_path,
            helper_path,
            helper_name,
            raw_name,
            decode_count,
            event,
        ) in cases:
            with self.subTest(name=name):
                wrapper = function_body(wrapper_path, name)
                helper = function_body(helper_path, helper_name)
                self.assertIn(f"{helper_name}(", wrapper)
                self.assertNotIn("LoadTileMemoryElement(", wrapper)
                self.assertNotIn("LoadTileMemoryElement(", helper)
                self.assertIn(f"let {raw_name} = LoadTranslatedUnsigned(", helper)
                self.assertEqual(
                    helper.count(f"let {raw_name} = LoadTranslatedUnsigned("), 1
                )
                self.assertIn(event, helper)
                event_start = helper.index(event)
                event_end = helper.index(");", event_start)
                self.assertIn(raw_name, helper[event_start:event_end])
                self.assertEqual(
                    helper.count("DecodeTileMemoryElementRaw("), decode_count
                )
                self.assertRegex(
                    helper,
                    rf"DecodeTileMemoryElementRaw\(\s*{raw_name}\s*,",
                )

    def test_shared_raw_decoder_keeps_packed_and_full_width_paths(self) -> None:
        decoder = function_body(
            "asl/tile/model/memory/load-store.asl",
            "DecodeTileMemoryElementRaw",
        )
        self.assertIn("TileDataTypeIsFourBit(data_type)", decoder)
        self.assertIn("raw[7:4]", decoder)
        self.assertIn("raw[3:0]", decoder)
        self.assertIn("TileMemoryElementBytes(data_type)", decoder)
        self.assertIn(
            "NormalizeLoadedValue(raw, element_bytes,", decoder
        )
        self.assertIn("TileDataTypeIsSigned(data_type)", decoder)


if __name__ == "__main__":
    unittest.main()
