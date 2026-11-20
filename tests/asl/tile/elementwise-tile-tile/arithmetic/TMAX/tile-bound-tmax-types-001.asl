// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"boundary","summary":"TMAX accepts exactly its sixteen arithmetic element types","pass_condition":"the accepted floating and integer types pass while HiF8 and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TMAXDataTypeLegal(TileDataType_FP32);
    assert TMAXDataTypeLegal(TileDataType_FP64);
    assert TMAXDataTypeLegal(TileDataType_TF32);
    assert TMAXDataTypeLegal(TileDataType_HF32);
    assert TMAXDataTypeLegal(TileDataType_FP16);
    assert TMAXDataTypeLegal(TileDataType_BF16);
    assert TMAXDataTypeLegal(TileDataType_E4M3);
    assert TMAXDataTypeLegal(TileDataType_E5M2);
    assert TMAXDataTypeLegal(TileDataType_S64);
    assert TMAXDataTypeLegal(TileDataType_S32);
    assert TMAXDataTypeLegal(TileDataType_S16);
    assert TMAXDataTypeLegal(TileDataType_S8);
    assert TMAXDataTypeLegal(TileDataType_U64);
    assert TMAXDataTypeLegal(TileDataType_U32);
    assert TMAXDataTypeLegal(TileDataType_U16);
    assert TMAXDataTypeLegal(TileDataType_U8);
    assert !TMAXDataTypeLegal(TileDataType_HiF8);
    assert !TMAXDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
