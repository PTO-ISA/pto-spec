---
{
  "id": "ADR-TILE-0003",
  "title": "Define explicit tile handoff slots",
  "title_zh": "定义显式 Tile 交接槽",
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
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-REQ-SHARED-TILE-001",
    "PTO-REQ-TILE-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0015"
  ]
}
---
# ADR-TILE-0003: Define explicit tile handoff slots

## Context

The direct tile catalog gives `TPUSH` and `TPOP` explicit destination and source
tile indices, but both operations previously copied the same complete
`TileInfo` record. That made the two mnemonics architecturally indistinguishable
and left source lifetime, full/empty behavior, ordering, and capacity effects
undefined.

PTO does not expose implementation pipe, semaphore, scheduler, or physical FIFO
state. The direct architecture therefore needs management semantics expressed
only through visible `TileInfo` allocations and instruction operands.

## Decision

- A tile index used as a handoff slot is ordinary visible `TileInfo` state; no
  hidden pipe state or implicit queue cursor is added.
- `TPUSH destination, source` publishes a complete, defined source tile into an
  unallocated destination slot. The source remains allocated and unchanged.
  The publication duplicates the allocation, so the resulting aggregate
  capacity must fit `TILE_CAPACITY`.
- `TPOP destination, source` consumes an allocated, defined source slot into an
  already configured destination with matching shape, valid region, type, and
  layout. It copies payload and element-definedness while retaining the
  destination descriptor, then releases the source slot.
- Source and destination must differ. Push to a full slot, pop from an empty
  slot, a mismatched pop, and self-aliasing are illegal before any effect.
- `TFREE destination` releases an allocated tile or handoff slot. Freeing an
  already free index is illegal.
- Slot selection and ordering are explicit in the tile-index operands and
  architectural program order. PTO defines no hidden FIFO order between
  different indices; software chooses and sequences the slots it uses.

Typed producer/consumer helpers may refine these direct operations with
implementation scheduling and transport behavior, but that evidence cannot add
portable hidden state or change the visible effects above.

## Consequences

`TPUSH` and `TPOP` are observably distinct. Producer lifetime, consumer
descriptor preservation, source-slot release, capacity duplication, full and
empty failures, alias rejection, and explicit multi-slot selection all have
decoded executable witnesses.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Producer-to-consumer Tile transfer needs visible capacity, descriptor, payload, occupancy, and lifetime state. An implicit queue cannot define which transfer fails when full, which slot is consumed, or how trap and retry preserve state.

生产者到消费者的 Tile 传递需要可见的容量、描述符、payload、占用和生命周期状态。隐式队列无法确定满时哪次传递失败、消费哪个槽，也无法定义陷阱与重试如何保留状态。

### Detailed decision / 详细决策

Tile handoff uses explicit selectable slots. `TPUSH` snapshots a valid source into an available slot under capacity and alias checks; `TPOP` reads a selected occupied slot into a destination and releases the source slot only on successful publication. Full, empty, duplicate, and invalid-alias cases reject before state changes.

Tile 交接使用显式可选择槽。`TPUSH` 在容量和别名检查通过后把有效源快照到空闲槽；`TPOP` 把所选已占用槽读取到目的，并仅在成功发布后释放源槽。满、空、重复和非法别名情况均在状态改变前拒绝。

### What changed / 改动内容

#### English

- Replaced implicit handoff behavior with explicit architectural slots.
- Closed occupancy, capacity, alias, publication, and release behavior for push/pop.

#### 中文

- 以显式架构槽替代隐式交接行为。
- 闭合 push/pop 的占用、容量、别名、发布和释放行为。

### Scope and boundaries / 范围与边界

The ADR governs handoff state and transfer atomicity. It does not create body-local queues, replay state, or operation-specific computation semantics.

本 ADR 管理交接状态与传递原子性；不创建 Body 本地队列、重放状态或操作特定计算语义。
