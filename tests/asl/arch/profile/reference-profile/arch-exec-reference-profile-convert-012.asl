// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-CONVERT-012","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference profile converts finite FP32, FP64, signed integer, and unsigned integer carriers","pass_condition":"FP width conversion and both integer conversion directions produce the fixed RNE or RTZ result and flags","related_sources":["asl/arch/profile/reference-quantization.asl"]}
func main() => integer
begin
    let (fp32_to_fp64, fp32_to_fp64_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, Zeros{5}, Zeros{5} + 1,
        Zeros{PTO_XLEN} + 0x3fc00000);
    let (fp64_to_fp32, fp64_to_fp32_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, Zeros{5} + 1, Zeros{5},
        Zeros{PTO_XLEN} + 0x4002000000000000);
    let (signed_to_fp32, signed_to_fp32_flags) =
        ScalarIntegerToFPProfile(
            NumericRound_RNE, Zeros{5} + 8, Zeros{5} + 1,
            Ones{PTO_XLEN} - 2);
    let (unsigned_to_fp64, unsigned_to_fp64_flags) =
        ScalarIntegerToFPProfile(
            NumericRound_RNE, Zeros{5} + 1, Zeros{5},
            Zeros{PTO_XLEN} + 9);
    let (fp32_to_integer, fp32_to_integer_flags) =
        ScalarFPToIntegerProfile(
            NumericRound_RNE, Zeros{5}, Zeros{5} + 1,
            Zeros{PTO_XLEN} + 0x40200000);
    let (fp64_to_integer, fp64_to_integer_flags) =
        ScalarFPToIntegerProfile(
            NumericRound_RTZ, Zeros{5} + 8, Zeros{5},
            Zeros{PTO_XLEN} + 0xc00e000000000000);

    assert fp32_to_fp64 == Zeros{PTO_XLEN} + 0x3ff8000000000000;
    assert fp64_to_fp32 == Zeros{PTO_XLEN} + 0x40100000;
    assert signed_to_fp32 == Zeros{PTO_XLEN} + 0xc0400000;
    assert unsigned_to_fp64 == Zeros{PTO_XLEN} + 0x4022000000000000;
    assert fp32_to_integer == Zeros{PTO_XLEN} + 2;
    assert fp64_to_integer == Ones{PTO_XLEN} - 2;
    assert fp32_to_fp64_flags == Zeros{5};
    assert fp64_to_fp32_flags == Zeros{5};
    assert signed_to_fp32_flags == Zeros{5};
    assert unsigned_to_fp64_flags == Zeros{5};
    assert fp32_to_integer_flags == Zeros{5} + 0x10;
    assert fp64_to_integer_flags == Zeros{5} + 0x10;
    return 0;
end;
