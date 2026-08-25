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

This unit gives PTO ASL a closed vocabulary for selecting floating-point operation families. It defines operation selectors only; operand formats, rounding, exceptions, result values, and state effects remain owned by the ASL functions that consume these selectors.

<!-- PTO-READER-BLOCK: arch-floating-point-concepts role=concepts-state -->
## Operation families

`FloatingBinaryOperation` covers `ADD`, `SUB`, `MUL`, `DIV`, `MIN`, and `MAX`. `FloatingCompareOperation` covers `EQ`, `NE`, `LT`, `LE`, `GT`, and `GE`.

`FloatingUnaryOperation` covers `ABS`, `SQRT`, `EXP`, and `RECIP`; `FloatingFusedOperation` covers `MADD`, `MSUB`, `NMADD`, and `NMSUB`.

<!-- PTO-READER-BLOCK: arch-floating-point-rules role=rules-interactions -->
## Selection and interpretation

A caller passes one member of the appropriate enumeration to a numeric semantic owner. That owner, not this enumeration, determines the chosen data format and the exact arithmetic behavior.

The four enumeration types prevent a compare selector from being silently used as a binary, unary, or fused selector.

<!-- PTO-READER-BLOCK: arch-floating-point-boundaries role=boundaries -->
## Boundaries

The presence of `MIN`, `MAX`, `RECIP`, or a fused selector does not by itself define NaN selection, rounding, overflow, underflow, flags, or contraction behavior. Those questions must be answered by a reachable numeric-format or profile ASL contract.

The static AVS for this unit checks that the selector declarations compile in the complete model; this evidence statement does not define arithmetic results.

<!-- PTO-READER-BLOCK: arch-floating-point-example role=example-usage -->
## Non-normative reading example

This example illustrates selector lookup and is not an arithmetic definition.

On seeing `FloatingFused_NMSUB`, first identify the consuming ASL function, then read that owner's operand ordering, format, rounding, and exceptional-value rules before reasoning about a result.

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
