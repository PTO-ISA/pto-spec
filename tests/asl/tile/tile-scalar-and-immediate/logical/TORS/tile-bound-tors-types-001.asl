// PTO-TEST: {"id":"PTO-AVS-TILE-TORS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/logical/TORS.asl","requirements":["PTO-INST-TILE-TORS"],"kind":"boundary","summary":"TORS exposes its closed integer DataType subset","pass_condition":"the two representative assigned integer types pass while an assigned out-of-subset type and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TORS(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TORS(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TORS(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TORS(TileDataType_U4X2);
    return 0;
end;
