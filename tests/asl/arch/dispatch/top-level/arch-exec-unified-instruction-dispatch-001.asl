// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTUNIFIEDINSTRUCTIONDISPATCH-EXECUTION-001","source":"asl/arch/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Covers Unified Instruction Dispatch.","pass_condition":"TestUnifiedInstructionDispatch completes without assertion failure","related_sources":[]}
func TestUnifiedInstructionDispatch()
begin
    ResetProfileState();
    let scalar_status = ExecutePTOInstruction(
        Zeros{64} + 0x0000000000000015, 32);
    assert scalar_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let command_status = ExecutePTOInstruction(
        Zeros{64} + 0x0000000000000011, 32);
    assert command_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;

    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0xaa);
    let rejected_status = ExecutePTOInstruction(Zeros{64}, 64);
    assert rejected_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xaa;
end;
func main() => integer
begin
    ResetProfileState();
    TestUnifiedInstructionDispatch();
    return 0;
end;
