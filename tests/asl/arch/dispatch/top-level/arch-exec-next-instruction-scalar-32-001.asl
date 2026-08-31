// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-SCALAR-32-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-INST-SCALAR-ADD"],"kind":"execution","summary":"A fetched 32-bit ADD executes through the next-instruction action.","pass_condition":"ExecuteNextPTOInstruction writes GPR3=30 and advances TPC by four bytes.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/scalar/alu/ADD.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    WritePEGPR(0, 1, Zeros{PTO_XLEN} + 10);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 20);
    WriteMemoryByte(entry, Zeros{8} + 0x85);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x81);
    WriteMemoryByte(entry + 2, Zeros{8} + 0x20);
    WriteMemoryByte(entry + 3, Zeros{8});
    let pre_cycle = _SystemRegisters.cycle;

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 30;
    assert ReadTPC() == entry + 4;
    return 0;
end;
