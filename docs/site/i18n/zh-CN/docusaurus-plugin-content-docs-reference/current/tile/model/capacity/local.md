<!-- GENERATED FROM: asl/tile/model/capacity/local.asl -->
# Local

**Normative ASL source:** `asl/tile/model/capacity/local.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-CAPACITY-LOCAL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-capacity-local-purpose role=purpose-scope -->
## 用途与范围

本单元度量 Local Tile 容量。它回答两个问题：每个 PE 的 Local 上限是多少，以及一个新的 Local 分配能否放入它所命名的每个 PE。

它定义 `TileCapacityLimitBytes`、每 PE 用量辅助函数、适配检查 `LocalTileAllocationFits` 和 `LocalTileAllocationFitsExcept`，以及整个 Core 的 Local 总量 `TileCapacityInUse`。

<!-- PTO-READER-BLOCK: tile-model-capacity-local-concepts role=concepts-state -->
## 概念与可见状态

上限是只读系统寄存器 `TILE_CAPACITY` 的值。`TileCapacityLimitBytes` 断言它不超过 `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`，即 262144 字节（256 KiB），复位时把该寄存器设为这个值。

每个 PE 都有自己的同样大小的 Local 池。一个 Local 对象向其分配掩码中置位的每个 PE 计入完整的 `capacity_bytes`。

这些辅助函数读取两部分状态：`_Tiles` 中的 `allocated` 标志和 `capacity_bytes`，以及 `_TileAllocationMasks` 中的掩码。掩码位通过 `PTOPEMaskBitOfPEIdentity` 映射到 PE，它把 PE0 放在最高位。

<!-- PTO-READER-BLOCK: tile-model-capacity-local-rules role=rules-interactions -->
## 规则与交互

`TileCapacityInUseForPE` 对掩码包含该 PE 的已分配寄存器的 `capacity_bytes` 求和。`Except` 变体跳过一个寄存器。

如果 `pe_mask` 中的任何 PE 在加上 `per_pe_bytes` 后会超过上限（忽略被排除寄存器的当前用量），`LocalTileAllocationFitsExcept(excluded, pe_mask, per_pe_bytes)` 返回 FALSE。`LocalTileAllocationFits` 执行同样的检查，但不排除任何寄存器。

设计要点：检查按 PE 进行，而不是按 Core 进行。一个 PE 的 Local 分配永远不会消耗另一个 PE 的池，因此程序可以填满 PE0 的 256 KiB 而不影响 PE3。

设计要点：分配转换使用 `Except` 形式，并以正在配置的寄存器作为排除项。因此重新配置一个寄存器会替换其旧的计入量，而不是把它计算两次。

`TileCapacityInUse` 用 `TileCoreAllocationBytes` 对整个 Core 求和，后者把每 PE 字节数乘以掩码中的 PE 数量。

<!-- PTO-READER-BLOCK: tile-model-capacity-local-boundaries role=boundaries -->
## 架构边界

本单元不限制单个对象的大小。128 字节粒度和 64 KiB 的单个 Local 对象上限由描述符单元中的 `TileCapacityIsLegal` 强制执行。若干个 Local 对象可以共同填满 256 KiB 的池。

Local 池和 Shared 池相互独立。Shared 池由另一个所有者度量。

`PTO_MODEL_MEMORY_AGENTS` 为 4，因此适配检查遍历 PE0 到 PE3。

<!-- PTO-READER-BLOCK: tile-model-capacity-local-example role=example-usage -->
## 非规范阅读示例

假设 PE0 和 PE1 各自已经持有三个以掩码 `1100` 分配的 64 KiB Local 对象。这两个 PE 各有 196608 字节在用。

- 一个掩码为 `1100` 的新 64 KiB 对象可以放入：196608 + 65536 = 262144，恰好等于上限。
- 第二个这样的对象放不下，因为在 PE0 和 PE1 上 262144 + 65536 都超过上限。
- 一个掩码为 `0011` 的 64 KiB 对象仍然可以放入，因为 PE2 和 PE3 的用量为 0 字节。

放入第一个新对象后，`TileCapacityInUse` 报告整个 Core 共 4 x 2 x 65536 = 524288 字节。

<!-- PTO-READER-BLOCK: tile-model-capacity-local-related role=related-owners-navigation -->
## 相关所有者

- [Shared 容量](shared.md)拥有独立的、覆盖整个 Core 的 Shared 池。
- [描述符](../state/descriptors.md)拥有对象大小规则 `TileCapacityIsLegal`。
- [分配](../state/allocation.md)在写入状态之前调用适配检查。
- [PE 掩码合法性](../legality/pe-mask.md)定义 `TileCoreAllocationBytes`。
- [Tile 分配功能](../../../arch/features/tile-allocation.md)规定架构池大小。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/capacity/local.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-CAPACITY-LOCAL","surface":"tile","classification":["model","capacity","local"],"depends_on":["PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func TileCapacityLimitBytes() => integer {0..262144}
begin
    assert UInt(_SystemRegisters.tile_capacity) <=
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    return UInt(_SystemRegisters.tile_capacity) as integer {0..262144};
end;

readonly func TileCapacityInUseExcept(excluded: TileIndex) => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TileAllocationMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseForPE(
    pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated &&
           _TileAllocationMasks[[index]][mask_bit] == '1' then
            total = total + _Tiles[[index]].capacity_bytes;
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseExceptForPE(
    excluded: TileIndex, pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated &&
           _TileAllocationMasks[[index]][mask_bit] == '1' then
            total = total + _Tiles[[index]].capacity_bytes;
        end;
    end;
    return total;
end;

readonly func LocalTileAllocationFitsExcept(
    excluded: TileIndex, pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        if pe_mask[mask_bit] == '1' &&
           TileCapacityInUseExceptForPE(excluded, pe) + per_pe_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func LocalTileAllocationFits(
    pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        if pe_mask[mask_bit] == '1' &&
           TileCapacityInUseForPE(pe) + per_pe_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileCapacityInUse() => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TileAllocationMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;
```
<!-- GENERATED-ASL-END: unit -->
