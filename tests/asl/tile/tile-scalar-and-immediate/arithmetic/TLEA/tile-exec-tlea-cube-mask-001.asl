// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-CUBE-MASK-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"TLEA suppresses inactive CUBE source reads and applies common MERGE and ZERO results.","pass_condition":"An undefined inactive S32 source coordinate is legal; the active coordinate scales, while the inactive U64 destination coordinate first merges from the base and then zeros.","related_sources":["asl/tile/model/legality/execution-mask-source-schema.asl","asl/tile/model/execution/execution-mask-state.asl","asl/tile/model/execution/lea.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_S32, TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        1, 512, 1, 2, TileDataType_S64, TileLayout_CUBE_M32);
    let base_ready = ConfigureCubeTile(
        2, 512, 1, 2, TileDataType_S64, TileLayout_CUBE_M32);
    assert source_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x55);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x66);

    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M32, 1, 2);
    _BundleExecutionMask.merge_base = 2;
    _BundleExecutionMask.merge_base_valid = TRUE;
    assert TileOperandsLegal_TLEA(1, 0, Zeros{PTO_XLEN} + 16);
    TLEA(1, 0, Zeros{PTO_XLEN} + 16);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x66;

    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_TLEA(1, 0, Zeros{PTO_XLEN} + 16);
    TLEA(1, 0, Zeros{PTO_XLEN} + 16);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
