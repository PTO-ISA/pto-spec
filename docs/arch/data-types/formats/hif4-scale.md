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

A HiF4 Matrix scale is one `32`-bit raw word used with `64` logical HiF4 lanes. This page explains how the base E6M2 field and two levels of exponent-selection bits combine; exact behavior remains in `PTO-CUBE-HIF4-SCALE-001` and its ASL functions.

<!-- PTO-READER-BLOCK: arch-hif4-scale-concepts role=concepts-state -->
## Scale-word layout

Bits `7:0` hold one E6M2 base scale, bits `15:8` hold eight E1_8 exponent bits, and bits `31:16` hold sixteen E1_16 exponent bits.

For lane index `q` in `0..63`, `HiF4ScaleExponentIncrement` selects bit `8 + (q DIVRM 8)` and bit `16 + (q DIVRM 4)`, then adds the two selected bits to produce an increment from `0` through `2`.

<!-- PTO-READER-BLOCK: arch-hif4-scale-rules role=rules-interactions -->
## Base value and lane scale

E6M2 encodings `0x00` through `0xfe` are finite positive values with bias `48` and two fraction bits. `0xff` is a legal quiet NaN scale.

For a finite base, `HiF4ScaleFiniteValue` multiplies `HiF4E6M2FiniteValue` by `FP19PowerOfTwo(increment)`, where `increment` is returned by `HiF4ScaleExponentIncrement`. The function requires the base field to classify as `NumericValue_PositiveNormal`.

<!-- PTO-READER-BLOCK: arch-hif4-scale-boundaries role=boundaries -->
## Boundaries

`0x00` denotes `2^-48`; `0xfe` denotes `1.5 * 2^15`; `0xff` is not accepted by `HiF4E6M2FiniteValue` because it is the quiet NaN encoding.

Each E1_8 bit is shared by eight consecutive logical lanes, while each E1_16 bit is shared by four. The selected pair, not the other exponent bits in the word, affects a given `q`.

<!-- PTO-READER-BLOCK: arch-hif4-scale-example role=example-usage -->
## Non-normative reading example

This example illustrates indexing and does not add a scale rule.

With base `0x00`, E1_8 bit `8` set, and E1_16 bit `16` set, lane `q = 0` gets increment `2` and scale `2^-46`; lane `q = 8` selects different exponent bits and gets increment `0` in the AVS fixture.

<!-- PTO-READER-BLOCK: arch-hif4-scale-related role=related-owners-navigation -->
## Related owners

- [FP19](../fp19.md) provides `FP19PowerOfTwo`.
- [HiF4X2](hif4x2.md) defines the packed HiF4 logical-lane value format.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif4-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE","surface":"arch","classification":["data-types","formats","hif4-scale"],"depends_on":["PTO-ARCH-DATA-TYPES-FP19"]}

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
    if value == Ones{8} then return NumericValue_QuietNaN; end;
    return NumericValue_PositiveNormal;
end;

pure func HiF4E6M2FiniteValue(value: bits(8)) => real
begin
    assert value != Ones{8};
    let exponent = (UInt(value[7:2]) - 48) as integer {-48..15};
    let mantissa_quarters = 4 + UInt(value[1:0]);
    return (Real(mantissa_quarters) / 4.0) * FP19PowerOfTwo(exponent);
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
