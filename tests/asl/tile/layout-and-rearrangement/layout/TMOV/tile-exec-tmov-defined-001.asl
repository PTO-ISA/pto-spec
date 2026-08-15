// PTO-TEST: {"id":"PTO-AVS-TILE-TMOV-DEFINED-001","source":"asl/tile/layout-and-rearrangement/layout/TMOV.asl","requirements":["PTO-TMOV-CONTRACT-001","PTO-INST-TILE-TMOV"],"kind":"execution","summary":"Local TMOV copies payload and per-element definedness without consuming its source.","pass_condition":"The destination matches the source payload and definedness while the source remains unchanged.","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/tile/model/legality/memory-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 32, 4, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);
    TMOV(2, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert TileElementDefined(2, 0, 0);
    assert !TileElementDefined(2, 0, 1);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 7;
    return 0;
end;
