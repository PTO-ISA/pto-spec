// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-SCALAR-16-002","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-INST-SCALAR-C-MOVI"],"kind":"execution","summary":"A fetched 16-bit C.MOVI executes through the next-instruction action.","pass_condition":"ExecuteNextPTOInstruction writes GPR2 and advances TPC by two bytes.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/scalar/alu/C.MOVI.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteTPC(entry);
    WriteMemoryByte(entry, Zeros{8} + 0x16);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x14);
    let pre_cycle = _SystemRegisters.cycle;

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xfffffffffffffff0;
    assert ReadTPC() == entry + 2;
    return 0;
end;
