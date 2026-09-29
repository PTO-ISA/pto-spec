<!-- GENERATED FROM: asl/tile/model/numeric/formats.asl -->
# Formats

**Normative ASL source:** `asl/tile/model/numeric/formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-formats-purpose role=purpose-scope -->
## 作用与范围

本单元拥有 `TCVT` 的元素转换执行体及其使用的值转换分派。

- `NormalizeTileInteger`、`TileIntegerMinimum` 与 `TileIntegerMaximum` 描述整数范围。
- `TileConvertIntegerSaturating` 与 `TileConvertIntegerValue` 在整数类型之间转换。
- `TileProfileConvert` 与 `TileConvertValue` 为类型对选择转换规则。
- `TCVT` 转换整个 Tile，`TileCommitConversionResult` 发布结果。

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-concepts role=concepts-state -->
## 概念与可见状态

`NumericExecutionControl` 携带一个舍入模式和一个 `saturating` 标志。在 TCVT 中，它们来自指令束的 `RMode` 与 `Sat` 字段。

`NormalizeTileInteger` 保留类型宽度内的低位，对有符号类型（S4X2、S8、S16、S32）做符号扩展，对无符号类型做零扩展。无符号类型的 `TileIntegerMinimum` 为 0；`TileIntegerMaximum` 例如对 S8 为 `0x7f`，对 U8 为 `0xff`。

TCVT 的源操作类型在指令束提供 BSTART DataType 时取该类型，否则取源 Tile 自身的类型。目标类型为目标 Tile 的类型。

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-rules role=rules-interactions -->
## 规则与交互

`TileConvertValue` 选择一条规则：

- 整数到整数：`TileConvertIntegerValue`。不饱和时截断到目标宽度。饱和时进行钳位：有符号负源在无符号目标中变为 0，越界值变为目标最小值或最大值。不产生标志。
- 任一侧为浮点：`TileProfileConvert`。

`TileProfileConvert` 把任一侧为 E2M1X2、E1M2X2 与 E6M2，以及源为 RCPE6M2 的情况交给 `ReferenceTCVTConvert`。公共集合（FP64、FP32、FP16、E4M3 以及 S/U 64、32、16、8）内的类型对交给 `ReferenceCommonConvert`。E8M0 目标交给 `ReferenceFloatToE8M0`。

其他任何类型对都走回退路径。整数目标接收原始源位的 `NormalizeTileInteger`，浮点目标接收原始源字，两者都不带标志。BF16 不在公共集合中，因此例如 BF16 到 FP32 在当前 ASL 中走这条回退路径。

`TCVT` 断言有效形状相等，并对非 CUBE 布局断言物理形状相等。它清除目标已定义性，并转换每个活动的有效元素。当源操作类型为 E8M0、E2M1X2、E1M2X2、E6M2 或 RCPE6M2，或目标为 E2M1X2、E1M2X2 或 E6M2，且 `HardwareTCVTTypePairSupported` 接受该类型对时，元素直接交给 `ReferenceTCVTConvert`；否则交给 `TileConvertValue`。非活动元素接收 ExecutionMask 的零值或合并值。随后它把有效区域标记为已定义，对其余部分应用指令束 `PadValue`，并调用 `TileCommitConversionResult`。

设计要点：源从任何目标写入之前拍下的快照中读取，因此与目标别名的源仍按其原始值转换。

设计要点：每个已转换元素的标志按位或在一起，并在 `TileCommitConversionResult` 中、紧接目标发布之前记录一次。执行体没有故障路径，合法性拒绝发生在执行体运行之前，因此被拒绝的 TCVT 既不改变目标，也不改变粘滞状态。

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-boundaries role=boundaries -->
## 架构边界

类型对、舍入模式、编码、已定义性与布局合法性在本执行体运行之前由 `TileOperandsLegal_TCVT` 与块 TCVT schema 检查。本执行体只断言形状规则，并且只把 `HardwareTCVTTypePairSupported` 用于路由选择。

各格式的舍入与特殊值规则位于 reference、TCVT、packed 与 E8M0 conversion 单元。

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-example role=example-usage -->
## 非规范阅读示例

用 TCVT 转换 S16 值 -300（`0xFED4`）。

- 不饱和转换到 S8：低 8 位为 `0xD4`，即 -44。
- 饱和转换到 S8：-300 小于 -128，因此结果为 S8 最小值 -128（低字节 `0x80`）。
- 饱和转换到 U8：源为负，因此结果为 0。
- 不饱和转换到 U16：结果为 `0xFED4`（65236）。

这些整数转换都不设置标志。

<!-- PTO-READER-BLOCK: tile-model-numeric-formats-related role=related-owners-navigation -->
## 相关归属

- [Reference conversion](reference-conversion.md) 拥有公共转换规则。
- [TCVT conversion](tcvt-conversion.md) 拥有封闭的缩放格式与打包格式。
- [E8M0 conversion](e8m0-conversion.md) 拥有类型对合法性以及浮点到 E8M0 的转换。
- [Numeric status](../../../arch/state/numeric-status.md) 拥有粘滞标志。
- [TCVT](../../elementwise-tile-tile/format-conversion/TCVT.md) 是指令页面。
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
