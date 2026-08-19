// PTO-TEST: {"id":"PTO-AVS-ARCH-MATRIX-INTERMEDIATE-002","source":"asl/arch/profile/matrix-quantization.asl","requirements":["PTO-MATRIX-QUANT-BITEXACT-001"],"kind":"execution","summary":"Matrix quantization rounds and saturates at assigned signed intermediate widths","pass_condition":"S5 S9 S17 and shifted S16 boundaries return exact values and numeric flags","related_sources":["asl/arch/profile/matrix-postprocess.asl"]}
func main() => integer
begin
    let (s5_maximum, s5_maximum_flags) =
        MatrixRoundAndSaturateSigned(15.0, 5, NumericRound_RNE);
    assert s5_maximum == 15;
    assert s5_maximum_flags == Zeros{5};

    let (s5_high, s5_high_flags) =
        MatrixRoundAndSaturateSigned(15.5, 5, NumericRound_RNE);
    assert s5_high == 15;
    assert s5_high_flags == Zeros{5} + 0x14;

    let (s5_low, s5_low_flags) =
        MatrixRoundAndSaturateSigned(-16.5, 5, NumericRound_RNA);
    assert s5_low == -16;
    assert s5_low_flags == Zeros{5} + 0x14;

    let (s9_high, s9_high_flags) =
        MatrixRoundAndSaturateSigned(255.75, 9, NumericRound_RNE);
    assert s9_high == 255;
    assert s9_high_flags == Zeros{5} + 0x14;

    let (s9_low, s9_low_flags) =
        MatrixRoundAndSaturateSigned(-256.75, 9, NumericRound_RNE);
    assert s9_low == -256;
    assert s9_low_flags == Zeros{5} + 0x14;

    let (s17_inexact, s17_inexact_flags) =
        MatrixRoundAndSaturateSigned(65535.4, 17, NumericRound_RTZ);
    assert s17_inexact == 65535;
    assert s17_inexact_flags == Zeros{5} + 0x10;

    let (rne_tie, -) =
        MatrixRoundAndSaturateSigned(0.5, 9, NumericRound_RNE);
    let (rna_tie, -) =
        MatrixRoundAndSaturateSigned(0.5, 9, NumericRound_RNA);
    let (rtp_tie, -) =
        MatrixRoundAndSaturateSigned(0.5, 9, NumericRound_RTP);
    let (rtm_tie, -) =
        MatrixRoundAndSaturateSigned(0.5, 9, NumericRound_RTM);
    let (rtz_tie, -) =
        MatrixRoundAndSaturateSigned(0.5, 9, NumericRound_RTZ);
    assert rne_tie == 0;
    assert rna_tie == 1;
    assert rtp_tie == 1;
    assert rtm_tie == 0;
    assert rtz_tie == 0;

    let (negative_rne_tie, -) =
        MatrixRoundAndSaturateSigned(-0.5, 9, NumericRound_RNE);
    let (negative_rna_tie, -) =
        MatrixRoundAndSaturateSigned(-0.5, 9, NumericRound_RNA);
    let (negative_rtp_tie, -) =
        MatrixRoundAndSaturateSigned(-0.5, 9, NumericRound_RTP);
    let (negative_rtm_tie, -) =
        MatrixRoundAndSaturateSigned(-0.5, 9, NumericRound_RTM);
    let (negative_rtz_tie, -) =
        MatrixRoundAndSaturateSigned(-0.5, 9, NumericRound_RTZ);
    assert negative_rne_tie == 0;
    assert negative_rna_tie == -1;
    assert negative_rtp_tie == 0;
    assert negative_rtm_tie == -1;
    assert negative_rtz_tie == 0;

    let (shifted_negative, shifted_negative_flags) =
        MatrixShiftS32ToS16('11111111111111111111111111011111', 1);
    assert shifted_negative == Zeros{PTO_XLEN} + 0xffffffffffffffef;
    assert shifted_negative_flags == Zeros{5};

    let (shifted_high, shifted_high_flags) =
        MatrixShiftS32ToS16('01111111111111111111111111111111', 1);
    assert shifted_high == Zeros{PTO_XLEN} + 0x7fff;
    assert shifted_high_flags == Zeros{5} + 0x14;
    return 0;
end;
