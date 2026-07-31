// PTO-REQ-TEPL-CONVERT-001: conversion, quantization, and dequantization.

pure func NormalizeTileInteger(value: Word, data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S8 => return SignExtend{PTO_XLEN}(value[7:0]);
        when TileDataType_U8 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when TileDataType_S16 => return SignExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_U16 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_S32 => return SignExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_U32 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_S64, TileDataType_U64 => return value;
        otherwise => return value;
    end;
end;

impdef func TileProfileConvert(value: Word, source_type: TileDataType,
                               destination_type: TileDataType,
                               control: NumericExecutionControl) => Word
begin
    // Profiles replace this raw-encoding rule for floating conversions.
    return value;
end;

func TileConvertValue(value: Word, source_type: TileDataType,
                      destination_type: TileDataType,
                      control: NumericExecutionControl) => Word
begin
    if TileDataTypeIsFloating(source_type) || TileDataTypeIsFloating(destination_type) then
        return TileProfileConvert(value, source_type, destination_type, control);
    else
        // Integer conversion first interprets the source width/signedness,
        // then truncates or extends into the destination representation.
        return NormalizeTileInteger(
            NormalizeTileInteger(value, source_type), destination_type);
    end;
end;

func TCVT(destination: TileIndex, source: TileIndex,
          control: NumericExecutionControl)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.valid_rows == source_tile.valid_rows;
    assert destination_tile.valid_columns == source_tile.valid_columns;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[destination_element]] = TileConvertValue(
                source_payload[[source_element]], source_tile.data_type,
                destination_tile.data_type, control);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

impdef func TileProfileQuantize(value: Word, scale: Word, zero_point: Word,
                                source_type: TileDataType,
                                destination_type: TileDataType,
                                control: NumericExecutionControl) => Word
begin
    assert !IsZero(scale);
    return NormalizeTileInteger(DivideWordUnsigned(value, scale) + zero_point,
        destination_type);
end;

impdef func TileProfileDequantize(value: Word, scale: Word, zero_point: Word,
                                  source_type: TileDataType,
                                  destination_type: TileDataType,
                                  control: NumericExecutionControl) => Word
begin
    return MultiplyWord(value - zero_point, scale);
end;

func TQUANT(destination: TileIndex, source: TileIndex, scale: Word,
            zero_point: Word, control: NumericExecutionControl)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.valid_rows == source_tile.valid_rows;
    assert destination_tile.valid_columns == source_tile.valid_columns;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] = TileProfileQuantize(
                source_payload[[element]], scale, zero_point,
                source_tile.data_type, destination_tile.data_type, control);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TDEQUANT(destination: TileIndex, source: TileIndex, scale: Word,
              zero_point: Word, control: NumericExecutionControl)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.valid_rows == source_tile.valid_rows;
    assert destination_tile.valid_columns == source_tile.valid_columns;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] = TileProfileDequantize(
                source_payload[[element]], scale, zero_point,
                source_tile.data_type, destination_tile.data_type, control);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;
