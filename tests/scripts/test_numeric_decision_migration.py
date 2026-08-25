import copy
import json
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest

from scripts.adr_records import load_adrs


ROOT = Path(__file__).resolve().parents[2]
FORMER_PD_IDS = {f"PD-{value:02d}" for value in range(1, 13)}
EXPECTED_MAPPING = {
    "PD-01": "ADR-0086",
    "PD-02": "ADR-0087",
    "PD-03": "ADR-0047",
    "PD-04": "ADR-0049",
    "PD-05": "ADR-0088",
    "PD-06": "ADR-0089",
    "PD-07": "ADR-0090",
    "PD-08": "ADR-0091",
    "PD-09": "ADR-0092",
    "PD-10": "ADR-0093",
    "PD-11": "ADR-0094",
    "PD-12": "ADR-0095",
}
ALL_NUMERIC_DOMAINS = {
    "cube-matrix",
    "scalar-binary",
    "scalar-fp-convert",
    "scalar-fp-to-integer",
    "scalar-fused",
    "scalar-integer-to-fp",
    "scalar-unary",
    "tile-binary",
    "tile-compare",
    "tile-convert",
    "tile-dequantize",
    "tile-expand",
    "tile-fused",
    "tile-order",
    "tile-partial",
    "tile-quantize",
    "tile-reduction",
    "tile-unary",
}
EXPECTED_DOMAINS_BY_ADR = {
    "ADR-0047": ALL_NUMERIC_DOMAINS - {"tile-compare", "tile-order"},
    "ADR-0049": ALL_NUMERIC_DOMAINS
    - {
        "scalar-fp-to-integer",
        "scalar-integer-to-fp",
        "tile-compare",
        "tile-order",
    },
    "ADR-0086": ALL_NUMERIC_DOMAINS,
    "ADR-0087": ALL_NUMERIC_DOMAINS,
    "ADR-0088": ALL_NUMERIC_DOMAINS - {"scalar-integer-to-fp"},
    "ADR-0089": {
        "scalar-binary",
        "scalar-fp-convert",
        "scalar-fp-to-integer",
        "scalar-fused",
        "scalar-integer-to-fp",
        "scalar-unary",
    },
    "ADR-0090": {
        "scalar-fp-convert",
        "scalar-fp-to-integer",
        "scalar-integer-to-fp",
        "tile-convert",
        "tile-dequantize",
        "tile-quantize",
    },
    "ADR-0091": {
        "scalar-binary",
        "scalar-unary",
        "tile-binary",
        "tile-expand",
        "tile-unary",
    },
    "ADR-0092": {"tile-compare", "tile-order", "tile-partial", "tile-reduction"},
    "ADR-0093": {"tile-dequantize", "tile-quantize"},
    "ADR-0094": {"cube-matrix"},
    "ADR-0095": ALL_NUMERIC_DOMAINS,
}


class NumericDecisionMigrationTest(unittest.TestCase):
    def script_namespace(self, name: str) -> dict[str, object]:
        return runpy.run_path(str(ROOT / "scripts" / name))

    def test_every_pd_maps_to_one_adr(self) -> None:
        index = json.loads(
            (ROOT / "spec/evidence/adr-index.json").read_text(encoding="utf-8")
        )
        owners = {
            key: value
            for key, value in index["legacy_map"].items()
            if key.startswith("PD-") and len(key) == len("PD-00")
        }
        self.assertEqual(set(owners), FORMER_PD_IDS)
        self.assertEqual(owners, EXPECTED_MAPPING)

    def test_open_numeric_decisions_are_draft_adrs(self) -> None:
        records = {
            record.adr_id: record
            for record in load_adrs(ROOT / "docs/status/decisions")
        }
        draft_legacy = {
            legacy_id
            for record in records.values()
            if record.status == "draft"
            for legacy_id in record.legacy_ids
            if legacy_id in FORMER_PD_IDS
        }
        self.assertEqual(draft_legacy, FORMER_PD_IDS - {"PD-03", "PD-04"})
        self.assertEqual(records["ADR-0047"].status, "accepted")
        self.assertEqual(records["ADR-0049"].status, "accepted")

    def test_numeric_evidence_uses_adr_ids_and_preserves_maturity(self) -> None:
        inputs = json.loads(
            (ROOT / "spec/evidence/numeric-profile-decision-inputs.json").read_text(
                encoding="utf-8"
            )
        )
        proposals = json.loads(
            (
                ROOT / "spec/evidence/numeric-profile-decision-proposals.json"
            ).read_text(encoding="utf-8")
        )
        rows = inputs["decisions"]
        self.assertEqual({row["adr"] for row in rows}, set(EXPECTED_MAPPING.values()))
        self.assertEqual(sum(row["status"] == "accepted" for row in rows), 2)
        self.assertEqual(proposals["summary"]["accepted_decision_count"], 2)
        self.assertEqual(proposals["summary"]["accepted_domain_rule_count"], 0)
        self.assertFalse(proposals["summary"]["can_close_s5_t2_a"])

    def test_accepted_numeric_checkpoints_retain_0571_applicability(self) -> None:
        accepted_profile = "pto-hardware-numeric-0.57.1-ieee-v1"
        for relative in (
            "spec/evidence/numeric-subnormal-contract.json",
            "spec/evidence/numeric-special-value-contract.json",
        ):
            artifact = json.loads((ROOT / relative).read_text(encoding="utf-8"))
            self.assertEqual(artifact["profile_id"], accepted_profile)
        for relative in (
            "docs/status/decisions/0049-hardware-subnormal-policy.md",
            "docs/status/decisions/0050-hardware-special-value-checkpoint.md",
        ):
            self.assertIn(
                accepted_profile,
                (ROOT / relative).read_text(encoding="utf-8"),
            )

    def test_accepted_adr_counts_match_generated_contracts(self) -> None:
        rounding = json.loads(
            (ROOT / "spec/evidence/numeric-rounding-selector-contract.json").read_text(
                encoding="utf-8"
            )
        )["summary"]
        subnormal = json.loads(
            (ROOT / "spec/evidence/numeric-subnormal-contract.json").read_text(
                encoding="utf-8"
            )
        )["summary"]
        rounding_body = (
            ROOT / "docs/status/decisions/0047-numeric-rounding-semantics.md"
        ).read_text(encoding="utf-8")
        subnormal_body = (
            ROOT / "docs/status/decisions/0049-hardware-subnormal-policy.md"
        ).read_text(encoding="utf-8")

        self.assertIn(
            f"{rounding['affected_domain_count']} affected rounding domains and "
            f"{rounding['affected_operation_count']} affected operations",
            rounding_body,
        )
        self.assertIn(
            f"{subnormal['affected_operation_count']} compressed operation rows",
            subnormal_body,
        )
        self.assertIn(
            f"{subnormal['conditional_operation_type_tuple_count']:,} "
            "operation/type obligations",
            subnormal_body,
        )

    def test_active_numeric_surfaces_contain_no_pd_identity(self) -> None:
        result = subprocess.run(
            [
                "git",
                "grep",
                "-nE",
                r"(^|[^A-Z0-9_])PD-[0-9]{2}",
                "--",
                "asl/**",
                "scripts/generate-numeric-*",
                "spec/catalog/**",
                "spec/evidence/*.json",
                ":!spec/evidence/adr-index.json",
                "tests/asl/**",
            ],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 1, result.stdout)

    def test_open_index_is_generated_from_draft_adrs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "adr-index.json"
            open_output = Path(directory) / "open-index.md"
            result = subprocess.run(
                [
                    str(ROOT / "scripts/generate-adr-index"),
                    "--output",
                    str(output),
                    "--open-output",
                    str(open_output),
                ],
                cwd=ROOT,
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            rendered = open_output.read_text(encoding="utf-8")
        self.assertTrue(rendered.startswith("<!-- GENERATED FILE"))
        for adr_id in sorted(FORMER_PD_IDS - {"PD-03", "PD-04"}):
            mapped = EXPECTED_MAPPING[adr_id]
            self.assertIn(mapped, rendered)
        self.assertIn("Target release", rendered)
        self.assertIn("Implementation issue", rendered)
        self.assertIn("Affected NDF clauses", rendered)
        self.assertIn("Blockers", rendered)
        self.assertIn("../../../spec/evidence/architecture-readiness.json", rendered)

    def test_failed_comparison_evidence_rejects_numeric_generation(self) -> None:
        for script_name in (
            "generate-numeric-profile-decision-inputs",
            "generate-numeric-subnormal-contract",
            "generate-numeric-special-value-contract",
        ):
            with self.subTest(script=script_name):
                namespace = self.script_namespace(script_name)
                generate = namespace["generate"]
                original_load = generate.__globals__["load"]

                def load_with_failed_comparison(path):
                    data = copy.deepcopy(original_load(path))
                    if Path(path).name == "executable-model-comparison.json":
                        data["status"] = "comparison-matrix-closed-gate-open:S5-T3-G2"
                        data["closure_judgment"] = {
                            "can_close_s5_t3": False,
                            "remaining_blockers": ["documentation-check failed"],
                        }
                        formats = json.loads(
                            (
                                ROOT
                                / "spec/evidence/numeric-format-namespace-contract.json"
                            ).read_text(encoding="utf-8")
                        )
                        data["snapshot"]["revision_sha256"] = formats[
                            "independent_comparison"
                        ]["provenance_sha256"]
                    if Path(path).name == "hardware-conformance-profile.json":
                        profile_id = generate.__globals__.get("EVIDENCE_PROFILE_ID")
                        if profile_id is not None:
                            data["profile_id"] = profile_id
                            data["subnormal_policy"]["profile_selection"] = (
                                f"fixed by {profile_id}"
                            )
                    return data

                generate.__globals__["load"] = load_with_failed_comparison
                with self.assertRaisesRegex(SystemExit, "comparison.*(closed|closure)"):
                    generate()

    def test_affected_domain_parser_rejects_unknown_duplicate_and_missing(self) -> None:
        namespace = self.script_namespace("generate-numeric-profile-decision-inputs")
        parse = namespace["parse_affected_domains"]
        known = {"scalar-binary", "tile-unary"}
        cases = {
            "unknown": "## Affected domains\n\n- `unknown-domain`\n",
            "duplicate": (
                "## Affected domains\n\n- `scalar-binary`\n- `scalar-binary`\n"
            ),
            "missing": "## Context\n\nNo domain section.\n",
        }
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, body in cases.items():
                with self.subTest(case=name):
                    path = root / f"{name}.md"
                    path.write_text(body, encoding="utf-8")
                    with self.assertRaises(ValueError):
                        parse(path, known)

    def test_generated_domains_match_adr_bullet_lists(self) -> None:
        namespace = self.script_namespace("generate-numeric-profile-decision-inputs")
        parse = namespace["parse_affected_domains"]
        inputs = json.loads(
            (ROOT / "spec/evidence/numeric-profile-decision-inputs.json").read_text(
                encoding="utf-8"
            )
        )
        records = {
            record.adr_id: record
            for record in load_adrs(ROOT / "docs/status/decisions")
        }
        known = {row["domain"] for row in inputs["domain_matrix"]}
        for row in inputs["decisions"]:
            with self.subTest(adr=row["adr"]):
                self.assertEqual(
                    set(row["affected_domains"]), EXPECTED_DOMAINS_BY_ADR[row["adr"]]
                )
                self.assertEqual(
                    row["affected_domains"],
                    list(parse(records[row["adr"]].path, known)),
                )


if __name__ == "__main__":
    unittest.main()
