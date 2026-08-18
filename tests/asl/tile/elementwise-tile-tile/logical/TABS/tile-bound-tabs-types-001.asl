// PTO-TEST: {"id":"PTO-AVS-TILE-TABS-TYPES-001","source":"asl/tile/elementwise-tile-tile/logical/TABS.asl","requirements":["PTO-TABS-CONTRACT-001"],"kind":"boundary","summary":"TABS accepts exactly its arithmetic element types","pass_condition":"the sixteen accepted integer and floating types pass while HiF8 and packed U4X2 reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TABS(TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TABS(TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_S32);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_U8);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_HiF8);
    assert !InstructionContractDataTypeLegal_TABS(TileDataType_U4X2);
    return 0;
end;
