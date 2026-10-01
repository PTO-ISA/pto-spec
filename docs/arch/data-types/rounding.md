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

`NumericRoundingMode` is the semantic enumeration of rounding modes, and `NumericExecutionControl` is the two-field record that pairs one mode with a `saturating` flag. The same file also declares the bounded `NumericApplicabilityRuleSet` enumeration.

The unit owns meanings only. It reads no selector field and rounds no value, so a consumer must resolve its encoded selector into `NumericRoundingMode` first and then hand the record to the operation.

Design point: scalar `FRM`, the fixed conversion overrides, bundle `RMode`, and the public API controls are four different encodings of the same small set of meanings, and each meaning appears once in this enumeration. The consequence is that an enum position is never an encoding anywhere, and the same three bits can mean two different modes in two namespaces: `010` selects `NumericRound_RTP` for scalar `FRM` in `ResolveScalarFPActiveRoundingMode`, while `010` selects `NumericRound_RTZ` for bundle `RMode` in `DecodeBundleRoundingSelection`.

<!-- PTO-READER-BLOCK: arch-rounding-concepts-state role=concepts-state -->
## Concepts and visible state

- `NumericRoundingMode` has seven members: `NumericRound_RNE`, `NumericRound_RTM`, `NumericRound_RTP`, `NumericRound_RTZ`, `NumericRound_RNA`, `NumericRound_RTO`, and `NumericRound_RHB`.
- `NumericExecutionControl` has exactly two fields, `rounding_mode: NumericRoundingMode` and `saturating: boolean`.
- `NumericApplicabilityRuleSet` has two members, `NumericApplicabilityRules_None` and `NumericApplicabilityRules_MxRejection`.

Design point: `DefaultNumericExecutionControl()` returns `NumericRound_RNE` together with `saturating = FALSE` as one value, not as two independent defaults. A consumer that needs the architectural default obtains both fields from a single call, so the default mode cannot be paired with a different saturation setting by choosing only one of them.

<!-- PTO-READER-BLOCK: arch-rounding-rules-interactions role=rules-interactions -->
## Rules and interactions

The architectural default is `NumericRound_RNE` with `saturating = FALSE`. `DefaultNumericExecutionControl` is a `pure func` that takes no argument, so its result depends on no register and on no encoded field.

Resolving an instruction default is a separate step with its own owner. `ResolveTileNumericExecutionControl` copies the operand control and, when the instruction asks for the operation default, replaces `rounding_mode` with `NumericRound_RNE`, or with `NumericRound_RTZ` when the operation is `TileOperation_TCVT` with a floating source and a non-floating destination. That branch does not change `saturating`.

Design point: the operation default is applied by the resolver rather than by editing `DefaultNumericExecutionControl`. The consequence is that the two situations stay distinguishable: an explicit control keeps the mode the caller encoded, and a defaulted control has only its `rounding_mode` replaced while `saturating` is carried over unchanged from the operand control.

<!-- PTO-READER-BLOCK: arch-rounding-boundaries role=boundaries -->
## Architectural boundaries

This unit defines no algorithm. Which value an operation rounds, and how a rounded result becomes a `Word`, belong to the operation and profile ASL.

`NumericApplicabilityRuleSet` selects only a bounded set of accepted negative applicability rules. A missing rejection does not claim that a target supports anything, and it does not select result semantics.

Design point: `NumericApplicabilityRules_MxRejection` is a named rule set rather than a boolean "rejected" flag. Because the enumeration names which negative rules are active, the value has no meaning outside the owner that selected the rule set, and that owner still decides whether a particular operand is rejected.

<!-- PTO-READER-BLOCK: arch-rounding-example-usage role=example-usage -->
## Non-normative reading example

A scalar floating-point operation reads its active mode from an encoded field: `ScalarFPActiveRoundingMode` passes `core_state[39:37]` to `ResolveScalarFPActiveRoundingMode`, which maps `001` to `NumericRound_RTM`, `010` to `NumericRound_RTP`, `011` to `NumericRound_RTZ`, and every other value to `NumericRound_RNE`.

A fixed conversion does not consult that field. `ScalarFPFixedConversionRoundingMode` maps `ScalarOperation_FCVTA` to `NumericRound_RNA`, `ScalarOperation_FCVTM` to `NumericRound_RTM`, `ScalarOperation_FCVTN` to `NumericRound_RNE`, `ScalarOperation_FCVTP` to `NumericRound_RTP`, and `ScalarOperation_FCVTZ` to `NumericRound_RTZ`.

A bundle selector reaches the same type through two steps: `DecodeBundleRoundingSelection` turns the three-bit `RMode` into a selection whose `rounding_mode` is one of the seven members, and `ResolveTileNumericExecutionControl` reads that selection from the operands and produces the `NumericExecutionControl` this unit declares.

<!-- PTO-READER-BLOCK: arch-rounding-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric classification](numeric-classification.md)
- [Floating point](floating-point.md)
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

// Selects only a bounded set of accepted negative applicability rules.
// Absence of a rejection does not claim support or select numeric result
// semantics.
type NumericApplicabilityRuleSet of enumeration {
    NumericApplicabilityRules_None,
    NumericApplicabilityRules_MxRejection
};
```
<!-- GENERATED-ASL-END: unit -->
