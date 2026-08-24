// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-RANGE-CONSTRUCTION-001","source":"asl/block/model/operands/shared-generation.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001"],"kind":"execution","summary":"Two decoded Shared writers construct and atomically publish one parent generation.","pass_condition":"INIT retains the old Sx mapping while recording the first CELL, LAST supplies the second CELL and publishes the complete 256 B parent with both values.","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/operands/B.ASSEMBLE.asl"]}
pure func SharedGenerationStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedGenerationBIOS() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedGenerationAssemble(init: boolean, last: boolean,
                                   offset: integer,
                                   parent_size: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + parent_size;
    return instruction;
end;

func ExecuteSharedWriter(init: boolean, last: boolean,
                         offset: integer, parent_size: integer,
                         value: integer) => boolean
begin
    _Memory[[0]] = Zeros{8} + value;
    let started = ExecuteCommandInstruction(SharedGenerationStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    let binder = ExecuteCommandInstruction(SharedGenerationBIOS(), 32);
    let modifier = ExecuteCommandInstruction(
        SharedGenerationAssemble(init, last, offset, parent_size), 32);
    assert binder == CommandExecution_Executed;
    assert modifier == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func main() => integer
begin
    ResetProfileState();
    let first = ExecuteSharedWriter(TRUE, FALSE, 0, 2, 0x11);
    assert first && _LastFault == Fault_None;
    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;

    ClearBundleHeaderState();
    let second = ExecuteSharedWriter(FALSE, TRUE, 1, 0, 0x22);
    assert second && _LastFault == Fault_None;
    assert SharedTilePublished(shared_tile_id);
    let shared = SharedTileRecord(shared_tile_id);
    assert shared.tile.capacity_bytes == 256;
    assert TileReadLogicalElement(shared.tile, 0) == Zeros{PTO_XLEN} + 0x11;
    assert TileReadLogicalElement(shared.tile, 128) == Zeros{PTO_XLEN} + 0x22;
    return 0;
end;
