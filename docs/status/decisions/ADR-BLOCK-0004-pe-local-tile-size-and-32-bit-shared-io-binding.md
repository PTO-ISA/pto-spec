---
{
  "id": "ADR-BLOCK-0004",
  "title": "PE-Local Tile Size and 32-bit Shared I/O Binding",
  "title_zh": "PE 本地 Tile 大小与 32 位 Shared I/O 绑定",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-06",
  "accepted": "2026-08-06",
  "rejected": null,
  "superseded": null,
  "baseline": "f7d2d0c88e82929a65e9324eadbf6231aa164dcd",
  "target_releases": [
    "0.58.0"
  ],
  "affected_ndf": [
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-RELEASE-VERIFICATION",
    "PTO-SOURCE-HIERARCHY",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS",
    "PTO-ARCH-STATE-TILE-DESCRIPTOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TSTORE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0054"
  ]
}
---
# ADR-BLOCK-0004: PE-Local Tile Size and 32-bit Shared I/O Binding

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

- **Date**: 2026-08-06
- **Deciders**: PTO ISA maintainers

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

## Context

PTO ISA 0.58 originally described `TSize` using a four-PE aggregate size table
even though Tile dimensions and execution are programmed at PE granularity.
That mixed two architectural levels: encoded dimensions described one PE while
encoded capacity described the Core aggregate.

The active 16-bit `C.B.IOS` binder also carried only an absolute `SharedTID`.
GM-to-Shared `TLOAD` therefore reinterpreted `B.IOR.RegDst[11:9]` as a Shared
size, and Shared TLSU operations used a destination-free `B.IOT` as a mask-only
companion. That `B.IOT` spelling is binary-identical to an existing Local T
destination form and cannot round-trip unambiguously. Local-to-Shared `TMOV`
additionally borrowed the Local binder's destination-size field for a Shared
destination.

## Decision

PTO ISA 0.58 is reissued in place. The architecture version remains `0.58.0`
and the existing ABI string remains unchanged; the regenerated release manifest
and content hashes identify the replacement specification tree. Artifacts built
against the superseded 0.58 tree are stale and must not be mixed with the
reissued toolchain.

`B.DIM` dimensions and every explicit Tile destination `TSize` describe one
selected PE. The nonzero size table is 128 B, 256 B, 512 B, 1 KiB, 2 KiB,
4 KiB, and 8 KiB for codes 1 through 7. Core allocation is
`popcount(PE_MASK) * per_pe_size`. Mask bits map to fixed identities:
`1000=PE0`, `0100=PE1`, `0010=PE2`, and `0001=PE3`; selected PEs are never
packed. Mask zero is a strict no-op with no allocation, rename, source read,
memory access, state change, binder consumption, lifetime transition, or fault.

The active Shared operand binder is replaced by 32-bit `B.IOS`:

```text
width       = 32
opcode      = 0x13
funct3      = 001
match       = 0x00001013
mask        = 0xf00871ff
SharedTID   = bits[27:20]
PE_MASK     = bits[18:15]
TSize       = bits[11:9]
reserved    = bits[31:28], bit[19], bits[8:7] (all zero)
```

It belongs to catalog semantic group `Bundle Input & Output` and uses handler
`BindBundleSharedIO`. `TSize=0` denotes a Shared source; `TSize=1..7` denotes a
Shared destination and declares per-PE capacity. The encoded role must agree
with the selected operation schema. One instruction binds one absolute
Core-private register `S0..S255`; at most four ordered bindings may be live.
Duplicate unconsumed IDs and a fifth binding are illegal.

`B.IOS` owns Shared ID, role/size, and PE mask. `B.IOR` owns scalar/address
operands only and `RegDst` is zero in Shared TLSU schemas. `B.IOT` owns Local
Tile operands only and has no mask-only Shared form. Mixed Local/Shared
operations require equal masks. Shared CUBE operands are sources with
`TSize=0` and mask `1111`; TGEMV rejects every Shared binder.

The first nonzero allocating Shared write records an immutable allocation mask
and one per-PE descriptor. Later destination writes may update a subset but may
not expand the allocation mask; the compiler allocates a new `Sx` for a
different mask or incompatible descriptor. Reads of unallocated or
uninitialized Shared lanes retain undefined-register behavior: no trap and no
state change. Shared destination updates remain atomic descriptor-plus-selected-
payload operations. The architecture imposes no ordering on conflicting PE
accesses; programs must avoid conflicts.

For `MShard4`, encoded `M`, `N`, and `K` remain per-PE and the group view derives
`group_M=4*pe_M`, `group_N=pe_N`, and `group_K=pe_K`. Other distribution kinds
must define their own derivation.

## Consequences

- The `C.B.IOS` mnemonic and form are removed from the active catalog and
  rejected by the assembler. Its historical raw bit pattern decodes only as
  the overlapping active `C.B.DIMI` form; active `B.IOS` is added, so the
  command-form count remains 99.
- The reviewed 573-form binary envelope is rebound to SHA-256 fingerprint
  `9155a78499c4908e0fdc7ac2a48159eacb5c1dfc78ea724dbedf689369430993`.
- The old reviewed `C.B.DIMI`/`C.B.IOS` catalog-overlap exception is removed
  because only `C.B.DIMI` remains active at that bit pattern.
- `BundleSharedBinding` gains `size_code` and `pe_mask`, including reset,
  consume, trap snapshot, and recovery behavior.
- GM-to-Shared `TLOAD` size and mask come from `B.IOS`; Shared stores use source
  `B.IOS`; Local-to-Shared `TMOV` takes Shared capacity from destination
  `B.IOS`; Shared-to-Local keeps Local capacity in destination `B.IOT`.
- All legality checks occur before memory, payload, descriptor, allocation,
  rename, destination finalization, or binder consumption effects.
- Catalogs, ASL, tests, requirements, Markdown, HTML, XLSX, evidence, release
  manifest, and downstream PTO consumers must be regenerated.

## Supersession

ADR 0045's `B.IOT` allocation-size-code paragraph and ADR 0052's aggregate
Tile-size table remain historical. This ADR supersedes those size encodings,
plus ADR 0052's active `C.B.IOS` encoding, `B.IOR` Shared-size carrier,
mask-only `B.IOT` companion, and Shared binder schema. The retained operation
inventory and extension-encoding reservations in ADR 0052 remain in force.

This ADR also supersedes ADR 0052's current Tile/Bundle assertion-inventory
pin. The direct assertions protecting a valid live `B.IOS` binding and a
nonzero first-allocation mask raise that fail-closed inventory from 200 to
202; the scalar/system/concurrency inventory remains 34.

## Rejected Alternatives

- Keeping aggregate sizes leaves dimensions and capacity at different levels.
- Reusing `B.IOR.RegDst` keeps Tile allocation metadata in a scalar binder.
- A destination-free `B.IOT` is ambiguous with an existing Local T destination.
- Extending `C.B.IOS` cannot fit the approved ID, size, and mask contract.
- A separate direction bit is unnecessary because zero/nonzero `TSize` already
  distinguishes source and destination roles.
- Keeping both binders active creates two 0.58 ABIs and violates the approved
  clean break.
- A new 0.59 release or ABI-v2 suffix is not used; this decision replaces the
  earlier 0.58 design before toolchain stabilization.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The previous design mixed per-PE dimensions with aggregate Core capacity and spread Shared operand metadata across overlapping binders. That made allocation sizes inconsistent and prevented unambiguous assembly/disassembly round trips.

旧设计把每 PE 维度与 Core 聚合容量混在一起，并把 Shared 操作数元数据分散到相互重叠的绑定指令中，导致分配大小层级不一致且汇编/反汇编无法无歧义往返。

### Detailed decision / 详细决策

Tile size codes describe one selected PE, and total Core allocation derives from the PE mask. A 32-bit `B.IOS` exclusively carries the Shared register ID, source/destination role through `TSize`, and PE mask. `B.IOR` remains scalar/address binding and `B.IOT` remains Local Tile binding. Shared allocation masks and per-PE descriptors become persistent under the stated first-write and atomic-update rules.

Tile 大小码描述单个被选 PE，Core 总分配量由 PE 掩码推导。32 位 `B.IOS` 独占 Shared 寄存器 ID、由 `TSize` 表示的源/目的角色以及 PE 掩码；`B.IOR` 保持标量/地址绑定，`B.IOT` 保持 Local Tile 绑定。Shared 分配掩码与每 PE 描述符按照首次写入和原子更新规则持久化。

### What changed / 改动内容

#### English

- Replaced aggregate Tile sizing with per-PE sizing and explicit mask-derived allocation.
- Replaced compressed/overlapping Shared binding forms with one unambiguous 32-bit `B.IOS` contract.

#### 中文

- 以每 PE 大小和掩码推导分配替代聚合 Tile 大小。
- 以唯一明确的 32 位 `B.IOS` 契约替代压缩且重叠的 Shared 绑定形式。

### Scope and boundaries / 范围与边界

The decision changes binding ownership, capacity interpretation, and the affected release artifacts. It does not define new Tile operations, ordering for conflicting PE accesses, or a second 0.58 ABI.

本决策改变绑定归属、容量解释及相关发布产物；不定义新的 Tile 操作、不规定冲突 PE 访问顺序，也不创建第二套 0.58 ABI。
