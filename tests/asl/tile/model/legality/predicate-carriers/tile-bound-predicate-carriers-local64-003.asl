// PTO-TEST: {"id":"PTO-AVS-TILE-PREDICATE-CARRIERS-LOCAL64-003","source":"asl/tile/model/legality/predicate-carriers.asl","requirements":["PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"boundary","summary":"Predicate-carrier legality admits all selected M32 64-bit basis types and rejects their M16 form.","pass_condition":"FP64, S64, and U64 use two M32 predicate fields, legal numeric and PredicateCell descriptors, while M16 64-bit allocation remains unavailable.","related_sources":["asl/tile/model/execution/predicate-carriers.asl","asl/tile/model/shape/cube-double-cell.asl"]}
func main() => integer
begin
    assert TileCubePredicateDataTypeSupported(TileDataType_FP64);
    assert TileCubePredicateDataTypeSupported(TileDataType_S64);
    assert TileCubePredicateDataTypeSupported(TileDataType_U64);
    assert TileCubePredicateGPRDataTypeSupported(TileDataType_FP64);
    assert TileCubePredicateGPRDataTypeSupported(TileDataType_S64);
    assert TileCubePredicateGPRDataTypeSupported(TileDataType_U64);
    assert TileCubePredicateFieldCount(
        TileDataType_U64, TileLayout_CUBE_M32) == 2;

    ResetProfileState();
    let numeric_ready = ConfigureCubeTile(
        0, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    let predicate_ready = ConfigurePredicateCell(
        1, 128, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert numeric_ready && predicate_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    assert TileCubePredicateGPRShapeLegal(0);
    assert TilePredicateCellDescriptorLegal(1);
    assert TilePredicateCellShapeMatchesNumeric(1, 0);
    let m16_predicate = ConfigurePredicateCell(
        2, 128, 1, 1, TileDataType_U64, TileLayout_CUBE_M16);
    assert !m16_predicate;
    return 0;
end;
