// PTO-TEST: {"id":"PTO-AVS-TILE-TSHL-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TSHL.asl","requirements":["PTO-INST-TILE-TSHL"],"kind":"boundary","summary":"TSHL accepts only the eight scalar integer Tile types","pass_condition":"S16 and U32 pass while FP16 and U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TSHL(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TSHL(TileDataType_U32);
    assert !InstructionContractDataTypeLegal_TSHL(TileDataType_FP16);
    assert !InstructionContractDataTypeLegal_TSHL(TileDataType_U4X2);
    return 0;
end;
