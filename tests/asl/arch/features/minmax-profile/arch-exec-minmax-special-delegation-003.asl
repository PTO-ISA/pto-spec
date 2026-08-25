// PTO-TEST: {"id":"PTO-AVS-ARCH-MINMAX-SPECIAL-DELEGATION-EXEC-003","source":"asl/arch/features/minmax-profile.asl","requirements":[],"kind":"execution","summary":"floating min-max delegates NaN and signed-zero cases to the special-value owner","pass_condition":"one-NaN and signed-zero min-max results match the delegated special rules","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let quiet_nan = Zeros{PTO_XLEN} + 0x7fc00000;
    let one = Zeros{PTO_XLEN} + 0x3f800000;
    let (nan_available, nan_result, nan_invalid) =
        HardwareNumericFloatingMinMax(FALSE, TileDataType_FP32,
            quiet_nan, one);
    assert nan_available && nan_result == one && !nan_invalid;

    let positive_zero = Zeros{PTO_XLEN};
    let negative_zero = Zeros{PTO_XLEN} + 0x80000000;
    let (min_available, min_result, min_invalid) =
        HardwareNumericFloatingMinMax(FALSE, TileDataType_FP32,
            positive_zero, negative_zero);
    let (max_available, max_result, max_invalid) =
        HardwareNumericFloatingMinMax(TRUE, TileDataType_FP32,
            negative_zero, positive_zero);
    assert min_available && min_result == negative_zero && !min_invalid;
    assert max_available && max_result == positive_zero && !max_invalid;
    return 0;
end;
