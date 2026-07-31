// PTO-REQ-PROFILE-001, PTO-REQ-HARDWARE-NUMERIC-001:
// bit-exact value classification for every TileDataType.

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

pure func NumericValueClassFromFiniteSign(sign: bits(1), zero: boolean,
                                           subnormal: boolean)
    => NumericValueClass
begin
    if zero then
        if sign == '1' then return NumericValue_NegativeZero;
        else return NumericValue_PositiveZero;
        end;
    elsif subnormal then
        if sign == '1' then return NumericValue_NegativeSubnormal;
        else return NumericValue_PositiveSubnormal;
        end;
    elsif sign == '1' then return NumericValue_NegativeNormal;
    else return NumericValue_PositiveNormal;
    end;
end;

// The ASL Word is a verification carrier. Bits above a type's architectural
// element width are ignored. Only constraints inside the architectural
// element are checked here.
pure func TileNumericEncodingValid(data_type: TileDataType,
                                   value: Word) => boolean
begin
    case data_type of
        when TileDataType_TF32 => return value[12:0] == Zeros{13};
        when TileDataType_HF32 => return value[11:0] == Zeros{12};
        when TileDataType_E3M2, TileDataType_E2M3 =>
            return value[7:6] == Zeros{2};
        otherwise => return TRUE;
    end;
end;

pure func ClassifyBinary64(value: Word) => NumericValueClass
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

pure func ClassifyBinary32(value: bits(32), retained_fraction_bits: integer {10,11,23})
    => NumericValueClass
begin
    let exponent = value[30:23];
    var fraction_nonzero = value[22:0] != Zeros{23};
    if retained_fraction_bits == 10 then
        fraction_nonzero = value[22:13] != Zeros{10};
    elsif retained_fraction_bits == 11 then
        fraction_nonzero = value[22:12] != Zeros{11};
    end;
    if exponent == Ones{8} then
        if !fraction_nonzero then
            if value[31] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif value[22] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[31],
        exponent == Zeros{8} && !fraction_nonzero,
        exponent == Zeros{8} && fraction_nonzero);
end;

pure func ClassifyBinary16(value: bits(16)) => NumericValueClass
begin
    let exponent = value[14:10];
    let fraction = value[9:0];
    if exponent == Ones{5} then
        if fraction == Zeros{10} then
            if value[15] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif fraction[9] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[15],
        exponent == Zeros{5} && fraction == Zeros{10},
        exponent == Zeros{5} && fraction != Zeros{10});
end;

pure func ClassifyBFloat16(value: bits(16)) => NumericValueClass
begin
    let exponent = value[14:7];
    let fraction = value[6:0];
    if exponent == Ones{8} then
        if fraction == Zeros{7} then
            if value[15] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif fraction[6] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[15],
        exponent == Zeros{8} && fraction == Zeros{7},
        exponent == Zeros{8} && fraction != Zeros{7});
end;

pure func ClassifyHiF8(value: bits(8)) => NumericValueClass
begin
    if value == '10000000' then return NumericValue_QuietNaN;
    elsif value == '01101111' then return NumericValue_PositiveInfinity;
    elsif value == '11101111' then return NumericValue_NegativeInfinity;
    elsif value == Zeros{8} then return NumericValue_PositiveZero;
    elsif UInt(value[6:0]) <= 7 then
        return NumericValueClassFromFiniteSign(value[7], FALSE, TRUE);
    else return NumericValueClassFromFiniteSign(value[7], FALSE, FALSE);
    end;
end;

pure func ClassifyE4M3(value: bits(8)) => NumericValueClass
begin
    let exponent = value[6:3];
    let fraction = value[2:0];
    if exponent == Ones{4} && fraction == Ones{3} then
        return NumericValue_QuietNaN;
    end;
    return NumericValueClassFromFiniteSign(value[7],
        exponent == Zeros{4} && fraction == Zeros{3},
        exponent == Zeros{4} && fraction != Zeros{3});
end;

pure func ClassifyE5M2(value: bits(8)) => NumericValueClass
begin
    let exponent = value[6:2];
    let fraction = value[1:0];
    if exponent == Ones{5} then
        if fraction == Zeros{2} then
            if value[7] == '1' then return NumericValue_NegativeInfinity;
            else return NumericValue_PositiveInfinity;
            end;
        elsif fraction[1] == '1' then return NumericValue_QuietNaN;
        else return NumericValue_SignalingNaN;
        end;
    end;
    return NumericValueClassFromFiniteSign(value[7],
        exponent == Zeros{5} && fraction == Zeros{2},
        exponent == Zeros{5} && fraction != Zeros{2});
end;

pure func ClassifyE3M2(value: bits(8)) => NumericValueClass
begin
    let exponent = value[4:2];
    let fraction = value[1:0];
    return NumericValueClassFromFiniteSign(value[5],
        exponent == Zeros{3} && fraction == Zeros{2},
        exponent == Zeros{3} && fraction != Zeros{2});
end;

pure func ClassifyE2M3(value: bits(8)) => NumericValueClass
begin
    let exponent = value[4:3];
    let fraction = value[2:0];
    return NumericValueClassFromFiniteSign(value[5],
        exponent == Zeros{2} && fraction == Zeros{3},
        exponent == Zeros{2} && fraction != Zeros{3});
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
        when TileDataType_FP64 => return ClassifyBinary64(value);
        when TileDataType_FP32 => return ClassifyBinary32(value[31:0], 23);
        when TileDataType_TF32 => return ClassifyBinary32(value[31:0], 10);
        when TileDataType_HF32 => return ClassifyBinary32(value[31:0], 11);
        when TileDataType_FP16 => return ClassifyBinary16(value[15:0]);
        when TileDataType_BF16 => return ClassifyBFloat16(value[15:0]);
        when TileDataType_HiF8 => return ClassifyHiF8(value[7:0]);
        when TileDataType_E4M3 => return ClassifyE4M3(value[7:0]);
        when TileDataType_E5M2 => return ClassifyE5M2(value[7:0]);
        when TileDataType_E3M2 => return ClassifyE3M2(value[7:0]);
        when TileDataType_E2M3 => return ClassifyE2M3(value[7:0]);
        when TileDataType_E2M1X2, TileDataType_E1M2X2,
             TileDataType_HiF4X2 =>
            return NumericValueClassFromFiniteSign(value[3],
                value[2:0] == Zeros{3}, FALSE);
        when TileDataType_E8M0 =>
            if value[7:0] == Ones{8} then return NumericValue_QuietNaN;
            else return NumericValue_PositiveNormal;
            end;
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
        when TileDataType_FP64 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x7ff8000000000000);
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x7fc00000);
        when TileDataType_FP16 => return (TRUE, Zeros{PTO_XLEN} + 0x7e00);
        when TileDataType_BF16 => return (TRUE, Zeros{PTO_XLEN} + 0x7fc0);
        when TileDataType_HiF8 => return (TRUE, Zeros{PTO_XLEN} + 0x80);
        when TileDataType_E4M3 => return (TRUE, Zeros{PTO_XLEN} + 0x7f);
        when TileDataType_E5M2 => return (TRUE, Zeros{PTO_XLEN} + 0x7e);
        when TileDataType_E8M0 => return (TRUE, Zeros{PTO_XLEN} + 0xff);
        otherwise => return (FALSE, Zeros{PTO_XLEN});
    end;
end;
