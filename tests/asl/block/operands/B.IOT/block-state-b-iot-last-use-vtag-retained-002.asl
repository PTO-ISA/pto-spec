// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-LAST-USE-VTAG-RETAINED-002","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-B-IOT-STREAM-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001","PTO-INST-BLOCK-B-IOT"],"kind":"state-transition","summary":"B.IOT last-use consumes selected-PE payload capacity while retaining the relative Local generation identity.","pass_condition":"Successful last-use clears only the participating PE payload-live bits, preserves the descriptor and relative selector, frees corresponding capacity, and makes a later selected-PE payload use unavailable.","related_sources":["asl/block/model/operands/tile-bindings.asl","asl/tile/model/capacity/local.asl","asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(7, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, '1100');
    InstallRelativeTileFixture(0, 7);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 0x55);

    assert RelativeTileSourceAvailable(0);
    assert ResolveRelativeTileSource(0) == 7;
    assert TilePayloadLiveForMask(7, '1100');
    assert TileCapacityInUseForPE(0) == 128;
    assert TileCapacityInUseForPE(1) == 128;

    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1000',
        TRUE, FALSE, 7, 0, FALSE, TRUE, TRUE);
    _BundleTileBindings[[0]].source0_subview.valid = TRUE;
    _BundleTileBindings[[0]].source0_subview.size_code = 1;
    FinalizeBundleTileAttempt(TileExecution_Rejected);
    assert _TilePayloadLiveMasks[[7]] == '1100';
    FinalizeBundleTileAttempt(TileExecution_Executed);

    assert _Tiles[[7]].allocated;
    assert _TileAllocationMasks[[7]] == '1100';
    assert _TilePayloadLiveMasks[[7]] == '0100';
    assert RelativeTileSourceAvailable(0);
    assert ResolveRelativeTileSource(0) == 7;
    assert !TilePayloadLiveForMask(7, '1000');
    assert TilePayloadLiveForMask(7, '0100');
    assert TileCapacityInUseForPE(0) == 0;
    assert TileCapacityInUseForPE(1) == 128;

    ClearBundleHeaderState();
    ClearFault();
    AddBundleTileBinding(FALSE, 0, 0, '1000',
        TRUE, FALSE, 0, 0, TRUE);
    MarkBundleTileBindingSourcesRelative(0);
    let resolved = ResolveBundleRelativeTileSources();
    assert resolved;
    assert _BundleTileBindings[[0]].source0 == 7;
    let payload_available = RequireBundleTileSourcePayloads();
    assert !payload_available;
    assert _LastFault == Fault_TileLegality;
    assert ResolveRelativeTileSource(0) == 7;
    return 0;
end;
