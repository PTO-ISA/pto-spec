from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ADR = ROOT / "docs/status/decisions/ADR-BLOCK-0015-b-iot-b-ios-sizecode-pemode.md"
MAKEFILE = ROOT / "Makefile"
REPOSITORY_CHECK = ROOT / "scripts/check-repository"
RELEASE_GATE_GENERATOR = ROOT / "scripts/generate-release-gate-readiness"


class ArchitectureReleaseBoundaryTest(unittest.TestCase):
    def test_binder_adr_targets_0583_with_version_neutral_architecture_text(self) -> None:
        text = ADR.read_text(encoding="utf-8")
        _, metadata_text, body = text.split("---", 2)
        metadata = json.loads(metadata_text)

        self.assertEqual(metadata["target_releases"], ["0.58.3"])
        for pattern in (
            r"\b0\.\d+(?:\.\d+)?\b",
            r"post-0\.",
            r"encoding_abi",
            r"Merge gate:",
            r"must not merge until",
        ):
            with self.subTest(pattern=pattern):
                self.assertIsNone(re.search(pattern, body))

    def test_ordinary_repository_check_excludes_release_manifest(self) -> None:
        checker = REPOSITORY_CHECK.read_text(encoding="utf-8")
        execution_tail = checker[checker.index("if [[ $structure_only == true ]]") :]
        self.assertIn("./scripts/check-binary-closure", execution_tail)
        self.assertNotIn("./scripts/check-release-manifest", execution_tail)
        self.assertNotIn("generate-release-traceability-readiness", execution_tail)
        self.assertNotIn("generate-release-gate-readiness", execution_tail)
        self.assertNotIn("./scripts/check-release-closure", execution_tail)

    def test_release_gate_requires_manifest_linkage(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")
        generator = RELEASE_GATE_GENERATOR.read_text(encoding="utf-8")
        self.assertIn("./scripts/check-binary-closure --release", makefile)
        self.assertIn("./scripts/check-release-manifest", makefile)
        self.assertIn('"command": "scripts/check-binary-closure --release"', generator)


if __name__ == "__main__":
    unittest.main()
