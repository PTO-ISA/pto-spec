// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-SPECIAL-005","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"B.FPATR special values produce deterministic integer and floating results","pass_condition":"NaN and infinities map to the assigned integer endpoints or canonical floating NaN with exact sticky flags","related_sources":["asl/arch/profile/reference-quantization.asl","asl/arch/state/numeric-status.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 9);

    let (nan_integer, nan_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0x7fc00000,
        '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
        scale_one, Zeros{PTO_XLEN}, control);
    assert nan_integer == Zeros{PTO_XLEN} + 0xffffffffffffff80;
    assert nan_flags == Zeros{5} + 1;

    let (positive_inf, positive_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x7f800000,
            '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
            scale_one, Zeros{PTO_XLEN}, control);
    assert positive_inf == Zeros{PTO_XLEN} + 0xffffffffffffff80;
    assert positive_flags == Zeros{5} + 1;

    let (negative_inf, negative_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0xff800000,
            '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
            scale_one, Zeros{PTO_XLEN}, control);
    assert negative_inf == Zeros{PTO_XLEN} + 0xffffffffffffff80;
    assert negative_flags == Zeros{5} + 1;

    let saturating = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = TRUE
    };
    let (sat_nan, sat_nan_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0x7fc00000,
        '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
        scale_one, Zeros{PTO_XLEN}, saturating);
    assert sat_nan == Zeros{PTO_XLEN};
    assert sat_nan_flags == Zeros{5} + 1;
    let (sat_inf, sat_inf_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0x7f800000,
        '011000', Zeros{3}, Zeros{4}, TileDataType_S8,
        scale_one, Zeros{PTO_XLEN}, saturating);
    assert sat_inf == Zeros{PTO_XLEN} + 127;
    assert sat_inf_flags == Zeros{5} + 0x14;

    let (nan_e4m3, nan_e4m3_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x7fc00000,
            '011010', Zeros{3}, Zeros{4}, TileDataType_E4M3,
            MatrixQuantParameter(FP32ToFP19(
                Zeros{PTO_XLEN} + 0x3f800000),
                Zeros{PTO_XLEN}, 0),
            Zeros{PTO_XLEN}, control);
    assert nan_e4m3 == Zeros{PTO_XLEN} + 0x7f;
    assert nan_e4m3_flags == Zeros{5};
    return 0;
end;
