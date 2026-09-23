// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-PARENT-REF-006","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"fault","summary":"A source-form B.IOS reclassified as a B.ASSEMBLE continuation destination cannot carry last-use.","pass_condition":"A last-use ParentRef faults TileLegality before LAST publication and leaves the prior Shared descriptor and payload unchanged.","related_sources":["asl/block/model/operands/range-modifiers.asl","asl/block/model/operands/shared-generation.asl"]}
pure func SharedParentRefStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedParentRefBinding(size_code: bits(4),
                                  last_use: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = size_code;
    instruction[11:9] = '111';
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

pure func SharedParentRefAssemble(init: boolean, last: boolean,
                                   offset: integer) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;

func SharedParentRefSetDimensions()
begin
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 8) as SharedTileID;
    _Memory[[0]] = Zeros{8} + 0x11;
    let init_start = ExecuteCommandInstruction(SharedParentRefStart(), 32);
    SharedParentRefSetDimensions();
    let init_binder = ExecuteCommandInstruction(
        SharedParentRefBinding('0010', FALSE), 32);
    let init_modifier = ExecuteCommandInstruction(
        SharedParentRefAssemble(TRUE, FALSE, 0), 32);
    assert init_start == CommandExecution_Executed &&
           init_binder == CommandExecution_Executed &&
           init_modifier == CommandExecution_Executed;
    let initialized = ExecuteBundleTileOperation();
    assert initialized;
    assert BundleSharedGenerationOpen(shared_id);
    let prior = SharedTileRecord(shared_id);

    ClearBundleHeaderState();
    _Memory[[0]] = Zeros{8} + 0x22;
    let last_start = ExecuteCommandInstruction(SharedParentRefStart(), 32);
    SharedParentRefSetDimensions();
    let last_binder = ExecuteCommandInstruction(
        SharedParentRefBinding(Zeros{4}, TRUE), 32);
    let modifier_tpc = ReadTPC();
    let last_modifier = ExecuteCommandInstruction(
        SharedParentRefAssemble(FALSE, TRUE, 1), 32);
    assert last_start == CommandExecution_Executed &&
           last_binder == CommandExecution_Executed;
    assert last_modifier == CommandExecution_Rejected;
    assert _LastFault == Fault_TileLegality;
    assert ReadTPC() == modifier_tpc;
    assert !_BundleSharedBindings[[0]].destination_assemble.valid;
    let after = SharedTileRecord(shared_id);
    assert after.descriptor_valid == prior.descriptor_valid;
    assert after.payload_live == prior.payload_live;
    assert after.published == prior.published;
    assert after.tile.capacity_bytes == prior.tile.capacity_bytes;
    assert after.tile.payload[[0]] == prior.tile.payload[[0]];
    return 0;
end;
