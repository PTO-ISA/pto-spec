// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-PACKED-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-INST-TILE-TCMPS","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Direct TCMPS fallback uses the source backing for scalar comparison","pass_condition":"an S8 source and scalar compare through the direct-call source-backing fallback and pack ten GE results","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        8,
        16,
        1,
        10,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigurePredicateTile(1, 128, 8, 16, 1, 10);
    for column = 0 to 9 looplimit 10 do
        WriteTileElement(
            0,
            0,
            column,
            Zeros{PTO_XLEN} + column);
    end;

    ExecuteTileCompareScalar(
        1,
        0,
        Zeros{PTO_XLEN} + 5,
        TileComparison_GE);

    assert ReadTilePredicateByte(1, 0) == '11100000';
    assert ReadTilePredicateByte(1, 1) == '00000011';
    assert TilePredicateBitDefined(1, 0, 9);
    return 0;
end;
