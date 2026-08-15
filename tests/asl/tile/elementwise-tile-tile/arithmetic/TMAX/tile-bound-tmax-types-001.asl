// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-TYPES-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"boundary","summary":"TMAX accepts exactly its sixteen arithmetic element types","pass_condition":"the accepted floating and integer types pass while HiF8 and packed U4X2 reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_TF32);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_HF32);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_E5M2);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_S64);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_S16);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_S8);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_U32);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_U16);
    assert InstructionContractDataTypeLegal_TMAX(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TMAX(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TMAX(TileDataType_U4X2);
    return 0;
end;
