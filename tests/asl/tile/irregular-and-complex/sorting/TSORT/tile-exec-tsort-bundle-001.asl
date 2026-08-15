// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-BUNDLE-001","source":"asl/tile/irregular-and-complex/sorting/TSORT.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"execution","summary":"TSORT uses LB0 only as sort width while destination shapes follow the source","pass_condition":"a four-column source sorts in width-three groups and publishes matching value and U32 index destinations","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-execution.asl"]}

pure func TSORTBundleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01100';
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        32,
        128,
        8,
        4,
        1,
        4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(32, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(32, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(32, 0, 3, Zeros{PTO_XLEN});

    let started = ExecuteCommandInstruction(TSORTBundleStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '0001',
        TRUE,
        FALSE,
        32,
        0,
        FALSE);
    AddBundleTileBinding(
        TRUE,
        1,
        1,
        '0001',
        FALSE,
        FALSE,
        0,
        0,
        TRUE);

    let stopped = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert stopped == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN};
    assert ReadTileElement(16, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(16, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(16, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(16, 0, 3) == Zeros{PTO_XLEN};
    return 0;
end;
