<!-- GENERATED FROM: asl/tile/model/numeric/formats.asl -->
# Formats

**Normative ASL source:** `asl/tile/model/numeric/formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-FORMATS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-FORMATS","surface":"tile","classification":["model","numeric","formats"],"depends_on":["PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","PTO-ARCH-FEATURES-MX-FORMATS","PTO-ARCH-STATE-NUMERIC-STATUS"]}
// PTO-REQ-TEPL-CONVERT-001: conversion, quantization, and dequantization.

pure func NormalizeTileInteger(value: Word, data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S4X2 => return SignExtend{PTO_XLEN}(value[3:0]);
        when TileDataType_U4X2 => return ZeroExtend{PTO_XLEN}(value[3:0]);
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

pure func TileIntegerMinimum(data_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(data_type);
    case data_type of
        when TileDataType_S4X2 =>
            return SignExtend{PTO_XLEN}('1000');
        when TileDataType_S8 =>
            return SignExtend{PTO_XLEN}('10000000');
        when TileDataType_S16 =>
            return SignExtend{PTO_XLEN}('1000000000000000');
        when TileDataType_S32 =>
            return Zeros{PTO_XLEN} + 0xffffffff80000000;
        when TileDataType_S64 =>
            return Zeros{PTO_XLEN} + 0x8000000000000000;
        otherwise => return Zeros{PTO_XLEN};
    end;
end;

pure func TileIntegerMaximum(data_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(data_type);
    case data_type of
        when TileDataType_S4X2 => return Zeros{PTO_XLEN} + 0x7;
        when TileDataType_U4X2 => return Zeros{PTO_XLEN} + 0xf;
        when TileDataType_S8 => return Zeros{PTO_XLEN} + 0x7f;
        when TileDataType_U8 => return Zeros{PTO_XLEN} + 0xff;
        when TileDataType_S16 => return Zeros{PTO_XLEN} + 0x7fff;
        when TileDataType_U16 => return Zeros{PTO_XLEN} + 0xffff;
        when TileDataType_S32 => return Zeros{PTO_XLEN} + 0x7fffffff;
        when TileDataType_U32 => return Zeros{PTO_XLEN} + 0xffffffff;
        when TileDataType_S64 =>
            return Zeros{PTO_XLEN} + 0x7fffffffffffffff;
        when TileDataType_U64 => return Ones{PTO_XLEN};
        otherwise => unreachable;
    end;
end;

pure func TileQuantizationScaleLegal(scale: Word) => boolean
begin
    if !TileNumericEncodingValid(TileDataType_FP32, scale) ||
       scale[31] == '1' then
        return FALSE;
    end;
    let value_class = TileNumericValueClass(TileDataType_FP32, scale);
    return !NumericValueClassIsNaN(value_class) &&
           !NumericValueClassIsInfinity(value_class) &&
           !NumericValueClassIsZero(value_class);
end;

pure func TileQuantizationZeroPointLegal(
    zero_point: Word,
    data_type: TileDataType) => boolean
begin
    if data_type != TileDataType_S8 && data_type != TileDataType_U8 then
        return FALSE;
    end;
    return NormalizeTileInteger(zero_point, data_type) == zero_point;
end;

pure func TileConvertIntegerSaturating(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(source_type);
    assert TileDataTypeIsInteger(destination_type);
    let source = NormalizeTileInteger(value, source_type);
    let minimum = TileIntegerMinimum(destination_type);
    let maximum = TileIntegerMaximum(destination_type);
    if TileDataTypeIsSigned(source_type) then
        if !TileDataTypeIsSigned(destination_type) && SInt(source) < 0 then
            return minimum;
        end;
        if TileDataTypeIsSigned(destination_type) then
            if SInt(source) < SInt(minimum) then return minimum; end;
            if SInt(source) > SInt(maximum) then return maximum; end;
        elsif UInt(source) > UInt(maximum) then
            return maximum;
        end;
    elsif UInt(source) > UInt(maximum) then
        return maximum;
    end;
    return NormalizeTileInteger(source, destination_type);
end;

pure func TileConvertIntegerValue(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType,
    saturating: boolean) => Word
begin
    if saturating then
        return TileConvertIntegerSaturating(
            value, source_type, destination_type);
    end;
    return NormalizeTileInteger(
        NormalizeTileInteger(value, source_type), destination_type);
end;

impdef func TileProfileConvert(value: Word, source_type: TileDataType,
                               destination_type: TileDataType,
                               control: NumericExecutionControl)
                               => (Word, bits(5))
begin
    // Profiles replace this raw-encoding rule for floating conversions.
    return (value, Zeros{5});
end;

func TileConvertValue(value: Word, source_type: TileDataType,
                      destination_type: TileDataType,
                      control: NumericExecutionControl)
                      => (Word, bits(5))
begin
    if TileDataTypeIsFloating(source_type) || TileDataTypeIsFloating(destination_type) then
        return TileProfileConvert(value, source_type, destination_type, control);
    else
        // Integer conversion first interprets the source width/signedness,
        // then truncates or extends into the destination representation.
        return (TileConvertIntegerValue(
            value, source_type, destination_type, control.saturating),
            Zeros{5});
    end;
end;

func TileCommitConversionResult(destination: TileIndex,
                                result: TileInfo,
                                flags: bits(5))
begin
    // All conversion and padding work is complete before this non-faulting
    // architectural publish boundary is entered.
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;

func TCVT(destination: TileIndex, source: TileIndex,
          control: NumericExecutionControl)
begin
    var result = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert result.valid_rows == source_tile.valid_rows;
    assert result.valid_columns == source_tile.valid_columns;
    if TileLayoutIsCube(source_tile.layout) then
        assert result.layout == source_tile.layout &&
               result.location == TileLocation_Matrix;
    else
        assert result.rows == source_tile.rows;
        assert result.columns == source_tile.columns;
    end;
    var conversion_flags = Zeros{5};
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    result.contents_defined = FALSE;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let (converted, flags) = TileConvertValue(
                TileReadLogicalElement(source_tile, source_element),
                source_tile.data_type,
                result.data_type, control);
            result = TileInfoWithLogicalElement(result, destination_element,
                converted);
            conversion_flags = conversion_flags OR flags;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    // CUBE_M16/M32 is a persistent Local matrix representation.  Ordinary
    // TCVT outputs remain public tiles, but a CUBE-to-CUBE conversion must
    // retain the representation so the destination can be consumed by the
    // matrix/CELL paths without an implicit layout conversion.
    if TileLayoutIsCube(result.layout) then
        result.location = TileLocation_Matrix;
    else
        result.location = TileLocation_Any;
    end;
    TileCommitConversionResult(destination, result, conversion_flags);
end;

impdef func TileProfileQuantize(value: Word, scale: Word, zero_point: Word,
                                source_type: TileDataType,
                                destination_type: TileDataType,
                                control: NumericExecutionControl)
                                => (Word, bits(5))
begin
    assert !IsZero(scale);
    return (
        NormalizeTileInteger(value + zero_point, destination_type),
        Zeros{5});
end;

impdef func TileProfileDequantize(value: Word, scale: Word, zero_point: Word,
                                  source_type: TileDataType,
                                  destination_type: TileDataType,
                                  control: NumericExecutionControl)
                                  => (Word, bits(5))
begin
    return (value - zero_point, Zeros{5});
end;

func TQUANT(destination: TileIndex, source: TileIndex, scale: Word,
            zero_point: Word, control: NumericExecutionControl)
begin
    var result = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert result.valid_rows == source_tile.valid_rows;
    assert result.valid_columns == source_tile.valid_columns;
    var conversion_flags = Zeros{5};
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    result.contents_defined = FALSE;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let (converted, flags) = TileProfileQuantize(
                TileReadLogicalElement(source_tile, source_element),
                scale,
                zero_point,
                source_tile.data_type,
                result.data_type,
                control);
            result = TileInfoWithLogicalElement(result, destination_element,
                converted);
            conversion_flags = conversion_flags OR flags;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    TileCommitConversionResult(destination, result, conversion_flags);
end;

func TDEQUANT(destination: TileIndex, source: TileIndex, scale: Word,
              zero_point: Word, control: NumericExecutionControl)
begin
    var result = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert result.valid_rows == source_tile.valid_rows;
    assert result.valid_columns == source_tile.valid_columns;
    var conversion_flags = Zeros{5};
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    result.contents_defined = FALSE;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let (converted, flags) = TileProfileDequantize(
                TileReadLogicalElement(source_tile, source_element),
                scale,
                zero_point,
                source_tile.data_type,
                result.data_type,
                control);
            result = TileInfoWithLogicalElement(result, destination_element,
                converted);
            conversion_flags = conversion_flags OR flags;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    TileCommitConversionResult(destination, result, conversion_flags);
end;
```
<!-- GENERATED-ASL-END: unit -->
