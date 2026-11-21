// PTO-TEST: {"id":"PTO-AVS-TILE-TXOR-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TXOR.asl","requirements":["PTO-INST-TILE-TXOR"],"kind":"boundary","summary":"TXOR accepts only the eight scalar integer Tile types","pass_condition":"S32 and U16 pass while E4M3 and HiF4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert TXORDataTypeLegal(TileDataType_S32);
    assert TXORDataTypeLegal(TileDataType_U16);
    assert !TXORDataTypeLegal(TileDataType_E4M3);
    assert !TXORDataTypeLegal(TileDataType_HiF4X2);
    return 0;
end;
