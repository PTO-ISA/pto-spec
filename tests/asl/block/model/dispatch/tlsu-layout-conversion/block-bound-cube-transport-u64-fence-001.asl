// PTO-TEST: {"id":"PTO-AVS-BLOCK-CUBE-TRANSPORT-U64-FENCE-001","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-CUBE-AUX-CELLREG-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"boundary","summary":"U64 CUBE transport admits N8 load and M32 double-CELL load/store only","pass_condition":"ND2N8 U64 TLOAD and M32 U64 load/store are accepted while M16 U64 transport and N8 U64 store remain illegal","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/shape/cube-double-cell.asl"]}
func main() => integer
begin
    assert BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_N8, 0);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M16, 0);
    assert BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M32, 0);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_N8, 1);
    assert !BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M16, 1);
    assert BundleCubeTransportDataTypeSupported(
        TileDataType_U64, TileLayout_CUBE_M32, 1);
    return 0;
end;
