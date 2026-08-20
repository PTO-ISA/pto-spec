// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-LAYOUT-002","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"boundary","summary":"Local Matrix primaries use exact M16 M32 and N8 CUBE layout roles","pass_condition":"A C and D accept the selected M layout B accepts only N8 and M16 or M32 enforce their architectural M limits","related_sources":["asl/tile/model/legality/matrix-operands.asl","asl/tile/model/shape/cube-cell.asl"]}
func main() => integer
begin
    ResetProfileState();
    let a_m16 = ConfigureCubeTile(0, 640, 13, 17,
        TileDataType_FP16, TileLayout_CUBE_M16, TileLocation_Matrix);
    let a_m32 = ConfigureCubeTile(1, 1152, 13, 17,
        TileDataType_FP16, TileLayout_CUBE_M32, TileLocation_Matrix);
    let b_n8 = ConfigureCubeTile(2, 768, 17, 9,
        TileDataType_FP16, TileLayout_CUBE_N8, TileLocation_Matrix);
    let c_m16 = ConfigureCubeTile(3, 640, 13, 9,
        TileDataType_FP32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert a_m16 && a_m32 && b_n8 && c_m16;
    MarkTileValidRegionDefined(0);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(3);

    assert TileMatrixMLayoutLegal(TileLayout_CUBE_M16, 1);
    assert TileMatrixMLayoutLegal(TileLayout_CUBE_M16, 16);
    assert !TileMatrixMLayoutLegal(TileLayout_CUBE_M16, 17);
    assert TileMatrixMLayoutLegal(TileLayout_CUBE_M32, 16);
    assert TileMatrixMLayoutLegal(TileLayout_CUBE_M32, 17);
    assert TileMatrixMLayoutLegal(TileLayout_CUBE_M32, 32);
    assert !TileMatrixMLayoutLegal(TileLayout_CUBE_M32, 33);
    assert !TileMatrixMLayoutLegal(TileLayout_CUBE_N8, 13);

    assert TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[0]], 13, 17, TileDataType_FP16, TileLayout_CUBE_M16);
    assert TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[1]], 13, 17, TileDataType_FP16, TileLayout_CUBE_M32);
    assert TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[2]], 17, 9, TileDataType_FP16, TileLayout_CUBE_N8);
    assert TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[3]], 13, 9, TileDataType_FP32, TileLayout_CUBE_M16);
    assert !TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[0]], 13, 17, TileDataType_FP16, TileLayout_CUBE_N8);
    assert !TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[2]], 17, 9, TileDataType_FP16, TileLayout_CUBE_M16);
    assert !TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[3]], 13, 9, TileDataType_FP32, TileLayout_CUBE_M32);
    return 0;
end;
