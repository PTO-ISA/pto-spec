// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-MGATHER-MASK-PACKED-003","source":"asl/tile/model/memory/gather-scatter.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-INST-TILE-MGATHER-MASK"],"kind":"execution","summary":"Packed MGATHER_MASK keeps transfer-mask and expanded destination MERGE coordinates distinct","pass_condition":"An execution-masked packed transfer skips its invalid address and writes both expanded destination nibbles according to ZERO or their distinct MERGE coordinates","related_sources":["asl/tile/model/legality/indexed-layout.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func ConfigurePackedMaskedGatherTiles()
begin
    let destination_ready = ConfigureCubeTile(
        0, 128, 1, 4, TileDataType_S4X2, TileLayout_CUBE_M16);
    let indices_ready = ConfigureCubeTile(
        1, 128, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let predicate_ready = ConfigureCubeTile(
        2, 128, 1, 2, TileDataType_U8, TileLayout_CUBE_M16);
    let merge_ready = ConfigureCubeTile(
        3, 128, 1, 4, TileDataType_S4X2, TileLayout_CUBE_M16);
    assert destination_ready && indices_ready && predicate_ready && merge_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4096);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(3, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 3, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x380, 1, Zeros{PTO_XLEN} + 0x7e);
end;

func CaptureFirstPackedTransferOnly()
begin
    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePackedMaskedGatherTiles();
    CaptureFirstPackedTransferOnly();
    _BundleExecutionMask.zero_inactive = TRUE;
    StartMemoryEventCapture(0);
    MGATHER_MASK(0, Zeros{PTO_XLEN} + 0x380, 1, 2, TilePad_Max);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 14;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN};
    StopMemoryEventCapture();

    CaptureFirstPackedTransferOnly();
    _BundleExecutionMask.zero_inactive = FALSE;
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    StartMemoryEventCapture(0);
    MGATHER_MASK(0, Zeros{PTO_XLEN} + 0x380, 1, 2, TilePad_Max);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 14;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 4;
    StopMemoryEventCapture();
    return 0;
end;
