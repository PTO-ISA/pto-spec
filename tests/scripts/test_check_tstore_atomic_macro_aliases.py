from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-tstore-atomic-macro-aliases"
DECODER_WORD = f"{0x00111181:032b}"


class TStoreAtomicMacroAliasCheckerTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self._copy(
            "spec/catalog/tile-macro-assembly.json",
            "spec/catalog/tile-operations.json",
            "spec/catalog/command-forms.json",
            "asl/arch/data-types/tile-data-types.asl",
            "tests/asl/block/execution/BSTART.TSTORE/block-exec-bstart-tstore-atomic-modes-001.asl",
            "tests/asl/block/execution/BSTART.TSTORE/block-decode-bstart-tstore-canonical-001.asl",
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def _copy(self, *relative_paths: str) -> None:
        for relative in relative_paths:
            source = ROOT / relative
            destination = self.root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)

    def _run(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(CHECKER), "--root", str(self.root)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def _mutate_and_reject(self, relative: str, before: str, after: str) -> None:
        path = self.root / relative
        original = path.read_text(encoding="utf-8")
        self.assertIn(before, original)
        path.write_text(original.replace(before, after, 1), encoding="utf-8")
        result = self._run()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        path.write_text(original, encoding="utf-8")

    def test_current_parameterized_constructor_and_independent_u32_encoding_pass(self) -> None:
        result = self._run()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("independently pinned fixed bits", result.stdout)

    def test_carrier_dtype_and_decoder_mutations_are_rejected(self) -> None:
        modes = "tests/asl/block/execution/BSTART.TSTORE/block-exec-bstart-tstore-atomic-modes-001.asl"
        data_types = "asl/arch/data-types/tile-data-types.asl"
        decoder = "tests/asl/block/execution/BSTART.TSTORE/block-decode-bstart-tstore-canonical-001.asl"
        command_forms = "spec/catalog/command-forms.json"
        cases = (
            (modes, "0x00111181", "0x00111180"),
            (modes, "instruction[31:27]", "instruction[30:26]"),
            (modes, "AtomicModeStart(TileDataType_U32)", "AtomicModeStart(TileDataType_FP16)"),
            (data_types, "when TileDataType_U32 => return Zeros{5} + 25;", "when TileDataType_U32 => return Zeros{5} + 24;"),
            (decoder, DECODER_WORD, f"{0x00111180:032b}"),
        )
        for relative, before, after in cases:
            with self.subTest(relative=relative, before=before):
                self._mutate_and_reject(relative, before, after)

        document = json.loads((self.root / command_forms).read_text(encoding="utf-8"))
        form = next(item for item in document["forms"] if item["mnemonic"] == "BSTART.TSTORE")
        form["encoding"][0]["match"] = "0x00111180"
        (self.root / command_forms).write_text(
            json.dumps(document), encoding="utf-8"
        )
        result = self._run()
        self.assertNotEqual(result.returncode, 0, result.stdout)


if __name__ == "__main__":
    unittest.main()
