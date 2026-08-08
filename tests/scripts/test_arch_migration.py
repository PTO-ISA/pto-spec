from __future__ import annotations

import os
import subprocess
import unittest
from pathlib import Path

from scripts.asl_units import _symbols_from_text, compare_ref_to_tree


REPO = Path(__file__).resolve().parents[2]

LEGACY_SOURCES = (
    Path("asl/architecture.asl"),
    Path("asl/types.asl"),
    Path("asl/numeric/formats.asl"),
    Path("asl/state.asl"),
    Path("asl/concurrency.asl"),
    Path("asl/profiles/pto-v0.asl"),
    Path("asl/dispatch.asl"),
)

MIGRATED_SOURCES = (
    Path("asl/arch/overview/architecture.asl"),
    Path("asl/arch/overview/instruction-classification.asl"),
    Path("asl/arch/data-types/integer.asl"),
    Path("asl/arch/data-types/fault.asl"),
    Path("asl/arch/data-types/floating-point.asl"),
    Path("asl/arch/data-types/memory-model.asl"),
    Path("asl/arch/data-types/memory-operations.asl"),
    Path("asl/arch/data-types/packed.asl"),
    Path("asl/arch/data-types/tile-data-types.asl"),
    Path("asl/arch/data-types/numeric-classification.asl"),
    Path("asl/arch/data-types/rounding.asl"),
    Path("asl/arch/data-types/system-registers.asl"),
    Path("asl/arch/programming-model/core-pe-topology.asl"),
    Path("asl/arch/programming-model/execution-context.asl"),
    Path("asl/arch/programming-model/scalar-registers.asl"),
    Path("asl/arch/programming-model/predicate-registers.asl"),
    Path("asl/arch/programming-model/tile-registers.asl"),
    Path("asl/arch/programming-model/shared-tile-registers.asl"),
    Path("asl/arch/state/program-counter.asl"),
    Path("asl/arch/state/execution-mask.asl"),
    Path("asl/arch/state/trap-context.asl"),
    Path("asl/arch/data-types/trap-context.asl"),
    Path("asl/arch/state/tile-descriptor.asl"),
    Path("asl/arch/state/definedness.asl"),
    Path("asl/arch/system-registers/addressing.asl"),
    Path("asl/arch/system-registers/access-control.asl"),
    Path("asl/arch/system-registers/context.asl"),
    Path("asl/arch/system-registers/interrupt.asl"),
    Path("asl/arch/system-registers/timer.asl"),
    Path("asl/arch/system-registers/maintenance.asl"),
    Path("asl/arch/memory-model/address-space.asl"),
    Path("asl/arch/memory-model/memory-events.asl"),
    Path("asl/arch/memory-model/ordering.asl"),
    Path("asl/arch/memory-model/atomicity.asl"),
    Path("asl/arch/memory-model/fault-precision.asl"),
    Path("asl/arch/features/predication.asl"),
    Path("asl/arch/features/mx-formats.asl"),
    Path("asl/arch/features/tile-allocation.asl"),
    Path("asl/arch/features/shared-tile-state.asl"),
    Path("asl/arch/profile/reset.asl"),
    Path("asl/arch/profile/applicability.asl"),
    Path("asl/arch/profile/reference-profile.asl"),
    Path("asl/arch/dispatch/top-level.asl"),
    Path("asl/block/model/state/types.asl"),
    Path("asl/block/model/schema/profile-encoding.asl"),
    Path("asl/scalar/model/types/operations.asl"),
    Path("asl/tile/model/state/types.asl"),
)


def _symbol_map(documents: list[str]) -> dict[tuple[str, str], tuple[str, str]]:
    result: dict[tuple[str, str], tuple[str, str]] = {}
    for document in documents:
        for symbol in _symbols_from_text(document):
            key = (symbol.kind, symbol.name)
            if key in result:
                raise AssertionError(f"duplicate symbol in migration inventory: {key}")
            result[key] = (symbol.signature, symbol.body)
    return result


class ArchitectureMigrationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.baseline = os.environ.get("PTO_MIGRATION_BASE_REF")
        if not cls.baseline:
            raise RuntimeError("PTO_MIGRATION_BASE_REF must name the pre-migration commit")

    def baseline_text(self, path: Path) -> str:
        return subprocess.check_output(
            ["git", "show", f"{self.baseline}:{path.as_posix()}"],
            cwd=REPO,
            text=True,
        )

    def assert_migrated_files_exist(self) -> None:
        missing = [path.as_posix() for path in MIGRATED_SOURCES if not (REPO / path).is_file()]
        self.assertEqual(missing, [])

    def test_approved_architecture_leaves_replace_legacy_aggregates(self) -> None:
        missing = [path.as_posix() for path in MIGRATED_SOURCES if not (REPO / path).is_file()]
        remaining = [path.as_posix() for path in LEGACY_SOURCES if (REPO / path).exists()]
        self.assertEqual(missing, [])
        self.assertEqual(remaining, [])

    def test_named_declarations_signatures_and_bodies_are_preserved(self) -> None:
        self.assert_migrated_files_exist()
        old_symbols = _symbol_map([self.baseline_text(path) for path in LEGACY_SOURCES])
        new_symbols = _symbol_map([(REPO / path).read_text(encoding="utf-8") for path in MIGRATED_SOURCES])
        self.assertEqual(new_symbols, old_symbols)

    def test_repository_semantic_surface_is_unchanged(self) -> None:
        self.assert_migrated_files_exist()
        self.assertEqual(
            compare_ref_to_tree(
                REPO,
                self.baseline,
                REPO / "asl",
                ("arch", "block", "scalar", "tile"),
            ),
            [],
        )

    def test_migrated_units_respect_the_line_limit_and_metadata_contract(self) -> None:
        self.assert_migrated_files_exist()
        for path in MIGRATED_SOURCES:
            document = (REPO / path).read_text(encoding="utf-8")
            with self.subTest(path=path):
                self.assertLessEqual(len(document.splitlines()), 500)
                self.assertEqual(document.count("// PTO-UNIT: "), 1)


if __name__ == "__main__":
    unittest.main()
