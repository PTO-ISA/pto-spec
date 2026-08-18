// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-E8M0-ROUND-003","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"boundary","summary":"E8M0 conversion applies every architectural rounding mode to the base-two exponent.","pass_condition":"BF16 1.5 and 0.75 select the required adjacent exponent for RNE, directed, away, odd, and greater-half modes, with NX.","related_sources":["asl/tile/model/numeric/formats.asl","asl/arch/data-types/rounding.asl"]}
func ConvertBF16ToE8M0(value: Word, mode: NumericRoundingMode) => Word
begin
    let control = NumericExecutionControl {
        rounding_mode = mode,
        saturating = FALSE
    };
    let (result, flags) = TileProfileConvert(
        value, TileDataType_BF16, TileDataType_E8M0, control);
    assert flags == Zeros{5} + 0x10;
    return result;
end;

func main() => integer
begin
    let one_point_five = Zeros{PTO_XLEN} + 0x3fc0;
    let rne = ConvertBF16ToE8M0(one_point_five, NumericRound_RNE);
    let rtm = ConvertBF16ToE8M0(one_point_five, NumericRound_RTM);
    let rtp = ConvertBF16ToE8M0(one_point_five, NumericRound_RTP);
    let rtz = ConvertBF16ToE8M0(one_point_five, NumericRound_RTZ);
    let rna = ConvertBF16ToE8M0(one_point_five, NumericRound_RNA);
    let rto = ConvertBF16ToE8M0(one_point_five, NumericRound_RTO);
    let rhb = ConvertBF16ToE8M0(one_point_five, NumericRound_RHB);
    assert rne == Zeros{PTO_XLEN} + 128;
    assert rtm == Zeros{PTO_XLEN} + 127;
    assert rtp == Zeros{PTO_XLEN} + 128;
    assert rtz == Zeros{PTO_XLEN} + 127;
    assert rna == Zeros{PTO_XLEN} + 128;
    assert rto == Zeros{PTO_XLEN} + 128;
    assert rhb == Zeros{PTO_XLEN} + 128;

    let zero_point_seven_five = Zeros{PTO_XLEN} + 0x3f40;
    let negative_rtm = ConvertBF16ToE8M0(
        zero_point_seven_five, NumericRound_RTM);
    let negative_rtp = ConvertBF16ToE8M0(
        zero_point_seven_five, NumericRound_RTP);
    let negative_rtz = ConvertBF16ToE8M0(
        zero_point_seven_five, NumericRound_RTZ);
    assert negative_rtm == Zeros{PTO_XLEN} + 126;
    assert negative_rtp == Zeros{PTO_XLEN} + 127;
    assert negative_rtz == Zeros{PTO_XLEN} + 127;
    return 0;
end;
