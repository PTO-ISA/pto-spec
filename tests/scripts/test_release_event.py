from __future__ import annotations

import json
from pathlib import Path
import runpy
import unittest

from scripts.release_event import canonical_release_event, validate_release_event


ROOT = Path(__file__).resolve().parents[2]
SCHEMA_PATH = ROOT / "spec/schemas/pto-spec-release-event-v1.schema.json"
VALIDATE_SCHEMA = runpy.run_path(str(ROOT / "scripts/check-release-event-schema"))[
    "validate_schema"
]
VALID_PAYLOAD = {
    "schema_version": "1",
    "repository": "PTO-ISA/pto-spec",
    "tag": "v0.58.2",
    "commit": "0123456789abcdef0123456789abcdef01234567",
    "release_id": 123,
    "release_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.2",
    "release_manifest_sha256": "a" * 64,
    "published_at": "2026-08-10T00:00:00Z",
}


class ReleaseEventTest(unittest.TestCase):
    def assert_invalid(self, **updates: object) -> None:
        payload = {**VALID_PAYLOAD, **updates}
        self.assertTrue(validate_release_event(payload))

    def test_valid_payload_is_accepted(self) -> None:
        self.assertEqual(validate_release_event(VALID_PAYLOAD), [])

    def test_existing_major_minor_tag_remains_accepted(self) -> None:
        payload = {
            **VALID_PAYLOAD,
            "tag": "v0.58",
            "release_url": "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58",
        }

        self.assertEqual(validate_release_event(payload), [])

    def test_repository_schema_is_accepted_by_the_semantic_checker(self) -> None:
        schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
        self.assertEqual(VALIDATE_SCHEMA(schema), [])

    def test_schema_checker_rejects_additional_semantic_keywords(self) -> None:
        schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
        schema["not"] = {}
        self.assertTrue(VALIDATE_SCHEMA(schema))

    def test_canonical_payload_is_sorted_and_compact(self) -> None:
        self.assertEqual(
            canonical_release_event(VALID_PAYLOAD),
            json.dumps(VALID_PAYLOAD, sort_keys=True, separators=(",", ":")),
        )

    def test_wrong_schema_version_is_rejected(self) -> None:
        self.assert_invalid(schema_version="2")

    def test_wrong_repository_is_rejected(self) -> None:
        self.assert_invalid(repository="heng" + "liao1972/DavinciOO")

    def test_non_semantic_release_tag_is_rejected(self) -> None:
        for tag in ("0.58.2", "v0.58.2.0", "v0.x", "v01.58.2"):
            with self.subTest(tag=tag):
                self.assert_invalid(tag=tag)

    def test_uppercase_or_short_commit_is_rejected(self) -> None:
        for commit in ("A" * 40, "a" * 39):
            with self.subTest(commit=commit):
                self.assert_invalid(commit=commit)

    def test_nonpositive_or_noninteger_release_id_is_rejected(self) -> None:
        for release_id in (0, -1, True, "123"):
            with self.subTest(release_id=release_id):
                self.assert_invalid(release_id=release_id)

    def test_non_release_or_mismatched_release_url_is_rejected(self) -> None:
        for release_url in (
            "https://example.com/PTO-ISA/pto-spec/releases/tag/v0.58.2",
            "https://github.com/PTO-ISA/pto-spec/releases/v0.58.2",
            "https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.1",
        ):
            with self.subTest(release_url=release_url):
                self.assert_invalid(release_url=release_url)

    def test_invalid_sha256_is_rejected(self) -> None:
        for digest in ("a" * 63, "A" * 64, "g" * 64):
            with self.subTest(digest=digest):
                self.assert_invalid(release_manifest_sha256=digest)

    def test_missing_or_invalid_utc_timestamp_is_rejected(self) -> None:
        missing = dict(VALID_PAYLOAD)
        del missing["published_at"]
        self.assertTrue(validate_release_event(missing))
        for published_at in (
            "2026-08-10T00:00:00+00:00",
            "2026-08-10 00:00:00Z",
            "2026-02-30T00:00:00Z",
        ):
            with self.subTest(published_at=published_at):
                self.assert_invalid(published_at=published_at)

    def test_additional_top_level_property_is_rejected(self) -> None:
        self.assert_invalid(untrusted="value")

    def test_non_object_payload_is_rejected(self) -> None:
        for payload in (None, [], "payload", 1):
            with self.subTest(payload=payload):
                self.assertTrue(validate_release_event(payload))

    def test_canonicalization_rejects_invalid_payload(self) -> None:
        with self.assertRaises(ValueError):
            canonical_release_event({**VALID_PAYLOAD, "schema_version": "2"})


if __name__ == "__main__":
    unittest.main()
