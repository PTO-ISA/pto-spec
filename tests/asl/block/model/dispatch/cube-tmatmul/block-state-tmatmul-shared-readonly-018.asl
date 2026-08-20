// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-READONLY-018","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"state-transition","summary":"Successful cooperative Matrix reads leave persistent Shared state unchanged","pass_condition":"descriptor masks publication payload and initialized state are identical after both Shared bindings are consumed","related_sources":["asl/tile/model/state/shared-registers.asl"]}
func PrepareReadonlyShared(index: TileIndex, shared_id: bits(8),
                           value: integer)
begin
    ConfigureTileForMask(index, 128, 64, 1, 1, 1,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    WriteTileElement(index, 0, 0, Zeros{PTO_XLEN} + value);
    InstallSharedTile(shared_id, _Tiles[[index]], '1111');
end;

func main() => integer
begin
    ResetProfileState();
    PrepareReadonlyShared(10, Zeros{8} + 60, 2);
    PrepareReadonlyShared(11, Zeros{8} + 61, 3);
    let left_before = SharedTileRecord(Zeros{8} + 60);
    let right_before = SharedTileRecord(Zeros{8} + 61);

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    BindBundleSharedIO(Zeros{8} + 60, 0, '1111');
    BindBundleSharedIO(Zeros{8} + 61, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _BundleSharedBindings[[0]].consumed;
    assert _BundleSharedBindings[[1]].consumed;
    let left_after = SharedTileRecord(Zeros{8} + 60);
    let right_after = SharedTileRecord(Zeros{8} + 61);
    assert left_after.descriptor_valid == left_before.descriptor_valid;
    assert left_after.allocation_mask == left_before.allocation_mask;
    assert left_after.initialized_mask == left_before.initialized_mask;
    assert left_after.published == left_before.published;
    assert left_after.tile.payload[[0]] == left_before.tile.payload[[0]];
    assert right_after.descriptor_valid == right_before.descriptor_valid;
    assert right_after.allocation_mask == right_before.allocation_mask;
    assert right_after.initialized_mask == right_before.initialized_mask;
    assert right_after.published == right_before.published;
    assert right_after.tile.payload[[0]] == right_before.tile.payload[[0]];
    return 0;
end;
