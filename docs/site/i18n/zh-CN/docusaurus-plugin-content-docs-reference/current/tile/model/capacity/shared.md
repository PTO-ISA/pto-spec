<!-- GENERATED FROM: asl/tile/model/capacity/shared.asl -->
# Shared

**Normative ASL source:** `asl/tile/model/capacity/shared.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-CAPACITY-SHARED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-capacity-shared-purpose role=purpose-scope -->
## 用途与范围

本单元衡量 Core 范围的 Shared Tile 池并报告合计 Tile 用量。`SharedTileCapacityCharge` 单独计算一个 Shared 寄存器的计费，使分配、替换、源回收和开放组装采用同一套记账。

- `SharedTileCapacityInUse` 汇总每个寄存器的计费。
- `SharedTileCapacityCharge` 比较存活载荷与待发布父对象预约。
- `SharedTileCapacityLimitBytes` 给出独立的 Shared 上限。
- `CoreTileCapacityInUse` 报告 Local 与 Shared 用量之和。

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-concepts role=concepts-state -->
## 概念与可见状态

Shared Tile 寄存器是 `_SharedTiles` 中 S0 到 S63 之一。它属于 Core 而不属于某个 PE，全部四个 PE 寻址同一组 64 条记录。

有效描述符本身不产生载荷容量计费。计费取存活载荷字节数与开放组装的 `reserved_capacity_bytes` 较大值。因此，消费旧载荷不会把待发布父对象的预约空间借给另一个 Shared 寄存器。

上限为 `PTO_SHARED_TILE_MAX_ALLOCATION_BYTES`，即 262144 字节（256 KiB）。

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-rules role=rules-interactions -->
## 规则与交互

Shared 寄存器单元中的 `SharedTileUpdateCompatible` 使用这些辅助函数。当目标寄存器尚无描述符时，只有当前 Shared 用量加上新容量仍不超过 `SharedTileCapacityLimitBytes`，更新才被接受。

设计要点：无论有多少 PE 参与，一个 Shared 父级只计费一次。Shared 记录的分配掩码控制的是参与，而不是计费，因此一个 256 KiB 的四 PE Shared 父级恰好占满整个 Shared 池。

设计要点：Shared 池与 Local 池相互独立。`SharedTileCapacityInUse` 只读取 `_SharedTiles`，而 Local 适配检查只读取 Local 寄存器状态和 `TILE_CAPACITY` 上限，因此任何一种分配都不会因另一种分配而失败。

`CoreTileCapacityInUse` 是 `TileCapacityInUse` 与 `SharedTileCapacityInUse` 的报告性求和。由于 Local 用量乘以每个掩码中的 PE 数，而 Shared 用量不乘，该和就是整个 Core 上持有的总字节数。

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-boundaries role=boundaries -->
## 架构边界

该上限是固定的。与 Local 上限不同，它不读取 `TILE_CAPACITY` 系统寄存器。

对象合法性（包括 128 字节粒度）由描述符单元中的 `SharedTileCapacityIsLegal` 检查。本单元只对用量求和。

`CoreTileCapacityInUse` 不是合法性检查：没有任何分配会把它与一个合并预算比较。

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-example role=example-usage -->
## 非规范阅读示例

S4 有存活的 128 KiB 载荷，S9 有存活的 64 KiB 载荷，初始计费为 196608 字节。若 S4 开启同容量组装，其计费仍为 128 KiB。即使回收 S4 的旧源，该预约仍持续计费，直到发布或中止。

- 在空寄存器中新建一个 64 KiB Shared 父级可以容纳：196608 + 65536 = 262144。
- 新建一个 128 KiB 父级无法容纳，因为总和将为 327680。
- 更新 S4 本身不会再次计费，因为其描述符已经存在；此时更新必须与现有描述符兼容。

<!-- PTO-READER-BLOCK: tile-model-capacity-shared-related role=related-owners-navigation -->
## 相关所有者

- [Local 容量](local.md)拥有每 PE 的 Local 池。
- [Shared 寄存器](../state/shared-registers.md)在更新时调用 Shared 上限。
- [描述符](../state/descriptors.md)拥有 `SharedTileCapacityIsLegal`。
- [Shared Tile 状态](../../../arch/features/shared-tile-state.md)给出架构层面的 Shared 模型。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/capacity/shared.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-CAPACITY-SHARED","surface":"tile","classification":["model","capacity","shared"],"depends_on":["PTO-TILE-MODEL-CAPACITY-LOCAL"]}
readonly func SharedTileCapacityInUse() => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_SHARED_TILE_COUNT - 1 do
        total = total + SharedTileCapacityCharge(
            (Zeros{6} + index) as SharedTileID);
    end;
    return total;
end;

readonly func SharedTileCapacityCharge(shared_tile_id: SharedTileID) => integer
begin
    let index = UInt(shared_tile_id) as SharedTileIndex;
    let live_bytes = if _SharedTiles[[index]].descriptor_valid &&
        _SharedTiles[[index]].payload_live then
        _SharedTiles[[index]].tile.capacity_bytes else 0;
    let reserved_bytes = _SharedTiles[[index]].reserved_capacity_bytes;
    return if live_bytes > reserved_bytes then live_bytes else reserved_bytes;
end;

pure func SharedTileCapacityLimitBytes() => integer
begin
    return PTO_SHARED_TILE_MAX_ALLOCATION_BYTES;
end;

readonly func CoreTileCapacityInUse() => integer
begin
    return TileCapacityInUse() + SharedTileCapacityInUse();
end;
```
<!-- GENERATED-ASL-END: unit -->
