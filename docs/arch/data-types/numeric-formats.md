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

This unit is the central dispatcher from `TileDataType` to each floating or scale format descriptor and exact finite decomposition.

It gives consumers one typed entry point while preserving each format file as the owner of its own raw encoding.

<!-- PTO-READER-BLOCK: arch-numeric-formats-concepts-state role=concepts-state -->
## Concepts and visible state

- `TileNumericFormatDescriptor` dispatches all declared floating and scale data types from `FP64` through `HiF4X2` to their format-specific descriptors.
- `TileNumericFiniteDecomposition` dispatches the same formats to exact finite decomposition and narrows the `Word` carrier to the architectural width where required.
- The decomposition tuple is availability, sign, integer significand, and integer exponent, representing `(-1)^sign * UInt(significand) * 2^exponent`.

<!-- PTO-READER-BLOCK: arch-numeric-formats-rules-interactions role=rules-interactions -->
## Rules and interactions

Valid finite floating or scale encodings decompose without host floating-point arithmetic.

Invalid internal encodings, infinities, NaNs, and integer `TileDataType` members report unavailable.

An unhandled descriptor request returns `UnavailableNumericFormatDescriptor`; an unhandled decomposition returns `(FALSE, FALSE, Zeros{PTO_XLEN}, 0)`.

<!-- PTO-READER-BLOCK: arch-numeric-formats-boundaries role=boundaries -->
## Architectural boundaries

This unit does not reinterpret the returned tuple with host arithmetic. The integer significand and exponent are the exact interchange contract.

Format availability is not the same as operation support. A consuming instruction or named profile may further restrict accepted data types.

<!-- PTO-READER-BLOCK: arch-numeric-formats-example-usage role=example-usage -->
## Non-normative reading example

For `TileDataType_TF32`, the dispatcher passes `value[31:0]` to `TF32FiniteDecomposition`; required low-zero bits are therefore checked by the `TF32` owner.

For `TileDataType_S32`, no floating decomposition branch exists, so availability is false rather than an invented integer decomposition.

<!-- PTO-READER-BLOCK: arch-numeric-formats-related-owners role=related-owners-navigation -->
## Related owners

- [Tile data-type namespace](tile-data-types.md)
- [Numeric classification](numeric-classification.md)
- [TF32 format](formats/tf32.md)
- [HiF8 format](formats/hif8.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/numeric-formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","surface":"arch","classification":["data-types","numeric-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-FP64","PTO-ARCH-DATA-TYPES-FORMAT-FP32","PTO-ARCH-DATA-TYPES-FORMAT-TF32","PTO-ARCH-DATA-TYPES-FORMAT-HF32","PTO-ARCH-DATA-TYPES-FORMAT-FP16","PTO-ARCH-DATA-TYPES-FORMAT-BF16","PTO-ARCH-DATA-TYPES-FORMAT-HIF8","PTO-ARCH-DATA-TYPES-FORMAT-E4M3","PTO-ARCH-DATA-TYPES-FORMAT-E5M2","PTO-ARCH-DATA-TYPES-FORMAT-E3M2","PTO-ARCH-DATA-TYPES-FORMAT-E2M3","PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2","PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2","PTO-ARCH-DATA-TYPES-FORMAT-E8M0","PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2"]}

// NDF-BEGIN: PTO-NUMERIC-FINITE-DECOMPOSITION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Every valid finite floating or scale encoding MUST decompose without host
// floating-point arithmetic into available, sign, integer significand, and
// integer exponent such that its exact value is
// (-1)^sign * UInt(significand) * 2^exponent. Invalid internal encodings,
// infinities, NaNs, and integer Tile DataTypes MUST report unavailable.
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
        otherwise => return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
