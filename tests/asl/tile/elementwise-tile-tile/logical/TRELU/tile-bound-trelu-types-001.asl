// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"boundary","summary":"TRELU accepts exactly its seven arithmetic element types","pass_condition":"representative accepted 64-bit, 32-bit, and floating types pass while S16, E8M0, and packed S4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert TRELUDataTypeLegal(TileDataType_FP32);
    assert TRELUDataTypeLegal(TileDataType_FP16);
    assert TRELUDataTypeLegal(TileDataType_BF16);
    assert TRELUDataTypeLegal(TileDataType_S32);
    assert TRELUDataTypeLegal(TileDataType_U64);
    assert TRELUDataTypeLegal(TileDataType_FP64);
    assert !TRELUDataTypeLegal(TileDataType_S16);
    assert !TRELUDataTypeLegal(TileDataType_E8M0);
    assert !TRELUDataTypeLegal(TileDataType_S4X2);
    return 0;
end;
