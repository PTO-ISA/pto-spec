from __future__ import annotations

import copy
import json
from pathlib import Path
import tempfile
import unittest

from scripts.current_source_form_inventory import (
    EXPECTED_CURRENT_FORM_COUNT,
    EXPECTED_CURRENT_SOURCE_FINGERPRINT,
    EXPECTED_RELEASE_FINGERPRINT,
    EXPECTED_RELEASE_FORM_COUNT,
    check_current_source_binary,
    check_release_binary,
)


ROOT = Path(__file__).resolve().parents[2]


class CurrentSourceFormInventoryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.scalar = json.loads(
            (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
        )
        self.command = json.loads(
            (ROOT / "spec/catalog/command-forms.json").read_text(encoding="utf-8")
        )

    def _write_catalogs(self, root: Path, scalar: dict) -> None:
        scalar_path = root / "spec/catalog/scalar-forms.json"
        command_path = root / "spec/catalog/command-forms.json"
        scalar_path.parent.mkdir(parents=True, exist_ok=True)
        scalar_path.write_text(json.dumps(scalar), encoding="utf-8")
        command_path.write_text(json.dumps(self.command), encoding="utf-8")

    def test_current_source_closure_includes_scoped_forms(self) -> None:
        self.assertEqual(
            check_current_source_binary(ROOT),
            (EXPECTED_CURRENT_FORM_COUNT, EXPECTED_CURRENT_SOURCE_FINGERPRINT),
        )

    def test_release_binary_identity_remains_legacy_only(self) -> None:
        self.assertEqual(
            check_release_binary(ROOT),
            (EXPECTED_RELEASE_FORM_COUNT, EXPECTED_RELEASE_FINGERPRINT),
        )

    def test_scoped_mask_operand_and_constraint_drift_is_rejected(self) -> None:
        mutations = {
            "encoding mask": lambda form: form["encoding"][0].__setitem__(
                "mask",
                f"0x{(int(form['encoding'][0]['mask'], 16) | (1 << 31)):08x}",
            ),
            "operand piece": lambda form: form["fields"][0]["pieces"][0].__setitem__(
                "instruction_lsb",
                form["fields"][0]["pieces"][0]["instruction_lsb"] + 1,
            ),
            "constraint": lambda form: form["constraints"].append(
                {"kind": "drift-probe"}
            ),
        }
        for label, mutate in mutations.items():
            with self.subTest(drift=label), tempfile.TemporaryDirectory() as temp_dir:
                candidate = copy.deepcopy(self.scalar)
                mutate(candidate["scoped_forms"][0])
                root = Path(temp_dir)
                self._write_catalogs(root, candidate)
                with self.assertRaisesRegex(
                    ValueError, "current-source accepted-form fingerprint drift"
                ):
                    check_current_source_binary(root)


if __name__ == "__main__":
    unittest.main()
