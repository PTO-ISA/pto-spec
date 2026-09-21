<!-- GENERATED FROM: asl/tile/model/numeric/packed-conversion.asl -->
# Packed Conversion

**Normative ASL source:** `asl/tile/model/numeric/packed-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION}

<!-- SUPPLEMENTARY-BEGIN -->

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
