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

This unit gives `HiF8` its exact eight-bit format description, dynamic dot-field decoding, finite decomposition, value classification, and canonical NaN.

It exists so consumers can reason from raw carriers without substituting a host floating-point type for the architecture-defined encoding.

<!-- PTO-READER-BLOCK: arch-hif8-concepts-state role=concepts-state -->
## Concepts and visible state

- `HiF8NumericFormatDescriptor` records one sign bit, a variable `0..4`-bit exponent, a `1..3`-bit fraction, one eight-bit lane, and no fixed exponent bias.
- `HiF8DecodeDotField` maps the carrier's dot field to `HiF8DotField_Denormal` or `HiF8DotField_D0` through `HiF8DotField_D4`, together with the active exponent and fraction widths.
- `HiF8FiniteDecomposition` returns availability, sign, an integer significand, and a base-two exponent; `ClassifyHiF8` supplies the corresponding value class.

<!-- PTO-READER-BLOCK: arch-hif8-rules-interactions role=rules-interactions -->
## Rules and interactions

The raw carriers `0x80`, `0x6f`, and `0xef` are non-finite: the first is the quiet NaN and the latter two are positive and negative infinity.

The all-zero carrier is positive zero. Carriers whose low seven bits are in `1..7` classify as signed subnormals; the remaining finite carriers classify as signed normals.

`HiF8CanonicalNaN` returns `0x80`, matching the classification rule rather than inventing a second NaN encoding.

<!-- PTO-READER-BLOCK: arch-hif8-boundaries role=boundaries -->
## Architectural boundaries

The descriptor advertises zero, subnormal, infinity, and quiet NaN support, but not signed zero or signaling NaN support.

The decomposition reports unavailable for every non-finite carrier; callers must consult availability before using its significand and exponent outputs.

<!-- PTO-READER-BLOCK: arch-hif8-example-usage role=example-usage -->
## Non-normative reading example

For `0x01`, the decoder selects `HiF8DotField_Denormal`; the value is available, positive, and subnormal, with the exact magnitude represented by the returned integer significand and exponent.

For `0x80`, classification returns `NumericValue_QuietNaN` and finite decomposition reports unavailable.

This is a reading example of the two APIs, not a new arithmetic rule.

<!-- PTO-READER-BLOCK: arch-hif8-related-owners role=related-owners-navigation -->
## Related owners

- [Numeric format dispatch](../numeric-formats.md)
- [Numeric classification](../numeric-classification.md)
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
