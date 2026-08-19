// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-FP64","surface":"arch","classification":["data-types","formats","fp64"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact FP64 encoding and finite values.

pure func FP64NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 64, lane_bits = 64, lanes_per_carrier = 1,
        sign_bits = 1, sign_bit = 63,
        exponent_bits_min = 11, exponent_bits_max = 11,
        fraction_bits_min = 52, fraction_bits_max = 52,
        exponent_bias_available = TRUE, exponent_bias = 1023,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = TRUE,
        has_infinity = TRUE, has_quiet_nan = TRUE,
        has_signaling_nan = TRUE
    };
end;

pure func FP64FiniteDecomposition(value: Word)
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    let exponent = value[62:52];
    let fraction = value[51:0];
    if exponent == Ones{11} then
        return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    elsif exponent == Zeros{11} then
        if fraction == Zeros{52} then
            return (TRUE, value[63] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, value[63] == '1',
                     ZeroExtend{PTO_XLEN}(fraction), -1074);
        end;
    else return (TRUE, value[63] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 52) +
                     ZeroExtend{PTO_XLEN}(fraction),
                 (UInt(exponent) - (1023 + 52))
                     as integer {-1074..1023});
    end;
end;
pure func ClassifyFP64(value: Word) => NumericValueClass
begin
    let exponent = value[62:52];
    let fraction = value[51:0];
    if exponent == Ones{11} then
        if fraction == Zeros{52} then
            if value[63] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif fraction[51] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[63],
        exponent == Zeros{11} && fraction == Zeros{52},
        exponent == Zeros{11} && fraction != Zeros{52});
end;

pure func FP64CanonicalNaN() => Word
begin
    return Zeros{PTO_XLEN} + 0x7ff8000000000000;
end;

pure func FP64SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x8000000000000000);
end;
// DOC-END: operation
