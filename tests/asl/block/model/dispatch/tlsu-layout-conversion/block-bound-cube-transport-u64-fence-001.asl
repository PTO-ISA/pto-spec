// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-TRANSPORT-U64-FENCE-001","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-CUBE-AUX-CELLREG-001"],"kind":"boundary","summary":"U64 CUBE transport is fenced to ND2N8 TLOAD","pass_condition":"only ND2N8 U64 TLOAD is accepted; U64 M-layout loads and every U64 store remain illegal","related_sources":["asl/tile/model/shape/cube-cell.asl"]}
func main() => integer
begin
    assert BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_N8, 0);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M16, 0);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M32, 0);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_N8, 1);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M16, 1);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M32, 1);
    return 0;
end;
