// PTO-TEST: {"id":"PTO-AVS-TILE-TSEL-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TSEL.asl","requirements":["PTO-TSEL-CONTRACT-001"],"kind":"boundary","summary":"TSEL accepts its exact sixteen numeric carrier types","pass_condition":"the eight floating and eight integer types pass while compact, exponent-only, and packed types reject","related_sources":["asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_E5M2);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_U8);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TSEL(TileDataType_U64);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_E2M3);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_S4X2);
    assert !InstructionContractDataTypeLegal_TSEL(TileDataType_U4X2);
    return 0;
end;
