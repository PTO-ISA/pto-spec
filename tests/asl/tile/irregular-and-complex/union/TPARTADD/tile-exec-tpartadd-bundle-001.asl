// PTO-TEST: {"id":"PTO-AVS-TILE-TPARTADD-BUNDLE-001","source":"asl/tile/irregular-and-complex/union/TPARTADD.asl","requirements":["PTO-INST-TILE-TPARTADD"],"kind":"execution","summary":"TPARTADD closes its complete Local bundle schema and derives the destination from B.DIM","pass_condition":"an S16 overlap is added and the source-only tail is copied through decoded BSTART and BSTOP","related_sources":["asl/block/model/dispatch/partial-schema.asl","asl/block/model/dispatch/tile-execution.asl"]}

pure func TPARTADDBundleStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '10001';
    instruction[31:27] = Zeros{5} + 18;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(32, 128, 16, 4, 1, 3, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(33, 128, 32, 2, 1, 2, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(32, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(32, 0, 2, Zeros{PTO_XLEN} + 7);
    WriteTileElement(33, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(33, 0, 1, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(TPARTADDBundleStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '0001', TRUE, TRUE, 32, 33, TRUE);
    let stopped = ExecuteCommandInstruction(Zeros{64} + 1, 32);

    assert stopped == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
