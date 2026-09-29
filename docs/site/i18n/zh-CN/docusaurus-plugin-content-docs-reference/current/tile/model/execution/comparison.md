<!-- GENERATED FROM: asl/tile/model/execution/comparison.asl -->
# Comparison

**Normative ASL source:** `asl/tile/model/execution/comparison.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-COMPARISON}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-comparison-purpose role=purpose-scope -->
## 用途与范围

本单元定义 Tile 比较与选择。TCMP 比较两个 Tile，TCMPS 比较 Tile 与标量，TSEL 在掩码下于两个 Tile 之间选择，TSELS 在 Tile 与标量之间选择。

指令单元通过 `ExecuteTileCompare`、`ExecuteTileCompareScalar`、`ExecuteTileSelect` 和 `ExecuteTileSelectScalar` 到达本单元。本单元还提供 `TileCompareCUBEToGPRAs`，当 CUBE TCMP 把谓词写入 GPR 时由块分派调用。

<!-- PTO-READER-BLOCK: tile-model-execution-comparison-concepts role=concepts-state -->
## 概念与可见状态

比较为每个坐标产生一个布尔值。目标载体取决于源布局：

- RowMajor 源通过 `TileInfoWithPredicateBit` 写入旧式谓词 Tile，每个元素一位。
- CUBE_M16 和 CUBE_M32 源委托给 [ExecutionMask 比较](execution-mask-comparison.md)中的 `ExecuteTileCompareCellAs`，它写入由 `0x00` 或 `0x01` 字节组成的 PredicateCell。
- GPR 形式把每个坐标的一位打包进一个 64 位字。

`TileCompareElement` 计算布尔值和一个五位状态值。整数类型在符号扩展或零扩展之后按类型所示的有符号或无符号方式比较。浮点类型使用 `TileProfileFloatingCompare`。

<!-- PTO-READER-BLOCK: tile-model-execution-comparison-rules role=rules-interactions -->
## 规则与交互

浮点比较先处理特殊值。只要任一操作数为 NaN，结果只对 NE 为 TRUE，并且仅当某个 NaN 为信号 NaN 时才置 NV 标志。正零与负零比较相等。其他值按 `TileFloatingOrderKey` 排序，它把符号-幅值编码映射为递增的无符号键。

每个执行器先断言其合法性辅助函数。比较执行器把逐元素状态 OR 成一个值，并在循环结束后调用一次 `RecordNumericStatusFlags`。选择执行器不计算数值状态。

RowMajor 比较之后，`PredicateTileWithPadding` 填充有效区域之外的位：Max 用 1 填充，Zero 和 Min 用 0 填充，Null 使其保持未定义。TSEL 和 TSELS 在 RowMajor 和 CUBE 布局上都调用 `TileWithValidRegionDefined`，然后以指令束 PadValue 调用 `TileWithPadding`。

对于 CUBE 布局，TSEL 和 TSELS 读取 PredicateCell 字节，仅当其恰为 `0x01` 时选择真源。每个坐标先询问 `BundleExecutionMaskActiveAt`；非活动坐标取 `BundleExecutionMaskDestinationValue`。

GPR 形式从 `TilePredicateGPRPaddingValue` 开始：Zero 或 Min 为全零，Max 为全一，Null 为配置档值，本模型将其设为零。随后它为每个活动的有效坐标覆写位 `row + field x rows`，其中 `rows` 对 CUBE_M16 为 16，对 CUBE_M32 为 32。当 ExecutionMask 生效时，块分派随后把该字交给 `TileExecutionMaskPredicateGPRResult`，它在 ZERO 下把每个非活动有效位设为 0，在 MERGE 下设为旧的 GPR 位。

设计要点：每个执行器在循环之前复制其源 Tile（`left_tile`、`right_tile`、`source_tile`、`true_tile`、`false_tile`、`mask_tile`），并在私有的 `result` 中构建结果；目标只在最后的赋值处改变一次，因此与源别名的目标仍看到旧的源值。

设计要点：NaN 使每个有序关系为 FALSE，使 NE 为 TRUE。这使 `!EQ` 与 NE 即使对 NaN 输入也保持一致。

<!-- PTO-READER-BLOCK: tile-model-execution-comparison-boundaries role=boundaries -->
## 架构边界

`TileCompareDataTypeSupported` 和 `TileSelectDataTypeSupported` 都接受 16 种 VEC 算术类型集合：FP64、FP32、TF32、HF32、FP16、BF16、E4M3、E5M2，以及有符号和无符号的 8、16、32 和 64 位整数。

GPR 形式还要求 CUBE_M16 或 CUBE_M32 源以及 GPR 谓词类型。`high` 选择子仅对 8 位类型合法；它把起始列移到 CUBE_M32 的 2 或 CUBE_M16 的 4。

`TileProfileCompare` 在当前 ASL 中没有调用者。

<!-- PTO-READER-BLOCK: tile-model-execution-comparison-example role=example-usage -->
## 非规范阅读示例

CMode 为 LT 的 TCMP 比较两个 FP32 RowMajor Tile，有效区域为 1 行乘 4 列。

| 列 | 左源行 | 右源行 | LT 结果 |
| --- | --- | --- | --- |
| 0 | 1.0 | 2.0 | 1 |
| 1 | 静默 NaN | 1.0 | 0 |
| 2 | -0.0 | +0.0 | 0 |
| 3 | 2.0 | 2.0 | 0 |

第 0 到 3 列的谓词位为 1、0、0、0。没有信号 NaN，因此不记录标志。若改用 CMode NE，第 1 和第 2 列将得到 1 和 0，因为 NaN 与任何值都不相等，而两个零相等。

<!-- PTO-READER-BLOCK: tile-model-execution-comparison-related role=related-owners-navigation -->
## 相关所有者

- [ExecutionMask 比较](execution-mask-comparison.md)拥有 CUBE PredicateCell 比较路径。
- [谓词载体](predicate-carriers.md)拥有标量 GPR 比较以及 GPR 掩码选择形式。
- [操作数 schema](../legality/operand-schema.md)定义比较与选择的合法性辅助函数。
- [数值状态](../../../arch/state/numeric-status.md)定义粘滞标志寄存器。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/comparison.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-COMPARISON","surface":"tile","classification":["model","execution","comparison"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
// PTO-REQ-TEPL-COMPARISON-001: packed predicate compare and select semantics.
pure func TileCompareDataTypeSupported(data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;
pure func TileSelectDataTypeSupported(data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;
pure func TileCompareBoolean(
    comparison: TileComparison,
    left_less: boolean,
    equal: boolean) => boolean
begin
    case comparison of
        when TileComparison_EQ => return equal;
        when TileComparison_NE => return !equal;
        when TileComparison_LT => return left_less;
        when TileComparison_LE => return left_less || equal;
        when TileComparison_GT => return !left_less && !equal;
        when TileComparison_GE => return !left_less || equal;
    end;
end;
pure func TileFloatingOrderKey(
    data_type: TileDataType,
    value: Word) => Word
begin
    var carrier = value;
    var sign_mask = Zeros{PTO_XLEN};
    var width_mask = Ones{PTO_XLEN};
    if data_type == TileDataType_FP64 then
        sign_mask = Zeros{PTO_XLEN} + 0x8000000000000000;
    elsif data_type == TileDataType_FP32 ||
          data_type == TileDataType_TF32 ||
          data_type == TileDataType_HF32 then
        carrier = ZeroExtend{PTO_XLEN}(value[31:0]);
        sign_mask = Zeros{PTO_XLEN} + 0x80000000;
        width_mask = Zeros{PTO_XLEN} + 0xffffffff;
    elsif data_type == TileDataType_FP16 ||
          data_type == TileDataType_BF16 then
        carrier = ZeroExtend{PTO_XLEN}(value[15:0]);
        sign_mask = Zeros{PTO_XLEN} + 0x8000;
        width_mask = Zeros{PTO_XLEN} + 0xffff;
    elsif data_type == TileDataType_E4M3 ||
          data_type == TileDataType_E5M2 then
        carrier = ZeroExtend{PTO_XLEN}(value[7:0]);
        sign_mask = Zeros{PTO_XLEN} + 0x80;
        width_mask = Zeros{PTO_XLEN} + 0xff;
    else
        unreachable;
    end;
    if (carrier AND sign_mask) != Zeros{PTO_XLEN} then
        return (NOT carrier) AND width_mask;
    end;
    return carrier OR sign_mask;
end;
func TileProfileFloatingCompare(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, bits(5))
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let signaling_nan =
        left_class == NumericValue_SignalingNaN ||
        right_class == NumericValue_SignalingNaN;
    if NumericValueClassIsNaN(left_class) ||
       NumericValueClassIsNaN(right_class) then
        return (
            comparison == TileComparison_NE,
            if signaling_nan then Zeros{5} + 1 else Zeros{5});
    end;
    let both_zero = NumericValueClassIsZero(left_class) &&
        NumericValueClassIsZero(right_class);
    let equal = both_zero || left == right;
    let left_less = if both_zero then FALSE else
        UInt(TileFloatingOrderKey(data_type, left)) <
        UInt(TileFloatingOrderKey(data_type, right));
    return (TileCompareBoolean(comparison, left_less, equal), Zeros{5});
end;

readonly func TileProfilePredicateNullGPRPadding() => Word
begin
    return Zeros{PTO_XLEN};
end;

readonly func TilePredicateGPRPaddingValue() => Word
begin
    case CurrentBundlePadValue() of
        when TilePad_Zero, TilePad_Min => return Zeros{PTO_XLEN};
        when TilePad_Max => return Ones{PTO_XLEN};
        when TilePad_Null => return TileProfilePredicateNullGPRPadding();
    end;
end;

func TileCompareElement(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, bits(5))
begin
    assert TileCompareDataTypeSupported(data_type);
    if TileDataTypeIsFloating(data_type) then
        return TileProfileFloatingCompare(
            comparison,
            data_type,
            left,
            right);
    end;
    let left_value = TileIntegerOperandValue(left, data_type);
    let right_value = TileIntegerOperandValue(right, data_type);
    let equal = left_value == right_value;
    let left_less = if TileDataTypeIsSigned(data_type) then
        SInt(left_value) < SInt(right_value) else
        UInt(left_value) < UInt(right_value);
    return (TileCompareBoolean(comparison, left_less, equal), Zeros{5});
end;
func ExecuteTileCompareAs(destination: TileIndex, source_left: TileIndex, source_right: TileIndex, comparison: TileComparison, operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileCompareAs(destination, source_left, source_right, comparison, operation_type);
    let left_tile = _Tiles[[source_left]];
    if TileLayoutIsCube(left_tile.layout) then
        ExecuteTileCompareCellAs(
            destination, source_left, source_right, comparison, operation_type);
        return;
    end;
    let right_tile = _Tiles[[source_right]];
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison,
                operation_type,
                TileReadLogicalElement(left_tile, element),
                TileReadLogicalElement(right_tile, element));
            result = TileInfoWithPredicateBit(
                result,
                row as integer {0..65535},
                column as integer {0..65535},
                predicate);
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateTileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
func ExecuteTileCompare(destination: TileIndex, source_left: TileIndex, source_right: TileIndex, comparison: TileComparison)
begin
    let (operation_type_valid, operation_type) = ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    assert operation_type_valid;
    ExecuteTileCompareAs(destination, source_left, source_right, comparison, operation_type);
end;
func TileProfileCompare(
    comparison: TileComparison,
    data_type: TileDataType,
    left: Word,
    right: Word) => Word
begin
    let (predicate, -) = TileCompareElement(
        comparison,
        data_type,
        left,
        right);
    return if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
end;
func ExecuteTileCompareScalarAs(destination: TileIndex, source: TileIndex, scalar: Word, comparison: TileComparison, operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileCompareScalarAs(destination, source, scalar, comparison, operation_type);
    let source_tile = _Tiles[[source]];
    if TileLayoutIsCube(source_tile.layout) then
        ExecuteTileCompareCellScalarAs(
            destination, source, scalar, comparison, operation_type);
        return;
    end;
    var result = _Tiles[[destination]];
    let normalized_scalar = TileRawElementValue(
        scalar,
        operation_type);
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison,
                operation_type,
                TileReadLogicalElement(source_tile, element),
                normalized_scalar);
            result = TileInfoWithPredicateBit(
                result,
                row as integer {0..65535},
                column as integer {0..65535},
                predicate);
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateTileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
func ExecuteTileCompareScalar(destination: TileIndex, source: TileIndex, scalar: Word, comparison: TileComparison)
begin
    let (operation_type_valid, operation_type) = ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    assert operation_type_valid;
    ExecuteTileCompareScalarAs(destination, source, scalar, comparison, operation_type);
end;
func ExecuteTileSelectAs(destination: TileIndex, mask: TileIndex, source_true: TileIndex, source_false: TileIndex, operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileSelectAs(destination, mask, source_true, source_false, operation_type);
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    let mask_tile = _Tiles[[mask]];
    var result = _Tiles[[destination]];
    if TileLayoutIsCube(true_tile.layout) then
        for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
            for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
                let source_element = TileLogicalLinearIndex(true_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let destination_element = TileLogicalLinearIndex(result,
                    row as integer {0..65535}, column as integer {0..65535});
                var value = Zeros{PTO_XLEN};
                if BundleExecutionMaskActiveAt(
                       true_tile.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let predicate_element = TileLogicalLinearIndex(mask_tile,
                        row as integer {0..65535}, column as integer {0..65535});
                    if TileReadLogicalElement(mask_tile, predicate_element)[7:0] ==
                       '00000001' then
                        value = TileReadLogicalElement(true_tile, source_element);
                    else
                        value = TileReadLogicalElement(false_tile, source_element);
                    end;
                else
                    value = BundleExecutionMaskDestinationValue(
                        true_tile.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN});
                end;
                result = TileInfoWithLogicalElement(
                    result, destination_element, value);
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, CurrentBundlePadValue());
        _Tiles[[destination]] = result;
        return;
    end;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if TilePredicateBitFromInfo(
                mask_tile,
                row as integer {0..65535},
                column as integer {0..65535}) then
                result = TileInfoWithLogicalElement(result, element,
                    TileReadLogicalElement(true_tile, element));
            else
                result = TileInfoWithLogicalElement(result, element,
                    TileReadLogicalElement(false_tile, element));
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelect(destination: TileIndex, mask: TileIndex, source_true: TileIndex, source_false: TileIndex)
begin
    let (operation_type_valid, operation_type) = ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    assert operation_type_valid;
    ExecuteTileSelectAs(destination, mask, source_true, source_false, operation_type);
end;
func ExecuteTileSelectScalarAs(destination: TileIndex, mask: TileIndex, source_true: TileIndex, scalar_false: Word, operation_type: TileDataType)
begin
    assert TileOperandsLegal_ExecuteTileSelectScalarAs(destination, mask, source_true, scalar_false, operation_type);
    var result = _Tiles[[destination]];
    let true_tile = _Tiles[[source_true]];
    let mask_tile = _Tiles[[mask]];
    let normalized_scalar = TileRawElementValue(
        scalar_false,
        operation_type);
    if TileLayoutIsCube(true_tile.layout) then
        for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
            for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
                let source_element = TileLogicalLinearIndex(true_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let destination_element = TileLogicalLinearIndex(result,
                    row as integer {0..65535}, column as integer {0..65535});
                var value = Zeros{PTO_XLEN};
                if BundleExecutionMaskActiveAt(
                       true_tile.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let predicate_element = TileLogicalLinearIndex(mask_tile,
                        row as integer {0..65535}, column as integer {0..65535});
                    if TileReadLogicalElement(mask_tile, predicate_element)[7:0] ==
                       '00000001' then
                        value = TileReadLogicalElement(true_tile, source_element);
                    else
                        value = normalized_scalar;
                    end;
                else
                    value = BundleExecutionMaskDestinationValue(
                        true_tile.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN});
                end;
                result = TileInfoWithLogicalElement(
                    result, destination_element, value);
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, CurrentBundlePadValue());
        _Tiles[[destination]] = result;
        return;
    end;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if TilePredicateBitFromInfo(
                mask_tile,
                row as integer {0..65535},
                column as integer {0..65535}) then
                result = TileInfoWithLogicalElement(result, element,
                    TileReadLogicalElement(true_tile, element));
            else
                result = TileInfoWithLogicalElement(
                    result, element, normalized_scalar);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
func ExecuteTileSelectScalar(destination: TileIndex, mask: TileIndex, source_true: TileIndex, scalar_false: Word)
begin
    let (operation_type_valid, operation_type) = ResolveTileCarrierOperationType(_Tiles[[destination]].data_type);
    assert operation_type_valid;
    ExecuteTileSelectScalarAs(destination, mask, source_true, scalar_false, operation_type);
end;
// CUBE predicate-carrier extension.  The legacy packed row-major path above is
// intentionally unchanged; these helpers are selected only for CUBE layouts.
pure func TileCubePredicateColumnBase(data_type: TileDataType,
                                      layout: TileLayout,
                                      high: boolean) => integer {0..8}
begin
    if TileElementBits(data_type) != 8 then return 0; end;
    if layout == TileLayout_CUBE_M32 then return if high then 2 else 0; end;
    return if high then 4 else 0;
end;
readonly func TileOperandsLegal_ExecuteTileCompareGPRAs(
    source_left: TileIndex, source_right: TileIndex, high: boolean,
    operation_type: TileDataType) => boolean
begin
    if !TileCompareDataTypeSupported(operation_type) ||
       !TileCubeNumericShapeMatch(source_left, source_right) then
        return FALSE;
    end;
    let left = _Tiles[[source_left]];
    if left.layout != TileLayout_CUBE_M16 && left.layout != TileLayout_CUBE_M32 then
        return FALSE;
    end;
    return TileCubePredicateGPRDataTypeSupported(operation_type) &&
           TileCubePredicateGPRShapeLegalAs(source_left, operation_type) &&
           (TileElementBits(operation_type) == 8 || !high) &&
           TileCarrierWidthCompatible(left.data_type, operation_type) &&
           TileCarrierWidthCompatible(
               _Tiles[[source_right]].data_type, operation_type) &&
           TileCubeNumericSourceLegalAs(source_left, operation_type) &&
           TileCubeNumericSourceLegalAs(source_right, operation_type);
end;
readonly func TileOperandsLegal_ExecuteTileCompareGPR(
    source_left: TileIndex, source_right: TileIndex, high: boolean) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    return operation_type_valid &&
           TileOperandsLegal_ExecuteTileCompareGPRAs(
               source_left, source_right, high, operation_type);
end;
func TileCompareCUBEToGPRAs(source_left: TileIndex, source_right: TileIndex,
                            comparison: TileComparison, high: boolean,
                            operation_type: TileDataType) => Word
begin
    assert TileOperandsLegal_ExecuteTileCompareGPRAs(
        source_left, source_right, high, operation_type);
    let left = _Tiles[[source_left]];
    let right = _Tiles[[source_right]];
    let width = TileCubePredicateRowBits(left.layout);
    let fields = TileCubePredicateFieldCount(operation_type, left.layout);
    let base = TileCubePredicateColumnBase(operation_type, left.layout, high);
    var result = TilePredicateGPRPaddingValue();
    var flags = Zeros{5};
    for field = 0 to fields - 1 looplimit 8 do
        let column = base + field;
        if column < left.valid_columns then
            for row = 0 to width - 1 looplimit 32 do
                if row < left.valid_rows &&
                   BundleExecutionMaskActiveAt(
                       left.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let element = TileLogicalLinearIndex(left,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let (predicate, element_flags) = TileCompareElement(
                        comparison, operation_type,
                        TileReadLogicalElement(left, element),
                        TileReadLogicalElement(right, element));
                    flags = flags OR element_flags;
                    let result_index = row + field * width;
                    result[result_index] = if predicate then '1' else '0';
                end;
            end;
        end;
    end;
    RecordNumericStatusFlags(flags);
    return result;
end;
func TileCompareCUBEToGPR(source_left: TileIndex, source_right: TileIndex,
                          comparison: TileComparison, high: boolean) => Word
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    assert operation_type_valid;
    return TileCompareCUBEToGPRAs(
        source_left, source_right, comparison, high, operation_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
