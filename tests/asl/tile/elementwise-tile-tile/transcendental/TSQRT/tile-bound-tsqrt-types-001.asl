// PTO-TEST: {"id":"PTO-AVS-TILE-TSQRT-TYPES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl","requirements":["PTO-INST-TILE-TSQRT"],"kind":"boundary","summary":"TSQRT accepts only its four assigned floating element types","pass_condition":"FP64, FP32, FP16, and BF16 pass while TF32, HF32, compact, integer, exponent-only, and packed types reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert TSQRTDataTypeLegal(TileDataType_FP32);
    assert TSQRTDataTypeLegal(TileDataType_FP16);
    assert TSQRTDataTypeLegal(TileDataType_BF16);
    assert TSQRTDataTypeLegal(TileDataType_FP64);
    assert !TSQRTDataTypeLegal(TileDataType_TF32);
    assert !TSQRTDataTypeLegal(TileDataType_HF32);
    assert !TSQRTDataTypeLegal(TileDataType_E4M3);
    assert !TSQRTDataTypeLegal(TileDataType_E5M2);
    assert !TSQRTDataTypeLegal(TileDataType_U64);
    assert !TSQRTDataTypeLegal(TileDataType_E8M0);
    assert !TSQRTDataTypeLegal(TileDataType_E3M2);
    assert !TSQRTDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
