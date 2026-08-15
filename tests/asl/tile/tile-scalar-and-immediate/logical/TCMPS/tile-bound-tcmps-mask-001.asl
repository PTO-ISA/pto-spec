// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-MASK-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-INST-TILE-TCMPS"],"kind":"boundary","summary":"TCMPS requires numeric input and predicate-kind destination storage","pass_condition":"the predicate destination passes while an ordinary numeric destination rejects","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTCMPSInput()
begin
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
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 9);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTCMPSInput();
    ConfigurePredicateTile(1, 128, 8, 2, 1, 2);
    assert TileOperandsLegal_ExecuteTileCompareScalar(
        1,
        0,
        Zeros{PTO_XLEN} + 7,
        TileComparison_EQ);

    ResetProfileState();
    ConfigureTCMPSInput();
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
    assert !TileOperandsLegal_ExecuteTileCompareScalar(
        1,
        0,
        Zeros{PTO_XLEN} + 7,
        TileComparison_EQ);
    return 0;
end;
