<!-- GENERATED FROM: asl/arch/data-types/rounding.asl -->
# Rounding

**Normative ASL source:** `asl/arch/data-types/rounding.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-ROUNDING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-rounding-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the semantic rounding-mode namespace and the common execution-control record used after encoded selectors have been resolved.

It separates mathematical mode identity from scalar `FRM`, fixed conversion overrides, bundle `RMode`, and public API selector encodings.

<!-- PTO-READER-BLOCK: arch-rounding-concepts-state role=concepts-state -->
## Concepts and visible state

- `NumericRoundingMode` contains `RNE`, `RTM`, `RTP`, `RTZ`, `RNA`, `RTO`, and `RHB` semantic modes.
- `NumericExecutionControl` pairs a `NumericRoundingMode` with a `saturating` boolean.
- `NumericApplicabilityRuleSet` names no extra rejection or the bounded `A2A3MxRejection` rule set.

<!-- PTO-READER-BLOCK: arch-rounding-rules-interactions role=rules-interactions -->
## Rules and interactions

`DefaultNumericExecutionControl` selects `NumericRound_RNE` with `saturating = FALSE`.

Every encoded selector namespace must resolve explicitly into `NumericRoundingMode`; enum position is not an implicit wire encoding.

The applicability enum is only a bounded negative-rule selector. Lack of rejection does not claim target support or select result semantics.

<!-- PTO-READER-BLOCK: arch-rounding-boundaries role=boundaries -->
## Architectural boundaries

These types do not define how an arithmetic operation rounds a particular value. Exact result algorithms remain with operation/profile owners.

`A2A3MxRejection` is a named target-facing rule set, not portable PTO behavior that can be applied outside its selecting owner.

<!-- PTO-READER-BLOCK: arch-rounding-example-usage role=example-usage -->
## Non-normative reading example

A bundle `RMode` code is first decoded by its owner and only then becomes, for example, `NumericRound_RTZ`; this page does not equate their numeric encodings.

A consumer that needs the architectural default can call `DefaultNumericExecutionControl` rather than reproducing `RNE` and non-saturating defaults locally.

<!-- PTO-READER-BLOCK: arch-rounding-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric classification](numeric-classification.md)
- [Hardware numeric profile](../features/mx-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/rounding.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
