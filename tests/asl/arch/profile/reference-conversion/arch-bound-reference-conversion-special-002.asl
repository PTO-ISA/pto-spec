// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-CONVERSION-SPECIAL-002","source":"asl/arch/profile/reference-conversion.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001"],"kind":"boundary","summary":"the common conversion profile fixes special values, range results, wrap, and saturation","pass_condition":"NaNs, infinities, signed zero, finite overflow, integer wrap, and saturation produce the accepted carriers and flags","related_sources":["asl/tile/model/numeric/formats.asl","asl/arch/profile/e8m0-conversion.asl"]}
func main() => integer
begin
    let ordinary = DefaultNumericExecutionControl();
    var saturating = DefaultNumericExecutionControl();
    saturating.saturating = TRUE;

    let (quiet_nan, quiet_nan_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x7fc00042,
        TileDataType_FP32, TileDataType_FP16, ordinary);
    let (signaling_nan, signaling_nan_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x7f800042,
        TileDataType_FP32, TileDataType_FP16, ordinary);
    let (infinity, infinity_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x7f800000,
        TileDataType_FP32, TileDataType_FP16, ordinary);
    let (e4m3_overflow, e4m3_overflow_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x7f800000,
        TileDataType_FP32, TileDataType_E4M3, ordinary);
    let (e4m3_saturating, e4m3_saturating_flags) =
        ReferenceCommonConvert(
            Zeros{PTO_XLEN} + 0x7f800000,
            TileDataType_FP32, TileDataType_E4M3, saturating);
    let (negative_zero, negative_zero_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x80000000,
        TileDataType_FP32, TileDataType_E4M3, ordinary);
    let (wrapped, wrapped_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x43966000,
        TileDataType_FP32, TileDataType_U8, ordinary);
    let (clamped, clamped_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x43966000,
        TileDataType_FP32, TileDataType_U8, saturating);
    let (nan_integer, nan_integer_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0x7fc00042,
        TileDataType_FP32, TileDataType_U8, ordinary);
    let (positive_infinity_integer, positive_infinity_integer_flags) =
        ReferenceCommonConvert(
            Zeros{PTO_XLEN} + 0x7f800000,
            TileDataType_FP32, TileDataType_U8, ordinary);
    let (negative_infinity_integer, negative_infinity_integer_flags) =
        ReferenceCommonConvert(
            Zeros{PTO_XLEN} + 0xff800000,
            TileDataType_FP32, TileDataType_U8, ordinary);
    let (signed_to_half, signed_to_half_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 0xfffe,
        TileDataType_S16, TileDataType_FP16, ordinary);

    assert quiet_nan == Zeros{PTO_XLEN} + 0x7e00;
    assert quiet_nan_flags == Zeros{5};
    assert signaling_nan == Zeros{PTO_XLEN} + 0x7e00;
    assert signaling_nan_flags == Zeros{5} + 1;
    assert infinity == Zeros{PTO_XLEN} + 0x7c00;
    assert infinity_flags == Zeros{5};
    assert e4m3_overflow == Zeros{PTO_XLEN} + 0x7f;
    assert e4m3_overflow_flags == Zeros{5} + 0x14;
    assert e4m3_saturating == Zeros{PTO_XLEN} + 0x7e;
    assert e4m3_saturating_flags == Zeros{5} + 0x14;
    assert negative_zero == Zeros{PTO_XLEN} + 0x80;
    assert negative_zero_flags == Zeros{5};
    assert wrapped == Zeros{PTO_XLEN} + 45;
    assert wrapped_flags == Zeros{5} + 0x14;
    assert clamped == Zeros{PTO_XLEN} + 255;
    assert clamped_flags == Zeros{5} + 0x14;
    assert nan_integer == Zeros{PTO_XLEN};
    assert nan_integer_flags == Zeros{5} + 1;
    assert positive_infinity_integer == Zeros{PTO_XLEN} + 255;
    assert positive_infinity_integer_flags == Zeros{5} + 1;
    assert negative_infinity_integer == Zeros{PTO_XLEN};
    assert negative_infinity_integer_flags == Zeros{5} + 1;
    assert signed_to_half == Zeros{PTO_XLEN} + 0xc000;
    assert signed_to_half_flags == Zeros{5};
    return 0;
end;
