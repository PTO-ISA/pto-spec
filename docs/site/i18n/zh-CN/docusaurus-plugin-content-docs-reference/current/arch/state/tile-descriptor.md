<!-- GENERATED FROM: asl/arch/state/tile-descriptor.asl -->
# Tile Descriptor

**Normative ASL source:** `asl/arch/state/tile-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-TILE-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-descriptor-purpose-scope role=purpose-scope -->
## 用途与范围

`asl/arch/state/tile-descriptor.asl` 是一个两行的单元。第 1 行是 `PTO-UNIT` JSON，其中给出 `PTO-ARCH-STATE-TILE-DESCRIPTOR` 以及依赖 `PTO-ARCH-FEATURES-SHARED-TILE-STATE`；第 2 行是注释，说明该单元拥有这个架构概念，而可执行状态由其依赖定义。

这里没有声明任何描述符记录、字段、访问函数或状态转换，文件中也没有 `DOC-BEGIN` 或 `NDF-BEGIN` 区域。本页是该概念的稳定名称，并指向真正持有描述符状态的所有者。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-concepts-state role=concepts-state -->
## 声明的依赖包含什么

第 1 行给出的依赖同样只是名称所有者。`asl/arch/features/shared-tile-state.asl` 有两行，其 `PTO-UNIT` JSON 给出 `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`；后者有两行并给出 `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`；该单元有两行并给出 `PTO-ARCH-FEATURES-PREDICATION`。

在这条链上，第一个含可执行 ASL 的单元是 `asl/arch/programming-model/predicate-registers.asl` 中的 `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS`。同一条链的更远处还有 `asl/arch/programming-model/execution-context.asl` 与 `asl/arch/system-registers/addressing.asl`，后者的 `ResetProfileState` 会清除承载描述符的记录。

可执行的描述符状态声明在 `asl/tile/model/state/types.asl`。`SharedTileInfo` 含类型为 `boolean` 的 `descriptor_valid`、类型为 `bits(4)` 的 `allocation_mask`、类型为 `bits(4)` 的 `initialized_mask`、类型为 `boolean` 的 `whole_parent_ready`、类型为 `boolean` 的 `published`，以及类型为 `TileInfo` 的 `tile`。`SharedTileSnapshot` 是 `array [[PTO_SHARED_TILE_COUNT]] of SharedTileInfo`，而 `_SharedTiles` 以该类型在 `asl/tile/model/state/local-registers.asl` 中声明，因此一个核持有 `64` 条 Shared 记录。

Design point：`descriptor_valid` 是分配门，而不是缓存的合法性结果。`asl/tile/model/state/shared-registers.asl` 中的 `SharedTileDescriptorLegal` 每次都用当时读到的记录重新计算合法性，条件包括 `descriptor_valid`、`tile.allocated`、非零的 `allocation_mask`、掩码测试 `(initialized_mask AND NOT allocation_mask) == Zeros{4}` 以及容量与形状测试。因此，改变 `initialized_mask` 或几何形状会改变描述符合法性，而无需写入 `descriptor_valid`。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-rules-interactions role=rules-interactions -->
## 描述符状态如何变化

`AtomicUpdateSharedTileWithPublication` 是提交点。它从当前记录构造 `updated`，在首次分配时设置 `descriptor_valid`、`allocation_mask` 与 `tile`，为多 PE 生产者推进 `initialized_mask`，最后以一次记录赋值 `_SharedTiles[[index]] = updated` 结束。PE 掩码为零时会在任何写入之前返回 `TRUE`。随后 `SharedTilePublished` 要求 `descriptor_valid`、`initialized_mask == allocation_mask`、`tile.contents_defined`、`whole_parent_ready` 与 `published`。

本地 Tile 的几何与已定义性使用的正是嵌套在 `SharedTileInfo` 内部的那个 `TileInfo` 类型。`ResetProfileState` 清除 `_Tiles[[index]]` 的字段，包括 `allocated`、`contents_defined`、`defined_elements`、`defined_valid_elements`、`capacity_bytes`、`rows`、`columns`、`valid_rows`、`valid_columns`、`data_type` 与 `layout`，并清除 `_SharedTiles[[index]].descriptor_valid` 与 `published`。

形状合法性是计算出来的，而不是存储的。`asl/tile/model/shape/valid-region.asl` 中的 `TileDescriptorShapeLegal` 用 `DerivedTileRows` 从 `capacity_bytes`、`columns` 与 `data_type` 推导出 `rows`，然后检查 `valid_rows <= rows`、`valid_columns <= columns`，以及有效区域是否满足 `TileLogicalElementCapacity`。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-boundaries role=boundaries -->
## 架构边界

本页不发明描述符布局、有效性、容量、所有权、生命周期或故障行为。这些规则中的每一条都必须从记录声明或实现它的辅助函数中读取。

无效的 Shared 记录并不构成故障。当 `descriptor_valid` 为 `FALSE`、`whole_parent_ready` 为 `FALSE`，或所寻址元素未定义时，`ReadSharedTileWord` 返回 `UndefinedSharedTileWord(shared_tile_id, element)`；该读取既不分配寄存器，也不改变 Shared 状态。

Design point：由于 Shared 记录按值嵌套完整的 `TileInfo`，而不是引用某个本地 Tile，发布操作一次搬运整个描述符加载荷快照。`MaterializeSharedTile` 断言 `SharedTilePublished` 并返回 `shared.tile`，因此通过该检查的消费者读到的是一个内部一致的描述符，无法观察到只更新了一半的字段集合。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-example-usage role=example-usage -->
## 阅读示例

紧接 `ResetProfileState` 之后，一条 Shared 记录的 `descriptor_valid` 为 `FALSE`、`allocation_mask` 为 `0000`，因此 `SharedTileDescriptorLegal` 为 `FALSE`，`ReadSharedTileWord` 回答的是由 `UndefinedSharedTileWord` 产生的确定性模型值。一次 `AtomicUpdateSharedTileWithPublication` 调用，若使用单 PE 掩码或掩码 `1111`、`publish` 为真，且记录的 `tile.contents_defined` 为真，就会在那一次提交中设置 `descriptor_valid`、`allocation_mask`、`initialized_mask`、`whole_parent_ready` 与 `published`，此后 `SharedTilePublished` 为 `TRUE`。

<!-- PTO-READER-BLOCK: arch-tile-descriptor-related-owners role=related-owners-navigation -->
## 相关所有者

- [Shared Tile 状态](../features/shared-tile-state.md)是第 1 行给出的依赖。
- [Shared Tile 寄存器](../programming-model/shared-tile-registers.md)与 [Tile 寄存器](../programming-model/tile-registers.md)延续该链。
- [Shared 寄存器状态](../../tile/model/state/shared-registers.md)拥有描述符合法性与发布辅助函数。
- [Tile 状态类型](../../tile/model/state/types.md)声明 `TileInfo` 与 `SharedTileInfo`。
- [已定义性](definedness.md)把本概念所有者列为其依赖。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/tile-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-TILE-DESCRIPTOR","surface":"arch","classification":["state","tile-descriptor"],"depends_on":["PTO-ARCH-FEATURES-SHARED-TILE-STATE"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
