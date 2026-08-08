// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","surface":"arch","classification":["data-types","numeric-classification"],"depends_on":["PTO-ARCH-DATA-TYPES-ROUNDING"]}
type NumericValueClass of enumeration {
    NumericValue_InvalidEncoding,
    NumericValue_PositiveZero,
    NumericValue_NegativeZero,
    NumericValue_PositiveSubnormal,
    NumericValue_NegativeSubnormal,
    NumericValue_PositiveNormal,
    NumericValue_NegativeNormal,
    NumericValue_PositiveInfinity,
    NumericValue_NegativeInfinity,
    NumericValue_QuietNaN,
    NumericValue_SignalingNaN
};

// Input and result subnormal rules are intentionally separate. They describe
// the named hardware numeric profile and are not pto-v0 arithmetic behavior.
type NumericInputSubnormalRule of enumeration {
    NumericInputSubnormal_NotApplicable,
    NumericInputSubnormal_Preserve
};

type NumericResultSubnormalRule of enumeration {
    NumericResultSubnormal_NotApplicable,
    NumericResultSubnormal_GradualUnderflow
};

type NumericTininessDetectionRule of enumeration {
    NumericTininessDetection_NotApplicable,
    NumericTininessDetection_AfterRounding
};

type TileNumericSelection of record {
    use_operation_default: boolean,
    rounding_mode: NumericRoundingMode,
    saturating: boolean
};

// PTO-REQ-PROFILE-001, PTO-REQ-HARDWARE-NUMERIC-001:
// bit-exact value classification for every TileDataType.

pure func NumericValueClassIsNaN(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_QuietNaN ||
           value_class == NumericValue_SignalingNaN;
end;

pure func NumericValueClassIsInfinity(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveInfinity ||
           value_class == NumericValue_NegativeInfinity;
end;

pure func NumericValueClassIsZero(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveZero ||
           value_class == NumericValue_NegativeZero;
end;

pure func NumericValueClassIsSubnormal(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveSubnormal ||
           value_class == NumericValue_NegativeSubnormal;
end;

