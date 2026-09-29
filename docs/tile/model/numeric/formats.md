<!-- GENERATED FROM: asl/tile/model/numeric/formats.asl -->
# Formats

**Normative ASL source:** `asl/tile/model/numeric/formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-formats-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the `TCVT` element-conversion body and the value-conversion dispatch it uses.

- `NormalizeTileInteger`, `TileIntegerMinimum`, and `TileIntegerMaximum` describe integer ranges.
- `TileConvertIntegerSaturating` and `TileConvertIntegerValue` convert between integer types.
- `TileProfileConvert` and `TileConvertValue` choose the conversion rule for a type pair.
- `TCVT` converts a whole Tile, and `TileCommitConversionResult` publishes it.

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-concepts role=concepts-state -->
## Concepts and visible state

`NumericExecutionControl` carries a rounding mode and a `saturating` flag. In TCVT they come from the bundle `RMode` and `Sat` fields.

`NormalizeTileInteger` keeps the low bits of the type width and sign-extends signed types (S4X2, S8, S16, S32) or zero-extends unsigned types. `TileIntegerMinimum` is 0 for unsigned types; `TileIntegerMaximum` is, for example, `0x7f` for S8 and `0xff` for U8.

The source operation type of TCVT is the BSTART DataType when the bundle supplies one, and otherwise the source Tile's own type. The destination type is the destination Tile's type.

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-rules role=rules-interactions -->
## Rules and interactions

`TileConvertValue` picks a rule:

- Integer to integer: `TileConvertIntegerValue`. Without saturation it truncates to the destination width. With saturation it clamps: a negative signed source becomes 0 in an unsigned destination, and out-of-range values become the destination minimum or maximum. No flags are produced.
- Any floating side: `TileProfileConvert`.

`TileProfileConvert` sends E2M1X2, E1M2X2, and E6M2 on either side, and RCPE6M2 as a source, to `ReferenceTCVTConvert`. A pair inside the common set (FP64, FP32, FP16, E4M3, and S/U 64, 32, 16, 8) goes to `ReferenceCommonConvert`. An E8M0 destination goes to `ReferenceFloatToE8M0`.

Any other pair falls back. An integer destination receives `NormalizeTileInteger` of the raw source bits, and a floating destination receives the raw source word, both with no flags. BF16 is not in the common set, so for example BF16 to FP32 takes this fallback in the current ASL.

`TCVT` asserts equal valid shapes, and for layouts other than CUBE, equal physical shapes. It clears destination definedness and converts each active valid element. When the source operation type is E8M0, E2M1X2, E1M2X2, E6M2, or RCPE6M2, or the destination is E2M1X2, E1M2X2, or E6M2, and `HardwareTCVTTypePairSupported` accepts the pair, the element goes directly to `ReferenceTCVTConvert`; otherwise it goes to `TileConvertValue`. Inactive elements receive the ExecutionMask zero or merge value. It then marks the valid region defined, applies the bundle `PadValue` to the rest, and calls `TileCommitConversionResult`.

Design point: the source is read from a snapshot taken before any destination write, so a source that aliases the destination still converts its original values.

Design point: flags from every converted element are ORed together and recorded once, in `TileCommitConversionResult`, immediately before the destination is published. The body has no fault path, and legality rejection happens before the body runs, so a rejected TCVT changes neither the destination nor the sticky status.

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-boundaries role=boundaries -->
## Architectural boundaries

Type-pair, rounding-mode, encoding, definedness, and layout legality are checked by `TileOperandsLegal_TCVT` and the block TCVT schema before this body runs. This body only asserts the shape rules, and it uses `HardwareTCVTTypePairSupported` only to choose a route.

The rounding and special-value rules for each format live in the reference, TCVT, packed, and E8M0 conversion units.

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-example role=example-usage -->
## Non-normative reading example

Convert S16 value -300 (`0xFED4`) with TCVT.

- To S8 without saturation: the low 8 bits are `0xD4`, which is -44.
- To S8 with saturation: -300 is below -128, so the result is the S8 minimum -128 (low byte `0x80`).
- To U8 with saturation: the source is negative, so the result is 0.
- To U16 without saturation: the result is `0xFED4` (65236).

None of these integer conversions sets a flag.

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-related role=related-owners-navigation -->
## Related owners

- [Reference conversion](reference-conversion.md) owns the common conversion rule.
- [TCVT conversion](tcvt-conversion.md) owns the closed scale and packed formats.
- [E8M0 conversion](e8m0-conversion.md) owns type-pair legality and float to E8M0.
- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flags.
- [TCVT](../../elementwise-tile-tile/format-conversion/TCVT.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-FORMATS","surface":"tile","classification":["model","numeric","formats"],"depends_on":["PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","PTO-ARCH-FEATURES-MX-FORMATS","PTO-ARCH-STATE-NUMERIC-STATUS"]}
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

func TileProfileConvert(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    // The E6M2/RCPE6M2 scale identities and the packed X2 formats have their
    // own closed reference policy; route them through the same dispatcher the
    // TCVT instruction uses instead of the generic raw-encoding fallback.
    if source_type == TileDataType_E2M1X2 ||
       source_type == TileDataType_E1M2X2 ||
       destination_type == TileDataType_E2M1X2 ||
       destination_type == TileDataType_E1M2X2 ||
       source_type == TileDataType_E6M2 ||
       destination_type == TileDataType_E6M2 ||
       source_type == TileDataType_RCPE6M2 then
        return ReferenceTCVTConvert(
            value, source_type, destination_type, control);
    end;
    if ReferenceCommonConversionTypeSupported(source_type) &&
       ReferenceCommonConversionTypeSupported(destination_type) then
        return ReferenceCommonConvert(
            value, source_type, destination_type, control);
    elsif destination_type == TileDataType_E8M0 then
        return ReferenceFloatToE8M0(value, source_type, control);
    elsif !TileDataTypeIsFloating(destination_type) then
        return (
            NormalizeTileInteger(value, destination_type),
            Zeros{5});
    end;
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
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    var result = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let source_operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else source_tile.data_type;
    assert result.valid_rows == source_tile.valid_rows;
    assert result.valid_columns == source_tile.valid_columns;
    if TileLayoutIsCube(source_tile.layout) then
        assert result.layout == source_tile.layout;
    else
        assert result.rows == source_tile.rows;
        assert result.columns == source_tile.columns;
    end;
    var conversion_flags = Zeros{5};
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    result.contents_defined = FALSE;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let source_element = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let source_value = TileReadLogicalElement(
                    source_tile, source_element);
                var converted: Word = source_value;
                var flags: bits(5) = Zeros{5};
                if (source_operation_type == TileDataType_E8M0 ||
                    source_operation_type == TileDataType_E2M1X2 ||
                    source_operation_type == TileDataType_E1M2X2 ||
                    result.data_type == TileDataType_E2M1X2 ||
                    result.data_type == TileDataType_E1M2X2 ||
                    source_operation_type == TileDataType_E6M2 ||
                    result.data_type == TileDataType_E6M2 ||
                    source_operation_type == TileDataType_RCPE6M2) &&
                   HardwareTCVTTypePairSupported(source_operation_type,
                       result.data_type) then
                    (converted, flags) = ReferenceTCVTConvert(source_value,
                        source_operation_type, result.data_type, control);
                else
                    (converted, flags) = TileConvertValue(source_value,
                        source_operation_type, result.data_type, control);
                end;
                result = TileInfoWithLogicalElement(
                    result, destination_element, converted);
                conversion_flags = conversion_flags OR flags;
            else
                result = TileInfoWithLogicalElement(
                    result, destination_element,
                    BundleExecutionMaskDestinationValue(
                        source_tile.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    TileCommitConversionResult(destination, result, conversion_flags);
end;
```
<!-- GENERATED-ASL-END: unit -->
