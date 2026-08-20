// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-CAPACITY-008","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"fault","summary":"Local CUBE Matrix sources and destination require the smallest fitting per-PE TSize","pass_condition":"M16 M32 and N8 accept the smallest fitting size reject the next smaller size and destination failure publishes nothing","related_sources":["asl/block/model/dispatch/cube-destination.asl","asl/tile/model/shape/cube-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert ConfigureCubeTile(1, 1024, 16, 17,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix);
    assert !ConfigureCubeTile(2, 512, 16, 17,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix);
    assert ConfigureCubeTile(3, 2048, 17, 17,
        TileDataType_FP16, TileLayout_CUBE_M32,
        TileLocation_Matrix);
    assert !ConfigureCubeTile(4, 1024, 17, 17,
        TileDataType_FP16, TileLayout_CUBE_M32,
        TileLocation_Matrix);
    assert ConfigureCubeTile(5, 1024, 17, 9,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix);
    assert !ConfigureCubeTile(6, 512, 17, 9,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix);

    ResetProfileState();
    assert ConfigureCubeTileForMask(1, 1024, 16, 17,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert ConfigureCubeTileForMask(2, 1024, 17, 9,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    _Tiles[[1]].capacity_bytes = 512;
    var start: bits(64) = Zeros{64} + 0x00031181;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 9);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 17);
    AddBundleTileBinding(
        TRUE, 0, 4, '1111', TRUE, TRUE, 1, 2, TRUE);
    let malformed_source = ExecuteBundleTileOperation();
    assert !malformed_source;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ResetProfileState();
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', FALSE, FALSE, 0, 0, TRUE);
    let insufficient_destination = ResolveBundleTMATMULDestination(
        16, 9, TileDataType_FP32, TRUE, TileLayout_CUBE_M16);
    assert !insufficient_destination;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;

    ResetProfileState();
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 4, '1111', FALSE, FALSE, 0, 0, TRUE);
    let exact_destination = ResolveBundleTMATMULDestination(
        16, 9, TileDataType_FP32, TRUE, TileLayout_CUBE_M16);
    assert exact_destination;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == TileLayout_CUBE_M16;
    assert _Tiles[[destination]].capacity_bytes == 1024;
    return 0;
end;
