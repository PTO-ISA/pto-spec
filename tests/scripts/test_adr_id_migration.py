from __future__ import annotations

import hashlib
import json
from pathlib import Path
import runpy
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
CHECK = runpy.run_path(str(ROOT / "scripts/check-adr-id-migration"))
validate_migration = CHECK["validate_migration"]
ALLOWED_TYPES = CHECK["ALLOWED_TYPES"]


class AdrIdMigrationTest(unittest.TestCase):
    def write_adr(self, root: Path, path: str, adr_id: str, body: str) -> None:
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(
            f'---\n{{"id": "{adr_id}"}}\n---\n{body}', encoding="utf-8"
        )

    def fixture(self, root: Path) -> tuple[Path, dict[str, object]]:
        bodies = {
            "0001": (
                "# ADR-0001\n"
                "See ADR-0003 at docs/status/decisions/0003-state.md "
                "(0003-state.md).\n"
            ),
            "0003": "# ADR-0003\n",
        }
        records = []
        for type_name, old_serial, new_serial, slug in (
            ("GOV", "0001", "0001", "scope.md"),
            ("STATE", "0003", "0001", "state.md"),
        ):
            old_path = f"docs/status/decisions/{old_serial}-{slug}"
            new_path = f"docs/status/decisions/{type_name}-{new_serial}-{slug}"
            body = bodies[old_serial]
            self.write_adr(root, old_path, f"ADR-{old_serial}", body)
            records.append(
                {
                    "old_id": f"ADR-{old_serial}",
                    "new_id": f"ADR-{type_name}-{new_serial}",
                    "old_path": old_path,
                    "new_path": new_path,
                    "type": type_name,
                    "old_body_sha256": hashlib.sha256(body.encode()).hexdigest(),
                }
            )
        document = {
            "schema": "pto.adr-id-migration",
            "schema_version": 1,
            "types": list(ALLOWED_TYPES),
            "records": records,
        }
        mapping = root / "spec/adr-id-migration.json"
        mapping.parent.mkdir(parents=True)
        mapping.write_text(json.dumps(document), encoding="utf-8")
        return mapping, document

    def test_repository_mapping_is_valid(self) -> None:
        self.assertEqual(validate_migration(ROOT, ROOT / "spec/adr-id-migration.json"), [])

    def test_pre_migration_tree_is_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mapping, _ = self.fixture(root)
            self.assertEqual(validate_migration(root, mapping), [])

    def test_post_migration_tree_with_only_mapped_tokens_changed_is_accepted(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mapping, document = self.fixture(root)
            records = document["records"]
            assert isinstance(records, list)
            for record in records:
                assert isinstance(record, dict)
                old_path = root / str(record["old_path"])
                _, body = CHECK["_front_matter_and_body"](old_path)
                old_path.unlink()
                migrated = body
                for mapped in records:
                    assert isinstance(mapped, dict)
                    migrated = migrated.replace(
                        str(mapped["old_id"]).encode(), str(mapped["new_id"]).encode()
                    )
                    migrated = migrated.replace(
                        str(mapped["old_path"]).encode(),
                        str(mapped["new_path"]).encode(),
                    )
                    migrated = migrated.replace(
                        Path(str(mapped["old_path"])).name.encode(),
                        Path(str(mapped["new_path"])).name.encode(),
                    )
                self.write_adr(
                    root,
                    str(record["new_path"]),
                    str(record["new_id"]),
                    migrated.decode(),
                )
            self.assertEqual(validate_migration(root, mapping), [])

    def test_missing_coverage_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mapping, document = self.fixture(root)
            records = document["records"]
            assert isinstance(records, list)
            records.pop()
            mapping.write_text(json.dumps(document), encoding="utf-8")
            errors = validate_migration(root, mapping)
            self.assertTrue(any("unexpected files" in error for error in errors), errors)

    def test_noncontiguous_type_serial_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mapping, document = self.fixture(root)
            records = document["records"]
            assert isinstance(records, list) and isinstance(records[0], dict)
            records[0]["new_id"] = "ADR-GOV-0002"
            records[0]["new_path"] = "docs/status/decisions/GOV-0002-scope.md"
            mapping.write_text(json.dumps(document), encoding="utf-8")
            errors = validate_migration(root, mapping)
            self.assertTrue(any("contiguous" in error for error in errors), errors)

    def test_body_change_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mapping, _ = self.fixture(root)
            path = root / "docs/status/decisions/0001-scope.md"
            path.write_text(path.read_text(encoding="utf-8") + "changed\n", encoding="utf-8")
            errors = validate_migration(root, mapping)
            self.assertTrue(any("body SHA-256" in error for error in errors), errors)

    def test_coexisting_old_and_new_paths_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            mapping, document = self.fixture(root)
            record = document["records"][0]
            assert isinstance(record, dict)
            self.write_adr(
                root, str(record["new_path"]), str(record["new_id"]), "# migrated\n"
            )
            errors = validate_migration(root, mapping)
            self.assertTrue(any("exactly one" in error for error in errors), errors)


if __name__ == "__main__":
    unittest.main()
