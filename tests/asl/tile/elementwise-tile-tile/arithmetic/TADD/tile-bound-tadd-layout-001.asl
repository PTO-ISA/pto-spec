// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-LAYOUT-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD"],"kind":"boundary","summary":"TADD accepts row-major Tiles and rejects other physical layouts","pass_condition":"matching column-major descriptors are rejected before destination effects","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 2, 8, 1, 1,
            TileDataType_U64, TileLayout_ColumnMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);

    assert !TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD, 2, 0, 1);
    assert !_Tiles[[2]].contents_defined;
    return 0;
end;
