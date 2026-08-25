// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-TYPE-DOMAIN-002","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-INST-TILE-TABS"],"kind":"boundary","summary":"TABS discriminates its complete executable helper DataType domain","pass_condition":"all sixteen TileVecArithmetic types pass and representative non-domain carrier, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TABS(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_E5M2);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_U4X2);
    return 0;
end;
