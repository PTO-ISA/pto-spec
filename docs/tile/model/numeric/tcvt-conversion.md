<!-- GENERATED FROM: asl/tile/model/numeric/tcvt-conversion.asl -->
# Tcvt Conversion

**Normative ASL source:** `asl/tile/model/numeric/tcvt-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-purpose role=purpose-scope -->
## Purpose and scope

This unit owns `ReferenceTCVTConvert`, the TCVT conversion rule for the closed scale and packed formats, and its wrappers.

- `ReferenceTCVTConvertPacked4` and `ReferenceTCVTConvertFromPacked4` convert to and from E2M1X2 and E1M2X2.
- `ReferenceTCVTConvertToE6M2` and `ReferenceTCVTConvertFromE6M2` convert to and from E6M2.
- `ReferenceTCVTConvertFromRCPE6M2` converts from RCPE6M2, the reciprocal reading of an E6M2 code.
- `ReferenceTCVTConvertFromE8M0` converts from E8M0.

Each wrapper handles special values and then calls a finite encoder.

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-concepts role=concepts-state -->
## Concepts and visible state

`ReferenceTCVTConvert` checks the pair in this order: E8M0 source, packed destination, packed source, E6M2 destination, E6M2 source, RCPE6M2 source. Any other pair goes to `ReferenceCommonConvert`.

The ordinary floating side of these wrappers is FP32, FP16, or BF16. `ReferenceTCVTOrdinaryFloatingSourceSupported` asserts this for conversions into the packed formats and E6M2, and `ReferenceTCVTConvertFromE8M0` asserts it for its destination. The legal pairs themselves are decided by `HardwareTCVTTypePairSupported` in the E8M0 conversion unit.

Flags use `0x01` NV, `0x10` NX, `0x14` OF plus NX, and `0x18` UF plus NX.

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-rules role=rules-interactions -->
## Rules and interactions

Into E2M1X2 or E1M2X2:

- NaN or invalid encoding gives code 0, with NV only for a signaling NaN or invalid encoding.
- Infinity gives the largest finite code of the same sign (6 or 14 for E2M1X2, 7 or 15 for E1M2X2) with OF and NX.
- Zero keeps its sign; a finite value goes to `ReferencePacked4Encoding`.

Design point: the four-bit formats have no NaN or infinity encoding, so these wrappers map NaN to positive zero and infinity to the finite endpoint. The observable result is that a four-bit Tile never holds a special value: OF records a replaced infinity, and NV records a replaced signaling NaN or invalid encoding; a replaced quiet NaN raises no flag.

From E2M1X2 or E1M2X2: zero keeps its sign, and every other lane value is exact and is rounded once to the destination.

Into E6M2:

- NaN or invalid encoding gives `0xFF`, with NV only for a signaling NaN or invalid encoding.
- Either zero gives code 0 (2^-48) with UF and NX, because E6M2 has no zero.
- A negative value or negative infinity gives `0xFF` with NV.
- Positive infinity gives `0xFF`, or `0xFE` with saturation, with OF and NX.

From E6M2, RCPE6M2, or E8M0: the NaN code `0xFF` gives the destination canonical quiet NaN with no flag. Every other code is converted to its exact real value (for E8M0, 2^(code - 127)) and rounded once to the destination.

Design point: RCPE6M2 is read as the exact reciprocal of the E6M2 value, and only the final destination rounding is applied. There is no intermediate rounded E6M2 or floating value, so the result can differ from converting the E6M2 value first and then taking a reciprocal.

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-boundaries role=boundaries -->
## Architectural boundaries

`TCVT` in the formats unit calls this rule directly for accepted pairs involving these formats, and `TileProfileConvert` reaches it for the packed formats, E6M2, and an RCPE6M2 source, but not for an E8M0 source. Conversion to E8M0 is not here; it is `ReferenceFloatToE8M0`.

Rounding-mode legality is checked before this rule runs: E6M2 and RCPE6M2 pairs accept only RNE and RNA.

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-example role=example-usage -->
## Non-normative reading example

E8M0 to FP16 and BF16 with RNE:

- Code `0x7F` is 2^0 = 1.0, giving FP16 `0x3C00` with no flag.
- Code `0x8F` is 2^16 = 65536, which exceeds the FP16 maximum 65504. The result is FP16 infinity `0x7C00` with OF and NX, or `0x7BFF` with saturation.
- Code `0x00` is 2^-127. In BF16 it is the exact subnormal `0x0040` with no flag. In FP16 it is below half the smallest subnormal 2^-24, so it rounds to `0x0000` with UF and NX.

E6M2 code `0xC0` has exponent field 48 and fraction 0, so it is 1.0 and converts to FP16 `0x3C00`.

<!-- PTO-READER-BLOCK: tile-model-numeric-tcvt-conversion-related role=related-owners-navigation -->
## Related owners

- [Packed conversion](packed-conversion.md) owns the finite four-bit and E6M2 encoders.
- [E8M0 conversion](e8m0-conversion.md) owns pair legality and conversion into E8M0.
- [Reference conversion](reference-conversion.md) owns the common rule used for other pairs.
- [RCPE6M2 format](../../../arch/data-types/formats/rcpe6m2.md) and [E6M2 format](../../../arch/data-types/formats/e6m2.md) own the scale encodings.
- [TCVT](../../elementwise-tile-tile/format-conversion/TCVT.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/tcvt-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION","surface":"tile","classification":["model","numeric","tcvt-conversion"],"depends_on":["PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION"]}

pure func ReferenceTCVTOrdinaryFloatingSourceSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16;
end;

pure func ReferenceTCVTOrdinaryFloatingFiniteValue(
    value: Word, data_type: TileDataType) => real
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(data_type);
    if data_type == TileDataType_FP32 then
        return ReferenceFP32FiniteValue(value[31:0]);
    end;
    return ReferenceBinary16FiniteValue(value, data_type);
end;

func ReferenceTCVTConvertPacked4(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        return (Zeros{PTO_XLEN},
            if value_class == NumericValue_SignalingNaN ||
               value_class == NumericValue_InvalidEncoding then
                Zeros{5} + 1 else Zeros{5});
    end;
    if NumericValueClassIsInfinity(value_class) then
        let negative = value_class == NumericValue_NegativeInfinity;
        let maximum_code = if destination_type == TileDataType_E2M1X2
            then 6 else 7;
        return (Zeros{PTO_XLEN} +
                (if negative then maximum_code + 8 else maximum_code),
                Zeros{5} + 0x14);
    end;
    if NumericValueClassIsZero(value_class) then
        let (available, positive, negative) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (if value_class == NumericValue_NegativeZero then negative
                else positive, Zeros{5});
    end;
    return ReferencePacked4Encoding(
        ReferenceTCVTOrdinaryFloatingFiniteValue(value, source_type),
        destination_type, control);
end;

func ReferenceTCVTConvertFromPacked4(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsZero(value_class) then
        let (available, positive, negative) =
            HardwareNumericSignedZeroEncodings(destination_type);
        assert available;
        return (if value_class == NumericValue_NegativeZero then negative
                else positive, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        ReferencePacked4FiniteValue(source_type, UInt(value[3:0])),
        destination_type, control);
end;

func ReferenceTCVTConvertToE6M2(
    value: Word, source_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert ReferenceTCVTOrdinaryFloatingSourceSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        return (Zeros{PTO_XLEN} + 0xff,
            if value_class == NumericValue_SignalingNaN ||
               value_class == NumericValue_InvalidEncoding then
                Zeros{5} + 1 else Zeros{5});
    end;
    if value_class == NumericValue_NegativeZero ||
       value_class == NumericValue_PositiveZero then
        return (Zeros{PTO_XLEN}, Zeros{5} + 0x18);
    end;
    if value_class == NumericValue_NegativeInfinity ||
       value_class == NumericValue_NegativeNormal ||
       value_class == NumericValue_NegativeSubnormal then
        return (Zeros{PTO_XLEN} + 0xff, Zeros{5} + 1);
    end;
    if value_class == NumericValue_PositiveInfinity then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;
    return ReferenceE6M2Encoding(
        ReferenceTCVTOrdinaryFloatingFiniteValue(value, source_type),
        control);
end;

func ReferenceTCVTConvertFromE6M2(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(
        TileDataType_E6M2, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        E6M2FiniteValue(value[7:0]), destination_type, control);
end;

func ReferenceTCVTConvertFromRCPE6M2(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let value_class = TileNumericValueClass(
        TileDataType_RCPE6M2, value);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_InvalidEncoding then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    return ReferenceMatrixFloatingEncoding(
        RCPE6M2FiniteValue(value[7:0]), destination_type, control);
end;

func ReferenceTCVTConvertFromE8M0(
    value: Word, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_FP16 ||
           destination_type == TileDataType_BF16 ||
           destination_type == TileDataType_FP32;
    if value[7:0] == Ones{8} then
        let (available, canonical) =
            TileNumericCanonicalNaN(destination_type);
        assert available;
        return (canonical, Zeros{5});
    end;
    let exponent = (UInt(value[7:0]) - 127)
        as integer {-1074..1023};
    return ReferenceMatrixFloatingEncoding(
        ReferencePowerOfTwo(exponent), destination_type, control);
end;

func ReferenceTCVTConvert(
    value: Word, source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if source_type == TileDataType_E8M0 then
        return ReferenceTCVTConvertFromE8M0(
            value, destination_type, control);
    elsif destination_type == TileDataType_E2M1X2 ||
       destination_type == TileDataType_E1M2X2 then
        return ReferenceTCVTConvertPacked4(
            value, source_type, destination_type, control);
    elsif source_type == TileDataType_E2M1X2 ||
          source_type == TileDataType_E1M2X2 then
        return ReferenceTCVTConvertFromPacked4(
            value, source_type, destination_type, control);
    elsif destination_type == TileDataType_E6M2 then
        return ReferenceTCVTConvertToE6M2(value, source_type, control);
    elsif source_type == TileDataType_E6M2 then
        return ReferenceTCVTConvertFromE6M2(
            value, destination_type, control);
    elsif source_type == TileDataType_RCPE6M2 then
        return ReferenceTCVTConvertFromRCPE6M2(
            value, destination_type, control);
    end;
    return ReferenceCommonConvert(
        value, source_type, destination_type, control);
end;
```
<!-- GENERATED-ASL-END: unit -->
