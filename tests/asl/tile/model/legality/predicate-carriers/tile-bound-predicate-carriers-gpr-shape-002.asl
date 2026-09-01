// PTO-TEST: {"id":"PTO-AVS-TILE-PREDICATE-CARRIERS-GPR-SHAPE-002","source":"asl/tile/model/legality/predicate-carriers.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TSEL-CONTRACT-001"],"kind":"boundary","summary":"CUBE GPR predicate carriers fail closed at their row and column capacity","pass_condition":"maximum M32 and M16 S16 shapes fit one GPR while one extra representable CUBE column is rejected","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/block/model/dispatch/comparison-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    let m32_max = ConfigureCubeTile(
        10, 128, 32, 2, TileDataType_S16,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let m32_over = ConfigureCubeTile(
        11, 256, 32, 3, TileDataType_S16,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let m16_max = ConfigureCubeTile(
        12, 128, 16, 4, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let m16_over = ConfigureCubeTile(
        13, 256, 16, 5, TileDataType_S16,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    assert m32_max && m32_over && m16_max && m16_over;
    assert TileCubePredicateGPRShapeLegal(10);
    assert !TileCubePredicateGPRShapeLegal(11);
    assert TileCubePredicateGPRShapeLegal(12);
    assert !TileCubePredicateGPRShapeLegal(13);
    return 0;
end;
