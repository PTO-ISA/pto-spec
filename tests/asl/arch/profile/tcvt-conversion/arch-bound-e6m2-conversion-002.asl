// PTO-TEST: {"id":"PTO-AVS-ARCH-E6M2-CONVERSION-BOUNDARIES-002","source":"asl/arch/profile/tcvt-conversion.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-NUMERIC-E6M2-FORMAT-001"],"kind":"boundary","summary":"E6M2 TCVT covers the complete finite code range and mixed FP16/BF16 boundary policy","pass_condition":"All E6M2 finite codes are positive and ordered, endpoint/NaN identities round-trip, FP16/BF16 special and overflow rules return exact carriers and flags, and RNE/RNA midpoint choices differ as specified","related_sources":["asl/arch/data-types/formats/e6m2.asl","asl/arch/profile/matrix-quantization.asl"]}
func AssertE6M2FiniteRange()
begin
    assert E6M2FiniteValue(Zeros{8}) == FP19PowerOfTwo(-48);
    assert E6M2FiniteValue(Zeros{8} + 0xfe) == 49152.0;
    assert TileNumericValueClass(TileDataType_E6M2,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;
    var prior = -1.0;
    for code = 0 to 254 looplimit 255 do
        let raw = (Zeros{8} + code) as bits(8);
        assert TileNumericValueClass(TileDataType_E6M2,
            Zeros{PTO_XLEN} + code) == NumericValue_PositiveNormal;
        let value = E6M2FiniteValue(raw);
        assert value > prior;
        let (available, negative, significand, exponent) =
            E6M2FiniteDecomposition(raw);
        assert available && !negative;
        assert significand != Zeros{PTO_XLEN};
        prior = value;
    end;
    let (unavailable, -, -, -) = E6M2FiniteDecomposition(
        Ones{8});
    assert !unavailable;
end;

func ConvertFromBF16(value: Word, mode: NumericRoundingMode,
                    saturating: boolean) => (Word, bits(5))
begin
    let control = NumericExecutionControl {
        rounding_mode = mode, saturating = saturating
    };
    return TileProfileConvert(value, TileDataType_BF16,
        TileDataType_E6M2, control);
end;

func ConvertFromFP16(value: Word, mode: NumericRoundingMode,
                    saturating: boolean) => (Word, bits(5))
begin
    let control = NumericExecutionControl {
        rounding_mode = mode, saturating = saturating
    };
    return TileProfileConvert(value, TileDataType_FP16,
        TileDataType_E6M2, control);
end;

func ConvertE6To(destination_type: TileDataType, raw: integer {0..255},
                 mode: NumericRoundingMode, saturating: boolean)
                 => (Word, bits(5))
begin
    let control = NumericExecutionControl {
        rounding_mode = mode, saturating = saturating
    };
    return TileProfileConvert(Zeros{PTO_XLEN} + raw,
        TileDataType_E6M2, destination_type, control);
end;

func AssertE6M2ForwardPolicy()
begin
    let (zero, zero_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN}, NumericRound_RNE, FALSE);
    let (negative_zero, negative_zero_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN} + 0x8000, NumericRound_RNE, FALSE);
    assert zero == Zeros{PTO_XLEN} &&
           zero_flags == Zeros{5} + 0x18;
    assert negative_zero == Zeros{PTO_XLEN} &&
           negative_zero_flags == Zeros{5} + 0x18;

    let (exact, exact_flags) = ConvertFromFP16(
        Zeros{PTO_XLEN} + 0x3d00, NumericRound_RNE, FALSE);
    assert exact == Zeros{PTO_XLEN} + 0xc1 &&
           exact_flags == Zeros{5};

    let (negative_finite, negative_finite_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN} + 0xbf80, NumericRound_RNE, FALSE);
    let (negative_inf, negative_inf_flags) = ConvertFromFP16(
        Zeros{PTO_XLEN} + 0xfc00, NumericRound_RNE, FALSE);
    assert negative_finite == Zeros{PTO_XLEN} + 0xff &&
           negative_finite_flags == Zeros{5} + 1;
    assert negative_inf == Zeros{PTO_XLEN} + 0xff &&
           negative_inf_flags == Zeros{5} + 1;

    let (qnan, qnan_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN} + 0x7fc0, NumericRound_RNE, FALSE);
    let (snan, snan_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN} + 0x7f81, NumericRound_RNE, FALSE);
    assert qnan == Zeros{PTO_XLEN} + 0xff && qnan_flags == Zeros{5};
    assert snan == Zeros{PTO_XLEN} + 0xff &&
           snan_flags == Zeros{5} + 1;

    let (positive_inf, positive_inf_flags) = ConvertFromFP16(
        Zeros{PTO_XLEN} + 0x7c00, NumericRound_RNE, FALSE);
    let (positive_inf_sat, positive_inf_sat_flags) = ConvertFromFP16(
        Zeros{PTO_XLEN} + 0x7c00, NumericRound_RNE, TRUE);
    assert positive_inf == Zeros{PTO_XLEN} + 0xff &&
           positive_inf_flags == Zeros{5} + 0x14;
    assert positive_inf_sat == Zeros{PTO_XLEN} + 0xfe &&
           positive_inf_sat_flags == Zeros{5} + 0x14;

    let (finite_over, finite_over_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN} + 0x4780, NumericRound_RNE, FALSE);
    let (finite_over_sat, finite_over_sat_flags) = ConvertFromBF16(
        Zeros{PTO_XLEN} + 0x4780, NumericRound_RNE, TRUE);
    assert finite_over == Zeros{PTO_XLEN} + 0xff &&
           finite_over_flags == Zeros{5} + 0x14;
    assert finite_over_sat == Zeros{PTO_XLEN} + 0xfe &&
           finite_over_sat_flags == Zeros{5} + 0x14;

    let midpoint = Zeros{PTO_XLEN} + 0x3f90;
    let (rne, rne_flags) = ConvertFromBF16(
        midpoint, NumericRound_RNE, FALSE);
    let (rna, rna_flags) = ConvertFromBF16(
        midpoint, NumericRound_RNA, FALSE);
    assert rne == Zeros{PTO_XLEN} + 0xc0 &&
           rna == Zeros{PTO_XLEN} + 0xc1;
    assert rne_flags == Zeros{5} + 0x10 &&
           rna_flags == Zeros{5} + 0x10;
end;

func AssertE6M2ReversePolicy()
begin
    let (bf16_zero, bf16_zero_flags) = ConvertE6To(
        TileDataType_BF16, 0, NumericRound_RNE, FALSE);
    let (bf16_one, bf16_one_flags) = ConvertE6To(
        TileDataType_BF16, 0xc0, NumericRound_RNE, FALSE);
    let (bf16_max, bf16_max_flags) = ConvertE6To(
        TileDataType_BF16, 0xfe, NumericRound_RNE, FALSE);
    assert bf16_zero == Zeros{PTO_XLEN} + 0x2780 &&
           bf16_one == Zeros{PTO_XLEN} + 0x3f80 &&
           bf16_max == Zeros{PTO_XLEN} + 0x4740;
    assert bf16_zero_flags == Zeros{5} &&
           bf16_one_flags == Zeros{5} &&
           bf16_max_flags == Zeros{5};

    let (fp16_zero, fp16_zero_flags) = ConvertE6To(
        TileDataType_FP16, 0, NumericRound_RNE, FALSE);
    let (fp16_subnormal, fp16_subnormal_flags) = ConvertE6To(
        TileDataType_FP16, 0x80, NumericRound_RNE, FALSE);
    let (fp16_underflow, fp16_underflow_flags) = ConvertE6To(
        TileDataType_FP16, 0, NumericRound_RNE, FALSE);
    let (fp16_max, fp16_max_flags) = ConvertE6To(
        TileDataType_FP16, 0xfe, NumericRound_RNE, FALSE);
    let (fp16_max_sat, fp16_max_sat_flags) = ConvertE6To(
        TileDataType_FP16, 0xfe, NumericRound_RNE, TRUE);
    assert fp16_zero == Zeros{PTO_XLEN} &&
           fp16_underflow == Zeros{PTO_XLEN};
    assert fp16_zero_flags == Zeros{5} + 0x18 &&
           fp16_underflow_flags == Zeros{5} + 0x18;
    assert fp16_subnormal == Zeros{PTO_XLEN} + 0x100 &&
           fp16_subnormal_flags == Zeros{5};
    assert fp16_max == Zeros{PTO_XLEN} + 0x7a00 &&
           fp16_max_flags == Zeros{5};
    assert fp16_max_sat == Zeros{PTO_XLEN} + 0x7a00 &&
           fp16_max_sat_flags == Zeros{5};

    let (canonical, canonical_flags) = ConvertE6To(
        TileDataType_FP16, 0xff, NumericRound_RNE, FALSE);
    assert canonical == Zeros{PTO_XLEN} + 0x7e00 &&
           canonical_flags == Zeros{5};
end;

func main() => integer
begin
    AssertE6M2FiniteRange();
    AssertE6M2ForwardPolicy();
    AssertE6M2ReversePolicy();
    return 0;
end;
