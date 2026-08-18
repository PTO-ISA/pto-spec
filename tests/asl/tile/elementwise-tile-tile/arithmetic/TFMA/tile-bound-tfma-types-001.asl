// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"boundary","summary":"TFMA accepts exactly its sixteen fused arithmetic element types.","pass_condition":"The sixteen accepted integer and floating types pass while HiF8 and packed U4X2 reject.","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TFMA(TileDataType_U16);
    assert !InstructionContractDataTypeLegal_TFMA(TileDataType_S8);
    assert !InstructionContractDataTypeLegal_TFMA(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TFMA(TileDataType_FP64);
    return 0;
end;
