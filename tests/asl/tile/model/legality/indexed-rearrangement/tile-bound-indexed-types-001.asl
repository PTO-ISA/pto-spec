// PTO-TEST: {"id":"PTO-AVS-TILE-INDEXED-TYPES-001","source":"asl/tile/model/legality/indexed-rearrangement.asl","requirements":[],"kind":"boundary","summary":"Indexed rearrangement exposes independent non-packed data and index domains.","pass_condition":"Non-packed gather/scatter values accept cross-width indices while packed values and unsupported M-family index widths reject.","related_sources":["asl/tile/irregular-and-complex/layout/TGATHER.asl","asl/tile/irregular-and-complex/layout/TSCATTER.asl"]}

func main() => integer
begin
    assert InstructionContractValueDataTypeLegal_TGATHER(
        TileDataType_FP32);
    assert InstructionContractValueDataTypeLegal_TGATHER(
        TileDataType_U8);
    assert !InstructionContractValueDataTypeLegal_TGATHER(
        TileDataType_E2M1X2);
    assert InstructionContractIndexDataTypeLegal_TGATHER(
        TileDataType_S32);
    assert InstructionContractIndexDataTypeLegal_TGATHER(
        TileDataType_U16);
    assert InstructionContractIndexDataTypeLegal_TGATHER(
        TileDataType_U64);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8,
        TileDataType_S16);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8,
        TileDataType_U32);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8,
        TileDataType_S64);
    assert !InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8,
        TileDataType_S8);
    return 0;
end;
