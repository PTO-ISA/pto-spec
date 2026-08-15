// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-PAIR-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"TMATMUL accepts complete Shared left and right operand groups","pass_condition":"both Shared sources are consumed only after a new Local U32 result is published","related_sources":["asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(10, 128, 1, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(11, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 5);
    InstallSharedTile(Zeros{8} + 40, _Tiles[[10]], '1111');
    InstallSharedTile(Zeros{8} + 41, _Tiles[[11]], '1111');
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let start_result = ExecuteCommandInstruction(start, 32);
    assert start_result == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    BindBundleSharedIO(Zeros{8} + 40, 0, '1111');
    BindBundleSharedIO(Zeros{8} + 41, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert _BundleSharedBindings[[1]].consumed;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 20;
    return 0;
end;
