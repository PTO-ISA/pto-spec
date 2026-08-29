// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-ODD-PC-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"fault","summary":"An odd TPC faults before instruction fetch or scalar effects.","pass_condition":"ExecuteOnePTOStep raises InstructionPC, records the original TPC in trap context, preserves GPR state, and does not tick decoded execution time.","related_sources":["asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    WriteTPC(Zeros{PTO_XLEN} + 0x101);
    let initialized = InitializeFunctionalModelGPR(
        2, Zeros{PTO_XLEN} + 0xaa);
    assert initialized;

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Trap;
    assert result.pre_tpc == Zeros{PTO_XLEN} + 0x101;
    assert result.post_tpc == ReadTPC();
    assert result.length_bits == 0;
    assert result.fault == Fault_InstructionPC;
    assert result.fault_address == Zeros{PTO_XLEN} + 0x101;
    assert _LastFault == Fault_InstructionPC;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x101;
    assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x101;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xaa;
    return 0;
end;
