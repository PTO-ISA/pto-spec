<!-- GENERATED FROM: asl/tile/model/execution/execution-mask-comparison.asl -->
# Execution Mask Comparison

**Normative ASL source:** `asl/tile/model/execution/execution-mask-comparison.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-purpose role=purpose-scope -->
## 用途与范围

本单元定义源使用 CUBE_M16 或 CUBE_M32 布局且目标为 PredicateCell 时的 TCMP 和 TCMPS。PredicateCell 是 U8 CUBE 谓词存储，在每个坐标上以 `0x01` 表示 TRUE，以 `0x00` 表示 FALSE。

当源布局为 CUBE 布局时，[比较](comparison.md)中的 `ExecuteTileCompareAs` 和 `ExecuteTileCompareScalarAs` 委托到这里。这些函数在委托之前断言比较合法性辅助函数。这里的两个 `As` 函数接收显式操作类型，两个包装函数通过 `ResolveTileCarrierOperationType` 解析该类型。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-concepts role=concepts-state -->
## 概念与可见状态

Tile-Tile 形式遍历左源的有效行和列。标量形式遍历源的有效区域，并先用 `TileRawElementValue` 把标量规格化为操作类型的宽度。

对每个坐标，执行器询问 `BundleExecutionMaskActiveAt`。没有生效的 ExecutionMask 时，每个坐标都活动。

结果在目标记录的私有副本中构建，五位数值状态在 `flags` 中累积。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-rules role=rules-interactions -->
## 规则与交互

活动坐标读取两个操作数，调用 `TileCompareElement`，把 `1` 或 `0` 写入目标元素，并把元素状态 OR 进 `flags`。

非活动坐标不读取任何源值，也不贡献状态。它写入 `BundleExecutionMaskDestinationValue`，在 ZERO 策略下为零，在 MERGE 下为合并基的旧元素。

循环结束后，执行器以指令束 PadValue 调用 `PredicateCellWithPadding`。在有效区域之外，Max 写入 `0x01` 并标为已定义，Zero 和 Min 写入 `0x00` 并标为已定义，Null 写入零并使其保持未定义。

随后它把 `defined_valid_elements` 设为有效面积，把 `contents_defined` 设为 TRUE，一次性记录累积标志，并发布目标。

设计要点：源从 `left`、`right` 和 `source_tile` 读取，它们是循环之前取得的副本，目标只在最后写入。因此与源别名的目标不会改变比较所读取的值。

设计要点：非活动坐标跳过 `TileCompareElement`。因此非活动坐标上的信号 NaN 不能置 NV，这与非活动效果不贡献数值状态的要求一致。

设计要点：整个有效区域都变为已定义，包括非活动坐标。在 MERGE 下，合法性检查已要求合并基完全已定义，因此复制来的值也是已定义的。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-boundaries role=boundaries -->
## 架构边界

本单元只产生 PredicateCell 目标。RowMajor 比较在[比较](comparison.md)中产生按位打包的谓词 Tile，GPR 目标形式由那里的 `TileCompareCUBEToGPRAs` 和[谓词载体](predicate-carriers.md)中的 `TileCompareCUBEScalarToGPRAs` 拥有。

本单元自身不检查合法性。类型、形状、编码有效性和 PredicateCell 描述符检查在到达这些函数之前运行。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-example role=example-usage -->
## 非规范阅读示例

CMode 为 GE 的 TCMPS 把一个 S16 CUBE_M16 源与标量 `0x00010005` 比较。规格化为 16 位后保留 `0x0005`，即 5。

有效区域为 1 行乘 3 列，值为 7、5 和 -2。一个 GPR ExecutionMask 使第 2 列非活动，且 B.DATR Zero 为 1。

| 列 | 源值 | 活动 | 目标字节 |
| --- | --- | --- | --- |
| 0 | 7 | 是 | `0x01` |
| 1 | 5 | 是 | `0x01` |
| 2 | -2 | 否 | `0x00` |

第 2 列为 `0x00` 是由于 ZERO 策略，而不是因为 -2 小于 5。不记录任何标志，因为整数比较从不设置状态。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-related role=related-owners-navigation -->
## 相关所有者

- [比较](comparison.md)拥有 `TileCompareElement` 和 RowMajor 路径。
- [ExecutionMask 状态](execution-mask-state.md)拥有活动性测试和非活动目标值。
- [谓词载体合法性](../legality/predicate-carriers.md)拥有 `PredicateCellWithPadding` 和 PredicateCell 描述符规则。
- [比较 schema](../../../block/model/dispatch/comparison-schema.md)在 PredicateCell 与 GPR 目标形式之间选择。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/execution-mask-comparison.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON","surface":"tile","classification":["model","execution","execution-mask-comparison"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
func ExecuteTileCompareCellAs(destination: TileIndex, source_left: TileIndex,
                              source_right: TileIndex, comparison: TileComparison,
                              operation_type: TileDataType)
begin
    let left = _Tiles[[source_left]];
    let right = _Tiles[[source_right]];
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to left.valid_rows - 1 looplimit 65536 do
        for column = 0 to left.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   left.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(left,
                    row as integer {0..65535}, column as integer {0..65535});
                let (predicate, element_flags) = TileCompareElement(
                    comparison, operation_type,
                    TileReadLogicalElement(left, element),
                    TileReadLogicalElement(right, element));
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
                flags = flags OR element_flags;
            else
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    BundleExecutionMaskDestinationValue(
                        left.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = PredicateCellWithPadding(result, CurrentBundlePadValue());
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;

func ExecuteTileCompareCell(destination: TileIndex, source_left: TileIndex,
                            source_right: TileIndex, comparison: TileComparison)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    assert operation_type_valid;
    ExecuteTileCompareCellAs(
        destination, source_left, source_right, comparison, operation_type);
end;

func ExecuteTileCompareCellScalarAs(destination: TileIndex, source: TileIndex,
                                    scalar: Word, comparison: TileComparison,
                                    operation_type: TileDataType)
begin
    let source_tile = _Tiles[[source]];
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let source_element = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let (predicate, element_flags) = TileCompareElement(
                    comparison, operation_type,
                    TileReadLogicalElement(source_tile, source_element),
                    normalized_scalar);
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
                flags = flags OR element_flags;
            else
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    BundleExecutionMaskDestinationValue(
                        source_tile.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = PredicateCellWithPadding(result, CurrentBundlePadValue());
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;

func ExecuteTileCompareCellScalar(destination: TileIndex, source: TileIndex,
                                  scalar: Word, comparison: TileComparison)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    assert operation_type_valid;
    ExecuteTileCompareCellScalarAs(
        destination, source, scalar, comparison, operation_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
