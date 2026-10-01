<!-- GENERATED FROM: asl/tile/model/shape/rows-columns.asl -->
# Rows Columns

**Normative ASL source:** `asl/tile/model/shape/rows-columns.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-purpose role=purpose-scope -->
## 用途与范围

本单元根据 Tile 的字节容量、列数和元素类型，决定它有多少个物理行。其他形状检查都建立在它之上。

它定义四个辅助函数：

- `IsNonzeroPowerOfTwo`，检查一个 16 位计数。
- `TileDataTypeAllowsOddPhysicalColumns`，列出可以使用非 2 的幂列数的类型。
- `DerivedTileRows` 和 `TileShapeMatchesCapacity`，推导并检查行数。

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-concepts role=concepts-state -->
## 概念与可见状态

容量（`capacity_bytes`，也称 TSize）是每 PE 的字节预算。它不是逻辑维度。对于 2 的幂列数，行数由它推导；对于被准入的奇数列数，它限制所存储的行数。

共有两种列配置档：

- 2 的幂列数，对每种类型都合法。除行配对的 E2M1X2 和 E1M2X2 外，Tile 必须恰好填满其容量。
- 其他正列数，只对 FP32、FP16、BF16 以及行配对打包类型 E2M1X2 和 E1M2X2 合法。此时容量是完整行存储的上界。

对于行配对形式的 E2M1X2 和 E1M2X2，每行存储 `(columns + 1) / 2` 字节，即加一后向下取整。奇数的最后一列仍然占用一整个字节。

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-rules role=rules-interactions -->
## 规则与交互

当容量或列数为 0，或者列数不是 2 的幂且类型未被准入时，`DerivedTileRows(capacity_bytes, columns, data_type)` 返回 0，表示“没有合法形状”。

否则：

1. 对行配对打包类型，行数为 `capacity_bytes / row_bytes`，向下取整。
2. 对其他类型，行数为 `capacity_bits / (columns x element_bits)`，向下取整。
3. 在 2 的幂列数下，第 2 步的余数非零时返回 0。
4. 结果为 0 或大于 65535 时返回 0。

随后 `TileShapeMatchesCapacity` 把存储的 `rows` 与推导值比较。2 的幂配置档要求相等。被准入的非 2 的幂配置档只要求 `rows <= derived_rows`。

设计要点：2 的幂配置档保持精确容量契约，因此行数完全由容量、列数和类型决定。如源注释所述，被准入的奇数配置档则使用能容纳的完整行，未用的容量作为描述符尾部保留。

设计要点：行配对存储是行内的。由于每行各自把字节数向上取整，奇数最后一列的填充永远不会与下一行共享字节。

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-boundaries role=boundaries -->
## 架构边界

这些辅助函数是纯函数。它们不检查有效区域、容量合法性或池空间；这些由有效区域所有者和分配所有者负责。

`HiF4X2`、`S4X2` 和 `U4X2` 是四位类型，但不是行配对的。它们遵循第 2 步的通用规则，并且必须使用 2 的幂列数。

65535 这个界限是 16 位行字段的宽度，而不是容量规则。

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-example role=example-usage -->
## 非规范阅读示例

| 容量 | 列数 | 类型 | 推导行数 | 原因 |
| --- | --- | --- | --- | --- |
| 4096 | 16 | FP32 | 64 | 32768 位 / 每行 512 位，无余数 |
| 4096 | 12 | FP32 | 85 | 32768 / 384 = 85，FP32 允许余数 |
| 4096 | 12 | S32 | 0 | 12 不是 2 的幂，且 S32 未被准入 |
| 128 | 5 | E2M1X2 | 42 | 每行存储 3 字节；128 / 3 = 42 |

对于第二行，存储的 `rows` 为 80 同样匹配，因为被准入的配置档只要求 `rows <= 85`。

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-related role=related-owners-navigation -->
## 相关所有者

- [有效区域](valid-region.md)在 `DerivedTileRows` 之上构建描述符和存储检查。
- [打包边界](../definedness/packed-boundary.md)定义 `PackedTileRowStorageBytes`。
- [描述符](../state/descriptors.md)提供 `TileElementBits`。
- [分配](../state/allocation.md)在推导行数与调用者给定的行数之间选择。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/rows-columns.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS","surface":"tile","classification":["model","shape","rows-columns"],"depends_on":["PTO-TILE-MODEL-STATE-DESCRIPTORS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY"]}
// Non-packed architectural Tile dimensions use exact powers of two. Packed-X2
// RowMajor dimensions retain their logical Col while deriving each row's
// storage from its row-local pair count.
pure func IsNonzeroPowerOfTwo(value: integer {0..65535}) => boolean
begin
    if value == 0 then return FALSE; end;
    var candidate: integer = 1;
    for exponent = 0 to 15 do
        if value == candidate then return TRUE; end;
        candidate = candidate * 2;
    end;
    return FALSE;
end;

pure func TileDataTypeAllowsOddPhysicalColumns(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           PackedTileDataTypeUsesRowLocalPairs(data_type);
end;

// TSize is a per-PE byte capacity. Legacy power-of-two-column descriptors use
// the exact full-capacity row count. Explicitly admitted odd ordinary profiles
// use the capacity as an upper bound: every positive row count whose complete
// row-local storage fits is representable. Zero means that no legal 16-bit row
// count exists for the supplied shape.
pure func DerivedTileRows(capacity_bytes: integer {0..262144},
                          columns: integer {0..65535},
                          data_type: TileDataType) => integer {0..65535}
begin
    if capacity_bytes == 0 || columns == 0 ||
       (!IsNonzeroPowerOfTwo(columns) &&
        !TileDataTypeAllowsOddPhysicalColumns(data_type)) then
        return 0;
    end;
    if PackedTileDataTypeUsesRowLocalPairs(data_type) then
        let row_bytes = PackedTileRowStorageBytes(
            columns as integer {1..65535}, data_type);
        let rows = capacity_bytes DIVRM row_bytes;
        if rows == 0 || rows > 65535 then return 0; end;
        return rows as integer {0..65535};
    end;
    let capacity_bits: integer = capacity_bytes * 8;
    let row_bits: integer = columns * TileElementBits(data_type);
    if row_bits == 0 then return 0; end;
    // Legacy power-of-two columns retain the exact capacity contract. The
    // explicitly admitted odd ordinary FP shapes use the complete rows that
    // fit, leaving unused capacity as the descriptor tail.
    if IsNonzeroPowerOfTwo(columns) && capacity_bits MOD row_bits != 0 then
        return 0;
    end;
    let rows: integer = capacity_bits DIVRM row_bits;
    if rows == 0 || rows > 65535 then return 0; end;
    return rows as integer {0..65535};
end;

pure func TileShapeMatchesCapacity(capacity_bytes: integer {0..262144},
                                   rows: integer {0..65535},
                                   columns: integer {0..65535},
                                   data_type: TileDataType) => boolean
begin
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    if derived_rows == 0 || rows == 0 then return FALSE; end;
    if !IsNonzeroPowerOfTwo(columns) &&
       TileDataTypeAllowsOddPhysicalColumns(data_type) then
        // DerivedTileRows is the floor of capacity/row-storage for the
        // admitted odd profiles, so this is equivalent to a complete-row
        // storage-fit check without creating a shape-module dependency cycle.
        return rows <= derived_rows;
    end;
    return rows == derived_rows;
end;
```
<!-- GENERATED-ASL-END: unit -->
