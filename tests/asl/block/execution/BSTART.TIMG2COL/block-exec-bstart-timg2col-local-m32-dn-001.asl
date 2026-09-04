// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-LOCAL-M32-DN-001","source":"asl/block/execution/BSTART.TIMG2COL.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-BSTART-TIMG2COL-CONTRACT-001","PTO-BSTART-TIMG2COL-CROP-001"],"kind":"execution","summary":"Decoded DN-source TIMG2COL publishes a canonical Local CUBE_M32 fragment.","pass_condition":"The Function-28 path uses DN channel-major GM indexing for 17 rows and publishes the complete legal CUBE_M32 descriptor and endpoint payload values.","related_sources":["asl/block/model/dispatch/timg2col-execution.asl","asl/block/model/memory/timg2col-gm.asl"]}
pure func TIMG2COLM32Start() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TIMG2COLM32DATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

pure func TIMG2COLM32IOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func TIMG2COLM32Destination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = '0100';
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    Store(Zeros{PTO_XLEN}, 1, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 543, 1, Zeros{PTO_XLEN} + 0x22);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        WritePEGPR(agent, 2, Zeros{PTO_XLEN});
        WritePEGPR(agent, 3, Zeros{64} + 17 + (1 << 16) + (32 << 32) +
            (1 << 48) + (1 << 56));
        WritePEGPR(agent, 4, Zeros{64} + (1 << 32) + (1 << 37) +
            (1 << 42) + (1 << 48));
        WritePEGPR(agent, 5, Zeros{PTO_XLEN});
    end;
    let start = ExecuteCommandInstruction(TIMG2COLM32Start(), 32);
    let datr = ExecuteCommandInstruction(TIMG2COLM32DATR(), 32);
    assert start == CommandExecution_Executed && datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    let gm = ExecuteCommandInstruction(TIMG2COLM32IOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(TIMG2COLM32IOR(3, 4, 5), 32);
    let destination = ExecuteCommandInstruction(TIMG2COLM32Destination(), 32);
    assert gm == CommandExecution_Executed &&
        parameters == CommandExecution_Executed &&
        destination == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let tile = _Tiles[[_BundleTileBindings[[0]].destination]];
    assert TileCubeDescriptorLegal(tile);
    assert tile.layout == TileLayout_CUBE_M32 &&
        tile.location == TileLocation_Matrix;
    assert tile.valid_rows == 17 && tile.valid_columns == 32;
    let first = TileLogicalLinearIndex(tile, 0, 0);
    let last = TileLogicalLinearIndex(tile, 16, 31);
    assert TileReadLogicalElement(tile, first) == Zeros{PTO_XLEN} + 0x11;
    assert TileReadLogicalElement(tile, last) == Zeros{PTO_XLEN} + 0x22;
    return 0;
end;
