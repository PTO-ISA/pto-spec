// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMULMX-BIAS-EXEC-001","source":"asl/block/execution/BSTART.TMATMULMX.BIAS.asl","requirements":["PTO-B-DATR-MATRIX-ACC-CONTROL-001","PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001","PTO-CUBE-INTERNAL-ACCUMULATOR-001","PTO-CUBE-MATRIX-SCALE-001","PTO-INST-BLOCK-BSTART-TMATMULMX-BIAS"],"kind":"execution","summary":"TMATMULMX.BIAS CCTRL=01 preserves non-identity MX scaling and Bias in raw partial D while supplying a transparent-cache replacement hint.","pass_condition":"32 E4M3 products with left scale two, right scale three, and Bias five always publish one raw FP32 destination containing 1157.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/cube.asl","asl/tile/model/execution/internal-accumulator.asl","asl/tile/model/execution/matrix-scale.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 512, 1, 32,
        TileDataType_E4M3, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let a_scale_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(3, 512, 32, 1,
        TileDataType_E4M3, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let b_scale_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert a_ready && a_scale_ready && b_ready && b_scale_ready;
    ConfigureTile(5, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    for inner = 0 to 31 looplimit 32 do
        WriteTileElement(1, 0, inner, Zeros{PTO_XLEN} + 2);
        WriteTileElement(3, inner, 0, Zeros{PTO_XLEN} + 3);
    end;
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(4);

    var start: bits(64) = Zeros{64} + 0x00531181;
    start[31:27] = Zeros{5} + 7;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(
        Zeros{5} + 7, Zeros{5}, '01', Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 3, 4, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 5, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 1157;
    return 0;
end;
