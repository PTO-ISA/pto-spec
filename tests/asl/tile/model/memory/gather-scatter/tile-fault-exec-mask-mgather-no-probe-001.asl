// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-MGATHER-NO-PROBE-001","source":"asl/tile/model/memory/gather-scatter.asl","requirements":["PTO-REQ-TEPL-PREDICATE-CARRIER-001","PTO-INST-TILE-MGATHER"],"kind":"fault","summary":"MGATHER skips inactive indexed addresses before memory probes","pass_condition":"the active indexed load completes while an inactive index points into an unmapped page without a fault or event; the inactive result is ZERO","related_sources":["asl/tile/model/legality/memory-schema.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let destination_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let indices_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert destination_ready && indices_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4096);
    Store(Zeros{PTO_XLEN} + 512, 4, Zeros{PTO_XLEN} + 21);
    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 512, 1);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};
    StopMemoryEventCapture();
    return 0;
end;
