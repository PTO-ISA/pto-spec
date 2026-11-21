// PTO-TEST: {"id":"PTO-AVS-TILE-TSHR-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TSHR.asl","requirements":["PTO-INST-TILE-TSHR"],"kind":"boundary","summary":"TSHR accepts only the eight scalar integer Tile types","pass_condition":"S32 and U64 pass while BF16 and S4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TSHRDataTypeLegal(TileDataType_S32);
    assert TSHRDataTypeLegal(TileDataType_U32);
    assert TSHRDataTypeLegal(TileDataType_S8);
    assert TSHRDataTypeLegal(TileDataType_U8);
    assert TSHRDataTypeLegal(TileDataType_U64);
    assert !TSHRDataTypeLegal(TileDataType_BF16);
    assert !TSHRDataTypeLegal(TileDataType_S4X2);
    return 0;
end;
