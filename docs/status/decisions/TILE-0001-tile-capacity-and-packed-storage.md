---
{
  "id": "ADR-TILE-0001",
  "title": "Define tile capacity and packed storage",
  "title_zh": "定义 Tile 容量与紧凑存储",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-REQ-SHARED-TILE-001",
    "PTO-REQ-TILE-001",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-STATE-TILE-DESCRIPTOR",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0013"
  ]
}
---
# ADR-TILE-0001: Define tile capacity and packed storage

## Decision scope

The minimum-allocation clause is superseded by
[ADR 0054](BLOCK-0004-pe-local-tile-size-and-32-bit-shared-io-binding.md).
ADR 0054 defines the current per-PE TSize map: codes 1 through 7 represent
128 bytes through 8 KiB. The capacity-accounting, packed-storage, precision,
and rollback decisions below remain current.

## Context

`TileInfo` records an allocation capacity independently from the bounded ASL
payload used for executable verification. The previous model treated zero as
both a legal capacity and a release request, and it did not prove that the
declared shape fit in the allocation. It also counted four-bit formats as one
byte per element because each model payload slot uses a 64-bit carrier. Those
choices confused architectural storage with model representation.

The direct `TALLOC` form must reject an illegal descriptor before changing the
old destination. `TFREE` needs a distinct release transition so zero capacity
cannot be mistaken for an active allocation.

## Decision

- An active tile allocation has a capacity from 128 bytes through the current
  `TILE_CAPACITY` value, inclusive. Zero is never an active capacity.
- `TFREE` invokes a separate release transition. Release clears allocation,
  definedness, capacity, shape, valid region, data type, layout, and location
  descriptor state; it does not need a zero-capacity `TALLOC` surrogate.
- The sum of all active allocation capacities cannot exceed `TILE_CAPACITY`.
  Reconfiguration replaces the destination's prior contribution before the
  new capacity is checked.
- Shape storage is `ceil(rows * columns * element_bits / 8)` bytes. Four-bit
  formats use four bits per element for this calculation, including rounding
  an odd final element up to a whole byte. Other formats use their declared
  8-, 16-, 32-, or 64-bit width.
- A legal allocation has positive shape dimensions, a valid region contained
  by that shape, architectural storage no larger than its capacity, and a
  shape representable by the selected executable-model bound.
- Decoded allocation and tile-copy management operations perform every
  capacity check before their first descriptor or payload effect.

This decision defines descriptor storage accounting. It does not silently
choose the byte-addressing or packing protocol for sub-byte tile-memory
transfers; that instruction-level rule remains a separate TLSU closure item.

## Consequences

Zero, below-128-byte-minimum, shape overflow, and aggregate overflow are
tile-legality faults with the previous destination preserved. The 128-byte
minimum, maximum, exact-fit, reconfiguration, and release boundaries have
executable witnesses. The ASL payload carrier width remains verification
infrastructure and no longer determines architectural capacity for four-bit
formats.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Tile capacity is architectural, while the ASL payload carrier is a bounded verification mechanism. Conflating the two made four-bit packed formats depend on model storage width and obscured exact-fit, reconfiguration, and release behavior.

Tile 容量属于架构，而 ASL payload 载体只是有界验证机制。混淆两者会使四位紧凑格式依赖模型存储宽度，并模糊恰好装满、重新配置和释放行为。

### Detailed decision / 详细决策

Each Local Tile register has an explicit per-PE architectural capacity selected through the accepted size contract. Elements are packed according to their architectural bit width, including four-bit values, rather than one model slot per element. Descriptor shape and packed payload must fit the selected capacity before allocation or reconfiguration publishes.

每个 Local Tile 寄存器都具有由已接受大小契约选择的显式每 PE 架构容量。元素按照架构位宽紧凑存储，包括四位值，而不是每个元素占用一个模型槽。描述符形状与紧凑 payload 必须在分配或重配置发布前适配所选容量。

### What changed / 改动内容

#### English

- Separated architectural Tile capacity from the ASL carrier bound.
- Defined packed-capacity checks for all supported element widths.

#### 中文

- 分离架构 Tile 容量与 ASL 载体边界。
- 为所有受支持元素宽度定义紧凑容量检查。

### Scope and boundaries / 范围与边界

This ADR governs capacity accounting and packed storage. It does not define operation-specific shapes, arithmetic, or aggregate Shared allocation, and it does not claim that the ASL carrier bound is an implementation limit.

本 ADR 管理容量核算与紧凑存储；不定义操作特定形状、算术或 Shared 聚合分配，也不把 ASL 载体边界解释为实现限制。
