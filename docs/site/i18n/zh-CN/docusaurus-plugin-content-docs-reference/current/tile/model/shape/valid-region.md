<!-- GENERATED FROM: asl/tile/model/shape/valid-region.asl -->
# Valid Region

**Normative ASL source:** `asl/tile/model/shape/valid-region.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-VALID-REGION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-purpose role=purpose-scope -->
## 用途与范围

本单元检查 Tile 的有效区域和物理存储是否符合其容量。它还查找能够表示所请求形状的最小 SizeCode 容量。

有效区域是位于物理 `rows` 乘 `columns` 形状左上角的 `valid_rows` 乘 `valid_columns` 矩形。操作在有效区域上计算；物理形状的其余部分是填充。

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-concepts role=concepts-state -->
## 概念与可见状态

本单元定义五个辅助函数：

- `TileDescriptorShapeLegal` 在推导行数下检查所请求的形状。
- `TileDescriptorPhysicalShapeLegal` 检查已存储的物理形状。
- `TileStorageBytes` 计算物理形状的存储量。
- `TileStorageFitsCapacity` 把该存储量与容量比较。
- `MinimumTileCapacityBytesForShape` 搜索 SizeCode 1 到 12。

存储计量按位打包。两个四位元素占一个字节，奇数的最后一个元素向上取整。行配对的 E2M1X2 和 E1M2X2 则对每一行分别向上取整。

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-rules role=rules-interactions -->
## 规则与交互

`TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows, valid_columns, data_type)` 在以下条件下成立：

- `DerivedTileRows` 非零。
- `valid_rows` 不超过推导行数，且 `valid_columns` 不超过 `columns`。
- `valid_rows x valid_columns` 不超过逻辑元素容量。

`TileDescriptorPhysicalShapeLegal` 加入已存储的 `rows`：形状必须按行列规则与容量匹配，有效区域必须位于其内，且 `TileStorageBytes` 不得超过容量。

设计要点：Shared 源可以不带大小而被命名。源注释说明源形式的 `B.IOS` 携带 SizeCode 0。当所选 Shared 寄存器没有描述符时，消费者用 `MinimumTileCapacityBytesForShape` 推导能表示其形状的最小容量，该函数返回第一个通过 `TileDescriptorShapeLegal` 的 SizeCode 字节值。结果为 0 表示 128 B 到 256 KiB 之间没有能容纳的大小。

设计要点：物理检查独立于行数推导来度量存储。对于被准入的奇数列数，允许行数少于推导的最大值，而存储检查确认这些行仍然能够容纳。

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-boundaries role=boundaries -->
## 架构边界

这些辅助函数不检查容量合法性或池空间，也不适用于 CUBE 布局；CUBE 布局有自己的几何所有者。

`MinimumTileCapacityBytesForShape` 搜索完整的 1 到 12 范围。其结果对 Local 或 Shared 角色是否合法，由调用者决定。

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-example role=example-usage -->
## 非规范阅读示例

一次 Shared 读取请求 32 列 FP16，有效区域为 20 乘 30。

- 128 字节：推导行数为 1024 / 512 = 2，少于 20 个有效行。拒绝。
- 256 和 512 字节分别得到 4 和 8 行。拒绝。
- 1024 字节得到 16 行。拒绝。
- 2048 字节得到 32 行。20 不超过 32，30 不超过 32，且 600 个元素不超过 1024。接受。

`MinimumTileCapacityBytesForShape` 返回 2048。

就存储而言，16 乘 8 的 U4X2 Tile 需要 16 x 8 x 4 = 512 位，即 64 字节。16 乘 5 的行配对 E2M1X2 Tile 需要 16 x 3 = 48 字节，因为每行向上取整到完整的配对。

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-related role=related-owners-navigation -->
## 相关所有者

- [行与列](rows-columns.md)拥有 `DerivedTileRows` 和 `TileShapeMatchesCapacity`。
- [CUBE 单元格几何](cube-cell.md)拥有 CUBE 形状规则。
- [Shared 寄存器](../state/shared-registers.md)对不带大小的 Shared 读取使用最小容量搜索。
- [分配](../state/allocation.md)断言两项形状检查。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/valid-region.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-VALID-REGION","surface":"tile","classification":["model","shape","valid-region"],"depends_on":["PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS"]}
readonly func TileDescriptorShapeLegal(capacity_bytes: integer {0..262144},
                                   columns: integer {0..65535},
                                   valid_rows: integer {0..65535},
                                   valid_columns: integer {0..65535},
                                   data_type: TileDataType) => boolean
begin
    let rows = DerivedTileRows(capacity_bytes, columns, data_type);
    return rows != 0 && valid_rows <= rows && valid_columns <= columns &&
           valid_rows * valid_columns <=
               TileLogicalElementCapacity(capacity_bytes, data_type);
end;

// A source-form B.IOS carries SizeCode=0. When the selected Shared register has
// no descriptor, the consuming operation derives the smallest architectural
// per-PE capacity that can represent its completed schema.  Zero reports that
// no 128 B through 256 KiB Shared Tile size can represent the requested shape.
readonly func MinimumTileCapacityBytesForShape(
    columns: integer {0..65535}, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, data_type: TileDataType)
    => integer {0..262144}
begin
    for size_code = 1 to 12 do
        let capacity_bytes = TileSizeCodeBytes(
            size_code as integer {1..12});
        if TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
               valid_columns, data_type) then
            return capacity_bytes;
        end;
    end;
    return 0;
end;

pure func TileStorageBytes(rows: integer {0..65535},
                           columns: integer {0..65535},
                           data_type: TileDataType) => integer
begin
    // Packed-X2 rows reserve a complete final byte for an odd logical column,
    // so row padding is not shared across row boundaries.
    if PackedTileDataTypeUsesRowLocalPairs(data_type) then
        if columns == 0 then return 0; end;
        return rows * PackedTileRowStorageBytes(
            columns as integer {1..65535}, data_type);
    end;
    // Capacity accounting is bit-packed. In particular, two four-bit
    // elements occupy one byte and an odd final element rounds up.
    return ((rows * columns * TileElementBits(data_type)) + 7) DIVRM 8;
end;

pure func TileStorageFitsCapacity(rows: integer {0..65535},
                                  columns: integer {0..65535},
                                  data_type: TileDataType,
                                  capacity_bytes: integer {0..262144})
    => boolean
begin
    return TileStorageBytes(rows, columns, data_type) <= capacity_bytes;
end;

readonly func TileDescriptorPhysicalShapeLegal(
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535}, columns: integer {0..65535},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileShapeMatchesCapacity(capacity_bytes, rows, columns, data_type) &&
           valid_rows <= rows && valid_columns <= columns &&
           valid_rows * valid_columns <=
               TileLogicalElementCapacity(capacity_bytes, data_type) &&
           TileStorageFitsCapacity(rows, columns, data_type, capacity_bytes);
end;
```
<!-- GENERATED-ASL-END: unit -->
