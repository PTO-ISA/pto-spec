// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLARGMAX-CUBE-M32-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLARGMAX.asl","requirements":["PTO-TCOLARGMAX-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001","PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"CUBE_M32 TCOLARGMAX interprets E8M0-backed bytes as U8 and allocates the larger U32 index footprint.","pass_condition":"A 32x4, 3x2 E8M0 backing tile returns U32 row indices into a 32x2 destination of at least 256 bytes while preserving the source descriptor and payload.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/shape/cube-cell.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TcolargmaxCubeOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '11100';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func TcolargmaxCubeDATR(layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[11:7] = layout;
    instruction[24:20] = Zeros{5} + 31;
    instruction[28:27] = '11';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTileForMaskWithPhysical(
        1, 128, 32, 4, 3, 2, TileDataType_E8M0,
        TileLayout_CUBE_M32, '1111');
    assert source_ready;
    assert TileCubeDescriptorLegal(_Tiles[[1]]);
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
        TcolargmaxCubeOperationViewStart(TileDataType_U8), 32);
    assert started == CommandExecution_Executed;
    let datr = ExecuteCommandInstruction(
        TcolargmaxCubeDATR(Zeros{5} + 29), 32);
    assert datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE, 0, 2, '1111', TRUE, FALSE, 1, 0, TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x05c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[destination]].capacity_bytes == 256;
    assert _Tiles[[destination]].rows == 32;
    assert _Tiles[[destination]].columns == 2;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].cube_storage_bytes == 256;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert !TileElementDefined(destination, 1, 0);
    assert _Tiles[[1]].data_type == TileDataType_E8M0;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == 32 && _Tiles[[1]].columns == 4;
    assert _Tiles[[1]].valid_rows == 3 && _Tiles[[1]].valid_columns == 2;
    assert _Tiles[[1]].layout == TileLayout_CUBE_M32;
    assert ReadTileElement(1, 0, 0) == raw00;
    assert ReadTileElement(1, 2, 1) == raw21;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
