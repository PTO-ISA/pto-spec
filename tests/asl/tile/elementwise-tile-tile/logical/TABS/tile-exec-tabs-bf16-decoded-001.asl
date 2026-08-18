// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-BF16-DECODED-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001"],"kind":"execution","summary":"decoded BF16 TABS executes through the normal bundle path","pass_condition":"the decoded BF16 bundle completes and publishes the positive absolute-value encoding","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/unary.asl"]}
pure func TabsDecodedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '00';
    instruction[24:20] = '01111';
    instruction[31:27] = Zeros{5} + 5;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_BF16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xbf80);

    let started = ExecuteCommandInstruction(TabsDecodedStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x00f)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedUnarySchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f80;
    return 0;
end;
