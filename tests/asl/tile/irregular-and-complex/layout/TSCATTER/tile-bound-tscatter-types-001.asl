// PTO-TEST: {"id":"PTO-AVS-TILE-TSCATTER-TYPES-001","source":"asl/tile/irregular-and-complex/layout/TSCATTER.asl","requirements":["PTO-TSCATTER-CONTRACT-001"],"kind":"boundary","summary":"TSCATTER exposes its exact width-matched value and index DataType pairs.","pass_condition":"Accepted pairs are legal and width-mismatched or unsupported pairs are rejected.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_FP32, TileDataType_S32);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_BF16, TileDataType_U16);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8, TileDataType_S16);
    assert !InstructionContractTypePairLegal_TSCATTER(
        TileDataType_FP16, TileDataType_U32);
    assert !InstructionContractTypePairLegal_TSCATTER(
        TileDataType_FP64, TileDataType_S32);
    return 0;
end;
