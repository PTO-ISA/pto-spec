// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-ASSEMBLE-ENCODING-001","source":"asl/block/operands/B.ASSEMBLE.asl","requirements":["PTO-INST-BLOCK-B-ASSEMBLE","PTO-INST-BLOCK-B-IOT","PTO-INST-BLOCK-B-IOS"],"kind":"execution","summary":"B.ASSEMBLE records a nonzero WriterSizeCode for allocating and Local ParentRef or Shared reused-destination continuation carriers.","pass_condition":"INIT uses the preceding destination binder SizeCode as ParentCapacity; Local continuation uses one final source-form ParentRef, while Shared continuation contextually reclassifies the final SizeCode=0 B.IOS as the reused destination; reserved or zero participating writer controls fault before state effects.","related_sources":["asl/block/model/dispatch/commands.asl","asl/block/model/operands/range-modifiers.asl"]}
pure func AssembleInstruction(init: boolean, last: boolean, reg_src: integer,
                              uimm11: integer, writer_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + uimm11;
    instruction[19:15] = Zeros{5} + reg_src;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer_size;
    return instruction;
end;
pure func LocalDestinationBinder(size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + 2;
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    return instruction;
end;
pure func LocalParentRefBinder(selector: integer, last: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6} + selector;
    instruction[19] = if last then '1' else '0';
    instruction[11:9] = '111';
    instruction[8:7] = '00';
    return instruction;
end;
pure func SharedBinder(shared_tile_id: integer, size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + shared_tile_id;
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111';
    return instruction;
end;
func StartBlock()
begin
    let started = ExecuteCommandInstruction(Zeros{64} + 0x00019181, 32);
    assert started == CommandExecution_Executed;
end;
func ResetAssembleFixture()
begin
    ResetBundleControlState();
    ClearFault();
    WriteBPC(Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN});
end;
func AssertLocalInit(parent_size: integer, writer_size: integer)
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x580);
    StartBlock();
    let bound = ExecuteCommandInstruction(
        LocalDestinationBinder(parent_size), 32);
    let assembled = ExecuteCommandInstruction(
        AssembleInstruction(TRUE, FALSE, 0, 0, writer_size), 32);
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    assert _BundleTileBindings[[0]].destination_valid;
    assert !_BundleTileBindings[[0]].parent_ref_valid;
    assert _BundleTileBindings[[0]].destination_size == parent_size;
    assert _BundleTileBindings[[0]].destination_assemble.size_code == writer_size;
    assert _BundleTileBindings[[0]].destination_assemble.init;
end;
func AssertLocalParentRef(writer_size: integer)
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x590);
    StartBlock();
    let bound = ExecuteCommandInstruction(
        LocalParentRefBinder(0, TRUE), 32);
    let assembled = ExecuteCommandInstruction(
        AssembleInstruction(FALSE, TRUE, 0, 0, writer_size), 32);
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    assert !_BundleTileBindings[[0]].destination_valid;
    assert _BundleTileBindings[[0]].source0_valid == FALSE;
    assert _BundleTileBindings[[0]].parent_ref_valid;
    assert _BundleTileBindings[[0]].parent_ref == 0;
    assert _BundleTileBindings[[0]].parent_ref_relative;
    assert _BundleTileBindings[[0]].destination_assemble.size_code == writer_size;
    assert !_BundleTileBindings[[0]].destination_assemble.init;
    assert _BundleTileBindings[[0]].destination_assemble.last;
end;
func AssertSharedInit(parent_size: integer, writer_size: integer)
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x5a0);
    StartBlock();
    let bound = ExecuteCommandInstruction(SharedBinder(9, parent_size), 32);
    let assembled = ExecuteCommandInstruction(
        AssembleInstruction(TRUE, TRUE, 0, 0, writer_size), 32);
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].size_code == parent_size;
    assert !BundleSharedBindingIsReusedDestination(0);
    assert BundleSharedBindingCount() == 1;
    assert _BundleSharedBindings[[0]].destination_assemble.size_code == writer_size;
end;
func AssertSharedZeroSourceOutsideAssemble()
begin
    ResetAssembleFixture();
    StartBlock();
    let bound = ExecuteCommandInstruction(SharedBinder(10, 0), 32);
    assert bound == CommandExecution_Executed;
    assert BundleSharedBindingPhysicalCount() == 1;
    assert BundleSharedBindingCount() == 1;
    assert !BundleSharedBindingIsReusedDestination(0);
end;
func AssertSharedContinuationDestination(writer_size: integer)
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x5b0);
    StartBlock();
    let bound = ExecuteCommandInstruction(SharedBinder(9, 0), 32);
    let assembled = ExecuteCommandInstruction(
        AssembleInstruction(FALSE, TRUE, 0, 0, writer_size), 32);
    assert bound == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    assert _BundleSharedBindings[[0]].size_code == 0;
    assert BundleSharedBindingIsReusedDestination(0);
    assert BundleSharedBindingCount() == 0;
    assert BundleSharedBindingPhysicalCount() == 1;
    assert _BundleSharedBindings[[0]].destination_assemble.size_code == writer_size;
end;
func AssertAssembleIllegal(instruction: bits(64))
begin
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    StartBlock();
    let started = ExecuteCommandInstruction(LocalDestinationBinder(4), 32);
    assert started == CommandExecution_Executed;
    let before_tpc = ReadTPC();
    let rejected = ExecuteCommandInstruction(instruction, 32);
    assert rejected == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTPC() == before_tpc;
    assert _BundleRangeGroup.open;
    assert !_BundleRangeGroup.destination_seen;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
end;
func main() => integer
begin
    assert DecodeCommandForm(AssembleInstruction(TRUE, TRUE, 0, 0, 1), 32) == 75;
    AssertLocalInit(1, 1);
    AssertLocalInit(10, 10);
    AssertLocalParentRef(1);
    AssertSharedInit(1, 1);
    AssertSharedInit(12, 12);
    AssertSharedZeroSourceOutsideAssemble();
    AssertSharedContinuationDestination(12);

    // A participating writer must be nonzero; the raw reserved high codes
    // are rejected before the GPR is read or the carrier advances.
    ResetAssembleFixture();
    WriteTPC(Zeros{PTO_XLEN} + 0x610);
    StartBlock();
    let bound = ExecuteCommandInstruction(LocalDestinationBinder(4), 32);
    assert bound == CommandExecution_Executed;
    let zero_writer = ExecuteCommandInstruction(
        AssembleInstruction(TRUE, FALSE, 0, 0, 0), 32);
    assert zero_writer == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleTileBindings[[0]].destination_assemble.valid;
    for reserved_size = 13 to 15 looplimit 3 do
        AssertAssembleIllegal(AssembleInstruction(TRUE, FALSE, 0, 0,
                                                   reserved_size));
    end;
    for selector = 24 to 31 looplimit 8 do
        AssertAssembleIllegal(AssembleInstruction(TRUE, FALSE, selector, 0, 1));
    end;
    return 0;
end;
