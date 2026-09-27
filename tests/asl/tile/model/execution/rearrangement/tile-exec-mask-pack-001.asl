// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-PACK-001","source":"asl/tile/model/execution/rearrangement.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001"],"kind":"execution","summary":"TPACK reads active words only and applies ExecutionMask MERGE/ZERO per CUBE cell","pass_condition":"active word packs, undefined inactive source words do not reject, MERGE preserves old inactive destination, and ZERO writes zero without reading any source word","related_sources":["asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert left_ready && right_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x11223344);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x55667788);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 88);
    var mask = Zeros{PTO_XLEN};
    mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = FALSE;
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    let control = Zeros{PTO_XLEN} + 0x0000000000000202;
    assert TileOperandsLegal_TPACK(2, 0, 1, control);
    TPACK(2, 0, 1, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x77883344;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 88;

    ResetProfileState();
    let left_zero_ready = ConfigureCubeTile(
        0, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let right_zero_ready = ConfigureCubeTile(
        1, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_zero_ready = ConfigureCubeTile(
        2, 256, 1, 2, TileDataType_U32, TileLayout_CUBE_M16);
    assert left_zero_ready && right_zero_ready && destination_zero_ready;
    CaptureBundleExecutionMaskGPR(
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, 1,
        TileLayout_CUBE_M16, 1, 2);
    _BundleExecutionMask.zero_inactive = TRUE;
    assert TileOperandsLegal_TPACK(2, 0, 1, control);
    TPACK(2, 0, 1, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
