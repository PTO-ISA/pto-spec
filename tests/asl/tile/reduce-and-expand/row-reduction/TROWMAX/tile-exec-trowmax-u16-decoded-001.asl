// PTO-TEST: {"id":"PTO-AVS-TILE-TROWMAX-U16-DECODED-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWMAX.asl","requirements":["PTO-INST-TILE-TROWMAX"],"kind":"execution","summary":"decoded U16 TROWMAX executes through the normal reduction path","pass_condition":"the decoded U16 bundle completes and publishes the larger unsigned reduction value","related_sources":["asl/block/model/dispatch/tile-execution.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowmaxDecodedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00001';
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 9);

    let started = ExecuteCommandInstruction(TrowmaxDecodedStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x041)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U16;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 9;
    return 0;
end;
