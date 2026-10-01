<!-- GENERATED FROM: asl/arch/data-types/floating-point.asl -->
# Floating Point

**Normative ASL source:** `asl/arch/data-types/floating-point.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FLOATING-POINT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-floating-point-purpose role=purpose-scope -->
## Purpose and scope

This unit gives PTO ASL a closed vocabulary for selecting floating-point operation families. It defines operation selectors only.

The four enumerations cover ordinary arithmetic, comparison, unary evaluation, and fused multiply-add forms; each one is a separate type.

<!-- PTO-READER-BLOCK: arch-floating-point-concepts role=concepts-state -->
## Concepts and visible state

`FloatingBinaryOperation` contains `FloatingBinary_ADD`, `FloatingBinary_SUB`, `FloatingBinary_MUL`, `FloatingBinary_DIV`, `FloatingBinary_MIN`, and `FloatingBinary_MAX`, and a caller selects one of those members as the operation identity.

`FloatingCompareOperation` contains `EQ`, `NE`, `LT`, `LE`, `GT`, and `GE`; `FloatingUnaryOperation` contains `ABS`, `SQRT`, `EXP`, and `RECIP`; `FloatingFusedOperation` contains `MADD`, `MSUB`, `NMADD`, and `NMSUB`.

Design point: four enumerations instead of one mean a compare selector cannot be passed where a binary selector is expected, so a mismatched operation kind is a type error rather than a silent reinterpretation.

<!-- PTO-READER-BLOCK: arch-floating-point-rules role=rules-interactions -->
## Rules and interactions

A caller passes one member of the matching enumeration to a numeric semantic owner, and that owner decides the operand format and the exact arithmetic result.

Selecting `MIN`, `MAX`, `RECIP`, or a fused form does not define NaN selection, rounding, or exceptional-value handling; those questions belong to the consuming owner.

`NMADD` and `NMSUB` are separate members from `MADD` and `MSUB`, so the sign of the product in a fused operation is carried by the operation identity rather than by an operand flag.

<!-- PTO-READER-BLOCK: arch-floating-point-boundaries role=boundaries -->
## Architectural boundaries

Because the selectors carry no format, the same selector can be used by an owner that accepts more than one data type without the enumeration itself claiming that support.

This unit declares no arithmetic and no state, so a selector that no consumer references has no observable effect.

This unit declares four enumerations and no functions, so the member lists above are the complete scope and the consuming owner supplies the operation semantics.

<!-- PTO-READER-BLOCK: arch-floating-point-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Reading a result means reading the consuming operation profile, which supplies the format, the rounding mode, and the exceptional-value rule.

On seeing `FloatingFused_NMSUB`, first identify the consuming ASL function, then read that owner's operand ordering, format, rounding, and exceptional-value rules before reasoning about a result.

Because the selectors carry no format, this unit does not accept an operand, produce a value, or record numeric status; all of that stays with the consuming operation profile.

<!-- PTO-READER-BLOCK: arch-floating-point-related role=related-owners-navigation -->
## Related owners

- [Rounding](rounding.md) defines the architecture's rounding vocabulary.

- [Numeric formats](numeric-formats.md) connects Tile data types to their exact format helpers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/floating-point.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FLOATING-POINT","surface":"arch","classification":["data-types","floating-point"],"depends_on":["PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS"]}
type FloatingBinaryOperation of enumeration {
    FloatingBinary_ADD,
    FloatingBinary_SUB,
    FloatingBinary_MUL,
    FloatingBinary_DIV,
    FloatingBinary_MIN,
    FloatingBinary_MAX
};

type FloatingCompareOperation of enumeration {
    FloatingCompare_EQ,
    FloatingCompare_NE,
    FloatingCompare_LT,
    FloatingCompare_LE,
    FloatingCompare_GT,
    FloatingCompare_GE
};

type FloatingUnaryOperation of enumeration {
    FloatingUnary_ABS,
    FloatingUnary_SQRT,
    FloatingUnary_EXP,
    FloatingUnary_RECIP
};

type FloatingFusedOperation of enumeration {
    FloatingFused_MADD,
    FloatingFused_MSUB,
    FloatingFused_NMADD,
    FloatingFused_NMSUB
};
```
<!-- GENERATED-ASL-END: unit -->
