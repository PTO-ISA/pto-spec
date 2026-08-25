// PTO-TEST: {"id":"PTO-AVS-ARCH-MINMAX-ORDERING-TIES-EXEC-004","source":"asl/arch/features/minmax-profile.asl","requirements":[],"kind":"execution","summary":"ordinary min-max follows numeric key order and selects the left carrier on equal keys","pass_condition":"positive, negative, and equal-key left-tie assertions hold","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let one = Zeros{PTO_XLEN} + 0x3f800000;
    let two = Zeros{PTO_XLEN} + 0x40000000;
    let (positive_min_available, positive_min, positive_min_invalid) =
        HardwareNumericFloatingMinMax(FALSE, TileDataType_FP32, two, one);
    let (positive_max_available, positive_max, positive_max_invalid) =
        HardwareNumericFloatingMinMax(TRUE, TileDataType_FP32, one, two);
    assert positive_min_available && positive_min == one && !positive_min_invalid;
    assert positive_max_available && positive_max == two && !positive_max_invalid;

    let negative_two = Zeros{PTO_XLEN} + 0xc0000000;
    let negative_one = Zeros{PTO_XLEN} + 0xbf800000;
    let (negative_min_available, negative_min, negative_min_invalid) =
        HardwareNumericFloatingMinMax(FALSE, TileDataType_FP32,
            negative_one, negative_two);
    let (negative_max_available, negative_max, negative_max_invalid) =
        HardwareNumericFloatingMinMax(TRUE, TileDataType_FP32,
            negative_two, negative_one);
    assert negative_min_available && negative_min == negative_two && !negative_min_invalid;
    assert negative_max_available && negative_max == negative_one && !negative_max_invalid;

    let left_tie = Zeros{PTO_XLEN} + 0x111111113f800000;
    let right_tie = Zeros{PTO_XLEN} + 0x222222223f800000;
    let (tie_min_available, tie_min, tie_min_invalid) =
        HardwareNumericFloatingMinMax(FALSE, TileDataType_FP32,
            left_tie, right_tie);
    let (tie_max_available, tie_max, tie_max_invalid) =
        HardwareNumericFloatingMinMax(TRUE, TileDataType_FP32,
            left_tie, right_tie);
    assert tie_min_available && tie_min == left_tie && !tie_min_invalid;
    assert tie_max_available && tie_max == left_tie && !tie_max_invalid;
    return 0;
end;
