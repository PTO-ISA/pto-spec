from __future__ import annotations

import json
import os
import re
import subprocess
import unittest
from pathlib import Path

from scripts.asl_units import INSTRUCTION_PREFIX, _symbols_from_text


REPO = Path(__file__).resolve().parents[2]

MODEL_SOURCES = (
    "asl/block/model/state/types.asl",
    "asl/block/model/state/control-state.asl",
    "asl/block/model/state/descriptor-state.asl",
    "asl/block/model/state/binding-state.asl",
    "asl/block/model/lifecycle/reset.asl",
    "asl/block/model/lifecycle/begin.asl",
    "asl/block/model/lifecycle/enter-stop.asl",
    "asl/block/model/lifecycle/lifetime.asl",
    "asl/block/model/operands/scalar-bindings.asl",
    "asl/block/model/operands/tile-bindings.asl",
    "asl/block/model/operands/shared-bindings.asl",
    "asl/block/model/schema/header.asl",
    "asl/block/model/schema/dimensions.asl",
    "asl/block/model/schema/attributes.asl",
    "asl/block/model/schema/profile-encoding.asl",
    "asl/block/model/commit/validation.asl",
    "asl/block/model/commit/effects.asl",
    "asl/block/model/faults/rollback.asl",
    "asl/block/model/dispatch/decode.asl",
    "asl/block/model/dispatch/descriptor-legality.asl",
    "asl/block/model/dispatch/scalar-schema.asl",
    "asl/block/model/dispatch/tile-schema.asl",
    "asl/block/model/dispatch/numeric-control.asl",
    "asl/block/model/dispatch/destination-shape.asl",
    "asl/block/model/dispatch/shared-cube.asl",
    "asl/block/model/dispatch/shared-tlsu.asl",
    "asl/block/model/dispatch/tile-execution.asl",
    "asl/block/model/dispatch/start.asl",
    "asl/block/model/dispatch/commands.asl",
    "asl/block/model/dispatch/top-level.asl",
)


def instruction_records_from_text(text: str) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for line in text.splitlines():
        if line.startswith(INSTRUCTION_PREFIX):
            record = json.loads(line[len(INSTRUCTION_PREFIX) :])
            record.pop("id", None)
            record.pop("depends_on", None)
            records.append(record)
    return records


class BlockMigrationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.baseline = os.environ.get("PTO_MIGRATION_BASE_REF")
        if not cls.baseline:
            raise RuntimeError("PTO_MIGRATION_BASE_REF must name the pre-migration commit")

    def baseline_paths(self) -> list[Path]:
        output = subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", self.baseline, "--", "asl/bundle", "asl/block"],
            cwd=REPO,
            text=True,
        )
        return [Path(line) for line in output.splitlines() if line.endswith(".asl")]

    def baseline_text(self, path: Path) -> str:
        return subprocess.check_output(
            ["git", "show", f"{self.baseline}:{path.as_posix()}"],
            cwd=REPO,
            text=True,
        )

    def test_bundle_root_is_replaced_by_complete_block_model(self) -> None:
        self.assertFalse((REPO / "asl/bundle").exists())
        self.assertEqual([path for path in MODEL_SOURCES if not (REPO / path).is_file()], [])

    def test_block_symbols_are_preserved(self) -> None:
        old_symbols = {
            (symbol.kind, symbol.name, symbol.signature): symbol.body
            for path in self.baseline_paths()
            for symbol in _symbols_from_text(self.baseline_text(path))
        }
        migrated_paths = [
            path
            for path in (REPO / "asl/block").rglob("*.asl")
            if path.relative_to(REPO).as_posix()
            not in {"asl/block/model/state/types.asl", "asl/block/model/schema/profile-encoding.asl"}
        ]
        new_symbols = {
            (symbol.kind, symbol.name, symbol.signature): symbol.body
            for path in migrated_paths
            for symbol in _symbols_from_text(path.read_text(encoding="utf-8"))
        }
        self.assertEqual(new_symbols, old_symbols)

    def test_instruction_records_and_mnemonic_ownership_are_preserved(self) -> None:
        old_records: list[dict[str, object]] = []
        for path in self.baseline_paths():
            old_records.extend(instruction_records_from_text(self.baseline_text(path)))
        mnemonic_files = sorted(
            path for path in (REPO / "asl/block").rglob("*.asl") if "model" not in path.relative_to(REPO / "asl/block").parts
        )
        new_records: list[dict[str, object]] = []
        for path in mnemonic_files:
            text = path.read_text(encoding="utf-8")
            records = instruction_records_from_text(text)
            with self.subTest(path=path.relative_to(REPO)):
                self.assertEqual(len(records), 1)
                expected_stem = re.sub(r"[^A-Za-z0-9._-]+", "_", str(records[0]["mnemonic"])).strip("_")
                self.assertEqual(expected_stem, path.stem)
                raw = json.loads(next(line[len(INSTRUCTION_PREFIX) :] for line in text.splitlines() if line.startswith(INSTRUCTION_PREFIX)))
                self.assertIn("id", raw)
                self.assertIn("depends_on", raw)
                if "id" in raw:
                    self.assertTrue(str(raw["id"]).startswith("PTO-BLOCK-"))
                if "depends_on" in raw:
                    self.assertIsInstance(raw["depends_on"], list)
            new_records.extend(records)
        self.assertEqual(new_records, old_records)

    def test_all_block_units_respect_the_line_limit(self) -> None:
        for path in (REPO / "asl/block").rglob("*.asl"):
            with self.subTest(path=path.relative_to(REPO)):
                self.assertLessEqual(len(path.read_text(encoding="utf-8").splitlines()), 500)


if __name__ == "__main__":
    unittest.main()
