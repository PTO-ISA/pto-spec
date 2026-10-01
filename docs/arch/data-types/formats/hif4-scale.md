<!-- GENERATED FROM: asl/arch/data-types/formats/hif4-scale.asl -->
# Hif4 Scale

**Normative ASL source:** `asl/arch/data-types/formats/hif4-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-hif4-scale-purpose role=purpose-scope -->
## Purpose and scope

A HiF4 Matrix scale is one raw `32`-bit word that supplies a base scale and per-lane exponent increments for `64` logical HiF4 lanes, and this unit owns its field layout, index selection, and finite value rule.

The contract `PTO-CUBE-HIF4-SCALE-001` fixes the word layout, and the ASL functions in this unit implement it.

Design point: the scale word is not a Tile data type of its own, so the descriptor function has no entry for it; one raw scale word instead fixes the increment shared by `64` logical HiF4 lanes.

<!-- PTO-READER-BLOCK: arch-hif4-scale-concepts role=concepts-state -->
## Carrier and fields

The word holds one `E6M2` base value in bits `7:0`, eight E1_8 exponent bits in bits `15:8`, and sixteen E1_16 exponent bits in bits `31:16`.

For a lane index `q` in `0..63`, `HiF4ScaleExponentIncrement` reads bit `8 + (q DIVRM 8)` and bit `16 + (q DIVRM 4)`, then returns their sum as an increment in `0..2`.

Design point: each E1_8 bit is shared by eight consecutive lanes and each E1_16 bit by four, so the increment is the sum of a coarse and a fine term rather than a per-lane field.

<!-- PTO-READER-BLOCK: arch-hif4-scale-rules role=rules-interactions -->
## Decomposition and classification

`HiF4E6M2ValueClass` forwards to `ClassifyE6M2` and `HiF4E6M2FiniteValue` forwards to `E6M2FiniteValue`, so both functions keep the `E6M2` code meaning unchanged.

`HiF4ScaleFiniteValue` asserts that the base field classifies as `NumericValue_PositiveNormal`, then multiplies the `E6M2` finite value by `FP19PowerOfTwo` of the increment.

`E6M2` codes `0x00` through `0xfe` are finite positive values with bias `48` and two fraction bits, and `0xff` is a legal quiet NaN scale.

Design point: this unit returns no availability flag; the `E6M2` base code `0xff` is excluded by the assertion in `HiF4E6M2FiniteValue`, so a non-finite base is a definedness failure rather than a value a consumer can test.

<!-- PTO-READER-BLOCK: arch-hif4-scale-boundaries role=boundaries -->
## Boundaries and exact encodings

The base field must be a positive normal value, so a scale word whose `E6M2` field is `0xff` cannot be evaluated as a finite scale; only the selected pair of exponent bits affects a given lane index.

Design point: `HiF4ScaleFiniteValue` asserts the base class before the multiplication, so a scale word whose `E6M2` field is not a positive normal value stops at the assertion instead of returning a per-lane scale.

Design point: the `E6M2` base field has no zero code, because the `E6M2` descriptor declares no zero encoding and classification never returns a zero class.

Read this page in the order of the functions: take the field positions from the `PTO-CUBE-HIF4-SCALE-001` contract, call `HiF4E6M2ValueClass` when the base value class matters, and call `HiF4ScaleFiniteValue` only for a base code that classifies as `NumericValue_PositiveNormal`.

<!-- PTO-READER-BLOCK: arch-hif4-scale-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`0x00` denotes `2^-48` and `0xfe` denotes `1.5 * 2^15`; these are the smallest and largest finite base values a scale word can carry.

`HiF4E6M2ValueClass` reports the quiet NaN class for `0xff` and the positive normal class for every other base code, and `HiF4E6M2FiniteValue` therefore asserts on `0xff`.

<!-- PTO-READER-BLOCK: arch-hif4-scale-related role=related-owners-navigation -->
## Related owners

- [Numeric format descriptor](../format-descriptor.md) defines the common metadata record.

- [Numeric formats](../numeric-formats.md) dispatches Tile data types to their format-specific helpers.

- [HiF4X2](hif4x2.md) defines the packed logical lanes that this scale word multiplies.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif4-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE","surface":"arch","classification":["data-types","formats","hif4-scale"],"depends_on":["PTO-ARCH-DATA-TYPES-FP19","PTO-ARCH-DATA-TYPES-FORMAT-E6M2"]}

// NDF-BEGIN: PTO-CUBE-HIF4-SCALE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A HiF4 Matrix scale MUST be one raw U32 word containing E6M2 in bits 7:0,
// eight E1_8 exponents in bits 15:8, and sixteen E1_16 exponents in bits
// 31:16. E6M2 values 00..FE MUST be finite with bias 48 and two fraction
// bits; FF MUST be a legal quiet NaN scale. One word scales 64 logical HiF4
// lanes through the selected E1_8 plus E1_16 exponent bits.
// NDF-END: PTO-CUBE-HIF4-SCALE-001

pure func HiF4E6M2ValueClass(value: bits(8)) => NumericValueClass
begin
    return ClassifyE6M2(value);
end;

pure func HiF4E6M2FiniteValue(value: bits(8)) => real
begin
    return E6M2FiniteValue(value);
end;

pure func HiF4ScaleExponentIncrement(
    scale_word: bits(32), q: integer {0..63}) => integer {0..2}
begin
    let e1_8_index = 8 + (q DIVRM 8);
    let e1_16_index = 16 + (q DIVRM 4);
    return UInt(scale_word[e1_8_index]) +
           UInt(scale_word[e1_16_index]);
end;

pure func HiF4ScaleFiniteValue(
    scale_word: bits(32), q: integer {0..63}) => real
begin
    assert HiF4E6M2ValueClass(scale_word[7:0]) ==
        NumericValue_PositiveNormal;
    return HiF4E6M2FiniteValue(scale_word[7:0]) *
        FP19PowerOfTwo(HiF4ScaleExponentIncrement(scale_word, q));
end;
```
<!-- GENERATED-ASL-END: unit -->
