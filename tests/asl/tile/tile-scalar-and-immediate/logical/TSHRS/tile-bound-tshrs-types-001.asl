// PTO-TEST: {"id":"PTO-AVS-TILE-TSHRS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSHRS.asl","requirements":["PTO-INST-TILE-TSHRS"],"kind":"boundary","summary":"TSHRS exposes its closed integer DataType subset","pass_condition":"the two representative assigned integer types pass while an assigned out-of-subset type and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TSHRSDataTypeLegal(TileDataType_S8);
    assert TSHRSDataTypeLegal(TileDataType_U8);
    assert TSHRSDataTypeLegal(TileDataType_S32);
    assert TSHRSDataTypeLegal(TileDataType_U64);
    assert !TSHRSDataTypeLegal(TileDataType_FP32);
    assert !TSHRSDataTypeLegal(TileDataType_U4X2);
    return 0;
end;
