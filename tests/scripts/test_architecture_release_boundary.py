from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ADR = ROOT / "docs/status/decisions/0069-b-iot-b-ios-sizecode-pemode.md"
MAKEFILE = ROOT / "Makefile"
REPOSITORY_CHECK = ROOT / "scripts/check-repository"


class ArchitectureReleaseBoundaryTest(unittest.TestCase):
    def test_binder_adr_is_version_neutral(self) -> None:
        text = ADR.read_text(encoding="utf-8")
        for pattern in (
            r"\b0\.\d+(?:\.\d+)?\b",
            r"post-0\.",
            r"encoding_abi",
            r"Merge gate:",
            r"must not merge until",
        ):
            with self.subTest(pattern=pattern):
                self.assertIsNone(re.search(pattern, text))

    def test_ordinary_repository_check_excludes_release_manifest(self) -> None:
        checker = REPOSITORY_CHECK.read_text(encoding="utf-8")
        self.assertIn("./scripts/check-binary-closure", checker)
        self.assertNotIn("./scripts/check-release-manifest", checker)
        self.assertNotIn("generate-release-traceability-readiness", checker)
        self.assertNotIn("generate-release-gate-readiness", checker)
        self.assertNotIn("./scripts/check-release-closure", checker)

    def test_release_gate_requires_manifest_linkage(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")
        self.assertIn("./scripts/check-binary-closure --release", makefile)
        self.assertIn("./scripts/check-release-manifest", makefile)


if __name__ == "__main__":
    unittest.main()
