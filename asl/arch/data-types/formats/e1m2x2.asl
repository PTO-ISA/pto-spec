// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2","surface":"arch","classification":["data-types","formats","e1m2x2"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact HiF4 S1P2 logical lanes.

pure func E1M2X2NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 4, lanes_per_carrier = 2,
        sign_bits = 1, sign_bit = 3,
        exponent_bits_min = 0, exponent_bits_max = 0,
        fraction_bits_min = 3, fraction_bits_max = 3,
        exponent_bias_available = FALSE, exponent_bias = 0,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;

pure func E1M2X2FiniteDecomposition(value: Word)
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    let lane = value[3:0];
    let magnitude = lane[2:0];
    if magnitude == Zeros{3} then
        return (TRUE, lane[3] == '1', Zeros{PTO_XLEN}, 0);
    end;
    return (TRUE, lane[3] == '1',
            ZeroExtend{PTO_XLEN}(magnitude), -2);
end;
pure func ClassifyE1M2X2(value: Word) => NumericValueClass
begin
    return NumericValueClassFromFiniteSign(value[3],
        value[2:0] == Zeros{3}, FALSE);
end;

pure func E1M2X2SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x8);
end;
// DOC-END: operation
