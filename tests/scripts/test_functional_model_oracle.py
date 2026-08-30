from __future__ import annotations

import importlib.util
from importlib.machinery import SourceFileLoader
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
ORACLE = ROOT / "scripts" / "run-functional-model-aslref"
COMPARATOR = ROOT / "scripts" / "compare-functional-model-runs"
LIBRARY = ROOT / "scripts" / "run-functional-model-library"


def load_script(name: str, path: Path):
    loader = SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    if spec is None:
        raise RuntimeError(f"cannot import {path}")
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class FunctionalModelOracleTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.oracle = load_script("functional_model_aslref_oracle", ORACLE)
        cls.comparator = load_script("functional_model_run_comparator", COMPARATOR)
        cls.library = load_script("functional_model_library_runner", LIBRARY)

    def run_manifest(self, engine: str) -> dict[str, object]:
        return {
            "schema": "linx-gfrun-asl-run-v1",
            "engine": engine,
            "model_descriptor_sha256": "12" * 32,
            "model_descriptor": {"schema": "pto-functional-model-descriptor-v1"},
            "elf": {"filename": "case.elf", "entry": 0x100},
            "stop_policy": {"kind": "stop_pc", "stop_pc": 0x102, "max_steps": 1},
            "outcome": {
                "status": "completed",
                "reason": "stop_pc",
                "steps": 1,
                "final_tpc": 0x102,
            },
            "trace": [
                {
                    "status": 0,
                    "result_valid": True,
                    "step_state": 1,
                    "instruction_status": 1,
                    "pre_tpc": 0x100,
                    "post_tpc": 0x102,
                    "pre_bpc": 0,
                    "post_bpc": 0,
                    "raw_instruction_le": 0x16,
                    "length_bits": 16,
                    "fault_code": 0,
                    "fault_address": 0,
                    "fault_cause": 0,
                    "origin_pe": 0,
                    "request_token": 0,
                    "request_type": 0,
                    "request_argument0": 0,
                    "sequence": 3,
                    "memory_write_count": 0,
                    "memory_write_sha256":
                        "c129c88090d63d98e2082e24d5f1b68e9e05b33e6580c6d7f62382208436fd25",
                    "memory_writes": [],
                    "bundle_tile_state_sha256": None,
                }
            ],
            "result": {"address": 0x200, "size": 4, "bytes_hex": "19000000"},
        }

    def write_case(self, root: Path, engine: str) -> None:
        case = root / "case"
        case.mkdir(parents=True)
        (case / "run.json").write_text(
            json.dumps(self.run_manifest(engine), indent=2, sort_keys=True) + "\n"
        )
        (case / "result.bin").write_bytes(bytes.fromhex("19000000"))

    def test_comparator_accepts_exact_architectural_match(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            aslref = root / "aslref"
            gfrun = root / "gfrun"
            self.write_case(aslref, "aslref")
            self.write_case(gfrun, "asl")
            result = self.comparator.compare_case("case", aslref, gfrun)
            self.assertEqual(result["status"], "pass")
            self.assertEqual(result["trace_step_count"], 1)

    def test_comparator_reports_first_trace_difference(self) -> None:
        left = self.run_manifest("aslref")
        right = self.run_manifest("asl")
        right["trace"][0]["post_tpc"] = 0x104
        difference = self.comparator.first_difference(
            self.comparator.comparable(left), self.comparator.comparable(right)
        )
        self.assertIn("$.trace[0].post_tpc", difference)

    def test_oracle_manifest_uses_external_descriptor_digest(self) -> None:
        case = {
            "elf": {"filename": "case.elf", "entry": 0x100},
            "isa": {
                "version": "0.58.5",
                "encoding_abi": "pto-isa-0.58.5-mode-function-v1",
                "encoding_projection_sha256": "34" * 32,
            },
            "stop_policy": {"kind": "stop_pc", "stop_pc": 0x102, "max_steps": 1},
            "expected_trace": [
                {
                    "pre_tpc": 0x100,
                    "post_tpc": 0x102,
                    "pre_bpc": 0,
                    "post_bpc": 0,
                    "raw_instruction_le": 0x16,
                    "length_bits": 16,
                    "sequence": 3,
                }
            ],
            "result": {"address": 0x200, "size": 4},
        }
        observed = self.oracle.oracle_run_manifest(
            case, {"schema": "descriptor"}, "ab" * 32
        )
        self.assertEqual(observed["model_descriptor_sha256"], "ab" * 32)

    def test_standalone_output_parser_preserves_all_step_fields(self) -> None:
        trace, result = self.library.parse_output(
            "STEP 0 1 1 256 258 0 0 22 16 0 0 0 0 0 0 0 3 0 "
            "c129c88090d63d98e2082e24d5f1b68e9e05b33e6580c6d7f62382208436fd25 "
            "1212121212121212121212121212121212121212121212121212121212121212\n"
            "RESULT 19000000\n"
        )
        self.assertEqual(result, "19000000")
        self.assertEqual(trace[0]["pre_tpc"], 256)
        self.assertEqual(trace[0]["post_tpc"], 258)
        self.assertEqual(trace[0]["raw_instruction_le"], 22)
        self.assertEqual(trace[0]["sequence"], 3)
        self.assertEqual(trace[0]["memory_write_count"], 0)
        self.assertEqual(trace[0]["memory_writes"], [])
        self.assertEqual(trace[0]["bundle_tile_state_sha256"], "12" * 32)
        self.assertTrue(trace[0]["result_valid"])


if __name__ == "__main__":
    unittest.main()
