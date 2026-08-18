// PTO-TEST: {"id":"PTO-AVS-TILE-TSCATTER-TYPES-001","source":"asl/tile/irregular-and-complex/layout/TSCATTER.asl","requirements":["PTO-TSCATTER-CONTRACT-001"],"kind":"boundary","summary":"TSCATTER exposes independent non-packed value and index domains.","pass_condition":"Representative cross-width non-packed pairs are legal for all six index types while packed values remain rejected.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl"]}

func main() => integer
begin
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_FP32, TileDataType_S32);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8, TileDataType_U64);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_BF16, TileDataType_U16);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8, TileDataType_S16);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_FP16, TileDataType_U32);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_FP64, TileDataType_S32);
    assert InstructionContractTypePairLegal_TSCATTER(
        TileDataType_S64, TileDataType_S64);
    assert !InstructionContractTypePairLegal_TSCATTER(
        TileDataType_E2M1X2, TileDataType_S32);
    assert !InstructionContractTypePairLegal_TSCATTER(
        TileDataType_U8, TileDataType_S8);
    return 0;
end;
