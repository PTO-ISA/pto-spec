<!-- GENERATED FROM: asl/tile/model/numeric/e8m0-conversion.asl -->
# E8m0 Conversion

**Normative ASL source:** `asl/tile/model/numeric/e8m0-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-E8M0-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-purpose role=purpose-scope -->
## Purpose and scope

This unit owns two things.

- The TCVT type-pair and rounding-mode legality predicates, `HardwareTCVTTypePairSupported` and `HardwareTCVTRoundingModeSupported`.
- The conversion from FP16, BF16, or FP32 to E8M0, `ReferenceFloatToE8M0`, with its exponent-rounding helper `ReferenceE8M0RoundExponent`.

E8M0 is an eight-bit scale format that stores only a biased exponent. Code `c` from `0x00` to `0xFE` means 2^(c - 127), and `0xFF` is NaN. The reverse conversion, E8M0 to a float, is in the TCVT conversion unit.

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-concepts role=concepts-state -->
## Concepts and visible state

A conversion result is a value word and a five-bit flag set. The flag constants used by the ASL are `0x01` NV (invalid), `0x02` DZ, `0x04` OF (overflow), `0x08` UF (underflow), and `0x10` NX (inexact). TCVT ORs the flags of all converted elements into the sticky numeric status.

`HardwareTCVTTypePairSupported` returns:

- FALSE for any pair with HiF4X2, and for RCPE6M2 as a destination.
- RCPE6M2 source: TRUE only for FP16 or BF16 destinations.
- E8M0 source: TRUE only for FP16, BF16, or FP32 destinations.
- E6M2 on either side: TRUE only for E6M2 to FP16 or BF16, and FP16 or BF16 to E6M2.
- E2M1X2 or E1M2X2 on either side: TRUE only for one packed side and one side in FP32, FP16, or BF16.
- E8M0 destination: TRUE only for FP16, BF16, or FP32 sources.
- Every other pair: TRUE.

`HardwareTCVTRoundingModeSupported` allows only RNE and RNA when E6M2 or RCPE6M2 is involved, and every mode otherwise.

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-rules role=rules-interactions -->
## Rules and interactions

`ReferenceFloatToE8M0` asserts an FP16, BF16, or FP32 source and then classifies it.

- Zero, negative values, negative infinity, NaNs, and invalid encodings give `0xFF` with NV.
- Positive infinity gives `0xFF` with OF and NX (`0x14`), or `0xFE` when `Sat` is set.

A positive finite value is decomposed as significand times 2^exponent. Its floor exponent is `exponent + highest set bit`, that is floor(log2 value).

- Floor exponent below -127: `0xFF`, or `0x00` with `Sat`, with UF and NX (`0x18`).
- Floor exponent 127 and not an exact power of two: `0xFF`, or `0xFE` with `Sat`, with OF and NX.
- Otherwise the rounded exponent `r` gives code `r + 127`, with NX if the value was not an exact power of two.

Design point: rounding is applied to the exponent, not to the value. RTM takes the floor and RTP the ceiling. RTZ moves the exponent toward zero, so a value below 1 rounds up in value. RTO picks the odd exponent. The nearest modes compare the value with the geometric midpoint 2^(floor + 0.5), by testing the squared significand against 2^(2 x highest + 1). An integer square is never an odd power of two, so the tie branches are not reached for these inputs.

Design point: the out-of-range checks come before rounding. A value in (2^127, 2^128) is overflow even under RTZ or RTM, and a value below 2^-127 is underflow even under RTP.

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-boundaries role=boundaries -->
## Architectural boundaries

The two legality predicates are called by TCVT operand legality and by the block TCVT schema check, so an unsupported pair or mode is rejected before destination allocation.

`ReferenceFloatToE8M0` is reached from `TileProfileConvert` in the formats unit. It does not record flags itself; TCVT publishes them.

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-example role=example-usage -->
## Non-normative reading example

Convert FP32 3.0 (`0x40400000`) to E8M0.

- Significand `0xC00000`, exponent 128 - 150 = -22, highest set bit 23, so the floor exponent is 1.
- RNE: the square is `0x900000000000` and the boundary is 2^47 = `0x800000000000`. The square is larger, so the exponent rounds to 2. The code is 2 + 127 = 129 = `0x81` (value 4.0), with NX `0x10`.
- RTZ or RTM: the exponent stays 1, giving code `0x80` (value 2.0), with NX.

For FP32 2.5 the square is below the boundary, so RNE gives `0x80`.

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-related role=related-owners-navigation -->
## Related owners

- [TCVT conversion](tcvt-conversion.md) owns E8M0 to float.
- [Formats](formats.md) owns `TCVT` and the dispatch into this unit.
- [E8M0 format](../../../arch/data-types/formats/e8m0.md) owns the encoding.
- [Numeric status](../../../arch/state/numeric-status.md) owns sticky flags.
- [TCVT](../../elementwise-tile-tile/format-conversion/TCVT.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/e8m0-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-E8M0-CONVERSION","surface":"tile","classification":["model","numeric","e8m0-conversion"],"depends_on":["PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION","PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-TCVT-E8M0-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// TCVT to E8M0 MUST accept only FP16, BF16, and FP32 sources. Positive
// finite values MUST round their base-two exponent under the selected RMode.
// Zero, negative values, and NaNs MUST produce 0xFF with NV. Positive
// infinity and finite range overflow or underflow MUST produce 0xFF when Sat
// is zero and the corresponding finite endpoint when Sat is one, with exact
// OF or UF plus NX status. Canonicalize MUST retain its representation role.
// TCVT from E8M0 MUST accept only FP16, BF16, and FP32 destinations. Codes
// 0x00 through 0xFE denote 2^(code-127) and use the ordinary target rounding,
// saturation, overflow, underflow, and inexact rules. Code 0xFF MUST produce
// the target canonical quiet NaN without NV.
// NDF-END: PTO-TCVT-E8M0-001

// DOC-BEGIN: operation
pure func HardwareTCVTE8M0SourceTypeSupported(
    source_type: TileDataType) => boolean
begin
    return source_type == TileDataType_FP16 ||
           source_type == TileDataType_BF16 ||
           source_type == TileDataType_FP32;
end;

pure func HardwareTCVTTypePairSupported(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    // HiF4X2 is the payload of the composite Matrix/MX format, not a
    // standalone TCVT scalar. The two newly allocated scale identities have
    // deliberately narrow conversion profiles; width equality does not widen
    // these profiles.
    if source_type == TileDataType_HiF4X2 ||
       destination_type == TileDataType_HiF4X2 then
        return FALSE;
    end;
    if destination_type == TileDataType_RCPE6M2 then
        return FALSE;
    end;
    if source_type == TileDataType_RCPE6M2 then
        return destination_type == TileDataType_FP16 ||
               destination_type == TileDataType_BF16;
    end;
    if source_type == TileDataType_E8M0 then
        return destination_type == TileDataType_FP16 ||
               destination_type == TileDataType_BF16 ||
               destination_type == TileDataType_FP32;
    end;
    if source_type == TileDataType_E6M2 ||
       destination_type == TileDataType_E6M2 then
        return (source_type == TileDataType_E6M2 &&
                (destination_type == TileDataType_FP16 ||
                 destination_type == TileDataType_BF16)) ||
               (destination_type == TileDataType_E6M2 &&
                (source_type == TileDataType_FP16 ||
                 source_type == TileDataType_BF16));
    end;
    if source_type == TileDataType_E2M1X2 ||
       source_type == TileDataType_E1M2X2 ||
       destination_type == TileDataType_E2M1X2 ||
       destination_type == TileDataType_E1M2X2 then
        let source_ok = source_type == TileDataType_E2M1X2 ||
            source_type == TileDataType_E1M2X2 ||
            source_type == TileDataType_FP32 ||
            source_type == TileDataType_FP16 ||
            source_type == TileDataType_BF16;
        let destination_ok = destination_type == TileDataType_E2M1X2 ||
            destination_type == TileDataType_E1M2X2 ||
            destination_type == TileDataType_FP32 ||
            destination_type == TileDataType_FP16 ||
            destination_type == TileDataType_BF16;
        let source_packed = source_type == TileDataType_E2M1X2 ||
            source_type == TileDataType_E1M2X2;
        let destination_packed = destination_type == TileDataType_E2M1X2 ||
            destination_type == TileDataType_E1M2X2;
        return source_ok && destination_ok &&
               source_packed != destination_packed;
    end;
    if destination_type == TileDataType_E8M0 then
        return HardwareTCVTE8M0SourceTypeSupported(source_type);
    end;
    return TRUE;
end;

pure func HardwareTCVTRoundingModeSupported(
    source_type: TileDataType,
    destination_type: TileDataType,
    mode: NumericRoundingMode) => boolean
begin
    if source_type == TileDataType_E6M2 ||
       destination_type == TileDataType_E6M2 ||
       source_type == TileDataType_RCPE6M2 then
        return mode == NumericRound_RNE || mode == NumericRound_RNA;
    end;
    return TRUE;
end;

pure func ReferenceE8M0HighestSetBit(
    significand: Word) => integer {0..63}
begin
    assert !IsZero(significand);
    var highest: integer {0..63} = 0;
    for position = 0 to 63 do
        if significand[position] == '1' then
            highest = position as integer {0..63};
        end;
    end;
    return highest;
end;

pure func ReferenceE8M0RoundExponent(
    significand: Word,
    exponent: integer {-1074..1023},
    mode: NumericRoundingMode) => (integer {-149..128}, boolean)
begin
    let highest = ReferenceE8M0HighestSetBit(significand);
    let floor_candidate = exponent + highest;
    assert -149 <= floor_candidate && floor_candidate <= 127;
    let floor_exponent = floor_candidate as integer {-149..127};
    let exact_power = significand ==
        LSL(Zeros{PTO_XLEN} + 1, highest);
    if exact_power then
        return (floor_exponent, TRUE);
    end;

    let ceiling_exponent = (floor_exponent + 1) as integer {-148..128};
    if mode == NumericRound_RTM then
        return (floor_exponent, FALSE);
    elsif mode == NumericRound_RTP then
        return (ceiling_exponent, FALSE);
    elsif mode == NumericRound_RTZ then
        if floor_exponent < 0 then
            return (ceiling_exponent, FALSE);
        else return (floor_exponent, FALSE);
        end;
    elsif mode == NumericRound_RTO then
        if floor_exponent MOD 2 != 0 then
            return (floor_exponent, FALSE);
        else return (ceiling_exponent, FALSE);
        end;
    end;

    let square = MultiplyWord(significand, significand);
    let boundary_shift = 2 * highest + 1;
    assert boundary_shift <= 127;
    let boundary = LSL(
        Zeros{PTO_XLEN} + 1,
        boundary_shift as integer {0..127});
    if UInt(square) < UInt(boundary) then
        return (floor_exponent, FALSE);
    elsif UInt(square) > UInt(boundary) then
        return (ceiling_exponent, FALSE);
    elsif mode == NumericRound_RNE then
        if floor_exponent MOD 2 == 0 then
            return (floor_exponent, FALSE);
        else return (ceiling_exponent, FALSE);
        end;
    elsif mode == NumericRound_RNA then
        if floor_exponent < 0 then
            return (floor_exponent, FALSE);
        else return (ceiling_exponent, FALSE);
        end;
    else
        assert mode == NumericRound_RHB;
        return (ceiling_exponent, FALSE);
    end;
end;

func ReferenceFloatToE8M0(
    value: Word,
    source_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert HardwareTCVTE8M0SourceTypeSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if value_class == NumericValue_InvalidEncoding ||
       NumericValueClassIsNaN(value_class) ||
       NumericValueClassIsZero(value_class) ||
       value_class == NumericValue_NegativeInfinity ||
       value_class == NumericValue_NegativeNormal ||
       value_class == NumericValue_NegativeSubnormal then
        return (Zeros{PTO_XLEN} + 0xff, Zeros{5} + 0x01);
    elsif value_class == NumericValue_PositiveInfinity then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;

    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(source_type, value);
    assert available && !negative && !IsZero(significand);
    let highest = ReferenceE8M0HighestSetBit(significand);
    let floor_candidate = exponent + highest;
    assert -149 <= floor_candidate && floor_candidate <= 127;
    let floor_exponent = floor_candidate as integer {-149..127};
    let exact_power = significand ==
        LSL(Zeros{PTO_XLEN} + 1, highest);
    if floor_exponent < -127 then
        return (
            if control.saturating then Zeros{PTO_XLEN}
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x18);
    elsif floor_exponent == 127 && !exact_power then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;

    let (rounded_exponent, exact) = ReferenceE8M0RoundExponent(
        significand, exponent, control.rounding_mode);
    assert -127 <= rounded_exponent && rounded_exponent <= 127;
    let code = (rounded_exponent + 127) as integer {0..254};
    return (
        Zeros{PTO_XLEN} + code,
        if exact then Zeros{5} else Zeros{5} + 0x10);
end;

// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
