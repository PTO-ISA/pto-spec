<!-- GENERATED FROM: asl/arch/profile/e8m0-conversion.asl -->
# E8m0 Conversion

**Normative ASL source:** `asl/arch/profile/e8m0-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-E8M0-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-e8m0-purpose role=purpose-scope -->
## Purpose and scope

This unit supplies the PTO reference conversion path for `TCVT` with destination type `E8M0`. It defines accepted source types, exponent selection under `RMode`, exceptional encodings, saturation endpoints, and five-bit numeric status.

<!-- PTO-READER-BLOCK: arch-e8m0-concepts role=concepts-state -->
## Inputs and representation

- Supported sources are `FP16`, `BF16`, and `FP32`; other source-to-`E8M0` pairs fail the type-pair predicate.
- Finite positive input is decomposed into a significand and base-two exponent.
- Encoded finite results use exponent plus `127`, producing codes from `0x00` through `0xfe`; `0xff` is used by the exceptional paths.

<!-- PTO-READER-BLOCK: arch-e8m0-rules role=rules-interactions -->
## Conversion rules

- Exact powers of two preserve their exponent and report no inexact status.
- Non-powers use `ReferenceE8M0RoundExponent`, which implements `RTM`, `RTP`, `RTZ`, `RTO`, `RNE`, `RNA`, and `RHB` choices.
- Zero, negative values, and NaNs return `0xff` with `NV`.
- `ReferenceFloatToE8M0` also routes `NumericValue_InvalidEncoding` to `0xff` with `NV`.
- Positive infinity and finite overflow or underflow choose `0xff` without saturation or the finite endpoint with saturation, and report the corresponding `OF` or `UF` plus `NX`.

<!-- PTO-READER-BLOCK: arch-e8m0-boundaries role=boundaries -->
## Boundaries

`TileProfileConvert` delegates only destination `E8M0` to this path. Non-floating integer destinations use `NormalizeTileInteger`; other floating destinations are returned unchanged by this owner. `Canonicalize` remains a representation concern outside this conversion helper.

<!-- PTO-READER-BLOCK: arch-e8m0-example role=example-usage -->
## Non-normative conversion example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-e8m0-related role=related-owners-navigation -->
## Related owners

- Reference quantization provides shared finite-value and numeric helpers.
- Numeric-format owners classify source encodings; `TCVT` owns operation legality and publication.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/e8m0-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-E8M0-CONVERSION","surface":"arch","classification":["profile","e8m0-conversion"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION","PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-TCVT-E8M0-PROFILE-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// TCVT to E8M0 MUST accept only FP16, BF16, and FP32 sources. Positive
// finite values MUST round their base-two exponent under the selected RMode.
// Zero, negative values, and NaNs MUST produce 0xFF with NV. Positive
// infinity and finite range overflow or underflow MUST produce 0xFF when Sat
// is zero and the corresponding finite endpoint when Sat is one, with exact
// OF or UF plus NX status. Canonicalize MUST retain its representation role.
// NDF-END: PTO-TCVT-E8M0-PROFILE-001

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
    if destination_type == TileDataType_E8M0 then
        return HardwareTCVTE8M0SourceTypeSupported(source_type);
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

implementation func TileProfileConvert(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if destination_type == TileDataType_E8M0 then
        return ReferenceFloatToE8M0(value, source_type, control);
    elsif !TileDataTypeIsFloating(destination_type) then
        return (
            NormalizeTileInteger(value, destination_type),
            Zeros{5});
    end;
    return (value, Zeros{5});
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
