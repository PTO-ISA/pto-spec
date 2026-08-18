// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-E2M3","surface":"arch","classification":["data-types","formats","e2m3"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact zero-extended E2M3 values.

pure func E2M3NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 6, lanes_per_carrier = 1,
        sign_bits = 1, sign_bit = 5,
        exponent_bits_min = 2, exponent_bits_max = 2,
        fraction_bits_min = 3, fraction_bits_max = 3,
        exponent_bias_available = TRUE, exponent_bias = 1,
        required_low_zero_bits = 0, required_high_zero_bits = 2,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = TRUE,
        has_infinity = FALSE, has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;

pure func E2M3FiniteDecomposition(value: bits(8))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    if value[7:6] != Zeros{2} then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
    let exponent = value[4:3];
    let fraction = value[2:0];
    if exponent == Zeros{2} then
        if fraction == Zeros{3} then
            return (TRUE, value[5] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, value[5] == '1',
                     ZeroExtend{PTO_XLEN}(fraction), -3);
        end;
    else return (TRUE, value[5] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 3) +
                     ZeroExtend{PTO_XLEN}(fraction),
                 (UInt(exponent) - (1 + 3))
                     as integer {-1074..1023});
    end;
end;

pure func E2M3EncodingValid(value: bits(8)) => boolean
begin
    return value[7:6] == Zeros{2};
end;
pure func ClassifyE2M3(value: bits(8)) => NumericValueClass
begin
    let exponent = value[4:3];
    let fraction = value[2:0];
    return NumericValueClassFromFiniteSign(value[5],
        exponent == Zeros{2} && fraction == Zeros{3},
        exponent == Zeros{2} && fraction != Zeros{3});
end;

pure func E2M3SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x20);
end;
// DOC-END: operation
