<!-- GENERATED FROM: asl/tile/model/memory/stride.asl -->
# Stride

**Normative ASL source:** `asl/tile/model/memory/stride.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-STRIDE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-stride-purpose role=purpose-scope -->
## 作用与范围

本单元拥有 Tile 转移的带行步长 GM 寻址。行步长是内存中一行 Tile 的起点到下一行起点之间的距离。

它定义四个辅助函数：

- `TileMemoryStridedByteAddress` 根据字节行步长计算 `(row, column)` 的字节地址。
- `TileMemoryStridedByteHighNibble` 为四位类型选择半字节。
- `TileDenseRowStrideBytes` 计算以字节计的密集行宽。
- `TileMemoryStridedIndex` 根据以元素计的行步长计算元素索引。

<!-- PTO-READER-BLOCK: tile-model-memory-stride-concepts role=concepts-state -->
## 概念与可见状态

本单元中有两种步长单位，不能混用。

- 字节行步长（`row_stride_bytes`）由 `TLOAD`、`TSTORE` 以及 Shared 转移辅助函数使用。
- 元素行步长（`row_stride_elements`）由 `TPREFETCH` 通过 `TileMemoryStridedIndex` 使用，其结果随后由 `TileMemoryIndexedAddress` 缩放。

四位类型（E2M1X2、E1M2X2、HiF4X2、S4X2、U4X2）每字节打包两个元素。它的行基址仍是整字节；列在行内选择一个字节和一个半字节。

<!-- PTO-READER-BLOCK: tile-model-memory-stride-rules role=rules-interactions -->
## 规则与交互

对非四位类型，`TileMemoryStridedByteAddress` 返回 `base + row * row_stride_bytes + column * TileElementBytes(data_type)`。

对四位类型，它返回 `base + row * row_stride_bytes + column / 2`（向下取整）。对四位类型的奇数列，`TileMemoryStridedByteHighNibble` 为 TRUE，否则为 FALSE。

`TileDenseRowStrideBytes` 对非四位类型返回 `columns * TileElementBytes(data_type)`，对四位类型返回向下取整的 `(columns + 1) / 2`。当 `B.IOR` 被省略时，块操作数解析器以解析后的物理列数调用它，作为 `TLOAD` 与 `TSTORE` 的行步长。

`TileMemoryStridedIndex` 返回 `row * row_stride_elements + column`。所有乘积与求和都使用 `Word` 运算，按模 2^64 回绕。

设计要点：字节行步长按字节相加，不会再乘一次元素大小（ADR-MEM-0008 记录了这一决定）。其结果是可以表达不是元素大小整数倍的行间距。这样的地址是否合法，由随后 load-store 单元中的对齐探测决定。

设计要点：四位行从字节边界开始。物理列数为奇数时，密集步长向上取整，因此一行最后一个字节中未使用的高半字节不属于下一行。

<!-- PTO-READER-BLOCK: tile-model-memory-stride-boundaries role=boundaries -->
## 架构边界

这些辅助函数只计算地址。它们不探测、不产生故障，也不记录内存事件。

省略 `B.IOR` 与编码零寄存器不同：编码的零选择器读取零 GPR，给出真实的步长 0，因此每一行都访问同一段内存。只有省略才选择密集默认值。`B.IOR` 的译码由块操作数解析器拥有，而不是本单元。

`TPREFETCH` 保留以元素计数的步长。当它的 `B.IOR` 被省略时，预取分派器以物理列数作为元素步长。

<!-- PTO-READER-BLOCK: tile-model-memory-stride-example role=example-usage -->
## 非规范阅读示例

FP16 的 `TLOAD`，基地址 `0x1000`，`row_stride_bytes = 64`，读取元素 `(2, 3)` 的地址为 `0x1000 + 2 x 64 + 3 x 2 = 0x1000 + 128 + 6 = 0x1086`。

物理列数为 5 的 U4X2 Tile，密集步长为 `(5 + 1) / 2 = 3` 字节。从基地址 `0x2000` 起，元素 `(1, 3)` 位于 `0x2000 + 1 x 3 + 3 / 2 = 0x2004`，因为第 3 列是奇数，所以位于高半字节。

对 5 列的 FP16，密集步长为 `5 x 2 = 10` 字节。

<!-- PTO-READER-BLOCK: tile-model-memory-stride-related role=related-owners-navigation -->
## 相关归属

- [Addressing](addressing.md) 拥有按元素缩放的地址与字节位移地址。
- [Load and store](load-store.md) 拥有使用字节行步长的 `TLOAD` 与 `TSTORE`。
- [Gather and scatter](gather-scatter.md) 拥有使用元素行步长的 `TPREFETCHCore`。
- [Shared movement](shared-movement.md) 拥有使用每 PE 字节步长的 Shared 转移。
- [TLOAD](../../memory-and-data-movement/regular/TLOAD.md) 给出指令级的步长默认值。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/stride.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-STRIDE","surface":"tile","classification":["model","memory","stride"],"depends_on":["PTO-TILE-MODEL-MEMORY-ADDRESSING"]}
readonly func TileMemoryStridedIndex(row: integer {0..65535},
                                     column: integer {0..65535},
                                     row_stride_elements: Word) => Word
begin
    return MultiplyWord(NaturalToWord(row as integer {0..262144}),
                        row_stride_elements) +
           NaturalToWord(column as integer {0..262144});
end;

pure func TileDenseRowStrideBytes(columns: integer {0..65535},
                                  data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let packed_bytes = ((columns + 1) DIVRM 2) as integer {0..32768};
        return NaturalToWord(packed_bytes as integer {0..262144});
    else
        return MultiplyWord(
            NaturalToWord(columns as integer {0..262144}),
            NaturalToWord(TileElementBytes(data_type) as
                integer {0..262144}));
    end;
end;

readonly func TileMemoryStridedByteAddress(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    let row_base = base_address + MultiplyWord(
        NaturalToWord(row as integer {0..262144}), row_stride_bytes);
    if TileDataTypeIsFourBit(data_type) then
        return row_base + NaturalToWord(
            (column DIVRM 2) as integer {0..262144});
    else
        return row_base + MultiplyWord(
            NaturalToWord(column as integer {0..262144}),
            NaturalToWord(TileElementBytes(data_type) as
                integer {0..262144}));
    end;
end;

pure func TileMemoryStridedByteHighNibble(
    column: integer {0..65535}, data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && column MOD 2 == 1;
end;
```
<!-- GENERATED-ASL-END: unit -->
