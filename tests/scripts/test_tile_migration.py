from __future__ import annotations

import json
import os
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import INSTRUCTION_PREFIX, _symbols_from_text


REPO = Path(__file__).resolve().parents[2]

REQUIRED_MODEL_SOURCES = (
    "asl/tile/model/state/types.asl",
    "asl/tile/model/state/local-registers.asl",
    "asl/tile/model/state/shared-registers.asl",
    "asl/tile/model/state/descriptors.asl",
    "asl/tile/model/state/allocation.asl",
    "asl/tile/model/definedness/elements.asl",
    "asl/tile/model/shape/rows-columns.asl",
    "asl/tile/model/shape/valid-region.asl",
    "asl/tile/model/capacity/local.asl",
    "asl/tile/model/capacity/shared.asl",
    "asl/tile/model/legality/descriptor-shape.asl",
    "asl/tile/model/legality/allocation-capacity.asl",
    "asl/tile/model/legality/dtype-layout.asl",
    "asl/tile/model/legality/operand-schema.asl",
    "asl/tile/model/legality/matrix-shape.asl",
    "asl/tile/model/legality/pe-mask.asl",
    "asl/tile/model/memory/addressing.asl",
    "asl/tile/model/memory/stride.asl",
    "asl/tile/model/memory/load-store.asl",
    "asl/tile/model/memory/gather-scatter.asl",
    "asl/tile/model/memory/atomics.asl",
    "asl/tile/model/memory/restart.asl",
    "asl/tile/model/numeric/formats.asl",
    "asl/tile/model/numeric/rounding.asl",
    "asl/tile/model/numeric/exceptions.asl",
    "asl/tile/model/dispatch/top-level.asl",
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


class TileMigrationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.baseline = os.environ.get("PTO_MIGRATION_BASE_REF")
        if not cls.baseline:
            raise RuntimeError("PTO_MIGRATION_BASE_REF must name the pre-migration commit")

    def baseline_paths(self) -> list[Path]:
        output = subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", self.baseline, "--", "asl/tile"],
            cwd=REPO,
            text=True,
        )
        return [Path(line) for line in output.splitlines() if line.endswith(".asl")]

    def baseline_text(self, path: Path) -> str:
        return subprocess.check_output(
            ["git", "show", f"{self.baseline}:{path.as_posix()}"], cwd=REPO, text=True
        )

    def test_tile_root_contains_only_taxonomy_and_model_directories(self) -> None:
        root_files = sorted(path.name for path in (REPO / "asl/tile").glob("*.asl"))
        self.assertEqual(root_files, [])
        self.assertEqual([path for path in REQUIRED_MODEL_SOURCES if not (REPO / path).is_file()], [])

    def test_tile_symbols_are_preserved(self) -> None:
        old_symbols = {
            (symbol.kind, symbol.name, symbol.signature): symbol.body
            for path in self.baseline_paths()
            for symbol in _symbols_from_text(self.baseline_text(path))
        }
        migrated_paths = [
            path
            for path in (REPO / "asl/tile").rglob("*.asl")
            if path.relative_to(REPO).as_posix() != "asl/tile/model/state/types.asl"
        ]
        new_symbols = {
            (symbol.kind, symbol.name, symbol.signature): symbol.body
            for path in migrated_paths
            for symbol in _symbols_from_text(path.read_text(encoding="utf-8"))
        }
        self.assertEqual(new_symbols, old_symbols)

    def test_instruction_records_and_checked_taxonomy_paths_are_preserved(self) -> None:
        old_records: list[dict[str, object]] = []
        for path in self.baseline_paths():
            old_records.extend(instruction_records_from_text(self.baseline_text(path)))
        mnemonic_files = sorted(
            path
            for path in (REPO / "asl/tile").rglob("*.asl")
            if "model" not in path.relative_to(REPO / "asl/tile").parts
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
                taxonomy_path = tuple(path.relative_to(REPO / "asl/tile").parts[:-1])
                self.assertEqual(tuple(record["classification"]), taxonomy_path)
                raw = json.loads(
                    next(
                        line[len(INSTRUCTION_PREFIX) :]
                        for line in text.splitlines()
                        if line.startswith(INSTRUCTION_PREFIX)
                    )
                )
                self.assertTrue(str(raw.get("id", "")).startswith("PTO-TILE-"))
                self.assertIn("PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING", raw.get("depends_on", []))
            new_records.extend(records)
        self.assertEqual(new_records, old_records)

    def test_all_tile_units_respect_the_line_limit(self) -> None:
        for path in (REPO / "asl/tile").rglob("*.asl"):
            with self.subTest(path=path.relative_to(REPO)):
                self.assertLessEqual(len(path.read_text(encoding="utf-8").splitlines()), 500)

    def test_ordered_assembler_splices_decoder_exactly_once(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp = Path(temp_dir)
            first = temp / "first.asl"
            second = temp / "second.asl"
            decoder = temp / "decoder.asl"
            order = temp / "order.txt"
            output = temp / "output.asl"
            first.write_text("type First of boolean;\n", encoding="utf-8")
            second.write_text("type Second of boolean;\n", encoding="utf-8")
            decoder.write_text("type Decoder of boolean;\n", encoding="utf-8")
            order.write_text(f"{first}\n@generated-decoder@\n{second}\n", encoding="utf-8")
            subprocess.run(
                [
                    str(REPO / "scripts/assemble-asl"),
                    "--order",
                    str(order),
                    "--decoder",
                    str(decoder),
                    "--output",
                    str(output),
                ],
                cwd=REPO,
                check=True,
            )
            assembled = output.read_text(encoding="utf-8")
            self.assertLess(assembled.index("type First"), assembled.index("type Decoder"))
            self.assertLess(assembled.index("type Decoder"), assembled.index("type Second"))

    def test_ordered_assembler_rejects_invalid_order_manifests(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            temp = Path(temp_dir)
            source = temp / "source.asl"
            decoder = temp / "decoder.asl"
            order = temp / "order.txt"
            output = temp / "output.asl"
            source.write_text("type Source of boolean;\n", encoding="utf-8")
            decoder.write_text("type Decoder of boolean;\n", encoding="utf-8")
            invalid_orders = (
                f"{source}\n",
                f"@generated-decoder@\n@generated-decoder@\n{source}\n",
                f"{source}\n@generated-decoder@\n{source}\n",
                f"{temp / 'missing.asl'}\n@generated-decoder@\n",
            )
            for content in invalid_orders:
                with self.subTest(content=content):
                    order.write_text(content, encoding="utf-8")
                    result = subprocess.run(
                        [
                            str(REPO / "scripts/assemble-asl"),
                            "--order",
                            str(order),
                            "--decoder",
                            str(decoder),
                            "--output",
                            str(output),
                        ],
                        cwd=REPO,
                        capture_output=True,
                        text=True,
                    )
                    self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
