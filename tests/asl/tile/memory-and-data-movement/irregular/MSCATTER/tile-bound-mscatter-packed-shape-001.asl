// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-PACKED-SHAPE-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER.asl","requirements":["PTO-MSCATTER-BYTE-DISPLACEMENT-001"],"kind":"boundary","summary":"MSCATTER rejects an incomplete packed byte valid region.","pass_condition":"A U4X2 source with an odd valid-column count rejects against one index lane before any memory effect.","related_sources":["asl/tile/model/legality/indexed-layout.asl","asl/tile/model/legality/memory-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 1, TileDataType_U4X2,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    assert !TileOperandsLegal_MSCATTER(
        Zeros{PTO_XLEN}, 0, 1);
    return 0;
end;
