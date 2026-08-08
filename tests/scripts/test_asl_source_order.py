from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from scripts.asl_units import generate_source_order


def metadata(
    unit_id: str,
    surface: str,
    classification: list[str],
    depends_on: list[str],
    *,
    mnemonic: str | None = None,
) -> str:
    record: dict[str, object] = {
        "id": unit_id,
        "surface": surface,
        "classification": classification,
        "depends_on": depends_on,
    }
    prefix = "// PTO-UNIT: "
    if mnemonic is not None:
        record["mnemonic"] = mnemonic
        prefix = "// PTO-INSTRUCTION: "
    return prefix + json.dumps(record, separators=(",", ":")) + "\n"


class AslSourceOrderTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        for surface in ("arch", "block", "scalar", "tile"):
            (self.root / "asl" / surface).mkdir(parents=True)
        self.write(
            "arch/overview/architecture.asl",
            metadata(
                "PTO-ARCH-OVERVIEW-ARCHITECTURE",
                "arch",
                ["overview", "architecture"],
                [],
            ),
        )
        self.write(
            "arch/state/registers.asl",
            metadata(
                "PTO-ARCH-STATE-REGISTERS",
                "arch",
                ["state", "registers"],
                ["PTO-ARCH-OVERVIEW-ARCHITECTURE"],
            ),
        )
        self.write(
            "scalar/alu/ADD.asl",
            metadata(
                "PTO-SCALAR-ALU-ADD",
                "scalar",
                ["alu"],
                ["generated:decoders", "PTO-ARCH-STATE-REGISTERS"],
                mnemonic="ADD",
            ),
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write(self, relative: str, content: str) -> None:
        path = self.root / "asl" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content + "constant TEST_VALUE = 1;\n", encoding="utf-8")

    def test_order_respects_dependencies_and_places_decoder_marker_once(self) -> None:
        order = generate_source_order(self.root)

        self.assertLess(
            order.index("asl/arch/overview/architecture.asl"),
            order.index("asl/arch/state/registers.asl"),
        )
        self.assertLess(
            order.index("@generated-decoder@"),
            order.index("asl/scalar/alu/ADD.asl"),
        )
        self.assertEqual(order.count("@generated-decoder@"), 1)

    def test_repeated_generation_is_byte_identical(self) -> None:
        self.assertEqual(generate_source_order(self.root), generate_source_order(self.root))

    def test_missing_dependency_is_rejected(self) -> None:
        self.write(
            "tile/model/state/base.asl",
            metadata(
                "PTO-TILE-MODEL-STATE-BASE",
                "tile",
                ["model", "state", "base"],
                ["PTO-DOES-NOT-EXIST"],
            ),
        )

        with self.assertRaisesRegex(ValueError, "unknown ASL dependency PTO-DOES-NOT-EXIST"):
            generate_source_order(self.root)

    def test_cli_write_check_and_drift_detection(self) -> None:
        output = self.root / "build/asl-source-order.txt"
        command = [
            sys.executable,
            "scripts/generate-asl-source-order",
            "--root",
            str(self.root),
            "--output",
            str(output),
        ]

        write = subprocess.run(command, cwd=Path(__file__).resolve().parents[2], text=True, capture_output=True)
        self.assertEqual(write.returncode, 0, write.stderr)
        expected = "\n".join(generate_source_order(self.root)) + "\n"
        self.assertEqual(output.read_text(encoding="utf-8"), expected)

        check = subprocess.run(
            [*command, "--check"],
            cwd=Path(__file__).resolve().parents[2],
            text=True,
            capture_output=True,
        )
        self.assertEqual(check.returncode, 0)

        output.write_text("stale\n", encoding="utf-8")
        stale = subprocess.run(
            [*command, "--check"],
            cwd=Path(__file__).resolve().parents[2],
            text=True,
            capture_output=True,
        )
        self.assertEqual(stale.returncode, 1)


if __name__ == "__main__":
    unittest.main()
