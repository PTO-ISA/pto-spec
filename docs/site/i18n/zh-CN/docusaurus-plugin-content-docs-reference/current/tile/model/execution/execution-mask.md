<!-- GENERATED FROM: asl/tile/model/execution/execution-mask.asl -->
# Execution Mask

**Normative ASL source:** `asl/tile/model/execution/execution-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-purpose role=purpose-scope -->
## 用途与范围

本单元把 ExecutionMask 捕获到指令束作用域的记录 `_BundleExecutionMask` 中。ExecutionMask 是合格的 Local CUBE_M16 或 CUBE_M32 Tile 操作的显式逐坐标谓词。

它有两个捕获函数，每种载体一个。`CaptureBundleExecutionMaskGPR` 接收一个或两个标量字。`CaptureBundleExecutionMaskPredicateTile` 接收 PredicateCell，即每个坐标保存 `0x00` 或 `0x01` 的 U8 CUBE 存储。两者都由块分派层中的 `CaptureSelectedBundleExecutionMask` 在载体已选定并检查之后调用。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-concepts role=concepts-state -->
## 概念与可见状态

两个函数都把 `valid` 设为 TRUE，记录载体种类、坐标布局和坐标有效形状。两者都复制两个 B.DATR 控制：把 `execution_mask_invert`（PredInv）复制到 `invert`，把 `execution_mask_zero`（Zero）复制到 `zero_inactive`。两者都清除 `merge_base_valid`；另一个分派步骤负责准备 MERGE 基。

GPR 形式把 `low` 存入 `low_word`。仅当 `word_count` 为 2 时才把 `high` 存入 `high_word`，否则存零。

PredicateCell 形式构建 `predicate_tile_snapshot`，这是一个 524288 位的向量。对每个有效行和列，它把谓词元素的第 0 位存到索引 `row x valid_columns + column`。它还记录 `predicate_tile`，并把两个 GPR 字和 `word_count` 清零。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-rules role=rules-interactions -->
## 规则与交互

`CaptureBundleExecutionMaskGPR` 断言布局为 CUBE_M16 或 CUBE_M32。

`CaptureBundleExecutionMaskPredicateTile` 断言 `TileExecutionMaskPredicateCellShapeLegal`。该检查要求合法的 PredicateCell 描述符、等于 `layout` 实参的 CUBE_M16 或 CUBE_M32 布局、相同的有效行数和列数、已定义的内容，并且每个有效值都等于 `0x00` 或 `0x01`。分派已在 ExecutionMask schema 中把 PredicateCell 布局与消费者布局比较过。

分派在解析并分配操作目标之前捕获掩码。之后每次调用 `BundleExecutionMaskActiveAt` 都读取捕获的记录，而不是实时载体。

设计要点：PredicateCell 在捕获时被复制到快照中。即使操作的目标之后被分配到同一寄存器，整个操作使用的谓词值仍是操作前的值。

设计要点：即使 Zero 为 0，捕获也会清除 `merge_base_valid`。只有在 `PrepareSelectedBundleExecutionMaskMerge` 检查过合并基之后，MERGE 才可用，因此未经检查的基永远不会供给非活动坐标。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-boundaries role=boundaries -->
## 架构边界

这些函数不检查操作合格性、GPR 字数与形状的关系或 B.DATR 合法性。分派用[谓词载体](predicate-carriers.md)中的 `TileOperationExecutionMaskEligible` 检查合格性；[ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) 在捕获之前检查载体和 GPR 形状；[命令数据属性](../../../block/model/dispatch/command-data-attributes.md)中的 `BundleExecutionMaskDataAttributesLegal` 在捕获之后立即检查 B.DATR。任何失败都会在操作执行之前引发 Fault_TileLegality。

掩码是指令束状态，而不是架构寄存器状态。指令束复位和描述符状态复位会把 `valid` 设为 FALSE，因此掩码永远不会从一个指令束带到下一个指令束。

每个 PredicateCell 元素只捕获第 0 位；形状检查已要求整个字节为 `0x00` 或 `0x01`。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-example role=example-usage -->
## 非规范阅读示例

一个 PredicateCell 采用 CUBE_M32 布局，有效形状为 2 行乘 3 列。其值为第 0 行：`0x01 0x00 0x01`，第 1 行：`0x00 0x01 0x01`。

1. 快照索引为 `row x 3 + column`。第 0 行用 1、0、1 填充索引 0、1、2。第 1 行用 0、1、1 填充索引 3、4、5。
2. PredInv 清零时，6 个坐标中有 4 个活动。
3. PredInv 置位时，`invert` 为 TRUE，改为另外 2 个坐标活动，即第 0 行第 1 列和第 1 行第 0 列。
4. 如果操作随后在同一寄存器中发布目标，这些答案不会改变。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-related role=related-owners-navigation -->
## 相关所有者

- [ExecutionMask 状态](execution-mask-state.md)读取捕获的记录，以决定活动性和非活动值。
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md)选择载体、调用这些函数并准备合并基。
- [谓词载体合法性](../legality/predicate-carriers.md)定义 `TileExecutionMaskPredicateCellShapeLegal`。
- [谓词载体](predicate-carriers.md)在其需求注释中陈述载体规则。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/execution-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MASK","surface":"tile","classification":["model","execution","execution-mask"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-ALLOCATION"]}
func CaptureBundleExecutionMaskGPR(
    low: Word, high: Word, word_count: integer {1..2},
    layout: TileLayout, valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
begin
    assert layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32;
    _BundleExecutionMask.valid = TRUE;
    _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
    _BundleExecutionMask.predicate_tile = 0;
    _BundleExecutionMask.predicate_source_ordinal = 0;
    _BundleExecutionMask.low_word = low;
    _BundleExecutionMask.high_word =
        if word_count == 2 then high else Zeros{PTO_XLEN};
    _BundleExecutionMask.word_count = word_count;
    _BundleExecutionMask.layout = layout;
    _BundleExecutionMask.valid_rows = valid_rows;
    _BundleExecutionMask.valid_columns = valid_columns;
    _BundleExecutionMask.invert =
        _BundleDataAttributes.execution_mask_invert;
    _BundleExecutionMask.zero_inactive =
        _BundleDataAttributes.execution_mask_zero;
    _BundleExecutionMask.merge_base_valid = FALSE;
end;
func CaptureBundleExecutionMaskPredicateTile(
    predicate: TileIndex, layout: TileLayout,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
begin
    assert TileExecutionMaskPredicateCellShapeLegal(
        predicate, layout, valid_rows, valid_columns);
    let source = _Tiles[[predicate]];
    var snapshot = Zeros{524288};
    for row = 0 to valid_rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                source, row as integer {0..65535},
                column as integer {0..65535});
            let logical_index = (row * valid_columns + column)
                as integer {0..524287};
            snapshot[logical_index] = source.payload[[element]][0];
        end;
    end;
    _BundleExecutionMask.valid = TRUE;
    _BundleExecutionMask.carrier = BundleExecutionMask_PredicateTile;
    _BundleExecutionMask.predicate_tile = predicate;
    _BundleExecutionMask.predicate_source_ordinal = 0;
    _BundleExecutionMask.low_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.high_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.word_count = 0;
    _BundleExecutionMask.layout = layout;
    _BundleExecutionMask.valid_rows = valid_rows;
    _BundleExecutionMask.valid_columns = valid_columns;
    _BundleExecutionMask.invert =
        _BundleDataAttributes.execution_mask_invert;
    _BundleExecutionMask.zero_inactive =
        _BundleDataAttributes.execution_mask_zero;
    _BundleExecutionMask.merge_base_valid = FALSE;
    _BundleExecutionMask.predicate_tile_snapshot = snapshot;
end;
```
<!-- GENERATED-ASL-END: unit -->
