// PTO-REQ-PROFILE-001, PTO-REQ-HARDWARE-NUMERIC-001:
// bit-exact value classification for every TileDataType.

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

pure func TileNumericFormatDescriptor(data_type: TileDataType)
    => NumericFormatDescriptor
begin
    case data_type of
        when TileDataType_FP64 => return FP64NumericFormatDescriptor();
        when TileDataType_FP32 => return FP32NumericFormatDescriptor();
        when TileDataType_TF32 => return TF32NumericFormatDescriptor();
        when TileDataType_HF32 => return HF32NumericFormatDescriptor();
        when TileDataType_FP16 => return FP16NumericFormatDescriptor();
        when TileDataType_BF16 => return BF16NumericFormatDescriptor();
        when TileDataType_HiF8 => return HiF8NumericFormatDescriptor();
        when TileDataType_E4M3 => return E4M3NumericFormatDescriptor();
        when TileDataType_E5M2 => return E5M2NumericFormatDescriptor();
        when TileDataType_E3M2 => return E3M2NumericFormatDescriptor();
        when TileDataType_E2M3 => return E2M3NumericFormatDescriptor();
        when TileDataType_E2M1X2 => return E2M1X2NumericFormatDescriptor();
        when TileDataType_E1M2X2 => return E1M2X2NumericFormatDescriptor();
        when TileDataType_E8M0 => return E8M0NumericFormatDescriptor();
        when TileDataType_HiF4X2 => return HiF4X2NumericFormatDescriptor();
        otherwise => return UnavailableNumericFormatDescriptor();
    end;
end;

// When available is TRUE, the value equals
// (-1)^negative * UInt(significand) * 2^exponent exactly.
pure func TileNumericFiniteDecomposition(data_type: TileDataType,
                                          value: Word)
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    case data_type of
        when TileDataType_FP64 => return FP64FiniteDecomposition(value);
        when TileDataType_FP32 => return FP32FiniteDecomposition(value[31:0]);
        when TileDataType_TF32 => return TF32FiniteDecomposition(value[31:0]);
        when TileDataType_HF32 => return HF32FiniteDecomposition(value[31:0]);
        when TileDataType_FP16 => return FP16FiniteDecomposition(value[15:0]);
        when TileDataType_BF16 => return BF16FiniteDecomposition(value[15:0]);
        when TileDataType_HiF8 => return HiF8FiniteDecomposition(value[7:0]);
        when TileDataType_E4M3 => return E4M3FiniteDecomposition(value[7:0]);
        when TileDataType_E5M2 => return E5M2FiniteDecomposition(value[7:0]);
        when TileDataType_E3M2 => return E3M2FiniteDecomposition(value[7:0]);
        when TileDataType_E2M3 => return E2M3FiniteDecomposition(value[7:0]);
        when TileDataType_E2M1X2 => return E2M1X2FiniteDecomposition(value);
        when TileDataType_E1M2X2 => return E1M2X2FiniteDecomposition(value);
        when TileDataType_E8M0 => return E8M0FiniteDecomposition(value[7:0]);
        when TileDataType_HiF4X2 => return HiF4X2FiniteDecomposition(value);
        otherwise => return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
end;

pure func NumericValueClassIsNaN(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_QuietNaN ||
           value_class == NumericValue_SignalingNaN;
end;

pure func NumericValueClassIsInfinity(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveInfinity ||
           value_class == NumericValue_NegativeInfinity;
end;

pure func NumericValueClassIsZero(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveZero ||
           value_class == NumericValue_NegativeZero;
end;

pure func NumericValueClassIsSubnormal(value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_PositiveSubnormal ||
           value_class == NumericValue_NegativeSubnormal;
end;

pure func HardwareNumericTypeHasSubnormals(data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_HiF8, TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_E3M2, TileDataType_E2M3 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func HardwareNumericInputSubnormalRule(data_type: TileDataType)
    => NumericInputSubnormalRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericInputSubnormal_Preserve;
    else return NumericInputSubnormal_NotApplicable;
    end;
end;

pure func HardwareNumericResultSubnormalRule(data_type: TileDataType)
    => NumericResultSubnormalRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericResultSubnormal_GradualUnderflow;
    else return NumericResultSubnormal_NotApplicable;
    end;
end;

pure func HardwareNumericTininessDetectionRule(data_type: TileDataType)
    => NumericTininessDetectionRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericTininessDetection_AfterRounding;
    else return NumericTininessDetection_NotApplicable;
    end;
end;

// These booleans describe a candidate conformance configuration. They are not
// architectural mode bits. The 0.58.0 hardware profile exposes no FTZ/DAZ
// state and permits no operation-local override.
pure func HardwareNumericSubnormalConfigurationValid(flush_to_zero: boolean,
                                                       denormals_are_zero: boolean,
                                                       operation_override: boolean)
    => boolean
begin
    return !flush_to_zero && !denormals_are_zero && !operation_override;
end;

// Returns availability, minimum positive subnormal, maximum positive
// subnormal, and minimum positive normal. Values are exact raw encodings.
pure func HardwareNumericSubnormalBoundaries(data_type: TileDataType)
    => (boolean, Word, Word, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x000fffffffffffff,
                    Zeros{PTO_XLEN} + 0x0010000000000000);
        when TileDataType_FP32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x007fffff,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_TF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x00002000,
                    Zeros{PTO_XLEN} + 0x007fe000,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_HF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x00001000,
                    Zeros{PTO_XLEN} + 0x007ff000,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_FP16 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x03ff,
                    Zeros{PTO_XLEN} + 0x0400);
        when TileDataType_BF16 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x007f,
                    Zeros{PTO_XLEN} + 0x0080);
        when TileDataType_HiF8 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E4M3 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E5M2, TileDataType_E3M2 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x03,
                    Zeros{PTO_XLEN} + 0x04);
        when TileDataType_E2M3 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        otherwise =>
            return (FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
                    Zeros{PTO_XLEN});
    end;
end;

// The ASL Word is a verification carrier. Bits above a type's architectural
// element width are ignored. Only constraints inside the architectural
// element are checked here.
pure func TileNumericEncodingValid(data_type: TileDataType,
                                   value: Word) => boolean
begin
    case data_type of
        when TileDataType_TF32 => return TF32EncodingValid(value[31:0]);
        when TileDataType_HF32 => return HF32EncodingValid(value[31:0]);
        when TileDataType_E3M2 => return E3M2EncodingValid(value[7:0]);
        when TileDataType_E2M3 => return E2M3EncodingValid(value[7:0]);
        otherwise => return TRUE;
    end;
end;

pure func ClassifySignedInteger(value: Word, sign_bit: integer {3,7,15,31,63})
    => NumericValueClass
begin
    var zero = FALSE;
    case sign_bit of
        when 3 => zero = value[3:0] == Zeros{4};
        when 7 => zero = value[7:0] == Zeros{8};
        when 15 => zero = value[15:0] == Zeros{16};
        when 31 => zero = value[31:0] == Zeros{32};
        when 63 => zero = value == Zeros{PTO_XLEN};
    end;
    if zero then return NumericValue_PositiveZero;
    elsif value[sign_bit] == '1' then return NumericValue_NegativeNormal;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func ClassifyUnsignedInteger(value: Word, width: integer {4,8,16,32,64})
    => NumericValueClass
begin
    var zero = FALSE;
    case width of
        when 4 => zero = value[3:0] == Zeros{4};
        when 8 => zero = value[7:0] == Zeros{8};
        when 16 => zero = value[15:0] == Zeros{16};
        when 32 => zero = value[31:0] == Zeros{32};
        when 64 => zero = value == Zeros{PTO_XLEN};
    end;
    if zero then return NumericValue_PositiveZero;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func TileNumericValueClass(data_type: TileDataType,
                                value: Word) => NumericValueClass
begin
    if !TileNumericEncodingValid(data_type, value) then
        return NumericValue_InvalidEncoding;
    end;
    case data_type of
        when TileDataType_FP64 => return ClassifyFP64(value);
        when TileDataType_FP32 => return ClassifyFP32(value[31:0]);
        when TileDataType_TF32 => return ClassifyTF32(value[31:0]);
        when TileDataType_HF32 => return ClassifyHF32(value[31:0]);
        when TileDataType_FP16 => return ClassifyFP16(value[15:0]);
        when TileDataType_BF16 => return ClassifyBF16(value[15:0]);
        when TileDataType_HiF8 => return ClassifyHiF8(value[7:0]);
        when TileDataType_E4M3 => return ClassifyE4M3(value[7:0]);
        when TileDataType_E5M2 => return ClassifyE5M2(value[7:0]);
        when TileDataType_E3M2 => return ClassifyE3M2(value[7:0]);
        when TileDataType_E2M3 => return ClassifyE2M3(value[7:0]);
        when TileDataType_E2M1X2 => return ClassifyE2M1X2(value);
        when TileDataType_E1M2X2 => return ClassifyE1M2X2(value);
        when TileDataType_E8M0 => return ClassifyE8M0(value[7:0]);
        when TileDataType_HiF4X2 => return ClassifyHiF4X2(value);
        when TileDataType_S64 => return ClassifySignedInteger(value, 63);
        when TileDataType_S32 => return ClassifySignedInteger(value, 31);
        when TileDataType_S16 => return ClassifySignedInteger(value, 15);
        when TileDataType_S8 => return ClassifySignedInteger(value, 7);
        when TileDataType_S4X2 => return ClassifySignedInteger(value, 3);
        when TileDataType_U64 => return ClassifyUnsignedInteger(value, 64);
        when TileDataType_U32 => return ClassifyUnsignedInteger(value, 32);
        when TileDataType_U16 => return ClassifyUnsignedInteger(value, 16);
        when TileDataType_U8 => return ClassifyUnsignedInteger(value, 8);
        when TileDataType_U4X2 => return ClassifyUnsignedInteger(value, 4);
    end;
end;

pure func TileNumericCanonicalNaN(data_type: TileDataType) => (boolean, Word)
begin
    case data_type of
        when TileDataType_FP64 => return (TRUE, FP64CanonicalNaN());
        when TileDataType_FP32 => return (TRUE, FP32CanonicalNaN());
        when TileDataType_TF32 => return (TRUE, TF32CanonicalNaN());
        when TileDataType_HF32 => return (TRUE, HF32CanonicalNaN());
        when TileDataType_FP16 => return (TRUE, FP16CanonicalNaN());
        when TileDataType_BF16 => return (TRUE, BF16CanonicalNaN());
        when TileDataType_HiF8 => return (TRUE, HiF8CanonicalNaN());
        when TileDataType_E4M3 => return (TRUE, E4M3CanonicalNaN());
        when TileDataType_E5M2 => return (TRUE, E5M2CanonicalNaN());
        when TileDataType_E8M0 => return (TRUE, E8M0CanonicalNaN());
        otherwise => return (FALSE, Zeros{PTO_XLEN});
    end;
end;

// Named hardware-profile special-result helpers. These functions classify
// only cases whose result is fixed without evaluating ordinary arithmetic.
// Invalid internal encodings and non-special operands remain unhandled so a
// complete operation/type profile must reject or evaluate them explicitly.
pure func HardwareNumericCanonicalNaNResult(data_type: TileDataType)
    => (boolean, Word)
begin
    return TileNumericCanonicalNaN(data_type);
end;

pure func HardwareNumericSignedZeroEncodings(data_type: TileDataType)
    => (boolean, Word, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            let (positive, negative) = FP64SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_FP32 =>
            let (positive, negative) = FP32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_TF32 =>
            let (positive, negative) = TF32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_HF32 =>
            let (positive, negative) = HF32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_FP16 =>
            let (positive, negative) = FP16SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_BF16 =>
            let (positive, negative) = BF16SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E4M3 =>
            let (positive, negative) = E4M3SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E5M2 =>
            let (positive, negative) = E5M2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E3M2 =>
            let (positive, negative) = E3M2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E2M3 =>
            let (positive, negative) = E2M3SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E2M1X2 =>
            let (positive, negative) = E2M1X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E1M2X2 =>
            let (positive, negative) = E1M2X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_HiF4X2 =>
            let (positive, negative) = HiF4X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        otherwise => return (FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    end;
end;

// Returns handled, result carrier, and invalid-condition status. NaN
// comparisons are unordered except NE, and signed zeros compare equal.
pure func HardwareNumericComparisonSpecial(
    comparison: TileComparison, data_type: TileDataType,
    left: Word, right: Word) => (boolean, Word, boolean)
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if left_class == NumericValue_InvalidEncoding ||
       right_class == NumericValue_InvalidEncoding then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);
    let invalid = left_class == NumericValue_SignalingNaN ||
                  right_class == NumericValue_SignalingNaN;
    if left_nan || right_nan then
        if comparison == TileComparison_NE then
            return (TRUE, Zeros{PTO_XLEN} + 1, invalid);
        else return (TRUE, Zeros{PTO_XLEN}, invalid);
        end;
    end;
    if NumericValueClassIsZero(left_class) &&
       NumericValueClassIsZero(right_class) then
        if comparison == TileComparison_EQ || comparison == TileComparison_LE ||
           comparison == TileComparison_GE then
            return (TRUE, Zeros{PTO_XLEN} + 1, FALSE);
        else return (TRUE, Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, FALSE);
end;

// Returns handled, result carrier, and invalid-condition status for MIN/MAX
// NaN and zero ties. One NaN selects the numeric operand, two NaNs produce the
// destination canonical NaN, MIN chooses -0, and MAX chooses +0.
pure func HardwareNumericMinMaxSpecial(
    maximum: boolean, data_type: TileDataType,
    left: Word, right: Word) => (boolean, Word, boolean)
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if left_class == NumericValue_InvalidEncoding ||
       right_class == NumericValue_InvalidEncoding then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);
    let invalid = left_class == NumericValue_SignalingNaN ||
                  right_class == NumericValue_SignalingNaN;
    if left_nan && right_nan then
        let (available, canonical) =
            HardwareNumericCanonicalNaNResult(data_type);
        assert available;
        return (TRUE, canonical, invalid);
    elsif left_nan then return (TRUE, right, invalid);
    elsif right_nan then return (TRUE, left, invalid);
    end;
    if NumericValueClassIsZero(left_class) &&
       NumericValueClassIsZero(right_class) then
        if maximum && left_class == NumericValue_NegativeZero &&
           right_class == NumericValue_NegativeZero then
            return (TRUE, left, FALSE);
        elsif maximum then return (TRUE, Zeros{PTO_XLEN}, FALSE);
        elsif left_class == NumericValue_NegativeZero then
            return (TRUE, left, FALSE);
        elsif right_class == NumericValue_NegativeZero then
            return (TRUE, right, FALSE);
        else return (TRUE, Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, FALSE);
end;
