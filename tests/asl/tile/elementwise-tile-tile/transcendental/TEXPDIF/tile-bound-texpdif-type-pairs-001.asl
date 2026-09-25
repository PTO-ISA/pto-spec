// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-TYPE-PAIRS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"boundary","summary":"TEXPDIF accepts exactly the five frozen source-operation and destination type pairs","pass_condition":"all five specified pairs pass and representative reverse, packed, integer, and FP64 pairs reject","related_sources":["asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    assert InstructionContractOperation_TEXPDIF() == TileOperation_TEXPDIF;
    assert InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP16, TileDataType_FP16);
    assert InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_BF16, TileDataType_BF16);
    assert InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP32, TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP16, TileDataType_FP32);
    assert InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_BF16, TileDataType_FP32);
    assert !InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP32, TileDataType_FP16);
    assert !InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP64, TileDataType_FP64);
    assert !InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP16, TileDataType_BF16);
    assert !InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_S16, TileDataType_FP16);
    assert !InstructionContractDataTypeLegal_TEXPDIF(
        TileDataType_FP16, TileDataType_E2M1X2);
    return 0;
end;
