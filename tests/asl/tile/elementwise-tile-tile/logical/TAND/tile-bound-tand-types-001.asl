// PTO-TEST: {"id":"PTO-AVS-TILE-TAND-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TAND.asl","requirements":["PTO-INST-TILE-TAND"],"kind":"boundary","summary":"TAND accepts only the eight scalar integer Tile types","pass_condition":"S64 and U8 pass while FP32 and U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TAND(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TAND(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TAND(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TAND(TileDataType_U4X2);
    return 0;
end;
