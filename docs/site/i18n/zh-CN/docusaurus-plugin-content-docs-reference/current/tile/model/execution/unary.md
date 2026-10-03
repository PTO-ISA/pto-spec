<!-- GENERATED FROM: asl/tile/model/execution/unary.asl -->
# Unary

**Normative ASL source:** `asl/tile/model/execution/unary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-UNARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-unary-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 `ExecuteTileUnary`，这是九个单源逐元素 Tile 操作共享的处理函数。封闭组为 TABS、TNOT、TNEG 和 TRELU。SFU 组为 TEXP、TLOG、TRECIP、TSQRT 和 TRSQRT。

它还拥有逐元素辅助函数：封闭组使用的 `TileFixedUnaryValue`、SFU 特殊输入使用的 `TileSFUUnarySpecialValue`，以及 `TileProfileUnary`。EXPDIF 单元在其 EXP 步骤中复用这些 SFU 辅助函数。

<!-- PTO-READER-BLOCK: tile-model-execution-unary-concepts role=concepts-state -->
## 概念与可见状态

操作类型是目标 Tile 的 `data_type`。源必须已分配、与目标形状匹配，并具有兼容的载体宽度。

各操作的类型集合不同。TNOT 接受八种有符号与无符号整数类型。TABS 使用 16 类型向量算术集合。TNEG 接受 `FP64`、`S64`、`U64`、`S32`、`S16`、`S8`、`FP32`、`FP16` 与 `BF16`。TRELU 接受 `FP64`、`S64`、`U64`、`FP16`、`BF16`、`FP32` 与 `S32`。SFU 组中，TEXP 保留八种浮点类型 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3` 与 `E5M2`；TLOG、TRECIP、TSQRT 与 TRSQRT 恰好接受 `FP64`、`FP32`、`FP16` 与 `BF16`。

状态标志从 bit 0 到 bit 4 依次为 NV、DZ、OF、UF 和 NX。SFU 元素返回全部五个标志；封闭组元素只返回一个无效位，记录为 NV。处理函数把活动元素的标志按位或起来，并用 `ScalarFPRecordFlags` 记录一次。

<!-- PTO-READER-BLOCK: tile-model-execution-unary-rules role=rules-interactions -->
## 规则与交互

整数封闭操作回绕到元素宽度。对有符号类型，最小负值的 TABS 返回相同的位模式，TRELU 对负值返回零。TNOT 翻转元素的每一位。

浮点 TABS 清除符号位，TNEG 翻转符号位，即使输入是 NaN 也如此，且不产生标志。浮点 TRELU 对负值和 +0 返回零，保留正值，并把 NaN 变为规范静默 NaN；输入为信号 NaN 时设置 NV。

SFU 元素首先经过 `TileSFUUnarySpecialValue`：

- NaN 输入返回规范静默 NaN；信号 NaN 设置 NV。
- TEXP 把零映射为 1.0，把 +inf 映射为 +inf，把 -inf 映射为 +0。
- TLOG 把 1.0 映射为 +0，把零映射为 -inf 并设置 DZ，把 +inf 映射为 +inf，把负值映射为 NaN 并设置 NV。
- TRECIP 把零映射为同号无穷并设置 DZ，把无穷映射为同号零。
- TSQRT 保留零和 +inf，把负值映射为 NaN 并设置 NV。
- TRSQRT 把零映射为同号无穷并设置 DZ，把 +inf 映射为 +0，把负值映射为 NaN 并设置 NV。

E4M3 没有无穷编码，因此无界结果变为其规范 NaN。其他输入交给 `ReferenceTileUnaryFinite`，它按 RNE 舍入。

设计要点：源在任何写入之前被快照。循环读取源 `TileInfo` 的副本并私下构建结果，因此目标即使命名该源，读取的仍是旧值。

设计要点：特殊输入在有限值配置档之前就被决定。因此 NaN、零和无穷输入的结果，以及 TLOG、TSQRT 和 TRSQRT 的负值输入结果，由本单元固定，而不是由有限值参考实现决定。

<!-- PTO-READER-BLOCK: tile-model-execution-unary-boundaries role=boundaries -->
## 架构边界

ExecutionMask 下的非活动坐标取 ZERO 或 MERGE 值，且不贡献标志。发布之后，处理函数把有效区域标记为已定义，并应用指令束填充。

`ReferenceTileUnaryFinite` 接受 `FP64`、`FP32`、`FP16` 与 `BF16`。它们是 TLOG、TRECIP、TSQRT 与 TRSQRT 的完整类型域。TEXP 还接受 `TF32`、`HF32`、`E4M3` 与 `E5M2`，这些类型保留既有有限、非特殊结果缺口；整数与打包 SFU 操作类型在到达该路径前拒绝。

`TileUnaryValue` 在可执行模型中没有调用者。

<!-- PTO-READER-BLOCK: tile-model-execution-unary-example role=example-usage -->
## 非规范阅读示例

考虑在 32 乘 4 元素、有效行为一行的 FP32 Tile 上执行 TRECIP，没有 ExecutionMask：

```text
TRECIP <Row=32, Col=4, ValidRow=1, FP32>, T#1, ->T<512B>
```

有效源行为 2.0、-0.0、+inf 和 4.0。

1. 2.0 是有限值，因此参考实现给出 0.5，编码为 `0x3f000000`，无标志。
2. -0.0 是零，因此结果为 -inf，即 `0xff800000`，并设置 DZ。
3. +inf 得到 +0，即 `0x00000000`。
4. 4.0 得到 0.25，即 `0x3e800000`，无标志。

记录的标志只有 DZ，它被按位或进已有的粘滞状态。

<!-- PTO-READER-BLOCK: tile-model-execution-unary-related role=related-owners-navigation -->
## 相关所有者

- [逐元素执行](elementwise.md)拥有共享的二元辅助函数和类型规范化。
- [操作数 schema](../legality/operand-schema.md)拥有一元合法性检查。
- [参考转换](../numeric/reference-conversion.md)拥有 `ReferenceTileUnaryFinite`。
- [EXPDIF 执行](expdif.md)复用 TEXP 辅助函数。
- [数值状态](../../../arch/state/numeric-status.md)拥有粘滞标志。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/unary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-UNARY","surface":"tile","classification":["model","execution","unary"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE"]}

pure func TileIntegerUnaryValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => Word
begin
    assert TileDataTypeIsInteger(data_type);

    let unsigned_value = TileUnsignedElementValue(value, data_type);
    let signed_value = TileIntegerOperandValue(value, data_type);
    case operation of
        when TileUnary_ABS =>
            if TileDataTypeIsSigned(data_type) &&
               SInt(signed_value) < 0 then
                return TileUnsignedElementValue(
                    Zeros{PTO_XLEN} - signed_value,
                    data_type);
            else
                return unsigned_value;
            end;
        when TileUnary_NOT =>
            return TileUnsignedElementValue(
                NOT unsigned_value,
                data_type);
        when TileUnary_NEG =>
            return TileUnsignedElementValue(
                Zeros{PTO_XLEN} - unsigned_value,
                data_type);
        when TileUnary_RELU =>
            if TileDataTypeIsSigned(data_type) &&
               SInt(signed_value) < 0 then
                return Zeros{PTO_XLEN};
            else
                return unsigned_value;
            end;
        otherwise =>
            unreachable;
    end;
end;

pure func TileUnaryUsesClosedElementwiseContract(
    operation: TileUnaryOperation) => boolean
begin
    return operation == TileUnary_ABS ||
           operation == TileUnary_NOT ||
           operation == TileUnary_NEG ||
           operation == TileUnary_RELU;
end;

pure func TileUnaryUsesSFUElementwiseContract(
    operation: TileUnaryOperation) => boolean
begin
    return operation == TileUnary_EXP ||
           operation == TileUnary_LOG ||
           operation == TileUnary_RECIP ||
           operation == TileUnary_SQRT ||
           operation == TileUnary_RSQRT;
end;

pure func TileUnaryUsesCompleteElementwiseSchema(
    operation: TileUnaryOperation) => boolean
begin
    return TileUnaryUsesClosedElementwiseContract(operation) ||
           TileUnaryUsesSFUElementwiseContract(operation);
end;

pure func TileUnaryScalarIntegerDataType(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S64 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_U64 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8;
end;

pure func TileUnaryDataTypeSupported(
    operation: TileUnaryOperation,
    data_type: TileDataType) => boolean
begin
    if operation == TileUnary_NOT then
        return TileVecScalarIntegerDataTypeSupported(data_type);
    end;
    if operation == TileUnary_ABS then
        return TileVecArithmeticDataTypeSupported(data_type);
    end;
    if operation == TileUnary_NEG then
        return TileTNegDataTypeSupported(data_type);
    end;
    if operation == TileUnary_RELU then
        return TileTReluDataTypeSupported(data_type);
    end;
    if operation == TileUnary_EXP then
        return TileFloatingElementwiseDataTypeSupported(data_type);
    end;
    if TileUnaryUsesSFUElementwiseContract(operation) then
        return TileF3DataTypeSupported(data_type);
    end;
    return FALSE;
end;

pure func TileFloatingUnaryCarrier(
    data_type: TileDataType,
    value: Word) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return value;
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_FP16, TileDataType_BF16 =>
            return ZeroExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_E4M3, TileDataType_E5M2 =>
            return ZeroExtend{PTO_XLEN}(value[7:0]);
        otherwise =>
            unreachable;
    end;
end;

pure func TileFloatingUnarySignMask(
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x8000000000000000;
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0x80000000;
        when TileDataType_FP16, TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x8000;
        when TileDataType_E4M3, TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0x80;
        otherwise =>
            unreachable;
    end;
end;

pure func TileFloatingUnaryOneEncoding(
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0x3ff0000000000000;
        when TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} + 0x38;
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0x3c;
        otherwise =>
            unreachable;
    end;
end;

pure func TileFloatingUnaryInfinityEncoding(
    data_type: TileDataType,
    negative: boolean) => (boolean, Word)
begin
    var positive = Zeros{PTO_XLEN};
    case data_type of
        when TileDataType_FP64 =>
            positive = Zeros{PTO_XLEN} + 0x7ff0000000000000;
        when TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 =>
            positive = Zeros{PTO_XLEN} + 0x7f800000;
        when TileDataType_FP16 =>
            positive = Zeros{PTO_XLEN} + 0x7c00;
        when TileDataType_BF16 =>
            positive = Zeros{PTO_XLEN} + 0x7f80;
        when TileDataType_E5M2 =>
            positive = Zeros{PTO_XLEN} + 0x7c;
        when TileDataType_E4M3 =>
            return (FALSE, Zeros{PTO_XLEN});
        otherwise =>
            unreachable;
    end;
    if negative then
        return (
            TRUE,
            positive OR TileFloatingUnarySignMask(data_type));
    end;
    return (TRUE, positive);
end;

pure func TileFloatingUnaryUnboundedResult(
    data_type: TileDataType,
    negative: boolean) => Word
begin
    let (infinity_available, infinity) =
        TileFloatingUnaryInfinityEncoding(
            data_type,
            negative);
    if infinity_available then
        return infinity;
    end;

    // E4M3 has no infinity encoding.  These SFU operations do not admit
    // saturation, so the OFP8 non-saturating destination result is NaN.
    let (nan_available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    assert nan_available;
    return quiet_nan;
end;

pure func TileNumericValueClassIsNegative(
    value_class: NumericValueClass) => boolean
begin
    return value_class == NumericValue_NegativeZero ||
           value_class == NumericValue_NegativeSubnormal ||
           value_class == NumericValue_NegativeNormal ||
           value_class == NumericValue_NegativeInfinity;
end;

pure func TileSFUUnarySpecialValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (boolean, Word, bits(5))
begin
    assert TileUnaryUsesSFUElementwiseContract(operation);
    assert TileUnaryDataTypeSupported(operation, data_type);
    assert TileNumericEncodingValid(data_type, value);

    let carrier = TileFloatingUnaryCarrier(data_type, value);
    let value_class = TileNumericValueClass(data_type, carrier);
    let (nan_available, quiet_nan) =
        HardwareNumericCanonicalNaNResult(data_type);
    let (zero_available, positive_zero, negative_zero) =
        HardwareNumericSignedZeroEncodings(data_type);
    assert nan_available;
    assert zero_available;

    if NumericValueClassIsNaN(value_class) then
        var nan_flags = Zeros{5};
        if value_class == NumericValue_SignalingNaN then
            nan_flags = Zeros{5} + 1;
        end;
        return (TRUE, quiet_nan, nan_flags);
    end;

    if operation == TileUnary_EXP then
        if NumericValueClassIsZero(value_class) then
            return (
                TRUE,
                TileFloatingUnaryOneEncoding(data_type),
                Zeros{5});
        elsif value_class == NumericValue_PositiveInfinity then
            return (TRUE, carrier, Zeros{5});
        elsif value_class == NumericValue_NegativeInfinity then
            return (TRUE, positive_zero, Zeros{5});
        end;
    elsif operation == TileUnary_LOG then
        if carrier == TileFloatingUnaryOneEncoding(data_type) then
            return (TRUE, positive_zero, Zeros{5});
        elsif NumericValueClassIsZero(value_class) then
            return (
                TRUE,
                TileFloatingUnaryUnboundedResult(data_type, TRUE),
                Zeros{5} + 2);
        elsif value_class == NumericValue_PositiveInfinity then
            return (TRUE, carrier, Zeros{5});
        elsif TileNumericValueClassIsNegative(value_class) then
            return (TRUE, quiet_nan, Zeros{5} + 1);
        end;
    elsif operation == TileUnary_RECIP then
        if NumericValueClassIsZero(value_class) then
            let negative = value_class == NumericValue_NegativeZero;
            return (
                TRUE,
                TileFloatingUnaryUnboundedResult(data_type, negative),
                Zeros{5} + 2);
        elsif NumericValueClassIsInfinity(value_class) then
            if value_class == NumericValue_NegativeInfinity then
                return (TRUE, negative_zero, Zeros{5});
            end;
            return (TRUE, positive_zero, Zeros{5});
        end;
    elsif operation == TileUnary_SQRT then
        if NumericValueClassIsZero(value_class) ||
           value_class == NumericValue_PositiveInfinity then
            return (TRUE, carrier, Zeros{5});
        elsif TileNumericValueClassIsNegative(value_class) then
            return (TRUE, quiet_nan, Zeros{5} + 1);
        end;
    else
        assert operation == TileUnary_RSQRT;
        if NumericValueClassIsZero(value_class) then
            let negative = value_class == NumericValue_NegativeZero;
            return (
                TRUE,
                TileFloatingUnaryUnboundedResult(data_type, negative),
                Zeros{5} + 2);
        elsif value_class == NumericValue_PositiveInfinity then
            return (TRUE, positive_zero, Zeros{5});
        elsif TileNumericValueClassIsNegative(value_class) then
            return (TRUE, quiet_nan, Zeros{5} + 1);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, Zeros{5});
end;

pure func TileFloatingUnaryValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, boolean)
begin
    assert TileDataTypeIsFloating(data_type);
    assert TileNumericEncodingValid(data_type, value);

    let carrier = TileFloatingUnaryCarrier(data_type, value);
    let sign_mask = TileFloatingUnarySignMask(data_type);
    if operation == TileUnary_ABS then
        return (carrier AND NOT sign_mask, FALSE);
    elsif operation == TileUnary_NEG then
        return (carrier XOR sign_mask, FALSE);
    end;

    assert operation == TileUnary_RELU;
    let value_class = TileNumericValueClass(data_type, carrier);
    case value_class of
        when NumericValue_NegativeZero,
             NumericValue_NegativeSubnormal,
             NumericValue_NegativeNormal,
             NumericValue_NegativeInfinity,
             NumericValue_PositiveZero =>
            return (Zeros{PTO_XLEN}, FALSE);
        when NumericValue_PositiveSubnormal,
             NumericValue_PositiveNormal,
             NumericValue_PositiveInfinity =>
            return (carrier, FALSE);
        when NumericValue_QuietNaN, NumericValue_SignalingNaN =>
            let (available, quiet_nan) =
                HardwareNumericCanonicalNaNResult(data_type);
            assert available;
            return (
                quiet_nan,
                value_class == NumericValue_SignalingNaN);
        otherwise =>
            unreachable;
    end;
end;

pure func TileFixedUnaryValue(
    operation: TileUnaryOperation,
    data_type: TileDataType,
    value: Word) => (Word, boolean)
begin
    assert TileUnaryUsesClosedElementwiseContract(operation);
    assert TileUnaryDataTypeSupported(operation, data_type);
    if TileDataTypeIsInteger(data_type) then
        return (
            TileIntegerUnaryValue(operation, data_type, value),
            FALSE);
    end;
    return TileFloatingUnaryValue(operation, data_type, value);
end;

func TileUnaryValue(operation: TileUnaryOperation, value: Word) => Word
begin
    case operation of
        when TileUnary_ABS =>
            if SInt(value) < 0 then
                return Zeros{PTO_XLEN} - value;
            else
                return value;
            end;
        when TileUnary_NOT =>
            return NOT value;
        when TileUnary_NEG =>
            return Zeros{PTO_XLEN} - value;
        when TileUnary_RELU =>
            if SInt(value) < 0 then
                return Zeros{PTO_XLEN};
            else
                return value;
            end;
        when TileUnary_SQRT =>
            return TileSquareRoot(value);
        when TileUnary_LOG =>
            return TileLogarithm(value);
        when TileUnary_RECIP =>
            return TileReciprocal(value);
        when TileUnary_EXP =>
            return TileExponential(value);
        when TileUnary_RSQRT =>
            return TileReciprocalSquareRoot(value);
    end;
end;

func TileProfileUnary(op: TileUnaryOperation,
                                      data_type: TileDataType,
                                      value: Word) => (Word, bits(5))
begin
    if TileUnaryUsesClosedElementwiseContract(op) then
        let (result, invalid) = TileFixedUnaryValue(
            op,
            data_type,
            value);
        return (
            result,
            if invalid then Zeros{5} + 1 else Zeros{5});
    end;
    return ReferenceTileUnaryFinite(op, data_type, value);
end;

func ExecuteTileUnary(
    operation: TileUnaryOperation,
    destination: TileIndex,
    source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let operation_type = _Tiles[[destination]].data_type;
    assert source_tile.allocated;
    assert TileElementwiseShapeMatch(destination, source);
    assert TileCarrierWidthCompatible(source_tile.data_type, operation_type);
    assert _Tiles[[destination]].data_type == operation_type;

    var result_tile = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                if TileUnaryUsesClosedElementwiseContract(operation) then
                    let (result, element_invalid) = TileFixedUnaryValue(
                        operation, operation_type,
                        TileReadLogicalElement(source_tile, element));
                    result_tile = TileInfoWithLogicalElement(
                        result_tile, element, result);
                    if element_invalid then
                        flags = flags OR (Zeros{5} + 1);
                    end;
                else
                    let (handled, special_result, special_flags) =
                        TileSFUUnarySpecialValue(
                            operation, operation_type,
                            TileReadLogicalElement(source_tile, element));
                    var result = special_result;
                    var element_flags = special_flags;
                    if !handled then
                        let (profile_result, profile_flags) = TileProfileUnary(
                            operation, operation_type,
                            TileReadLogicalElement(source_tile, element));
                        result = profile_result;
                        element_flags = profile_flags;
                    end;
                    result_tile = TileInfoWithLogicalElement(
                        result_tile, element, result);
                    flags = flags OR element_flags;
                end;
            else
                let inactive_value = BundleExecutionMaskDestinationValue(
                    source_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result_tile = TileInfoWithLogicalElement(
                    result_tile, element, inactive_value);
            end;
        end;
    end;
    _Tiles[[destination]] = result_tile;
    MarkTileValidRegionDefined(destination);
    if TileUnaryUsesCompleteElementwiseSchema(operation) then
        ApplyTilePadding(destination, CurrentBundlePadValue());
    end;
    ScalarFPRecordFlags(flags);
end;
```
<!-- GENERATED-ASL-END: unit -->
