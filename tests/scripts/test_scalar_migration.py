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
    "asl/scalar/model/types/operations.asl",
    "asl/scalar/model/types/operands.asl",
    "asl/scalar/model/alu/semantics.asl",
    "asl/scalar/model/bru/semantics.asl",
    "asl/scalar/model/sys/registers.asl",
    "asl/scalar/model/sys/semantics.asl",
    "asl/scalar/model/amo/semantics.asl",
    "asl/scalar/model/agu/memory.asl",
    "asl/scalar/model/agu/addressing.asl",
    "asl/scalar/model/fsu/arithmetic.asl",
    "asl/scalar/model/fsu/profile.asl",
    "asl/scalar/model/dispatch/decode.asl",
    "asl/scalar/model/dispatch/alu.asl",
    "asl/scalar/model/dispatch/bru.asl",
    "asl/scalar/model/dispatch/sys.asl",
    "asl/scalar/model/dispatch/amo.asl",
    "asl/scalar/model/dispatch/agu.asl",
    "asl/scalar/model/dispatch/fsu.asl",
    "asl/scalar/model/dispatch/top-level.asl",
)

SCALAR_CLASSES = ("alu", "bru", "sys", "amo", "agu", "fsu")


def instruction_records_from_text(text: str) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for line in text.splitlines():
        if line.startswith(INSTRUCTION_PREFIX):
            record = json.loads(line[len(INSTRUCTION_PREFIX) :])
            record.pop("id", None)
            record.pop("depends_on", None)
            records.append(record)
    return records


class ScalarMigrationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.baseline = os.environ.get("PTO_MIGRATION_BASE_REF")
        if not cls.baseline:
            raise RuntimeError("PTO_MIGRATION_BASE_REF must name the pre-migration commit")

    def baseline_paths(self) -> list[Path]:
        output = subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", self.baseline, "--", "asl/scalar"],
            cwd=REPO,
            text=True,
        )
        return [Path(line) for line in output.splitlines() if line.endswith(".asl")]

    def baseline_text(self, path: Path) -> str:
        return subprocess.check_output(
            ["git", "show", f"{self.baseline}:{path.as_posix()}"], cwd=REPO, text=True
        )

    def test_scalar_root_contains_only_class_and_model_directories(self) -> None:
        root_files = sorted(path.name for path in (REPO / "asl/scalar").glob("*.asl"))
        self.assertEqual(root_files, [])
        self.assertEqual([path for path in MODEL_SOURCES if not (REPO / path).is_file()], [])

    def test_scalar_symbols_are_preserved(self) -> None:
        old_symbols = {
            (symbol.kind, symbol.name, symbol.signature): symbol.body
            for path in self.baseline_paths()
            for symbol in _symbols_from_text(self.baseline_text(path))
        }
        migrated_paths = [
            path
            for path in (REPO / "asl/scalar").rglob("*.asl")
            if path.relative_to(REPO).as_posix() != "asl/scalar/model/types/operations.asl"
        ]
        new_symbols = {
            (symbol.kind, symbol.name, symbol.signature): symbol.body
            for path in migrated_paths
            for symbol in _symbols_from_text(path.read_text(encoding="utf-8"))
        }
        self.assertEqual(new_symbols, old_symbols)

    def test_instruction_records_and_class_dispatch_dependencies_are_preserved(self) -> None:
        old_records: list[dict[str, object]] = []
        for path in self.baseline_paths():
            old_records.extend(instruction_records_from_text(self.baseline_text(path)))
        mnemonic_files = sorted(
            path
            for path in (REPO / "asl/scalar").rglob("*.asl")
            if "model" not in path.relative_to(REPO / "asl/scalar").parts
        )
        new_records: list[dict[str, object]] = []
        for path in mnemonic_files:
            text = path.read_text(encoding="utf-8")
            records = instruction_records_from_text(text)
            with self.subTest(path=path.relative_to(REPO)):
                self.assertEqual(len(records), 1)
                record = records[0]
                expected_stem = re.sub(r"[^A-Za-z0-9._-]+", "_", str(record["mnemonic"])).strip("_")
                self.assertEqual(expected_stem, path.stem)
                raw = json.loads(
                    next(
                        line[len(INSTRUCTION_PREFIX) :]
                        for line in text.splitlines()
                        if line.startswith(INSTRUCTION_PREFIX)
                    )
                )
                self.assertTrue(str(raw.get("id", "")).startswith("PTO-SCALAR-"))
                self.assertIn("PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING", raw.get("depends_on", []))
            new_records.extend(records)
        self.assertEqual(new_records, old_records)

    def test_scalar_dispatch_is_split_by_class(self) -> None:
        self.assertFalse((REPO / "asl/scalar/dispatch.asl").exists())
        top_level = REPO / "asl/scalar/model/dispatch/top-level.asl"
        self.assertLessEqual(len(top_level.read_text(encoding="utf-8").splitlines()), 120)
        for scalar_class in SCALAR_CLASSES:
            text = (REPO / f"asl/scalar/model/dispatch/{scalar_class}.asl").read_text(encoding="utf-8")
            self.assertIn(f"ExecuteDecoded{scalar_class.upper()}Form", text)
            metadata = json.loads(
                next(
                    line.removeprefix("// PTO-UNIT: ")
                    for line in text.splitlines()
                    if line.startswith("// PTO-UNIT: ")
                )
            )
            mnemonic_ids = {
                json.loads(
                    next(
                        line.removeprefix(INSTRUCTION_PREFIX)
                        for line in path.read_text(encoding="utf-8").splitlines()
                        if line.startswith(INSTRUCTION_PREFIX)
                    )
                )["id"]
                for path in (REPO / f"asl/scalar/{scalar_class}").glob("*.asl")
            }
            self.assertTrue(mnemonic_ids.issubset(set(metadata["depends_on"])))

    def test_all_scalar_units_respect_the_line_limit(self) -> None:
        for path in (REPO / "asl/scalar").rglob("*.asl"):
            with self.subTest(path=path.relative_to(REPO)):
                self.assertLessEqual(len(path.read_text(encoding="utf-8").splitlines()), 500)


if __name__ == "__main__":
    unittest.main()
