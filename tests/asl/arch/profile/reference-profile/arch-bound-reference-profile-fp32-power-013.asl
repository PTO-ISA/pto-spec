// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-FP32-POWER-013","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"boundary","summary":"the finite FP32 reference profile preserves the 16.0 exponent boundary used by compiler-generated scalar initialization","pass_condition":"signed 160 converts to FP32, fused multiplication by the compiler 0.1 carrier rounds to 16.0, and RTZ converts the result back to signed 16","related_sources":["asl/arch/profile/reference-quantization.asl","asl/scalar/model/fsu/arithmetic.asl","asl/scalar/fsu/SCVTF.asl","asl/scalar/fsu/FMADD.asl","asl/scalar/fsu/FCVTZ.asl"]}
func main() => integer
begin
    let (integer_fp32, integer_flags) = ScalarIntegerToFPProfile(
        NumericRound_RNE,
        Zeros{5} + 8,
        Zeros{5} + 1,
        Zeros{PTO_XLEN} + 160);
    assert integer_fp32 == Zeros{PTO_XLEN} + 0x43200000;
    assert integer_flags == Zeros{5};
    assert ReferenceScalarFPFiniteValue(integer_fp32, Zeros{5} + 1) ==
        160.0;

    let (scaled_fp32, scaled_flags) = ReferenceScalarFPFusedFinite(
        FloatingFused_MADD,
        NumericRound_RNE,
        Zeros{5} + 1,
        Zeros{PTO_XLEN},
        integer_fp32,
        Zeros{PTO_XLEN} + 0x3dcccccd);
    assert scaled_fp32 == Zeros{PTO_XLEN} + 0x41800000;
    assert scaled_flags == Zeros{5} + 0x10;

    let (converted, converted_flags) = ScalarFPToIntegerProfile(
        NumericRound_RTZ,
        Zeros{5} + 8,
        Zeros{5} + 1,
        scaled_fp32);
    assert converted == Zeros{PTO_XLEN} + 16;
    assert converted_flags == Zeros{5};
    return 0;
end;
