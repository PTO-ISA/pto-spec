// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-INST-TILE-TMIN"],"kind":"boundary","summary":"TMIN accepts exactly its sixteen arithmetic element types","pass_condition":"the accepted floating and integer types pass while HiF8 and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TMINDataTypeLegal(TileDataType_FP32);
    assert TMINDataTypeLegal(TileDataType_FP64);
    assert TMINDataTypeLegal(TileDataType_TF32);
    assert TMINDataTypeLegal(TileDataType_HF32);
    assert TMINDataTypeLegal(TileDataType_FP16);
    assert TMINDataTypeLegal(TileDataType_BF16);
    assert TMINDataTypeLegal(TileDataType_E4M3);
    assert TMINDataTypeLegal(TileDataType_E5M2);
    assert TMINDataTypeLegal(TileDataType_S64);
    assert TMINDataTypeLegal(TileDataType_S32);
    assert TMINDataTypeLegal(TileDataType_S16);
    assert TMINDataTypeLegal(TileDataType_S8);
    assert TMINDataTypeLegal(TileDataType_U64);
    assert TMINDataTypeLegal(TileDataType_U32);
    assert TMINDataTypeLegal(TileDataType_U16);
    assert TMINDataTypeLegal(TileDataType_U8);
    assert !TMINDataTypeLegal(TileDataType_HiF8);
    assert !TMINDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
