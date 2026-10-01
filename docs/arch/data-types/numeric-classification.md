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

This unit defines the value-class vocabulary and the numeric-policy records shared by every Tile numeric format.

It is a type and helper unit, so it describes what a value is and how a policy is selected, not what any operation computes.

<!-- PTO-READER-BLOCK: arch-numeric-classification-concepts-state role=concepts-state -->
## Concepts and visible state

`NumericValueClass` contains `NumericValue_InvalidEncoding`, the signed zero and subnormal and normal and infinity classes, and `NumericValue_QuietNaN` together with `NumericValue_SignalingNaN`.

The subnormal rules are separate for inputs and results: `NumericInputSubnormalRule` holds `NumericInputSubnormal_NotApplicable` or `NumericInputSubnormal_Preserve`, and `NumericResultSubnormalRule` holds `NumericResultSubnormal_NotApplicable` or `NumericResultSubnormal_GradualUnderflow`.

`TileNumericSelection` records whether an operation default is used, the selected `NumericRoundingMode`, and whether the operation saturates.

<!-- PTO-READER-BLOCK: arch-numeric-classification-rules-interactions role=rules-interactions -->
## Rules and interactions

Design point: inputs and results keep separate subnormal rules because preserving a subnormal operand and producing a gradual-underflow result are different behaviours, so one switch could not express a configuration that does one without the other.

`NumericValueClassIsNaN`, `NumericValueClassIsInfinity`, `NumericValueClassIsZero`, and `NumericValueClassIsSubnormal` each test only their own named class pair and return a boolean.

`NumericTininessDetectionRule` distinguishes `NumericTininessDetection_NotApplicable` from `NumericTininessDetection_AfterRounding`, and the integer classifiers `ClassifySignedInteger` and `ClassifyUnsignedInteger` are owned by the hardware numeric profile rather than by this unit.

<!-- PTO-READER-BLOCK: arch-numeric-classification-boundaries role=boundaries -->
## Architectural boundaries

Classification is a format property: it reports which category a raw carrier falls into and does not itself choose an exception flag, a rounding mode, a saturation decision, or a result value.

`NumericValue_InvalidEncoding` is a class of its own, so a carrier that a format rejects is distinguishable from a carrier that denotes a NaN.

This unit has no format descriptor and no decomposition function, so the value-class declarations and the four boolean class tests above are the complete definition.

<!-- PTO-READER-BLOCK: arch-numeric-classification-example-usage role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Design point: invalid encoding is separated from the value classes because rejection happens before any numeric interpretation, so a consumer can tell a malformed carrier from a well-formed non-finite one.

The input and result subnormal enumerations describe the named hardware numeric profile, and the comment in the owner states that they are not general `pto-v0` arithmetic behaviour.

A value class does not prove that an operation supports the corresponding data type, because support remains with the active operation and profile owner.

<!-- PTO-READER-BLOCK: arch-numeric-classification-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric format dispatch](numeric-formats.md) dispatches a Tile data type to its descriptor and finite decomposition.

- [Rounding types](rounding.md) defines the rounding modes named by a selection record.

- [Hardware numeric profile](../features/mx-formats.md) applies these rules to declared types.
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

// PTO-REQ-RESET-001, PTO-REQ-HARDWARE-NUMERIC-001:
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
