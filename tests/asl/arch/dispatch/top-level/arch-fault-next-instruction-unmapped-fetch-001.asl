// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-UNMAPPED-FETCH-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"fault","summary":"A first instruction halfword outside reference memory raises InstructionPage.","pass_condition":"ExecuteNextPTOInstruction records the original TPC, preserves GPR2, and performs no decoded attempt.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    WriteTPC(entry);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0xbb);

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_InstructionPage;
    assert _FaultAddress == entry;
    assert _TrapContexts[[0]].tpc == entry;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xbb;
    return 0;
end;
