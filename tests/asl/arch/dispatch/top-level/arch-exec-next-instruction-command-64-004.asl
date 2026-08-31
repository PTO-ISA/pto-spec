// PTO-TEST: {"id":"PTO-AVS-ARCH-NEXT-INSTRUCTION-COMMAND-64-004","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-INST-BLOCK-L-BSTOP"],"kind":"execution","summary":"A fetched 64-bit L.BSTOP executes through the next-instruction action.","pass_condition":"ExecuteNextPTOInstruction commits the active bundle and returns to its entry TPC.","related_sources":["asl/arch/memory-model/instruction-fetch.asl","asl/block/lifecycle/L.BSTOP.asl"]}
func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x280;
    WriteTPC(entry);
    let started = ExecuteCommandInstruction(
        Zeros{64} + 0x00000011,
        32);
    assert started == CommandExecution_Executed;
    let step_pc = ReadTPC();
    WriteMemoryByte(step_pc, Zeros{8} + 0x0f);
    WriteMemoryByte(step_pc + 1, Zeros{8});
    WriteMemoryByte(step_pc + 2, Zeros{8});
    WriteMemoryByte(step_pc + 3, Zeros{8});
    WriteMemoryByte(step_pc + 4, Zeros{8} + 0x01);
    WriteMemoryByte(step_pc + 5, Zeros{8});
    WriteMemoryByte(step_pc + 6, Zeros{8});
    WriteMemoryByte(step_pc + 7, Zeros{8});
    let pre_cycle = _SystemRegisters.cycle;

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert !_BundleActive;
    assert ReadTPC() == entry;
    return 0;
end;
