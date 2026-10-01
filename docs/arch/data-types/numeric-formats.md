<!-- GENERATED FROM: asl/arch/data-types/numeric-formats.asl -->
# Numeric Formats

**Normative ASL source:** `asl/arch/data-types/numeric-formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-numeric-formats-purpose-scope role=purpose-scope -->
## Purpose and scope

`TileNumericFormatDescriptor` and `TileNumericFiniteDecomposition` are the two entry points that turn a `TileDataType` into format metadata and into an exact finite decomposition. Both are `pure func`s that `case` over the same seventeen floating and scale members, `TileDataType_FP64` through `TileDataType_E6M2` plus the derived `TileDataType_RCPE6M2`.

The unit owns the dispatch only. Each arm returns what the named format owner produces, so no carrier width, lane count, bias, or special-value rule is decided on this page.

Design point: the dispatcher narrows the `Word` carrier itself, `value[31:0]` for `FP32`, `TF32`, and `HF32`, `value[15:0]` for `FP16` and `BF16`, and `value[7:0]` for the eight-bit formats. A caller therefore cannot make an eight-bit format read a bit above bit 7, and each helper receives exactly the carrier its own descriptor declares.

<!-- PTO-READER-BLOCK: arch-numeric-formats-concepts-state role=concepts-state -->
## Concepts and visible state

- `TileNumericFormatDescriptor` and `TileNumericFiniteDecomposition` each have seventeen `when` arms; the descriptor's `otherwise` arm returns `UnavailableNumericFormatDescriptor()` and the decomposition's returns the four-tuple `(FALSE, FALSE, Zeros{PTO_XLEN}, 0)`.
- The decomposition result is availability, sign, integer significand, and integer exponent, with the exact value `(-1)^sign * UInt(significand) * 2^exponent`. The exponent is typed `integer {-1074..1023}`.
- Four arms pass the whole `Word` unchanged: `TileDataType_FP64`, `TileDataType_E2M1X2`, `TileDataType_E1M2X2`, and `TileDataType_HiF4X2`. Of those, the three `X2` helpers read `value[3:0]` only, so one call decomposes one 4-bit lane and not the two lanes their descriptors count.

Design point: the exponent is typed `integer {-1074..1023}`, one range shared by every arm. `-1074` is what the `FP64` arm returns for a subnormal and `1023` is the declared upper bound, so a consumer can compare exponents from any arm against the same two limits.

<!-- PTO-READER-BLOCK: arch-numeric-formats-rules-interactions role=rules-interactions -->
## Rules and interactions

The owning NDF clause `PTO-NUMERIC-FINITE-DECOMPOSITION-001` requires every valid finite floating or scale encoding with a finite-binary decomposition to decompose, without host floating-point arithmetic, into availability, sign, integer significand, and integer exponent.

An encoding that is invalid for its own type reports `available = FALSE` from the format helper, and so does an infinity or a NaN encoding where the type has one; the owning NDF clause requires exactly that. The ten integer members, `TileDataType_S64`, `TileDataType_S32`, `TileDataType_S16`, `TileDataType_S8`, `TileDataType_S4X2`, `TileDataType_U64`, `TileDataType_U32`, `TileDataType_U16`, `TileDataType_U8`, and `TileDataType_U4X2`, have no arm at all, so they reach `otherwise`.

`UnavailableNumericFormatDescriptor()` sets `available = FALSE`, `kind = NumericFormatKind_Unavailable`, and every bit count, bit position, and special-value flag to `FALSE` or `0`.

Design point: the dispatcher never inspects an exponent or fraction field; each helper applies its own validity rule first, as `TF32FiniteDecomposition` does when it requires `value[12:0]` to be zero. Two data types can therefore both be dispatched and still disagree about availability, because the answer is produced one level below the `case`.

<!-- PTO-READER-BLOCK: arch-numeric-formats-boundaries role=boundaries -->
## Architectural boundaries

A returned descriptor is metadata about an encoding, not a statement that an instruction accepts the data type. A consuming instruction or a named profile may accept less than the format family offers.

This unit does not reinterpret the returned tuple with host arithmetic: the integer significand and the integer exponent are the whole interchange contract, so a consumer that needs a rounded value must round it itself.

`TileDataType_RCPE6M2` is where the two entry points answer differently on purpose: its descriptor arm returns `RCPE6M2NumericFormatDescriptor()` with `available = TRUE`, while `RCPE6M2FiniteDecomposition` returns `(FALSE, FALSE, Zeros{PTO_XLEN}, 0)` for every input, which `PTO-NUMERIC-FINITE-DECOMPOSITION-001` allows for a derived exact-real source whose exact real decoder, `RCPE6M2FiniteValue`, is exposed to the operation profile instead.

Design point: because descriptor availability and decomposition availability are separate answers, a consumer must ask for the one it needs. Reading `available = TRUE` for `TileDataType_RCPE6M2` and then expecting a binary significand would treat a derived exact-real type as an ordinary fixed-binary one.

<!-- PTO-READER-BLOCK: arch-numeric-formats-example-usage role=example-usage -->
## Non-normative reading example

Take `TileDataType_TF32` and the encoding `0x3F800000`. The dispatcher passes `value[31:0]` to `TF32FiniteDecomposition`; the low thirteen bits are zero, the exponent field is `0x7F`, and the fraction field is zero, so the helper returns availability `TRUE`, sign `FALSE`, significand `1024`, and exponent `-10`. The exact value is `1024 * 2^-10`, which is one.

For `TileDataType_S32` the dispatcher finds no arm, so availability is `FALSE`, sign is `FALSE`, the significand is `Zeros{PTO_XLEN}`, and the exponent is `0`. No integer decomposition is invented for it.

For `TileDataType_E2M1X2` the dispatcher passes the whole `Word` while `E2M1X2FiniteDecomposition` reads only `value[3:0]`, so a caller holding two four-bit lanes in one byte gets the low lane decomposed and the high lane untouched.

<!-- PTO-READER-BLOCK: arch-numeric-formats-related-owners role=related-owners-navigation -->
## Related owners

- [Tile data-type namespace](tile-data-types.md)
- [Numeric classification](numeric-classification.md)
- [Format descriptor record](format-descriptor.md)
- [TF32 format](formats/tf32.md)
- [RCPE6M2 format](formats/rcpe6m2.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/numeric-formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","surface":"arch","classification":["data-types","numeric-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-FP64","PTO-ARCH-DATA-TYPES-FORMAT-FP32","PTO-ARCH-DATA-TYPES-FORMAT-TF32","PTO-ARCH-DATA-TYPES-FORMAT-HF32","PTO-ARCH-DATA-TYPES-FORMAT-FP16","PTO-ARCH-DATA-TYPES-FORMAT-BF16","PTO-ARCH-DATA-TYPES-FORMAT-HIF8","PTO-ARCH-DATA-TYPES-FORMAT-E4M3","PTO-ARCH-DATA-TYPES-FORMAT-E5M2","PTO-ARCH-DATA-TYPES-FORMAT-E3M2","PTO-ARCH-DATA-TYPES-FORMAT-E2M3","PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2","PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2","PTO-ARCH-DATA-TYPES-FORMAT-E8M0","PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2","PTO-ARCH-DATA-TYPES-FORMAT-E6M2","PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2"]}

// NDF-BEGIN: PTO-NUMERIC-FINITE-DECOMPOSITION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Every valid finite floating or scale encoding with a finite-binary
// decomposition MUST decompose without host floating-point arithmetic into
// available, sign, integer significand, and integer exponent such that its
// exact value is (-1)^sign * UInt(significand) * 2^exponent. A derived exact-
// real source whose values are not all finite-binary, such as RCPE6M2, may
// report unavailable here and MUST expose its exact real decoder to the
// operation profile. Invalid internal encodings, infinities, NaNs, and
// integer Tile DataTypes MUST report unavailable.
// NDF-END: PTO-NUMERIC-FINITE-DECOMPOSITION-001

// DOC-BEGIN: operation
pure func TileNumericFormatDescriptor(data_type: TileDataType)
    => NumericFormatDescriptor
begin
    case data_type of
        when TileDataType_FP64 => return FP64NumericFormatDescriptor();
        when TileDataType_FP32 => return FP32NumericFormatDescriptor();
        when TileDataType_TF32 => return TF32NumericFormatDescriptor();
        when TileDataType_HF32 => return HF32NumericFormatDescriptor();
        when TileDataType_FP16 => return FP16NumericFormatDescriptor();
        when TileDataType_BF16 => return BF16NumericFormatDescriptor();
        when TileDataType_HiF8 => return HiF8NumericFormatDescriptor();
        when TileDataType_E4M3 => return E4M3NumericFormatDescriptor();
        when TileDataType_E5M2 => return E5M2NumericFormatDescriptor();
        when TileDataType_E3M2 => return E3M2NumericFormatDescriptor();
        when TileDataType_E2M3 => return E2M3NumericFormatDescriptor();
        when TileDataType_E2M1X2 => return E2M1X2NumericFormatDescriptor();
        when TileDataType_E1M2X2 => return E1M2X2NumericFormatDescriptor();
        when TileDataType_E8M0 => return E8M0NumericFormatDescriptor();
        when TileDataType_HiF4X2 => return HiF4X2NumericFormatDescriptor();
        when TileDataType_E6M2 => return E6M2NumericFormatDescriptor();
        when TileDataType_RCPE6M2 => return RCPE6M2NumericFormatDescriptor();
        otherwise => return UnavailableNumericFormatDescriptor();
    end;
end;

pure func TileNumericFiniteDecomposition(
    data_type: TileDataType,
    value: Word) => (boolean, boolean, Word, integer {-1074..1023})
begin
    case data_type of
        when TileDataType_FP64 => return FP64FiniteDecomposition(value);
        when TileDataType_FP32 => return FP32FiniteDecomposition(value[31:0]);
        when TileDataType_TF32 => return TF32FiniteDecomposition(value[31:0]);
        when TileDataType_HF32 => return HF32FiniteDecomposition(value[31:0]);
        when TileDataType_FP16 => return FP16FiniteDecomposition(value[15:0]);
        when TileDataType_BF16 => return BF16FiniteDecomposition(value[15:0]);
        when TileDataType_HiF8 => return HiF8FiniteDecomposition(value[7:0]);
        when TileDataType_E4M3 => return E4M3FiniteDecomposition(value[7:0]);
        when TileDataType_E5M2 => return E5M2FiniteDecomposition(value[7:0]);
        when TileDataType_E3M2 => return E3M2FiniteDecomposition(value[7:0]);
        when TileDataType_E2M3 => return E2M3FiniteDecomposition(value[7:0]);
        when TileDataType_E2M1X2 => return E2M1X2FiniteDecomposition(value);
        when TileDataType_E1M2X2 => return E1M2X2FiniteDecomposition(value);
        when TileDataType_E8M0 => return E8M0FiniteDecomposition(value[7:0]);
        when TileDataType_HiF4X2 => return HiF4X2FiniteDecomposition(value);
        when TileDataType_E6M2 => return E6M2FiniteDecomposition(value[7:0]);
        when TileDataType_RCPE6M2 => return RCPE6M2FiniteDecomposition(value[7:0]);
        otherwise => return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
