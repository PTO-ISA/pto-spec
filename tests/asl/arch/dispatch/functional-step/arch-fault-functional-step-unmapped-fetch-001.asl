// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-UNMAPPED-FETCH-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"fault","summary":"A first instruction halfword outside reference memory raises InstructionPage.","pass_condition":"ExecuteOnePTOStep records the original TPC in trap context, preserves a sentinel GPR, and does not tick decoded execution time.","related_sources":["asl/arch/memory-model/address-space.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES);
    let initialized = InitializeFunctionalModelGPR(
        2, Zeros{PTO_XLEN} + 0xbb);
    assert initialized;

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Trap;
    assert result.instruction_status == PTOFunctionalInstruction_NotAttempted;
    assert result.pre_tpc == Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    assert result.post_tpc == ReadTPC();
    assert result.length_bits == 0;
    assert result.fault == Fault_InstructionPage;
    assert result.fault_address == result.pre_tpc;
    assert _LastFault == Fault_InstructionPage;
    assert _FaultAddress == Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    assert _TrapContexts[[0]].tpc == result.pre_tpc;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xbb;
    return 0;
end;
