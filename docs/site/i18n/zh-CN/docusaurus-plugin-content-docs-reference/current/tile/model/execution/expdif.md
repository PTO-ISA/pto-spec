<!-- GENERATED FROM: asl/tile/model/execution/expdif.asl -->
# Expdif

**Normative ASL source:** `asl/tile/model/execution/expdif.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-EXPDIF}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-expdif-purpose role=purpose-scope -->
## 用途与范围

本单元拥有自然指数差序列：左减右之差的指数。`ExecuteTileExpdif` 是 TEXPDIF 指令的处理函数。`TileExpdifValueWithTypesAndFlags` 计算单个元素，并通过扩展单元与 TROWEXPANDEXPDIF 和 TCOLEXPANDEXPDIF 广播形式共享。

它承载已接受的条款 `PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001`。

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-concepts role=concepts-state -->
## 概念与可见状态

涉及两种类型。源操作类型来自指令束选择的 DataType；没有选中指令束操作时，来自第一个源 Tile。目标类型是目标 Tile 的 `data_type`。

`TileExpdifTypePairLegal` 允许五种组合：

| 源操作类型 | 目标类型 |
| --- | --- |
| FP16 | FP16 或 FP32 |
| BF16 | BF16 或 FP32 |
| FP32 | FP32 |

每个元素返回一个值和五个状态标志，从 bit 0 到 bit 4 依次为 NV、DZ、OF、UF 和 NX。

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-rules role=rules-interactions -->
## 规则与交互

对同类型组合，元素在目标类型中计算：

1. 通过 `TileProfileBinaryWithFlags` 执行左减右的 SUB。
2. 对差值应用 TEXP 特殊值规则。
3. 否则用 `TileProfileUnary` 计算有限值指数。

两个步骤的标志按位或合并。

对混合组合，两个源先由 `ExactWidenFP16ToFP32` 或 `ExactWidenBF16ToFP32` 精确加宽到 FP32。随后在 FP32 中执行相同的 SUB 和 EXP 步骤。`HardwareNumericMixedExpdifDiscriminator` 在这些步骤之前为两对特定的加宽输入固定结果。

设计要点：加宽是精确的重新解释，而不是 TCVT。它保持所表示的值，包括 NaN 载荷，并且不贡献转换状态。只有 FP32 的 SUB 和 EXP 可以设置标志。

设计要点：两个源记录都在构建任何结果之前被捕获。`ExecuteTileExpdif` 复制两个源的 `TileInfo` 记录并私下构建结果，因此目标即使命名任一源，读取的仍是旧值。

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-boundaries role=boundaries -->
## 架构边界

在 ExecutionMask 下，非活动坐标不读取源、不执行算术，也不贡献标志。它取 ZERO 或 MERGE 值。

循环结束后，处理函数把有效区域标记为已定义，应用指令束填充，记录按位或合并的标志，并发布目标。

合法组合集合中的每种类型都是 FP32、FP16 或 BF16。SUB 辅助函数和有限值 EXP 辅助函数都接受这些类型。

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-example role=example-usage -->
## 非规范阅读示例

考虑 TEXPDIF，源为 FP32，目标为 32 乘 4 元素、有效行为一行的 FP32 Tile：

```text
TEXPDIF <Row=32, Col=4, ValidRow=1, FP32>, T#1, T#2, ->T<512B>
```

四个有效列中的两列展示特殊路径。

1. 左 3.0、右 3.0：差为 +0。零的 EXP 为 1.0，编码为 `0x3f800000`，无标志。
2. 左 1.0、右 +inf：差为 -inf，无标志。-inf 的 EXP 为 +0，编码为 `0x00000000`。

两列都不记录标志，因此这两个元素不改变粘滞状态。

<!-- PTO-READER-BLOCK: tile-model-execution-expdif-related role=related-owners-navigation -->
## 相关所有者

- [TEXPDIF](../../elementwise-tile-tile/transcendental/TEXPDIF.md) 是到达 `ExecuteTileExpdif` 的指令。
- [EXPDIF 操作数合法性](../legality/expdif-operands.md)拥有源操作类型。
- [扩展执行](expansion.md)为广播形式复用元素辅助函数。
- [一元执行](unary.md)拥有 TEXP 特殊值。
- [逐元素执行](elementwise.md)拥有 SUB 辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/expdif.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Predicated TEXPDIF evaluates source encodings, source reads, arithmetic, and numeric-status contribution only for active logical result coordinates. Inactive destination coordinates use the common MERGE/ZERO rule and contribute no numeric flags; the existing source-operation and destination type-pair contract remains unchanged.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-EXPDIF","surface":"tile","classification":["model","execution","expdif"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
// PTO-REQ-TILE-EXPDIF-001: one typed natural-expansion-difference sequence is
// shared by the binary and broadcast Tile operations.

// Exact FP16/BF16 value widening is an interpretation step, not TCVT. It
// preserves the represented value and contributes no conversion status.
pure func ExactWidenBF16ToFP32(value: Word) => Word
begin
    return LSL(ZeroExtend{PTO_XLEN}(value[15:0]), 16);
end;

pure func ExactWidenFP16ToFP32(value: Word) => Word
begin
    let raw = value[15:0];
    let sign = raw[15];
    let exponent = raw[14:10];
    let fraction = raw[9:0];
    var result: bits(32) = Zeros{32};
    result[31] = sign;
    if exponent == '11111' then
        result[30:23] = Ones{8};
        // Preserve NaN payload and the quiet/signaling bit for FP32 SUB.
        result[22:13] = fraction;
    elsif exponent != Zeros{5} then
        result[30:23] = Zeros{8} + (UInt(exponent) + 112);
        result[22:13] = fraction;
    elsif fraction != Zeros{10} then
        var normalized = fraction;
        var shift_count: integer {0..9} = 0;
        for shift = 0 to 9 looplimit 10 do
            if normalized[9] == '0' then
                normalized = LSL(normalized, 1);
                shift_count = (shift_count + 1) as integer {0..9};
            end;
        end;
        result[30:23] = Zeros{8} + (112 - shift_count);
        result[22:13] = ZeroExtend{10}(normalized[8:0]);
    end;
    return ZeroExtend{PTO_XLEN}(result);
end;

func TileProfileMixedExpdifFP32(
    source_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    assert source_type == TileDataType_FP16 ||
           source_type == TileDataType_BF16;
    let (handled, discriminator_result) =
        HardwareNumericMixedExpdifDiscriminator(left, right);
    if handled then return (discriminator_result, Zeros{5}); end;

    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        TileDataType_FP32,
        left,
        right);
    let (special_handled, special_result, special_flags) =
        TileSFUUnarySpecialValue(
            TileUnary_EXP,
            TileDataType_FP32,
            difference);
    if special_handled then
        return (special_result, subtract_flags OR special_flags);
    end;

    let (profile_result, profile_flags) = TileProfileUnary(
        TileUnary_EXP,
        TileDataType_FP32,
        difference);
    return (profile_result, subtract_flags OR profile_flags);
end;

func TileExpdifValueWithTypesAndFlags(
    source_operation_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    assert TileExpdifTypePairLegal(
        source_operation_type, destination_type);
    if source_operation_type != destination_type then
        assert destination_type == TileDataType_FP32;
        let widened_left = if source_operation_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(left)
        else
            ExactWidenBF16ToFP32(left);
        let widened_right = if source_operation_type == TileDataType_FP16 then
            ExactWidenFP16ToFP32(right)
        else
            ExactWidenBF16ToFP32(right);
        return TileProfileMixedExpdifFP32(
            source_operation_type, widened_left, widened_right);
    end;

    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        destination_type,
        left,
        right);
    let (handled, special_result, special_flags) =
        TileSFUUnarySpecialValue(
            TileUnary_EXP,
            destination_type,
            difference);
    if handled then
        return (special_result, subtract_flags OR special_flags);
    end;
    let (profile_result, profile_flags) = TileProfileUnary(
        TileUnary_EXP,
        destination_type,
        difference);
    return (profile_result, subtract_flags OR profile_flags);
end;

func ExecuteTileExpdif(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileExpdif(
        destination, source0, source1);
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    assert operation_type_valid;
    let left_tile = _Tiles[[source0]];
    let right_tile = _Tiles[[source1]];
    var result_tile = _Tiles[[destination]];
    var accumulated_flags = Zeros{5};

    // Capture both complete source records before constructing any result.
    // The destination may name either old source in the rename model.
    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let left_element = TileLogicalLinearIndex(
                    left_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let right_element = TileLogicalLinearIndex(
                    right_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let (value, element_flags) = TileExpdifValueWithTypesAndFlags(
                    operation_type,
                    result_tile.data_type,
                    TileReadLogicalElement(left_tile, left_element),
                    TileReadLogicalElement(right_tile, right_element));
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
                accumulated_flags = accumulated_flags OR element_flags;
            else
                let value = BundleExecutionMaskDestinationValue(
                    result_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result_tile = TileInfoWithLogicalElement(
                    result_tile, destination_element, value);
            end;
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(result_tile, CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
```
<!-- GENERATED-ASL-END: unit -->
