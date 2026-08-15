// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-TYPES-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP"],"kind":"boundary","summary":"TEXP accepts only the eight assigned floating element types","pass_condition":"FP64 through E5M2 pass while integer, exponent-only, compact, and packed types reject","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    assert InstructionContractDataTypeLegal_TEXP(
        TileDataType_FP64);
    assert InstructionContractDataTypeLegal_TEXP(
        TileDataType_E4M3);
    assert InstructionContractDataTypeLegal_TEXP(
        TileDataType_E5M2);
    assert !InstructionContractDataTypeLegal_TEXP(
        TileDataType_U64);
    assert !InstructionContractDataTypeLegal_TEXP(
        TileDataType_E8M0);
    assert !InstructionContractDataTypeLegal_TEXP(
        TileDataType_E3M2);
    assert !InstructionContractDataTypeLegal_TEXP(
        TileDataType_U4X2);
    return 0;
end;
