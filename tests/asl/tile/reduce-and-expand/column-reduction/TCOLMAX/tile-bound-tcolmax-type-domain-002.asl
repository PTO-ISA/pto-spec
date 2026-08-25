// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLMAX-TYPE-DOMAIN-002","source":"asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl","requirements":["PTO-INST-TILE-TCOLMAX"],"kind":"boundary","summary":"TCOLMAX discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_E5M2);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TCOLMAX(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TCOLMAX(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TCOLMAX(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TCOLMAX(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TCOLMAX(TileDataType_U4X2);
    return 0;
end;
