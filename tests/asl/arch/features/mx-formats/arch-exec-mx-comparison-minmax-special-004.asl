// PTO-TEST: {"id":"PTO-AVS-ARCH-MX-COMPARISON-MINMAX-SPECIAL-EXEC-004","source":"asl/arch/features/mx-formats.asl","requirements":[],"kind":"execution","summary":"comparison and min-max special helpers distinguish handled cases from ordinary or invalid encodings","pass_condition":"NaN, signed-zero, ordinary, and invalid-encoding handled assertions hold","related_sources":["asl/arch/data-types/numeric-classification.asl"]}
func main() => integer
begin
    let quiet_nan = Zeros{PTO_XLEN} + 0x7fc00000;
    let one = Zeros{PTO_XLEN} + 0x3f800000;
    let (nan_compare_handled, nan_compare, nan_compare_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_NE,
            TileDataType_FP32, quiet_nan, one);
    assert nan_compare_handled;
    assert nan_compare == Zeros{PTO_XLEN} + 1;
    assert !nan_compare_invalid;

    let positive_zero = Zeros{PTO_XLEN};
    let negative_zero = Zeros{PTO_XLEN} + 0x80000000;
    let (zero_compare_handled, zero_compare, zero_compare_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_EQ,
            TileDataType_FP32, positive_zero, negative_zero);
    assert zero_compare_handled;
    assert zero_compare == Zeros{PTO_XLEN} + 1;
    assert !zero_compare_invalid;

    let (nan_min_handled, nan_min, nan_min_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, TileDataType_FP32,
            quiet_nan, one);
    let (zero_min_handled, zero_min, zero_min_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, TileDataType_FP32,
            positive_zero, negative_zero);
    assert nan_min_handled && nan_min == one && !nan_min_invalid;
    assert zero_min_handled && zero_min == negative_zero && !zero_min_invalid;

    let two = Zeros{PTO_XLEN} + 0x40000000;
    let (ordinary_handled, ordinary_result, ordinary_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_LT,
            TileDataType_FP32, one, two);
    assert !ordinary_handled;
    assert ordinary_result == Zeros{PTO_XLEN};
    assert !ordinary_invalid;

    let invalid_tf32 = Zeros{PTO_XLEN} + 0x3f800001;
    let (invalid_handled, invalid_result, invalid_condition) =
        HardwareNumericMinMaxSpecial(FALSE, TileDataType_TF32,
            quiet_nan, invalid_tf32);
    assert !invalid_handled;
    assert invalid_result == Zeros{PTO_XLEN};
    assert !invalid_condition;
    return 0;
end;
