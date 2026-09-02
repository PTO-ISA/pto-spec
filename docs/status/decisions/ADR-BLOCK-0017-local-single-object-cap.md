---
{
  "id": "ADR-BLOCK-0017",
  "title": "Local single-object cap versus aggregate Local pool",
  "title_zh": "Local 单对象上限与 Local 总容量池",
  "status": "accepted",
  "authors": [
    "PTO ISA maintainers"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-27",
  "accepted": "2026-08-27",
  "rejected": null,
  "superseded": null,
  "baseline": "7dc8b7e5b121d2b2499a2273bebff29e2cd86812",
  "target_releases": [
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-B-IOT-STREAM-001",
    "PTO-TILE-CAPACITY-PER-PE",
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-ASSEMBLE-RANGE-001",
    "PTO-INST-BLOCK-B-ASSEMBLE",
    "PTO-INST-BLOCK-B-SUBVIEW"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-B-ASSEMBLE",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/166",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0109"
  ]
}
---

# ADR-BLOCK-0017: Local single-object cap versus aggregate Local pool

## Decision

ADR-BLOCK-0017 is a scoped clarification of ADR-CUBE-0010. Each individual Local object
or `B.IOT` destination is limited to SizeCode `1..10`, encoding `128 B..64 KiB`.
Each PE retains an independent aggregate Local pool of `256 KiB`, so multiple
separate Local objects may jointly consume that pool. A single SizeCode-12
encoding is not a Local object form.

The common SizeCode byte mapping remains unchanged: codes `1..12` encode
`128 B..256 KiB`, and Shared `B.IOS` destinations continue to accept
SizeCode `1..12`.

For the already-defined range modifiers, raw `B.SUBVIEW` and `B.ASSEMBLE`
fields retain their decoded `1..12` domain. Their effective association is
role-dependent: Local groups reject source/parent sizes `11` and `12`, while
Shared groups retain the complete `1..12` domain. `B.ASSEMBLE` SizeCode zero
MIDDLE/LAST behavior and the Shared decisions recorded by ADR-CUBE-0014,
ADR-CUBE-0015, and ADR-CUBE-0016 remain owned by those records and are not redefined
here.

## Boundary and evidence

Local `B.IOT` SizeCodes `11..12` are not assigned Local destination forms and
raise `Fault_IllegalInstruction` before Local binding or allocation effects.
Reserved SizeCodes `13..15` remain separately reserved. `B.SUBVIEW` and
`B.ASSEMBLE` retain raw assigned codes through 12; when raw code 11 or 12 is
associated with a Local group, it raises `Fault_TileLegality` before GPR reads
or carrier updates, while the same code remains legal for a Shared group.
Focused AVS proves a valid Local SizeCode-10 destination, both Local boundary
fault classes, multiple 64 KiB objects reaching one PE's 256 KiB aggregate,
Shared SizeCode-12 acceptance, and role-dependent range-modifier boundaries.

## Relationship to ADR-CUBE-0010

This record does not supersede ADR-CUBE-0010 and does not restate its unaffected
capacity-pool, encoding, cooperative group-M, or compatibility decisions.
ADR-CUBE-0010 remains the historical record; its 0.58.4.1 amendment points to
ADR-CUBE-0014, ADR-CUBE-0015, and ADR-CUBE-0016 for the Shared decisions it references.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Local storage has two different limits: the capacity of one addressable Tile object and the aggregate pool available to a PE. Conflating them would let range modifiers imply objects larger than the descriptor and binding encodings can represent.

Local 存储存在两个不同限制：单个可寻址 Tile 对象的容量，以及一个 PE 可用的总容量池。混淆两者会使范围修饰符暗示超过描述符与绑定编码表示能力的对象。

### Detailed decision / 详细决策

The record preserves the aggregate Local pool while imposing the documented single-object cap on each Local Tile descriptor. `B.SUBVIEW` and `B.ASSEMBLE` operate within that object boundary and do not concatenate capacity into a larger architectural object. The related Shared capacity decisions remain separate.

本记录保留 Local 总容量池，同时对每个 Local Tile 描述符施加已记录的单对象上限。`B.SUBVIEW` 与 `B.ASSEMBLE` 在该对象边界内工作，不把容量拼接成更大的架构对象。相关 Shared 容量决策保持独立。

### What changed / 改动内容

#### English

- Distinguished the Local per-object cap from aggregate per-PE capacity.
- Applied the object boundary to Local binding and range-modifier legality.

#### 中文

- 区分 Local 单对象上限与每 PE 聚合容量。
- 将对象边界应用于 Local 绑定和范围修饰符合法性。

### Scope and boundaries / 范围与边界

This ADR does not alter the aggregate pool or supersede Shared-capacity and cooperative-sharding decisions in ADR-CUBE-0010 and its amendments.

本 ADR 不改变总容量池，也不废止 ADR-CUBE-0010 及其修正中的 Shared 容量与协作分片决策。
