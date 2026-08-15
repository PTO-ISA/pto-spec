// PTO-TEST: {"id":"PTO-AVS-TILE-TCMPS-PACKED-001","source":"asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl","requirements":["PTO-INST-TILE-TCMPS"],"kind":"execution","summary":"TCMPS packs scalar-comparison predicates from low logical indices into low byte bits","pass_condition":"ten GE comparisons occupy bits zero through seven of byte zero and bits zero through one of byte one","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
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
        TileDataType_U8,
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
