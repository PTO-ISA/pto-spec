// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-TYPES-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT excludes private HiF4X2 while recognizing the assigned E6M2 and RCPE6M2 identities","pass_condition":"the TCVT contract rejects HiF4X2 and accepts the two newly assigned data type identities as contract-level types","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_HiF8);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E5M2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E3M2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E2M3);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E2M1X2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E1M2X2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TCVT(TileDataType_HiF4X2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_E6M2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_RCPE6M2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_S4X2);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_U4X2);
    return 0;
end;
