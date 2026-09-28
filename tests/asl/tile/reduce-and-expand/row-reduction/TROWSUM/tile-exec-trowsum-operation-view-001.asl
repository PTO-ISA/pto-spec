// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TROWSUM interprets persistent U16 source bits as BF16 and allocates a BF16 result.","pass_condition":"The decoded BF16 fold accepts U16 backing, publishes exact BF16 sums and status, and preserves the U16 source descriptor and payload.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowsumOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 4, 3, 2,
        TileDataType_U16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    WriteTileElement(1, 2, 0, Zeros{PTO_XLEN} + 0x40a0);
    WriteTileElement(1, 2, 1, Zeros{PTO_XLEN} + 0x40c0);
    let source_before = _Tiles[[1]];
    let raw_row0 = ReadTileElement(1, 0, 0);
    let raw_row1 = ReadTileElement(1, 1, 1);
    assert _Tiles[[1]].contents_defined;

    let started = ExecuteCommandInstruction(
        TrowsumOperationViewStart(TileDataType_BF16), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;

    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].valid_rows == 3;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].columns == 1;
    assert _Tiles[[destination]].rows ==
        DerivedTileRows(_Tiles[[destination]].capacity_bytes, 1,
            TileDataType_BF16);
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4040;
    assert ReadTileElement(destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x40e0;
    assert ReadTileElement(destination, 2, 0) ==
        Zeros{PTO_XLEN} + 0x4130;
    assert !TileElementDefined(destination, 3, 0);
    assert NumericStatusFlags() == Zeros{5};
    assert _Tiles[[1]].data_type == source_before.data_type;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == source_before.rows;
    assert _Tiles[[1]].columns == source_before.columns;
    assert _Tiles[[1]].valid_rows == source_before.valid_rows;
    assert _Tiles[[1]].valid_columns == source_before.valid_columns;
    assert _Tiles[[1]].layout == source_before.layout;
    assert _Tiles[[1]].contents_defined == source_before.contents_defined;
    assert ReadTileElement(1, 0, 0) == raw_row0;
    assert ReadTileElement(1, 1, 1) == raw_row1;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(1, 1, 0) == Zeros{PTO_XLEN} + 0x4040;
    assert ReadTileElement(1, 2, 0) == Zeros{PTO_XLEN} + 0x40a0;
    assert ReadTileElement(1, 2, 1) == Zeros{PTO_XLEN} + 0x40c0;
    return 0;
end;
