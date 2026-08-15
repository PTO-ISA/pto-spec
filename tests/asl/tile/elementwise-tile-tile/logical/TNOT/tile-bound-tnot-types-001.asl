// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"boundary","summary":"TNOT accepts exactly the eight scalar integer Tile types","pass_condition":"the signed and unsigned 8 16 32 and 64 bit types pass while FP32 and packed U4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TNOT(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TNOT(TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TNOT(TileDataType_U4X2);
    return 0;
end;
