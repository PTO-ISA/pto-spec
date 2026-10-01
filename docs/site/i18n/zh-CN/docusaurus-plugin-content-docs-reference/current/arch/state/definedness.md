<!-- GENERATED FROM: asl/arch/state/definedness.asl -->
# Definedness

**Normative ASL source:** `asl/arch/state/definedness.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-DEFINEDNESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-definedness-purpose-scope role=purpose-scope -->
## 用途与范围

`asl/arch/state/definedness.asl` 是一个两行的单元。第 1 行是 `PTO-UNIT` JSON，其中给出 `PTO-ARCH-STATE-DEFINEDNESS` 以及唯一的依赖 `PTO-ARCH-STATE-TILE-DESCRIPTOR`；第 2 行是注释 `// This unit owns the named architecture concept; executable state is defined by its dependencies.`。

该文件没有声明任何函数、类型、常量、状态变量、`DOC-BEGIN` 区域或 `NDF-BEGIN` 子句。因此本页拥有的是一个架构名称，以及通往真正包含已定义性状态的所有者的路径；它不是这些状态的第二个定义。

<!-- PTO-READER-BLOCK: arch-definedness-concepts-state role=concepts-state -->
## 声明的依赖包含什么

第 1 行给出的依赖本身也只是名称所有者。`asl/arch/state/tile-descriptor.asl` 有两行，它自己的 `PTO-UNIT` JSON 给出 `PTO-ARCH-FEATURES-SHARED-TILE-STATE`；后者有两行并给出 `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`；该单元有两行并给出 `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`；该单元有两行并给出 `PTO-ARCH-FEATURES-PREDICATION`。

在这条链上，第一个文件内含可执行 ASL 的单元是 `asl/arch/programming-model/predicate-registers.asl` 中的 `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS`：它声明 `_PredicateRegisters`，`ReadPredicateRegister` 对索引 `0` 返回 `Ones{PTO_PREDICATE_WIDTH}`，否则返回已存储的字，而 `WritePredicateRegister` 忽略索引 `0`。

Design point：从本单元出发沿第 1 行的链接前进，会先到达谓词寄存器所有者，而不是任何已定义性所有者。可执行的已定义性状态由 `asl/tile/model/definedness/elements.asl` 中的 `PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS` 拥有，而该单元没有出现在本页依赖链的任何位置。只按单元标识解析已定义性的读者会落到谓词寄存器上，而谓词并不是 Tile 已定义性。

<!-- PTO-READER-BLOCK: arch-definedness-rules-interactions role=rules-interactions -->
## 已定义性在何处可执行

已定义性是 `asl/tile/model/state/types.asl` 中声明的 `TileInfo` 记录的一组字段：`contents_defined` 是 `boolean`，`defined_elements` 是 `bits(PTO_MODEL_TILE_ELEMENTS)`，`defined_valid_elements` 是 `integer {0..524288}`，`packed_defined_elements` 是 `bits(524288)`。这些记录存放于 `_Tiles`，由 `asl/tile/model/state/local-registers.asl` 声明。

`TileElementDefined(index, row, column)` 按坐标作答：对打包行的填充列返回 `FALSE`，否则用 `TileLogicalLinearIndex` 映射该坐标并返回 `TileLogicalElementDefined(tile, element)`。此外还有两个整 Tile 辅助函数：`MarkTileValidRegionDefined(index)` 定义 `valid_rows` 乘 `valid_columns` 有效区域中的每个坐标，`MarkTilePhysicalRegionDefined(index)` 把该操作扩展到完整的 `rows` 乘 `columns` 区域以及打包行的余量。

Design point：`WriteTileElement` 让汇总字段由逐元素记录推导，而不是信任调用方。它在写入前读取 `was_defined`，仅当该坐标此前未定义且位于有效区域内时才递增 `defined_valid_elements`，随后把 `contents_defined` 重新计算为 `defined_valid_elements == valid_rows * valid_columns`。可观察的结果是：部分写入的本地 Tile 会报告 `contents_defined` 为 `FALSE`，于是 `asl/tile/model/legality/descriptor-shape.asl` 中的 `TileSourceContentsDefined`（即 `TileDescriptorLegal(index) && _Tiles[[index]].contents_defined`）会拒绝把该 Tile 作为源。

<!-- PTO-READER-BLOCK: arch-definedness-boundaries role=boundaries -->
## 架构边界

本页不定义值何时变为已定义，也不引入单独的有效位。已定义性恰好就是上面四个 `TileInfo` 字段以及维护它们的那些辅助函数。

填充不会自动变为已定义。`TileWithPadding` 把 `padding_defined` 计算为 `pad_value != TilePad_Null`，并把该标志传给 `TileInfoWithLogicalElementAndDefined`，由后者把 `'1'` 或 `'0'` 存入该元素的已定义性位。因此 `PadValue=Null` 的填充过程会让填充坐标保持未定义，`TileElementDefined` 对它们继续返回 `FALSE`。

<!-- PTO-READER-BLOCK: arch-definedness-example-usage role=example-usage -->
## 阅读示例

取一个已分配的 Tile，其 `valid_rows` 为 `4`、`valid_columns` 为 `8`。执行 `MarkTileValidRegionDefined(index)` 之后，`defined_valid_elements` 为 `32`，`contents_defined` 为 `TRUE`。之后在该区域内调用 `WriteTileElement` 会读到 `was_defined` 为真，计数保持 `32`，汇总字段保持 `TRUE`。对物理区域执行 `PadValue=Null` 的填充过程不会改变任何已定义性位，所以 `TileElementDefined` 在有效区域之外仍然回答 `FALSE`。

<!-- PTO-READER-BLOCK: arch-definedness-related-owners role=related-owners-navigation -->
## 相关所有者

- [Tile 描述符](tile-descriptor.md)是第 1 行给出的依赖。
- [Shared Tile 状态](../features/shared-tile-state.md)是该链的下一环。
- [Tile 本地寄存器](../../tile/model/state/local-registers.md)声明 `_Tiles` 以及状态对象 `PTO-STATE-TILE-LOCAL` 和 `PTO-STATE-TILE-SHARED`。
- [Tile 已定义性元素](../../tile/model/definedness/elements.md)拥有逐元素与整 Tile 的已定义性辅助函数。
- [Tile 描述符形状合法性](../../tile/model/legality/descriptor-shape.md)拥有 `TileSourceContentsDefined`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/definedness.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-DEFINEDNESS","surface":"arch","classification":["state","definedness"],"depends_on":["PTO-ARCH-STATE-TILE-DESCRIPTOR"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
