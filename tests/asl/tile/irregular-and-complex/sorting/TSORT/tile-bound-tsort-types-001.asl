// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-TYPES-001","source":"asl/tile/irregular-and-complex/sorting/TSORT.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"boundary","summary":"TSORT accepts only FP32 or FP16 values with U32 indices","pass_condition":"an otherwise legal U64 value configuration is rejected","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        20, 256, 1, 2, 1, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        21, 256, 1, 2, 1, 2,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        22, 256, 1, 2, 1, 2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(22, 0, 1, Zeros{PTO_XLEN} + 2);

    assert !TileOperandsLegal_TSORT(20, 21, 22, 2, FALSE);
    return 0;
end;
