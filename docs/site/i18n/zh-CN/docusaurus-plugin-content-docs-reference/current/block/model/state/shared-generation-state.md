<!-- GENERATED FROM: asl/block/model/state/shared-generation-state.asl -->
# Shared Generation State

**Normative ASL source:** `asl/block/model/state/shared-generation-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-SHARED-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-purpose role=purpose-scope -->
## 用途与范围

本单元定义挂起的 Shared 代次记录如何被清除、复位、查询和中止。Shared 代次是对一个 Shared Tile 进行中的 `B.ASSEMBLE` 构建，在发布之前可以由若干个指令束或参与的 PE 填充。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-concepts role=concepts-state -->
## 概念与可见状态

`_SharedGenerations` 为每个 Shared Tile ID 保存一条记录，共 `PTO_SHARED_TILE_COUNT` 条记录。每条记录跟踪：

- 生命周期标志 `open`、`closed` 和 `published`；
- Shared Tile ID、参与者掩码、父级大小码和父级单元数；
- `covered_cells` 和 `ready_cells` 位图，以及 `arrived_participants` 掩码；
- 专用的生产者输入和元数据，以及一个有效标志；
- `last_seen`；
- Tile 的一个工作副本（`working_tile`），以及 `working_valid` 和 `working_initialized_mask`。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-rules role=rules-interactions -->
## 规则与交互

`ClearBundleSharedGenerationState(id)` 复位一个 ID 的记录：它保留 Shared Tile ID，其余所有标志、掩码、位图和输入都变为零或 false。`working_tile` 从当前已发布的 Shared Tile 重新加载。

`ResetBundleSharedGenerationState` 清除每条记录。`BundleSharedGenerationOpen(id)` 报告 `open` 标志。`AbortBundleSharedGeneration(id)` 与清除该记录相同。

设计要点：中止只丢弃工作副本。已发布的 Shared Tile 不受影响，工作副本从它重新加载。因此，被拒绝或发生故障的组装会让先前已发布的 Shared 对象保持原样，这正是 Shared 代次契约 `PTO-B-ASSEMBLE-SHARED-GENERATION-001` 所要求的。

设计要点：挂起的 Shared 代次在完整的集体发布之前始终位于架构 `S` 寄存器堆之外。其他读者看到的要么是旧对象，要么是完整的新对象，永远不会看到部分组装的 Tile。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-boundaries role=boundaries -->
## 架构边界

本单元不打开、扩展或发布代次。这些步骤以及覆盖和参与者检查由 Shared 代次操作数单元拥有。

Shared 代次记录不会被 `ClearBundleHeaderState` 清除。它们在提交后保留，并通过中止、发布或复位关闭。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对 Shared Tile 3 的一个双指令束组装在第二个指令束发生故障时已覆盖一半单元。Tile 执行中止 ID 3 的代次。该记录的所有标志都回到 false，其覆盖为空，其工作副本等于已发布的 Shared Tile 3，Shared Tile 3 的读者仍然看到旧对象。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-related role=related-owners-navigation -->
## 相关所有者

- [Shared 代次](../operands/shared-generation.md)打开、扩展并发布代次。
- [Shared 寄存器](../../../tile/model/state/shared-registers.md)拥有已发布的 Shared Tile。
- [Tile 执行](../dispatch/tile-execution.md)在操作失败后中止代次。
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/shared-generation-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","surface":"block","classification":["model","state","shared-generation-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
func ClearBundleSharedGenerationState(shared_tile_id: SharedTileID)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedGenerations[[index]].open = FALSE;
    _SharedGenerations[[index]].closed = FALSE;
    _SharedGenerations[[index]].published = FALSE;
    _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
    _SharedGenerations[[index]].participant_mask = Zeros{4};
    _SharedGenerations[[index]].parent_size_code = 0;
    _SharedGenerations[[index]].parent_cell_count = 0;
    _SharedGenerations[[index]].covered_cells = Zeros{8192};
    _SharedGenerations[[index]].ready_cells = Zeros{8192};
    _SharedGenerations[[index]].arrived_participants = Zeros{4};
    _SharedGenerations[[index]].specialized_inputs_valid = FALSE;
    _SharedGenerations[[index]].specialized_input0 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input1 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input2 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input3 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_metadata = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].last_seen = FALSE;
    _SharedGenerations[[index]].working_valid = FALSE;
    _SharedGenerations[[index]].working_tile =
        _SharedTiles[[index]].tile;
    _SharedGenerations[[index]].working_initialized_mask = Zeros{4};
end;

func ResetBundleSharedGenerationState()
begin
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        ClearBundleSharedGenerationState(
            (Zeros{6} + raw_id) as SharedTileID);
    end;
end;

readonly func BundleSharedGenerationOpen(shared_tile_id: SharedTileID)
    => boolean
begin
    return _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].open;
end;

func AbortBundleSharedGeneration(shared_tile_id: SharedTileID)
begin
    ClearBundleSharedGenerationState(shared_tile_id);
end;
```
<!-- GENERATED-ASL-END: unit -->
