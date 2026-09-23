// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOS-LAST-USE-VTAG-RETAINED-004","source":"asl/block/operands/B.IOS.asl","requirements":["PTO-B-IOS-SHARED-STATE-001","PTO-ARCH-SHARED-VTAG-LIFETIME-001"],"kind":"state-transition","summary":"B.IOS last-use frees complete Core-wide Shared payload capacity while retaining Sx identity and descriptor.","pass_condition":"A rejected attempt preserves payload, a successful SUBVIEW-marked last-use clears whole-parent payload-live state and capacity, and a later source of the same Sx faults without reallocating.","related_sources":["asl/block/model/operands/shared-bindings.asl","asl/tile/model/capacity/shared.asl","asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    let shared_id = (Zeros{6} + 7) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    assert SharedTileRecord(shared_id).descriptor_valid;
    assert SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 128;

    BindBundleSharedIOWithReuse(shared_id, 0, '1111', FALSE);
    assert _BundleSharedBindings[[0]].valid;
    assert !_BundleSharedBindings[[0]].source_reuse;
    _BundleSharedBindings[[0]].source0_subview.valid = TRUE;
    _BundleSharedBindings[[0]].source0_subview.size_code = 1;
    FinalizeBundleTileAttempt(TileExecution_Rejected);
    assert SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 128;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert SharedTileRecord(shared_id).descriptor_valid;
    assert SharedTileRecord(shared_id).allocation_mask == '1111';
    assert !SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 0;

    ClearBundleHeaderState();
    ClearFault();
    BindBundleSharedIO(shared_id, 0, '1111');
    assert _BundleSharedBindings[[0]].source_reuse;
    let available = RequireBundleSharedSourcePayloads();
    assert !available;
    assert _LastFault == Fault_TileLegality;
    assert SharedTileRecord(shared_id).descriptor_valid;
    assert SharedTileCapacityInUse() == 0;

    // A consumed descriptor keeps its Sx identity but a later same-size
    // destination must reacquire capacity. Fill the released pool first.
    var full_parent = _Tiles[[0]];
    full_parent.capacity_bytes = 262144;
    full_parent.rows = 32768;
    full_parent.columns = 1;
    let other_id = (Zeros{6} + 8) as SharedTileID;
    let filled = AtomicUpdateSharedTile(other_id, full_parent, '1111');
    assert filled;
    assert SharedTileCapacityInUse() == 262144;
    let denied = AtomicUpdateSharedTile(shared_id, _Tiles[[0]], '1111');
    assert !denied;
    assert SharedTileRecord(shared_id).descriptor_valid;
    assert !SharedTileRecord(shared_id).payload_live;
    assert SharedTileRecord(other_id).payload_live;
    assert SharedTileCapacityInUse() == 262144;

    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x66);
    InstallSharedTile(shared_id, _Tiles[[0]], '1111');
    BindBundleSharedIOWithReuse(shared_id, 0, '1111', TRUE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert SharedTileRecord(shared_id).payload_live;
    assert SharedTileCapacityInUse() == 128;
    return 0;
end;
