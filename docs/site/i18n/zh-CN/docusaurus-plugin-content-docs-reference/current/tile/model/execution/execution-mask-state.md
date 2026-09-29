<!-- GENERATED FROM: asl/tile/model/execution/execution-mask-state.asl -->
# Execution Mask State

**Normative ASL source:** `asl/tile/model/execution/execution-mask-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-purpose role=purpose-scope -->
## 用途与范围

本单元为每个支持掩码的 Tile 执行器回答一个问题：在当前 ExecutionMask 下，这个结果坐标是否活动？ExecutionMask 是显式的逐坐标谓词，指令束可以把它绑定到合格的 Local CUBE_M16 或 CUBE_M32 操作上。

它还回答后续问题：非活动坐标得到什么值？本单元拥有五个只读或纯辅助函数，自身不拥有状态。它们读取的状态 `_BundleExecutionMask` 由 [ExecutionMask 捕获](execution-mask.md)单元捕获。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-concepts role=concepts-state -->
## 概念与可见状态

`_BundleExecutionMask` 记录掩码是否生效（`valid`）、由哪个载体提供（GPR 字或 PredicateCell 快照）、坐标布局与有效形状，以及两个 B.DATR 控制。`invert` 来自 PredInv。`zero_inactive` 来自 Zero。选择 MERGE 时，`merge_base` 指明其旧值由非活动坐标保留的 Tile。

GPR 载体每个坐标打包一位。`TileCubePredicateGPRBit` 计算 `row + column x rows`，其中 CUBE_M32 的 rows 为 32，其他情况为 16。索引 0 到 63 来自低字，64 到 127 来自高字。

PredicateCell 载体从按 `row x valid_columns + column` 索引的私有快照中读取，而不是从实时 Tile 读取。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-rules role=rules-interactions -->
## 规则与交互

没有生效的掩码时，`BundleExecutionMaskActiveAt` 返回 TRUE。否则它返回坐标位 XOR `invert`。

`BundleExecutionMaskCoordinateBit` 断言掩码有效、请求的布局等于捕获的布局，且坐标位于捕获的有效形状之内。

对于活动坐标或没有生效的掩码，`BundleExecutionMaskDestinationValue` 返回计算值。对于非活动坐标，`zero_inactive` 为 TRUE 时返回零。否则它断言 `merge_base_valid`，并返回合并基在同一行列上的旧元素。

没有生效的掩码时，`BundleExecutionMaskHasActiveCoordinate` 返回 TRUE；否则它扫描捕获的有效形状，报告是否存在活动坐标。合法性检查会使用它，例如使整数 TDIVS 或 TREMS 的零除数检查仅在存在活动坐标时适用。

设计要点：掩码通过快照读取，而不是读取实时谓词 Tile。同一操作中后来的写入，包括复用该谓词寄存器的目标，都不能改变哪些坐标是活动的。

设计要点：取反只在 `BundleExecutionMaskActiveAt` 中施加一次。调用此辅助函数的每个执行器看到相同的极性，因此 PredInv 不需要逐操作处理。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-boundaries role=boundaries -->
## 架构边界

这些辅助函数不决定操作能否接受掩码。该决定由[谓词载体](predicate-carriers.md)中的 `TileOperationExecutionMaskEligible` 与块分派 schema共同作出。

MERGE 需要 `merge_base_valid`。块分派辅助函数 `PrepareSelectedBundleExecutionMaskMerge` 仅在检查合并基已分配、完全已定义且与期望的布局、形状和类型一致之后才设置它。否则分派会在产生效果之前以故障拒绝。

GPR 载体最多覆盖 128 位，因为 `TileCubePredicateGPRBit` 断言 `column x rows < 128`。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-example role=example-usage -->
## 非规范阅读示例

考虑一个 FP16 CUBE_M16 操作，其单字 GPR 掩码的低字为 `0x0000000800000000`（只有第 35 位置位）。

1. 对于第 3 行第 2 列，打包索引为 3 + 2 x 16 = 35。第 35 位为 1，因此该坐标活动。
2. 对于第 4 行第 2 列，索引为 36。该位为 0，因此该坐标非活动。
3. 设置 PredInv 时，`invert` 为 TRUE，两个答案互换。
4. Zero 清零且合并基有效时，第 4 行第 2 列的非活动坐标保留合并基在该处的旧元素。

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-related role=related-owners-navigation -->
## 相关所有者

- [ExecutionMask 捕获](execution-mask.md)从 GPR 对或 PredicateCell 填充 `_BundleExecutionMask`。
- [谓词载体](predicate-carriers.md)列出合格操作以及 GPR 谓词生产者。
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md)选择载体并准备合并基。
- [逐元素执行](elementwise.md)是调用这些辅助函数的众多执行器之一。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/execution-mask-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MASK-STATE","surface":"tile","classification":["model","execution","execution-mask-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
pure func TileCubePredicateGPRBit(
    low: Word, high: Word, layout: TileLayout,
    row: integer {0..65535}, column: integer {0..65535}) => boolean
begin
    let rows = if layout == TileLayout_CUBE_M32 then 32 else 16;
    assert row < rows && column * rows < 128;
    let packed_index = (row + column * rows) as integer {0..127};
    if packed_index < 64 then return low[packed_index] == '1'; end;
    return high[packed_index - 64] == '1';
end;
readonly func BundleExecutionMaskCoordinateBit(
    layout: TileLayout, row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    assert _BundleExecutionMask.valid &&
           layout == _BundleExecutionMask.layout &&
           row < _BundleExecutionMask.valid_rows &&
           column < _BundleExecutionMask.valid_columns;
    if _BundleExecutionMask.carrier == BundleExecutionMask_GPR then
        assert _BundleExecutionMask.word_count == 1 ||
               _BundleExecutionMask.word_count == 2;
        return TileCubePredicateGPRBit(
            _BundleExecutionMask.low_word,
            _BundleExecutionMask.high_word, layout, row, column);
    end;
    assert _BundleExecutionMask.carrier ==
           BundleExecutionMask_PredicateTile;
    let logical_index =
        (row * _BundleExecutionMask.valid_columns + column)
            as integer {0..524287};
    return _BundleExecutionMask.predicate_tile_snapshot[logical_index] == '1';
end;
readonly func BundleExecutionMaskActiveAt(
    layout: TileLayout, row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    return BundleExecutionMaskCoordinateBit(layout, row, column) !=
           _BundleExecutionMask.invert;
end;

readonly func BundleExecutionMaskHasActiveCoordinate() => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    for row = 0 to _BundleExecutionMask.valid_rows - 1 looplimit 65536 do
        for column = 0 to _BundleExecutionMask.valid_columns - 1
            looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   _BundleExecutionMask.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

readonly func BundleExecutionMaskDestinationValue(
    layout: TileLayout, row: integer {0..65535},
    column: integer {0..65535}, computed: Word) => Word
begin
    if !_BundleExecutionMask.valid ||
       BundleExecutionMaskActiveAt(layout, row, column) then
        return computed;
    end;
    if _BundleExecutionMask.zero_inactive then
        return Zeros{PTO_XLEN};
    end;
    assert _BundleExecutionMask.merge_base_valid;
    let base = _Tiles[[_BundleExecutionMask.merge_base]];
    let element = TileLogicalLinearIndex(base, row, column);
    return TileReadLogicalElement(base, element);
end;
```
<!-- GENERATED-ASL-END: unit -->
