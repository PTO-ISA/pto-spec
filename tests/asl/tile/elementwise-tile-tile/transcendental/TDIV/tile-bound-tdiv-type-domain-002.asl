// PTO-TEST: {"id":"PTO-AVS-TILE-TDIV-TYPE-DOMAIN-002","source":"asl/tile/elementwise-tile-tile/transcendental/TDIV.asl","requirements":["PTO-INST-TILE-TDIV"],"kind":"boundary","summary":"TDIV discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_E5M2);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TDIV(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TDIV(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TDIV(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TDIV(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TDIV(TileDataType_U4X2);
    return 0;
end;
