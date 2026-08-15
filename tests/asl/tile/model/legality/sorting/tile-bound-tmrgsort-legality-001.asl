// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-LEGALITY-001","source":"asl/tile/model/legality/sorting.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"boundary","summary":"TMRGSORT requires two nonempty single-row sources sorted in the selected direction","pass_condition":"ascending FP32 sources are legal and a descending left source is rejected","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        30, 128, 16, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        31, 128, 16, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        32, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(30, 0, 1, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(31, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(31, 0, 1, Zeros{PTO_XLEN} + 0x40800000);

    assert TileOperandsLegal_TMRGSORT(32, 30, 31, FALSE);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);
    assert !TileOperandsLegal_TMRGSORT(32, 30, 31, FALSE);
    return 0;
end;
