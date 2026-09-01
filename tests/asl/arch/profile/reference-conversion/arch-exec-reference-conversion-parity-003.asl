// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-CONVERSION-PARITY-003","source":"asl/arch/profile/reference-conversion.asl","requirements":["PTO-COMMON-CONVERSION-PROFILE-001","PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"scalar conversion profiles and TCVT use the same shared conversion results","pass_condition":"representative floating, integer, half, E4M3, and range conversions produce identical scalar and Tile results and flags","related_sources":["asl/scalar/model/fsu/profile.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();

    let (scalar_half, scalar_half_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, Zeros{5} + 2, Zeros{5} + 1,
        Zeros{PTO_XLEN} + 0x3dcccccd);
    let (tile_half, tile_half_flags) = TileConvertValue(
        Zeros{PTO_XLEN} + 0x3dcccccd,
        TileDataType_FP32, TileDataType_FP16, control);
    let (scalar_integer, scalar_integer_flags) = ScalarFPToIntegerProfile(
        NumericRound_RTZ, Zeros{5} + 11, Zeros{5} + 3,
        Zeros{PTO_XLEN} + 0x3c);
    var truncating = DefaultNumericExecutionControl();
    truncating.rounding_mode = NumericRound_RTZ;
    let (tile_integer, tile_integer_flags) = TileConvertValue(
        Zeros{PTO_XLEN} + 0x3c,
        TileDataType_E4M3, TileDataType_S8, truncating);
    let (scalar_float, scalar_float_flags) = ScalarIntegerToFPProfile(
        NumericRound_RNE, Zeros{5} + 10, Zeros{5} + 1,
        Ones{PTO_XLEN} - 1);
    let (tile_float, tile_float_flags) = TileConvertValue(
        Ones{PTO_XLEN} - 1,
        TileDataType_S16, TileDataType_FP32, control);

    assert scalar_half == tile_half;
    assert scalar_half_flags == tile_half_flags;
    assert scalar_integer == tile_integer;
    assert scalar_integer_flags == tile_integer_flags;
    assert scalar_float == tile_float;
    assert scalar_float_flags == tile_float_flags;
    return 0;
end;
