// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-INTEGRAL-BOUNDARIES-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001","PTO-NUMERIC-STATUS-STICKY-001"],"kind":"state-transition","summary":"TCVT integral rounding preserves exact, exceptional, boundary, and sticky status behavior","pass_condition":"All four formats preserve signed zeros, infinities, and exact integer/max-finite encodings; canonicalize NaNs with the common NV policy; round signed smallest subnormals with NX; retain large FP32/FP64 integers beyond integer tile ranges; and ignore Sat for finite rounding and common special values","related_sources":["asl/tile/model/numeric/tcvt-conversion.asl","asl/tile/model/numeric/reference-conversion.asl","asl/arch/state/numeric-status.asl"]}
pure func TCVTBoundaryType(type_index: integer {0..3}) => TileDataType
begin
    case type_index of
        when 0 => return TileDataType_FP16;
        when 1 => return TileDataType_BF16;
        when 2 => return TileDataType_FP32;
        when 3 => return TileDataType_FP64;
    end;
end;

pure func TCVTBoundaryRows(data_type: TileDataType)
    => integer {1..65535}
begin
    return DerivedTileRows(256, 16, data_type) as integer {1..65535};
end;

pure func TCVTBoundaryInput(data_type: TileDataType, sample: integer {0..13})
    => Word
begin
    if data_type == TileDataType_FP16 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x0000;
            when 1 => return Zeros{PTO_XLEN} + 0x8000;
            when 2 => return Zeros{PTO_XLEN} + 0x7c00;
            when 3 => return Zeros{PTO_XLEN} + 0xfc00;
            when 4 => return Zeros{PTO_XLEN} + 0x7e00;
            when 5 => return Zeros{PTO_XLEN} + 0x7c01;
            when 6 => return Zeros{PTO_XLEN} + 0x0001;
            when 7 => return Zeros{PTO_XLEN} + 0x8001;
            when 8 => return Zeros{PTO_XLEN} + 0x0001;
            when 9 => return Zeros{PTO_XLEN} + 0x8001;
            when 10 => return Zeros{PTO_XLEN} + 0x7bff;
            when 11 => return Zeros{PTO_XLEN} + 0x7bff;
            when 12 => return Zeros{PTO_XLEN} + 0x4166;
            when 13 => return Zeros{PTO_XLEN} + 0xbc00;
        end;
    elsif data_type == TileDataType_BF16 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x0000;
            when 1 => return Zeros{PTO_XLEN} + 0x8000;
            when 2 => return Zeros{PTO_XLEN} + 0x7f80;
            when 3 => return Zeros{PTO_XLEN} + 0xff80;
            when 4 => return Zeros{PTO_XLEN} + 0x7fc0;
            when 5 => return Zeros{PTO_XLEN} + 0x7f81;
            when 6 => return Zeros{PTO_XLEN} + 0x0001;
            when 7 => return Zeros{PTO_XLEN} + 0x8001;
            when 8 => return Zeros{PTO_XLEN} + 0x0001;
            when 9 => return Zeros{PTO_XLEN} + 0x8001;
            when 10 => return Zeros{PTO_XLEN} + 0x7f7f;
            when 11 => return Zeros{PTO_XLEN} + 0x7f7f;
            when 12 => return Zeros{PTO_XLEN} + 0x402d;
            when 13 => return Zeros{PTO_XLEN} + 0xbf80;
        end;
    elsif data_type == TileDataType_FP32 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x00000000;
            when 1 => return Zeros{PTO_XLEN} + 0x80000000;
            when 2 => return Zeros{PTO_XLEN} + 0x7f800000;
            when 3 => return Zeros{PTO_XLEN} + 0xff800000;
            when 4 => return Zeros{PTO_XLEN} + 0x7fc00000;
            when 5 => return Zeros{PTO_XLEN} + 0x7f800001;
            when 6 => return Zeros{PTO_XLEN} + 0x00000001;
            when 7 => return Zeros{PTO_XLEN} + 0x80000001;
            when 8 => return Zeros{PTO_XLEN} + 0x00000001;
            when 9 => return Zeros{PTO_XLEN} + 0x80000001;
            when 10 => return Zeros{PTO_XLEN} + 0x7f7fffff;
            when 11 => return Zeros{PTO_XLEN} + 0x53800000;
            when 12 => return Zeros{PTO_XLEN} + 0x402ccccd;
            when 13 => return Zeros{PTO_XLEN} + 0xbf800000;
        end;
    else
        assert data_type == TileDataType_FP64;
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x0000000000000000;
            when 1 => return Zeros{PTO_XLEN} + 0x8000000000000000;
            when 2 => return Zeros{PTO_XLEN} + 0x7ff0000000000000;
            when 3 => return Zeros{PTO_XLEN} + 0xfff0000000000000;
            when 4 => return Zeros{PTO_XLEN} + 0x7ff8000000000000;
            when 5 => return Zeros{PTO_XLEN} + 0x7ff0000000000001;
            when 6 => return Zeros{PTO_XLEN} + 0x0000000000000001;
            when 7 => return Zeros{PTO_XLEN} + 0x8000000000000001;
            when 8 => return Zeros{PTO_XLEN} + 0x0000000000000001;
            when 9 => return Zeros{PTO_XLEN} + 0x8000000000000001;
            when 10 => return Zeros{PTO_XLEN} + 0x7fefffffffffffff;
            when 11 => return Zeros{PTO_XLEN} + 0x43f0000000000000;
            when 12 => return Zeros{PTO_XLEN} + 0x400599999999999a;
            when 13 => return Zeros{PTO_XLEN} + 0xbff0000000000000;
        end;
    end;
end;

pure func TCVTBoundaryOutput(data_type: TileDataType, sample: integer {0..13})
    => Word
begin
    if data_type == TileDataType_FP16 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x0000;
            when 1 => return Zeros{PTO_XLEN} + 0x8000;
            when 2 => return Zeros{PTO_XLEN} + 0x7c00;
            when 3 => return Zeros{PTO_XLEN} + 0xfc00;
            when 4 => return Zeros{PTO_XLEN} + 0x7e00;
            when 5 => return Zeros{PTO_XLEN} + 0x7e00;
            when 6 => return Zeros{PTO_XLEN} + 0x0000;
            when 7 => return Zeros{PTO_XLEN} + 0x8000;
            when 8 => return Zeros{PTO_XLEN} + 0x3c00;
            when 9 => return Zeros{PTO_XLEN} + 0xbc00;
            when 10 => return Zeros{PTO_XLEN} + 0x7bff;
            when 11 => return Zeros{PTO_XLEN} + 0x7bff;
            when 12 => return Zeros{PTO_XLEN} + 0x4200;
            when 13 => return Zeros{PTO_XLEN} + 0xbc00;
        end;
    elsif data_type == TileDataType_BF16 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x0000;
            when 1 => return Zeros{PTO_XLEN} + 0x8000;
            when 2 => return Zeros{PTO_XLEN} + 0x7f80;
            when 3 => return Zeros{PTO_XLEN} + 0xff80;
            when 4 => return Zeros{PTO_XLEN} + 0x7fc0;
            when 5 => return Zeros{PTO_XLEN} + 0x7fc0;
            when 6 => return Zeros{PTO_XLEN} + 0x0000;
            when 7 => return Zeros{PTO_XLEN} + 0x8000;
            when 8 => return Zeros{PTO_XLEN} + 0x3f80;
            when 9 => return Zeros{PTO_XLEN} + 0xbf80;
            when 10 => return Zeros{PTO_XLEN} + 0x7f7f;
            when 11 => return Zeros{PTO_XLEN} + 0x7f7f;
            when 12 => return Zeros{PTO_XLEN} + 0x4040;
            when 13 => return Zeros{PTO_XLEN} + 0xbf80;
        end;
    elsif data_type == TileDataType_FP32 then
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x00000000;
            when 1 => return Zeros{PTO_XLEN} + 0x80000000;
            when 2 => return Zeros{PTO_XLEN} + 0x7f800000;
            when 3 => return Zeros{PTO_XLEN} + 0xff800000;
            when 4 => return Zeros{PTO_XLEN} + 0x7fc00000;
            when 5 => return Zeros{PTO_XLEN} + 0x7fc00000;
            when 6 => return Zeros{PTO_XLEN} + 0x00000000;
            when 7 => return Zeros{PTO_XLEN} + 0x80000000;
            when 8 => return Zeros{PTO_XLEN} + 0x3f800000;
            when 9 => return Zeros{PTO_XLEN} + 0xbf800000;
            when 10 => return Zeros{PTO_XLEN} + 0x7f7fffff;
            when 11 => return Zeros{PTO_XLEN} + 0x53800000;
            when 12 => return Zeros{PTO_XLEN} + 0x40400000;
            when 13 => return Zeros{PTO_XLEN} + 0xbf800000;
        end;
    else
        assert data_type == TileDataType_FP64;
        case sample of
            when 0 => return Zeros{PTO_XLEN} + 0x0000000000000000;
            when 1 => return Zeros{PTO_XLEN} + 0x8000000000000000;
            when 2 => return Zeros{PTO_XLEN} + 0x7ff0000000000000;
            when 3 => return Zeros{PTO_XLEN} + 0xfff0000000000000;
            when 4 => return Zeros{PTO_XLEN} + 0x7ff8000000000000;
            when 5 => return Zeros{PTO_XLEN} + 0x7ff8000000000000;
            when 6 => return Zeros{PTO_XLEN} + 0x0000000000000000;
            when 7 => return Zeros{PTO_XLEN} + 0x8000000000000000;
            when 8 => return Zeros{PTO_XLEN} + 0x3ff0000000000000;
            when 9 => return Zeros{PTO_XLEN} + 0xbff0000000000000;
            when 10 => return Zeros{PTO_XLEN} + 0x7fefffffffffffff;
            when 11 => return Zeros{PTO_XLEN} + 0x43f0000000000000;
            when 12 => return Zeros{PTO_XLEN} + 0x4008000000000000;
            when 13 => return Zeros{PTO_XLEN} + 0xbff0000000000000;
        end;
    end;
end;

func RunTCVTBoundaryCase(
    data_type: TileDataType,
    sample: integer {0..13},
    rounding_mode: NumericRoundingMode,
    rounding_code: bits(3),
    saturating: boolean,
    initial_flags: bits(5),
    expected_flags: bits(5))
begin
    ResetProfileState();
    let rows = TCVTBoundaryRows(data_type);
    ConfigureTile(0, 256, rows, 16, 1, 1, data_type,
        TileLayout_RowMajor);
    ConfigureTile(1, 256, rows, 16, 1, 1, data_type,
        TileLayout_RowMajor);
    let input = TCVTBoundaryInput(data_type, sample);
    WriteTileElement(0, 0, 0, input);
    RecordNumericStatusFlags(initial_flags);
    SetBundleDataAttributeState(
        TileDataTypeToEncoding(data_type), Zeros{5}, '00', Zeros{3},
        rounding_code, saturating, FALSE);
    _BundleDataAttributesPresent = TRUE;
    let control = NumericExecutionControl {
        rounding_mode = rounding_mode,
        saturating = saturating
    };
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);
    assert _LastFault == Fault_None;
    assert ReadTileElement(1, 0, 0) == TCVTBoundaryOutput(data_type, sample);
    assert NumericStatusFlags() == expected_flags;
end;

func CheckTCVTBoundaryType(data_type: TileDataType)
begin
    RunTCVTBoundaryCase(data_type, 0, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 1, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 2, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 3, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 4, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 5, NumericRound_RNE, '001', FALSE,
        '00000', Zeros{5} + 0x01);
    RunTCVTBoundaryCase(data_type, 6, NumericRound_RNE, '001', FALSE,
        '00000', Zeros{5} + 0x10);
    RunTCVTBoundaryCase(data_type, 7, NumericRound_RNE, '001', FALSE,
        '00000', Zeros{5} + 0x10);
    RunTCVTBoundaryCase(data_type, 8, NumericRound_RTP, '100', FALSE,
        '00000', Zeros{5} + 0x10);
    RunTCVTBoundaryCase(data_type, 9, NumericRound_RTM, '011', FALSE,
        '00000', Zeros{5} + 0x10);
    RunTCVTBoundaryCase(data_type, 10, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 12, NumericRound_RNE, '001', FALSE,
        '00000', Zeros{5} + 0x10);
    RunTCVTBoundaryCase(data_type, 12, NumericRound_RNE, '001', TRUE,
        '00000', Zeros{5} + 0x10);
    // Each sticky flag survives alongside a newly produced NX.
    RunTCVTBoundaryCase(data_type, 12, NumericRound_RNE, '001', FALSE,
        Zeros{5} + 0x01, Zeros{5} + 0x11);
    RunTCVTBoundaryCase(data_type, 12, NumericRound_RNE, '001', FALSE,
        Zeros{5} + 0x02, Zeros{5} + 0x12);
    RunTCVTBoundaryCase(data_type, 12, NumericRound_RNE, '001', FALSE,
        Zeros{5} + 0x04, Zeros{5} + 0x14);
    RunTCVTBoundaryCase(data_type, 12, NumericRound_RNE, '001', FALSE,
        Zeros{5} + 0x08, Zeros{5} + 0x18);
    RunTCVTBoundaryCase(data_type, 13, NumericRound_RNE, '001', FALSE,
        '00000', '00000');
    // Sat is unchanged for common infinities and NaN handling as well.
    RunTCVTBoundaryCase(data_type, 2, NumericRound_RNE, '001', TRUE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 3, NumericRound_RNE, '001', TRUE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 4, NumericRound_RNE, '001', TRUE,
        '00000', '00000');
    RunTCVTBoundaryCase(data_type, 5, NumericRound_RNE, '001', TRUE,
        '00000', Zeros{5} + 0x01);
    if data_type == TileDataType_FP32 || data_type == TileDataType_FP64 then
        RunTCVTBoundaryCase(data_type, 11, NumericRound_RNE, '001', FALSE,
            '00000', '00000');
    end;
end;

func main() => integer
begin
    for type_index = 0 to 3 do
        CheckTCVTBoundaryType(TCVTBoundaryType(type_index));
    end;
    return 0;
end;
