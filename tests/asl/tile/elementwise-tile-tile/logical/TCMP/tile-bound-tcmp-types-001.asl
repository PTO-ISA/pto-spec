// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001"],"kind":"boundary","summary":"TCMP accepts exactly its sixteen ordered numeric source types","pass_condition":"the eight floating and eight integer types pass while HiF8 and packed U4X2 reject","related_sources":["asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    assert TCMPDataTypeLegal(TileDataType_FP32);
    assert TCMPDataTypeLegal(TileDataType_FP64);
    assert TCMPDataTypeLegal(TileDataType_TF32);
    assert TCMPDataTypeLegal(TileDataType_HF32);
    assert TCMPDataTypeLegal(TileDataType_FP16);
    assert TCMPDataTypeLegal(TileDataType_BF16);
    assert TCMPDataTypeLegal(TileDataType_E4M3);
    assert TCMPDataTypeLegal(TileDataType_E5M2);
    assert TCMPDataTypeLegal(TileDataType_S64);
    assert TCMPDataTypeLegal(TileDataType_S32);
    assert TCMPDataTypeLegal(TileDataType_S16);
    assert TCMPDataTypeLegal(TileDataType_S8);
    assert TCMPDataTypeLegal(TileDataType_U64);
    assert TCMPDataTypeLegal(TileDataType_U32);
    assert TCMPDataTypeLegal(TileDataType_U16);
    assert TCMPDataTypeLegal(TileDataType_U8);
    assert !TCMPDataTypeLegal(TileDataType_HiF8);
    assert !TCMPDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
