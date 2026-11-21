// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"boundary","summary":"TNOT accepts exactly the eight scalar integer Tile types","pass_condition":"the signed and unsigned 8 16 32 and 64 bit types pass while FP32 and packed U4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert TNOTDataTypeLegal(TileDataType_S32);
    assert TNOTDataTypeLegal(TileDataType_S16);
    assert TNOTDataTypeLegal(TileDataType_S8);
    assert TNOTDataTypeLegal(TileDataType_U32);
    assert TNOTDataTypeLegal(TileDataType_U16);
    assert TNOTDataTypeLegal(TileDataType_U8);
    assert TNOTDataTypeLegal(TileDataType_S64);
    assert TNOTDataTypeLegal(TileDataType_U64);
    assert !TNOTDataTypeLegal(TileDataType_FP32);
    assert !TNOTDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
