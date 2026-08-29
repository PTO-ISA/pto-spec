from __future__ import annotations

import importlib.util
from importlib.machinery import SourceFileLoader
import json
from pathlib import Path
import struct
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
BUILDER = ROOT / "scripts" / "build-functional-model-corpus"
GFRUN_VALIDATOR = ROOT / "scripts" / "run-functional-model-gfrun"
CORPUS = ROOT / "tests" / "functional-model" / "corpus"


def load_builder():
    loader = SourceFileLoader("build_functional_model_corpus", str(BUILDER))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    if spec is None:
        raise RuntimeError("cannot import corpus builder")
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def load_gfrun_validator():
    loader = SourceFileLoader("run_functional_model_gfrun", str(GFRUN_VALIDATOR))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    if spec is None:
        raise RuntimeError("cannot import gfrun validator")
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def minimal_elf(*, flags: int = 5, filesz: int = 1, memsz: int = 1,
                entry: int = 0x100, second: tuple[int, int, int] | None = None) -> bytes:
    phnum = 2 if second else 1
    header = struct.pack(
        "<16sHHIQQQIHHHHHH",
        b"\x7fELF\x02\x01\x01" + bytes(9),
        2,
        233,
        1,
        entry,
        64,
        0,
        0,
        64,
        56,
        phnum,
        64,
        0,
        0,
    )
    headers = [struct.pack("<IIQQQQQQ", 1, flags, 64 + 56 * phnum,
                           0x100, 0, filesz, memsz, 1)]
    if second:
        address, second_filesz, second_memsz = second
        headers.append(struct.pack("<IIQQQQQQ", 1, 6,
                                   64 + 56 * phnum + filesz,
                                   address, 0, second_filesz,
                                   second_memsz, 1))
    return header + b"".join(headers) + bytes(filesz + (second[1] if second else 0))


class FunctionalModelCorpusTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.builder = load_builder()
        cls.validator = load_gfrun_validator()

    def test_checked_sources_contain_exact_bringup_encodings(self) -> None:
        scalar = (CORPUS / "scalar_stop_pc.S").read_text(encoding="utf-8")
        block = (CORPUS / "block_64_stop_pc.S").read_text(encoding="utf-8")
        self.assertIn("0x96,0x0a,0xd6,0x13,0x85,0x81,0x20,0x00", scalar)
        self.assertIn("0x0e,0x80,0x95,0xc0,0x00,0x00,0x16,0x00", scalar)
        self.assertIn("0x69,0xa0,0xc1,0x03", scalar)
        self.assertIn("0x11,0x00,0x00,0x00", block)
        self.assertIn("0x0f,0x00,0x00,0x00,0x01,0x00,0x00,0x00", block)
        self.assertIn("0xa5,0x5a,0x00,0x00", block)

    def test_case_contract_uses_real_length_bits_and_golden(self) -> None:
        scalar = self.builder.CASES["scalar_stop_pc"]
        block = self.builder.CASES["block_64_stop_pc"]
        self.assertEqual(scalar["lengths"], [16, 16, 32, 48, 16, 32])
        self.assertEqual(scalar["golden"], bytes.fromhex("19000000"))
        self.assertEqual(block["lengths"], [32, 64])
        self.assertEqual(block["golden"], bytes.fromhex("a55a0000"))
        known_ids = "\n".join(
            path.read_text(encoding="utf-8", errors="replace")
            for path in (ROOT / "tests" / "asl").rglob("*.asl")
        )
        for row in self.builder.CASES.values():
            for test_id in row["avs_ids"]:
                self.assertIn(f'"id":"{test_id}"', known_ids)

    def test_schema_is_closed_and_versioned(self) -> None:
        schema = json.loads(
            (ROOT / "spec" / "schemas" /
             "pto-functional-model-corpus-v1.schema.json").read_text()
        )
        self.assertEqual(schema["$schema"],
                         "https://json-schema.org/draft/2020-12/schema")
        self.assertEqual(schema["properties"]["schema"]["const"],
                         "pto-functional-model-corpus-v1")
        self.assertFalse(schema["additionalProperties"])
        self.assertEqual(
            schema["$defs"]["case"]["properties"]
            ["expected_length_sequence"]["items"]["enum"],
            [16, 32, 48, 64],
        )
        isa = schema["$defs"]["case"]["properties"]["isa"]["properties"]
        self.assertEqual(isa["version"]["const"], "0.58.5")
        self.assertEqual(
            isa["encoding_abi"]["const"],
            "pto-isa-0.58.5-mode-function-v1",
        )

    def assert_rejected(self, payload: bytes, pattern: str) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "fixture.elf"
            path.write_bytes(payload)
            with self.assertRaisesRegex(self.builder.CorpusError, pattern):
                self.builder.inspect_elf(path)

    def test_malformed_elf_is_rejected(self) -> None:
        self.assert_rejected(b"not-elf", "truncated")
        self.assert_rejected(bytes(64), "requires ELF64")

    def test_writable_executable_segment_is_rejected(self) -> None:
        self.assert_rejected(minimal_elf(flags=7), "writable executable")

    def test_invalid_load_bounds_are_rejected(self) -> None:
        self.assert_rejected(minimal_elf(filesz=2, memsz=1), "exceeds")
        self.assert_rejected(minimal_elf(entry=0x200), "entry")

    def test_overlapping_segments_are_rejected(self) -> None:
        self.assert_rejected(
            minimal_elf(filesz=4, memsz=8, second=(0x104, 1, 4)),
            "overlapping",
        )

    def test_builder_requires_explicit_readelf(self) -> None:
        text = BUILDER.read_text(encoding="utf-8")
        self.assertIn('parser.add_argument("--readelf"', text)
        self.assertNotIn("/Users/", text)
        self.assertNotIn("def source(", text)

    def valid_run_contract(self) -> tuple[dict[str, object], dict[str, object]]:
        case = {
            "case": {
                "stop_policy": {"stop_pc": 0x104, "max_steps": 2},
                "expected_length_sequence": [16, 16],
                "expected_trace": [
                    {
                        "pre_tpc": 0x100,
                        "post_tpc": 0x102,
                        "pre_bpc": 0,
                        "post_bpc": 0,
                        "raw_instruction_le": 0x11,
                        "length_bits": 16,
                        "sequence": 3,
                    },
                    {
                        "pre_tpc": 0x102,
                        "post_tpc": 0x104,
                        "pre_bpc": 0,
                        "post_bpc": 0,
                        "raw_instruction_le": 0x22,
                        "length_bits": 16,
                        "sequence": 4,
                    },
                ],
                "result": {"address": 0x200, "size": 4},
            }
        }
        run = {
            "schema": "linx-gfrun-asl-run-v1",
            "engine": "asl",
            "model_descriptor_sha256": "12" * 32,
            "outcome": {
                "status": "completed",
                "reason": "stop_pc",
                "steps": 2,
                "final_tpc": 0x104,
            },
            "result": {"address": 0x200, "size": 4, "bytes_hex": "19000000"},
            "trace": [
                {
                    "status": 0,
                    "step_state": 1,
                    "instruction_status": 1,
                    "fault_code": 0,
                    "fault_address": 0,
                    "fault_cause": 0,
                    "origin_pe": 0,
                    "request_token": 0,
                    "request_type": 0,
                    "request_argument0": 0,
                    "pre_tpc": 0x100,
                    "post_tpc": 0x102,
                    "pre_bpc": 0,
                    "post_bpc": 0,
                    "raw_instruction_le": 0x11,
                    "length_bits": 16,
                    "sequence": 3,
                },
                {
                    "status": 0,
                    "step_state": 1,
                    "instruction_status": 1,
                    "fault_code": 0,
                    "fault_address": 0,
                    "fault_cause": 0,
                    "origin_pe": 0,
                    "request_token": 0,
                    "request_type": 0,
                    "request_argument0": 0,
                    "pre_tpc": 0x102,
                    "post_tpc": 0x104,
                    "pre_bpc": 0,
                    "post_bpc": 0,
                    "raw_instruction_le": 0x22,
                    "length_bits": 16,
                    "sequence": 4,
                },
            ],
        }
        return case, run

    def test_gfrun_validator_accepts_exact_trace_and_golden(self) -> None:
        case, run = self.valid_run_contract()
        descriptor = self.validator.validate_run(
            case, run, bytes.fromhex("19000000"), bytes.fromhex("19000000")
        )
        self.assertEqual(descriptor, "12" * 32)

    def test_gfrun_validator_rejects_result_or_trace_mismatch(self) -> None:
        case, run = self.valid_run_contract()
        with self.assertRaisesRegex(self.validator.ValidationError, "result bytes"):
            self.validator.validate_run(
                case, run, bytes.fromhex("18000000"), bytes.fromhex("19000000")
            )
        run["trace"][1]["pre_tpc"] = 0x103
        with self.assertRaisesRegex(self.validator.ValidationError, "pre_tpc"):
            self.validator.validate_run(
                case, run, bytes.fromhex("19000000"), bytes.fromhex("19000000")
            )


if __name__ == "__main__":
    unittest.main()
