import json
import unittest
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE_ROOT = ROOT / "spec/evidence"
OBSOLETE_AGGREGATES = {
    "tests/asl/main.asl",
    "tests/asl/arch-tests.asl",
    "tests/asl/block-tests.asl",
    "tests/asl/bundle-tests.asl",
    "tests/asl/concurrency-tests.asl",
    "tests/asl/cube-totality-tests.asl",
    "tests/asl/dispatch-tests.asl",
    "tests/asl/scalar-tests.asl",
    "tests/asl/tile-tests.asl",
}


def strings(value: Any):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from strings(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from strings(item)


class EvidenceTestPathTests(unittest.TestCase):
    def test_evidence_references_independent_asl_points_only(self) -> None:
        failures: list[str] = []
        for evidence_path in sorted(EVIDENCE_ROOT.glob("*.json")):
            payload = json.loads(evidence_path.read_text(encoding="utf-8"))
            for value in strings(payload):
                path_text = value.split(":", 1)[0]
                if not path_text.startswith("tests/asl/") or not path_text.endswith(".asl"):
                    continue
                if path_text in OBSOLETE_AGGREGATES:
                    failures.append(f"{evidence_path.name}: obsolete {path_text}")
                    continue
                if not (ROOT / path_text).is_file():
                    failures.append(f"{evidence_path.name}: missing {path_text}")
        self.assertEqual(failures, [])


if __name__ == "__main__":
    unittest.main()
