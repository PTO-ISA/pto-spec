<!-- GENERATED FROM: asl/block/model/faults/rollback.asl -->
# Rollback

**Normative ASL source:** `asl/block/model/faults/rollback.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-FAULTS-ROLLBACK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-faults-rollback-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `RollBackBundleTileDestinations`。它释放失败的指令束为其目标分配的 Local Tile，并把这些绑定恢复为其编码的 hand。

每当目标分配之后的某一步失败时，tile 执行路径都会调用它：写者验证失败、GPR 比较载体失败，或操作主体失败或发生故障。若干专用的 TLSU 和 CUBE 处理程序也在其自身的失败路径上调用它。

<!-- PTO-READER-BLOCK: block-model-faults-rollback-concepts role=concepts-state -->
## 概念与可见状态

每个 Tile 绑定（一个 `B.IOT` 条目）以两种形式记录其目标。`destination_hand` 是编码的 hand（`T`、`U`、`M` 或 `N`，编码为 0 到 3）。`destination` 要么是该编码值，要么在分配之后是从该 hand 中选出的具体 Tile 寄存器索引。

两个标志描述具体目标的来源：

- 当本指令束为该目标分配了一个新的 Tile 时，设置 `destination_allocated_by_bundle`。
- 当目标是由 `B.ASSEMBLE` 代次延续的已有父 Tile 时，设置 `destination_reused_by_generation`。

<!-- PTO-READER-BLOCK: block-model-faults-rollback-rules role=rules-interactions -->
## 规则与交互

对于每个由指令束分配且未被代次复用的有效绑定，回滚执行三件事：

1. 用 `ReleaseTile` 释放已分配的 Tile。
2. 把 `destination` 设回编码的 hand 值。
3. 清除 `destination_allocated_by_bundle`。

然后，如果有故障待处理，且当前 ring 持有有效的陷阱上下文，回滚会把更新后的 Tile 绑定和范围组状态复制到该已保存的上下文中。

设计要点：只释放由指令束分配的目标。被代次复用的目标是在指令束之前就已存在的父 Tile，释放它会破坏并非由该指令束创建的数据。回滚将其保留在原处，代次中止会单独处理其代次记录。

设计要点：恢复编码的 hand 会把绑定恢复到分配之前的状态。当指令束从已保存的上下文重试时，目标解析会把该绑定视为未分配，并重新选择一个 Tile。

设计要点：已保存的陷阱上下文在释放之后被修补。ASL 注释给出了原因：内存故障会在调用者释放推测性目标之前保存 block，而 Tile 分配状态不属于可移植的陷阱上下文。如果不修补，恢复后的指令束会认为自己仍然拥有一个现已空闲的 Tile。

<!-- PTO-READER-BLOCK: block-model-faults-rollback-boundaries role=boundaries -->
## 架构边界

本单元只释放 Tile 绑定中记录的 Local 目标 Tile。中止 Local 和 Shared 代次记录以及丢弃子视图物化，是 tile 执行路径在本调用旁边另行发起的调用。

回滚不会撤销全局内存存储、标量写入或对源 Tile 的效果。可能产生此类效果的操作会定义各自的顺序和预检规则。

<!-- PTO-READER-BLOCK: block-model-faults-rollback-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个指令束在 hand `T` 上绑定一个目标，编码为 0。解析分配了 `T` 寄存器索引 5，并把该绑定标记为已分配。随后操作主体引发 `Fault_TileLegality`。回滚释放索引 5，并把绑定目标设回 0。由于 `SetFault` 已经保存了陷阱上下文，该上下文现在也显示目标为 0 且未分配。

<!-- PTO-READER-BLOCK: block-model-faults-rollback-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行](../dispatch/tile-execution.md)安排验证、分配、执行和回滚的顺序。
- [目标形状](../dispatch/destination-shape.md)执行回滚所撤销的分配。
- [Tile 绑定](../operands/tile-bindings.md)定义绑定字段。
- [陷阱上下文](../../../arch/state/trap-context.md)拥有回滚所修补的已保存上下文。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/faults/rollback.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-FAULTS-ROLLBACK","surface":"block","classification":["model","faults","rollback"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE"]}
func RollBackBundleTileDestinations()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_reused_by_generation then
            ReleaseTile(_BundleTileBindings[[binding]].destination);
            _BundleTileBindings[[binding]].destination =
                UInt(_BundleTileBindings[[binding]].destination_hand)
                    as TileIndex;
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                FALSE;
        end;
    end;
    let ring = CurrentACR();
    if _LastFault != Fault_None && _TrapContexts[[ring]].valid then
        // Memory faults save the block before the caller can release a
        // speculative destination.  Recovery must observe the same rolled
        // back binding state as live execution, because Tile allocation state
        // itself is not part of the portable trap context.
        _TrapContexts[[ring]].bundle_tile_bindings = _BundleTileBindings;
        _TrapContexts[[ring]].bundle_range_group = _BundleRangeGroup;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
