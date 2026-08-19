// PTO-TEST: {"id":"PTO-AVS-TILE-TREMS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TREMS.asl","requirements":["PTO-INST-TILE-TREMS"],"kind":"boundary","summary":"TREMS exposes its closed numeric DataType subset","pass_condition":"the two representative assigned numeric types pass while an assigned out-of-subset type and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TREMS(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TREMS(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TREMS(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TREMS(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TREMS(TileDataType_U4X2);
    return 0;
end;
