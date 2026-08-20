// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-BIAS-EXEC-001","source":"asl/block/execution/BSTART.TMATMUL.BIAS.asl","requirements":["PTO-BSTART-TMATMUL-BIAS-CONTRACT-001","PTO-TMATMUL-BIAS-CONTRACT-001","PTO-INST-BLOCK-BSTART-TMATMUL-BIAS"],"kind":"execution","summary":"TMATMUL.BIAS adds one 1xN private-result Bias after each dot product.","pass_condition":"A mixed S16 by S8 2x2 product adds one S32 1x2 Bias across both result rows and commits one new S32 destination.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/cube.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 2,
        TileDataType_S16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 2, 2,
        TileDataType_S8, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    ConfigureTile(3, 128, 4, 8, 1, 2, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 20);
    var start: bits(64) = Zeros{64} + 0x00131181;
    start[31:27] = Zeros{5} + 18;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5} + 19, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[1]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_S32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 29;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 42;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 53;
    assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN} + 70;
    return 0;
end;
