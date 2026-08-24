// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMULMX-HIF4-002","source":"asl/block/execution/BSTART.TMATMULMX.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-CUBE-HIF4-SCALE-001"],"kind":"execution","summary":"Decoded TMATMULMX accepts packed HiF4X2 sides with mandatory U32 group-64 scales.","pass_condition":"Two 1x1 packed HiF4X2 primaries and their Local CUBE_M32 U32 scale words execute through the Matrix-MX path and publish FP32 output.","related_sources":["asl/tile/model/legality/matrix-functions.asl","asl/tile/model/execution/matrix-scale.asl"]}

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_HiF4X2, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let a_scale_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_HiF4X2, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let b_scale_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_U32, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert a_ready && a_scale_ready && b_ready && b_scale_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(4);

    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 14;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 14, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 3, 4, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 6;
    return 0;
end;
