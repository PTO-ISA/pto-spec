// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-ODD-PC-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"fault","summary":"An odd TPC faults before fetch or decoded execution.","pass_condition":"ExecuteNextPTOInstruction raises InstructionPC, preserves GPR2, and does not tick decoded execution time.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x101;
    WriteTPC(entry);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0xaa);

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_InstructionPC;
    assert _FaultAddress == entry;
    assert _TrapContexts[[0]].tpc == entry;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xaa;
    return 0;
end;
