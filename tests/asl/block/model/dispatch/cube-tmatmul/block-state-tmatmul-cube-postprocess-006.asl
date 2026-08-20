// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-POSTPROCESS-006","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"state-transition","summary":"CUBE D uses final B.FPATR output dtype geometry while arithmetic remains accumulator typed","pass_condition":"FP32 accumulation converted to FP16 publishes one 128-byte M16 cell without indexing the payload as an invalid FP32 descriptor","related_sources":["asl/tile/model/execution/cube.asl","asl/tile/model/execution/postprocess.asl","asl/block/model/dispatch/cube-destination.asl"]}
func WritePostProcessCubeValue(index: TileIndex,
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
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 2,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 2, 3,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WritePostProcessCubeValue(1, 0, 0, 1);
    WritePostProcessCubeValue(1, 0, 1, 2);
    WritePostProcessCubeValue(1, 1, 0, 3);
    WritePostProcessCubeValue(1, 1, 1, 4);
    WritePostProcessCubeValue(2, 0, 0, 1);
    WritePostProcessCubeValue(2, 0, 1, 2);
    WritePostProcessCubeValue(2, 0, 2, 3);
    WritePostProcessCubeValue(2, 1, 0, 4);
    WritePostProcessCubeValue(2, 1, 1, 5);
    WritePostProcessCubeValue(2, 1, 2, 6);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6} + 1, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();

    assert _LastFault == Fault_None;
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    let d = _Tiles[[destination]];
    assert d.data_type == TileDataType_FP16;
    assert d.layout == TileLayout_CUBE_M16;
    assert d.rows == 16 && d.columns == 4;
    assert d.valid_rows == 2 && d.valid_columns == 3;
    assert d.cube_cell_count == 1 && d.cube_storage_bytes == 128;
    assert d.contents_defined && d.defined_valid_elements == 6;
    return 0;
end;
