// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-MGATHER-PACKED-002","source":"asl/tile/model/memory/gather-scatter.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"Packed MGATHER applies one transfer mask coordinate to both destination nibbles while MERGE reads each destination coordinate","pass_condition":"One active transfer loads both nibbles, one inactive transfer produces two zero or distinct merged nibbles without probing, and activating its invalid address raises Fault_DataPage","related_sources":["asl/tile/model/legality/indexed-layout.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func ConfigurePackedGatherTiles()
begin
    let destination_ready = ConfigureCubeTile(
        0, 128, 1, 4, TileDataType_U4X2, TileLayout_CUBE_M16);
    let indices_ready = ConfigureCubeTile(
        1, 128, 1, 2, TileDataType_S32, TileLayout_CUBE_M16);
    let merge_ready = ConfigureCubeTile(
        2, 128, 1, 4, TileDataType_U4X2, TileLayout_CUBE_M16);
    assert destination_ready && indices_ready && merge_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4096);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 3, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 0xa5);
end;

func CaptureFirstTransferOnly()
begin
    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePackedGatherTiles();
    CaptureFirstTransferOnly();
    _BundleExecutionMask.zero_inactive = TRUE;
    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x300, 1);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN};
    StopMemoryEventCapture();

    CaptureFirstTransferOnly();
    _BundleExecutionMask.zero_inactive = FALSE;
    _BundleExecutionMask.merge_base = 2;
    _BundleExecutionMask.merge_base_valid = TRUE;
    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x300, 1);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 4;
    StopMemoryEventCapture();

    var all_active = Zeros{PTO_XLEN};
    all_active[0] = '1';
    all_active[16] = '1';
    CaptureBundleExecutionMaskGPR(
        all_active, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    ClearFault();
    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x300, 1);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 4;
    StopMemoryEventCapture();
    return 0;
end;
