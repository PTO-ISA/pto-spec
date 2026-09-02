---
{
  "id": "ADR-TILE-0002",
  "title": "Track tile definedness per element",
  "title_zh": "逐元素跟踪 Tile 已定义性",
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
    "PTO-REQ-TILE-001"
  ],
  "affected_units": [
    "PTO-ARCH-STATE-DEFINEDNESS",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0014"
  ]
}
---
# ADR-TILE-0002: Track tile definedness per element

## Context

Allocation deliberately leaves tile payload undefined. A single
`contents_defined` flag previously changed to true after any element write,
which made every other element in the valid region readable. Whole-tile
arithmetic, reductions, and payload-dependent legality checks could therefore
observe carrier values that no architectural operation had produced.

The architecture needs both element-precise reads and an efficient legality
predicate for operations that consume an entire valid region.

## Decision

- Every `TileInfo` has one definedness bit for each executable-model payload
  element and a count of defined elements in its current valid region.
- `contents_defined` is the maintained summary that every element of the valid
  region is defined. It is not an independent source of truth.
- An element write defines only its addressed element. Rewriting an already
  defined element does not increment the valid-region count.
- A generic element read requires the selected element's definedness bit. It
  does not gain access to sibling elements merely because one write occurred.
- Operations that overwrite their complete destination valid region mark that
  region defined after all payload effects. Partial update operations require
  the untouched destination region to be defined before execution.
- Decoded operations that consume a whole source valid region reject an
  incomplete source before the first destination effect. Payload-dependent
  legality checks likewise fail closed on incomplete inputs.
- Allocation, reconfiguration, release, and reset clear all element
  definedness and the valid-region count. Descriptor-and-payload copies carry
  the corresponding definedness state.

Elements outside the valid region remain unobservable unless an operation
explicitly defines and addresses them. Such writes set their element bit but do
not contribute to the valid-region summary.

## Consequences

One-element initialization can be tested without accidentally defining a
whole tile. Reductions and other whole-region consumers cannot expose unwritten
payload. The ASL model retains `contents_defined` for concise dispatch
legality, but its value is now derived and covered by per-element regression
tests.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

A single whole-Tile defined flag cannot represent partial writes, Null padding, or consumers that require only a valid region. It can accidentally expose unwritten payload or mark initialized elements undefined.

单一整 Tile 已定义标志无法表示部分写入、Null padding 或只要求有效区域的消费者，可能意外暴露未写 payload，或把已初始化元素标记为未定义。

### Detailed decision / 详细决策

Definedness is tracked per architectural element. Writers publish defined bits only for elements they actually define; padding and partial updates preserve or clear element state according to the owning operation. Consumers validate exactly the region they read. The aggregate `contents_defined` value is derived for dispatch convenience rather than serving as the source of truth.

已定义性按架构元素跟踪。写入者只为实际定义的元素发布 defined bit；padding 与部分更新按照所属操作保留或清除元素状态。消费者只验证其读取区域。聚合 `contents_defined` 仅为 dispatch 便利而派生，不再是事实来源。

### What changed / 改动内容

#### English

- Replaced whole-Tile definedness ownership with per-element state for every architecture-visible payload location.
- Made consumer legality depend on the exact region read instead of unrelated elements elsewhere in the Tile.
- Defined full-coverage writes as the point at which the complete destination can become defined again.

#### 中文

- 以逐元素状态替代整 Tile 已定义性归属。
- 使消费者合法性依赖其精确读取区域。

### Scope and boundaries / 范围与边界

This decision defines state granularity, not the valid regions of individual operations. Each operation owner still determines which elements it reads, writes, pads, or leaves undefined.

本决策定义状态粒度，而非各操作的有效区域。每个操作 owner 仍决定其读取、写入、填充或保持未定义的元素。
