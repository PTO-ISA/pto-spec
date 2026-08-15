from __future__ import annotations

import json
import subprocess
import unittest
from pathlib import Path

from scripts.asl_tests import load_test_points, load_validation_resources
from scripts.asl_units import load_units


ROOT = Path(__file__).resolve().parents[2]


class AslTestResourcesTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.resources = load_validation_resources(ROOT)
        cls.points = load_test_points(
            ROOT,
            load_units(ROOT / "asl"),
            validation_resources=cls.resources,
        )
        completed = subprocess.run(
            [
                str(ROOT / "scripts/generate-asl-decoders"),
                "--kind",
                "validation-index",
            ],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=True,
        )
        cls.index = json.loads(completed.stdout)

    def test_each_external_validation_call_binds_one_exact_closure(self) -> None:
        bound = [point for point in self.points if point.validation_entrypoint]
        indexed = {entry["name"] for entry in self.index["validation"]}

        self.assertGreater(len(bound), 0)
        self.assertEqual(len(bound), len({point.test_id for point in bound}))
        for point in bound:
            self.assertIn(point.validation_entrypoint, indexed)
            self.assertEqual(
                point.validation_sha256,
                self.resources[point.validation_entrypoint],
            )

    def test_generated_validation_inventory_has_no_orphan(self) -> None:
        direct = {
            point.validation_entrypoint
            for point in self.points
            if point.validation_entrypoint is not None
        }
        dependencies = {
            dependency
            for entry in self.index["validation"]
            for dependency in entry["dependencies"]
        }

        self.assertEqual(set(self.resources), direct | dependencies)

    def test_empty_points_do_not_load_generated_validation_code(self) -> None:
        empty = [point for point in self.points if point.validation_entrypoint is None]
        bound = [point for point in self.points if point.validation_entrypoint]

        self.assertGreater(len(empty), 0)
        self.assertEqual(len(empty) + len(bound), len(self.points))
        self.assertEqual(len({point.validation_sha256 for point in empty}), 1)

    def test_generated_validation_points_use_compact_semantic_ids(self) -> None:
        bound = [point for point in self.points if point.validation_entrypoint]

        for point in bound:
            self.assertNotIn("VALIDATE", point.test_id)
            self.assertLessEqual(len(point.test_id), 48)

    def test_all_public_test_ids_fit_compact_display_budget(self) -> None:
        for point in self.points:
            self.assertLessEqual(len(point.test_id), 64, point.test_id)


if __name__ == "__main__":
    unittest.main()
