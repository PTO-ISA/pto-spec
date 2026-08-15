// PTO-TEST: {"id":"PTO-AVS-TILE-TSQRT-TYPES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl","requirements":["PTO-INST-TILE-TSQRT"],"kind":"boundary","summary":"TSQRT accepts only the eight assigned floating element types","pass_condition":"FP64 through E5M2 pass while integer, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TSQRT(TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TSQRT(TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TSQRT(TileDataType_E5M2);
    assert !InstructionContractDataTypeLegal_TSQRT(TileDataType_U64);
    assert !InstructionContractDataTypeLegal_TSQRT(TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TSQRT(TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TSQRT(TileDataType_U4X2);
    return 0;
end;
