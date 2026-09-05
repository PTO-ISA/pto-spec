from __future__ import annotations

import json
import runpy
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from scripts.release_preflight import (
    _git_head,
    _case_mapping,
    affected_pto_ids,
    approved_release_identity,
    validate_preflight,
)


ROOT = Path(__file__).resolve().parents[2]
COMMITS = {"pto": "a" * 40, "llvm": "b" * 40, "asl_model": "c" * 40, "workflow": "a" * 40}
IDENTITY = {
    "release": "0.58.5",
    "publication_version": "0.58.5.1",
    "encoding_abi": "pto-isa-0.58.5-mode-function-v1",
    "encoding_projection_sha256": "d" * 64,
}
MANDATORY = ["mandatory_case"]


def impact(pto_id: str = "PTO-INST-BLOCK-BSTART-TIMG2COL") -> dict[str, object]:
    return {
        "schema_version": "0.1", "command": "impact pto-release", "ok": True,
        "diagnostics": [], "data": {"schema_version": "1", "changes": [
            {"uri": f"ndf://pto-spec/{pto_id}", "kind": "modified"}
        ], "conformance_targets": []},
    }


def case(case_id: str, pto_ids: list[str]) -> dict[str, object]:
    return {
        "schema": "pto-avs-case-v1", "case_id": case_id, "lane": "asm",
        "source": "source.S", "linker_script": "link.ld", "pto_ids": pto_ids,
        "obligation_ids": ["ASLMODEL-VERIF-001"], "features": [], "avs_ids": [],
        "expected_length_sequence": [32],
        "compile": {"tool": "llvm_mc", "arguments": []},
        "link": {"tool": "ld_lld", "arguments": []},
        "execution": {"start_acr": 0, "start_symbol": "_start", "return_symbol": "return",
            "stop_symbol": "stop", "result_symbol": "result", "result_size_symbol": "result_size",
            "stop_after_hits": 1, "max_steps": 16, "stack_top": 4096, "host_request": None},
        "model": {"abi": "pto-asl-model-experimental-v2", "backend": "host-sparse",
            "profile": "bounded-reference-v1"},
        "golden": {"path": "golden.bin", "provenance": {"model_generated": False}},
        "profile": "pto-v0", "resource_class": "small", "timeout_seconds": 60,
    }


def validate_case_fixture(value: object) -> object:
    expected = {"schema", "case_id", "lane", "source", "linker_script", "pto_ids",
        "obligation_ids", "features", "avs_ids", "expected_length_sequence", "compile",
        "link", "execution", "model", "golden", "profile", "resource_class", "timeout_seconds"}
    if not isinstance(value, dict) or set(value) != expected or value["schema"] != "pto-avs-case-v1":
        raise ValueError("AVS case schema mismatch")
    return value


def load_case_fixtures(root: Path) -> dict[str, tuple[Path, dict[str, object]]]:
    result = {}
    for path in sorted(root.glob("*/case.yaml")):
        value = validate_case_fixture(json.loads(path.read_text()))
        case_id = str(value["case_id"])
        if path.parent.name != case_id:
            raise ValueError("directory and case_id differ")
        result[case_id] = (path.parent, value)
    return result


class Fixture:
    def __init__(self, root: Path) -> None:
        self.pto, self.llvm, self.model = root / "pto", root / "llvm", root / "model"
        for path in (self.pto / "spec", self.pto / "scripts", self.pto / "tools/ndf",
                     self.llvm / "llvm/utils/pto", self.llvm / "llvm/include/llvm/BinaryFormat",
                     self.model / "avs/cases/mapped_case", self.model / "avs/cases/mandatory_case"):
            path.mkdir(parents=True)
        (self.pto / "specification.toml").write_text(
            "[release]\narchitecture_version='0.58.5'\npublication_version='0.58.5.1'\n"
            "encoding_abi='pto-isa-0.58.5-mode-function-v1'\n", encoding="utf-8")
        (self.pto / "spec/release-manifest.json").write_text(json.dumps({
            "release": IDENTITY["release"], "publication_version": IDENTITY["publication_version"],
            "encoding_abi": IDENTITY["encoding_abi"],
            "encoding_projection_sha256": IDENTITY["encoding_projection_sha256"],
        }), encoding="utf-8")
        self.selection = {"schema": "pto.model-closure-selection.v1", "release": IDENTITY["release"],
            "adoption_baseline_commit": "e" * 40, "mandatory_case_ids": MANDATORY}
        self.write_selection()
        (self.pto / ".aslref-version").write_text("f" * 40 + "\n", encoding="utf-8")
        (self.model / "pto-lock.json").write_text(json.dumps({
            "architecture_version": IDENTITY["release"],
            "publication_version": IDENTITY["publication_version"],
            "encoding_abi": IDENTITY["encoding_abi"],
            "encoding_projection_sha256": IDENTITY["encoding_projection_sha256"],
        }), encoding="utf-8")
        self.write_pins()
        self.write_case("mapped_case", ["PTO-INST-BLOCK-BSTART-TIMG2COL"])
        self.write_case("mandatory_case", ["PTO-INST-SCALAR-ACRC"])
        self.impact = root / "impact.json"
        self.impact.write_text(json.dumps(impact()), encoding="utf-8")

    def write_selection(self) -> None:
        (self.pto / "spec/model-closure-selection.json").write_text(json.dumps(self.selection), encoding="utf-8")

    def write_pins(self, ndf: str = "1" * 40, pto: str = "2" * 40) -> None:
        (self.model / "ndf.lock").write_text(
            f'format_version: "0.1"\ndependencies:\n  ndf:\n    revision: {ndf}\n'
            f'  pto-spec:\n    revision: {pto}\n', encoding="utf-8")

    def write_case(self, case_id: str, pto_ids: list[str], directory: str | None = None) -> None:
        path = self.model / "avs/cases" / (directory or case_id) / "case.yaml"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(case(case_id, pto_ids)), encoding="utf-8")

    def validate(self) -> dict[str, object]:
        def mapping(root, affected):
            return _case_mapping(root, affected, load_case_fixtures)
        self.run_command = mock.Mock()
        with mock.patch("scripts.release_preflight._git_head",
                        side_effect=[COMMITS["pto"], COMMITS["llvm"], COMMITS["asl_model"],
                                     "1" * 40, "2" * 40, "3" * 40]):
            return validate_preflight(
                pto_root=self.pto, llvm_root=self.llvm, asl_model_root=self.model,
                pto_commit=COMMITS["pto"], llvm_commit=COMMITS["llvm"],
                asl_model_commit=COMMITS["asl_model"], workflow_commit=COMMITS["workflow"],
                impact_path=self.impact, case_mapping=mapping, run_command=self.run_command)


class ReleasePreflightTest(unittest.TestCase):
    def test_dirty_checkout_cannot_reuse_a_clean_commit_identity(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for args in (
                ("init", "-q"),
                ("config", "user.email", "agent@example.invalid"),
                ("config", "user.name", "fixture"),
                ("config", "commit.gpgsign", "false"),
            ):
                subprocess.run(["git", "-C", str(root), *args], check=True, capture_output=True)
            source = root / "source.txt"
            source.write_text("reviewed\n")
            subprocess.run(["git", "-C", str(root), "add", "source.txt"], check=True)
            subprocess.run(["git", "-C", str(root), "commit", "-qm", "fixture"], check=True)
            self.assertEqual(len(_git_head(root)), 40)
            source.write_text("unreviewed\n")
            with self.assertRaisesRegex(ValueError, "checkout is dirty"):
                _git_head(root)

    def test_approved_identity_has_one_checked_in_source(self) -> None:
        identity = approved_release_identity(ROOT)
        runner = runpy.run_path(str(ROOT / "scripts/run-model-closure"))
        self.assertEqual(runner["_identity"](), identity)
        source = (ROOT / "scripts/run-model-closure").read_text(encoding="utf-8")
        self.assertNotIn("EXPECTED_RELEASE", source)
        self.assertNotIn("EXPECTED_PROJECTION", source)

    def test_affected_instruction_identity_is_selected(self) -> None:
        self.assertEqual(affected_pto_ids(impact()), ["PTO-INST-BLOCK-BSTART-TIMG2COL"])

    def test_preflight_records_identity_pins_and_explicit_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            result = fixture.validate()
        self.assertEqual(result["commits"], COMMITS)
        self.assertEqual(result["dependencies"], {"pto_ndf": "3" * 40,
            "asl_model_ndf": "1" * 40, "aslref": "f" * 40})
        self.assertEqual(result["selection"], {"mandatory_case_ids": MANDATORY})
        self.assertEqual(result["impact"]["avs_cases_by_pto_id"], {
            "PTO-INST-BLOCK-BSTART-TIMG2COL": ["mapped_case"]})
        self.assertNotEqual(result["baselines"]["model_graph_import"], COMMITS["pto"])
        commands = [call.args[0] for call in fixture.run_command.call_args_list]
        self.assertEqual(commands[0], [str(fixture.pto / "scripts/check-release-manifest")])
        self.assertIn("--check", commands[1])
        self.assertIn(str(fixture.pto / "spec/release-manifest.json"), commands[1])

    def test_absent_affected_case_is_rejected_before_build(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            fixture.impact.write_text(json.dumps(impact("PTO-INST-TILE-NO-SUCH-CASE")))
            with self.assertRaisesRegex(ValueError, "no explicit ASL-MODEL AVS case"):
                fixture.validate()

    def test_missing_mandatory_case_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            (fixture.model / "avs/cases/mandatory_case/case.yaml").unlink()
            with self.assertRaisesRegex(ValueError, "mandatory ASL-MODEL AVS cases"):
                fixture.validate()

    def test_duplicate_case_identity_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            fixture.write_case("mapped_case", ["PTO-INST-SCALAR-ACRC"], "duplicate")
            with self.assertRaisesRegex(ValueError, "directory and case_id differ"):
                fixture.validate()

    def test_asl_model_identity_mismatch_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            lock = json.loads((fixture.model / "pto-lock.json").read_text())
            lock["encoding_projection_sha256"] = "0" * 64
            (fixture.model / "pto-lock.json").write_text(json.dumps(lock))
            with self.assertRaisesRegex(ValueError, "differs from PTO-SPEC"):
                fixture.validate()

    def test_malformed_model_pins_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            fixture.write_pins(ndf="not-a-commit")
            with self.assertRaisesRegex(ValueError, "dependency set mismatch"):
                fixture.validate()

    def test_wrong_model_ndf_checkout_is_rejected_before_commands(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            mapping = mock.Mock()
            run_command = mock.Mock()
            with mock.patch("scripts.release_preflight._git_head", side_effect=[
                COMMITS["pto"], COMMITS["llvm"], COMMITS["asl_model"], "9" * 40,
            ]):
                with self.assertRaisesRegex(ValueError, "NDF checkout differs"):
                    validate_preflight(
                        pto_root=fixture.pto, llvm_root=fixture.llvm,
                        asl_model_root=fixture.model, pto_commit=COMMITS["pto"],
                        llvm_commit=COMMITS["llvm"], asl_model_commit=COMMITS["asl_model"],
                        workflow_commit=COMMITS["workflow"], impact_path=fixture.impact,
                        case_mapping=mapping, run_command=run_command)
            run_command.assert_not_called()
            mapping.assert_not_called()

    def test_wrong_imported_graph_checkout_is_rejected_before_commands(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            mapping = mock.Mock()
            run_command = mock.Mock()
            with mock.patch("scripts.release_preflight._git_head", side_effect=[
                COMMITS["pto"], COMMITS["llvm"], COMMITS["asl_model"], "1" * 40, "9" * 40,
            ]):
                with self.assertRaisesRegex(ValueError, "imported PTO graph differs"):
                    validate_preflight(
                        pto_root=fixture.pto, llvm_root=fixture.llvm,
                        asl_model_root=fixture.model, pto_commit=COMMITS["pto"],
                        llvm_commit=COMMITS["llvm"], asl_model_commit=COMMITS["asl_model"],
                        workflow_commit=COMMITS["workflow"], impact_path=fixture.impact,
                        case_mapping=mapping, run_command=run_command)
            run_command.assert_not_called()
            mapping.assert_not_called()

    def test_approved_identity_drift_is_rejected_independently(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            fixture = Fixture(Path(directory))
            fixture.selection["release"] = "0.58.4"
            fixture.write_selection()
            with self.assertRaisesRegex(ValueError, "selection release mismatch"):
                approved_release_identity(fixture.pto)

    def test_cli_failure_diagnostic_gives_agent_next_action(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            diagnostics = root / "diagnostics.json"
            result = subprocess.run(
                [str(ROOT / "scripts/check-release-preflight"),
                 "--llvm-root", str(root / "llvm"),
                 "--asl-model-root", str(root / "model"),
                 "--pto-commit", "a" * 40, "--llvm-commit", "b" * 40,
                 "--asl-model-commit", "c" * 40, "--workflow-commit", "d" * 40,
                 "--impact", str(root / "impact.json"),
                 "--output", str(root / "candidate.json"),
                 "--diagnostics", str(diagnostics)],
                cwd=ROOT, text=True, capture_output=True, check=False,
            )
            report = json.loads(diagnostics.read_text())
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(report["ok"])
        self.assertIn("commit the fix", report["next_action"])


if __name__ == "__main__":
    unittest.main()
