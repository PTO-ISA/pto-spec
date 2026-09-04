// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-LOCAL-M16-001","source":"asl/block/execution/BSTART.TIMG2COL.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-BSTART-TIMG2COL-CONTRACT-001","PTO-BSTART-TIMG2COL-CROP-001","PTO-BSTART-TIMG2COL-DEFINEDNESS-001"],"kind":"execution","summary":"Decoded BSTART.TIMG2COL directly publishes one canonical Local CUBE_M16 fragment.","pass_condition":"A nonzero K crop with TotalCol greater than ValidCol reads the expected GM interval while persistent CUBE_M16 geometry remains derived from ValidCol.","related_sources":["asl/block/model/dispatch/timg2col-execution.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func TIMG2COLLocalStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TIMG2COLLocalDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 22;
    return instruction;
end;

pure func TIMG2COLLocalIOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func TIMG2COLLocalDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = '0011';
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    for element = 0 to 31 do
        Store(Zeros{PTO_XLEN} + 32 + element, 1,
            Zeros{PTO_XLEN} + element + 1);
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN});
        WritePEGPR(agent, 3, Zeros{64} + 1 + (1 << 16) + (64 << 32) +
            (1 << 48) + (1 << 56));
        WritePEGPR(agent, 4, Zeros{64} + (1 << 32) + (1 << 37) +
            (1 << 42) + (1 << 48));
        WritePEGPR(agent, 5, Zeros{PTO_XLEN} + (32 << 32));
    end;
    let start = ExecuteCommandInstruction(TIMG2COLLocalStart(), 32);
    let datr = ExecuteCommandInstruction(TIMG2COLLocalDATR(), 32);
    assert start == CommandExecution_Executed && datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    let gm = ExecuteCommandInstruction(TIMG2COLLocalIOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(
        TIMG2COLLocalIOR(3, 4, 5), 32);
    let destination = ExecuteCommandInstruction(TIMG2COLLocalDestination(), 32);
    assert gm == CommandExecution_Executed &&
        parameters == CommandExecution_Executed &&
        destination == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let tile_index = _BundleTileBindings[[0]].destination;
    let tile = _Tiles[[tile_index]];
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCubeDescriptorLegal(tile);
    assert tile.layout == TileLayout_CUBE_M16 &&
        tile.location == TileLocation_Matrix;
    assert tile.valid_rows == 1 && tile.valid_columns == 32 &&
        tile.columns == 32;
    let first = TileLogicalLinearIndex(tile, 0, 0);
    let last = TileLogicalLinearIndex(tile, 0, 31);
    assert TileLogicalElementDefined(tile, first) &&
        TileReadLogicalElement(tile, first) == Zeros{PTO_XLEN} + 1;
    assert TileLogicalElementDefined(tile, last) &&
        TileReadLogicalElement(tile, last) == Zeros{PTO_XLEN} + 32;
    return 0;
end;
