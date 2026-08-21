// PTO-REQ-HARDWARE-NUMERIC-001: exact FP32 encoding and finite values.

pure func FP32NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 32, lane_bits = 32, lanes_per_carrier = 1,
        sign_bits = 1, sign_bit = 31,
        exponent_bits_min = 8, exponent_bits_max = 8,
        fraction_bits_min = 23, fraction_bits_max = 23,
        exponent_bias_available = TRUE, exponent_bias = 127,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = TRUE,
        has_infinity = TRUE, has_quiet_nan = TRUE,
        has_signaling_nan = TRUE
    };
end;

pure func FP32FiniteDecomposition(value: bits(32))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    let exponent = value[30:23];
    let fraction = value[22:0];
    if exponent == Ones{8} then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    elsif exponent == Zeros{8} then
        if fraction == Zeros{23} then
            return (TRUE, value[31] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, value[31] == '1',
                     ZeroExtend{PTO_XLEN}(fraction), -149);
        end;
    else return (TRUE, value[31] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 23) +
                     ZeroExtend{PTO_XLEN}(fraction),
                 (UInt(exponent) - (127 + 23))
                     as integer {-1074..1023});
    end;
end;

pure func ClassifyFP32(value: bits(32)) => NumericValueClass
begin
    let exponent = value[30:23];
    let fraction = value[22:0];
    if exponent == Ones{8} then
        if fraction == Zeros{23} then
            if value[31] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif fraction[22] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[31],
        exponent == Zeros{8} && fraction == Zeros{23},
        exponent == Zeros{8} && fraction != Zeros{23});
end;

pure func FP32CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0x7fc00000;
end;

pure func FP32SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x80000000);
end;
