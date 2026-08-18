// PTO-TEST: {"id":"PTO-AVS-TILE-TGATHER-TYPES-001","source":"asl/tile/irregular-and-complex/layout/TGATHER.asl","requirements":["PTO-TGATHER-CONTRACT-001"],"kind":"boundary","summary":"TGATHER exposes its non-packed value and independent six-type index domains.","pass_condition":"All non-packed value types and S16/U16/S32/U32/S64/U64 row-index types are legal while packed value and index types remain rejected.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_FP32);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_FP16);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_BF16);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_S8);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_U64);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_S32);
    assert InstructionContractValueDataTypeLegal_TGATHER(TileDataType_U16);
    assert !InstructionContractValueDataTypeLegal_TGATHER(TileDataType_E2M1X2);
    assert !InstructionContractValueDataTypeLegal_TGATHER(TileDataType_U4X2);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_S16);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_U16);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_S32);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_U32);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_S64);
    assert InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_U64);
    assert !InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_S8);
    assert !InstructionContractIndexDataTypeLegal_TGATHER(TileDataType_E2M1X2);
    return 0;
end;
