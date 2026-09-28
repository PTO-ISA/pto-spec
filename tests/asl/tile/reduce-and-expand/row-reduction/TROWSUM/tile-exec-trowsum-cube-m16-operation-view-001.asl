// PTO-TEST: {"id":"PTO-AVS-TILE-TROWSUM-CUBE-M16-OPERATION-VIEW-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001","PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"CUBE_M16 TROWSUM interprets U16-backed cells as BF16 while retaining independent physical geometry.","pass_condition":"A 16x4, 3x2 U16 backing tile executes BF16 row sums into a 16x4 BF16 destination with Null padding and unchanged source bytes.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/shape/cube-cell.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/reduction.asl"]}
pure func TrowsumCubeOperationViewStart(data_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0xc2019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func ReductionLayoutDATR(layout: bits(5)) => bits(64)
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
        1, 128, 16, 4, 3, 2, TileDataType_U16,
        TileLayout_CUBE_M16, '1111');
    assert source_ready;
    assert TileCubeDescriptorLegal(_Tiles[[1]]);
    for row = 0 to 2 looplimit 3 do
        for column = 0 to 1 looplimit 2 do
            let value = if row == 0 then
                if column == 0 then 0x3f80 else 0x4000
            else if row == 1 then
                if column == 0 then 0x4040 else 0x4080
            else if column == 0 then 0x40a0 else 0x40c0;
            WriteTileElement(1, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN} + value);
        end;
    end;
    let source_before = _Tiles[[1]];
    let raw00 = ReadTileElement(1, 0, 0);
    let raw21 = ReadTileElement(1, 2, 1);

    let started = ExecuteCommandInstruction(
        TrowsumCubeOperationViewStart(TileDataType_BF16), 32);
    assert started == CommandExecution_Executed;
    let datr = ExecuteCommandInstruction(
        ReductionLayoutDATR(Zeros{5} + 31), 32);
    assert datr == CommandExecution_Executed;
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
    let attributes_legal = SelectedBundleTileDataAttributesLegal(operation);
    assert attributes_legal;
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_BF16;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].capacity_bytes == 128;
    assert _Tiles[[destination]].rows == 16;
    assert _Tiles[[destination]].columns == 4;
    assert _Tiles[[destination]].valid_rows == 3;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].cube_storage_bytes == 128;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4040;
    assert ReadTileElement(destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x40e0;
    assert ReadTileElement(destination, 2, 0) ==
        Zeros{PTO_XLEN} + 0x4130;
    assert !TileElementDefined(destination, 3, 0);
    assert _Tiles[[1]].data_type == TileDataType_U16;
    assert _Tiles[[1]].capacity_bytes == source_before.capacity_bytes;
    assert _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 4;
    assert _Tiles[[1]].valid_rows == 3 && _Tiles[[1]].valid_columns == 2;
    assert _Tiles[[1]].layout == TileLayout_CUBE_M16;
    assert ReadTileElement(1, 0, 0) == raw00;
    assert ReadTileElement(1, 2, 1) == raw21;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
