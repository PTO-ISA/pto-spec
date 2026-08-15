from __future__ import annotations

import runpy
import tempfile
import unittest
from dataclasses import replace
from pathlib import Path

from scripts.asl_units import AslUnit


SCRIPT = Path(__file__).resolve().parents[2] / "scripts/generate-mnemonic-avs.py"


def instruction_unit(surface: str, mnemonic: str, record: dict[str, object]) -> AslUnit:
    classification = {
        "scalar": ("alu",),
        "block": ("operands",),
        "tile": ("memory-and-data-movement", "regular"),
    }[surface]
    metadata = {
        "id": f"PTO-{surface.upper()}-{mnemonic.replace('.', '-').replace('_', '-')}",
        "surface": surface,
        "classification": list(classification),
        "depends_on": [],
        "mnemonic": mnemonic,
        "summary": f"{mnemonic} contract",
        "assembly": [f"{mnemonic} operands"],
        "block": ["BSTART", "B.IOT", "BSTOP"] if surface == "tile" else [],
        "catalog_indices": [3],
        "catalog_records": [record],
    }
    if surface == "tile":
        metadata["engine"] = "TLSU"
    return AslUnit(
        unit_id=f"PTO-{surface.upper()}-{mnemonic.replace('.', '-').replace('_', '-')}",
        surface=surface,
        classification=classification,
        depends_on=(),
        source_path=Path("asl") / surface / Path(*classification) / f"{mnemonic}.asl",
        mnemonic=mnemonic,
        line_count=20,
        metadata=metadata,
    )


class GenerateMnemonicAvsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.module = runpy.run_path(
            str(SCRIPT), run_name="generate_mnemonic_avs_module"
        )
        cls.render = staticmethod(cls.module["render_mnemonic_avs"])
        cls.render_concept = staticmethod(cls.module["render_concept_avs"])

    def test_scalar_decode_test_has_stable_identity_and_canonical_selectors(
        self,
    ) -> None:
        unit = instruction_unit(
            "scalar",
            "ADD",
            {
                "encoding": [{"index": 0, "match": "0x00000005", "width_bits": 32}],
                "fields": [
                    {
                        "name": "RegDst",
                        "width": 5,
                        "pieces": [{"instruction_lsb": 7, "value_lsb": 0, "width": 5}],
                    }
                ],
                "form_id": "add_32_fixture",
                "length_bits": 32,
                "semantic_family": "ALU",
                "semantic_handler": "ScalarBinary",
            },
        )

        path, document = self.render(unit)

        self.assertEqual(path.name, "scalar-decode-add-canonical-001.asl")
        self.assertEqual(document.count("func main() => integer"), 1)
        self.assertIn('"source":"asl/scalar/alu/ADD.asl"', document)
        self.assertIn("DecodeScalarForm", document)
        self.assertIn("ScalarOperationOfForm(3) == ScalarOperation_ADD", document)
        self.assertIn("ScalarHandlerOfForm(3) == ScalarHandler_ScalarBinary", document)
        self.assertIn("DecodeScalarOperandRaw", document)

    def test_block_engine_alias_gets_complete_operation_partition_point(self) -> None:
        alias = instruction_unit(
            "block",
            "BSTART.SFU",
            {
                "encoding": [],
                "fields": [],
                "form_id": "bstart_sfu_alias_fixture",
                "length_bits": 32,
                "semantic_family": "CMD",
                "semantic_handler": "ExecuteBundleStart",
            },
        )
        alias.metadata["alias_engine"] = "SFU"
        alias.metadata["alias_of"] = "BSTART.TEPL"
        alias.metadata["catalog_indices"] = []
        alias.metadata["catalog_records"] = []

        vec = instruction_unit(
            "tile",
            "TADD",
            {
                "encoding": [],
                "fields": [],
                "form_id": "tadd_fixture",
                "length_bits": 12,
                "semantic_family": "TEPL",
                "semantic_handler": "ExecuteTileBinary",
            },
        )
        vec.metadata["engine"] = "VEC"
        vec.metadata["catalog_indices"] = [7]
        sfu = instruction_unit(
            "tile",
            "TEXP",
            {
                "encoding": [],
                "fields": [],
                "form_id": "texp_fixture",
                "length_bits": 12,
                "semantic_family": "TEPL",
                "semantic_handler": "ExecuteTileUnary",
            },
        )
        sfu.metadata["engine"] = "SFU"
        sfu.metadata["catalog_indices"] = [19]

        render_alias = self.module["render_block_alias_avs"]
        documents = dict(render_alias(alias, [vec, sfu]))
        path = Path(
            "tests/asl/block/operands/BSTART.SFU/"
            "block-bound-bstart-sfu-engine-001.asl"
        )
        self.assertIn(path, documents)
        self.assertIn(
            "InstructionContractAcceptsTileOperation_BSTART_SFU(7) == FALSE",
            documents[path],
        )
        self.assertIn(
            "InstructionContractAcceptsTileOperation_BSTART_SFU(19) == TRUE",
            documents[path],
        )

    def test_scalar_agu_decode_test_checks_owner_semantic_metadata(self) -> None:
        unit = instruction_unit(
            "scalar",
            "LD",
            {
                "agu": {
                    "action": "Load",
                    "address_kind": "Register",
                    "offset_scale": 0,
                    "prefetch_returns_address": False,
                    "signed_load": False,
                    "size_bytes": 8,
                    "update_mode": "None",
                },
                "encoding": [{"index": 0, "match": "0x00003009", "width_bits": 32}],
                "fields": [],
                "form_id": "ld_32_fixture",
                "length_bits": 32,
                "semantic_family": "AGU",
                "semantic_handler": "ExecuteScalarLoad",
            },
        )

        _, document = self.render(unit)

        self.assertIn("InstructionContractAGUAction_LD() == ScalarAGU_Load", document)
        self.assertIn(
            "InstructionContractAGUAddressKind_LD() == ScalarAGU_Register",
            document,
        )
        self.assertIn("InstructionContractAGUSizeBytes_LD() == 8", document)
        self.assertIn("InstructionContractAGUOffsetScale_LD() == 0", document)
        self.assertIn(
            "InstructionContractAGUUpdateMode_LD() == AddressUpdate_None",
            document,
        )
        self.assertIn("InstructionContractAGUSignedLoad_LD() == FALSE", document)
        self.assertIn(
            "InstructionContractAGUPrefetchReturnsAddress_LD() == FALSE",
            document,
        )

    def test_scalar_sys_source_owner_gets_independent_t_and_u_points(self) -> None:
        unit = instruction_unit(
            "scalar",
            "ASSERT",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfff07fff",
                        "match": "0x0000102b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "assert_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ArchitectureAssert",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/ASSERT.asl"),
        )

        render_sys = self.module["render_scalar_sys_avs"]
        documents = dict(render_sys(unit))
        t_path = Path("tests/asl/scalar/sys/ASSERT/scalar-exec-assert-tsrc-001.asl")
        u_path = Path("tests/asl/scalar/sys/ASSERT/scalar-exec-assert-usrc-001.asl")

        self.assertIn(t_path, documents)
        self.assertIn(u_path, documents)
        self.assertIn("_TQueueValid[[0]] = TRUE;", documents[t_path])
        self.assertIn("_UQueueValid[[0]] = TRUE;", documents[u_path])
        self.assertIn("ScalarExecution_Executed", documents[t_path])
        self.assertIn("ScalarExecution_Executed", documents[u_path])

    def test_scalar_sys_destination_owner_gets_discard_u_and_t_points(self) -> None:
        unit = instruction_unit(
            "scalar",
            "SSRGET",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0x0000707f",
                        "match": "0x0000100b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "RegDst",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 7, "value_lsb": 0, "width": 5}
                        ],
                    },
                    {
                        "name": "SSR_ID",
                        "width": 12,
                        "pieces": [
                            {"instruction_lsb": 20, "value_lsb": 0, "width": 12}
                        ],
                    },
                ],
                "form_id": "ssrget_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteSystemRegisterGet",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/SSRGET.asl"),
        )

        render_sys = self.module["render_scalar_sys_avs"]
        documents = dict(render_sys(unit))
        expected = {
            "discard": "ScalarExecution_Executed",
            "udst": "ReadTemporaryQueue(FALSE, 0)",
            "tdst": "ReadTemporaryQueue(TRUE, 0)",
        }
        for purpose, assertion in expected.items():
            path = Path(
                f"tests/asl/scalar/sys/SSRGET/"
                f"scalar-exec-ssrget-{purpose}-001.asl"
            )
            with self.subTest(purpose=purpose):
                self.assertIn(path, documents)
                self.assertIn(assertion, documents[path])

    def test_scalar_sys_control_request_observes_publication_and_retirement(self) -> None:
        unit = instruction_unit(
            "scalar",
            "BSE",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfff07fff",
                        "match": "0x0000002b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "bse_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteControlRequest",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/BSE.asl"),
        )

        document = dict(self.module["render_scalar_sys_avs"](unit))[
            Path("tests/asl/scalar/sys/BSE/scalar-exec-bse-direct-001.asl")
        ]
        self.assertIn("_LastControlRequest == ExecutionControl_SendEvent", document)
        self.assertIn("_ControlRequestOperand == Zeros{PTO_XLEN} + 0x1000", document)
        self.assertIn("ReadTPC() == Zeros{PTO_XLEN} + 0x184", document)

    def test_scalar_sys_maintenance_observes_operation_operand_and_retirement(self) -> None:
        unit = instruction_unit(
            "scalar",
            "BC.IVA",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfff07fff",
                        "match": "0x0000102b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "bc_iva_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteMaintenance",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/BC.IVA.asl"),
        )

        document = dict(self.module["render_scalar_sys_avs"](unit))[
            Path("tests/asl/scalar/sys/BC.IVA/scalar-exec-bc-iva-direct-001.asl")
        ]
        self.assertIn("_LastMaintenanceOperation == Maintenance_BC_IVA", document)
        self.assertIn("_LastMaintenanceOperand == Zeros{PTO_XLEN} + 0x1000", document)
        self.assertIn("ReadTPC() == Zeros{PTO_XLEN} + 0x184", document)

    def test_scalar_sys_breakpoint_observes_complete_trap_envelope(self) -> None:
        unit = instruction_unit(
            "scalar",
            "EBREAK",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xffff0fff",
                        "match": "0x00000073",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "imm4",
                        "width": 4,
                        "pieces": [
                            {"instruction_lsb": 12, "value_lsb": 0, "width": 4}
                        ],
                    }
                ],
                "form_id": "ebreak_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "SoftwareBreakpoint",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/EBREAK.asl"),
        )

        document = dict(self.module["render_scalar_sys_avs"](unit))[
            Path("tests/asl/scalar/sys/EBREAK/scalar-exec-ebreak-direct-001.asl")
        ]
        self.assertIn("_ACRTrapNumber[[0]] == Zeros{6} + 50", document)
        self.assertIn("_ACRTrapArgument0[[0]] == Zeros{PTO_XLEN} + 0x180", document)
        self.assertIn("_TrapContexts[[0]].valid", document)

    def test_scalar_sys_breakpoints_get_independent_encoded_zero_points(self) -> None:
        for mnemonic, field_name, width, source_path in (
            ("C.EBREAK", "imm5", 5, "asl/scalar/sys/C.EBREAK.asl"),
            ("EBREAK", "imm4", 4, "asl/scalar/sys/EBREAK.asl"),
        ):
            with self.subTest(mnemonic=mnemonic):
                unit = instruction_unit(
                    "scalar",
                    mnemonic,
                    {
                        "constraints": [],
                        "encoding": [
                            {
                                "index": 0,
                                "mask": "0xffff0fff",
                                "match": "0x00000073",
                                "width_bits": 32,
                            }
                        ],
                        "fields": [
                            {
                                "name": field_name,
                                "width": width,
                                "pieces": [
                                    {
                                        "instruction_lsb": 12,
                                        "value_lsb": 0,
                                        "width": width,
                                    }
                                ],
                            }
                        ],
                        "form_id": f"{mnemonic.lower()}_fixture",
                        "length_bits": 32,
                        "semantic_family": "SYS",
                        "semantic_handler": "SoftwareBreakpoint",
                    },
                )
                unit = replace(
                    unit,
                    classification=("sys",),
                    source_path=Path(source_path),
                )

                documents = dict(self.module["render_scalar_sys_avs"](unit))
                filename = mnemonic.lower().replace(".", "-")
                document = documents[
                    Path(source_path.replace("asl/", "tests/asl/").removesuffix(".asl"))
                    / f"scalar-bound-{filename}-zero-001.asl"
                ]
                self.assertIn("_ACRTrapCause[[0]] == Zeros{24}", document)
                self.assertIn("_ACRTrapNumber[[0]] == Zeros{6} + 50", document)
                self.assertIn("_FaultAddress == Zeros{PTO_XLEN} + 0x180", document)
                self.assertIn("_TrapContexts[[0]].valid", document)
                self.assertIn("_TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x180", document)

    def test_compressed_ssrget_covers_every_assigned_direct_identifier(self) -> None:
        unit = instruction_unit(
            "scalar",
            "C.SSRGET",
            {
                "constraints": [{"field": "SSRID", "operator": "one-of", "values": [0, 1, 16]}],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xf83f",
                        "match": "0x802c",
                        "width_bits": 16,
                    }
                ],
                "fields": [
                    {
                        "name": "SSRID",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 6, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "c_ssrget_16_fixture",
                "length_bits": 16,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteCompressedSystemRegisterGet",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/C.SSRGET.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        global_ptr = documents[
            Path("tests/asl/scalar/sys/C.SSRGET/scalar-exec-c-ssrget-global-001.asl")
        ]
        time = documents[
            Path("tests/asl/scalar/sys/C.SSRGET/scalar-exec-c-ssrget-time-001.asl")
        ]
        self.assertIn("_SystemRegisters.global_ptr = Zeros{PTO_XLEN} + 0x222", global_ptr)
        self.assertIn("ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x222", global_ptr)
        self.assertIn("_SystemRegisters.cycle = Zeros{PTO_XLEN} + 40", time)
        self.assertIn("ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 41", time)
        self.assertIn("_SystemRegisters.cycle == Zeros{PTO_XLEN} + 41", time)

    def test_setc_target_covers_applicability_snapshot_and_source_read_order(self) -> None:
        unit = instruction_unit(
            "scalar",
            "SETC.TGT",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfff07fff",
                        "match": "0x0000403b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "setc_tgt_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "SetCommitTarget",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/SETC.TGT.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        direct = documents[
            Path("tests/asl/scalar/sys/SETC.TGT/scalar-exec-setc-tgt-direct-001.asl")
        ]
        floating = documents[
            Path("tests/asl/scalar/sys/SETC.TGT/scalar-exec-setc-tgt-floating-001.asl")
        ]
        unavailable = documents[
            Path("tests/asl/scalar/sys/SETC.TGT/scalar-fault-setc-tgt-source-001.asl")
        ]
        system = documents[
            Path("tests/asl/scalar/sys/SETC.TGT/scalar-fault-setc-tgt-system-001.asl")
        ]
        self.assertIn("ReadBPC() == Zeros{PTO_XLEN} + 0x100", direct)
        self.assertIn("_BARG.block_type == BundleKind_Standard", direct)
        self.assertIn("BeginBundle(BundleKind_Floating", floating)
        self.assertIn("_BARG.bpcn == Zeros{PTO_XLEN} + 0x2468", floating)
        self.assertIn("_LastFault == Fault_IllegalInstruction", unavailable)
        self.assertIn("_BARG.bpcn == Zeros{PTO_XLEN} + 0x555", unavailable)
        self.assertIn("_LastFault == Fault_BundleControl", system)
        self.assertIn("ReadGPR(5) == Zeros{PTO_XLEN} + 0x2468", system)

    def test_scalar_sys_assert_gets_independent_zero_fault_point(self) -> None:
        unit = instruction_unit(
            "scalar",
            "ASSERT",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfff07fff",
                        "match": "0x0000202b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "assert_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ArchitectureAssert",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/ASSERT.asl"),
        )

        path = Path("tests/asl/scalar/sys/ASSERT/scalar-fault-assert-zero-001.asl")
        document = dict(self.module["render_scalar_sys_avs"](unit))[path]
        self.assertIn("ScalarExecution_Rejected", document)
        self.assertIn("_LastFault == Fault_Assert", document)
        self.assertIn("_ACRTrapNumber[[0]] == Zeros{6} + 52", document)
        self.assertIn("_TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x180", document)

    def test_scalar_sys_tlb_gets_operand_and_ring_fault_points(self) -> None:
        unit = instruction_unit(
            "scalar",
            "TLB.IV",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfff07fff",
                        "match": "0x0010702b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    }
                ],
                "form_id": "tlb_iv_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteMaintenance",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/TLB.IV.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        operand = documents[
            Path("tests/asl/scalar/sys/TLB.IV/scalar-fault-tlb-iv-operand-001.asl")
        ]
        ring = documents[
            Path("tests/asl/scalar/sys/TLB.IV/scalar-fault-tlb-iv-ring-001.asl")
        ]
        self.assertIn("_LastFault == Fault_DataPage", operand)
        self.assertIn("_TLBEpoch == 7", operand)
        self.assertIn("_LastMaintenanceOperation == Maintenance_DC_IALL", operand)
        self.assertIn("SetCurrentACR(1)", ring)
        self.assertIn("_LastFault == Fault_IllegalInstruction", ring)
        self.assertIn("_TrapContexts[[1]].source_acr == 1", ring)

    def test_scalar_sys_register_transfer_gets_precise_access_fault_points(self) -> None:
        unit = instruction_unit(
            "scalar",
            "SSRSWAP",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0x0000707f",
                        "match": "0x0000203b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "RegDst",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 7, "value_lsb": 0, "width": 5}
                        ],
                    },
                    {
                        "name": "SrcL",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 15, "value_lsb": 0, "width": 5}
                        ],
                    },
                    {
                        "name": "SSR_ID",
                        "width": 12,
                        "pieces": [
                            {"instruction_lsb": 20, "value_lsb": 0, "width": 12}
                        ],
                    },
                ],
                "form_id": "ssrswap_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteSystemRegisterSwap",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/SSRSWAP.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        for purpose in ("access", "unknown", "ring"):
            path = Path(
                f"tests/asl/scalar/sys/SSRSWAP/"
                f"scalar-fault-ssrswap-{purpose}-001.asl"
            )
            with self.subTest(purpose=purpose):
                document = documents[path]
                self.assertIn("ScalarExecution_Rejected", document)
                self.assertIn("_LastFault == Fault_IllegalInstruction", document)
                self.assertIn("ReadGPR(3) == Zeros{PTO_XLEN} + 0x333", document)
                self.assertIn("ReadGPR(5) == Zeros{PTO_XLEN} + 0x222", document)
        self.assertIn("SetCurrentACR(2)", documents[path])
        self.assertIn("_TrapContexts[[1]].source_acr == 2", documents[path])

    def test_scalar_sys_lsrget_observes_each_barg_word_and_applicability(self) -> None:
        unit = instruction_unit(
            "scalar",
            "LSRGET",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0x000ff07f",
                        "match": "0x0000303b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "LSR_ID",
                        "width": 12,
                        "pieces": [
                            {"instruction_lsb": 20, "value_lsb": 0, "width": 12}
                        ],
                    },
                    {
                        "name": "RegDst",
                        "width": 5,
                        "pieces": [
                            {"instruction_lsb": 7, "value_lsb": 0, "width": 5}
                        ],
                    },
                ],
                "form_id": "lsrget_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ExecuteLocalStateRegisterGet",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/LSRGET.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        bpcn = documents[
            Path("tests/asl/scalar/sys/LSRGET/scalar-exec-lsrget-bpcn-001.asl")
        ]
        control = documents[
            Path("tests/asl/scalar/sys/LSRGET/scalar-exec-lsrget-control-001.asl")
        ]
        applicability = documents[
            Path("tests/asl/scalar/sys/LSRGET/scalar-fault-lsrget-applicable-001.asl")
        ]
        reserved = documents[
            Path("tests/asl/scalar/sys/LSRGET/scalar-fault-lsrget-reserved-001.asl")
        ]

        self.assertIn("BundleTransfer_Direct", bpcn)
        self.assertIn("ReadGPR(3) == Zeros{PTO_XLEN} + 0x1000", bpcn)
        self.assertIn("SetBundleControlAttributeState", control)
        self.assertIn("ReadGPR(3) == Zeros{PTO_XLEN} + 0x1fa0", control)
        self.assertIn("_LastFault == Fault_BundleControl", applicability)
        self.assertIn("ReadGPR(3) == Zeros{PTO_XLEN} + 0x333", applicability)
        self.assertIn("_LastFault == Fault_BundleControl", reserved)
        self.assertIn("ReadGPR(3) == Zeros{PTO_XLEN} + 0x333", reserved)

    def test_scalar_sys_acrc_observes_route_faults_and_terminal_recovery(self) -> None:
        unit = instruction_unit(
            "scalar",
            "ACRC",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xff0fffff",
                        "match": "0x0000302b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "RST_Type",
                        "width": 4,
                        "pieces": [
                            {"instruction_lsb": 20, "value_lsb": 0, "width": 4}
                        ],
                    }
                ],
                "form_id": "acrc_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ArchitectureCloseRequest",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/ACRC.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        direct = documents[
            Path("tests/asl/scalar/sys/ACRC/scalar-exec-acrc-direct-001.asl")
        ]
        terminal = documents[
            Path("tests/asl/scalar/sys/ACRC/scalar-state-acrc-terminal-001.asl")
        ]
        ring0 = documents[
            Path("tests/asl/scalar/sys/ACRC/scalar-fault-acrc-ring0-001.asl")
        ]
        ring1 = documents[
            Path("tests/asl/scalar/sys/ACRC/scalar-fault-acrc-ring1-001.asl")
        ]
        request = documents[
            Path("tests/asl/scalar/sys/ACRC/scalar-fault-acrc-request-001.asl")
        ]

        self.assertIn("_ACRTrapCause[[1]] == Zeros{24} + 1", direct)
        self.assertIn("_TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x184", direct)
        self.assertIn("_TrapContexts[[1]].source_acr == 2", direct)
        self.assertIn("RecoverTrapContext(1)", terminal)
        self.assertIn("_SystemBlockTerminalPending", terminal)
        self.assertIn("_LastFault == Fault_BundleControl", terminal)
        for document in (ring0, ring1, request):
            self.assertIn("_LastFault == Fault_IllegalInstruction", document)
            self.assertIn("assert !_SystemBlockTerminalPending", document)
            self.assertIn("_ArchitectureRequestEpoch == 7", document)

    def test_scalar_sys_acre_observes_alias_and_atomic_failure_boundaries(self) -> None:
        unit = instruction_unit(
            "scalar",
            "ACRE",
            {
                "constraints": [
                    {"field": "RRA_Type", "operator": "one-of", "values": [0, 1]}
                ],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xff0fffff",
                        "match": "0x0100302b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "RRA_Type",
                        "width": 4,
                        "pieces": [
                            {"instruction_lsb": 20, "value_lsb": 0, "width": 4}
                        ],
                    }
                ],
                "form_id": "acre_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "ArchitectureEnterRequest",
            },
        )
        unit = replace(
            unit,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/ACRE.asl"),
        )

        documents = dict(self.module["render_scalar_sys_avs"](unit))
        direct = documents[
            Path("tests/asl/scalar/sys/ACRE/scalar-exec-acre-direct-001.asl")
        ]
        alias = documents[
            Path("tests/asl/scalar/sys/ACRE/scalar-exec-acre-alias-001.asl")
        ]
        missing = documents[
            Path("tests/asl/scalar/sys/ACRE/scalar-fault-acre-missing-001.asl")
        ]
        invalid = documents[
            Path("tests/asl/scalar/sys/ACRE/scalar-fault-acre-context-001.asl")
        ]
        commit = documents[
            Path("tests/asl/scalar/sys/ACRE/scalar-fault-acre-commit-001.asl")
        ]

        for document, request in ((direct, 0), (alias, 1)):
            self.assertIn("assert !_BundleActive", document)
            self.assertIn("assert !_BundleBodyActive", document)
            self.assertIn("ReadTPC() == Zeros{PTO_XLEN} + 0x240", document)
            self.assertIn(f"_ControlRequestOperand == Zeros{{PTO_XLEN}} + {request}", document)
        self.assertIn("_LastFault == Fault_ExecutionStateCheck", missing)
        self.assertIn("_LastFault == Fault_ExecutionStateCheck", invalid)
        self.assertIn("_TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x241", invalid)
        self.assertIn("_LastFault == Fault_InstructionPC", commit)
        self.assertIn("_TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x240", commit)
        for document in (missing, invalid, commit):
            self.assertIn("_ArchitectureRequestEpoch == 7", document)

    def test_scalar_sys_fences_observe_reservation_event_and_visibility(self) -> None:
        fence_d = instruction_unit(
            "scalar",
            "FENCE.D",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xf00fffff",
                        "match": "0x0000202b",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "PRED_IMM",
                        "width": 4,
                        "pieces": [
                            {"instruction_lsb": 24, "value_lsb": 0, "width": 4}
                        ],
                    },
                    {
                        "name": "SUCC_IMM",
                        "width": 4,
                        "pieces": [
                            {"instruction_lsb": 20, "value_lsb": 0, "width": 4}
                        ],
                    },
                ],
                "form_id": "fence_d_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "FenceData",
            },
        )
        fence_d = replace(
            fence_d,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/FENCE.D.asl"),
        )
        fence_i = instruction_unit(
            "scalar",
            "FENCE.I",
            {
                "constraints": [],
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xffffffff",
                        "match": "0x1000202b",
                        "width_bits": 32,
                    }
                ],
                "fields": [],
                "form_id": "fence_i_32_fixture",
                "length_bits": 32,
                "semantic_family": "SYS",
                "semantic_handler": "FenceInstruction",
            },
        )
        fence_i = replace(
            fence_i,
            classification=("sys",),
            source_path=Path("asl/scalar/sys/FENCE.I.asl"),
        )

        data_documents = dict(self.module["render_scalar_sys_avs"](fence_d))
        direct = data_documents[
            Path("tests/asl/scalar/sys/FENCE.D/scalar-exec-fence-d-direct-001.asl")
        ]
        zero = data_documents[
            Path("tests/asl/scalar/sys/FENCE.D/scalar-bound-fence-d-zero-001.asl")
        ]
        visibility = data_documents[
            Path("tests/asl/scalar/sys/FENCE.D/scalar-order-fence-d-visible-001.asl")
        ]
        instruction = dict(self.module["render_scalar_sys_avs"](fence_i))[
            Path("tests/asl/scalar/sys/FENCE.I/scalar-exec-fence-i-direct-001.asl")
        ]

        for document in (direct, zero, visibility):
            self.assertIn("assert !_ReservationValid", document)
            self.assertIn("_MemoryEvents[[0]].kind == MemoryEvent_Fence", document)
            self.assertIn("_MemoryEventCount == 1", document)
        self.assertIn("_InstructionCacheEpoch == 7", zero)
        self.assertIn("fence_predecessor == Zeros{4}", zero)
        self.assertIn("_InstructionCacheEpoch == 8", visibility)
        self.assertIn("fence_predecessor == '1000'", visibility)
        self.assertIn("assert !_ReservationValid", instruction)
        self.assertIn("_InstructionCacheEpoch == 8", instruction)
        self.assertIn("_MemoryEventCount == 0", instruction)

    def test_block_decode_test_checks_canonical_form_handler_and_schema_selector(
        self,
    ) -> None:
        unit = instruction_unit(
            "block",
            "B.IOR",
            {
                "encoding": [{"index": 0, "match": "0x00000013", "width_bits": 32}],
                "fields": [],
                "form_id": "b_ior_32_fixture",
                "length_bits": 32,
                "semantic_handler": "BindBundleScalarIO",
            },
        )

        path, document = self.render(unit)

        self.assertEqual(path.name, "block-decode-b-ior-canonical-001.asl")
        self.assertIn("DecodeCommandForm", document)
        self.assertIn(
            "CommandOperationOfForm(3) == CommandOperation_b_ior_32_fixture", document
        )
        self.assertIn(
            "CommandHandlerOfForm(3) == CommandHandler_BindBundleScalarIO", document
        )
        self.assertIn("InstructionContractMatches_B_IOR", document)

    def test_block_decode_witness_satisfies_operand_constraints(self) -> None:
        unit = instruction_unit(
            "block",
            "B.IOT",
            {
                "encoding": [
                    {
                        "index": 0,
                        "mask": "0xfc00707f",
                        "match": "0x00005013",
                        "width_bits": 32,
                    }
                ],
                "fields": [
                    {
                        "name": "TSize",
                        "width": 3,
                        "pieces": [{"instruction_lsb": 9, "value_lsb": 0, "width": 3}],
                    }
                ],
                "constraints": [
                    {"field": "TSize", "operator": "one-of", "values": [1, 2, 3]}
                ],
                "form_id": "b_iot_32_fixture",
                "length_bits": 32,
                "semantic_handler": "BindBundleTileIO",
            },
        )

        _, document = self.render(unit)

        self.assertIn(
            "0000000000000000000000000000000000000000000000000101001000010011", document
        )
        self.assertNotIn(
            "0000000000000000000000000000000000000000000000000101000000010011", document
        )

    def test_cube_start_decode_checks_operation_function_and_shared_policy(
        self,
    ) -> None:
        cases = (
            ("BSTART.TMATMUL", "TMATMUL", 0, "TRUE"),
            ("BSTART.TGEMVMX.ACC", "TGEMV_MX_ACC", 22, "FALSE"),
        )
        for mnemonic, operation, function, shared in cases:
            with self.subTest(mnemonic=mnemonic):
                unit = instruction_unit(
                    "block",
                    mnemonic,
                    {
                        "encoding": [
                            {"index": 0, "match": "0x00031181", "width_bits": 32}
                        ],
                        "fields": [],
                        "form_id": f"{mnemonic.lower().replace('.', '_')}_fixture",
                        "length_bits": 32,
                        "semantic_handler": "ExecuteBundleStart",
                    },
                )
                unit.metadata["contract"] = {
                    "tile_operation": operation,
                    "cube_function": function,
                    "shared_operands_allowed": shared == "TRUE",
                }

                _, document = self.render(unit)
                identifier = mnemonic.replace(".", "_")

                self.assertIn(
                    f"InstructionContractTileOperation_{identifier}() == "
                    f"TileOperation_{operation}",
                    document,
                )
                self.assertIn(
                    f"InstructionContractCubeFunction_{identifier}() == {function}",
                    document,
                )
                self.assertIn(
                    f"InstructionContractSharedOperandsAllowed_{identifier}() == "
                    f"{shared}",
                    document,
                )

    def test_cube_start_avs_metadata_is_fail_closed(self) -> None:
        unit = instruction_unit(
            "block",
            "BSTART.TMATMUL",
            {
                "encoding": [
                    {"index": 0, "match": "0x00031181", "width_bits": 32}
                ],
                "fields": [],
                "form_id": "bstart_tmatmul_fixture",
                "length_bits": 32,
                "semantic_handler": "ExecuteBundleStart",
            },
        )
        unit.metadata["contract"] = {"cube_function": 0}

        with self.assertRaisesRegex(ValueError, "incomplete CUBE AVS contract"):
            self.render(unit)

    def test_tile_static_test_checks_selector_classification_and_block_composition(
        self,
    ) -> None:
        unit = instruction_unit(
            "tile",
            "TLOAD",
            {
                "family": "TLSU",
                "selector": "0x000",
                "semantic_handler": "TLOAD",
                "operands": [{"field": "destination0", "role": "destination"}],
            },
        )

        path, document = self.render(unit)

        self.assertEqual(path.name, "tile-static-tload-contract-001.asl")
        self.assertIn("DecodeTileOperation(TileDecode_TLSU", document)
        self.assertIn("TileOperationOfIndex(3) == TileOperation_TLOAD", document)
        self.assertIn("TileHandlerOfIndex(3) == TileHandler_TLOAD", document)
        self.assertIn("TileClassOfIndex(3) == TileClass_MemoryAndDataMovement", document)
        self.assertIn("TileEngineOfIndex(3) == TileEngine_TLSU", document)
        self.assertIn("// classification: memory-and-data-movement/regular", document)
        self.assertIn("// block: BSTART | B.IOT | BSTOP", document)

    def test_cube_tile_static_test_checks_function_and_shared_policy(self) -> None:
        unit = instruction_unit(
            "tile",
            "TMATMUL",
            {
                "family": "CUBE",
                "function": 0,
                "semantic_handler": "TMATMUL",
                "operands": [
                    {"field": "destination0", "role": "destination"},
                    {"field": "source0", "role": "left"},
                    {"field": "source1", "role": "right"},
                ],
            },
        )
        unit.metadata["engine"] = "CUBE"
        source_text = """
readonly func InstructionContractCubeFunction_TMATMUL()
    => integer {0..31}
begin
    return 0;
end;
readonly func InstructionContractSharedOperandsAllowed_TMATMUL()
    => boolean
begin
    return TRUE;
end;
"""

        _, document = self.render(unit, source_text=source_text)

        self.assertIn("InstructionContractCubeFunction_TMATMUL() == 0", document)
        self.assertIn(
            "InstructionContractSharedOperandsAllowed_TMATMUL() == TRUE",
            document,
        )

    def test_cube_tile_static_helpers_are_fail_closed(self) -> None:
        unit = instruction_unit(
            "tile",
            "TMATMUL",
            {
                "family": "CUBE",
                "function": 0,
                "semantic_handler": "TMATMUL",
                "operands": [],
            },
        )
        unit.metadata["engine"] = "CUBE"
        source_text = """
readonly func InstructionContractCubeFunction_TMATMUL()
    => integer {0..31}
begin
    return 0;
end;
"""

        with self.assertRaisesRegex(ValueError, "incomplete CUBE Tile helpers"):
            self.render(unit, source_text=source_text)

    def test_regeneration_is_byte_identical(self) -> None:
        unit = instruction_unit(
            "scalar",
            "ADD",
            {
                "encoding": [{"index": 0, "match": "0x00000005", "width_bits": 32}],
                "fields": [],
                "form_id": "add_32_fixture",
                "length_bits": 32,
                "semantic_family": "ALU",
                "semantic_handler": "ScalarBinary",
            },
        )

        self.assertEqual(self.render(unit), self.render(unit))

    def test_non_mnemonic_unit_gets_one_static_compile_owner(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "asl/arch/state/program-counter.asl"
            source.parent.mkdir(parents=True)
            source.write_text("constant TEST_PC = 0;\n", encoding="utf-8")
            concept = AslUnit(
                unit_id="PTO-ARCH-STATE-PROGRAM-COUNTER",
                surface="arch",
                classification=("state", "program-counter"),
                depends_on=(),
                source_path=Path("asl/arch/state/program-counter.asl"),
                mnemonic=None,
                line_count=1,
            )

            path, document = self.render_concept(root, concept)

        self.assertEqual(
            path.name,
            "arch-static-program-counter-contract-001.asl",
        )
        self.assertIn('"source":"asl/arch/state/program-counter.asl"', document)
        self.assertIn('"kind":"static-invariant"', document)
        self.assertEqual(document.count("func main() => integer"), 1)


if __name__ == "__main__":
    unittest.main()
