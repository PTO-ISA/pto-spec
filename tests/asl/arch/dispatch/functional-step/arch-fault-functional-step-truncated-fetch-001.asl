// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-TRUNCATED-FETCH-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"fault","summary":"A mapped 64-bit prefix faults when the selected full byte range crosses reference memory.","pass_condition":"ExecuteOnePTOStep reports InstructionPage, records the original TPC in trap context, publishes no scalar effect, and does not tick decoded execution time.","related_sources":["asl/arch/memory-model/address-space.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    let fetch_pc = Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 4);
    InitializeFunctionalModel(fetch_pc);
    let initialized = InitializeFunctionalModelGPR(
        2, Zeros{PTO_XLEN} + 0xcc);
    assert initialized;
    WriteMemoryByte(fetch_pc, Zeros{8} + 0x0f);
    WriteMemoryByte(fetch_pc + 1, Zeros{8});

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Trap;
    assert result.pre_tpc == fetch_pc;
    assert result.post_tpc == ReadTPC();
    assert result.length_bits == 64;
    assert result.fault == Fault_InstructionPage;
    assert result.fault_address == fetch_pc;
    assert _LastFault == Fault_InstructionPage;
    assert _FaultAddress == fetch_pc;
    assert _TrapContexts[[0]].tpc == fetch_pc;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xcc;
    return 0;
end;
