// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-DESTINATION-005","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"state-transition","summary":"Decoded Local TMATMUL allocates D in A's persistent M layout","pass_condition":"M16 A and N8 B publish a new FP32 M16 Matrix destination with exact CUBE geometry valid shape payload and allocation mask","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/execution/cube.asl"]}
func WriteMatrixCubeValue(index: TileIndex,
                          row: integer {0..65535},
                          column: integer {0..65535},
                          value: integer)
begin
    let element = TileStorageIndex(_Tiles[[index]], row, column);
    _Tiles[[index]].payload[[element]] = Zeros{PTO_XLEN} + value;
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 3,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 3, 2,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WriteMatrixCubeValue(1, 0, 0, 1);
    WriteMatrixCubeValue(1, 0, 1, 2);
    WriteMatrixCubeValue(1, 0, 2, 3);
    WriteMatrixCubeValue(1, 1, 0, 4);
    WriteMatrixCubeValue(1, 1, 1, 5);
    WriteMatrixCubeValue(1, 1, 2, 6);
    WriteMatrixCubeValue(2, 0, 0, 1);
    WriteMatrixCubeValue(2, 0, 1, 2);
    WriteMatrixCubeValue(2, 1, 0, 3);
    WriteMatrixCubeValue(2, 1, 1, 4);
    WriteMatrixCubeValue(2, 2, 0, 5);
    WriteMatrixCubeValue(2, 2, 1, 6);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();

    assert completed;
    assert _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    let d = _Tiles[[destination]];
    assert d.layout == TileLayout_CUBE_M16;
    assert d.location == TileLocation_Matrix;
    assert d.data_type == TileDataType_FP32;
    assert d.valid_rows == 2 && d.valid_columns == 2;
    assert d.rows == 16 && d.columns == 2;
    assert d.cube_cell_count == 1 && d.cube_storage_bytes == 128;
    assert _TileAllocationMasks[[destination]] == '1111';
    assert d.payload[[TileStorageIndex(d, 0, 0)]] ==
        Zeros{PTO_XLEN} + 22;
    assert d.payload[[TileStorageIndex(d, 1, 1)]] ==
        Zeros{PTO_XLEN} + 64;
    return 0;
end;
