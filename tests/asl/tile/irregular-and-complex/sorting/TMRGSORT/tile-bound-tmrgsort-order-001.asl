// PTO-TEST: {"id":"PTO-AVS-TILE-TMRGSORT-ORDER-001","source":"asl/tile/irregular-and-complex/sorting/TMRGSORT.asl","requirements":["PTO-INST-TILE-TMRGSORT"],"kind":"boundary","summary":"TMRGSORT requires each source to be sorted in the selected direction","pass_condition":"an ascending request rejects a descending left source","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        30, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        31, 256, 1, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        32, 256, 1, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(30, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(31, 0, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(31, 0, 1, Zeros{PTO_XLEN} + 0x40800000);

    assert !TileOperandsLegal_TMRGSORT(32, 30, 31, FALSE);
    return 0;
end;
