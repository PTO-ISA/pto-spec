// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-CUBE-BASIS-003","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001","PTO-TILE-MODEL-DEFINEDNESS-PREDICATE-CELL-001"],"kind":"fault","summary":"TSEL consumes logical PredicateCell values independently of comparison basis while rejecting malformed values and shape","pass_condition":"a U16-basis predicate selects FP32 data with independent true/false results; mismatched valid shape and non-Boolean predicates reject","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/state/types.asl"]}
func main() => integer
begin
    ResetProfileState();
    let mask_ready = ConfigurePredicateCell(
        8, 128, 1, 1, TileDataType_U16, TileLayout_CUBE_M32);
    let true_ready = ConfigureCubeTile(
        9, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32);
    let false_ready = ConfigureCubeTile(
        10, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        11, 128, 1, 1, TileDataType_FP32,
        TileLayout_CUBE_M32);
    assert mask_ready && true_ready && false_ready && destination_ready;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(9, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 20);
    _Tiles[[8]].contents_defined = TRUE;
    MarkTileValidRegionDefined(9);
    MarkTileValidRegionDefined(10);

    assert TilePredicateCellValuesLegal(8);
    assert !TilePredicateCellShapeMatchesNumeric(8, 9);
    // TSEL uses logical mask coordinates, not the comparison basis type.
    assert TileOperandsLegal_ExecuteTileSelect(11, 8, 9, 10);
    ExecuteTileSelect(11, 8, 9, 10);
    assert ReadTileElement(11, 0, 0) == Zeros{PTO_XLEN} + 10;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN});
    ExecuteTileSelect(11, 8, 9, 10);
    assert ReadTileElement(11, 0, 0) == Zeros{PTO_XLEN} + 20;
    let mismatched_shape = ConfigurePredicateCell(
        12, 128, 2, 1, TileDataType_U16, TileLayout_CUBE_M32);
    assert mismatched_shape;
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN});
    _Tiles[[12]].contents_defined = TRUE;
    assert !TileOperandsLegal_ExecuteTileSelect(11, 12, 9, 10);
    assert ReadTileElement(11, 0, 0) == Zeros{PTO_XLEN} + 20;

    ResetProfileState();
    let malformed_ready = ConfigurePredicateCell(
        8, 128, 1, 1, TileDataType_FP32, TileLayout_CUBE_M32);
    assert malformed_ready;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 2);
    _Tiles[[8]].contents_defined = TRUE;
    assert !TilePredicateCellValuesLegal(8);
    return 0;
end;
