// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-COMMAND-64-004","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001","PTO-REQ-FUNCTIONAL-STEP-001"],"kind":"execution","summary":"One fetched 64-bit L.BSTOP executes through the functional step boundary.","pass_condition":"ExecuteOnePTOStep fetches eight little-endian bytes, commits the prepared active bundle, and reports a successful 64-bit step.","related_sources":["asl/block/lifecycle/L.BSTOP.asl"]}
func main() => integer
begin
    let entry = Zeros{PTO_XLEN} + 0x280;
    InitializeFunctionalModel(entry);
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

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Executed;
    assert result.pre_tpc == step_pc;
    assert result.post_tpc == entry;
    assert result.raw_instruction == Zeros{64} + 0x000000010000000f;
    assert result.length_bits == 64;
    assert result.fault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert !_BundleActive;
    assert ReadTPC() == entry;
    return 0;
end;
