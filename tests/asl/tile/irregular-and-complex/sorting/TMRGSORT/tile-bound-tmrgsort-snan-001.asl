// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-SNAN-001","source":"asl/tile/irregular-and-complex/sorting/TMRGSORT.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"boundary","summary":"TMRGSORT merges signaling NaN after numeric values and records NV","pass_condition":"an FP32 signaling NaN remains mergeable, follows the numeric value, and sets numeric invalid status","related_sources":["asl/tile/model/execution/sorting.asl","asl/tile/model/legality/sorting.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        30, 256, 1, 1, 1, 1,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        31, 256, 1, 1, 1, 1,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        32, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 0x7f800001);
    WriteTileElement(31, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);

    assert TileOperandsLegal_TMRGSORT(32, 30, 31, FALSE);
    TMRGSORT(32, 30, 31, FALSE);

    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ReadTileElement(32, 0, 1) == Zeros{PTO_XLEN} + 0x7f800001;
    assert NumericStatusFlags() == Zeros{5} + 1;
    return 0;
end;
