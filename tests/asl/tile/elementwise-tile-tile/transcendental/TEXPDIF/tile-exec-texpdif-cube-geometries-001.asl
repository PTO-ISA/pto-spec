// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-CUBE-GEOMETRIES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"mixed TEXPDIF independently allocates FP32 geometry on CUBE_M16 and CUBE_M32","pass_condition":"FP16 CUBE_M16 16x4 and BF16 CUBE_M32 32x2 sources each occupy one cell; FP32 destinations retain their logical shape and use two cells, while a one-cell destination rejects before publication","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/shape/cube-cell.asl","asl/tile/model/execution/expdif.asl"]}
pure func TexdifCubeStart(source_type: TileDataType) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[24:20] = '11101';
    instruction[31:27] = TileDataTypeToEncoding(source_type);
    return instruction;
end;

pure func TexdifCubeDATR(data_type: bits(5), layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    instruction[11:7] = layout;
    instruction[28:27] = '00';
    return instruction;
end;

func RunTexdifCubeGeometry(
    source_type: TileDataType,
    layout: TileLayout,
    layout_code: bits(5),
    valid_rows: integer {16,32},
    valid_columns: integer {2,4},
    insufficient_capacity: boolean) => boolean
begin
    ResetProfileState();
    let source0_configured = ConfigureCubeTile(
        1, 128, valid_rows, valid_columns, source_type, layout);
    let source1_configured = ConfigureCubeTile(
        2, 128, valid_rows, valid_columns, source_type, layout);
    assert source0_configured && source1_configured;
    let one = if source_type == TileDataType_FP16 then
        Zeros{PTO_XLEN} + 0x3c00
    else
        Zeros{PTO_XLEN} + 0x3f80;
    for row = 0 to valid_rows - 1 looplimit 32 do
        for column = 0 to valid_columns - 1 looplimit 4 do
            WriteTileElement(1, row, column, one);
            WriteTileElement(2, row, column, Zeros{PTO_XLEN});
        end;
    end;
    let start_result = ExecuteCommandInstruction(
        TexdifCubeStart(source_type), 32);
    assert start_result == CommandExecution_Executed;
    let datr_result = ExecuteCommandInstruction(
        TexdifCubeDATR(
            TileDataTypeToEncoding(TileDataType_FP32), layout_code), 32);
    assert datr_result == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    SetBundleDimension(2, Zeros{PTO_XLEN} + valid_columns);
    AddBundleTileBinding(TRUE, 0,
        if insufficient_capacity then 1 else 2,
        '1111', TRUE, TRUE, 1, 2, TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL, '000000011101') as
            integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedBinarySchemaLegal(operation);
    assert SelectedBundleClosedSchemasLegal(operation);
    assert SelectedBundleTileMasksLegal();
    if insufficient_capacity then
        let before = NumericStatusFlags();
        let completed = ExecuteBundleTileOperation();
        assert !completed;
        assert _LastFault == Fault_TileAllocation;
        assert !_Tiles[[0]].allocated;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
        assert NumericStatusFlags() == before;
        return TRUE;
    end;

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.data_type == TileDataType_FP32;
    assert destination_tile.layout == layout;
    assert destination_tile.valid_rows == valid_rows;
    assert destination_tile.valid_columns == valid_columns;
    assert destination_tile.capacity_bytes == 256;
    assert destination_tile.cube_cell_count == 2;
    assert destination_tile.cube_storage_bytes ==
        TileCubePhysicalRequiredBytes(
            layout, destination_tile.rows, destination_tile.columns,
            TileDataType_FP32);
    let (expected, -) = TileExpdifValueWithTypesAndFlags(
        source_type, TileDataType_FP32, one, Zeros{PTO_XLEN});
    assert ReadTileElement(destination, 0, 0) == expected;
    assert ReadTileElement(
        destination, valid_rows - 1, valid_columns - 1) == expected;
    return TRUE;
end;

func main() => integer
begin
    let m16 = RunTexdifCubeGeometry(
        TileDataType_FP16, TileLayout_CUBE_M16, Zeros{5} + 31,
        16, 4, FALSE);
    let m32 = RunTexdifCubeGeometry(
        TileDataType_BF16, TileLayout_CUBE_M32, Zeros{5} + 29,
        32, 2, FALSE);
    let capacity_reject = RunTexdifCubeGeometry(
        TileDataType_FP16, TileLayout_CUBE_M16, Zeros{5} + 31,
        16, 4, TRUE);
    assert m16 && m32 && capacity_reject;
    return 0;
end;
