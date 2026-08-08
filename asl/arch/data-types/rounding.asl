// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-ROUNDING","surface":"arch","classification":["data-types","rounding"],"depends_on":["PTO-ARCH-DATA-TYPES-FLOATING-POINT"]}
// Semantic rounding modes are independent of every encoded selector
// namespace. Scalar FRM, fixed conversion overrides, bundle RMode, and public
// API controls must resolve into this type explicitly.
type NumericRoundingMode of enumeration {
    NumericRound_RNE,
    NumericRound_RTM,
    NumericRound_RTP,
    NumericRound_RTZ,
    NumericRound_RNA,
    NumericRound_RTO,
    NumericRound_RHB
};

type NumericExecutionControl of record {
    rounding_mode: NumericRoundingMode,
    saturating: boolean
};

// Bit-exact value classes are format properties. They do not select an
// operation result, exception flag, target profile, or arithmetic algorithm.
pure func DefaultNumericExecutionControl() => NumericExecutionControl
begin
    return NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
end;

// Selects only a bounded set of accepted negative applicability rules. This
// is not a complete target-profile selector: absence of a rejection does not
// claim target support or select numeric result semantics.
type NumericApplicabilityRuleSet of enumeration {
    NumericApplicabilityRules_None,
    NumericApplicabilityRules_A2A3MxRejection
};

