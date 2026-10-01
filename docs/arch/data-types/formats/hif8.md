<!-- GENERATED FROM: asl/arch/data-types/formats/hif8.asl -->
# Hif8

**Normative ASL source:** `asl/arch/data-types/formats/hif8.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF8}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-hif8-purpose-scope role=purpose-scope -->
## Purpose and scope

`HiF8` is an assigned PTO numeric format stored in an eight-bit carrier, and this unit owns its descriptor, dot-field decoding, finite decomposition, value classification, and canonical NaN.

`HiF8` is not a fixed-width-exponent format: the position of the dot between exponent and fraction depends on the value itself, so the format spends fewer exponent bits on small magnitudes and more on large ones.

Design point: the record keeps the carrier width and the logical lane width separate, so a packed type reports two lanes in one carrier while a single-lane type reports only its own lane width in its carrier.

<!-- PTO-READER-BLOCK: arch-hif8-concepts-state role=concepts-state -->
## Carrier and fields

The descriptor uses a `8`-bit carrier, a `8`-bit logical lane, and `1` lane per carrier, with `0` to `4` exponent bits, `1` to `3` fraction bits, and no fixed exponent bias.

The descriptor reports positive zero, subnormals, infinities, and quiet NaN, but not signed zero and not signaling NaN, and it selects `NumericFormatKind_HiF8`.

Design point: the exponent width is reported as a range rather than a single number, so a consumer that needs the field widths for one carrier must call `HiF8DecodeDotField` instead of reading the descriptor.

A reader that only needs a value class can stop after classification, because classification never requires an available decomposition.

<!-- PTO-READER-BLOCK: arch-hif8-rules-interactions role=rules-interactions -->
## Decomposition and classification

`HiF8DecodeDotField` maps carrier bits `6:3` to one dot field from `HiF8DotField_Denormal` and `HiF8DotField_D0` through `HiF8DotField_D4`, together with the exponent-bit count and the fraction-bit count active for that carrier.

`HiF8FiniteDecomposition` first excludes the three non-finite carriers, then returns availability, the sign, an integer significand, and a binary exponent such that the exact value is `(-1)^sign * UInt(significand) * 2^exponent`, and `ClassifyHiF8` returns the matching value class.

The carriers `0x80`, `0x6f`, and `0xef` are non-finite: `0x80` is quiet NaN, `0x6f` is positive infinity, and `0xef` is negative infinity; every other carrier is finite.

Design point: writing `FALSE` for availability instead of an arbitrary significand keeps a consumer from reading the placeholder fields of a non-finite carrier as a number, so the availability flag must be consulted first.

<!-- PTO-READER-BLOCK: arch-hif8-boundaries role=boundaries -->
## Boundaries and exact encodings

The all-zero carrier is positive zero, and a carrier whose low seven bits are in `1` through `7` classifies as a signed subnormal; the remaining finite carriers classify as signed normals.

Design point: the deferred dot-field lookup is what makes a first non-finite check possible, so the decoder only runs on a carrier whose decomposition is still meaningful.

Design point: only the all-zero carrier denotes zero, because a carrier with the sign bit set and an all-zero magnitude field is assigned to quiet NaN, so the descriptor reports no signed zero.

Read this page in the order of the functions: take the field positions from the descriptor, call the classification function when the value class matters, and call the decomposition function when the exact significand and exponent are needed.

<!-- PTO-READER-BLOCK: arch-hif8-example-usage role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`HiF8CanonicalNaN` returns `0x80`, which is the same carrier that classification reports as quiet NaN, so there is no second NaN encoding to reconcile.

`0x01` decodes through `HiF8DotField_Denormal` and decomposes to significand `1` with exponent `-22`, which is `2^-22`; `0x10` decodes through `HiF8DotField_D1` and decomposes to significand `8` with exponent `-2`, which is `2`.

<!-- PTO-READER-BLOCK: arch-hif8-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric format descriptor](../format-descriptor.md) defines the common metadata record.

- [Numeric formats](../numeric-formats.md) dispatches Tile data types to their format-specific helpers.

- [Numeric classification](../numeric-classification.md) defines the classes returned here.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif8.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF8","surface":"arch","classification":["data-types","formats","hif8"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact HiF8 dynamic encoding.

pure func HiF8NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_HiF8,
        carrier_bits = 8, lane_bits = 8, lanes_per_carrier = 1,
        sign_bits = 1, sign_bit = 7,
        exponent_bits_min = 0, exponent_bits_max = 4,
        fraction_bits_min = 1, fraction_bits_max = 3,
        exponent_bias_available = FALSE, exponent_bias = 0,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = FALSE, has_subnormal = TRUE,
        has_infinity = TRUE, has_quiet_nan = TRUE,
        has_signaling_nan = FALSE
    };
end;

pure func HiF8DecodeDotField(value: bits(8))
    => (HiF8DotField, integer {0..4}, integer {1..3})
begin
    if value[6:3] == '0000' then
        return (HiF8DotField_Denormal, 0, 3);
    elsif value[6:3] == '0001' then
        return (HiF8DotField_D0, 0, 3);
    elsif value[6:4] == '001' then
        return (HiF8DotField_D1, 1, 3);
    elsif value[6:5] == '01' then
        return (HiF8DotField_D2, 2, 3);
    elsif value[6:5] == '10' then
        return (HiF8DotField_D3, 3, 2);
    else return (HiF8DotField_D4, 4, 1);
    end;
end;

pure func HiF8FiniteDecomposition(value: bits(8))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    if value == '10000000' || value == '01101111' ||
       value == '11101111' then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
    let (dot, exponent_bits, fraction_bits) = HiF8DecodeDotField(value);
    case dot of
        when HiF8DotField_Denormal =>
            let mantissa = value[2:0];
            if mantissa == Zeros{3} then
                return (TRUE, FALSE, Zeros{PTO_XLEN}, 0);
            else return (TRUE, value[7] == '1', Zeros{PTO_XLEN} + 1,
                         (UInt(mantissa) - 23)
                             as integer {-1074..1023});
            end;
        when HiF8DotField_D0 =>
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 3) +
                        ZeroExtend{PTO_XLEN}(value[2:0]), -3);
        when HiF8DotField_D1 =>
            var actual_exponent: integer {-15..15} = 1;
            if value[3] == '1' then actual_exponent = -1; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 3) +
                        ZeroExtend{PTO_XLEN}(value[2:0]),
                    (actual_exponent - 3) as integer {-1074..1023});
        when HiF8DotField_D2 =>
            let magnitude = 2 + UInt(value[3]);
            var actual_exponent: integer {-15..15} = magnitude;
            if value[4] == '1' then actual_exponent = 0 - magnitude; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 3) +
                        ZeroExtend{PTO_XLEN}(value[2:0]),
                    (actual_exponent - 3) as integer {-1074..1023});
        when HiF8DotField_D3 =>
            let magnitude = 4 + UInt(value[3:2]);
            var actual_exponent: integer {-15..15} = magnitude;
            if value[4] == '1' then actual_exponent = 0 - magnitude; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 2) +
                        ZeroExtend{PTO_XLEN}(value[1:0]),
                    (actual_exponent - 2) as integer {-1074..1023});
        when HiF8DotField_D4 =>
            let magnitude = 8 + UInt(value[3:1]);
            var actual_exponent: integer {-15..15} = magnitude;
            if value[4] == '1' then actual_exponent = 0 - magnitude; end;
            return (TRUE, value[7] == '1',
                    LSL(Zeros{PTO_XLEN} + 1, 1) +
                        ZeroExtend{PTO_XLEN}(value[0:0]),
                    (actual_exponent - 1) as integer {-1074..1023});
    end;
end;
pure func ClassifyHiF8(value: bits(8)) => NumericValueClass
begin
    if value == '10000000' then return NumericValue_QuietNaN;
    elsif value == '01101111' then return NumericValue_PositiveInfinity;
    elsif value == '11101111' then return NumericValue_NegativeInfinity;
    elsif value == Zeros{8} then return NumericValue_PositiveZero;
    elsif UInt(value[6:0]) <= 7 then
        return NumericValueClassFromFiniteSign(value[7], FALSE, TRUE);
    else return NumericValueClassFromFiniteSign(value[7], FALSE, FALSE);
    end;
end;

pure func HiF8CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0x80;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
