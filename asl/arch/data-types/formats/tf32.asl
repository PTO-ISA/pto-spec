// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-TF32","surface":"arch","classification":["data-types","formats","tf32"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact TF32 encoding and finite values.

pure func TF32NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 32, lane_bits = 32, lanes_per_carrier = 1,
        sign_bits = 1, sign_bit = 31,
        exponent_bits_min = 8, exponent_bits_max = 8,
        fraction_bits_min = 10, fraction_bits_max = 10,
        exponent_bias_available = TRUE, exponent_bias = 127,
        required_low_zero_bits = 13, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = TRUE,
        has_infinity = TRUE, has_quiet_nan = TRUE,
        has_signaling_nan = TRUE
    };
end;

pure func TF32FiniteDecomposition(value: bits(32))
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    if value[12:0] != Zeros{13} then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
    let exponent = value[30:23];
    let fraction = value[22:13];
    if exponent == Ones{8} then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    elsif exponent == Zeros{8} then
        if fraction == Zeros{10} then
            return (TRUE, value[31] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, value[31] == '1',
                     ZeroExtend{PTO_XLEN}(fraction), -136);
        end;
    else return (TRUE, value[31] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 10) +
                     ZeroExtend{PTO_XLEN}(fraction),
                 (UInt(exponent) - (127 + 10))
                     as integer {-1074..1023});
    end;
end;

pure func TF32EncodingValid(value: bits(32)) => boolean
begin
    return value[12:0] == Zeros{13};
end;
pure func ClassifyTF32(value: bits(32)) => NumericValueClass
begin
    let exponent = value[30:23];
    let fraction = value[22:13];
    if exponent == Ones{8} then
        if fraction == Zeros{10} then
            if value[31] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif fraction[9] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[31],
        exponent == Zeros{8} && fraction == Zeros{10},
        exponent == Zeros{8} && fraction != Zeros{10});
end;

pure func TF32CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0x7fc00000;
end;

pure func TF32SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x80000000);
end;
// DOC-END: operation
