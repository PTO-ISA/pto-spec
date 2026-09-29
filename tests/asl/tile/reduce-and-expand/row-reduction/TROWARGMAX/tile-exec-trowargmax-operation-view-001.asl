// PTO-TEST: {"id":"PTO-AVS-TILE-TROWARGMAX-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMAX.asl","requirements":["PTO-TROWARGMAX-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TROWARGMAX interprets S32-backed bits as FP32 and returns the lowest equal maximum index.","pass_condition":"FP32 values stored in an S32 descriptor select U32 index one on a tie, with the source descriptor and raw payload unchanged.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowargmaxOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '01100';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 4, 1, 3,
        TileDataType_S32, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x40000000);
    let source_before = _Tiles[[1]];
    let raw0 = ReadTileElement(1, 0, 0);
    let raw1 = ReadTileElement(1, 0, 1);
    let raw2 = ReadTileElement(1, 0, 2);

    let started = ExecuteCommandInstruction(
        TrowargmaxOperationViewStart(TileDataType_FP32), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x04c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert _Tiles[[1]].data_type == TileDataType_S32;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert ReadTileElement(1, 0, 0) == raw0;
    assert ReadTileElement(1, 0, 1) == raw1;
    assert ReadTileElement(1, 0, 2) == raw2;
    return 0;
end;
