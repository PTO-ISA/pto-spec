from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts.adr_records import load_adrs


ROOT = Path(__file__).resolve().parents[2]
CHECKER = ROOT / "scripts/check-release-closure"
REGISTRY = ROOT / "spec/release-inputs.json"
MAKEFILE = ROOT / "Makefile"
RELEASE_GATE = ROOT / "spec/evidence/release-gate-readiness.json"
SPECIFICATION = ROOT / "specification.toml"
RELEASE_GENERATOR = ROOT / "scripts/generate-release-manifest"
TRACEABILITY = ROOT / "spec/evidence/release-traceability-readiness.json"


def pending_release_decisions() -> tuple[str, ...]:
    return tuple(
        record.adr_id
        for record in load_adrs(ROOT / "docs/status/decisions")
        if record.status == "accepted"
        and record.release_impact == "required"
        and "unassigned" in record.target_releases
    )


class ReleaseClosureTest(unittest.TestCase):
    def test_release_identity_is_0584_and_owns_0584_evidence(self) -> None:
        specification = SPECIFICATION.read_text(encoding="utf-8")
        generator = RELEASE_GENERATOR.read_text(encoding="utf-8")

        self.assertIn('architecture_version = "0.58.4"', specification)
        self.assertIn(
            'encoding_abi = "pto-isa-0.58.4-mode-function-v1"', specification
        )
        self.assertIn('RELEASE = "0.58.4"', generator)
        self.assertIn(
            'ENCODING_ABI = "pto-isa-0.58.4-mode-function-v1"', generator
        )
        self.assertIn("pto-isa-0584-encoding-totality.json", generator)

    def test_release_gate_provenance_covers_workflow_validator_implementation(
        self,
    ) -> None:
        gate = json.loads(RELEASE_GATE.read_text(encoding="utf-8"))
        self.assertIn("scripts/check-release-workflow", gate["sources"])
        self.assertIn("scripts/check-release-event-schema", gate["sources"])
        self.assertIn("scripts/release_event.py", gate["sources"])
        self.assertIn(
            "spec/schemas/pto-spec-release-event-v1.schema.json", gate["sources"]
        )
        self.assertIn("scripts/release_workflow.py", gate["sources"])
        self.assertIn("scripts/tile_taxonomy.py", gate["sources"])
        self.assertIn("scripts/instruction_contracts.py", gate["sources"])
        self.assertIn("scripts/generate-instruction-contract-closure", gate["sources"])
        self.assertIn("scripts/manual_semantic_audit.py", gate["sources"])
        for path in (
            "scripts/release_selection.py",
            "spec/evidence/architecture-readiness.json",
            "spec/release-selection.json",
            "spec/schemas/pto-release-selection.schema.json",
        ):
            self.assertIn(path, gate["sources"])
        release_closure = next(row for row in gate["gates"] if row["id"] == "RG-06")
        self.assertIn("spec/release-selection.json", release_closure["evidence"])
        self.assertIn("scripts/release_selection.py", release_closure["evidence"])
        self.assertIn(
            {
                "id": "RG-10",
                "name": "formal mnemonic implementation closure",
                "command": "python3 scripts/manual_semantic_audit.py",
                "evidence": ["scripts/manual_semantic_audit.py"],
            },
            gate["gates"],
        )

    def test_release_targets_require_fresh_canonical_evidence(self) -> None:
        makefile = MAKEFILE.read_text(encoding="utf-8")
        self.assertIn(
            "release-evidence-check:\n"
            "\t./scripts/generate-instruction-contract-closure --check\n"
            "\tpython3 scripts/manual_semantic_audit.py\n"
            "\t./scripts/generate-release-traceability-readiness --check\n"
            "\t./scripts/generate-architecture-readiness --check\n"
            "\t./scripts/generate-release-gate-readiness --check\n"
            "\t./scripts/check-release-closure\n"
            "\t./scripts/check-binary-closure --release\n"
            "\t./scripts/check-release-manifest\n",
            makefile,
        )
        self.assertIn("release-prepare: release-evidence-check", makefile)
        self.assertIn(
            "release-check: pr-check release-evidence-check toolchain-check check",
            makefile,
        )

    def test_canonical_generators_reject_stale_artifacts(self) -> None:
        for generator in (
            ROOT / "scripts/generate-instruction-contract-closure",
            ROOT / "scripts/generate-release-traceability-readiness",
            ROOT / "scripts/generate-release-gate-readiness",
        ):
            with self.subTest(generator=generator.name):
                with tempfile.TemporaryDirectory() as directory:
                    stale = Path(directory) / "stale.json"
                    stale.write_text("{}\n", encoding="utf-8")
                    result = subprocess.run(
                        [str(generator), "--check", "--output", str(stale)],
                        cwd=ROOT,
                        text=True,
                        capture_output=True,
                        check=False,
                    )
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("stale generated artifact", result.stderr)

    def test_obsolete_independent_owners_are_retired(self) -> None:
        self.assertFalse((ROOT / "scripts/check-catalogs").exists())
        self.assertFalse((ROOT / "spec/requirements.json").exists())

    def test_explicit_registry_owns_every_canonical_evidence_file(self) -> None:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        self.assertEqual(registry["schema"], "pto.release-inputs.v1")
        paths = [row["path"] for row in registry["evidence"]]
        self.assertEqual(len(paths), len(set(paths)))
        self.assertEqual(
            set(paths),
            {
                "spec/evidence/pto-isa-0584-abi-vectors.json",
                "spec/evidence/pto-isa-0584-encoding-totality.json",
                "spec/evidence/pto-isa-0584-hardware-numeric-vectors.json",
                "spec/evidence/architecture-readiness.json",
                "spec/evidence/instruction-contract-closure.json",
                "spec/evidence/release-gate-readiness.json",
                "spec/evidence/release-traceability-readiness.json",
                "spec/schemas/pto-spec-release-event-v1.schema.json",
            },
        )
        for row in registry["evidence"]:
            self.assertTrue((ROOT / row["path"]).is_file())
            self.assertTrue((ROOT / row["generator"]).is_file())

    def test_release_traceability_links_derived_readiness_subjects(self) -> None:
        traceability = json.loads(TRACEABILITY.read_text(encoding="utf-8"))
        units = {row["id"]: row for row in traceability["units"]}
        requirements = {row["id"]: row for row in traceability["requirements"]}

        self.assertEqual(
            traceability["derivation"]["architecture_readiness_projection"],
            "spec/evidence/architecture-readiness.json",
        )
        self.assertIn(
            "ADR-0047",
            units["PTO-ARCH-DATA-TYPES-ROUNDING"]["readiness_subjects"],
        )
        self.assertIn(
            "ADR-0047",
            requirements["PTO-TCVT-CONTRACT-001"]["readiness_subjects"],
        )

    def test_current_release_selection_has_no_blockers(self) -> None:
        pending = pending_release_decisions()
        if pending:
            self.skipTest(
                "release closure intentionally remains stale until pending "
                f"decisions receive a release identity: {', '.join(pending)}"
            )
        result = subprocess.run(
            [str(CHECKER)], cwd=ROOT, text=True, capture_output=True, check=False
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("release closure passed", result.stdout)

    def test_checker_rejects_legacy_and_missing_paths_in_registered_evidence(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "spec/evidence").mkdir(parents=True)
            (root / "scripts").mkdir()
            (root / "scripts/generator").write_text("#!/bin/true\n", encoding="utf-8")
            (root / "spec/evidence/bad.json").write_text(
                json.dumps(
                    {
                        "legacy": "docs/status/legacy/root/architecture.md",
                        "missing": "tests/asl/missing.asl",
                    }
                ),
                encoding="utf-8",
            )
            (root / "spec/release-inputs.json").write_text(
                json.dumps(
                    {
                        "schema": "pto.release-inputs.v1",
                        "evidence": [
                            {
                                "path": "spec/evidence/bad.json",
                                "generator": "scripts/generator",
                                "role": "canonical-input",
                            }
                        ],
                    }
                ),
                encoding="utf-8",
            )

            result = subprocess.run(
                [str(CHECKER), "--root", str(root)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("legacy", result.stderr)
            self.assertIn("missing active path", result.stderr)


if __name__ == "__main__":
    unittest.main()
