// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-MATRIX-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-COMMON-CONVERSION-001"],"kind":"execution","summary":"TCVT same-type integral rounding matches independent raw-bit goldens across four formats and six modes","pass_condition":"FP16, BF16, FP32, and FP64 each round independently encoded signed decimal samples under RNE, RTZ, RTM, RTP, RNA, and RHB with exact output encodings and NX","related_sources":["asl/tile/model/numeric/formats.asl","asl/tile/model/numeric/tcvt-conversion.asl","asl/tile/model/numeric/reference-conversion.asl"]}
pure func TCVTIntegralMatrixType(type_index: integer {0..3}) => TileDataType
begin
    case type_index of
        when 0 => return TileDataType_FP16;
        when 1 => return TileDataType_BF16;
        when 2 => return TileDataType_FP32;
        when 3 => return TileDataType_FP64;
    end;
end;

pure func TCVTIntegralMatrixMode(mode_index: integer {0..5})
    => NumericRoundingMode
begin
    case mode_index of
        when 0 => return NumericRound_RNE;
        when 1 => return NumericRound_RTZ;
        when 2 => return NumericRound_RTM;
        when 3 => return NumericRound_RTP;
        when 4 => return NumericRound_RNA;
        when 5 => return NumericRound_RHB;
    end;
end;

pure func TCVTIntegralMatrixModeCode(mode_index: integer {0..5})
    => bits(3)
begin
    case mode_index of
        when 0 => return '001';
        when 1 => return '010';
        when 2 => return '011';
        when 3 => return '100';
        when 4 => return '101';
        when 5 => return '111';
    end;
end;

pure func TCVTIntegralMatrixRows(data_type: TileDataType)
    => integer {1..65535}
begin
    return DerivedTileRows(256, 16, data_type) as integer {1..65535};
end;

pure func TCVTIntegralMatrixSource(
    data_type: TileDataType, sample: integer {0..11}) => Word
begin
    if data_type == TileDataType_FP16 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0xc300;
            when 1 => return Zeros{PTO_XLEN} + 0xc166;
            when 2 => return Zeros{PTO_XLEN} + 0xc100;
            when 3 => return Zeros{PTO_XLEN} + 0xc09a;
            when 4 => return Zeros{PTO_XLEN} + 0xbe00;
            when 5 => return Zeros{PTO_XLEN} + 0xb800;
            when 6 => return Zeros{PTO_XLEN} + 0x3800;
            when 7 => return Zeros{PTO_XLEN} + 0x3e00;
            when 8 => return Zeros{PTO_XLEN} + 0x409a;
            when 9 => return Zeros{PTO_XLEN} + 0x4100;
            when 10 => return Zeros{PTO_XLEN} + 0x4166;
            when 11 => return Zeros{PTO_XLEN} + 0x4300;
        end;
    elsif data_type == TileDataType_BF16 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0xc060;
            when 1 => return Zeros{PTO_XLEN} + 0xc02d;
            when 2 => return Zeros{PTO_XLEN} + 0xc020;
            when 3 => return Zeros{PTO_XLEN} + 0xc013;
            when 4 => return Zeros{PTO_XLEN} + 0xbfc0;
            when 5 => return Zeros{PTO_XLEN} + 0xbf00;
            when 6 => return Zeros{PTO_XLEN} + 0x3f00;
            when 7 => return Zeros{PTO_XLEN} + 0x3fc0;
            when 8 => return Zeros{PTO_XLEN} + 0x4013;
            when 9 => return Zeros{PTO_XLEN} + 0x4020;
            when 10 => return Zeros{PTO_XLEN} + 0x402d;
            when 11 => return Zeros{PTO_XLEN} + 0x4060;
        end;
    elsif data_type == TileDataType_FP32 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0xc0600000;
            when 1 => return Zeros{PTO_XLEN} + 0xc02ccccd;
            when 2 => return Zeros{PTO_XLEN} + 0xc0200000;
            when 3 => return Zeros{PTO_XLEN} + 0xc0133333;
            when 4 => return Zeros{PTO_XLEN} + 0xbfc00000;
            when 5 => return Zeros{PTO_XLEN} + 0xbf000000;
            when 6 => return Zeros{PTO_XLEN} + 0x3f000000;
            when 7 => return Zeros{PTO_XLEN} + 0x3fc00000;
            when 8 => return Zeros{PTO_XLEN} + 0x40133333;
            when 9 => return Zeros{PTO_XLEN} + 0x40200000;
            when 10 => return Zeros{PTO_XLEN} + 0x402ccccd;
            when 11 => return Zeros{PTO_XLEN} + 0x40600000;
        end;
    else
        assert data_type == TileDataType_FP64;
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0xc00c000000000000;
            when 1 => return Zeros{PTO_XLEN} + 0xc00599999999999a;
            when 2 => return Zeros{PTO_XLEN} + 0xc004000000000000;
            when 3 => return Zeros{PTO_XLEN} + 0xc002666666666666;
            when 4 => return Zeros{PTO_XLEN} + 0xbff8000000000000;
            when 5 => return Zeros{PTO_XLEN} + 0xbfe0000000000000;
            when 6 => return Zeros{PTO_XLEN} + 0x3fe0000000000000;
            when 7 => return Zeros{PTO_XLEN} + 0x3ff8000000000000;
            when 8 => return Zeros{PTO_XLEN} + 0x4002666666666666;
            when 9 => return Zeros{PTO_XLEN} + 0x4004000000000000;
            when 10 => return Zeros{PTO_XLEN} + 0x400599999999999a;
            when 11 => return Zeros{PTO_XLEN} + 0x400c000000000000;
        end;
    end;
end;

pure func TCVTIntegralMatrixInteger(
    mode_index: integer {0..5}, sample: integer {0..11})
    => integer {-4..4}
begin
    if mode_index == 0 then
        case sample of
            when 0 => return -4; when 1 => return -3;
            when 2 => return -2; when 3 => return -2;
            when 4 => return -2; when 5 => return 0;
            when 6 => return 0; when 7 => return 2;
            when 8 => return 2; when 9 => return 2;
            when 10 => return 3; when 11 => return 4;
        end;
    elsif mode_index == 1 then
        case sample of
            when 0 => return -3; when 1 => return -2;
            when 2 => return -2; when 3 => return -2;
            when 4 => return -1; when 5 => return 0;
            when 6 => return 0; when 7 => return 1;
            when 8 => return 2; when 9 => return 2;
            when 10 => return 2; when 11 => return 3;
        end;
    elsif mode_index == 2 then
        case sample of
            when 0 => return -4; when 1 => return -3;
            when 2 => return -3; when 3 => return -3;
            when 4 => return -2; when 5 => return -1;
            when 6 => return 0; when 7 => return 1;
            when 8 => return 2; when 9 => return 2;
            when 10 => return 2; when 11 => return 3;
        end;
    elsif mode_index == 3 then
        case sample of
            when 0 => return -3; when 1 => return -2;
            when 2 => return -2; when 3 => return -2;
            when 4 => return -1; when 5 => return 0;
            when 6 => return 1; when 7 => return 2;
            when 8 => return 3; when 9 => return 3;
            when 10 => return 3; when 11 => return 4;
        end;
    elsif mode_index == 4 then
        case sample of
            when 0 => return -4; when 1 => return -3;
            when 2 => return -3; when 3 => return -2;
            when 4 => return -2; when 5 => return -1;
            when 6 => return 1; when 7 => return 2;
            when 8 => return 2; when 9 => return 3;
            when 10 => return 3; when 11 => return 4;
        end;
    else
        assert mode_index == 5;
        case sample of
            when 0 => return -3; when 1 => return -3;
            when 2 => return -2; when 3 => return -2;
            when 4 => return -1; when 5 => return 0;
            when 6 => return 1; when 7 => return 2;
            when 8 => return 2; when 9 => return 3;
            when 10 => return 3; when 11 => return 4;
        end;
    end;
end;

pure func TCVTIntegralMatrixEncode(
    data_type: TileDataType, value: integer {-4..4}, negative_zero: boolean)
    => Word
begin
    if data_type == TileDataType_FP16 then
        if value == 0 then
            if negative_zero then return Zeros{PTO_XLEN} + 0x8000;
            else return Zeros{PTO_XLEN}; end;
        elsif value == -1 then return Zeros{PTO_XLEN} + 0xbc00;
        elsif value == 1 then return Zeros{PTO_XLEN} + 0x3c00;
        elsif value == -2 then return Zeros{PTO_XLEN} + 0xc000;
        elsif value == 2 then return Zeros{PTO_XLEN} + 0x4000;
        elsif value == -3 then return Zeros{PTO_XLEN} + 0xc200;
        elsif value == 3 then return Zeros{PTO_XLEN} + 0x4200;
        elsif value == -4 then return Zeros{PTO_XLEN} + 0xc400;
        else return Zeros{PTO_XLEN} + 0x4400;
        end;
    elsif data_type == TileDataType_BF16 then
        if value == 0 then
            if negative_zero then return Zeros{PTO_XLEN} + 0x8000;
            else return Zeros{PTO_XLEN}; end;
        elsif value == -1 then return Zeros{PTO_XLEN} + 0xbf80;
        elsif value == 1 then return Zeros{PTO_XLEN} + 0x3f80;
        elsif value == -2 then return Zeros{PTO_XLEN} + 0xc000;
        elsif value == 2 then return Zeros{PTO_XLEN} + 0x4000;
        elsif value == -3 then return Zeros{PTO_XLEN} + 0xc040;
        elsif value == 3 then return Zeros{PTO_XLEN} + 0x4040;
        elsif value == -4 then return Zeros{PTO_XLEN} + 0xc080;
        else return Zeros{PTO_XLEN} + 0x4080;
        end;
    elsif data_type == TileDataType_FP32 then
        if value == 0 then
            if negative_zero then return Zeros{PTO_XLEN} + 0x80000000;
            else return Zeros{PTO_XLEN}; end;
        elsif value == -1 then return Zeros{PTO_XLEN} + 0xbf800000;
        elsif value == 1 then return Zeros{PTO_XLEN} + 0x3f800000;
        elsif value == -2 then return Zeros{PTO_XLEN} + 0xc0000000;
        elsif value == 2 then return Zeros{PTO_XLEN} + 0x40000000;
        elsif value == -3 then return Zeros{PTO_XLEN} + 0xc0400000;
        elsif value == 3 then return Zeros{PTO_XLEN} + 0x40400000;
        elsif value == -4 then return Zeros{PTO_XLEN} + 0xc0800000;
        else return Zeros{PTO_XLEN} + 0x40800000;
        end;
    else
        assert data_type == TileDataType_FP64;
        if value == 0 then
            if negative_zero then return Zeros{PTO_XLEN} + 0x8000000000000000;
            else return Zeros{PTO_XLEN}; end;
        elsif value == -1 then return Zeros{PTO_XLEN} + 0xbff0000000000000;
        elsif value == 1 then return Zeros{PTO_XLEN} + 0x3ff0000000000000;
        elsif value == -2 then return Zeros{PTO_XLEN} + 0xc000000000000000;
        elsif value == 2 then return Zeros{PTO_XLEN} + 0x4000000000000000;
        elsif value == -3 then return Zeros{PTO_XLEN} + 0xc008000000000000;
        elsif value == 3 then return Zeros{PTO_XLEN} + 0x4008000000000000;
        elsif value == -4 then return Zeros{PTO_XLEN} + 0xc010000000000000;
        else return Zeros{PTO_XLEN} + 0x4010000000000000;
        end;
    end;
end;

func CheckTCVTIntegralMatrixPair(
    type_index: integer {0..3}, mode_index: integer {0..5})
begin
    ResetProfileState();
    let data_type = TCVTIntegralMatrixType(type_index);
    ConfigureTile(0, 256, TCVTIntegralMatrixRows(data_type), 16, 1, 12, data_type,
        TileLayout_RowMajor);
    ConfigureTile(1, 256, TCVTIntegralMatrixRows(data_type), 16, 1, 12, data_type,
        TileLayout_RowMajor);
    for sample = 0 to 11 do
        WriteTileElement(0, 0, sample,
            TCVTIntegralMatrixSource(data_type, sample));
    end;
    SetBundleDataAttributeState(
        TileDataTypeToEncoding(data_type), Zeros{5}, '00',
        Zeros{3}, TCVTIntegralMatrixModeCode(mode_index), FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    let control = NumericExecutionControl {
        rounding_mode = TCVTIntegralMatrixMode(mode_index),
        saturating = FALSE
    };
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);
    assert _LastFault == Fault_None;
    for sample = 0 to 11 do
        let integer_result = TCVTIntegralMatrixInteger(mode_index, sample);
        let negative_zero = sample <= 5 && integer_result == 0;
        assert ReadTileElement(1, 0, sample) == TCVTIntegralMatrixEncode(
            data_type, integer_result, negative_zero);
    end;
    assert NumericStatusFlags() == '10000';
end;

func main() => integer
begin
    for type_index = 0 to 3 do
        for mode_index = 0 to 5 do
            CheckTCVTIntegralMatrixPair(type_index, mode_index);
        end;
    end;
    return 0;
end;
