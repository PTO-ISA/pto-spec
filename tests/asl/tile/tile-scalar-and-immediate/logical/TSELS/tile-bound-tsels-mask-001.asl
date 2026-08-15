// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-MASK-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-INST-TILE-TSELS"],"kind":"boundary","summary":"TSELS accepts only a fully defined packed predicate mask","pass_condition":"a predicate-kind mask passes while an ordinary numeric mask rejects before effects","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTSELSNumericTiles()
begin
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 11);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTSELSNumericTiles();
    ConfigurePredicateTile(0, 128, 8, 2, 1, 2);
    WriteTilePredicateBit(0, 0, 0, TRUE);
    WriteTilePredicateBit(0, 0, 1, FALSE);
    assert TileOperandsLegal_ExecuteTileSelectScalar(
        2,
        0,
        1,
        Zeros{PTO_XLEN} + 9);

    ResetProfileState();
    ConfigureTSELSNumericTiles();
    ConfigureTile(
        0,
        128,
        8,
        2,
        1,
        2,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    assert !TileOperandsLegal_ExecuteTileSelectScalar(
        2,
        0,
        1,
        Zeros{PTO_XLEN} + 9);
    return 0;
end;
