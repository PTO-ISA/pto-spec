// PTO-TEST: {"id":"PTO-AVS-ARCH-MX-SUBNORMAL-BOUNDARIES-EXEC-001","source":"asl/arch/features/mx-formats.asl","requirements":[],"kind":"execution","summary":"hardware-profile subnormal rules and exact representative boundaries are executable","pass_condition":"configuration, policy, boundary, and unsupported-type assertions hold","related_sources":["asl/arch/data-types/numeric-classification.asl"]}
func main() => integer
begin
    assert HardwareNumericSubnormalConfigurationValid(FALSE, FALSE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(TRUE, FALSE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(FALSE, TRUE, FALSE);
    assert !HardwareNumericSubnormalConfigurationValid(FALSE, FALSE, TRUE);

    assert HardwareNumericTypeHasSubnormals(TileDataType_FP32);
    assert HardwareNumericInputSubnormalRule(TileDataType_FP32) ==
        NumericInputSubnormal_Preserve;
    assert HardwareNumericResultSubnormalRule(TileDataType_FP32) ==
        NumericResultSubnormal_GradualUnderflow;
    assert HardwareNumericTininessDetectionRule(TileDataType_FP32) ==
        NumericTininessDetection_AfterRounding;
    let (fp32_available, fp32_minimum, fp32_maximum, fp32_normal) =
        HardwareNumericSubnormalBoundaries(TileDataType_FP32);
    assert fp32_available;
    assert fp32_minimum == Zeros{PTO_XLEN} + 0x1;
    assert fp32_maximum == Zeros{PTO_XLEN} + 0x007fffff;
    assert fp32_normal == Zeros{PTO_XLEN} + 0x00800000;

    let (tf32_available, tf32_minimum, tf32_maximum, tf32_normal) =
        HardwareNumericSubnormalBoundaries(TileDataType_TF32);
    assert tf32_available;
    assert tf32_minimum == Zeros{PTO_XLEN} + 0x00002000;
    assert tf32_maximum == Zeros{PTO_XLEN} + 0x007fe000;
    assert tf32_normal == Zeros{PTO_XLEN} + 0x00800000;

    assert !HardwareNumericTypeHasSubnormals(TileDataType_S32);
    let (integer_available, integer_minimum, integer_maximum, integer_normal) =
        HardwareNumericSubnormalBoundaries(TileDataType_S32);
    assert !integer_available;
    assert integer_minimum == Zeros{PTO_XLEN};
    assert integer_maximum == Zeros{PTO_XLEN};
    assert integer_normal == Zeros{PTO_XLEN};
    return 0;
end;
