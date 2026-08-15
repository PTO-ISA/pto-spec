// PTO-TEST: {"id":"PTO-AVS-TILE-TSHLS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSHLS.asl","requirements":["PTO-INST-TILE-TSHLS"],"kind":"boundary","summary":"TSHLS exposes its closed integer DataType subset","pass_condition":"the two representative assigned integer types pass while an assigned out-of-subset type and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TSHLS(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TSHLS(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TSHLS(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TSHLS(TileDataType_U4X2);
    return 0;
end;
