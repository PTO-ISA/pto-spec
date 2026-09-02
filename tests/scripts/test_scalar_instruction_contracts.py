from __future__ import annotations

import unittest
from collections import Counter

from scripts.asl_units import load_units
from scripts.instruction_contracts import (
    PLACEHOLDER_TEXT,
    ROOT,
    check_instruction_contracts,
    load_field_domains,
    resolve_instruction_contract,
)


class ScalarInstructionContractsTest(unittest.TestCase):
    def test_src_r_type_dispatch_uses_architectural_family_decoders(self) -> None:
        dispatch_root = ROOT / "asl" / "scalar" / "model" / "dispatch"
        alu = (dispatch_root / "alu.asl").read_text(encoding="utf-8")
        bru = (dispatch_root / "bru.asl").read_text(encoding="utf-8")
        agu = (dispatch_root / "agu.asl").read_text(encoding="utf-8")

        self.assertIn("ScalarDecodedBinaryRightModifier", alu)
        self.assertIn("ScalarDecodedSelectRightModifier", alu)
        self.assertIn("ScalarDecodedComparisonRightModifier", bru)
        self.assertIn("ScalarDecodedAddressRightModifier", agu)
        self.assertNotIn("ScalarDecodedRightModifier", alu)
        self.assertNotIn("ScalarDecodedRightModifier", bru)
        self.assertNotIn("ScalarDecodedRightModifier", agu)

    def test_csel_contract_owns_predicate_modifier_and_alias_semantics(self) -> None:
        unit = next(
            unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic == "CSEL"
        )
        contract = resolve_instruction_contract(
            unit,
            load_field_domains(load_units(ROOT / "asl")),
        )
        self.assertIsNotNone(contract)
        assert contract is not None
        rendered = "\n".join(
            (
                str(unit.metadata["summary"]),
                *contract.defaults,
                *contract.legality,
                *contract.state_effects,
                *contract.ordering,
                *contract.exceptions,
            )
        )
        self.assertIn("Only an all-zero SrcP is false", rendered)
        self.assertIn("Codes 00, 01, and 10 leave SrcR unchanged", rendered)
        self.assertIn("code 11 negates", rendered)
        self.assertIn("24..27 select T#1..T#4", rendered)
        self.assertIn("28..31 select U#1..U#4", rendered)
        self.assertIn("Read all three Reg5 sources eagerly", rendered)
        self.assertIn("code 30 pushes U", rendered)
        self.assertIn("code 31 pushes T", rendered)

    def test_csel_has_independent_execution_and_boundary_points(self) -> None:
        directory = ROOT / "tests" / "asl" / "scalar" / "alu" / "CSEL"
        self.assertEqual(
            len(tuple(directory.glob("scalar-exec-csel-select-001.asl"))),
            1,
        )
        self.assertEqual(
            len(tuple(directory.glob("scalar-bound-csel-*-001.asl"))),
            2,
        )
        self.assertEqual(
            len(tuple(directory.glob("scalar-fault-csel-readiness-001.asl"))),
            1,
        )

    def test_ld_owner_declares_complete_agu_semantics(self) -> None:
        units = load_units(ROOT / "asl")
        unit = next(unit for unit in units if unit.mnemonic == "LD")
        record = unit.metadata["catalog_records"][0]

        self.assertEqual(
            record["agu"],
            {
                "action": "Load",
                "address_kind": "Register",
                "offset_scale": 0,
                "prefetch_returns_address": False,
                "signed_load": False,
                "size_bytes": 8,
                "update_mode": "None",
            },
        )
        contract = resolve_instruction_contract(unit, load_field_domains(units))
        self.assertIsNotNone(contract)
        assert contract is not None
        rendered = "\n".join(
            (
                str(unit.metadata["summary"]),
                *contract.defaults,
                *contract.legality,
                *contract.state_effects,
                *contract.memory_effects,
                *contract.ordering,
                *contract.exceptions,
            )
        )
        for required in (
            "codes 24..27 select T#1..T#4",
            "codes 28..31 select U#1..U#4",
            "SrcRType=0 leaves SrcR unchanged",
            "SrcRType=3 is reserved",
            "shamt values 0..31",
            "modulo 2^PTO_XLEN",
            "aligned little-endian 8-byte value",
            "one relaxed load event",
            "Fault_DataAlignment",
            "Fault_DataPage",
            "full reissue",
        ):
            self.assertIn(required, rendered)

        source = (ROOT / unit.source_path).read_text(encoding="utf-8")
        for helper in (
            "InstructionContractAGUAction_LD",
            "InstructionContractAGUAddressKind_LD",
            "InstructionContractAGUSizeBytes_LD",
            "InstructionContractAGUOffsetScale_LD",
            "InstructionContractAGUUpdateMode_LD",
            "InstructionContractAGUSignedLoad_LD",
            "InstructionContractAGUPrefetchReturnsAddress_LD",
        ):
            self.assertIn(helper, source)

    def test_every_agu_owner_declares_explicit_semantics_and_readable_helpers(self) -> None:
        agu_units = [
            unit
            for unit in load_units(ROOT / "asl")
            if unit.surface == "scalar" and unit.classification == ("agu",)
        ]
        self.assertEqual(len(agu_units), 183)
        expected_keys = {
            "action",
            "address_kind",
            "offset_scale",
            "prefetch_returns_address",
            "signed_load",
            "size_bytes",
            "update_mode",
        }
        for unit in agu_units:
            self.assertEqual(len(unit.metadata["catalog_records"]), 1, unit.source_path)
            record = unit.metadata["catalog_records"][0]
            agu = record.get("agu")
            self.assertIsInstance(agu, dict, unit.source_path)
            assert isinstance(agu, dict)
            self.assertEqual(set(agu), expected_keys, unit.source_path)
            source = (ROOT / unit.source_path).read_text(encoding="utf-8")
            identifier = unit.mnemonic.replace(".", "_")
            for stem in (
                "Action",
                "AddressKind",
                "SizeBytes",
                "OffsetScale",
                "UpdateMode",
                "SignedLoad",
                "PrefetchReturnsAddress",
            ):
                self.assertIn(
                    f"InstructionContractAGU{stem}_{identifier}",
                    source,
                    unit.source_path,
                )
            rendered = "\n".join(
                (
                    str(unit.metadata["summary"]),
                    *unit.metadata["contract"]["defaults"],
                    *unit.metadata["contract"]["legality"],
                    *unit.metadata["contract"]["state_effects"],
                    *unit.metadata["contract"]["memory_effects"],
                    *unit.metadata["contract"]["ordering"],
                    *unit.metadata["contract"]["exceptions"],
                )
            )
            self.assertIn(f"{agu['size_bytes']}-byte", rendered, unit.source_path)
            self.assertIn("TPC", rendered, unit.source_path)
            self.assertNotIn("left absolute GPR source", rendered, unit.source_path)
            self.assertNotIn("right absolute GPR source", rendered, unit.source_path)

    def test_prefetch_model_codes_above_two_are_reserved(self) -> None:
        by_mnemonic = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.surface == "scalar" and unit.mnemonic is not None
        }
        for mnemonic in ("HL.PRF", "HL.PRF.A", "HL.PRFI.U", "HL.PRFI.UA"):
            record = by_mnemonic[mnemonic].metadata["catalog_records"][0]
            model = [
                constraint
                for constraint in record["constraints"]
                if constraint["field"] == "model"
            ]
            self.assertEqual(
                model,
                [
                    {
                        "field": "model",
                        "operator": "one-of",
                        "values": [0, 1, 2],
                    }
                ],
                mnemonic,
            )

    def test_compressed_stores_require_the_implicit_t1_source(self) -> None:
        source = (
            ROOT / "asl" / "scalar" / "model" / "types" / "operands.asl"
        ).read_text(encoding="utf-8")
        implicit_legality = source.split(
            "readonly func ScalarImplicitSourceOperandsLegal", 1
        )[1].split("readonly func ReadScalarRegisterOperand", 1)[0]

        for operation in ("ScalarOperation_C_SDI", "ScalarOperation_C_SWI"):
            self.assertIn(operation, implicit_legality)
        self.assertIn(
            "TemporaryQueueSourceAvailable(TRUE, 0)", implicit_legality
        )

    def test_every_scalar_mnemonic_has_a_complete_contract(self) -> None:
        self.assertEqual(
            check_instruction_contracts(surface="scalar", require_complete=True), []
        )

    def test_scalar_family_inventory_and_encoded_fields_are_closed(self) -> None:
        units = load_units(ROOT / "asl")
        domains = load_field_domains(units)
        scalar_units = [
            unit for unit in units if unit.surface == "scalar" and unit.mnemonic is not None
        ]

        self.assertEqual(len(scalar_units), 466)
        self.assertEqual(
            Counter(unit.classification[0] for unit in scalar_units),
            Counter({"agu": 183, "alu": 107, "bru": 58, "amo": 53, "sys": 35, "fsu": 30}),
        )
        for unit in scalar_units:
            contract = resolve_instruction_contract(unit, domains)
            expected_fields = sum(
                len(record.get("fields", []))
                for record in unit.metadata["catalog_records"]
            )
            self.assertEqual(len(contract.encoded_fields), expected_fields)

    def test_scalar_summaries_name_the_actual_operation(self) -> None:
        for unit in load_units(ROOT / "asl"):
            if unit.surface != "scalar" or unit.mnemonic is None:
                continue
            self.assertIsNone(
                PLACEHOLDER_TEXT.search(str(unit.metadata["summary"])),
                unit.source_path,
            )
            for record in unit.metadata["catalog_records"]:
                summary = str(record.get("semantic_summary", ""))
                self.assertTrue(summary, unit.source_path)
                self.assertIsNone(PLACEHOLDER_TEXT.search(summary), unit.source_path)

    def test_store_only_atomic_contracts_do_not_claim_a_result_or_acquire(self) -> None:
        units = load_units(ROOT / "asl")
        domains = load_field_domains(units)
        by_mnemonic = {
            unit.mnemonic: unit
            for unit in units
            if unit.surface == "scalar" and unit.mnemonic is not None
        }
        expected = {
            f"{width}.{operation}"
            for width in ("SW", "SD")
            for operation in ("ADD", "AND", "OR", "XOR", "SMIN", "SMAX", "UMIN", "UMAX")
        }

        for mnemonic in sorted(expected):
            unit = by_mnemonic[mnemonic]
            contract = resolve_instruction_contract(unit, domains)
            self.assertIsNotNone(contract)
            assert contract is not None

            self.assertEqual(
                tuple((operand["field"], operand["role"]) for operand in contract.operands),
                (
                    ("SrcL", "Reg5 atomic address source"),
                    ("SrcR", "Reg5 atomic operand source"),
                    ("far", "flat-address routing hint"),
                    ("rl", "release ordering bit"),
                ),
                unit.source_path,
            )
            rendered = "\n".join(
                (
                    str(unit.metadata["summary"]),
                    *contract.state_effects,
                    *contract.memory_effects,
                    *contract.ordering,
                )
            ).lower()
            self.assertIn("does not publish the old value", rendered, unit.source_path)
            self.assertNotIn("returns the prior value", rendered, unit.source_path)
            self.assertIn("no acquire bit", rendered, unit.source_path)
            self.assertNotIn("requests acquire", rendered, unit.source_path)
            self.assertNotIn("aq ", rendered, unit.source_path)

    def test_store_only_atomic_mnemonics_have_independent_execution_points(self) -> None:
        for width in ("SW", "SD"):
            for operation in (
                "ADD",
                "AND",
                "OR",
                "XOR",
                "SMIN",
                "SMAX",
                "UMIN",
                "UMAX",
            ):
                mnemonic = f"{width}.{operation}"
                directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
                points = sorted(directory.glob("scalar-exec-*.asl"))
                self.assertEqual(len(points), 1, mnemonic)
                source = points[0].read_text(encoding="utf-8")
                self.assertIn(f'"source":"asl/scalar/amo/{mnemonic}.asl"', source)
                self.assertIn(f'"requirements":["PTO-INST-SCALAR-{width}-{operation}"]', source)
                self.assertIn("ExecuteScalarInstruction", source)
                self.assertIn("MemoryEvent_Atomic", source)
                self.assertIn("InstructionContractPublishesOldValue", source)

    def test_store_only_atomic_contracts_describe_precise_trap_recovery(self) -> None:
        units = load_units(ROOT / "asl")
        expected = {
            f"{width}.{operation}"
            for width in ("SW", "SD")
            for operation in ("ADD", "AND", "OR", "XOR", "SMIN", "SMAX", "UMIN", "UMAX")
        }

        for unit in units:
            if unit.mnemonic not in expected:
                continue
            state = "\n".join(unit.metadata["contract"]["state_effects"])
            self.assertNotIn("A fault leaves TPC", state, unit.source_path)
            self.assertIn("trap entry saves the original TPC", state, unit.source_path)
            self.assertIn("recovery restores that TPC for full reissue", state, unit.source_path)

    def test_store_only_atomic_mnemonics_have_form_and_fault_points(self) -> None:
        for width in ("SW", "SD"):
            for operation in (
                "ADD",
                "AND",
                "OR",
                "XOR",
                "SMIN",
                "SMAX",
                "UMIN",
                "UMAX",
            ):
                mnemonic = f"{width}.{operation}"
                directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
                self.assertEqual(len(tuple(directory.glob("scalar-bound-*-forms-001.asl"))), 1, mnemonic)
                self.assertEqual(len(tuple(directory.glob("scalar-fault-*-precise-001.asl"))), 1, mnemonic)

    def test_load_return_atomic_contracts_define_complete_visible_effects(self) -> None:
        units = load_units(ROOT / "asl")
        expected = {
            f"{width}.{operation}"
            for width in ("LW", "LD")
            for operation in ("ADD", "AND", "OR", "XOR", "SMIN", "SMAX", "UMIN", "UMAX")
        }
        selected = {unit.mnemonic: unit for unit in units if unit.mnemonic in expected}
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "canonical_assembly",
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            lower_text = text.lower()
            self.assertIn("destination codes 24..29 discard", lower_text, unit.source_path)
            self.assertIn("destination code 30 pushes u", lower_text, unit.source_path)
            self.assertIn("destination code 31 pushes t", lower_text, unit.source_path)
            self.assertIn("acquire-release", text, unit.source_path)
            self.assertIn("overlapping local reservation", text, unit.source_path)
            self.assertIn("trap entry saves the original TPC", text, unit.source_path)
            self.assertIn("recovery restores that TPC for full reissue", text, unit.source_path)
            if mnemonic.startswith("LW."):
                self.assertIn("sign-extended from 32 bits", text, unit.source_path)
            else:
                self.assertIn("unchanged 64-bit old value", text, unit.source_path)

    def test_load_return_atomic_mnemonics_have_independent_semantic_points(self) -> None:
        for width in ("LW", "LD"):
            for operation in (
                "ADD",
                "AND",
                "OR",
                "XOR",
                "SMIN",
                "SMAX",
                "UMIN",
                "UMAX",
            ):
                mnemonic = f"{width}.{operation}"
                directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
                self.assertEqual(len(tuple(directory.glob("scalar-exec-*-result-001.asl"))), 1, mnemonic)
                self.assertEqual(len(tuple(directory.glob("scalar-bound-*-forms-001.asl"))), 1, mnemonic)
                self.assertEqual(len(tuple(directory.glob("scalar-fault-*-precise-001.asl"))), 1, mnemonic)

    def test_load_reserved_contracts_define_reservation_and_alias_semantics(self) -> None:
        units = load_units(ROOT / "asl")
        expected = {"LR.B", "LR.H", "LR.W", "LR.D"}
        selected = {unit.mnemonic: unit for unit in units if unit.mnemonic in expected}
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "canonical_assembly",
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("SrcZero is an ignored alias field", text, unit.source_path)
            self.assertIn("64-byte reservation granule", text, unit.source_path)
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("acquire-release", text, unit.source_path)
            self.assertIn("prior reservation is preserved", text, unit.source_path)
            self.assertIn("full reissue", text, unit.source_path)

    def test_load_reserved_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("LR.B", "LR.H", "LR.W", "LR.D"):
            directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
            self.assertEqual(len(tuple(directory.glob("scalar-exec-*-reserve-001.asl"))), 1, mnemonic)
            self.assertEqual(len(tuple(directory.glob("scalar-bound-*-aliases-001.asl"))), 1, mnemonic)
            self.assertEqual(len(tuple(directory.glob("scalar-fault-*-precise-001.asl"))), 1, mnemonic)

    def test_store_conditional_contracts_define_line_match_and_probe_free_miss(self) -> None:
        units = load_units(ROOT / "asl")
        expected = {"SC.B", "SC.H", "SC.W", "SC.D"}
        selected = {unit.mnemonic: unit for unit in units if unit.mnemonic in expected}
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "canonical_assembly",
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("64-byte line", text, unit.source_path)
            self.assertIn("status zero", text, unit.source_path)
            self.assertIn("status one", text, unit.source_path)
            self.assertIn("probe-free", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("acquire-release", text, unit.source_path)
            self.assertIn("reissue without a new LR", text, unit.source_path)

    def test_store_conditional_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("SC.B", "SC.H", "SC.W", "SC.D"):
            directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
            self.assertEqual(len(tuple(directory.glob("scalar-exec-*-success-001.asl"))), 1, mnemonic)
            self.assertEqual(len(tuple(directory.glob("scalar-bound-*-miss-001.asl"))), 1, mnemonic)
            self.assertEqual(len(tuple(directory.glob("scalar-fault-*-precise-001.asl"))), 1, mnemonic)

    def test_swap_contracts_define_width_result_and_precise_effects(self) -> None:
        units = load_units(ROOT / "asl")
        expected = {"SWAPB", "SWAPH", "SWAPW", "SWAPD"}
        selected = {unit.mnemonic: unit for unit in units if unit.mnemonic in expected}
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "canonical_assembly",
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("acquire-release", text, unit.source_path)
            self.assertIn("read and write preflight", text, unit.source_path)
            self.assertIn("full reissue", text, unit.source_path)

    def test_swap_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("SWAPB", "SWAPH", "SWAPW", "SWAPD"):
            directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
            self.assertEqual(len(tuple(directory.glob("scalar-exec-*-result-001.asl"))), 1, mnemonic)
            self.assertEqual(len(tuple(directory.glob("scalar-bound-*-aliases-001.asl"))), 1, mnemonic)
            self.assertEqual(len(tuple(directory.glob("scalar-fault-*-precise-001.asl"))), 1, mnemonic)

    def test_compare_and_swap_contracts_define_match_mismatch_and_form_width(self) -> None:
        units = load_units(ROOT / "asl")
        expected = {
            f"{prefix}CAS{width}"
            for prefix in ("", "HL.")
            for width in ("B", "H", "W", "D")
        }
        selected = {unit.mnemonic: unit for unit in units if unit.mnemonic in expected}
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "canonical_assembly",
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("write_performed false", text, unit.source_path)
            self.assertIn("acquire-release", text, unit.source_path)
            self.assertIn("full reissue", text, unit.source_path)
            if mnemonic.startswith("HL."):
                self.assertIn("far combinations are assigned", text, unit.source_path)
                self.assertIn("advances TPC by 6 bytes", text, unit.source_path)
            else:
                self.assertIn("implicit far zero", text, unit.source_path)
                self.assertIn("advances TPC by 4 bytes", text, unit.source_path)

    def test_compare_and_swap_mnemonics_have_independent_semantic_points(self) -> None:
        for prefix in ("", "HL."):
            for width in ("B", "H", "W", "D"):
                mnemonic = f"{prefix}CAS{width}"
                directory = ROOT / "tests" / "asl" / "scalar" / "amo" / mnemonic
                self.assertEqual(len(tuple(directory.glob("scalar-exec-*-match-001.asl"))), 1, mnemonic)
                self.assertEqual(len(tuple(directory.glob("scalar-bound-*-mismatch-001.asl"))), 1, mnemonic)
                self.assertEqual(len(tuple(directory.glob("scalar-fault-*-precise-001.asl"))), 1, mnemonic)

    def test_dma_contract_defines_complete_snapshot_copy_semantics(self) -> None:
        unit = next(
            unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic == "DMA"
        )
        contract = unit.metadata["contract"]
        text = "\n".join(
            str(item)
            for key in (
                "canonical_assembly",
                "defaults",
                "legality",
                "state_effects",
                "memory_effects",
                "ordering",
                "exceptions",
            )
            for item in contract[key]
        )

        self.assertIn("24..27 select T#1..T#4", text)
        self.assertIn("28..31 select U#1..U#4", text)
        self.assertIn("source range is probed before the destination range", text)
        self.assertIn("All 64 source bytes are snapshotted", text)
        self.assertIn("memmove semantics", text)
        self.assertIn("eight ordered 8-byte relaxed load events", text)
        self.assertIn("eight ordered 8-byte relaxed store events", text)
        self.assertIn("overlapping local reservation", text)
        self.assertIn("full reissue", text)

    def test_dma_events_are_derived_from_the_single_source_snapshot(self) -> None:
        source = (ROOT / "asl/scalar/model/amo/semantics.asl").read_text(
            encoding="utf-8"
        )
        start = source.index("func ExecuteScalarDMACopy64")
        end = source.index("\nfunc LoadReserved", start)
        operation = source[start:end]

        self.assertIn("Bytes64ChunkValue(snapshot, chunk)", operation)
        self.assertNotIn("LoadTranslatedUnsigned", operation)

    def test_dma_has_independent_execution_boundary_and_fault_points(self) -> None:
        directory = ROOT / "tests/asl/scalar/amo/DMA"
        self.assertEqual(len(tuple(directory.glob("scalar-exec-dma-copy-001.asl"))), 1)
        self.assertEqual(len(tuple(directory.glob("scalar-bound-dma-overlap-001.asl"))), 1)
        self.assertEqual(len(tuple(directory.glob("scalar-fault-dma-precise-001.asl"))), 1)

    def test_unsigned_immediate_add_sub_contracts_define_word_and_xlen_rules(self) -> None:
        expected = {"ADDI", "ADDIW", "SUBI", "SUBIW"}
        selected = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic in expected
        }
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("unsigned 12-bit immediate", text, unit.source_path)
            self.assertIn("0 through 4095", text, unit.source_path)
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            self.assertIn("codes 0 and 24..29 discard", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("before the destination effect", text, unit.source_path)
            self.assertIn("raises no arithmetic exception", text, unit.source_path)
            if mnemonic.endswith("W"):
                self.assertIn("modulo 2^32", text, unit.source_path)
                self.assertIn("sign-extended to XLEN", text, unit.source_path)
            else:
                self.assertIn("modulo 2^PTO_XLEN", text, unit.source_path)

    def test_unsigned_immediate_add_sub_have_independent_semantic_points(self) -> None:
        for mnemonic in ("ADDI", "ADDIW", "SUBI", "SUBIW"):
            directory = ROOT / "tests/asl/scalar/alu" / mnemonic
            lower = mnemonic.lower()
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-exec-{lower}-result-001.asl"))),
                1,
                mnemonic,
            )
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-bound-{lower}-aliases-001.asl"))),
                1,
                mnemonic,
            )

    def test_signed_immediate_logical_contracts_define_extension_and_word_rules(self) -> None:
        expected = {"ANDI", "ANDIW", "ORI", "ORIW", "XORI", "XORIW"}
        selected = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic in expected
        }
        self.assertEqual(set(selected), expected)
        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("signed 12-bit immediate", text, unit.source_path)
            self.assertIn("-2048 through 2047", text, unit.source_path)
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            self.assertIn("codes 0 and 24..29 discard", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("before the destination effect", text, unit.source_path)
            self.assertIn("raises no arithmetic exception", text, unit.source_path)
            if mnemonic.endswith("W"):
                self.assertIn("low 32 bits", text, unit.source_path)
                self.assertIn("sign-extended to XLEN", text, unit.source_path)
            else:
                self.assertIn("sign-extended to PTO_XLEN", text, unit.source_path)

    def test_signed_immediate_logical_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("ANDI", "ANDIW", "ORI", "ORIW", "XORI", "XORIW"):
            directory = ROOT / "tests/asl/scalar/alu" / mnemonic
            lower = mnemonic.lower()
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-exec-{lower}-result-001.asl"))),
                1,
                mnemonic,
            )
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-bound-{lower}-aliases-001.asl"))),
                1,
                mnemonic,
            )

    def test_shift_immediate_contracts_define_width_direction_and_publication(self) -> None:
        expected = {"SLLI", "SLLIW", "SRLI", "SRLIW", "SRAI", "SRAIW"}
        selected = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic in expected
        }
        self.assertEqual(set(selected), expected)
        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            self.assertIn("codes 0 and 24..29 discard", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("before the destination effect", text, unit.source_path)
            self.assertIn("raises no arithmetic exception", text, unit.source_path)
            if mnemonic.endswith("W"):
                self.assertIn("5-bit shift amount from 0 through 31", text, unit.source_path)
                self.assertIn("sign-extended to XLEN", text, unit.source_path)
            else:
                self.assertIn("6-bit shift amount from 0 through 63", text, unit.source_path)
            if mnemonic.startswith("SLL"):
                self.assertIn("logical left shift", text, unit.source_path)
            elif mnemonic.startswith("SRL"):
                self.assertIn("logical right shift", text, unit.source_path)
            else:
                self.assertIn("arithmetic right shift", text, unit.source_path)

    def test_shift_immediate_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("SLLI", "SLLIW", "SRLI", "SRLIW", "SRAI", "SRAIW"):
            directory = ROOT / "tests/asl/scalar/alu" / mnemonic
            lower = mnemonic.lower()
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-exec-{lower}-maximum-001.asl"))),
                1,
                mnemonic,
            )
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-bound-{lower}-zero-001.asl"))),
                1,
                mnemonic,
            )

    def test_register_shift_contracts_define_mask_direction_and_publication(self) -> None:
        expected = {"SLL", "SLLW", "SRL", "SRLW", "SRA", "SRAW"}
        selected = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic in expected
        }
        self.assertEqual(set(selected), expected)
        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            self.assertIn("codes 0 and 24..29 discard", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("Snapshot both sources before the destination effect", text, unit.source_path)
            self.assertIn("raises no arithmetic exception", text, unit.source_path)
            if mnemonic.endswith("W"):
                self.assertIn("low five bits of the snapshotted SrcR", text, unit.source_path)
                self.assertIn("sign-extended to XLEN", text, unit.source_path)
            else:
                self.assertIn("low six bits of the snapshotted SrcR", text, unit.source_path)
            if mnemonic.startswith("SLL"):
                self.assertIn("logical left shift", text, unit.source_path)
            elif mnemonic.startswith("SRL"):
                self.assertIn("logical right shift", text, unit.source_path)
            else:
                self.assertIn("arithmetic right shift", text, unit.source_path)

    def test_register_shift_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("SLL", "SLLW", "SRL", "SRLW", "SRA", "SRAW"):
            directory = ROOT / "tests/asl/scalar/alu" / mnemonic
            lower = mnemonic.lower()
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-exec-{lower}-maximum-001.asl"))),
                1,
                mnemonic,
            )
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-bound-{lower}-masked-001.asl"))),
                1,
                mnemonic,
            )

    def test_scalar_minmax_contracts_define_signedness_aliases_and_publication(self) -> None:
        expected = {"MIN", "MINU", "MAX", "MAXU"}
        selected = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic in expected
        }
        self.assertEqual(set(selected), expected)
        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            comparison = "minimum" if mnemonic.startswith("MIN") else "maximum"
            signedness = "unsigned" if mnemonic.endswith("U") else "signed"
            self.assertIn(f"{signedness} full-XLEN comparison", text, unit.source_path)
            self.assertIn(f"complete bit pattern of the {comparison} operand", text, unit.source_path)
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            self.assertIn("codes 0 and 24..29 discard", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("Snapshot both sources before the destination effect", text, unit.source_path)
            self.assertIn("raises no arithmetic exception", text, unit.source_path)

    def test_scalar_minmax_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in ("MIN", "MINU", "MAX", "MAXU"):
            directory = ROOT / "tests/asl/scalar/alu" / mnemonic
            lower = mnemonic.lower()
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-exec-{lower}-boundary-001.asl"))),
                1,
                mnemonic,
            )
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-bound-{lower}-aliases-001.asl"))),
                1,
                mnemonic,
            )

    def test_register_binary_contracts_define_modifiers_order_and_publication(self) -> None:
        expected = {
            "ADD",
            "ADDW",
            "SUB",
            "SUBW",
            "AND",
            "ANDW",
            "OR",
            "ORW",
            "XOR",
            "XORW",
        }
        selected = {
            unit.mnemonic: unit
            for unit in load_units(ROOT / "asl")
            if unit.mnemonic in expected
        }
        self.assertEqual(set(selected), expected)

        for mnemonic, unit in selected.items():
            contract = unit.metadata["contract"]
            text = "\n".join(
                str(item)
                for key in (
                    "defaults",
                    "legality",
                    "state_effects",
                    "memory_effects",
                    "ordering",
                    "exceptions",
                )
                for item in contract[key]
            )
            logical = mnemonic.startswith(("AND", "OR", "XOR"))
            terminal_modifier = ".not" if logical else ".neg"
            self.assertIn("SrcRType=00 selects .sw", text, unit.source_path)
            self.assertIn("SrcRType=01 selects .uw", text, unit.source_path)
            self.assertIn(
                f"SrcRType=10 selects {terminal_modifier}",
                text,
                unit.source_path,
            )
            self.assertIn("SrcRType=11 selects no modifier", text, unit.source_path)
            self.assertIn("before the logical left shift", text, unit.source_path)
            self.assertIn("24..27 select T#1..T#4", text, unit.source_path)
            self.assertIn("28..31 select U#1..U#4", text, unit.source_path)
            self.assertIn("codes 0 and 24..29 discard", text, unit.source_path)
            self.assertIn("code 30 pushes U", text, unit.source_path)
            self.assertIn("code 31 pushes T", text, unit.source_path)
            self.assertIn("Snapshot both sources before the destination effect", text, unit.source_path)
            self.assertIn("raises no arithmetic exception", text, unit.source_path)
            if mnemonic.endswith("W"):
                self.assertIn("low 32-bit result", text, unit.source_path)
                self.assertIn("sign-extend", text, unit.source_path)
                self.assertIn("to XLEN", text, unit.source_path)
            elif logical:
                self.assertIn("PTO_XLEN", text, unit.source_path)
                self.assertIn("discard", text, unit.source_path)
            else:
                self.assertIn("modulo 2^PTO_XLEN", text, unit.source_path)

    def test_register_binary_mnemonics_have_independent_semantic_points(self) -> None:
        for mnemonic in (
            "ADD",
            "ADDW",
            "SUB",
            "SUBW",
            "AND",
            "ANDW",
            "OR",
            "ORW",
            "XOR",
            "XORW",
        ):
            directory = ROOT / "tests/asl/scalar/alu" / mnemonic
            lower = mnemonic.lower()
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-exec-{lower}-modifier-001.asl"))),
                1,
                mnemonic,
            )
            self.assertEqual(
                len(tuple(directory.glob(f"scalar-bound-{lower}-aliases-001.asl"))),
                1,
                mnemonic,
            )

    def test_scalar_right_modifier_raw_codes_follow_the_reviewed_contract(self) -> None:
        source = (ROOT / "asl/scalar/model/dispatch/decode.asl").read_text(
            encoding="utf-8"
        )
        expected = (
            "when '00' => return ScalarRight_SignedWord;",
            "when '01' => return ScalarRight_UnsignedWord;",
            "when '10' => return ScalarRight_NegateOrNot;",
            "when '11' => return ScalarRight_None;",
        )
        for clause in expected:
            self.assertIn(clause, source)


if __name__ == "__main__":
    unittest.main()
