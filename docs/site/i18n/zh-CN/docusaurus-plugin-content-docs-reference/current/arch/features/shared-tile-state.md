<!-- GENERATED FROM: asl/arch/features/shared-tile-state.asl -->
# Shared Tile State

**Normative ASL source:** `asl/arch/features/shared-tile-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-SHARED-TILE-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-shared-tile-state-purpose role=purpose-scope -->
## 用途与范围

`asl/arch/features/shared-tile-state.asl` 只有两行：`PTO-UNIT` 元数据注释，以及一条说明该单元拥有该命名概念、可执行状态由其依赖定义的注释。本单元自身不含任何可执行 ASL。

它所声明的依赖是 `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`，而后者本身也是一个只有两行的标记单元，因此仅沿本页自身的声明无法到达可执行定义。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-concepts role=concepts-state -->
## 所声明链条能到达什么

沿 `depends_on` 声明前进，本页与第一个可执行文件之间隔着三个标记单元：`PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`、`PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS` 与 `PTO-ARCH-FEATURES-PREDICATION`。链条上的第四个单元 `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS` 才是可执行的。

- 该链条上唯一的可执行文件是 `asl/arch/programming-model/predicate-registers.asl`。
- 它基于 `_PredicateRegisters` 定义 `ReadPredicateRegister`、`WritePredicateRegister` 与 `PredicateRegisterHasInstructionConsumer`。
- 三个标记都没有声明状态变量，链条上可执行的那个单元也没有自己的声明，因此该链条到达不了任何共享 Tile 存储。

设计要点：本页的 `depends_on` 指向架构编程模型标记，而标记只提供身份与导航。把本页及其所声明链条读到尽头得到的是谓词寄存器而不是共享 Tile 寄存器，因此共享 Tile 的问题必须改到另一个归属面上求解。

可执行的共享 Tile 状态声明在别处：状态 `PTO-STATE-TILE-SHARED` 只有一个成员 `_SharedTiles`，归属于 `PTO-TILE-MODEL-STATE-LOCAL-REGISTERS`，并带有 `var _SharedTiles : SharedTileSnapshot` 与 `SharedTileSnapshot of array [[PTO_SHARED_TILE_COUNT]] of SharedTileInfo`。每条记录带有 `descriptor_valid`、`allocation_mask`、`initialized_mask`、`whole_parent_ready`、`published` 与 `tile`，且 `PTO_SHARED_TILE_COUNT` 为 `64`。

设计要点：该状态对应的 NDF 条款 `PTO-REQ-SHARED-TILE-001` 与状态放在一起，而不在本标记中；它说明共享 Tile 寄存器必须是由 `PTO-STATE-TILE-SHARED` 定义的核心私有状态。因此对共享 Tile 行为的修改要针对该条款与该状态归属单元进行验证，而本页没有可修改的条款。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-rules role=rules-interactions -->
## 如何沿所有权链阅读

本单元只提供身份与一条依赖边：`id` 为 `PTO-ARCH-FEATURES-SHARED-TILE-STATE`，`surface` 为 `arch`，`classification` 为 `["features","shared-tile-state"]`，以及一条 `depends_on`。它不声明类型、函数、常量或变量，因此无法改变任何状态转换。

共享 Tile 的状态转换位于 `asl/tile/model/state/shared-registers.asl`，例如 `SharedTilePublished`、`AtomicUpdateSharedTile` 与 `InstallSharedTile`。这些函数不在本单元的依赖链上，因此本页不是它们的归属单元。

设计要点：归属文件的两行分别是元数据与一句归属说明，两者之间没有任何可执行语句。因此在这里无法添加任何行为，除非修改拥有 ASL 的单元；同样也无法对照本页验证任何共享 Tile 规则。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-boundaries role=boundaries -->
## 边界

不要从本标记推导分配、可见性、发布、配置档或生命周期行为。它的两行只说明归属与一条依赖，对其中的任何一项都没有规则。

追溯到本页的主张无法对照 ASL 检查，因为本页不拥有 ASL。请对照 `PTO-TILE-MODEL-STATE-LOCAL-REGISTERS` 检查状态，并对照共享寄存器归属单元检查状态转换。

设计要点：沿所声明链条可达的唯一可执行状态是谓词寄存器堆，它读写 `_PredicateRegisters` 并报告没有指令消费者。停在链条尽头的读者到达的是与共享 Tile 寄存器毫无关系的谓词状态。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-example role=example-usage -->
## 非规范阅读示例

要查明什么会发布共享 Tile，请从本页的元数据开始，沿 `depends_on` 到 `shared-tile-registers.asl`，再经过 `tile-registers.asl`、`predication.asl` 与 `predicate-registers.asl`；这条路径终止于谓词读写，回答不了该问题。

答案就在相邻的一个面上：`SharedTileRecord(shared_tile_id)` 返回由 `UInt(shared_tile_id)` 选出的 `SharedTileInfo` 记录，`SharedTileFullyInitialized` 组合 `descriptor_valid`、`initialized_mask == allocation_mask` 与 `tile.contents_defined`，而 `SharedTilePublished` 再加上 `whole_parent_ready` 与 `published`。

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-shared-tile-state-related role=related-owners-navigation -->
## 相关归属单元

- [共享 Tile 寄存器](../programming-model/shared-tile-registers.md) 是本页所声明的依赖。
- [Tile 寄存器](../programming-model/tile-registers.md) 是链条上的下一个标记。
- [共享 Tile 状态与状态转换](../../tile/model/state/shared-registers.md) 拥有 `_SharedTiles` 的访问与更新。
- [共享 Tile 状态类型](../../tile/model/state/types.md) 定义 `SharedTileInfo` 与 `SharedTileSnapshot`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/shared-tile-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-SHARED-TILE-STATE","surface":"arch","classification":["features","shared-tile-state"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
