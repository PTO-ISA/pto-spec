<!-- GENERATED FROM: asl/tile/model/legality/descriptor-shape.asl -->
# Descriptor Shape

**Normative ASL source:** `asl/tile/model/legality/descriptor-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-purpose role=purpose-scope -->
## 用途与范围

本单元定义大多数 Tile 合法性谓词所依赖的基础描述符检查。描述符是 Local Tile 寄存器的 `TileInfo` 记录：容量、形状、有效区域、数据类型、布局与存储种类。

- `TileDescriptorConfigured` 检查描述符内部是否一致。
- `TileDescriptorLegal` 进一步要求允许通用元素索引。
- `TileCubeDescriptorLegal` 是针对 CUBE 布局的独立检查。
- `TileSourceContentsDefined` 进一步要求载荷已定义。

本单元带有需求 `PTO-REQ-TILE-LEGALITY-001`：译码后的 Tile 操作数在产生效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-concepts role=concepts-state -->
## 概念与可见状态

这四个谓词读取 `_Tiles`，并经由 `TileCapacityIsLegal` 读取所配置的 Tile 容量上限；它们都不写状态，也不引发故障。

有效区域是操作所计算的 `valid_rows` 乘 `valid_columns` 矩形。它位于物理 `rows` 乘 `columns` 形状之内。

通用索引是指通过 `TileLinearIndex` 按行和列定位元素。`TileGenericIndexingPermitted` 对 RowMajor 与 ColumnMajor 允许通用索引；对分形布局，要求 `rows` 为 16 的倍数且 `columns` 为分形内部宽度的倍数。它拒绝 CUBE 布局和 `TileLayout_ImplementationDefined`。

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-rules role=rules-interactions -->
## 规则与交互

`TileDescriptorConfigured` 要求以下全部成立：

- 寄存器已分配，且其容量通过 `TileCapacityIsLegal`。
- 对谓词 Tile，`rows` 与 `columns` 为正，且 `PredicateTileStorageBytes` 不超过容量。
- 对其他 Tile，`TileShapeMatchesCapacity` 对其容量、形状与数据类型成立。
- 有效区域位于物理形状之内。
- `rows` x `columns` 不超过 `TileLogicalElementCapacity`。

`TileDescriptorLegal` 直接接受已配置的谓词 Tile。对其他存储种类，它还要求 `TileGenericIndexingPermitted`。

设计要点：CUBE Tile 永远不满足 `TileDescriptorLegal`，因为通用索引拒绝 CUBE 布局。CUBE Tile 改用 `TileCubeDescriptorLegal`。该谓词要求 Tile 为已分配的数值 Tile，调用 `TileCubeDescriptorShapeAndPhysicalLegal`，并把记录的 `cube_k_repeat`、`cube_n_repeat`、`cube_cell_count` 与 `cube_storage_bytes` 同由布局、形状和数据类型重新计算的值比较。由于记录的几何必须等于重新计算的几何，重复或单元字段与形状不一致的 CUBE 描述符会被拒绝。

`TileSourceContentsDefined` 等于 `TileDescriptorLegal` 加上 `contents_defined`。它是源 Tile 的常用检查门。

设计要点：基于这些检查的合法性谓词在操作读取源快照或写入目标载荷之前运行。其中一些在指令束封闭 schema 中、早于目标分配运行；生成的合法性处理函数在分配之后运行，失败时回滚该分配。已释放、从未分配或已分配但尚未写入的 Tile 会在此失败，因此操作从不读取陈旧或未定义的源数据。

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-boundaries role=boundaries -->
## 架构边界

这些谓词被广泛调用。例如，归约、索引重排、内存、ExecutionMask 源与分配容量等合法性单元都使用它们，指令束分派在 `ResolveBundleEffectiveDataType` 的 `TMOV` 路径中使用 `TileDescriptorConfigured`。

`TileSourceContentsDefined` 只检查整个 Tile 的标志。带掩码操作的逐元素已定义性在其他地方检查，例如由 `TileElementwiseSourceContentsDefined` 检查。

这些谓词不检查 PE 池中的剩余容量。容量准入属于 Local 容量单元。

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-example role=example-usage -->
## 非规范阅读示例

取一个已分配的 FP32 RowMajor Tile，容量 4096 字节，64 行，16 列，有效区域 50 乘 10。

- 当所配置的 Tile 容量上限不小于 4096 时，4096 是合法容量；且 4096 x 8 / (16 x 32) = 64 个派生行，因此形状匹配。
- 64 x 16 = 1024 个元素，等于 `TileLogicalElementCapacity`，即 32768 位 / 32 = 1024。
- RowMajor 允许通用索引，因此 `TileDescriptorLegal` 为 TRUE。

若该 Tile 尚未被写入，`contents_defined` 为 FALSE，`TileSourceContentsDefined` 也为 FALSE。

<!-- PTO-READER-BLOCK: tile-model-legality-descriptor-shape-related role=related-owners-navigation -->
## 相关所有者

- [Tile 模型类型](../state/types.md) 定义 `TileInfo`。
- [Tile 分配](../state/allocation.md) 写入此处检查的描述符。
- [行与列](../shape/rows-columns.md) 负责 `TileShapeMatchesCapacity`。
- [CUBE 单元几何](../shape/cube-cell.md) 负责 CUBE 形状与物理检查。
- [元素已定义性](../definedness/elements.md) 负责 `TileGenericIndexingPermitted`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/descriptor-shape.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","surface":"tile","classification":["model","legality","descriptor-shape"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS"]}
// PTO-REQ-TILE-LEGALITY-001: decoded tile operands are rejected before effects.

readonly func TileDescriptorConfigured(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    return tile.allocated &&
           TileCapacityIsLegal(tile.capacity_bytes) &&
           (if tile.storage_kind == TileStorage_Predicate then
                tile.rows > 0 && tile.columns > 0 &&
                PredicateTileStorageBytes(tile.rows, tile.columns) <=
                    tile.capacity_bytes
            else
                TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
                    tile.columns, tile.data_type)) &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <=
               TileLogicalElementCapacity(tile.capacity_bytes,
                                           tile.data_type);
end;

readonly func TileDescriptorLegal(index: TileIndex) => boolean
begin
    return TileDescriptorConfigured(index) &&
           (_Tiles[[index]].storage_kind == TileStorage_Predicate ||
            TileGenericIndexingPermitted(_Tiles[[index]]));
end;

readonly func TileCubeDescriptorLegal(tile: TileInfo) => boolean
begin
    if !tile.allocated || tile.storage_kind != TileStorage_Numeric ||
       !TileCubeDescriptorShapeAndPhysicalLegal(tile.capacity_bytes,
           tile.rows, tile.columns, tile.valid_rows, tile.valid_columns,
           tile.data_type, tile.layout) then
        return FALSE;
    end;
    return tile.cube_k_repeat == TileCubePhysicalKRepeat(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_n_repeat == TileCubePhysicalNRepeat(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_cell_count == TileCubePhysicalCellCount(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes == TileCubePhysicalRequiredBytes(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes <= tile.capacity_bytes;
end;

readonly func TileSourceContentsDefined(index: TileIndex) => boolean
begin
    return TileDescriptorLegal(index) && _Tiles[[index]].contents_defined;
end;
```
<!-- GENERATED-ASL-END: unit -->
