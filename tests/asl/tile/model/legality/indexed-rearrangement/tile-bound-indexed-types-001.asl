// PTO-TEST: {"id":"PTO-AVS-TILE-INDEXED-TYPES-001","source":"asl/tile/model/legality/indexed-rearrangement.asl","requirements":[],"kind":"boundary","summary":"Indexed rearrangement exposes the accepted gather and scatter DataType domains.","pass_condition":"Accepted type combinations return true and unsupported combinations return false.","related_sources":["asl/tile/irregular-and-complex/layout/TGATHER.asl","asl/tile/irregular-and-complex/layout/TSCATTER.asl"]}

func main() => integer
begin
    assert InstructionContractValueDataTypeLegal_TGATHER(
        TileDataType_FP32);
    assert InstructionContractIndexDataTypeLegal_TGATHER(
        TileDataType_S32);
    assert !InstructionContractIndexDataTypeLegal_TGATHER(
        TileDataType_U16);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8,
        TileDataType_S16);
    assert !InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8,
        TileDataType_U32);
    return 0;
end;
