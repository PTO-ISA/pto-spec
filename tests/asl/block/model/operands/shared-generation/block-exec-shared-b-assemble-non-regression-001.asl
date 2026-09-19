// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-B-ASSEMBLE-NON-REGRESSION-001","source":"asl/block/model/operands/shared-generation.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-B-ASSEMBLE-RANGE-001"],"kind":"execution","summary":"Shared B.ASSEMBLE keeps its fixed-column and ParentCapacity-complete semantics beside Local CUBE parent finalization.","pass_condition":"Shared INIT derives the parent from ParentCapacity, continuation preserves the fixed writer columns, and collective LAST publishes only after complete capacity coverage; no Local CUBE descriptor finalization is applied.","related_sources":["asl/block/model/operands/local-generation-cube.asl","asl/block/model/operands/shared-generation.asl","asl/block/operands/B.ASSEMBLE.asl"]}
pure func SharedRegressionStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func SharedRegressionBIOS(size_code: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = Zeros{4} + size_code;
    instruction[11:9] = '111';
    return instruction;
end;

pure func SharedRegressionAssemble(init: boolean, last: boolean,
                                   offset: integer, writer_size: integer)
    => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[30:20] = Zeros{11} + offset;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = Zeros{4} + writer_size;
    return instruction;
end;

func ExecuteSharedRegressionWriter(init: boolean, last: boolean,
                                   offset: integer, value: integer) => boolean
begin
    _Memory[[0]] = Zeros{8} + value;
    let started = ExecuteCommandInstruction(SharedRegressionStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
    let binder = ExecuteCommandInstruction(
        SharedRegressionBIOS(if init then 2 else 0), 32);
    let modifier = ExecuteCommandInstruction(
        SharedRegressionAssemble(init, last, offset, 1), 32);
    assert started == CommandExecution_Executed &&
           binder == CommandExecution_Executed &&
           modifier == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func main() => integer
begin
    ResetProfileState();
    let init = ExecuteSharedRegressionWriter(TRUE, FALSE, 0, 0x11);
    assert init;
    let shared_tile_id = (Zeros{6} + 8) as SharedTileID;
    assert BundleSharedGenerationOpen(shared_tile_id);
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;

    ClearBundleHeaderState();
    let last = ExecuteSharedRegressionWriter(FALSE, TRUE, 1, 0x22);
    assert last;
    assert SharedTilePublished(shared_tile_id);
    let shared = SharedTileRecord(shared_tile_id);
    assert shared.tile.capacity_bytes == 256;
    assert shared.tile.columns == 128;
    assert TileReadLogicalElement(shared.tile, 0) ==
        Zeros{PTO_XLEN} + 0x11;
    assert TileReadLogicalElement(shared.tile, 128) ==
        Zeros{PTO_XLEN} + 0x22;
    return 0;
end;
