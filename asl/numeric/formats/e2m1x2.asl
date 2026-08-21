// PTO-REQ-HARDWARE-NUMERIC-001: exact E2M1 logical lanes.

pure func E2M1X2NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 4, lanes_per_carrier = 2,
        sign_bits = 1, sign_bit = 3,
        exponent_bits_min = 2, exponent_bits_max = 2,
        fraction_bits_min = 1, fraction_bits_max = 1,
        exponent_bias_available = TRUE, exponent_bias = 1,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;

pure func E2M1X2FiniteDecomposition(value: Word)
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    let lane = value[3:0];
    let exponent = lane[2:1];
    let fraction = lane[0:0];
    if exponent == Zeros{2} then
        if fraction == Zeros{1} then
            return (TRUE, lane[3] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, lane[3] == '1', Zeros{PTO_XLEN} + 1, -1);
        end;
    else return (TRUE, lane[3] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 1) +
                     ZeroExtend{PTO_XLEN}(fraction),
                 (UInt(exponent) - 2) as integer {-1074..1023});
    end;
end;

pure func ClassifyE2M1X2(value: Word) => NumericValueClass
begin
    return NumericValueClassFromFiniteSign(value[3],
        value[2:0] == Zeros{3}, FALSE);
end;

pure func E2M1X2SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x8);
end;
