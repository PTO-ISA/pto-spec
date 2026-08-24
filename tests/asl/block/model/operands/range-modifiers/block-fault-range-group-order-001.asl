// PTO-TEST: {"id":"PTO-AVS-BLOCK-RANGE-GROUP-ORDER-001","source":"asl/block/model/operands/range-modifiers.asl","requirements":["PTO-INST-BLOCK-B-SUBVIEW","PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS"],"kind":"fault","summary":"B.SUBVIEW and B.ASSEMBLE execute only in the immediately preceding B.IOT/B.IOS group, consuming source0, source1, and destination roles in strict order.","pass_condition":"valid Local/Shared source and destination groups, omissions, duplicates, reverse/misordered/absent/intervening forms, B.IOT.L, and B.IOS source1 are each executed with the specified carrier or BundleControl result and no retroactive effect","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/tile-bindings.asl","asl/block/model/operands/shared-bindings.asl"]}
pure func SubviewForRole(source_select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if source_select then '1' else '0';
    instruction[19:15] = Zeros{5} + 1;
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;
pure func AssembleForDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    // ParentSizeCode=1 is the INIT form; keep this role fixture legal so
    // later assertions exercise group ordering rather than control faults.
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;
pure func BIOTTwoSourceBinder(last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + 3;
    instruction[31:26] = Zeros{6} + 4;
    instruction[19] = if last then '1' else '0';
    instruction[11:9] = '111';
    return instruction;
end;
pure func BIOTFullBinder(last: boolean) => bits(64)
begin
    var instruction = BIOTTwoSourceBinder(last);
    instruction[18:15] = Zeros{4} + 10;
    instruction[8:7] = '00';
    return instruction;
end;
pure func BIOTSource0Binder(last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 3;
    instruction[19] = if last then '1' else '0';
    instruction[11:9] = '111';
    return instruction;
end;
pure func BIOTDestinationBinder(last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = Zeros{4} + 10;
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    return instruction;
end;
pure func BIOSSourceBinder(mode: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 1;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = mode;
    return instruction;
end;
pure func BIOSDestinationBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '111';
    return instruction;
end;
func StartBlock()
begin
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
end;
func AssertBundleControl(instruction: bits(64), source0_seen: boolean, source1_seen: boolean, destination_seen: boolean)
begin
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(instruction, 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTPC() == before_tpc;
    assert _BundleRangeGroup.source0_seen == source0_seen;
    assert _BundleRangeGroup.source1_seen == source1_seen;
    assert _BundleRangeGroup.destination_seen == destination_seen;
end;
func main() => integer
begin
    // A complete Local group consumes source0, source1, and destination in
    // order; the exact carriers prove all three valid role paths.
    ResetProfileState();
    StartBlock();
    let full = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let source0 = ExecuteCommandInstruction(SubviewForRole(FALSE), 32);
    let source1 = ExecuteCommandInstruction(SubviewForRole(TRUE), 32);
    let destination = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert full == CommandExecution_Executed;
    assert source0 == CommandExecution_Executed;
    assert source1 == CommandExecution_Executed;
    assert destination == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].source0_subview.valid;
    assert _BundleTileBindings[[0]].source1_subview.valid;
    assert _BundleTileBindings[[0]].destination_assemble.valid;

    // Omitting earlier roles does not prevent a later role from binding.
    ResetProfileState();
    StartBlock();
    let omitted_source0 = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let omitted_source0_source1 = ExecuteCommandInstruction(SubviewForRole(TRUE), 32);
    let omitted_source0_destination = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert omitted_source0 == CommandExecution_Executed;
    assert omitted_source0_source1 == CommandExecution_Executed;
    assert omitted_source0_destination == CommandExecution_Executed;
    assert !_BundleTileBindings[[0]].source0_subview.valid;
    assert _BundleTileBindings[[0]].source1_subview.valid;
    assert _BundleTileBindings[[0]].destination_assemble.valid;
    ResetProfileState();
    StartBlock();
    let omitted_sources = ExecuteCommandInstruction(BIOTDestinationBinder(FALSE), 32);
    let omitted_sources_destination = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert omitted_sources == CommandExecution_Executed;
    assert omitted_sources_destination == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_assemble.valid;

    // Shared source and destination groups have the same immediate-group
    // association, while source1 is not a Shared role.
    ResetProfileState();
    StartBlock();
    let shared_source_binder = ExecuteCommandInstruction(BIOSSourceBinder('111'), 32);
    let shared_source = ExecuteCommandInstruction(SubviewForRole(FALSE), 32);
    assert shared_source_binder == CommandExecution_Executed;
    assert shared_source == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].source0_subview.valid;
    ResetProfileState();
    StartBlock();
    let shared_destination_binder = ExecuteCommandInstruction(BIOSDestinationBinder(), 32);
    let shared_destination = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert shared_destination_binder == CommandExecution_Executed;
    assert shared_destination == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].destination_assemble.valid;
    ResetProfileState();
    StartBlock();
    let shared_source1_binder = ExecuteCommandInstruction(BIOSSourceBinder('111'), 32);
    assert shared_source1_binder == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(TRUE), FALSE, FALSE, FALSE);

    // Every duplicate role is rejected after its first accepted carrier.
    ResetProfileState();
    StartBlock();
    let duplicate_source0_binder = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let duplicate_source0_first = ExecuteCommandInstruction(SubviewForRole(FALSE), 32);
    assert duplicate_source0_binder == CommandExecution_Executed;
    assert duplicate_source0_first == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(FALSE), TRUE, FALSE, FALSE);
    ResetProfileState();
    StartBlock();
    let duplicate_source1_binder = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let duplicate_source1_first = ExecuteCommandInstruction(SubviewForRole(TRUE), 32);
    assert duplicate_source1_binder == CommandExecution_Executed;
    assert duplicate_source1_first == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(TRUE), FALSE, TRUE, FALSE);
    ResetProfileState();
    StartBlock();
    let duplicate_destination_binder = ExecuteCommandInstruction(BIOTDestinationBinder(FALSE), 32);
    let duplicate_destination_first = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert duplicate_destination_binder == CommandExecution_Executed;
    assert duplicate_destination_first == CommandExecution_Executed;
    AssertBundleControl(AssembleForDestination(), FALSE, FALSE, TRUE);

    // Reverse and misordered role paths fault at the attempted modifier and
    // preserve the carriers already accepted in the group.
    ResetProfileState();
    StartBlock();
    let reverse_binder = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let reverse_source1 = ExecuteCommandInstruction(SubviewForRole(TRUE), 32);
    assert reverse_binder == CommandExecution_Executed;
    assert reverse_source1 == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(FALSE), FALSE, TRUE, FALSE);
    ResetProfileState();
    StartBlock();
    let destination_first_binder = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let destination_first = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert destination_first_binder == CommandExecution_Executed;
    assert destination_first == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(FALSE), FALSE, FALSE, TRUE);
    ResetProfileState();
    StartBlock();
    let source_destination_source_binder = ExecuteCommandInstruction(BIOTFullBinder(FALSE), 32);
    let source_destination_source0 = ExecuteCommandInstruction(SubviewForRole(FALSE), 32);
    let source_destination = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert source_destination_source_binder == CommandExecution_Executed;
    assert source_destination_source0 == CommandExecution_Executed;
    assert source_destination == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(TRUE), TRUE, FALSE, TRUE);

    // Absent roles reject with no carrier update.
    ResetProfileState();
    StartBlock();
    let absent_source1_binder = ExecuteCommandInstruction(BIOTSource0Binder(FALSE), 32);
    assert absent_source1_binder == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(TRUE), FALSE, FALSE, FALSE);
    assert !_BundleTileBindings[[0]].source1_subview.valid;
    ResetProfileState();
    StartBlock();
    let absent_destination_binder = ExecuteCommandInstruction(BIOTSource0Binder(FALSE), 32);
    assert absent_destination_binder == CommandExecution_Executed;
    AssertBundleControl(AssembleForDestination(), FALSE, FALSE, FALSE);
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
    ResetProfileState();
    StartBlock();
    let absent_source_binder = ExecuteCommandInstruction(BIOTDestinationBinder(FALSE), 32);
    assert absent_source_binder == CommandExecution_Executed;
    AssertBundleControl(SubviewForRole(FALSE), FALSE, FALSE, FALSE);
    assert !_BundleTileBindings[[0]].source0_subview.valid;

    // L=1 closes the B.IOT effective binding but leaves its syntactic
    // modifier group open.  A modifier still binds after that form.
    ResetProfileState();
    StartBlock();
    let last_binder = ExecuteCommandInstruction(BIOTSource0Binder(TRUE), 32);
    let last_source0 = ExecuteCommandInstruction(SubviewForRole(FALSE), 32);
    assert last_binder == CommandExecution_Executed;
    assert last_source0 == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].source0_subview.valid;
    ResetProfileState();
    StartBlock();
    let last_destination_binder = ExecuteCommandInstruction(BIOTDestinationBinder(TRUE), 32);
    let last_destination = ExecuteCommandInstruction(AssembleForDestination(), 32);
    assert last_destination_binder == CommandExecution_Executed;
    assert last_destination == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_assemble.valid;

    // Any intervening command closes the group.  The following modifier has
    // no retroactive effect on the earlier binder and does not advance TPC.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    StartBlock();
    let intervening_binder = ExecuteCommandInstruction(BIOTSource0Binder(FALSE), 32);
    let intervening_command = ExecuteCommandInstruction(Zeros{64} + 0x00002043, 32);
    assert intervening_binder == CommandExecution_Executed;
    assert intervening_command == CommandExecution_Executed;
    let before_intervening_modifier = ReadTPC();
    AssertBundleControl(SubviewForRole(FALSE), FALSE, FALSE, FALSE);
    assert ReadTPC() == before_intervening_modifier;
    assert !_BundleTileBindings[[0]].source0_subview.valid;
    return 0;
end;
