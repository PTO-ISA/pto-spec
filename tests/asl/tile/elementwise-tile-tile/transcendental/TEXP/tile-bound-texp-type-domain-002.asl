// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-TYPE-DOMAIN-002","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP"],"kind":"boundary","summary":"TEXP discriminates its complete executable helper DataType domain","pass_condition":"all eight floating helper types pass and representative integer, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TEXPDataTypeLegal(TileDataType_FP64);
    assert TEXPDataTypeLegal(TileDataType_FP32);
    assert TEXPDataTypeLegal(TileDataType_TF32);
    assert TEXPDataTypeLegal(TileDataType_HF32);
    assert TEXPDataTypeLegal(TileDataType_FP16);
    assert TEXPDataTypeLegal(TileDataType_BF16);
    assert TEXPDataTypeLegal(TileDataType_E4M3);
    assert TEXPDataTypeLegal(TileDataType_E5M2);
    assert !TEXPDataTypeLegal(TileDataType_HiF8);
    assert !TEXPDataTypeLegal(TileDataType_E8M0);
    assert !TEXPDataTypeLegal(TileDataType_E3M2);
    assert !TEXPDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
