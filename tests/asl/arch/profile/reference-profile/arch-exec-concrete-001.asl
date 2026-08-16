// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-SUBNORMAL-EXEC-001","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile subnormal boundaries and applicability are exact","pass_condition":"subnormal configuration, boundary, and applicability assertions hold","related_sources":[]}
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

func TestConcreteSubnormalProfile()
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
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteSubnormalProfile();
    return 0;
end;
