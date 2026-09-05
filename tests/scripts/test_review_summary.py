from __future__ import annotations

import json
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SUMMARY = runpy.run_path(str(ROOT / "scripts/generate-review-summary"))


class ReviewSummaryTest(unittest.TestCase):
    def test_navigation_is_not_an_adr_but_malformed_decisions_are_rejected(self) -> None:
        extract = SUMMARY["adr_metadata_id"]
        self.assertIsNone(extract("# Decision index\n", "docs/status/decisions/index.md"))
        with self.assertRaisesRegex(ValueError, "missing JSON frontmatter"):
            extract("# Missing metadata\n", "docs/status/decisions/ADR-BLOCK-0018-bad.md")

    def git(self, root: Path, *arguments: str) -> str:
        result = subprocess.run(
            ["git", *arguments], cwd=root, text=True, capture_output=True, check=True
        )
        return result.stdout.strip()

    def write_json(self, root: Path, path: str, value: object) -> None:
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(value), encoding="utf-8")

    def test_typed_and_legacy_adr_ids_are_reported_as_canonical_ids(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.git(root, "init")
            self.git(root, "config", "user.email", "agent@example.invalid")
            self.git(root, "config", "user.name", "test-agent")
            self.write_json(root, "spec/release-manifest.json", {"encoding_projection_sha256": "a" * 64})
            self.write_json(root, "spec/evidence/adr-index.json", {"records": [], "legacy_map": {}})
            self.write_json(root, "spec/evidence/release-traceability-readiness.json", {"units": []})
            legacy = root / "docs/status/decisions/ADR-0042-old.md"
            legacy.parent.mkdir(parents=True)
            legacy.write_text('---\n{"id": "ADR-0042"}\n---\nold\n', encoding="utf-8")
            self.git(root, "add", ".")
            self.git(root, "commit", "-m", "base")
            base = self.git(root, "rev-parse", "HEAD")

            legacy.unlink()
            typed = root / "docs/status/decisions/ADR-BLOCK-0018-current.md"
            typed.write_text(
                '---\n{"id": "ADR-BLOCK-0018", "legacy_ids": ["ADR-0042"]}\n---\nnew\n',
                encoding="utf-8",
            )
            self.write_json(
                root,
                "spec/evidence/adr-index.json",
                {
                    "records": [{"id": "ADR-BLOCK-0018", "release_impact": "none"}],
                    "legacy_map": {"ADR-0042": "ADR-BLOCK-0018"},
                },
            )
            self.git(root, "add", "-A")
            self.git(root, "commit", "-m", "typed ADR")

            SUMMARY["render"].__globals__["ROOT"] = root
            rendered = SUMMARY["render"](base, "HEAD")

            changed_adrs = rendered.split("## Changed ADRs\n", 1)[1].split("\n## ", 1)[0]
            self.assertIn("`ADR-BLOCK-0018`", changed_adrs)
            self.assertNotIn("- None", changed_adrs)
            self.assertNotIn("`ADR-0042`", changed_adrs)


if __name__ == "__main__":
    unittest.main()
