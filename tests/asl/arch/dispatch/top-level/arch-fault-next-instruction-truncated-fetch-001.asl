// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-TRUNCATED-FETCH-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"fault","summary":"A mapped 64-bit prefix faults when the complete range crosses reference memory.","pass_condition":"ExecuteNextPTOInstruction raises InstructionPage before decoded execution and preserves GPR2.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_BYTES - 4);
    WriteTPC(entry);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0xcc);
    WriteMemoryByte(entry, Zeros{8} + 0x0f);
    WriteMemoryByte(entry + 1, Zeros{8});

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_InstructionPage;
    assert _FaultAddress == entry;
    assert _TrapContexts[[0]].tpc == entry;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xcc;
    return 0;
end;
