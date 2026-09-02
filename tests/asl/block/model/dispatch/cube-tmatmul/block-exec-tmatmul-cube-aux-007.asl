// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-AUX-007","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"execution","summary":"Local CUBE TMATMUL keeps Bias in an ordinary row-major auxiliary Tile","pass_condition":"ordinary FP32 Bias adds to CUBE A and B while a CUBE-form Bias rejects before destination allocation","related_sources":["asl/tile/model/legality/matrix-operands.asl","asl/tile/model/execution/cube.asl"]}
func PrepareCubeBiasPrimaries()
begin
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    let a_element = TileStorageIndex(_Tiles[[1]], 0, 0);
    let b_element = TileStorageIndex(_Tiles[[2]], 0, 0);
    _Tiles[[1]].payload[[a_element]] = Zeros{PTO_XLEN} + 0x4000;
    _Tiles[[2]].payload[[b_element]] = Zeros{PTO_XLEN} + 0x4200;
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
end;

func StartCubeBiasBlock()
begin
    var start: bits(64) = Zeros{64} + 0x00131181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
end;

func main() => integer
begin
    ResetProfileState();
    PrepareCubeBiasPrimaries();
    ConfigureTileForMask(3, 128, 32, 1, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor,
        TileLocation_Any, '1111');
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
    StartCubeBiasBlock();
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    let d = _Tiles[[destination]];
    assert d.layout == TileLayout_CUBE_M16;
    assert d.payload[[TileStorageIndex(d, 0, 0)]] ==
        Zeros{PTO_XLEN} + 0x41300000;

    ResetProfileState();
    PrepareCubeBiasPrimaries();
    let cube_bias = ConfigureCubeTileForMask(3, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert cube_bias;
    MarkTileValidRegionDefined(3);
    StartCubeBiasBlock();
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    return 0;
end;
