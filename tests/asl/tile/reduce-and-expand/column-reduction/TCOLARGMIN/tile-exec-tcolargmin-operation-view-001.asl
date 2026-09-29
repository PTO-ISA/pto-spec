// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLARGMIN-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl","requirements":["PTO-TCOLARGMIN-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TCOLARGMIN interprets E8M0- and E6M2-backed bytes as U8 and returns U32 row indices.","pass_condition":"The U8 view accepts operation-valid bytes that are invalid under E8M0, selects the lowest unsigned minimum row per column, publishes U32 results without numeric status, and preserves each source descriptor and payload.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TcolargminOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '11101';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func TcolargminOperationViewBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
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
    let raw01 = ReadTileElement(1, 0, 1);
    let raw10 = ReadTileElement(1, 1, 0);
    let raw11 = ReadTileElement(1, 1, 1);
    let raw20 = ReadTileElement(1, 2, 0);
    let raw21 = ReadTileElement(1, 2, 1);

    let started = ExecuteCommandInstruction(
        TcolargminOperationViewStart(TileDataType_U8), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(
        TcolargminOperationViewBinding(), 32);
    assert bound == CommandExecution_Executed;
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
    assert NumericStatusFlags() == Zeros{5};
    assert _Tiles[[1]].data_type == TileDataType_E8M0;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert ReadTileElement(1, 0, 0) == raw00;
    assert ReadTileElement(1, 0, 1) == raw01;
    assert ReadTileElement(1, 1, 0) == raw10;
    assert ReadTileElement(1, 1, 1) == raw11;
    assert ReadTileElement(1, 2, 0) == raw20;
    assert ReadTileElement(1, 2, 1) == raw21;

    // E6M2 byte 0xff is a quiet NaN for its backing tag, but is the valid U8
    // value 255 under the operation view. Other bytes retain U8 ordering.
    ResetProfileState();
    ConfigureTile(1, 128, 32, 4, 2, 2,
        TileDataType_E6M2, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xff);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x20);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x07);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0xff);
    let e6m2_source_before = _Tiles[[1]];
    let e6m2_raw00 = ReadTileElement(1, 0, 0);
    let e6m2_raw10 = ReadTileElement(1, 1, 0);
    let e6m2_raw01 = ReadTileElement(1, 0, 1);
    let e6m2_raw11 = ReadTileElement(1, 1, 1);
    let e6m2_started = ExecuteCommandInstruction(
        TcolargminOperationViewStart(TileDataType_U8), 32);
    assert e6m2_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let e6m2_bound = ExecuteCommandInstruction(
        TcolargminOperationViewBinding(), 32);
    assert e6m2_bound == CommandExecution_Executed;
    let e6m2_completed = ExecuteBundleTileOperation();
    assert e6m2_completed;
    assert _LastFault == Fault_None;
    let e6m2_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[e6m2_destination]].capacity_bytes == 128;
    assert _Tiles[[e6m2_destination]].data_type == TileDataType_U32;
    assert _Tiles[[e6m2_destination]].columns == 4;
    assert _Tiles[[e6m2_destination]].rows == 8;
    assert _Tiles[[e6m2_destination]].valid_rows == 1;
    assert _Tiles[[e6m2_destination]].valid_columns == 2;
    assert ReadTileElement(e6m2_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(e6m2_destination, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == Zeros{5};
    assert _Tiles[[1]].allocated == e6m2_source_before.allocated;
    assert _Tiles[[1]].data_type == TileDataType_E6M2;
    assert _Tiles[[1]].capacity_bytes == e6m2_source_before.capacity_bytes;
    assert _Tiles[[1]].rows == e6m2_source_before.rows;
    assert _Tiles[[1]].columns == e6m2_source_before.columns;
    assert _Tiles[[1]].valid_rows == e6m2_source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == e6m2_source_before.valid_columns;
    assert _Tiles[[1]].layout == e6m2_source_before.layout;
    assert _Tiles[[1]].contents_defined ==
        e6m2_source_before.contents_defined;
    assert ReadTileElement(1, 0, 0) == e6m2_raw00;
    assert ReadTileElement(1, 1, 0) == e6m2_raw10;
    assert ReadTileElement(1, 0, 1) == e6m2_raw01;
    assert ReadTileElement(1, 1, 1) == e6m2_raw11;
    return 0;
end;
