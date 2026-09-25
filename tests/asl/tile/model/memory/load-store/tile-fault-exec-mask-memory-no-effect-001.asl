// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-MEMORY-NO-EFFECT-001","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TLOAD-MEMORY-001"],"kind":"fault","summary":"Inactive regular-load/store coordinates do not probe memory or read inactive source elements","pass_condition":"TLOAD and TSTORE complete with one active lane at the end of a mapped page while the inactive next-page lane has no fault or event; inactive TSTORE source may be undefined","related_sources":["asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/legality/execution-mask-source-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    let load_tile_ready = ConfigureCubeTile(
        4, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert load_tile_ready;
    Store(Zeros{PTO_XLEN} + 4092, 4, Zeros{PTO_XLEN} + 31);
    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    StartMemoryEventCapture(0);
    TLOAD(4, Zeros{PTO_XLEN} + 4092, Zeros{PTO_XLEN} + 4);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 31;
    assert ReadTileElement(4, 0, 1) == Zeros{PTO_XLEN};
    assert TileLogicalElementDefined(_Tiles[[4]], 1);
    StopMemoryEventCapture();

    ResetProfileState();
    let store_tile_ready = ConfigureCubeTile(
        5, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert store_tile_ready;
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 47);
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    StartMemoryEventCapture(0);
    TSTORE(Zeros{PTO_XLEN} + 4092, Zeros{PTO_XLEN} + 4, 5);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    let stored = LoadUnsigned(Zeros{PTO_XLEN} + 4092, 4);
    assert stored == Zeros{PTO_XLEN} + 47;
    StopMemoryEventCapture();
    return 0;
end;
