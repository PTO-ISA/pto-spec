<!-- GENERATED FROM: asl/arch/data-types/numeric-classification.asl -->
# Numeric Classification

**Normative ASL source:** `asl/arch/data-types/numeric-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-numeric-classification-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the common value classes and numeric-policy records used across every tile numeric format.

A shared classification vocabulary lets format owners report exact bit-pattern categories without selecting an arithmetic result or target implementation.

<!-- PTO-READER-BLOCK: arch-numeric-classification-concepts-state role=concepts-state -->
## Concepts and visible state

- `NumericValueClass` includes invalid encoding; signed zero, subnormal, normal, and infinity; plus quiet and signaling NaN.
- Input and result subnormal policies are separate: `NumericInputSubnormalRule` and `NumericResultSubnormalRule` do not collapse into one switch.
- `TileNumericSelection` carries whether an operation default is used, the selected `NumericRoundingMode`, and a saturating flag.

<!-- PTO-READER-BLOCK: arch-numeric-classification-rules-interactions role=rules-interactions -->
## Rules and interactions

`NumericValueClassIsNaN`, `NumericValueClassIsInfinity`, `NumericValueClassIsZero`, and `NumericValueClassIsSubnormal` test only their named class pairs.

`NumericTininessDetectionRule` distinguishes not-applicable from after-rounding detection.

Classification is a format property. It does not itself choose exception flags, rounding, saturation, or an operation result.

<!-- PTO-READER-BLOCK: arch-numeric-classification-boundaries role=boundaries -->
## Architectural boundaries

The input/result subnormal enums describe the named hardware numeric profile, not general `pto-v0` arithmetic behavior.

A value class does not prove that an operation supports the corresponding data type; support remains with the active operation and profile owner.

<!-- PTO-READER-BLOCK: arch-numeric-classification-example-usage role=example-usage -->
## Non-normative reading example

`NumericValue_NegativeZero` makes `NumericValueClassIsZero` true, but it does not make `NumericValueClassIsSubnormal` true.

A consumer may branch on NaN classification before ordinary comparison, then return to its own profile owner for the exact selected result.

<!-- PTO-READER-BLOCK: arch-numeric-classification-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric format dispatch](numeric-formats.md)
- [Rounding types](rounding.md)
- [Hardware numeric profile](../features/mx-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/numeric-classification.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
