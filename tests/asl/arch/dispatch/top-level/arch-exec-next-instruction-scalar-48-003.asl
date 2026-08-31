// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-SCALAR-48-003","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-INST-SCALAR-HL-XORI"],"kind":"execution","summary":"A fetched 48-bit HL.XORI executes through the next-instruction action.","pass_condition":"ExecuteNextPTOInstruction writes the decoded result and advances TPC by six bytes.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/scalar/alu/HL.XORI.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    WritePEGPR(0, 1, Zeros{PTO_XLEN});
    WriteMemoryByte(entry, Zeros{8} + 0x0e);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x80);
    WriteMemoryByte(entry + 2, Zeros{8} + 0x95);
    WriteMemoryByte(entry + 3, Zeros{8} + 0xc0);
    WriteMemoryByte(entry + 4, Zeros{8});
    WriteMemoryByte(entry + 5, Zeros{8});
    let pre_cycle = _SystemRegisters.cycle;

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xffffffffff800000;
    assert ReadTPC() == entry + 6;
    return 0;
end;
