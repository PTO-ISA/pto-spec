// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-SNAN-001","source":"asl/tile/irregular-and-complex/sorting/TSORT.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"boundary","summary":"TSORT orders signaling NaN after numeric values and records NV","pass_condition":"an FP32 signaling NaN remains a sortable value, follows the numeric element, preserves its source index, and sets numeric invalid status","related_sources":["asl/tile/model/execution/sorting.asl","asl/tile/model/legality/sorting.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        20, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        21, 256, 1, 2, 1, 2,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        22, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 0x7f800001);
    WriteTileElement(22, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);

    assert TileOperandsLegal_TSORT(20, 21, 22, 2, FALSE);
    TSORT(20, 21, 22, 2, FALSE);

    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(20, 0, 1) == Zeros{PTO_XLEN} + 0x7f800001;
    assert ReadTileElement(21, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(21, 0, 1) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == Zeros{5} + 1;
    return 0;
end;
