// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-M32-CHAIN-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TCMP-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"CUBE_M32 compare-produced PredicateCell is consumed by operation-typed TSEL","pass_condition":"a U8-basis PredicateCell produced from E4M3-backed sources selects distinct E4M3 and S8 carriers into a U8 destination","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/legality/predicate-carriers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(10, 128, 1, 4, TileDataType_E4M3,
        TileLayout_CUBE_M32);
    let right_ready = ConfigureCubeTile(11, 128, 1, 4, TileDataType_E4M3,
        TileLayout_CUBE_M32);
    let predicate_ready = ConfigurePredicateCell(
        12, 128, 1, 4, TileDataType_U8, TileLayout_CUBE_M32);
    let true_ready = ConfigureCubeTile(13, 128, 1, 4, TileDataType_E4M3,
        TileLayout_CUBE_M32);
    let false_ready = ConfigureCubeTile(14, 128, 1, 4, TileDataType_S8,
        TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(15, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32);
    assert left_ready && right_ready && predicate_ready && true_ready &&
        false_ready && destination_ready;

    for column = 0 to 3 looplimit 4 do
        WriteTileElement(10, 0, column, Zeros{PTO_XLEN} + column + 1);
        WriteTileElement(11, 0, column,
            Zeros{PTO_XLEN} + (if column MOD 2 == 0 then column + 1 else 9));
        WriteTileElement(13, 0, column, Zeros{PTO_XLEN} + 0xa0 + column);
        WriteTileElement(14, 0, column, Zeros{PTO_XLEN} + 0xb0 + column);
    end;
    MarkTileValidRegionDefined(10);
    MarkTileValidRegionDefined(11);
    MarkTileValidRegionDefined(13);
    MarkTileValidRegionDefined(14);

    assert TileOperandsLegal_ExecuteTileCompareAs(
        12, 10, 11, TileComparison_EQ, TileDataType_U8);
    ExecuteTileCompareCellAs(
        12, 10, 11, TileComparison_EQ, TileDataType_U8);
    assert _Tiles[[12]].predicate_basis_type == TileDataType_U8;
    assert ReadTileElement(12, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(12, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(12, 0, 2) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(12, 0, 3) == Zeros{PTO_XLEN};

    assert TileOperandsLegal_ExecuteTileSelectAs(
        15, 12, 13, 14, TileDataType_U8);
    ExecuteTileSelectAs(15, 12, 13, 14, TileDataType_U8);
    assert _Tiles[[15]].data_type == TileDataType_U8;
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 0xa0;
    assert ReadTileElement(15, 0, 1) == Zeros{PTO_XLEN} + 0xb1;
    assert ReadTileElement(15, 0, 2) == Zeros{PTO_XLEN} + 0xa2;
    assert ReadTileElement(15, 0, 3) == Zeros{PTO_XLEN} + 0xb3;
    return 0;
end;
