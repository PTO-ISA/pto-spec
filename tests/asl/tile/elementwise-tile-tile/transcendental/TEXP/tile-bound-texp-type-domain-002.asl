// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-TYPE-DOMAIN-002","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP"],"kind":"boundary","summary":"TEXP discriminates its complete executable helper DataType domain","pass_condition":"all eight floating helper types pass and representative integer, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TEXP(TileDataType_E5M2);
    assert !InstructionContractDataTypeLegal_TEXP(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TEXP(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TEXP(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TEXP(TileDataType_U4X2);
    return 0;
end;
