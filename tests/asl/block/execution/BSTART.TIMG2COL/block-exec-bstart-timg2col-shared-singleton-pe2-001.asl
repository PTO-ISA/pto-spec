// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TIMG2COL-SHARED-SINGLETON-PE2-001","source":"asl/block/execution/BSTART.TIMG2COL.asl","requirements":["PTO-INST-BLOCK-BSTART-TIMG2COL","PTO-BSTART-TIMG2COL-COOPERATIVE-001","PTO-BSTART-TIMG2COL-CROP-001"],"kind":"execution","summary":"A Shared singleton issued by PE2 uses the encoded crop RowStart without a cooperative prefix.","pass_condition":"The decoded PE2-only destination publishes the complete one-row parent from source RowStart one and writes it at Shared destination row zero without B.ASSEMBLE.","related_sources":["asl/block/model/dispatch/timg2col-execution.asl","asl/block/model/dispatch/timg2col-schema.asl"]}
pure func TIMG2COLSingletonStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x01c11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func TIMG2COLSingletonIOR(
    source0: integer, source1: integer, source2: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + source0;
    instruction[24:20] = Zeros{5} + source1;
    instruction[31:27] = Zeros{5} + source2;
    return instruction;
end;

pure func TIMG2COLSingletonSharedDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 8;
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '011';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    _CurrentMemoryAgent = 2;
    for element = 0 to 31 do
        Store(Zeros{PTO_XLEN} + 32 + element, 1,
            Zeros{PTO_XLEN} + 0x40 + element);
    end;
    WritePEGPR(2, 2, Zeros{PTO_XLEN});
    WritePEGPR(2, 3, Zeros{64} + 2 + (1 << 16) + (32 << 32) +
        (1 << 48) + (1 << 56));
    WritePEGPR(2, 4, Zeros{64} + (1 << 32) + (1 << 37) +
        (1 << 42) + (1 << 48));
    WritePEGPR(2, 5, Zeros{PTO_XLEN} + 1);
    let start = ExecuteCommandInstruction(TIMG2COLSingletonStart(), 32);
    assert start == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    let gm = ExecuteCommandInstruction(TIMG2COLSingletonIOR(2, 0, 0), 32);
    let parameters = ExecuteCommandInstruction(
        TIMG2COLSingletonIOR(3, 4, 5), 32);
    let destination = ExecuteCommandInstruction(
        TIMG2COLSingletonSharedDestination(), 32);
    assert gm == CommandExecution_Executed &&
        parameters == CommandExecution_Executed &&
        destination == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let shared_id = (Zeros{6} + 8) as SharedTileID;
    assert SharedTilePublished(shared_id);
    let shared = SharedTileRecord(shared_id);
    assert shared.allocation_mask == '0010';
    assert shared.tile.valid_rows == 1 && shared.tile.valid_columns == 32;
    let first = TileLogicalLinearIndex(shared.tile, 0, 0);
    assert TileLogicalElementDefined(shared.tile, first);
    assert TileReadLogicalElement(shared.tile, first) ==
        Zeros{PTO_XLEN} + 0x40;
    return 0;
end;
