from __future__ import annotations

import copy
import unittest

from scripts.model_closure import (
    canonical_sha256,
    invocation_path,
    validate_run_envelope,
    validate_semantic_payload,
)


EXPECTED = {
    "release": "0.58.5",
    "publication_version": "0.58.5.1",
    "encoding_abi": "pto-isa-0.58.5-mode-function-v1",
    "encoding_projection_sha256": "bc0718ee31162ba7f6ea04d2a5853c49fe30e7cb36b33c0704c58678710a0c87",
    "pto_commit": "1" * 40,
    "pto_tree": "2" * 40,
    "llvm_repository": "https://github.com/LinxISA/llvm-project.git",
    "llvm_commit": "3" * 40,
    "asl_model_commit": "4" * 40,
    "ndf_commit": "5" * 40,
    "ndf_tree": "6" * 40,
    "aslref_commit": "7" * 40,
    "workflow_commit": "8" * 40,
}


def valid_payload() -> dict[str, object]:
    obligations = ["PTO-OBLIGATION-ASM-ADD"]
    cases = ["PTO-CLOSURE-SCALAR-ADD-001"]
    lock: dict[str, object] = {
        "schema": "pto-closure-lock-v1",
        "identity": {
            "release": EXPECTED["release"],
            "publication_version": EXPECTED["publication_version"],
            "encoding_abi": EXPECTED["encoding_abi"],
            "encoding_projection_sha256": EXPECTED["encoding_projection_sha256"],
        },
        "repositories": {
            "pto_spec": {
                "repository": "https://github.com/PTO-ISA/pto-spec.git",
                "commit": EXPECTED["pto_commit"],
                "tree": EXPECTED["pto_tree"],
            },
            "llvm": {
                "repository": EXPECTED["llvm_repository"],
                "commit": EXPECTED["llvm_commit"],
                "tree": "9" * 40,
            },
            "asl_model": {
                "repository": "https://github.com/PTO-ISA/asl-model.git",
                "commit": EXPECTED["asl_model_commit"],
                "tree": "a" * 40,
            },
            "normative_language": {
                "repository": "https://github.com/PTO-ISA/normative_language.git",
                "commit": EXPECTED["ndf_commit"],
                "tree": EXPECTED["ndf_tree"],
            },
            "aslref": {
                "repository": "https://github.com/PTO-ISA/herdtools7.git",
                "commit": EXPECTED["aslref_commit"],
                "tree": "b" * 40,
            },
        },
        "tools": {
            name: {"path": f"/tools/{name}", "sha256": "c" * 64}
            for name in ("clang", "llvm_mc", "ld_lld", "aslref")
        },
        "target": {"triple": "linx64-linx-none-elf"},
        "model": {
            "abi": "pto-asl-model-experimental-v2",
            "worker_protocol": "pto-asl-worker-v1",
            "backend": "reference-array",
            "profile": "bounded-reference-v1",
        },
        "corpus": {"sha256": "d" * 64, "case_ids": cases},
        "obligations": {
            "affected_pto_ids": ["PTO-INST-SCALAR-ADD"],
            "selected": obligations,
            "sha256": canonical_sha256(obligations),
        },
    }
    return {
        "schema": "pto-closure-semantic-payload-v1",
        "closure_lock": lock,
        "closure_lock_sha256": canonical_sha256(lock),
        "ndf_impact": {
            "sha256": "e" * 64,
            "affected_pto_ids": ["PTO-INST-SCALAR-ADD"],
        },
        "obligations": {
            "selected": obligations,
            "completed": obligations,
            "passed": obligations,
            "failed": [],
        },
        "cases": {
            "selected": cases,
            "completed": cases,
            "passed": cases,
            "failed": [],
            "skipped": [],
            "timeout": [],
            "unknown": [],
        },
        "case_manifests": [{"case_id": cases[0], "sha256": "f" * 64}],
    }


def valid_envelope(payload: object) -> dict[str, object]:
    return {
        "schema": "pto-closure-run-envelope-v1",
        "semantic_payload_sha256": canonical_sha256(payload),
        "workflow": {
            "repository": "PTO-ISA/pto-spec",
            "path": ".github/workflows/release.yml",
            "commit": EXPECTED["workflow_commit"],
        },
        "run": {"id": "1234", "attempt": 1, "timestamp": "2026-09-02T10:00:00Z"},
        "runner": {"image": "ubuntu-24.04", "builder_identity": "github-hosted"},
        "artifact_sha256": "0" * 64,
        "attestation": None,
    }


class ModelClosureTest(unittest.TestCase):
    def test_invocation_path_preserves_driver_symlink_name(self) -> None:
        import pathlib
        import tempfile

        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            driver = root / "lld"
            driver.write_text("driver", encoding="utf-8")
            alias = root / "ld.lld"
            alias.symlink_to(driver)
            self.assertEqual(invocation_path(alias), alias.absolute())
            self.assertEqual(invocation_path(alias).name, "ld.lld")

    def test_complete_same_run_closure_is_accepted(self) -> None:
        payload = valid_payload()
        envelope = valid_envelope(payload)
        self.assertEqual(validate_semantic_payload(payload, EXPECTED), [])
        self.assertEqual(
            validate_run_envelope(
                envelope,
                payload,
                EXPECTED,
                expected_run_id="1234",
                expected_run_attempt="1",
            ),
            [],
        )

    def test_any_identity_drift_is_rejected(self) -> None:
        payload = valid_payload()
        payload["closure_lock"]["identity"]["encoding_projection_sha256"] = "0" * 64
        errors = validate_semantic_payload(payload, EXPECTED)
        self.assertTrue(any("encoding projection" in error for error in errors), errors)

    def test_obligation_and_case_domains_are_checked_separately(self) -> None:
        payload = valid_payload()
        payload["obligations"]["passed"] = []
        payload["cases"]["completed"] = []
        errors = validate_semantic_payload(payload, EXPECTED)
        self.assertIn(
            "selected, completed, and passed obligation sets must be equal", errors
        )
        self.assertIn("selected, completed, and passed case sets must be equal", errors)

    def test_failed_skipped_timeout_or_unknown_cases_are_rejected(self) -> None:
        for field in ("failed", "skipped", "timeout", "unknown"):
            with self.subTest(field=field):
                payload = valid_payload()
                payload["cases"][field] = ["PTO-CLOSURE-BAD"]
                errors = validate_semantic_payload(payload, EXPECTED)
                self.assertIn(f"{field} case set must be empty", errors)

    def test_envelope_recomputes_payload_digest_and_rejects_attestation(self) -> None:
        payload = valid_payload()
        envelope = valid_envelope(payload)
        envelope["semantic_payload_sha256"] = "0" * 64
        envelope["attestation"] = {"issuer": "untrusted"}
        errors = validate_run_envelope(envelope, payload, EXPECTED)
        self.assertIn("run envelope semantic payload digest mismatch", errors)
        self.assertIn("bootstrap release closure must not accept external attestation", errors)

    def test_payload_and_envelope_allow_different_run_provenance(self) -> None:
        payload = valid_payload()
        first = valid_envelope(payload)
        second = copy.deepcopy(first)
        second["run"] = {
            "id": "1235",
            "attempt": 2,
            "timestamp": "2026-09-02T11:00:00Z",
        }
        self.assertEqual(first["semantic_payload_sha256"], second["semantic_payload_sha256"])
        self.assertNotEqual(first, second)
        self.assertEqual(validate_run_envelope(first, payload, EXPECTED), [])
        self.assertEqual(validate_run_envelope(second, payload, EXPECTED), [])


if __name__ == "__main__":
    unittest.main()
