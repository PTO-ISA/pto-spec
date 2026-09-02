from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MAKEFILE = ROOT / "Makefile"


class AslBuildDependenciesTest(unittest.TestCase):
    def test_decoder_target_depends_on_shared_generation_modules(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")
        inputs = re.search(
            r"^DECODER_GENERATION_INPUTS := "
            r"(?P<prerequisites>(?:[^\n]*\\\n)*[^\n]*)$",
            makefile,
            flags=re.MULTILINE,
        )

        self.assertIsNotNone(inputs, "decoder generation inputs are absent")
        prerequisites = inputs.group("prerequisites")
        self.assertIn("scripts/encoding_witness.py", prerequisites)
        self.assertIn("scripts/tile_taxonomy.py", prerequisites)
        self.assertIn(
            "scripts/asl_validation_shards.py", prerequisites
        )
        self.assertIn("$(DECODER_SPEC): $(DECODER_GENERATION_INPUTS)", makefile)

    def test_validation_index_is_separate_from_normative_spec(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")

        self.assertIn("VALIDATION_INDEX := build/validation-index.json", makefile)
        self.assertRegex(
            makefile,
            r"\$\(VALIDATION_INDEX\):[^\n]*\$\(DECODER_GENERATION_INPUTS\)",
        )
        spec_rule = re.search(
            r"^\$\(SPEC\):(?P<prerequisites>[^\n]*)$",
            makefile,
            flags=re.MULTILINE,
        )
        self.assertIsNotNone(spec_rule)
        self.assertNotIn("VALIDATION_INDEX", spec_rule.group("prerequisites"))

    def test_pr_check_enforces_the_decoder_partition(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")
        checker = (ROOT / "scripts/check-pr").read_text(encoding="utf-8")

        self.assertIn(
            "check-decoder-partition: $(DECODER_SPEC) $(VALIDATION_INDEX)",
            makefile,
        )
        self.assertIn("pr-check:\n\t./scripts/check-pr", makefile)
        self.assertIn(
            '"make --no-print-directory check-decoder-partition"', checker
        )


if __name__ == "__main__":
    unittest.main()
