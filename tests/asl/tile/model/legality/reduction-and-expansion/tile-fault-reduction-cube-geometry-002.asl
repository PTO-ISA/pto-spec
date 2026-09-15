// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-CUBE-GEOMETRY-002","source":"asl/tile/model/legality/reduction-and-expansion.asl","requirements":["PTO-TROWARGMAX-CONTRACT-001","PTO-TCOLSUM-CONTRACT-001"],"kind":"fault","summary":"CUBE reduction destinations preserve the required physical source dimension","pass_condition":"row reductions reject a destination with mismatched physical Columns and column reductions reject a destination with mismatched physical Rows","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source = ConfigureCubeTileForMaskWithPhysical(0, 4096, 64, 16,
        8, 16, TileDataType_U8, TileLayout_CUBE_M32, '0001');
    let row_bad = ConfigureCubeTileForMaskWithPhysical(1, 512, 32, 4,
        8, 1, TileDataType_U8, TileLayout_CUBE_M32, '0001');
    let column_bad = ConfigureCubeTileForMaskWithPhysical(2, 1024, 32, 16,
        1, 16, TileDataType_U8, TileLayout_CUBE_M32, '0001');
    assert source && row_bad && column_bad;
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 1, 0);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Column, 2, 0);
    return 0;
end;
