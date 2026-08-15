import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OBSOLETE_TEST = re.compile(
    r"tests/asl/(?:main\.asl|shards(?:/|$)|[A-Za-z0-9_-]+-tests\.asl)"
)


class NumericProfileHookClosureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.profile_hooks = json.loads(
            (ROOT / "spec/profile-hooks.json").read_text(encoding="utf-8")
        )
        cls.numeric_contracts = json.loads(
            (ROOT / "spec/evidence/numeric-contracts.json").read_text(
                encoding="utf-8"
            )
        )

    def test_profile_hook_paths_are_current_files(self) -> None:
        paths = [self.profile_hooks["active_profile"]["conformance_tests"]]
        for hook in self.profile_hooks["hooks"]:
            paths.append(hook["model"])
            paths.extend(hook["tests"])

        for relative in paths:
            with self.subTest(path=relative):
                self.assertIsNone(OBSOLETE_TEST.search(relative))
                self.assertTrue((ROOT / relative).is_file())

    def test_s5_t2_hooks_match_numeric_contract_inventory(self) -> None:
        registered = {
            hook["name"]
            for hook in self.profile_hooks["hooks"]
            if hook["maturity_target"] == "S5-T2"
        }
        inventoried = {hook["name"] for hook in self.numeric_contracts["hooks"]}
        self.assertEqual(registered, inventoried)

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
