// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-BUNDLE-001","source":"asl/tile/irregular-and-complex/sorting/TMRGSORT.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"execution","summary":"TMRGSORT derives its destination width from both sorted source streams","pass_condition":"two two-column FP32 sources merge into one four-column destination without B.DIM","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-execution.asl"]}

pure func TMRGSORTBundleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '01101';
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        32,
        128,
        16,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        33,
        128,
        16,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(32, 0, 1, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(33, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(33, 0, 1, Zeros{PTO_XLEN} + 0x40800000);

    let started = ExecuteCommandInstruction(TMRGSORTBundleStart(), 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '0001',
        TRUE,
        TRUE,
        32,
        33,
        TRUE);

    let stopped = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert stopped == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _Tiles[[0]].valid_rows == 1;
    assert _Tiles[[0]].valid_columns == 4;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 0x40400000;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0x40800000;
    return 0;
end;
