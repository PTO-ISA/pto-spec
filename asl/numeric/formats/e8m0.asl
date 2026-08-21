// PTO-REQ-HARDWARE-NUMERIC-001: exact E8M0 power-of-two scale.

pure func E8M0NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_E8M0,
        carrier_bits = 8, lane_bits = 8, lanes_per_carrier = 1,
        sign_bits = 0, sign_bit = 0,
        exponent_bits_min = 8, exponent_bits_max = 8,
        fraction_bits_min = 0, fraction_bits_max = 0,
        exponent_bias_available = TRUE, exponent_bias = 127,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = FALSE, has_signed_zero = FALSE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = TRUE,
        has_signaling_nan = FALSE
    };
end;

pure func E8M0FiniteDecomposition(value: bits(8))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    if value == Ones{8} then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    else return (TRUE, FALSE, Zeros{PTO_XLEN} + 1,
                 (UInt(value) - 127) as integer {-1074..1023});
    end;
end;

pure func ClassifyE8M0(value: bits(8)) => NumericValueClass
begin
    if value == Ones{8} then return NumericValue_QuietNaN;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func E8M0CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0xff;
end;

pure func HardwareNumericScaleBlockElements() => integer {32}
begin
    return 32;
end;
