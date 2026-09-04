// PTO-TEST: {"id":"PTO-AVS-BLOCK-SOURCE-BACKING-DEST-001","source":"asl/block/model/dispatch/destination-shape.asl","requirements":["PTO-TMOV-CONTRACT-001"],"kind":"boundary","summary":"Source-carrier layout operations allocate the destination with the source backing DataType","pass_condition":"TMOV selected with a U16 carrier over BF16-backed sources each allocate a BF16-backed destination and pass carrier-width legality","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/memory-schema.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
pure func SourceBackingTMOVStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func SourceBackingLayoutStart(function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = function;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func AssertTMOVSourceBackingDestination()
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 16, 4, 1, 2, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);

    let started = ExecuteCommandInstruction(SourceBackingTMOVStart(), 32);
    assert started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let operation = 83 as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let resolved = ResolveBundleTileDestinationsForOperation(operation);
    assert resolved;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].rows == _Tiles[[1]].rows;
    assert _Tiles[[destination]].columns == _Tiles[[1]].columns;
    assert TileOperandsLegal_TMOV(destination, 1);
end;

func main() => integer
begin
    AssertTMOVSourceBackingDestination();
    return 0;
end;
