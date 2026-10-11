// PTO-TEST: {"id":"PTO-AVS-SCALAR-FP-IEEE-ADD-SUB-SIGNED-ZERO-015","source":"asl/scalar/model/fsu/scalar-fp.asl","requirements":["PTO-INST-SCALAR-FADD","PTO-INST-SCALAR-FSUB"],"kind":"execution","summary":"floating addition and subtraction select the IEEE-754 zero sign from effective operand signs and the active rounding mode","pass_condition":"FP32 equal-sign zeros preserve their sign, opposite-sign cancellation selects positive zero under RNE and negative zero under RTM, and exact-zero results set no flags","related_sources":["asl/scalar/model/fsu/reference-quantization.asl"]}
func main() => integer
begin
    let fp32 = Zeros{5} + 1;
    let positive_zero = Zeros{PTO_XLEN};
    let negative_zero = Zeros{PTO_XLEN} + 0x80000000;
    let positive_one = Zeros{PTO_XLEN} + 0x3f800000;
    let negative_one = Zeros{PTO_XLEN} + 0xbf800000;

    let (negative_zero_sum, negative_zero_sum_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, fp32,
        negative_zero, negative_zero);
    let (mixed_zero_sum, mixed_zero_sum_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, fp32,
        negative_zero, positive_zero);
    let (negative_zero_difference, negative_zero_difference_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_SUB, NumericRound_RNE, fp32,
            negative_zero, positive_zero);
    let (positive_zero_difference, positive_zero_difference_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_SUB, NumericRound_RNE, fp32,
            positive_zero, negative_zero);
    assert negative_zero_sum == negative_zero;
    assert mixed_zero_sum == positive_zero;
    assert negative_zero_difference == negative_zero;
    assert positive_zero_difference == positive_zero;
    assert negative_zero_sum_flags == Zeros{5};
    assert mixed_zero_sum_flags == Zeros{5};
    assert negative_zero_difference_flags == Zeros{5};
    assert positive_zero_difference_flags == Zeros{5};

    let (cancel_rne, cancel_rne_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, fp32,
        positive_one, negative_one);
    let (cancel_rtm, cancel_rtm_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RTM, fp32,
        positive_one, negative_one);
    let (same_rne, same_rne_flags) = ScalarFPBinaryProfile(
        FloatingBinary_SUB, NumericRound_RNE, fp32,
        positive_one, positive_one);
    let (same_rtm, same_rtm_flags) = ScalarFPBinaryProfile(
        FloatingBinary_SUB, NumericRound_RTM, fp32,
        positive_one, positive_one);
    assert cancel_rne == positive_zero;
    assert cancel_rtm == negative_zero;
    assert same_rne == positive_zero;
    assert same_rtm == negative_zero;
    assert cancel_rne_flags == Zeros{5};
    assert cancel_rtm_flags == Zeros{5};
    assert same_rne_flags == Zeros{5};
    assert same_rtm_flags == Zeros{5};

    let (fp64_negative_zero, fp64_negative_zero_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_ADD, NumericRound_RNE, Zeros{5},
            Zeros{PTO_XLEN} + 0x8000000000000000,
            Zeros{PTO_XLEN} + 0x8000000000000000);
    let (fp16_negative_zero, fp16_negative_zero_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_ADD, NumericRound_RNE, Zeros{5} + 4,
            Zeros{PTO_XLEN} + 0x8000,
            Zeros{PTO_XLEN} + 0x8000);
    let (bf16_negative_zero, bf16_negative_zero_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_ADD, NumericRound_RNE, Zeros{5} + 5,
            Zeros{PTO_XLEN} + 0x8000,
            Zeros{PTO_XLEN} + 0x8000);
    assert fp64_negative_zero ==
        Zeros{PTO_XLEN} + 0x8000000000000000;
    assert fp16_negative_zero == Zeros{PTO_XLEN} + 0x8000;
    assert bf16_negative_zero == Zeros{PTO_XLEN} + 0x8000;
    assert fp64_negative_zero_flags == Zeros{5};
    assert fp16_negative_zero_flags == Zeros{5};
    assert bf16_negative_zero_flags == Zeros{5};
    return 0;
end;
