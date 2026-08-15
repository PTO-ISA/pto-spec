// PTO-TEST: {"id":"PTO-AVS-TILE-TGATHER-TYPES-001","source":"asl/tile/irregular-and-complex/layout/TGATHER.asl","requirements":["PTO-TGATHER-CONTRACT-001"],"kind":"boundary","summary":"TGATHER exposes its exact value and index DataType domains.","pass_condition":"Only the accepted value types and S32/U32 row-index types are reported legal.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_FP32);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_FP16);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_S32);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_U16);
    assert !InstructionContractValueDataTypeLegal_TGATHER(TileDataType_BF16);
    assert !InstructionContractValueDataTypeLegal_TGATHER(TileDataType_U8);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_S32);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_U32);
    assert !InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_U16);
    return 0;
end;
