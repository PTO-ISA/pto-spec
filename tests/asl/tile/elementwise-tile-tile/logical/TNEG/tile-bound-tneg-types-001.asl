// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"boundary","summary":"TNEG accepts exactly its nine arithmetic element types","pass_condition":"representative accepted signed, 64-bit, and floating types pass while U32, HiF8, and packed S4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert TNEGDataTypeLegal(TileDataType_FP32);
    assert TNEGDataTypeLegal(TileDataType_FP16);
    assert TNEGDataTypeLegal(TileDataType_BF16);
    assert TNEGDataTypeLegal(TileDataType_S32);
    assert TNEGDataTypeLegal(TileDataType_S16);
    assert TNEGDataTypeLegal(TileDataType_S8);
    assert TNEGDataTypeLegal(TileDataType_U64);
    assert TNEGDataTypeLegal(TileDataType_FP64);
    assert !TNEGDataTypeLegal(TileDataType_U32);
    assert !TNEGDataTypeLegal(TileDataType_HiF8);
    assert !TNEGDataTypeLegal(TileDataType_S4X2);
    return 0;
end;
