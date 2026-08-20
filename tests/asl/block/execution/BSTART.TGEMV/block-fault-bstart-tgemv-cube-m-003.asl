// PTO-TEST: {"id":"PTO-AVS-BLOCK-TGEMV-CUBE-M-003","source":"asl/block/execution/BSTART.TGEMV.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"fault","summary":"TGEMV remains the M one specialization of Local CUBE Matrix execution","pass_condition":"explicit M two raises Tile legality before destination allocation or source and numeric-status effects","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x01031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();

    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;
    assert NumericStatusFlags() == status_before;
    return 0;
end;
