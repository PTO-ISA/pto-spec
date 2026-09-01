// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-FLOATING-MODULO-004","source":"asl/arch/profile/reference-conversion.asl","requirements":[],"kind":"execution","summary":"the reference Tile floating modulo profile implements finite and IEEE special values","pass_condition":"FP32 and FP16 finite remainders, zero-divisor NaNs, infinity, and flags are exact","related_sources":["asl/arch/profile/reference-profile.asl","asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    let (fp32_finite, fp32_finite_flags) = ReferenceTileFloatingModulo(
        TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x40b00000,
        Zeros{PTO_XLEN} + 0x40000000);
    assert fp32_finite == Zeros{PTO_XLEN} + 0x3fc00000;
    assert fp32_finite_flags == Zeros{5};

    let (fp16_finite, fp16_finite_flags) = ReferenceTileFloatingModulo(
        TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x4580,
        Zeros{PTO_XLEN} + 0x4000);
    assert fp16_finite == Zeros{PTO_XLEN} + 0x3e00;
    assert fp16_finite_flags == Zeros{5};

    let (fp32_zero_divisor, fp32_zero_divisor_flags) =
        ReferenceTileFloatingModulo(
            TileDataType_FP32, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    assert fp32_zero_divisor == Zeros{PTO_XLEN} + 0x7fc00000;
    assert fp32_zero_divisor_flags == Zeros{5} + 1;

    let (fp16_zero_divisor, fp16_zero_divisor_flags) =
        ReferenceTileFloatingModulo(
            TileDataType_FP16, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    assert fp16_zero_divisor == Zeros{PTO_XLEN} + 0x7e00;
    assert fp16_zero_divisor_flags == Zeros{5} + 1;

    let (finite_over_infinity, finite_over_infinity_flags) =
        ReferenceTileFloatingModulo(
            TileDataType_FP32,
            Zeros{PTO_XLEN} + 0x3fc00000,
            Zeros{PTO_XLEN} + 0x7f800000);
    assert finite_over_infinity == Zeros{PTO_XLEN} + 0x3fc00000;
    assert finite_over_infinity_flags == Zeros{5};
    return 0;
end;
