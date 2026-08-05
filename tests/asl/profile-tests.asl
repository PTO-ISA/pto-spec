// PTO-REQ-PROFILE-001: direct conformance witnesses for every PTO v0
// implementation-profile boundary.

func AssertHardwareNumericSubnormalBoundary(data_type: TileDataType,
                                             minimum: Word,
                                             maximum: Word,
                                             minimum_normal: Word,
                                             sign_mask: Word)
begin
    assert HardwareNumericTypeHasSubnormals(data_type);
    assert HardwareNumericInputSubnormalRule(data_type) ==
        NumericInputSubnormal_Preserve;
    assert HardwareNumericResultSubnormalRule(data_type) ==
        NumericResultSubnormal_GradualUnderflow;
    assert HardwareNumericTininessDetectionRule(data_type) ==
        NumericTininessDetection_AfterRounding;
    let (available, actual_minimum, actual_maximum, actual_minimum_normal) =
        HardwareNumericSubnormalBoundaries(data_type);
    assert available;
    assert actual_minimum == minimum;
    assert actual_maximum == maximum;
    assert actual_minimum_normal == minimum_normal;
    assert TileNumericEncodingValid(data_type, minimum);
    assert TileNumericEncodingValid(data_type, maximum);
    assert TileNumericEncodingValid(data_type, minimum_normal);
    assert TileNumericValueClass(data_type, minimum) ==
        NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(data_type, maximum) ==
        NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(data_type, minimum_normal) ==
        NumericValue_PositiveNormal;
    assert TileNumericValueClass(data_type, sign_mask + minimum) ==
        NumericValue_NegativeSubnormal;
    assert TileNumericValueClass(data_type, sign_mask + maximum) ==
        NumericValue_NegativeSubnormal;
end;

func AssertHardwareNumericSubnormalNotApplicable(data_type: TileDataType)
begin
    assert !HardwareNumericTypeHasSubnormals(data_type);
    assert HardwareNumericInputSubnormalRule(data_type) ==
        NumericInputSubnormal_NotApplicable;
    assert HardwareNumericResultSubnormalRule(data_type) ==
        NumericResultSubnormal_NotApplicable;
    assert HardwareNumericTininessDetectionRule(data_type) ==
        NumericTininessDetection_NotApplicable;
    let (available, minimum, maximum, minimum_normal) =
        HardwareNumericSubnormalBoundaries(data_type);
    assert !available;
    assert minimum == Zeros{PTO_XLEN};
    assert maximum == Zeros{PTO_XLEN};
    assert minimum_normal == Zeros{PTO_XLEN};
end;

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

func ValidateNumericFormatClassification()
begin
    assert HardwareNumericSubnormalConfigurationValid(FALSE, FALSE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(TRUE, FALSE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(FALSE, TRUE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(FALSE, FALSE, TRUE);
    assert !HardwareNumericSubnormalConfigurationValid(TRUE, TRUE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(TRUE, FALSE, TRUE);
    assert !HardwareNumericSubnormalConfigurationValid(FALSE, TRUE, TRUE);
    assert !HardwareNumericSubnormalConfigurationValid(TRUE, TRUE, TRUE);

    AssertHardwareNumericSubnormalBoundary(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x1,
        Zeros{PTO_XLEN} + 0x000fffffffffffff,
        Zeros{PTO_XLEN} + 0x0010000000000000,
        Zeros{PTO_XLEN} + 0x8000000000000000);
    AssertHardwareNumericSubnormalBoundary(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x007fffff,
        Zeros{PTO_XLEN} + 0x00800000, Zeros{PTO_XLEN} + 0x80000000);
    AssertHardwareNumericSubnormalBoundary(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x00002000, Zeros{PTO_XLEN} + 0x007fe000,
        Zeros{PTO_XLEN} + 0x00800000, Zeros{PTO_XLEN} + 0x80000000);
    AssertHardwareNumericSubnormalBoundary(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x00001000, Zeros{PTO_XLEN} + 0x007ff000,
        Zeros{PTO_XLEN} + 0x00800000, Zeros{PTO_XLEN} + 0x80000000);
    AssertHardwareNumericSubnormalBoundary(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x03ff,
        Zeros{PTO_XLEN} + 0x0400, Zeros{PTO_XLEN} + 0x8000);
    AssertHardwareNumericSubnormalBoundary(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x1, Zeros{PTO_XLEN} + 0x007f,
        Zeros{PTO_XLEN} + 0x0080, Zeros{PTO_XLEN} + 0x8000);
    AssertHardwareNumericSubnormalBoundary(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x01, Zeros{PTO_XLEN} + 0x07,
        Zeros{PTO_XLEN} + 0x08, Zeros{PTO_XLEN} + 0x80);
    AssertHardwareNumericSubnormalBoundary(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x01, Zeros{PTO_XLEN} + 0x07,
        Zeros{PTO_XLEN} + 0x08, Zeros{PTO_XLEN} + 0x80);
    AssertHardwareNumericSubnormalBoundary(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x01, Zeros{PTO_XLEN} + 0x03,
        Zeros{PTO_XLEN} + 0x04, Zeros{PTO_XLEN} + 0x80);
    AssertHardwareNumericSubnormalBoundary(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x01, Zeros{PTO_XLEN} + 0x03,
        Zeros{PTO_XLEN} + 0x04, Zeros{PTO_XLEN} + 0x20);
    AssertHardwareNumericSubnormalBoundary(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x01, Zeros{PTO_XLEN} + 0x07,
        Zeros{PTO_XLEN} + 0x08, Zeros{PTO_XLEN} + 0x20);

    AssertHardwareNumericSubnormalNotApplicable(TileDataType_E2M1X2);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_E1M2X2);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_E8M0);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_HiF4X2);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_S64);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_S32);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_S16);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_S8);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_S4X2);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_U64);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_U32);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_U16);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_U8);
    AssertHardwareNumericSubnormalNotApplicable(TileDataType_U4X2);

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

    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff8000000000000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000001) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xfff0000000000000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000000) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000001) == NumericValue_NegativeSubnormal;

    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xff800000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000) == NumericValue_NegativeZero;

    assert TileNumericEncodingValid(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert !TileNumericEncodingValid(TileDataType_TF32,
        Zeros{PTO_XLEN} + 1);
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 1) == NumericValue_InvalidEncoding;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7f802000) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x00002000) == NumericValue_PositiveSubnormal;
    assert TileNumericEncodingValid(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert !TileNumericEncodingValid(TileDataType_HF32,
        Zeros{PTO_XLEN} + 1);
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7f801000) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x00001000) == NumericValue_PositiveSubnormal;

    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e00) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c01) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8000) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7fc0) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f81) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f80) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;

    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x80) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x6f) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0xef) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x81) == NumericValue_NegativeSubnormal;

    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x7f) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x80) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7e) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7d) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7c) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;

    assert TileNumericEncodingValid(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x3f);
    assert !TileNumericEncodingValid(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40);
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40) == NumericValue_InvalidEncoding;
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x20) == NumericValue_NegativeZero;
    assert !TileNumericEncodingValid(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x80);
    assert TileNumericValueClass(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;

    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + 8) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_E1M2X2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + 9) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_E8M0,
        Zeros{PTO_XLEN}) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;

    assert TileNumericValueClass(TileDataType_S64,
        Ones{PTO_XLEN}) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_S32,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_S4X2,
        Zeros{PTO_XLEN} + 0xaf) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_U4X2,
        Zeros{PTO_XLEN} + 0xf0) == NumericValue_PositiveZero;

    let (fp64_nan_available, fp64_nan) =
        TileNumericCanonicalNaN(TileDataType_FP64);
    let (e5m2_nan_available, e5m2_nan) =
        TileNumericCanonicalNaN(TileDataType_E5M2);
    let (e8m0_nan_available, e8m0_nan) =
        TileNumericCanonicalNaN(TileDataType_E8M0);
    let (integer_nan_available, integer_nan) =
        TileNumericCanonicalNaN(TileDataType_S32);
    assert fp64_nan_available && fp64_nan ==
        Zeros{PTO_XLEN} + 0x7ff8000000000000;
    assert e5m2_nan_available && e5m2_nan == Zeros{PTO_XLEN} + 0x7e;
    assert e8m0_nan_available && e8m0_nan == Zeros{PTO_XLEN} + 0xff;
    assert !integer_nan_available && integer_nan == Zeros{PTO_XLEN};

    // Shared FP32/FP64 classification agrees with the scalar execution path.
    assert ScalarFP64IsNaN(Zeros{PTO_XLEN} + 0x7ff8000000000001);
    assert ScalarFP64IsSignalingNaN(Zeros{PTO_XLEN} + 0x7ff0000000000001);
    assert ScalarFP32IsNaN(Zeros{32} + 0x7fc00001);
    assert ScalarFP32IsSignalingNaN(Zeros{32} + 0x7f800001);
end;

func TestConcreteProfile()
begin
    ResetProfileState();
    ValidateNumericFormatClassification();
    assert CurrentACR() == 0;
    let reset_time = ReadMonotonicTime();
    assert reset_time == Zeros{PTO_XLEN};
    AdvanceArchitecturalTime();
    let advanced_time = ReadMonotonicTime();
    assert advanced_time == Zeros{PTO_XLEN} + 1;

    let exponential_zero = FloatingExponential(0.0);
    assert exponential_zero == 1.0;
    let rounded_even_low = FloatingRoundNearest(2.5);
    let rounded_even_high = FloatingRoundNearest(3.5);
    let rounded_even_negative_low = FloatingRoundNearest(-2.5);
    let rounded_even_negative_high = FloatingRoundNearest(-3.5);
    assert rounded_even_low == 2;
    assert rounded_even_high == 4;
    assert rounded_even_negative_low == -2;
    assert rounded_even_negative_high == -4;

    let rne_positive = FloatingToInteger(2.5, NumericRound_RNE);
    let rne_negative = FloatingToInteger(-2.5, NumericRound_RNE);
    let down_positive = FloatingToInteger(2.5, NumericRound_RTM);
    let down_negative = FloatingToInteger(-2.5, NumericRound_RTM);
    let up_positive = FloatingToInteger(2.5, NumericRound_RTP);
    let up_negative = FloatingToInteger(-2.5, NumericRound_RTP);
    let zero_positive = FloatingToInteger(2.5, NumericRound_RTZ);
    let zero_negative = FloatingToInteger(-2.5, NumericRound_RTZ);
    let away_nonhalf_positive = FloatingToInteger(2.1, NumericRound_RNA);
    let away_nonhalf_negative = FloatingToInteger(-2.1, NumericRound_RNA);
    let away_positive = FloatingToInteger(2.5, NumericRound_RNA);
    let away_negative = FloatingToInteger(-2.5, NumericRound_RNA);
    let odd_exact_even = FloatingToInteger(2.0, NumericRound_RTO);
    let odd_exact_odd = FloatingToInteger(3.0, NumericRound_RTO);
    let odd_positive = FloatingToInteger(2.25, NumericRound_RTO);
    let odd_negative = FloatingToInteger(-2.25, NumericRound_RTO);
    let half_up_positive = FloatingToInteger(2.5, NumericRound_RHB);
    let half_up_negative = FloatingToInteger(-2.5, NumericRound_RHB);
    assert rne_positive == 2;
    assert rne_negative == -2;
    assert down_positive == 2;
    assert down_negative == -3;
    assert up_positive == 3;
    assert up_negative == -2;
    assert zero_positive == 2;
    assert zero_negative == -2;
    assert away_nonhalf_positive == 2;
    assert away_nonhalf_negative == -2;
    assert away_positive == 3;
    assert away_negative == -3;
    assert odd_exact_even == 2;
    assert odd_exact_odd == 3;
    assert odd_positive == 3;
    assert odd_negative == -3;
    assert half_up_positive == 3;
    assert half_up_negative == -2;

    assert ResolveScalarFPActiveRoundingMode('000') == NumericRound_RNE;
    assert ResolveScalarFPActiveRoundingMode('001') == NumericRound_RTM;
    assert ResolveScalarFPActiveRoundingMode('010') == NumericRound_RTP;
    assert ResolveScalarFPActiveRoundingMode('011') == NumericRound_RTZ;
    // Active FRM has only four modes. Reserved raw values use the specified
    // RNE fallback and never inherit the bundle namespace.
    assert ResolveScalarFPActiveRoundingMode('100') == NumericRound_RNE;
    assert ResolveScalarFPActiveRoundingMode('111') == NumericRound_RNE;

    let bundle_none = DecodeBundleRoundingSelection('000');
    let bundle_rne = DecodeBundleRoundingSelection('001');
    let bundle_rtz = DecodeBundleRoundingSelection('010');
    let bundle_rdn = DecodeBundleRoundingSelection('011');
    let bundle_rup = DecodeBundleRoundingSelection('100');
    let bundle_rna = DecodeBundleRoundingSelection('101');
    let bundle_rto = DecodeBundleRoundingSelection('110');
    let bundle_rhb = DecodeBundleRoundingSelection('111');
    assert bundle_none.use_operation_default;
    assert bundle_rne.rounding_mode == NumericRound_RNE;
    assert bundle_rtz.rounding_mode == NumericRound_RTZ;
    assert bundle_rdn.rounding_mode == NumericRound_RTM;
    assert bundle_rup.rounding_mode == NumericRound_RTP;
    assert bundle_rna.rounding_mode == NumericRound_RNA;
    assert bundle_rto.rounding_mode == NumericRound_RTO;
    assert bundle_rhb.rounding_mode == NumericRound_RHB;

    let (public_none_valid, public_none) =
        DecodePublicConversionRoundingSelection('000');
    let (public_round_valid, public_round) =
        DecodePublicConversionRoundingSelection('010');
    let (public_floor_valid, public_floor) =
        DecodePublicConversionRoundingSelection('011');
    let (public_trunc_valid, public_trunc) =
        DecodePublicConversionRoundingSelection('101');
    let (public_odd_valid, public_odd) =
        DecodePublicConversionRoundingSelection('110');
    let (public_reserved_valid, -) =
        DecodePublicConversionRoundingSelection('111');
    assert public_none_valid && public_none.use_operation_default;
    assert public_round_valid &&
           public_round.rounding_mode == NumericRound_RNA;
    assert public_floor_valid &&
           public_floor.rounding_mode == NumericRound_RTM;
    assert public_trunc_valid &&
           public_trunc.rounding_mode == NumericRound_RTZ;
    assert public_odd_valid && public_odd.rounding_mode == NumericRound_RTO;
    assert !public_reserved_valid;

    let (fp_binary, fp_binary_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, Zeros{5},
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert fp_binary == Zeros{PTO_XLEN} + 5;
    assert fp_binary_flags == Zeros{5};
    let (fp_unary, fp_unary_flags) = ScalarFPUnaryProfile(
        FloatingUnary_EXP, NumericRound_RNE, Zeros{5}, Zeros{PTO_XLEN} + 4);
    assert fp_unary == Zeros{PTO_XLEN} + 5;
    assert fp_unary_flags == Zeros{5};
    let (fp_fused, fp_fused_flags) = ScalarFPFusedProfile(
        FloatingFused_MADD, NumericRound_RNE, Zeros{5}, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert fp_fused == Zeros{PTO_XLEN} + 7;
    assert fp_fused_flags == Zeros{5};
    let (fp_integer, fp_integer_flags) = ScalarFPToIntegerProfile(
        NumericRound_RNE, Zeros{5}, Zeros{5}, Zeros{PTO_XLEN} + 9);
    assert fp_integer == Zeros{PTO_XLEN} + 9;
    assert fp_integer_flags == Zeros{5};
    let (fp_convert, fp_convert_flags) = ScalarFPConvertProfile(
        NumericRound_RNE, Zeros{5} + 1, Zeros{5}, Zeros{PTO_XLEN} + 10);
    assert fp_convert == Zeros{PTO_XLEN} + 10;
    assert fp_convert_flags == Zeros{5};
    let (integer_fp, integer_fp_flags) = ScalarIntegerToFPProfile(
        NumericRound_RNE, Zeros{5}, Zeros{5} + 1, Zeros{PTO_XLEN} + 11);
    assert integer_fp == Zeros{PTO_XLEN} + 11;
    assert integer_fp_flags == Zeros{5};

    let tile_square_root = TileSquareRoot(Zeros{PTO_XLEN} + 9);
    let tile_logarithm = TileLogarithm(Zeros{PTO_XLEN} + 9);
    assert tile_square_root == Zeros{PTO_XLEN} + 9;
    assert tile_logarithm == Zeros{PTO_XLEN} + 9;
    let reciprocal_three = TileReciprocal(Zeros{PTO_XLEN} + 3);
    assert reciprocal_three == DivideWordUnsigned(
        Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 3);
    let tile_exponential = TileExponential(Zeros{PTO_XLEN} + 4);
    let tile_exp_difference = TileExpDifference(Zeros{PTO_XLEN} + 9,
        Zeros{PTO_XLEN} + 4);
    assert tile_exponential == Zeros{PTO_XLEN} + 5;
    assert tile_exp_difference == Zeros{PTO_XLEN} + 5;

    let converted_tile = TileProfileConvert(Zeros{PTO_XLEN} + 0x123,
        TileDataType_U64, TileDataType_U8, DefaultNumericExecutionControl());
    assert converted_tile == Zeros{PTO_XLEN} + 0x23;
    let quantized_tile = TileProfileQuantize(Zeros{PTO_XLEN} + 20,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 1,
        TileDataType_U64, TileDataType_U8, DefaultNumericExecutionControl());
    assert quantized_tile == Zeros{PTO_XLEN} + 6;
    let dequantized_tile = TileProfileDequantize(Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 1,
        TileDataType_U8, TileDataType_U64, DefaultNumericExecutionControl());
    assert dequantized_tile == Zeros{PTO_XLEN} + 18;

    assert AtomicAddress(Zeros{PTO_XLEN} + 128, FALSE) ==
        Zeros{PTO_XLEN} + 128;
    assert AtomicAddress(Zeros{PTO_XLEN} + 128, TRUE) ==
        Zeros{PTO_XLEN} + 128;
    let translated_address = TranslateDataAddress(
        Zeros{PTO_XLEN} + 256, 8, FALSE);
    assert translated_address == Zeros{PTO_XLEN} + 256;
    SetCurrentACR(2);
    let application_data_permitted = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3064, 8, FALSE);
    let application_data_denied = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3072, 8, FALSE);
    assert application_data_permitted;
    assert !application_data_denied;
    assert SystemRegisterAccessPermitted(
        Zeros{24} + 0x0000, FALSE, CurrentACR());
    assert !SystemRegisterAccessPermitted(
        Zeros{24} + 0x0f00, FALSE, CurrentACR());
    ClearFault();
    - = ReadSystemRegisterAddress(Zeros{24} + 0x0f00);
    assert _LastFault == Fault_IllegalInstruction;
    SetCurrentACR(0);
    let root_data_permitted = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3072, 8, TRUE);
    assert root_data_permitted;
    assert SystemRegisterAccessPermitted(
        Zeros{24} + 0x0f00, TRUE, CurrentACR());

    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    WriteBPC(Zeros{PTO_XLEN} + 0x600);
    _BundleArgument = Zeros{PTO_XLEN} + 0x77;
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    SaveTrapContext(1, CurrentACR());
    let saved_control = ReadSystemRegisterAddress(Zeros{24} + 0x1f40);
    let saved_bpc = ReadSystemRegisterAddress(Zeros{24} + 0x1f41);
    let saved_tpc = ReadSystemRegisterAddress(Zeros{24} + 0x1f43);
    assert saved_control[4] == '1';
    assert saved_bpc == Zeros{PTO_XLEN} + 0x600;
    assert saved_tpc == Zeros{PTO_XLEN} + 0x500;
    WriteSystemRegisterAddress(Zeros{24} + 0x1f41,
        Zeros{PTO_XLEN} + 0x610);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f43,
        Zeros{PTO_XLEN} + 0x510);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f45,
        Zeros{PTO_XLEN} + 0x22);
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    WriteBPC(Zeros{PTO_XLEN} + 0x800);
    _BundleArgument = Zeros{PTO_XLEN};
    let recovered_context = RecoverTrapContext(1);
    assert recovered_context;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x510;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x610;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x77;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert PTOv0ReadContextRegister(1, 0x0f40)[4] == '0';

    let before_failed_recovery = _ArchitectureRequestEpoch;
    ClearFault();
    ArchitectureEnterRequest('0001');
    assert _LastFault == Fault_ExecutionStateCheck;
    assert _ACRTrapNumber[[CurrentACR()]] == Zeros{6};
    assert _ACRTrapArgumentValid[[CurrentACR()]];
    assert _ACRTrapArgument0[[CurrentACR()]] == Zeros{PTO_XLEN} + 0x510;
    assert _ArchitectureRequestEpoch == before_failed_recovery;

    let tile_binary = TileProfileBinary(TileBinary_ADD, TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    let tile_unary = TileProfileUnary(TileUnary_NEG, TileDataType_S64,
        Zeros{PTO_XLEN} + 2);
    let tile_compare = TileProfileCompare(TileComparison_LT, TileDataType_S64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    let reduction_initial = TileProfileReductionInitial(
        TileReduction_SUM, TileDataType_U64, Zeros{PTO_XLEN} + 9);
    assert tile_binary == Zeros{PTO_XLEN} + 5;
    assert tile_unary == Zeros{PTO_XLEN} - 2;
    assert tile_compare == Zeros{PTO_XLEN} + 1;
    assert reduction_initial == Zeros{PTO_XLEN};
    let (reduction_sum, reduction_selected) = TileProfileReductionStep(
        TileReduction_SUM, TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert reduction_sum == Zeros{PTO_XLEN} + 5;
    assert !reduction_selected;
    let tile_expand = TileProfileExpand(TileExpand_ADD, TileDataType_U64,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 5);
    let tile_partial = TileProfilePartialValue(TilePartial_MUL,
        TileDataType_U64, Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 5);
    let tile_order_left = TileProfileOrderLeft(Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 5, FALSE, TileDataType_S64);
    let raw_profile_nan = TileProfileValueIsNaN(
        Zeros{PTO_XLEN} + 0x7ff8000000000000, TileDataType_FP64);
    let matrix_accumulate = TileProfileMatrixAccumulate(
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3,
        TileDataType_U64, TileDataType_U64, TileDataType_U64);
    let matrix_bias = TileProfileMatrixBias(Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 2, TileDataType_U64, TileDataType_U64);
    let matrix_scaled_accumulate = TileProfileMatrixScaledAccumulate(
        Zeros{PTO_XLEN} + 5, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 6, TileDataType_FP32,
        TileDataType_E4M3, TileDataType_E5M2,
        TileDataType_E8M0, TileDataType_E8M0);
    assert tile_expand == Zeros{PTO_XLEN} + 9;
    assert tile_partial == Zeros{PTO_XLEN} + 20;
    assert tile_order_left;
    assert !raw_profile_nan;
    assert matrix_accumulate == Zeros{PTO_XLEN} + 7;
    assert matrix_bias == Zeros{PTO_XLEN} + 9;
    assert matrix_scaled_accumulate == Zeros{PTO_XLEN} + 149;

    WriteTPC(Zeros{PTO_XLEN} + 0x120);
    WriteBPC(Zeros{PTO_XLEN} + 0x100);
    SetCurrentACR(2);
    SaveTrapContext(1, CurrentACR());
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteBPC(Zeros{PTO_XLEN} + 0x208);
    SetCurrentACR(0);
    let recovered_trap_context = RecoverTrapContext(1);
    assert recovered_trap_context;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x120;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x100;
    assert CurrentACR() == 2;

    WriteGPR(1, Zeros{PTO_XLEN} + 0x55);
    WriteGPR(23, Zeros{PTO_XLEN} + 0x66);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);
    WriteExecutionMask(Zeros{PTO_XLEN} + 0x33);
    WritePredicateRegister(0, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH} + 0x77);
    Store(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 0xaa);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 2048, 8,
        Zeros{PTO_XLEN});
    _MemoryEventCaptureEnabled = TRUE;
    _CurrentMemoryAgent = 3;
    _ExtendedSystemRegisters[[0x0f00]] = Ones{PTO_XLEN};
    _ExtendedSystemRegisters[[0x1f01]] = Ones{PTO_XLEN};
    _ExtendedSystemRegisters[[0xffb7]] = Ones{PTO_XLEN};
    ConfigureTile(0, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(63, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(63, 0, 0, Zeros{PTO_XLEN} + 2);
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    SetBundleScalarBinding(31, 1, 2, 3, 4, 3);
    SetBundleTileBinding(15, TRUE, 3, 3, '1111', TRUE, TRUE, 0, 63,
        TRUE);
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);
    SetBundleDataAttributeState(Zeros{5} + 1, Zeros{5} + 2,
        Zeros{2} + 3, Zeros{3} + 1, Zeros{3} + 2, TRUE);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x80;
    _ReservationSize = 8;
    _ACRTrapNumber[[15]] = Zeros{6} + 52;
    _ACRTrapArgument0[[15]] = Ones{PTO_XLEN};
    _TrapContexts[[15]].valid = TRUE;
    _TrapContexts[[15]].execution_mask = Zeros{PTO_XLEN};
    _TrapContexts[[15]].predicates[[7]] = Ones{PTO_PREDICATE_WIDTH};
    _SystemRegisters.thread_ptr = Ones{PTO_XLEN};
    _SystemRegisters.global_ptr = Ones{PTO_XLEN};
    _SystemRegisters.core_feature_enable = Ones{PTO_XLEN};
    SetCurrentACR(2);
    ResetProfileState();
    assert CurrentACR() == 0;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    assert ReadGPR(23) == Zeros{PTO_XLEN};
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN};
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN};
    assert ReadExecutionMask() == Zeros{PTO_XLEN};
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(7) == Zeros{PTO_PREDICATE_WIDTH};
    assert _MemoryEventCount == 0;
    assert !_MemoryEventCaptureEnabled;
    assert _CurrentMemoryAgent == 0;
    let reset_memory = LoadUnsigned(Zeros{PTO_XLEN}, 8);
    assert reset_memory == Zeros{PTO_XLEN};
    let final_reset_time = ReadMonotonicTime();
    assert final_reset_time == Zeros{PTO_XLEN};
    assert _SystemRegisters.version == Zeros{PTO_XLEN} + 1;
    assert _SystemRegisters.tile_capacity ==
        Zeros{PTO_XLEN} + PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    assert _SystemRegisters.thread_id == Zeros{PTO_XLEN};
    assert _SystemRegisters.thread_ptr == Zeros{PTO_XLEN};
    assert _SystemRegisters.global_ptr == Zeros{PTO_XLEN};
    assert _SystemRegisters.core_feature_enable == Zeros{PTO_XLEN};
    assert !_BundleActive && !_BundleBodyActive;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN};
    assert !_BundleScalarBindings[[31]].valid;
    assert !_BundleTileBindings[[15]].valid;
    assert !_BundleControlAttributes.trap_enabled;
    assert !_BundleDataAttributes.saturating;
    assert !_Tiles[[0]].allocated && !_Tiles[[63]].allocated;
    assert !_Tiles[[0]].contents_defined && !_Tiles[[63]].contents_defined;
    assert _Tiles[[0]].capacity_bytes == 0 &&
        _Tiles[[63]].capacity_bytes == 0;
    assert !_ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN};
    assert _ReservationSize == 1;
    for ring = 0 to PTO_ACR_COUNT - 1 do
        assert _ACRTrapNumber[[ring]] == Zeros{6};
        assert _ACRTrapArgument0[[ring]] == Zeros{PTO_XLEN};
        assert !_TrapContexts[[ring]].valid;
        assert _TrapContexts[[ring]].execution_mask == Zeros{PTO_XLEN};
        assert _TrapContexts[[ring]].predicates[[0]] ==
            Zeros{PTO_PREDICATE_WIDTH};
        assert _TrapContexts[[ring]].predicates[[7]] ==
            Zeros{PTO_PREDICATE_WIDTH};
    end;
    assert _ExtendedSystemRegisters[[0x0f00]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0x1f01]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0xffb7]] == Zeros{PTO_XLEN};
end;
