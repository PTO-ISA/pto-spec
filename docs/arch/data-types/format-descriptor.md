<!-- GENERATED FROM: asl/arch/data-types/format-descriptor.asl -->
# Format Descriptor

**Normative ASL source:** `asl/arch/data-types/format-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-descriptor-purpose role=purpose-scope -->
## Purpose and scope

`NumericFormatDescriptor` is the common record that reports whether numeric-format metadata is available for a Tile data type and, when it is, describes that format exactly.

One record carries the carrier width, the logical lane width, the number of lanes per carrier, the sign, exponent, and fraction fields, the constrained zero bits, the exponent bias, and the special-value classes the format supports.

<!-- PTO-READER-BLOCK: arch-format-descriptor-concepts role=concepts-state -->
## Concepts and visible state

`NumericFormatKind` distinguishes `NumericFormatKind_Unavailable`, the fixed binary formats, `HiF8`, and `E8M0`, so a consumer can tell which style of field description it is reading.

The width fields `carrier_bits`, `lane_bits`, and `lanes_per_carrier` describe how many raw bits a carrier has, how many bits one logical value occupies, and how many values share a carrier.

The field descriptions `sign_bits`, `sign_bit`, `exponent_bits_min` through `exponent_bits_max`, `fraction_bits_min` through `fraction_bits_max`, `exponent_bias_available`, and `exponent_bias` give the position and width of each part of the lane, or a range when the format varies them.

<!-- PTO-READER-BLOCK: arch-format-descriptor-rules role=rules-interactions -->
## Rules and interactions

Design point: a dynamic format such as `HiF8` reports an exponent range instead of one width, so the record describes the format family rather than one carrier, and the specific field widths come from the format's own decoder.

`required_low_zero_bits` and `required_high_zero_bits` count the bits that must be zero in a valid carrier, which is how a truncated carrier such as `TF32` stays distinct from a full-precision carrier of the same width.

The remaining booleans state whether zero, signed zero, subnormal, infinity, quiet NaN, and signaling NaN encodings exist, which tells a consumer what a raw carrier can denote before it decodes one.

The embedded `PTO-NUMERIC-FORMAT-DESCRIPTOR-001` clause requires every assigned floating or scale Tile data type to expose one exact descriptor of this shape and requires an integer Tile data type to report that no floating-format descriptor exists.

<!-- PTO-READER-BLOCK: arch-format-descriptor-boundaries role=boundaries -->
## Architectural boundaries

Design point: requiring a descriptor for every assigned type, rather than leaving fields unspecified, means a consumer never has to guess whether a missing value means a narrow format or missing metadata.

A descriptor reports layout and capabilities; the raw encoding of one value is still interpreted by the format's own decomposition and classification functions.

`UnavailableNumericFormatDescriptor` sets `available` to false, selects `NumericFormatKind_Unavailable`, zeros every width, position, bias, and constrained-bit field, and clears every special-value capability.

Read this page in the order of the functions: take the field positions from the descriptor, then use the constrained-bit counts to select the format-specific validity, decomposition, and classification owner.

<!-- PTO-READER-BLOCK: arch-format-descriptor-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Design point: the unavailable result is a fully populated record with all capabilities cleared, so a consumer that ignores availability sees zero widths and no supported classes rather than an arbitrary format.

Reading a format starts with `available` and `kind`, then the field widths, then the constrained-bit counts, and only then the format-specific helpers.

Before decoding a Tile data type as floating point, inspect `available` and `kind`; then use the field widths and constrained-bit counts to select the format-specific validity, decomposition, and classification owner.

<!-- PTO-READER-BLOCK: arch-format-descriptor-related role=related-owners-navigation -->
## Related owners

- [Tile data types](tile-data-types.md) defines the assigned Tile data-type vocabulary.

- [Numeric formats](numeric-formats.md) dispatches assigned types to their exact descriptor and value helpers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/format-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR","surface":"arch","classification":["data-types","format-descriptor"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}

// NDF-BEGIN: PTO-NUMERIC-FORMAT-DESCRIPTOR-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Each assigned floating or scale Tile DataType MUST expose one exact carrier,
// lane, field-width, bias, constrained-bit, and special-value descriptor.
// Integer Tile DataTypes MUST report that no floating-format descriptor exists.
// NDF-END: PTO-NUMERIC-FORMAT-DESCRIPTOR-001

// DOC-BEGIN: operation
type NumericFormatKind of enumeration {
    NumericFormatKind_Unavailable,
    NumericFormatKind_FixedBinary,
    NumericFormatKind_HiF8,
    NumericFormatKind_E8M0
};

type NumericFormatDescriptor of record {
    available: boolean,
    kind: NumericFormatKind,
    carrier_bits: integer {0..64},
    lane_bits: integer {0..64},
    lanes_per_carrier: integer {0..2},
    sign_bits: integer {0..1},
    sign_bit: integer {0..63},
    exponent_bits_min: integer {0..11},
    exponent_bits_max: integer {0..11},
    fraction_bits_min: integer {0..52},
    fraction_bits_max: integer {0..52},
    exponent_bias_available: boolean,
    exponent_bias: integer {0..1023},
    required_low_zero_bits: integer {0..13},
    required_high_zero_bits: integer {0..2},
    has_zero: boolean,
    has_signed_zero: boolean,
    has_subnormal: boolean,
    has_infinity: boolean,
    has_quiet_nan: boolean,
    has_signaling_nan: boolean
};

type HiF8DotField of enumeration {
    HiF8DotField_Denormal,
    HiF8DotField_D0,
    HiF8DotField_D1,
    HiF8DotField_D2,
    HiF8DotField_D3,
    HiF8DotField_D4
};

pure func UnavailableNumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = FALSE,
        kind = NumericFormatKind_Unavailable,
        carrier_bits = 0,
        lane_bits = 0,
        lanes_per_carrier = 0,
        sign_bits = 0,
        sign_bit = 0,
        exponent_bits_min = 0,
        exponent_bits_max = 0,
        fraction_bits_min = 0,
        fraction_bits_max = 0,
        exponent_bias_available = FALSE,
        exponent_bias = 0,
        required_low_zero_bits = 0,
        required_high_zero_bits = 0,
        has_zero = FALSE,
        has_signed_zero = FALSE,
        has_subnormal = FALSE,
        has_infinity = FALSE,
        has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
