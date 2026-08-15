// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-DEFINEDNESS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD"],"kind":"boundary","summary":"TADD rejects an undefined source Tile before destination effects","pass_condition":"binary operand legality rejects the undefined right source while preserving the destination","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);

    assert !TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD, 2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
