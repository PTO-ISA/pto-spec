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

`NumericFormatDescriptor` records whether numeric-format metadata is available and, when it is, describes carrier width, logical lanes, field widths and positions, constrained zero bits, exponent bias, and supported value classes.

<!-- PTO-READER-BLOCK: arch-format-descriptor-concepts role=concepts-state -->
## Descriptor structure

`NumericFormatKind` distinguishes unavailable metadata, fixed binary formats, `HiF8`, and `E8M0`. The width fields describe the carrier, each logical lane, the number of lanes, and the sign, exponent, and fraction fields.

The remaining fields state whether an exponent bias exists, how many high or low bits are constrained to zero, and whether zero, signed zero, subnormal, infinity, quiet NaN, and signaling NaN classes exist.

<!-- PTO-READER-BLOCK: arch-format-descriptor-rules role=rules-interactions -->
## How consumers use it

The embedded `PTO-NUMERIC-FORMAT-DESCRIPTOR-001` contract assigns one exact descriptor to each floating or scale Tile data type and assigns the unavailable result to integer Tile data types.

A descriptor reports capabilities and layout; format-specific decomposition and classification functions still own the interpretation of raw encodings.

<!-- PTO-READER-BLOCK: arch-format-descriptor-boundaries role=boundaries -->
## Unavailable descriptor

`UnavailableNumericFormatDescriptor` sets `available` to false, selects `NumericFormatKind_Unavailable`, zeros every width, position, bias, and constrained-bit field, and clears every special-value capability.

The focused boundary AVS checks the unavailable descriptor fields listed above; this sentence records evidence scope rather than defining another descriptor rule.

<!-- PTO-READER-BLOCK: arch-format-descriptor-example role=example-usage -->
## Non-normative reading example

This example is an inspection pattern, not a new format rule.

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
