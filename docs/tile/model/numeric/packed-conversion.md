<!-- GENERATED FROM: asl/tile/model/numeric/packed-conversion.asl -->
# Packed Conversion

**Normative ASL source:** `asl/tile/model/numeric/packed-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the reference encoders for three small formats (E2M1X2, E1M2X2, and E6M2). The encoders turn an exact real value into a code; the other helpers decode a lane or break ties.

- `ReferencePacked4FiniteValue` decodes one four-bit E2M1X2 or E1M2X2 lane.
- `ReferencePacked4Encoding` rounds a real value to one of those lanes.
- `ReferenceE6M2Encoding` rounds a positive real value to an E6M2 scale code.
- `ReferencePacked4CandidateBetter` and `ReferenceE6M2CandidateBetter` break ties between candidates.

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-concepts role=concepts-state -->
## Concepts and visible state

A four-bit lane has a sign bit (bit 3) and a three-bit magnitude code. Codes 8 to 15 are the negatives of codes 0 to 7, so code 8 is negative zero.

| Magnitude code | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E2M1X2 value | 0.0 | 0.5 | 1.0 | 1.5 | 2.0 | 3.0 | 4.0 | 6.0 |
| E1M2X2 value | 0.0 | 0.25 | 0.5 | 0.75 | 1.0 | 1.25 | 1.5 | 1.75 |

Neither four-bit format has infinity or NaN. E6M2 is unsigned, has no zero, and code `c` from 0 to 254 means (4 + low two bits) / 4 x 2^(high six bits - 48). Code `0xFF` is NaN.

Flags use the constants `0x10` NX, `0x14` OF plus NX, and `0x18` UF plus NX.

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-rules role=rules-interactions -->
## Rules and interactions

`ReferencePacked4Encoding` returns code 0 for an exact zero. A magnitude above the format maximum (6.0 or 1.75) is overflow with OF and NX. The overflow result is code 6 or 14 for E2M1X2 and code 7 or 15 for E1M2X2; the `saturating` control is not consulted.

Otherwise the encoder tries all 16 codes and keeps the best eligible one.

- RTP keeps the smallest candidate not below the value, and RTM keeps the largest not above it.
- RTZ and RTO keep the largest-magnitude candidate between zero and the value.
- The nearest modes keep the closest candidate. On a tie, RNE prefers an even code, RNA the larger magnitude, and RHB the larger value.
- RTO then moves an inexact even code up by one, to the odd neighbor.

Design point: the encoder searches the code table instead of manipulating exponent bits. The consequence is that each rounding mode is defined by which listed values are eligible and how ties are broken, and the result is always one of the 16 table entries.

Underflow is reported with UF and NX when the result is inexact and small. E2M1X2 tests the chosen value against 1.0. E1M2X2 tests the input magnitude against 0.25.

`ReferenceE6M2Encoding` returns code 0 for an exact zero with no flags and asserts that other inputs are positive. A value above code `0xFE` (49152) overflows to `0xFF`, or `0xFE` with saturation, with OF and NX. Otherwise the nearest of codes 0 to 254 is chosen; RNE breaks ties by even code, and every other mode by the larger value. A value below code 0 (2^-48) that is inexact reports UF and NX.

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-boundaries role=boundaries -->
## Architectural boundaries

These encoders see only finite real values: the TCVT conversion wrappers handle NaN, infinity, and signed zero first. The four-bit encoder handles the sign of a finite value itself; only the E6M2 wrapper rejects negative inputs, with `0xFF` and NV. The matrix quantization encoder `ReferenceMatrixFloatingEncoding` also calls both encoders.

TCVT legality allows only RNE and RNA when E6M2 is involved, so the other E6M2 tie rules are not reached through TCVT.

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-example role=example-usage -->
## Non-normative reading example

Encode 2.5 as E2M1X2.

- The neighbors are 2.0 (code 4) and 3.0 (code 5), both at distance 0.5.
- RNE picks the even code 4 (2.0), with NX.
- RNA picks the larger magnitude, code 5 (3.0), with NX.
- RTO first picks 2.0 (code 4), then moves to code 5 because 4 is even.

Encode negative 0.3 as E1M2X2 with RNE. The nearest value is negative 0.25 (code 9). The result is inexact and 0.3 is not below 0.25, so the flags are NX only.

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-related role=related-owners-navigation -->
## Related owners

- [TCVT conversion](tcvt-conversion.md) wraps these encoders with special-value handling.
- [Matrix quantization](../execution/matrix-quantization.md) owns `ReferenceMatrixFloatingEncoding`.
- [E2M1X2 format](../../../arch/data-types/formats/e2m1x2.md) and [E1M2X2 format](../../../arch/data-types/formats/e1m2x2.md) own the lane encodings.
- [E6M2 format](../../../arch/data-types/formats/e6m2.md) owns the scale encoding.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/packed-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION","surface":"tile","classification":["model","numeric","packed-conversion"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS","PTO-ARCH-DATA-TYPES-FORMAT-E6M2","PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2"]}

pure func ReferencePacked4FiniteValue(
    data_type: TileDataType, code: integer {0..15}) => real
begin
    assert data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2;
    let negative = code >= 8;
    let magnitude_code = if negative then code - 8 else code;
    var magnitude: real = 0.0;
    if data_type == TileDataType_E2M1X2 then
        case magnitude_code of
            when 0 => magnitude = 0.0;
            when 1 => magnitude = 0.5;
            when 2 => magnitude = 1.0;
            when 3 => magnitude = 1.5;
            when 4 => magnitude = 2.0;
            when 5 => magnitude = 3.0;
            when 6 => magnitude = 4.0;
            when 7 => magnitude = 6.0;
        end;
    else
        magnitude = Real(magnitude_code) / 4.0;
    end;
    if negative then return -magnitude; end;
    return magnitude;
end;

pure func ReferencePacked4CandidateBetter(
    target: real, candidate: real, candidate_code: integer {0..15},
    best: real, best_code: integer {0..15},
    mode: NumericRoundingMode) => boolean
begin
    let candidate_distance = if candidate >= target then
        candidate - target else target - candidate;
    let best_distance = if best >= target then
        best - target else target - best;
    if candidate_distance < best_distance then return TRUE;
    elsif candidate_distance > best_distance then return FALSE;
    end;
    if candidate == 0.0 && best == 0.0 && target < 0.0 then
        return candidate_code >= 8 && best_code < 8;
    end;
    if mode == NumericRound_RNE then
        return candidate_code MOD 2 == 0 && best_code MOD 2 != 0;
    elsif mode == NumericRound_RNA then
        let candidate_magnitude = if candidate < 0.0 then -candidate else candidate;
        let best_magnitude = if best < 0.0 then -best else best;
        return candidate_magnitude > best_magnitude;
    elsif mode == NumericRound_RTO then
        return candidate_code MOD 2 != 0 && best_code MOD 2 == 0;
    else
        return candidate > best;
    end;
end;

func ReferencePacked4Encoding(
    value: real, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_E2M1X2 ||
           destination_type == TileDataType_E1M2X2;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    let magnitude = if negative then -value else value;
    let maximum = if destination_type == TileDataType_E2M1X2 then 6.0
        else 1.75;
    if magnitude > maximum then
        return (
            Zeros{PTO_XLEN} + (if negative then
                (if destination_type == TileDataType_E2M1X2 then 14 else 15)
                else if destination_type == TileDataType_E2M1X2 then 6
                else 7),
            Zeros{5} + 0x14);
    end;

    var best_set = FALSE;
    var best_code: integer {0..15} = 0;
    var best_value: real = 0.0;
    for code = 0 to 15 do
        let candidate = ReferencePacked4FiniteValue(
            destination_type, code as integer {0..15});
        var eligible = TRUE;
        if control.rounding_mode == NumericRound_RTP then
            eligible = candidate >= value;
        elsif control.rounding_mode == NumericRound_RTM then
            eligible = candidate <= value;
        elsif control.rounding_mode == NumericRound_RTZ ||
              control.rounding_mode == NumericRound_RTO then
            eligible = if negative then candidate <= 0.0 && candidate >= value
                else candidate >= 0.0 && candidate <= value;
        end;
        if eligible then
                var better = !best_set;
                if best_set then
                    if control.rounding_mode == NumericRound_RTP then
                        better = candidate < best_value ||
                            (candidate == best_value && value < 0.0 &&
                             code >= 8 && best_code < 8);
                elsif control.rounding_mode == NumericRound_RTM then
                    better = candidate > best_value;
                elsif control.rounding_mode == NumericRound_RTZ ||
                      control.rounding_mode == NumericRound_RTO then
                    better = if negative then
                        candidate < best_value ||
                        (candidate == best_value &&
                         code >= 8 && best_code < 8)
                        else candidate > best_value;
                else
                    better = ReferencePacked4CandidateBetter(
                        value, candidate, code as integer {0..15},
                        best_value, best_code, control.rounding_mode);
                end;
            end;
            if better then
                best_set = TRUE;
                best_code = code as integer {0..15};
                best_value = candidate;
            end;
        end;
    end;
    assert best_set;
    if control.rounding_mode == NumericRound_RTO &&
       best_value != value && best_code MOD 2 == 0 then
        assert best_code < 15;
        best_code = (best_code + 1) as integer {0..15};
        best_value = ReferencePacked4FiniteValue(
            destination_type, best_code);
    end;
    let minimum_normal = if destination_type == TileDataType_E2M1X2
        then 1.0 else 0.25;
    let inexact = best_value != value;
    let best_magnitude = if best_value < 0.0 then -best_value else best_value;
    let underflow = if destination_type == TileDataType_E2M1X2 then
        inexact && best_magnitude < minimum_normal
        else inexact && magnitude < minimum_normal;
    return (Zeros{PTO_XLEN} + best_code,
            if underflow then Zeros{5} + 0x18
            else if inexact then Zeros{5} + 0x10
            else Zeros{5});
end;

pure func ReferenceE6M2CandidateBetter(
    target: real, candidate: real, candidate_code: integer {0..254},
    best: real, best_code: integer {0..254},
    mode: NumericRoundingMode) => boolean
begin
    let candidate_distance = if candidate >= target then
        candidate - target else target - candidate;
    let best_distance = if best >= target then
        best - target else target - best;
    if candidate_distance < best_distance then return TRUE;
    elsif candidate_distance > best_distance then return FALSE;
    end;
    if mode == NumericRound_RNE then
        return candidate_code MOD 2 == 0 && best_code MOD 2 != 0;
    elsif mode == NumericRound_RNA then
        return candidate > best;
    else
        return candidate > best;
    end;
end;

func ReferenceE6M2Encoding(
    value: real, control: NumericExecutionControl) => (Word, bits(5))
begin
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    assert value > 0.0;
    let maximum = E6M2FiniteValue(Zeros{8} + 0xfe);
    if value > maximum then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;

    var best_set = FALSE;
    var best_code: integer {0..254} = 0;
    var best_value: real = 0.0;
    for code = 0 to 254 do
        let candidate = E6M2FiniteValue(Zeros{8} + code);
        var better = !best_set;
        if best_set then
            better = ReferenceE6M2CandidateBetter(
                value, candidate, code as integer {0..254},
                best_value, best_code, control.rounding_mode);
        end;
        if better then
            best_set = TRUE;
            best_code = code as integer {0..254};
            best_value = candidate;
        end;
    end;
    assert best_set;
    let inexact = best_value != value;
    let underflow = inexact && value < E6M2FiniteValue(Zeros{8});
    return (Zeros{PTO_XLEN} + best_code,
            if underflow then Zeros{5} + 0x18
            else if inexact then Zeros{5} + 0x10
            else Zeros{5});
end;
```
<!-- GENERATED-ASL-END: unit -->
