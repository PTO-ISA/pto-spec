<!-- GENERATED FROM: asl/tile/model/legality/matrix-info-descriptor.asl -->
# Matrix Info Descriptor

**Normative ASL source:** `asl/tile/model/legality/matrix-info-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-purpose role=purpose-scope -->
## 用途与范围

本单元为以 `TileInfo` 值、而不是以 Local Tile 寄存器索引传入的矩阵（CUBE 矩阵乘）操作数定义两个描述符检查。

- `TileInfoDescriptorLegal` 检查一个非 CUBE 的 `TileInfo` 值是否为格式正确、已定义且可通用索引的 Tile。
- `TileMatrixMixedInfosMatchDimensions` 按矩阵乘维度 M、N 与 K 检查混合操作数对：CUBE 布局的左操作数与非 CUBE 的右操作数。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-concepts role=concepts-state -->
## 概念与可见状态

`TileInfo` 值是一个 Tile 的完整描述符与载荷记录。矩阵合法性有时作用于并不存放在 `_Tiles` 中的值，例如 `MaterializeBundleSharedMatrixPrimary` 从 Shared Tile 构造的右操作数。该值布局为 RowMajor，只在检查与计算期间存在。

设计要点：`TileDescriptorLegal` 接收寄存器索引并读取 `_Tiles`，因此无法检查物化出的值。`TileInfoDescriptorLegal` 直接在值上重复同类检查。

在矩阵乘中，左操作数为 M x K，右操作数为 K x N。这些维度与每个操作数的有效区域比较。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-rules role=rules-interactions -->
## 规则与交互

`TileInfoDescriptorLegal` 要求以下全部成立：

- `allocated` 与 `contents_defined` 为 TRUE。
- 容量通过 `TileCapacityIsLegal`，且 `TileShapeMatchesCapacity` 成立。
- 有效区域位于物理形状之内。
- `rows` x `columns` 不超过 `TileLogicalElementCapacity`。
- `TileGenericIndexingPermitted` 成立，这排除了 CUBE 布局。

设计要点：与 `TileDescriptorLegal` 不同，此检查还要求 `contents_defined`，因此调用者无需另行调用 `TileSourceContentsDefined` 即可获得已定义性测试。它没有谓词存储分支：它不测试 `storage_kind`，并始终应用数值型的 `TileShapeMatchesCapacity` 规则。

若 M、N 或 K 为 0，`TileMatrixMixedInfosMatchDimensions` 返回 FALSE。否则它要求：

- 左操作数通过 `TileCubeDescriptorLegal` 且已定义。
- 右操作数通过 `TileInfoDescriptorLegal`。
- 左有效区域为 M 乘 K，右有效区域为 K 乘 N。

在指令束路径中，这些谓词不是预检的关口：`ExecuteBundleTMATMULOperation` 在分配 D 之后才在一个 `assert` 中求值 `TileMatrixMixedInfosMatchDimensions`，因此任何会使其失败的指令束都必须已被更早的 Shared schema 与 Local 源检查拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-boundaries role=boundaries -->
## 架构边界

`TileInfoDescriptorLegal` 的使用者例如包括针对非 CUBE 操作数对与缩放 Tile 的矩阵形状检查。矩阵操作数检查中的 `TileMatrixInfoAccumulatorSchemaLegal` 也调用它，但该谓词在当前 ASL 中没有调用者。

`TileMatrixMixedInfosMatchDimensions` 被矩阵形状单元中的 `TileMatrixInfoOptionalScalesLegal` 使用；当 Shared 操作数的数量等于右操作数组计数，即只有右侧来自 Shared 存储时，CUBE TMATMUL 分派也使用它。

两个谓词都不把数据类型与操作类型比较，也不检查矩阵乘函数；普通类型列表属于矩阵形状单元，MX 类型列表属于矩阵函数单元。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-example role=example-usage -->
## 非规范阅读示例

考虑一次 M = 16、K = 32、N = 64 的矩阵乘，左操作数是 Local CUBE_M16 Tile，右操作数从 Shared Tile 物化得到。

- 左 CUBE Tile 必须通过 `TileCubeDescriptorLegal`、已定义，且有效区域为 16 乘 32。
- 右侧的值为 RowMajor，有效区域 32 乘 64。它必须已分配、已定义，且与容量相符。

若 K 为 0，检查在查看任何描述符之前就返回 FALSE。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-info-descriptor-related role=related-owners-navigation -->
## 相关所有者

- [矩阵形状](matrix-shape.md) 组合主操作数、混合与缩放形状检查。
- [矩阵 CUBE 主操作数](matrix-cube-primary.md) 负责全 CUBE 操作数对检查。
- [描述符形状](descriptor-shape.md) 负责 `TileCubeDescriptorLegal`。
- [Shared CUBE 矩阵](../../../block/model/dispatch/shared-cube-matrix.md) 物化 Shared 操作数。
- [CUBE TMATMUL 分派](../../../block/model/dispatch/cube-tmatmul.md) 选择操作数配对方式。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-info-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR","surface":"tile","classification":["model","legality","matrix-info-descriptor"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}

readonly func TileInfoDescriptorLegal(tile: TileInfo) => boolean
begin
    return tile.allocated && tile.contents_defined &&
           TileCapacityIsLegal(tile.capacity_bytes) &&
           TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
               tile.columns, tile.data_type) &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <=
               TileLogicalElementCapacity(tile.capacity_bytes,
                                          tile.data_type) &&
           TileGenericIndexingPermitted(tile);
end;

readonly func TileMatrixMixedInfosMatchDimensions(
    left: TileInfo, right: TileInfo,
    m: integer {0..65535}, n: integer {0..65535},
    k: integer {0..65535}) => boolean
begin
    if m == 0 || n == 0 || k == 0 then return FALSE; end;
    return TileCubeDescriptorLegal(left) && left.contents_defined &&
           TileInfoDescriptorLegal(right) &&
           left.valid_rows == m && left.valid_columns == k &&
           right.valid_rows == k && right.valid_columns == n;
end;
```
<!-- GENERATED-ASL-END: unit -->
