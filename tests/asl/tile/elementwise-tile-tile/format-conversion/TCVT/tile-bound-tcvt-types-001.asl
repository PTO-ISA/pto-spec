// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-TYPES-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT accepts every assigned Tile DataType including its private HiF4X2 format","pass_condition":"all twenty-five assigned Tile DataTypes are accepted as TCVT sources and destinations","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
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
    assert InstructionContractDataTypeLegal_TCVT(TileDataType_HiF4X2);
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
