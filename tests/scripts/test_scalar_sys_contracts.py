from __future__ import annotations

import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def instruction_metadata(mnemonic: str) -> dict[str, object]:
    path = ROOT / "asl" / "scalar" / "sys" / f"{mnemonic}.asl"
    first_line = path.read_text(encoding="utf-8").splitlines()[0]
    prefix = "// PTO-INSTRUCTION: "
    if not first_line.startswith(prefix):
        raise AssertionError(f"{path} has no PTO-INSTRUCTION record")
    return json.loads(first_line.removeprefix(prefix))


class ScalarSysContractTest(unittest.TestCase):
    def test_sys_reg5_operand_roles_are_explicit(self) -> None:
        source_role = "Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"
        destination_role = (
            "Reg5 destination: discard, R1..R23, push U, or push T"
        )

        for owner in sorted((ROOT / "asl/scalar/sys").glob("*.asl")):
            metadata = instruction_metadata(owner.stem)
            operands = {
                operand["field"]: operand["role"]
                for operand in metadata["contract"]["operands"]
            }
            with self.subTest(mnemonic=owner.stem):
                if "SrcL" in operands:
                    self.assertEqual(operands["SrcL"], source_role)
                if "RegDst" in operands:
                    self.assertEqual(operands["RegDst"], destination_role)

    def test_every_sys_owner_is_formally_complete_and_nontrivial(self) -> None:
        owners = sorted((ROOT / "asl/scalar/sys").glob("*.asl"))
        self.assertEqual(len(owners), 35)

        for owner in owners:
            text = owner.read_text(encoding="utf-8")
            mnemonic = owner.stem.replace(".", "_")
            with self.subTest(mnemonic=owner.stem):
                self.assertIn('"outcome":"FORMAL-COMPLETE"', text)
                self.assertIn(
                    f"InstructionContractRequiresSystemBlock_{mnemonic}", text
                )
                self.assertGreaterEqual(len(text.splitlines()), 28)

    def test_lsrget_reads_barg_not_system_registers(self) -> None:
        dispatch = (ROOT / "asl/scalar/model/dispatch/sys.asl").read_text(
            encoding="utf-8"
        )
        start = dispatch.index("when ScalarOperation_LSRGET =>")
        end = dispatch.index("when ScalarOperation_SSRGET =>", start)
        lsrget = dispatch[start:end]

        self.assertIn("ExecuteLocalStateRegisterGet", lsrget)
        self.assertNotIn("ExecuteSystemRegisterGet", lsrget)
        self.assertNotIn("ScalarDecodedSystemRegisterAddress", lsrget)

        metadata = instruction_metadata("LSRGET")
        record = metadata["catalog_records"][0]
        self.assertEqual(record["semantic_handler"], "ExecuteLocalStateRegisterGet")
        self.assertEqual(record["constraints"], [])
        self.assertIn(
            "IDs 3 through 4095 are reserved",
            metadata["contract"]["legality"][0],
        )

    def test_compressed_ssrget_assigns_only_three_direct_ids(self) -> None:
        metadata = instruction_metadata("C.SSRGET")
        constraints = metadata["catalog_records"][0]["constraints"]

        self.assertEqual(
            constraints,
            [{"field": "SSRID", "operator": "one-of", "values": [0, 1, 16]}],
        )

    def test_acre_assigns_only_two_alias_request_types(self) -> None:
        metadata = instruction_metadata("ACRE")
        constraints = metadata["catalog_records"][0]["constraints"]

        self.assertEqual(
            constraints,
            [{"field": "RRA_Type", "operator": "one-of", "values": [0, 1]}],
        )

    def test_breakpoint_cause_has_no_parallel_tag_state(self) -> None:
        semantics = (ROOT / "asl/scalar/model/sys/semantics.asl").read_text(
            encoding="utf-8"
        )
        faults = (ROOT / "asl/arch/memory-model/fault-precision.asl").read_text(
            encoding="utf-8"
        )
        execution_context = (
            ROOT / "asl/arch/programming-model/execution-context.asl"
        ).read_text(encoding="utf-8")

        self.assertNotIn("_BreakpointTag", semantics)
        self.assertNotIn("_BreakpointTag", execution_context)
        self.assertIn("SetFaultWithCause", semantics)
        self.assertIn("func SetFaultWithCause", faults)

    def test_register_write_preflights_before_source_read(self) -> None:
        registers = (ROOT / "asl/scalar/model/sys/registers.asl").read_text(
            encoding="utf-8"
        )
        start = registers.index("func ExecuteSystemRegisterSet(")
        end = registers.index("func ExecuteSystemRegisterSwap(", start)
        setter = registers[start:end]

        preflight = setter.index("SystemRegisterWritePermitted")
        source_read = setter.index("ReadScalarRegisterOperand")
        self.assertLess(preflight, source_read)

    def test_register_swap_preflights_before_source_read(self) -> None:
        registers = (ROOT / "asl/scalar/model/sys/registers.asl").read_text(
            encoding="utf-8"
        )
        start = registers.index("func ExecuteSystemRegisterSwap(")
        swap = registers[start:]

        preflight = swap.index("SystemRegisterSwapPermitted")
        source_read = swap.index("ReadScalarRegisterOperand")
        self.assertLess(preflight, source_read)

    def test_scalar_placement_precedes_operand_legality(self) -> None:
        top_level = (ROOT / "asl/scalar/model/dispatch/top-level.asl").read_text(
            encoding="utf-8"
        )

        placement = top_level.index("ScalarOperationApplicable")
        operand_legality = top_level.index("ScalarFormOperandsLegal")
        self.assertLess(placement, operand_legality)

    def test_acrc_marks_the_terminal_sys_position_before_trap_entry(self) -> None:
        semantics = (ROOT / "asl/scalar/model/sys/semantics.asl").read_text(
            encoding="utf-8"
        )
        start = semantics.index("func ArchitectureCloseRequest(")
        end = semantics.index("func ArchitectureEnterRequest(", start)
        close_request = semantics[start:end]

        marker = close_request.index("_SystemBlockTerminalPending = TRUE")
        trap_entry = close_request.index("RaiseServiceRequest")
        self.assertLess(marker, trap_entry)

    def test_acre_preflights_then_commits_then_recovers(self) -> None:
        semantics = (ROOT / "asl/scalar/model/sys/semantics.asl").read_text(
            encoding="utf-8"
        )
        start = semantics.index("func ArchitectureEnterRequest(")
        end = semantics.index("func ExecuteControlRequest(", start)
        enter_request = semantics[start:end]

        preflight = enter_request.index("TrapContextRecoverable")
        commit = enter_request.index("CompleteBundleAt")
        recover = enter_request.index("RecoverTrapContext")
        self.assertLess(preflight, commit)
        self.assertLess(commit, recover)
        self.assertIn("let recovery_context = _TrapContexts[[target]]", enter_request)
        self.assertIn("_TrapContexts[[target]] = recovery_context", enter_request)

    def test_terminal_sys_position_accepts_only_stop_or_new_start(self) -> None:
        top_level = (ROOT / "asl/block/model/dispatch/top-level.asl").read_text(
            encoding="utf-8"
        )

        terminal_check = top_level.index("_SystemBlockTerminalPending")
        operand_legality = top_level.index("CommandFormOperandsLegal")
        self.assertLess(terminal_check, operand_legality)
        self.assertIn("CommandHandler_ExecuteBundleStop", top_level)
        self.assertIn("CommandHandler_ExecuteBundleStart", top_level)


if __name__ == "__main__":
    unittest.main()
