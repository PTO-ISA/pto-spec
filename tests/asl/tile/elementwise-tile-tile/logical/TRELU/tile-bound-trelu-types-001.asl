// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"boundary","summary":"TRELU accepts exactly its seven arithmetic element types","pass_condition":"representative accepted 64-bit, 32-bit, and floating types pass while S16, E8M0, and packed S4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TRELU(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TRELU(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TRELU(TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TRELU(TileDataType_S32);
    assert InstructionContractDataTypeLegal_TRELU(TileDataType_U64);
    assert InstructionContractDataTypeLegal_TRELU(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TRELU(TileDataType_S16);
    assert !InstructionContractDataTypeLegal_TRELU(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TRELU(TileDataType_S4X2);
    return 0;
end;
