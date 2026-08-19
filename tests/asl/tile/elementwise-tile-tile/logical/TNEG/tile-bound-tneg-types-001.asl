// PTO-TEST: {"id":"PTO-AVS-TILE-TNEG-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TNEG.asl","requirements":["PTO-TNEG-CONTRACT-001"],"kind":"boundary","summary":"TNEG accepts exactly its arithmetic element types","pass_condition":"the sixteen accepted integer and floating types pass while HiF8 and packed S4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TNEG(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TNEG(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TNEG(TileDataType_S4X2);
    return 0;
end;
