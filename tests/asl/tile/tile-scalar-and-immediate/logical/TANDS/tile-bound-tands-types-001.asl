// PTO-TEST: {"id":"PTO-AVS-TILE-TANDS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/logical/TANDS.asl","requirements":["PTO-INST-TILE-TANDS"],"kind":"boundary","summary":"TANDS exposes its closed integer DataType subset","pass_condition":"the two representative assigned integer types pass while an assigned out-of-subset type and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TANDS(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TANDS(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TANDS(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TANDS(TileDataType_U4X2);
    return 0;
end;
