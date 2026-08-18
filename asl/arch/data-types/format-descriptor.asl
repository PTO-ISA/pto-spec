// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR","surface":"arch","classification":["data-types","format-descriptor"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}

// NDF-BEGIN: PTO-NUMERIC-FORMAT-DESCRIPTOR-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Each assigned floating or scale Tile DataType MUST expose one exact carrier,
// lane, field-width, bias, constrained-bit, and special-value descriptor.
// Integer Tile DataTypes MUST report that no floating-format descriptor exists.
// NDF-END: PTO-NUMERIC-FORMAT-DESCRIPTOR-001

// DOC-BEGIN: operation
type NumericFormatKind of enumeration {
    NumericFormatKind_Unavailable,
    NumericFormatKind_FixedBinary,
    NumericFormatKind_HiF8,
    NumericFormatKind_E8M0
};

type NumericFormatDescriptor of record {
    available: boolean,
    kind: NumericFormatKind,
    carrier_bits: integer {0..64},
    lane_bits: integer {0..64},
    lanes_per_carrier: integer {0..2},
    sign_bits: integer {0..1},
    sign_bit: integer {0..63},
    exponent_bits_min: integer {0..11},
    exponent_bits_max: integer {0..11},
    fraction_bits_min: integer {0..52},
    fraction_bits_max: integer {0..52},
    exponent_bias_available: boolean,
    exponent_bias: integer {0..1023},
    required_low_zero_bits: integer {0..13},
    required_high_zero_bits: integer {0..2},
    has_zero: boolean,
    has_signed_zero: boolean,
    has_subnormal: boolean,
    has_infinity: boolean,
    has_quiet_nan: boolean,
    has_signaling_nan: boolean
};

type HiF8DotField of enumeration {
    HiF8DotField_Denormal,
    HiF8DotField_D0,
    HiF8DotField_D1,
    HiF8DotField_D2,
    HiF8DotField_D3,
    HiF8DotField_D4
};

pure func UnavailableNumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = FALSE,
        kind = NumericFormatKind_Unavailable,
        carrier_bits = 0,
        lane_bits = 0,
        lanes_per_carrier = 0,
        sign_bits = 0,
        sign_bit = 0,
        exponent_bits_min = 0,
        exponent_bits_max = 0,
        fraction_bits_min = 0,
        fraction_bits_max = 0,
        exponent_bias_available = FALSE,
        exponent_bias = 0,
        required_low_zero_bits = 0,
        required_high_zero_bits = 0,
        has_zero = FALSE,
        has_signed_zero = FALSE,
        has_subnormal = FALSE,
        has_infinity = FALSE,
        has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;
// DOC-END: operation
