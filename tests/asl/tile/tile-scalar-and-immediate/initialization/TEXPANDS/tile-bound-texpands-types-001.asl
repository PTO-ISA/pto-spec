// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPANDS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl","requirements":["PTO-INST-TILE-TEXPANDS"],"kind":"boundary","summary":"TEXPANDS exposes its closed numeric DataType subset","pass_condition":"the two representative assigned numeric types pass while an assigned out-of-subset type and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TEXPANDSDataTypeLegal(TileDataType_FP32);
    assert TEXPANDSDataTypeLegal(TileDataType_U8);
    assert !TEXPANDSDataTypeLegal(TileDataType_HiF8);
    assert !TEXPANDSDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
