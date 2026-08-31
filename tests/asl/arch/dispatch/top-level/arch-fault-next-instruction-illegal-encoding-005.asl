// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-ILLEGAL-ENCODING-005","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"fault","summary":"A fetched 64-bit value with no accepted form raises IllegalInstruction.","pass_condition":"ExecuteNextPTOInstruction performs one decoded attempt, raises IllegalInstruction at the original TPC, and preserves GPR2.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x55);
    WriteMemoryByte(entry, Zeros{8} + 0x0f);
    for offset = 1 to 7 do
        WriteMemoryByte(entry + NaturalToWord(offset), Zeros{8});
    end;
    let pre_cycle = _SystemRegisters.cycle;

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _FaultAddress == entry;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadPEGPR(0, 2) == Zeros{PTO_XLEN} + 0x55;
    return 0;
end;
