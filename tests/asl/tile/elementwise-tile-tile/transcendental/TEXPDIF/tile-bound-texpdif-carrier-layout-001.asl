// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-CARRIER-LAYOUT-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"boundary","summary":"TEXPDIF admits ordinary equal-width carriers and only the three frozen elementwise layouts","pass_condition":"U16/S16 carriers are independently compatible with FP16, packed and width-changing carriers reject, and CUBE_N8 or mixed layouts reject","related_sources":["asl/tile/model/legality/dtype-layout.asl","asl/tile/model/legality/expdif-operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    assert TileCarrierWidthCompatible(
        TileDataType_U16, TileDataType_FP16);
    assert TileCarrierWidthCompatible(
        TileDataType_S16, TileDataType_FP16);
    assert !TileCarrierWidthCompatible(
        TileDataType_FP32, TileDataType_FP16);
    assert !TileCarrierWidthCompatible(
        TileDataType_E2M1X2, TileDataType_FP16);
    assert TileElementwiseLayoutSupported(TileLayout_RowMajor);
    assert TileElementwiseLayoutSupported(TileLayout_CUBE_M16);
    assert TileElementwiseLayoutSupported(TileLayout_CUBE_M32);
    assert !TileElementwiseLayoutSupported(TileLayout_CUBE_N8);
    ConfigureTile(1, 128, 16, 2, 1, 2,
        TileDataType_FP16, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 2, 1, 2,
        TileDataType_FP16, TileLayout_RowMajor);
    _Tiles[[2]].layout = TileLayout_CUBE_M16;
    assert !TileExpdifLogicalShapeMatch(1, 2);
    return 0;
end;
