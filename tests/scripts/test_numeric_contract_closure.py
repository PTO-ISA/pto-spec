import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OBSOLETE_TEST = re.compile(
    r"tests/asl/(?:main\.asl|shards(?:/|$)|[A-Za-z0-9_-]+-tests\.asl)"
)


class NumericContractClosureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.numeric_contracts = json.loads(
            (ROOT / "spec/evidence/numeric-contracts.json").read_text(
                encoding="utf-8"
            )
        )
        cls.scalar_forms = json.loads(
            (ROOT / "spec/catalog/scalar-forms.json").read_text(encoding="utf-8")
        )
        cls.tile_operations = json.loads(
            (ROOT / "spec/catalog/tile-operations.json").read_text(encoding="utf-8")
        )

    def test_numeric_operations_are_active_catalog_entries(self) -> None:
        active_keys = {
            f"scalar:{form['form_id']}"
            for form in self.scalar_forms["forms"]
            if form["status"] == "accepted"
        }
        active_keys.update(
            f"tile:{operation['family']}:{operation['name']}"
            for operation in self.tile_operations["operations"]
            if operation["disposition"] == "accepted-direct-operation"
        )
        for operation in self.numeric_contracts["operations"]:
            with self.subTest(operation=operation["key"]):
                self.assertIn(operation["key"], active_keys)

    def test_hook_operation_edges_are_bidirectional(self) -> None:
        operations = self.numeric_contracts["operations"]
        expected: dict[str, set[str]] = {
            hook["name"]: set() for hook in self.numeric_contracts["hooks"]
        }
        for operation in operations:
            for hook_name in operation["primary_hooks"] + operation["reference_helpers"]:
                expected[hook_name].add(operation["key"])

        for hook in self.numeric_contracts["hooks"]:
            with self.subTest(hook=hook["name"]):
                self.assertEqual(set(hook["operation_keys"]), expected[hook["name"]])

    def test_domain_hooks_match_common_primary_operation_hooks(self) -> None:
        operations_by_domain: dict[str, list[set[str]]] = {}
        for operation in self.numeric_contracts["operations"]:
            operations_by_domain.setdefault(operation["numeric_contract"], []).append(
                set(operation["primary_hooks"])
            )

        for domain in self.numeric_contracts["contract_domains"]:
            common_hooks = set.intersection(*operations_by_domain[domain["id"]])
            with self.subTest(domain=domain["id"]):
                self.assertEqual(set(domain["primary_hooks"]), common_hooks)

    def test_numeric_evidence_test_paths_are_current_files(self) -> None:
        evidence_paths = sorted((ROOT / "spec/evidence").glob("numeric-*.json"))
        evidence_paths.extend(
            [
                ROOT / "spec/evidence/public-integer-conversion-contract.json",
                ROOT / "spec/evidence/scalar-numeric-flag-contract.json",
            ]
        )

        def strings(value: object):
            if isinstance(value, str):
                yield value
            elif isinstance(value, list):
                for item in value:
                    yield from strings(item)
            elif isinstance(value, dict):
                for item in value.values():
                    yield from strings(item)

        for evidence_path in evidence_paths:
            evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
            for value in strings(evidence):
                if not value.startswith("tests/asl/"):
                    continue
                relative = value.split(":", 1)[0]
                with self.subTest(evidence=evidence_path.name, path=relative):
                    self.assertIsNone(OBSOLETE_TEST.search(relative))
                    self.assertTrue((ROOT / relative).is_file())


if __name__ == "__main__":
    unittest.main()
