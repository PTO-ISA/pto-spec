func TestUnifiedInstructionDispatch()
begin
    ResetBlockControlState();
    ClearFault();
    let scalar_status = ExecutePTOInstruction(
        Zeros{64} + 0x0000000000000015, 32);
    assert scalar_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;

    ResetBlockControlState();
    ClearFault();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let command_status = ExecutePTOInstruction(
        Zeros{64} + 0x0000000000000011, 32);
    assert command_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;

    ClearFault();
    let rejected_status = ExecutePTOInstruction(Zeros{64}, 64);
    assert rejected_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
end;
