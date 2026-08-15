// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT distinguishes omitted destination type and rounding controls from explicitly encoded zero","pass_condition":"omitted or DTYPE_NONE destination type inherits while encoded zero selects FP64; float-to-integer defaults RTZ and other rounded conversions default RNE","related_sources":["asl/block/model/dispatch/numeric-control.asl","asl/block/model/dispatch/descriptor-legality.asl"]}
func main() => integer
begin
    assert InstructionContractDestinationDataType_TCVT(
        TileDataType_U8,
        FALSE,
        Zeros{5}) == TileDataType_U8;
    assert InstructionContractDestinationDataType_TCVT(
        TileDataType_U8,
        TRUE,
        DTYPE_NONE) == TileDataType_U8;
    assert InstructionContractDestinationDataType_TCVT(
        TileDataType_U8,
        TRUE,
        Zeros{5}) == TileDataType_FP64;
    assert InstructionContractDefaultRounding_TCVT(
        TileDataType_FP32,
        TileDataType_S32) == NumericRound_RTZ;
    assert InstructionContractDefaultRounding_TCVT(
        TileDataType_FP32,
        TileDataType_FP16) == NumericRound_RNE;
    assert InstructionContractDefaultRounding_TCVT(
        TileDataType_S32,
        TileDataType_U8) == NumericRound_RNE;
    return 0;
end;
