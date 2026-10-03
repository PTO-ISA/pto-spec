<!-- GENERATED FROM: asl/tile/model/memory/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/tile/model/memory/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-addressing-purpose role=purpose-scope -->
## 作用与范围

本单元拥有纯地址运算：把 Tile 元素或索引值转换为全局内存（GM）字节地址。它本身不执行访问、探测或故障。

它定义三类辅助函数：

- 元素大小辅助函数：`TileMemoryElementBytes` 给出一个元素在内存中的访问宽度。
- 缩放索引辅助函数：`TileMemoryElementAddress` 与 `TileMemoryIndexedAddress` 把元素编号乘以元素宽度。
- 字节位移辅助函数：`TileIndexByteDisplacement` 与 `TileMemoryByteDisplacementAddress` 把索引值作为原始字节数加到基地址上。

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-concepts role=concepts-state -->
## 概念与可见状态

基地址是一个 XLEN `Word`，通常读取自 `B.IOR` 选择的 GPR。所有地址求和都使用 `Word` 运算，因此按模 2^64 回绕。

四位类型是 E2M1X2、E1M2X2、HiF4X2、S4X2 与 U4X2 之一（`TileDataTypeIsFourBit`）。两个这样的元素共享一个字节。对这些类型，`TileMemoryElementBytes` 返回 1，因为内存以整字节访问；`TileInfo` 的容量仍按打包方式计数。

半字节选择器说明元素使用该字节的哪一半。对奇数元素编号或奇数索引，`TileMemoryElementHighNibble` 与 `TileMemoryIndexedHighNibble` 返回 TRUE；对非四位类型总是返回 FALSE。

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-rules role=rules-interactions -->
## 规则与交互

缩放寻址：对非四位类型，偏移为 `element * TileElementBytes(data_type)`。对四位类型，偏移为元素编号除以 2（向下取整），最低位选择半字节。`TileMemoryIndexedAddress` 对索引字使用此规则；`TPREFETCHCore` 以 `TileMemoryStridedIndex` 给出的带步长元素索引调用它。

字节位移寻址：`TileIndexByteDisplacement` 按索引整数类型的宽度读取索引。有符号类型（S4X2、S8、S16、S32）做符号扩展，无符号类型（U4X2、U8、U16、U32）做零扩展，S64 与 U64 原样使用。结果不经缩放直接加到基地址。非整数索引类型使断言失败。

索引 TLSU 形式（`MGATHER`、`MSCATTER` 及其 MASK 形式、`MGATHER_CAS` 以及 GM atom/red 族）使用字节位移规则。它们的操作数合法性只接受 S32、U32、S64 与 U64 索引 Tile（`IndexedTLSUMemoryIndexDataTypeLegal`）；`TileIndexByteDisplacement` 中更窄的分支无法通过该合法性到达。

设计要点：NDF `PTO-INDEXED-TLSU-STRIDE-001` 要求索引 TLSU 把每个索引视为字节位移，并禁止对其缩放、按 `ValidCol` 分解或施加隐式行步长。其结果是同一个索引 Tile 可以寻址任意宽度的元素，而软件必须自行乘以元素大小。如果得到的地址不是元素宽度的整数倍，随后的探测会报告对齐故障。

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-boundaries role=boundaries -->
## 架构边界

这些辅助函数只计算地址。对齐、权限与范围检查发生在 load-store 单元的 `ProbeTileMemoryAccess` 中，它以 `TileMemoryElementBytes` 给出的宽度进行探测。

密集 `TLOAD` 与 `TSTORE` 的行地址不使用这些辅助函数；它们使用 stride 单元中的字节行步长。

在当前 ASL 中，`TileMemoryElementAddress`、`TileMemoryElementHighNibble` 与 `TileMemoryIndexedHighNibble` 在本单元之外没有调用者。

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-example role=example-usage -->
## 非规范阅读示例

取基地址 `0x1000`，以及一个低 32 位为 `0xFFFFFFF8` 的索引元素。

- 作为 S32 索引，`TileIndexByteDisplacement` 将其符号扩展为 -8，因此地址为 `0x1000 - 8 = 0xFF8`。
- 作为 U32 索引，它做零扩展，因此地址为 `0x1000 + 0xFFFFFFF8 = 0x100000FF8`。

再取 `TileMemoryIndexedAddress`，基地址 `0x2000`，索引 5。

- 对 FP16，偏移为 5 x 2 = 10 字节，因此地址为 `0x200A`。
- 对 U4X2，偏移为 5 / 2 = 2 字节，因此地址为 `0x2002`；索引位 0 为 1，所以该元素是高半字节。

<!-- PTO-READER-BLOCK: tile-model-memory-addressing-related role=related-owners-navigation -->
## 相关归属

- [Stride](stride.md) 拥有 `TLOAD`、`TSTORE` 与 `TPREFETCH` 的带行步长地址。
- [Load and store](load-store.md) 拥有探测以及字节级加载与存储辅助函数。
- [Gather and scatter](gather-scatter.md) 与 [GM atom/red execution](gm-atom-red-execution.md) 是字节位移的使用者。
- [Indexed layout legality](../legality/indexed-layout.md) 拥有可接受的索引类型。
- [Global memory access](../../../arch/memory-model/global-memory-access.md) 拥有 GM 地址空间。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ADDRESSING","surface":"tile","classification":["model","memory","addressing"],"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}
// NDF-BEGIN: PTO-INDEXED-TLSU-STRIDE-001
// ndf: kind=executable level=L3 layer=tile status=accepted
// Indexed TLSU MUST interpret S32, U32, S64, and U64 IndexTile elements as
// byte displacements. Signed values MUST sign-extend and unsigned values MUST
// zero-extend before addition to BaseGPR. Indexed TLSU MUST NOT scale the
// displacement, decompose it by ValidCol, or consume an implicit row stride.
// NDF-END: PTO-INDEXED-TLSU-STRIDE-001
pure func TileMemoryElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    // PTO-v0 TLSU exposes four-bit elements through byte-sized containing
    // accesses. Tile capacity remains packed in TileInfo.
    if TileDataTypeIsFourBit(data_type) then return 1;
    else return TileElementBytes(data_type);
    end;
end;

readonly func TileMemoryElementAddress(base_address: Word,
                                       element: ModelTileElementIndex,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let offset = (element DIVRM 2) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    else
        let element_bytes = TileElementBytes(data_type);
        let offset = (element * element_bytes) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    end;
end;

readonly func TileMemoryIndexedAddress(base_address: Word,
                                       index_value: Word,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        return base_address + ZeroExtend{PTO_XLEN}(index_value[63:1]);
    else
        let element_bytes = TileElementBytes(data_type);
        let byte_width = NaturalToWord(element_bytes as integer {0..262144});
        return base_address + MultiplyWord(index_value, byte_width);
    end;
end;

readonly func TileMemoryElementHighNibble(element: ModelTileElementIndex,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && element MOD 2 == 1;
end;

readonly func TileMemoryIndexedHighNibble(index_value: Word,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && index_value[0] == '1';
end;

pure func TileIndexByteDisplacement(index_value: Word,
                                    index_data_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(index_data_type);
    case index_data_type of
        when TileDataType_S4X2 =>
            return SignExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_S8 =>
            return SignExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_S16 =>
            return SignExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_S32 =>
            return SignExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_S64 => return index_value;
        when TileDataType_U4X2 =>
            return ZeroExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_U8 =>
            return ZeroExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_U16 =>
            return ZeroExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_U32 =>
            return ZeroExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_U64 => return index_value;
        otherwise => unreachable;
    end;
end;

pure func TileMemoryByteDisplacementAddress(
    base_address: Word, index_value: Word,
    index_data_type: TileDataType) => Word
begin
    return base_address +
        TileIndexByteDisplacement(index_value, index_data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
