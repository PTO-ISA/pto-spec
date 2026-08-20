// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-TMATMUL-CONTRACT-001"],"kind":"execution","summary":"TMATMUL accepts a Local A source and one fully published Shared B source.","pass_condition":"A U16 Local value and U8 Shared value produce one new Local U32 destination and consume the Shared source only after commit.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_U16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert left_ready;
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 7);
    InstallSharedTile(Zeros{8} + 9, _Tiles[[2]], '1111');
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5} + 27, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    BindBundleSharedIO(Zeros{8} + 9, 0, '1111');
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _BundleSharedBindings[[0]].consumed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 42;
    return 0;
end;
