// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLARGMIN-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl","requirements":["PTO-TCOLARGMIN-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TCOLARGMIN interprets E8M0-backed bytes as U8 and returns U32 row indices.","pass_condition":"The U8 view accepts byte 0xff despite its E8M0 interpretation, selects the lowest unsigned minimum row per column, and preserves source backing and payload.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TcolargminOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '11101';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 32, 4, 3, 2,
        TileDataType_E8M0, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x20);
    WriteTileElement(1, 2, 0, Zeros{PTO_XLEN} + 0x30);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x10);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x40);
    WriteTileElement(1, 2, 1, Zeros{PTO_XLEN} + 0x40);
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw21 = ReadTileElement(1, 2, 1);

    let started = ExecuteCommandInstruction(
        TcolargminOperationViewStart(TileDataType_U8), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x05d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].capacity_bytes == 128;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    assert _Tiles[[1]].data_type == TileDataType_E8M0;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert ReadTileElement(1, 0, 0) == raw00;
    assert ReadTileElement(1, 2, 1) == raw21;
    return 0;
end;
