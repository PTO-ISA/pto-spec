from __future__ import annotations

from pathlib import Path
import runpy
import unittest
from unittest import mock


ROOT = Path(__file__).resolve().parents[2]
MODULE = runpy.run_path(str(ROOT / "scripts/check-site-lighthouse"))


def scores(performance: float, *, cls: float = 0.0) -> dict[str, float]:
    return {
        "performance": performance,
        "accessibility": 100,
        "best-practices": 100,
        "seo": 100,
        "cls": cls,
    }


class StableLighthouseTest(unittest.TestCase):
    def test_first_passing_sample_is_not_repeated(self) -> None:
        runner = mock.Mock(return_value=scores(99))
        result = MODULE["check_route"](
            "home", "/", "home-desktop", desktop=True, runner=runner
        )
        self.assertEqual(result["performance"], 99)
        runner.assert_called_once_with("/", "home-desktop", desktop=True, attempt=1)

    def test_one_noisy_failure_uses_three_sample_median(self) -> None:
        runner = mock.Mock(side_effect=[scores(74), scores(99), scores(98)])
        result = MODULE["check_route"](
            "home", "/", "home-desktop", desktop=True, runner=runner
        )
        self.assertEqual(result["performance"], 98)
        self.assertEqual(runner.call_count, 3)

    def test_persistent_failure_remains_release_blocking(self) -> None:
        runner = mock.Mock(side_effect=[scores(74), scores(75), scores(76)])
        with self.assertRaisesRegex(ValueError, "performance 75 < 90"):
            MODULE["check_route"](
                "home", "/", "home-desktop", desktop=True, runner=runner
            )

    def test_median_applies_to_layout_shift_too(self) -> None:
        runner = mock.Mock(
            side_effect=[scores(99, cls=0.2), scores(99, cls=0.0), scores(99, cls=0.01)]
        )
        result = MODULE["check_route"](
            "home", "/", "home-desktop", desktop=True, runner=runner
        )
        self.assertEqual(result["cls"], 0.01)


if __name__ == "__main__":
    unittest.main()
