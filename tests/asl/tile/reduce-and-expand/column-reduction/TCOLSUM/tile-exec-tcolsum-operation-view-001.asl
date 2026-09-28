// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLSUM-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl","requirements":["PTO-TCOLSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TCOLSUM interprets persistent BF16 source bits as U16 and preserves direct-call fallback.","pass_condition":"The U16 bundle sums raw BF16-backed values as U16 into a U16 destination without changing the source; an unbundled direct call falls back to the U16 backing type.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TcolsumOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '10000';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 4, 2, 1,
        TileDataType_BF16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x3f80);
    let source_before = _Tiles[[1]];
    let raw0 = ReadTileElement(1, 0, 0);
    let raw1 = ReadTileElement(1, 1, 0);

    let started = ExecuteCommandInstruction(
        TcolsumOperationViewStart(TileDataType_U16), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x050)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U16;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 1;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7f00;
    assert NumericStatusFlags() == Zeros{5};
    assert _Tiles[[1]].data_type == TileDataType_BF16;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert ReadTileElement(1, 0, 0) == raw0;
    assert ReadTileElement(1, 1, 0) == raw1;

    ResetProfileState();
    ConfigureTile(0, 128, 16, 4, 2, 1,
        TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(1, 128, 16, 4, 1, 1,
        TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xfffe);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 5);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Column, 1, 0);
    assert _LastFault == Fault_None;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
