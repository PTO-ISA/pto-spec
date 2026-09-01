// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-QUANTIZATION-SPECIAL-BINARY-002","source":"asl/arch/profile/reference-quantization.asl","requirements":[],"kind":"execution","summary":"the reference scalar FP binary profile closes IEEE infinity, NaN, signed-zero, and divide-by-zero inputs","pass_condition":"FP32 and FP64 special-value results and NV/DZ flags match the Linx IEEE-754 contract","related_sources":["asl/arch/profile/reference-profile.asl","asl/scalar/model/fsu/profile.asl"]}
func main() => integer
begin
    let fp32 = Zeros{5} + 1;
    let fp64 = Zeros{5};

    let (fp32_infinite_product, fp32_infinite_product_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_MUL, NumericRound_RNE, fp32,
            Zeros{PTO_XLEN} + 0x7f800000,
            Zeros{PTO_XLEN} + 0x40000000);
    assert fp32_infinite_product == Zeros{PTO_XLEN} + 0x7f800000;
    assert fp32_infinite_product_flags == Zeros{5};

    let (fp16_sum, fp16_sum_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, Zeros{5} + 4,
        Zeros{PTO_XLEN} + 0x3e00, Zeros{PTO_XLEN} + 0x4080);
    assert fp16_sum == Zeros{PTO_XLEN} + 0x4380;
    assert fp16_sum_flags == Zeros{5};

    let (fp16_infinite_product, fp16_infinite_product_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_MUL, NumericRound_RNE, Zeros{5} + 4,
            Zeros{PTO_XLEN} + 0x7c00,
            Zeros{PTO_XLEN} + 0x4000);
    assert fp16_infinite_product == Zeros{PTO_XLEN} + 0x7c00;
    assert fp16_infinite_product_flags == Zeros{5};

    let (fp16_zero_over_zero, fp16_zero_over_zero_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_DIV, NumericRound_RNE, Zeros{5} + 4,
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    assert fp16_zero_over_zero == Zeros{PTO_XLEN} + 0x7e00;
    assert fp16_zero_over_zero_flags == Zeros{5} + 1;

    let (fp64_infinite_product, fp64_infinite_product_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_MUL, NumericRound_RNE, fp64,
            Zeros{PTO_XLEN} + 0xfff0000000000000,
            Zeros{PTO_XLEN} + 0xc000000000000000);
    assert fp64_infinite_product ==
        Zeros{PTO_XLEN} + 0x7ff0000000000000;
    assert fp64_infinite_product_flags == Zeros{5};

    let (zero_times_infinity, zero_times_infinity_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_MUL, NumericRound_RNE, fp32,
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0xff800000);
    assert zero_times_infinity == Zeros{PTO_XLEN} + 0x7fc00000;
    assert zero_times_infinity_flags == Zeros{5} + 1;

    let (quiet_nan_product, quiet_nan_product_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_MUL, NumericRound_RNE, fp64,
            Zeros{PTO_XLEN} + 0x7ff8000000000001,
            Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert quiet_nan_product == Zeros{PTO_XLEN} + 0x7ff8000000000000;
    assert quiet_nan_product_flags == Zeros{5};

    let (signaling_nan_product, signaling_nan_product_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_MUL, NumericRound_RNE, fp64,
            Zeros{PTO_XLEN} + 0x7ff0000000000001,
            Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert signaling_nan_product ==
        Zeros{PTO_XLEN} + 0x7ff8000000000000;
    assert signaling_nan_product_flags == Zeros{5} + 1;

    let (invalid_add, invalid_add_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, fp32,
        Zeros{PTO_XLEN} + 0x7f800000,
        Zeros{PTO_XLEN} + 0xff800000);
    assert invalid_add == Zeros{PTO_XLEN} + 0x7fc00000;
    assert invalid_add_flags == Zeros{5} + 1;

    let (invalid_subtract, invalid_subtract_flags) =
        ScalarFPBinaryProfile(
            FloatingBinary_SUB, NumericRound_RNE, fp64,
            Zeros{PTO_XLEN} + 0x7ff0000000000000,
            Zeros{PTO_XLEN} + 0x7ff0000000000000);
    assert invalid_subtract ==
        Zeros{PTO_XLEN} + 0x7ff8000000000000;
    assert invalid_subtract_flags == Zeros{5} + 1;

    let (divide_by_zero, divide_by_zero_flags) = ScalarFPBinaryProfile(
        FloatingBinary_DIV, NumericRound_RNE, fp32,
        Zeros{PTO_XLEN} + 0xbf800000, Zeros{PTO_XLEN});
    assert divide_by_zero == Zeros{PTO_XLEN} + 0xff800000;
    assert divide_by_zero_flags == Zeros{5} + 2;

    let (zero_over_zero, zero_over_zero_flags) = ScalarFPBinaryProfile(
        FloatingBinary_DIV, NumericRound_RNE, fp64,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    assert zero_over_zero == Zeros{PTO_XLEN} + 0x7ff8000000000000;
    assert zero_over_zero_flags == Zeros{5} + 1;

    let (finite_over_negative_infinity,
         finite_over_negative_infinity_flags) = ScalarFPBinaryProfile(
            FloatingBinary_DIV, NumericRound_RNE, fp32,
            Zeros{PTO_XLEN} + 0x3f800000,
            Zeros{PTO_XLEN} + 0xff800000);
    assert finite_over_negative_infinity ==
        Zeros{PTO_XLEN} + 0x80000000;
    assert finite_over_negative_infinity_flags == Zeros{5};
    return 0;
end;
