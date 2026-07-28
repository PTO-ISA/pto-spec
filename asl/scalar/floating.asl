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

func FloatingToInteger(value: real, mode: FloatingRoundingMode) => integer
begin
    case mode of
        when FloatingRound_Nearest => return FloatingRoundNearest(value);
        when FloatingRound_Up => return RoundUp(value);
        when FloatingRound_Down => return RoundDown(value);
        when FloatingRound_TowardsZero => return RoundTowardsZero(value);
        when FloatingRound_Away =>
            if value >= 0.0 then return RoundUp(value); else return RoundDown(value); end;
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

impdef func ConvertFloatingEncoding(value: Word, source_type: bits(5),
                                    destination_type: bits(5),
                                    rounding_mode: bits(3)) => Word
begin
    // Raw encodings, NaN propagation, flags, and saturation are supplied by a
    // named scalar numeric profile. The default keeps the bit pattern stable.
    return value;
end;
