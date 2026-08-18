from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class DecisionImplementationClosureTest(unittest.TestCase):
    def test_accepted_decision_mnemonics_have_owner_local_ndf(self) -> None:
        owners: dict[str, Path] = {}
        for path in (ROOT / "asl").rglob("*.asl"):
            lines = path.read_text(encoding="utf-8").splitlines()
            if not lines or not lines[0].startswith("// PTO-INSTRUCTION: "):
                continue
            metadata = json.loads(lines[0].split(": ", 1)[1])
            owners[metadata["mnemonic"]] = path

        decision_bound: dict[str, set[str]] = {}
        for path in (ROOT / "docs/status/decisions").glob("*.md"):
            text = path.read_text(encoding="utf-8")
            header = "\n".join(text.splitlines()[:10]).lower()
            if "status: superseded" in header:
                continue
            for token in re.findall(r"`([^`]+)`", text):
                if token in owners:
                    decision_bound.setdefault(token, set()).add(path.name)

        missing = {
            mnemonic: sorted(decisions)
            for mnemonic, decisions in decision_bound.items()
            if "// NDF-BEGIN:" not in owners[mnemonic].read_text(encoding="utf-8")
        }
        self.assertEqual(missing, {})


if __name__ == "__main__":
    unittest.main()
