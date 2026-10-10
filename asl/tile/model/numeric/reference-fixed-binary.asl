// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY","surface":"tile","classification":["model","numeric","reference-fixed-binary"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-NUMERIC-FORMATS"]}

pure func ReferenceCommonFloatingEndpoint(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xffefffffffffffff
                 else 0x7fefffffffffffff);
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fffff else 0x7f7fffff);
        when TileDataType_TF32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fe000 else 0x7f7fe000);
        when TileDataType_HF32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7ff000 else 0x7f7ff000);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfbff else 0x7bff);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7f else 0x7f7f);
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfe else 0x7e);
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfb else 0x7b);
        otherwise => unreachable;
    end;
end;

func ReferenceCommonReducedFloatingEncoding(
    value: real,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_TF32 ||
           destination_type == TileDataType_HF32 ||
           destination_type == TileDataType_E5M2;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-137..128} = 0;
    for step = 1 to 128 looplimit 128 do
        if normalized >= 2.0 && exponent < 128 then
            normalized = normalized / 2.0;
            exponent = (exponent + 1) as integer {-137..128};
        end;
    end;
    for step = 1 to 137 looplimit 137 do
        if normalized < 1.0 && exponent > -137 then
            normalized = normalized * 2.0;
            exponent = (exponent - 1) as integer {-137..128};
        end;
    end;
    let tf32 = destination_type == TileDataType_TF32;
    let hf32 = destination_type == TileDataType_HF32;
    let fraction_scale = if tf32 then 0x400
        else if hf32 then 0x800 else 4;
    let bias = if destination_type == TileDataType_E5M2 then 15 else 127;
    let maximum_exponent = if destination_type == TileDataType_E5M2
        then 15 else 127;
    let minimum_exponent = if destination_type == TileDataType_E5M2
        then -14 else -126;
    let minimum_subnormal_exponent = if tf32 then -136
        else if hf32 then -137 else -16;
    let low_zero_bits = if tf32 then 13 else if hf32 then 12 else 0;
    let sign = if negative then
        (if destination_type == TileDataType_E5M2
            then 0x80 else 0x80000000)
        else 0;
    let infinity = if destination_type == TileDataType_E5M2
        then 0x7c else 0x7f800000;
    if exponent > maximum_exponent then
        return (
            if control.saturating then
                ReferenceCommonFloatingEndpoint(destination_type, negative)
            else Zeros{PTO_XLEN} + sign + infinity,
            Zeros{5} + 0x14);
    end;
    if exponent < minimum_exponent then
        let scaled = normalized * ReferencePowerOfTwo(
            (exponent - minimum_subnormal_exponent)
                as integer {-1074..1023});
        var rounded = MatrixRoundMagnitude(
            scaled, control.rounding_mode, negative);
        if rounded < 0 then rounded = 0; end;
        let encoded = Zeros{PTO_XLEN} + sign + LSL(
            Zeros{PTO_XLEN} + rounded, low_zero_bits);
        let inexact = Real(rounded) != scaled;
        return (
            encoded,
            if !inexact then Zeros{5}
            else if rounded >= fraction_scale then Zeros{5} + 0x10
            else Zeros{5} + 0x18);
    end;
    let scaled = normalized * Real(fraction_scale);
    var rounded = MatrixRoundMagnitude(
        scaled, control.rounding_mode, negative);
    var encoded_exponent = exponent + bias;
    if rounded == 2 * fraction_scale then
        rounded = fraction_scale;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-122..255};
    end;
    if encoded_exponent >= 2 * bias + 1 then
        return (
            if control.saturating then
                ReferenceCommonFloatingEndpoint(destination_type, negative)
            else Zeros{PTO_XLEN} + sign + infinity,
            Zeros{5} + 0x14);
    end;
    let fraction = rounded - fraction_scale;
    let code = encoded_exponent * fraction_scale + fraction;
    return (
        Zeros{PTO_XLEN} + sign +
            LSL(Zeros{PTO_XLEN} + code, low_zero_bits),
        if Real(rounded) == scaled then Zeros{5}
        else Zeros{5} + 0x10);
end;
