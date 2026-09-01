// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-CONVERSION-FP16-001","source":"asl/arch/profile/reference-conversion.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001","PTO-INST-SCALAR-FCVT"],"kind":"boundary","summary":"the common conversion profile converts FP32 carriers to FP16 across rounding and range boundaries","pass_condition":"exact, inexact, overflow, normal, subnormal, and underflow inputs produce the selected binary16 carrier and flags","related_sources":["asl/arch/profile/reference-quantization.asl","asl/scalar/fsu/FCVT.asl"]}
func main() => integer
begin
    let fp32_type = Zeros{5} + 1;
    let fp16_type = Zeros{5} + 2;

    let (zero, zero_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN});
    let (one, one_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3f800000);
    let (negative_two, negative_two_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0xc0000000);
    let (one_tenth, one_tenth_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3dcccccd);
    let (tie_even, tie_even_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3f801000);
    let (tie_away, tie_away_flags) = ScalarFPConvertProfile(
        NumericRound_RNA, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3f801000);
    let (tie_up, tie_up_flags) = ScalarFPConvertProfile(
        NumericRound_RTP, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3f801000);
    let (tie_down, tie_down_flags) = ScalarFPConvertProfile(
        NumericRound_RTM, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3f801000);
    let (tie_zero, tie_zero_flags) = ScalarFPConvertProfile(
        NumericRound_RTZ, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x3f801000);
    let (maximum, maximum_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x477fe000);
    let (overflow, overflow_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x47800000);
    let (minimum_normal, minimum_normal_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x38800000);
    let (minimum_subnormal, minimum_subnormal_flags) =
        ScalarFPConvertProfile(
            NumericRound_RNE, fp16_type, fp32_type,
            Zeros{PTO_XLEN} + 0x33800000);
    let (underflow_even, underflow_even_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x33000000);
    let (underflow_up, underflow_up_flags) = ScalarFPConvertProfile(
        NumericRound_RTP, fp16_type, fp32_type,
        Zeros{PTO_XLEN} + 0x33000000);

    assert zero == Zeros{PTO_XLEN};
    assert one == Zeros{PTO_XLEN} + 0x3c00;
    assert negative_two == Zeros{PTO_XLEN} + 0xc000;
    assert one_tenth == Zeros{PTO_XLEN} + 0x2e66;
    assert tie_even == Zeros{PTO_XLEN} + 0x3c00;
    assert tie_away == Zeros{PTO_XLEN} + 0x3c01;
    assert tie_up == Zeros{PTO_XLEN} + 0x3c01;
    assert tie_down == Zeros{PTO_XLEN} + 0x3c00;
    assert tie_zero == Zeros{PTO_XLEN} + 0x3c00;
    assert maximum == Zeros{PTO_XLEN} + 0x7bff;
    assert overflow == Zeros{PTO_XLEN} + 0x7c00;
    assert minimum_normal == Zeros{PTO_XLEN} + 0x0400;
    assert minimum_subnormal == Zeros{PTO_XLEN} + 0x0001;
    assert underflow_even == Zeros{PTO_XLEN};
    assert underflow_up == Zeros{PTO_XLEN} + 0x0001;

    assert zero_flags == Zeros{5};
    assert one_flags == Zeros{5};
    assert negative_two_flags == Zeros{5};
    assert one_tenth_flags == Zeros{5} + 0x10;
    assert tie_even_flags == Zeros{5} + 0x10;
    assert tie_away_flags == Zeros{5} + 0x10;
    assert tie_up_flags == Zeros{5} + 0x10;
    assert tie_down_flags == Zeros{5} + 0x10;
    assert tie_zero_flags == Zeros{5} + 0x10;
    assert maximum_flags == Zeros{5};
    assert overflow_flags == Zeros{5} + 0x14;
    assert minimum_normal_flags == Zeros{5};
    assert minimum_subnormal_flags == Zeros{5};
    assert underflow_even_flags == Zeros{5} + 0x18;
    assert underflow_up_flags == Zeros{5} + 0x18;
    return 0;
end;
