// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"boundary","summary":"TFMA accepts exactly its six assigned fused arithmetic element types.","pass_condition":"FP64, S64, U64, FP16, FP32, and BF16 pass while all other tested carriers reject.","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TFMADataTypeLegal(TileDataType_FP32);
    assert TFMADataTypeLegal(TileDataType_FP64);
    assert !TFMADataTypeLegal(TileDataType_TF32);
    assert !TFMADataTypeLegal(TileDataType_HF32);
    assert TFMADataTypeLegal(TileDataType_FP16);
    assert TFMADataTypeLegal(TileDataType_BF16);
    assert !TFMADataTypeLegal(TileDataType_E4M3);
    assert !TFMADataTypeLegal(TileDataType_E5M2);
    assert TFMADataTypeLegal(TileDataType_S64);
    assert !TFMADataTypeLegal(TileDataType_S32);
    assert !TFMADataTypeLegal(TileDataType_S16);
    assert !TFMADataTypeLegal(TileDataType_S8);
    assert TFMADataTypeLegal(TileDataType_U64);
    assert !TFMADataTypeLegal(TileDataType_U32);
    assert !TFMADataTypeLegal(TileDataType_U16);
    assert !TFMADataTypeLegal(TileDataType_U8);
    assert !TFMADataTypeLegal(TileDataType_HiF8);
    assert !TFMADataTypeLegal(TileDataType_U4X2);
    return 0;
end;
