<!-- GENERATED FROM: asl/scalar/model/fsu/arithmetic.asl -->
# Arithmetic

**Normative ASL source:** `asl/scalar/model/fsu/arithmetic.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-ARITHMETIC}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/fsu/arithmetic.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-FSU-ARITHMETIC","surface":"scalar","classification":["model","fsu","arithmetic"],"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION"]}
// PTO-REQ-SCALAR-FP-001: mathematical floating semantics.
// Encoding, NaN payload, exception flag, and rounding-profile rules remain
// separate from this real-number value layer.

pure func FloatingBinary(op: FloatingBinaryOperation, left: real, right: real) => real
begin
    case op of
        when FloatingBinary_ADD => return left + right;
        when FloatingBinary_SUB => return left - right;
        when FloatingBinary_MUL => return left * right;
        when FloatingBinary_DIV => return left / right;
        when FloatingBinary_MIN => if left < right then return left; else return right; end;
        when FloatingBinary_MAX => if left > right then return left; else return right; end;
    end;
end;

pure func FloatingCompare(op: FloatingCompareOperation, left: real, right: real) => boolean
begin
    case op of
        when FloatingCompare_EQ => return left == right;
        when FloatingCompare_NE => return left != right;
        when FloatingCompare_LT => return left < right;
        when FloatingCompare_LE => return left <= right;
        when FloatingCompare_GT => return left > right;
        when FloatingCompare_GE => return left >= right;
    end;
end;

impdef func FloatingExponential(value: real) => real
begin
    // The executable default is stable; a numeric profile supplies IEEE encoding.
    return value;
end;

func FloatingUnary(op: FloatingUnaryOperation, value: real) => real
begin
    case op of
        when FloatingUnary_ABS => if value < 0.0 then return -value; else return value; end;
        when FloatingUnary_SQRT =>
            assert value >= 0.0;
            return SqrtRounded(value, 100);
        when FloatingUnary_EXP => return FloatingExponential(value);
        when FloatingUnary_RECIP => return 1.0 / value;
    end;
end;

pure func FloatingFused(op: FloatingFusedOperation, addend: real,
                        left: real, right: real) => real
begin
    let product = left * right;
    case op of
        when FloatingFused_MADD => return product + addend;
        when FloatingFused_MSUB => return product - addend;
        when FloatingFused_NMADD => return -(product + addend);
        when FloatingFused_NMSUB => return -(product - addend);
    end;
end;

impdef func FloatingRoundNearest(value: real) => integer
begin
    if value >= 0.0 then return RoundDown(value + 0.5);
    else return RoundUp(value - 0.5);
    end;
end;

func FloatingToInteger(value: real, mode: NumericRoundingMode) => integer
begin
    case mode of
        when NumericRound_RNE => return FloatingRoundNearest(value);
        when NumericRound_RTP => return RoundUp(value);
        when NumericRound_RTM => return RoundDown(value);
        when NumericRound_RTZ => return RoundTowardsZero(value);
        when NumericRound_RNA =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction < 0.5 then return lower;
            elsif fraction > 0.5 then return lower + 1;
            elsif value < 0.0 then return lower;
            else return lower + 1;
            end;
        when NumericRound_RTO =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction == 0.0 then return lower;
            elsif lower MOD 2 != 0 then return lower;
            else return lower + 1;
            end;
        when NumericRound_RHB =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction < 0.5 then return lower;
            else return lower + 1;
            end;
    end;
end;

pure func ResolveScalarFPActiveRoundingMode(encoded: bits(3))
                                                => NumericRoundingMode
begin
    if encoded == '001' then return NumericRound_RTM;
    elsif encoded == '010' then return NumericRound_RTP;
    elsif encoded == '011' then return NumericRound_RTZ;
    else return NumericRound_RNE;
    end;
end;

pure func DecodeBundleRoundingSelection(encoded: bits(3))
                                                => TileNumericSelection
begin
    var result = TileNumericSelection {
        use_operation_default = encoded == '000',
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    if encoded == '010' then result.rounding_mode = NumericRound_RTZ;
    elsif encoded == '011' then result.rounding_mode = NumericRound_RTM;
    elsif encoded == '100' then result.rounding_mode = NumericRound_RTP;
    elsif encoded == '101' then result.rounding_mode = NumericRound_RNA;
    elsif encoded == '110' then result.rounding_mode = NumericRound_RTO;
    elsif encoded == '111' then result.rounding_mode = NumericRound_RHB;
    end;
    return result;
end;

// Public conversion controls are not B.DATR encodings. Translate the seven
// assigned public ordinals explicitly; ordinal 7 is unassigned.
pure func DecodePublicConversionRoundingSelection(encoded: bits(3))
                                                => (boolean, TileNumericSelection)
begin
    if encoded == '000' then return (TRUE, DecodeBundleRoundingSelection('000'));
    elsif encoded == '001' then return (TRUE, DecodeBundleRoundingSelection('001'));
    elsif encoded == '010' then return (TRUE, DecodeBundleRoundingSelection('101'));
    elsif encoded == '011' then return (TRUE, DecodeBundleRoundingSelection('011'));
    elsif encoded == '100' then return (TRUE, DecodeBundleRoundingSelection('100'));
    elsif encoded == '101' then return (TRUE, DecodeBundleRoundingSelection('010'));
    elsif encoded == '110' then return (TRUE, DecodeBundleRoundingSelection('110'));
    else return (FALSE, DecodeBundleRoundingSelection('000'));
    end;
end;

pure func SignedWordToReal(value: Word) => real
begin
    return Real(SInt(value));
end;

pure func UnsignedWordToReal(value: Word) => real
begin
    return Real(UInt(value));
end;

func ConvertFloatingEncoding(value: Word, source_type: bits(5),
                             destination_type: bits(5),
                             rounding_mode: bits(3)) => Word
begin
    let (converted, -) = ScalarFPConvertProfile(
        ResolveScalarFPActiveRoundingMode(rounding_mode),
        destination_type, source_type, value);
    return converted;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
