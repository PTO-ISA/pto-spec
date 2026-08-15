// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-BIAS-SHARED-001","source":"asl/block/execution/BSTART.TMATMUL.BIAS.asl","requirements":["PTO-TMATMUL-BIAS-CONTRACT-001"],"kind":"execution","summary":"TMATMUL.BIAS keeps Bias Local when B is Shared.","pass_condition":"Local A and Bias plus one published Shared B produce one Local destination; only the Shared matrix binding is consumed.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 8, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(3, 128, 4, 8, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 5);
    InstallSharedTile(Zeros{8} + 10, _Tiles[[2]], '1111');
    var start: bits(64) = Zeros{64} + 0x00131181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5} + 27, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    BindBundleSharedIO(Zeros{8} + 10, 0, '1111');
    AddBundleTileBinding(FALSE, 0, 0, '1111', TRUE, FALSE, 1, 0, FALSE);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _BundleSharedBindings[[0]].consumed;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 47;
    return 0;
end;
