// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-SPECIAL-VALUES-EXEC-002","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile NaN and signed-zero rules are exact","pass_condition":"NaN, comparison, min-max, and signed-zero assertions hold","related_sources":[]}
func AssertHardwareNumericNaNSpecialRules(
    data_type: TileDataType, quiet_nan: Word,
    signaling_available: boolean, signaling_nan: Word,
    ordinary: Word)
begin
    let (canonical_available, canonical) =
        HardwareNumericCanonicalNaNResult(data_type);
    assert canonical_available;
    assert canonical == quiet_nan;

    let (eq_left_handled, eq_left, eq_left_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_EQ, data_type,
            quiet_nan, ordinary);
    let (ne_left_handled, ne_left, ne_left_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_NE, data_type,
            quiet_nan, ordinary);
    let (lt_right_handled, lt_right, lt_right_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_LT, data_type,
            ordinary, quiet_nan);
    let (le_right_handled, le_right, le_right_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_LE, data_type,
            ordinary, quiet_nan);
    let (gt_both_handled, gt_both, gt_both_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_GT, data_type,
            quiet_nan, quiet_nan);
    let (ge_both_handled, ge_both, ge_both_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_GE, data_type,
            quiet_nan, quiet_nan);
    assert eq_left_handled && eq_left == Zeros{PTO_XLEN} && !eq_left_invalid;
    assert ne_left_handled && ne_left == Zeros{PTO_XLEN} + 1 && !ne_left_invalid;
    assert lt_right_handled && lt_right == Zeros{PTO_XLEN} && !lt_right_invalid;
    assert le_right_handled && le_right == Zeros{PTO_XLEN} && !le_right_invalid;
    assert gt_both_handled && gt_both == Zeros{PTO_XLEN} && !gt_both_invalid;
    assert ge_both_handled && ge_both == Zeros{PTO_XLEN} && !ge_both_invalid;

    let (min_left_handled, min_left, min_left_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, data_type, quiet_nan, ordinary);
    let (max_right_handled, max_right, max_right_invalid) =
        HardwareNumericMinMaxSpecial(TRUE, data_type, ordinary, quiet_nan);
    let (min_both_handled, min_both, min_both_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, data_type, quiet_nan, quiet_nan);
    let (max_both_handled, max_both, max_both_invalid) =
        HardwareNumericMinMaxSpecial(TRUE, data_type, quiet_nan, quiet_nan);
    assert min_left_handled && min_left == ordinary && !min_left_invalid;
    assert max_right_handled && max_right == ordinary && !max_right_invalid;
    assert min_both_handled && min_both == canonical && !min_both_invalid;
    assert max_both_handled && max_both == canonical && !max_both_invalid;

    if signaling_available then
        let (signaling_compare_handled, signaling_compare,
             signaling_compare_invalid) = HardwareNumericComparisonSpecial(
                TileComparison_NE, data_type, signaling_nan, ordinary);
        let (signaling_min_handled, signaling_min, signaling_min_invalid) =
            HardwareNumericMinMaxSpecial(FALSE, data_type,
                signaling_nan, ordinary);
        let (signaling_both_handled, signaling_both,
             signaling_both_invalid) = HardwareNumericMinMaxSpecial(
                TRUE, data_type, signaling_nan, quiet_nan);
        assert signaling_compare_handled &&
               signaling_compare == Zeros{PTO_XLEN} + 1 &&
               signaling_compare_invalid;
        assert signaling_min_handled && signaling_min == ordinary &&
               signaling_min_invalid;
        assert signaling_both_handled && signaling_both == canonical &&
               signaling_both_invalid;
    end;
end;

func AssertHardwareNumericSignedZeroSpecialRules(
    data_type: TileDataType, negative_zero: Word)
begin
    let (available, positive_zero, actual_negative_zero) =
        HardwareNumericSignedZeroEncodings(data_type);
    assert available;
    assert positive_zero == Zeros{PTO_XLEN};
    assert actual_negative_zero == negative_zero;
    assert TileNumericValueClass(data_type, positive_zero) ==
        NumericValue_PositiveZero;
    assert TileNumericValueClass(data_type, negative_zero) ==
        NumericValue_NegativeZero;

    let (eq_handled, eq_result, eq_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_EQ, data_type,
            positive_zero, negative_zero);
    let (ne_handled, ne_result, ne_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_NE, data_type,
            negative_zero, positive_zero);
    let (lt_handled, lt_result, lt_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_LT, data_type,
            negative_zero, positive_zero);
    let (le_handled, le_result, le_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_LE, data_type,
            positive_zero, negative_zero);
    let (gt_handled, gt_result, gt_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_GT, data_type,
            positive_zero, negative_zero);
    let (ge_handled, ge_result, ge_invalid) =
        HardwareNumericComparisonSpecial(TileComparison_GE, data_type,
            negative_zero, positive_zero);
    assert eq_handled && eq_result == Zeros{PTO_XLEN} + 1 && !eq_invalid;
    assert ne_handled && ne_result == Zeros{PTO_XLEN} && !ne_invalid;
    assert lt_handled && lt_result == Zeros{PTO_XLEN} && !lt_invalid;
    assert le_handled && le_result == Zeros{PTO_XLEN} + 1 && !le_invalid;
    assert gt_handled && gt_result == Zeros{PTO_XLEN} && !gt_invalid;
    assert ge_handled && ge_result == Zeros{PTO_XLEN} + 1 && !ge_invalid;

    let (min_lr_handled, min_lr, min_lr_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, data_type,
            positive_zero, negative_zero);
    let (min_rl_handled, min_rl, min_rl_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, data_type,
            negative_zero, positive_zero);
    let (min_pp_handled, min_pp, min_pp_invalid) =
        HardwareNumericMinMaxSpecial(FALSE, data_type,
            positive_zero, positive_zero);
    let (max_lr_handled, max_lr, max_lr_invalid) =
        HardwareNumericMinMaxSpecial(TRUE, data_type,
            positive_zero, negative_zero);
    let (max_rl_handled, max_rl, max_rl_invalid) =
        HardwareNumericMinMaxSpecial(TRUE, data_type,
            negative_zero, positive_zero);
    let (max_nn_handled, max_nn, max_nn_invalid) =
        HardwareNumericMinMaxSpecial(TRUE, data_type,
            negative_zero, negative_zero);
    assert min_lr_handled && min_lr == negative_zero && !min_lr_invalid;
    assert min_rl_handled && min_rl == negative_zero && !min_rl_invalid;
    assert min_pp_handled && min_pp == positive_zero && !min_pp_invalid;
    assert max_lr_handled && max_lr == positive_zero && !max_lr_invalid;
    assert max_rl_handled && max_rl == positive_zero && !max_rl_invalid;
    assert max_nn_handled && max_nn == negative_zero && !max_nn_invalid;
end;

func AssertHardwareNumericSignedZeroNotApplicable(data_type: TileDataType)
begin
    let (available, positive_zero, negative_zero) =
        HardwareNumericSignedZeroEncodings(data_type);
    assert !available;
    assert positive_zero == Zeros{PTO_XLEN};
    assert negative_zero == Zeros{PTO_XLEN};
end;

func TestConcreteSpecialValueProfile()
begin
    AssertHardwareNumericNaNSpecialRules(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff8000000000000, TRUE,
        Zeros{PTO_XLEN} + 0x7ff0000000000001, Zeros{PTO_XLEN} + 0x3ff0000000000000);
    AssertHardwareNumericNaNSpecialRules(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00000, TRUE,
        Zeros{PTO_XLEN} + 0x7f800001, Zeros{PTO_XLEN} + 0x3f800000);
    AssertHardwareNumericNaNSpecialRules(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7fc00000, TRUE,
        Zeros{PTO_XLEN} + 0x7f802000, Zeros{PTO_XLEN} + 0x3f800000);
    AssertHardwareNumericNaNSpecialRules(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7fc00000, TRUE,
        Zeros{PTO_XLEN} + 0x7f801000, Zeros{PTO_XLEN} + 0x3f800000);
    AssertHardwareNumericNaNSpecialRules(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e00, TRUE,
        Zeros{PTO_XLEN} + 0x7c01, Zeros{PTO_XLEN} + 0x3c00);
    AssertHardwareNumericNaNSpecialRules(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7fc0, TRUE,
        Zeros{PTO_XLEN} + 0x7f81, Zeros{PTO_XLEN} + 0x3f80);
    AssertHardwareNumericNaNSpecialRules(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x80, FALSE, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x10);
    AssertHardwareNumericNaNSpecialRules(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x7f, FALSE, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x38);
    AssertHardwareNumericNaNSpecialRules(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7e, TRUE, Zeros{PTO_XLEN} + 0x7d,
        Zeros{PTO_XLEN} + 0x3c);
    AssertHardwareNumericNaNSpecialRules(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0xff, FALSE, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x7f);

    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000000);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x80000000);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x80000000);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8000);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x8000);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x80);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x80);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x20);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x20);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + 0x8);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_E1M2X2,
        Zeros{PTO_XLEN} + 0x8);
    AssertHardwareNumericSignedZeroSpecialRules(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + 0x8);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_HiF8);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_E8M0);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_S64);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_S32);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_S16);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_S8);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_S4X2);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_U64);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_U32);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_U16);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_U8);
    AssertHardwareNumericSignedZeroNotApplicable(TileDataType_U4X2);

    let tf32_invalid_encoding = Zeros{PTO_XLEN} + 0x3f800001;
    let tf32_quiet_nan = Zeros{PTO_XLEN} + 0x7fc00000;
    let (invalid_compare_handled, invalid_compare_result,
         invalid_compare_condition) = HardwareNumericComparisonSpecial(
            TileComparison_NE, TileDataType_TF32,
            tf32_quiet_nan, tf32_invalid_encoding);
    let (invalid_min_handled, invalid_min_result, invalid_min_condition) =
        HardwareNumericMinMaxSpecial(FALSE, TileDataType_TF32,
            tf32_quiet_nan, tf32_invalid_encoding);
    assert !invalid_compare_handled;
    assert invalid_compare_result == Zeros{PTO_XLEN};
    assert !invalid_compare_condition;
    assert !invalid_min_handled;
    assert invalid_min_result == Zeros{PTO_XLEN};
    assert !invalid_min_condition;
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteSpecialValueProfile();
    return 0;
end;
