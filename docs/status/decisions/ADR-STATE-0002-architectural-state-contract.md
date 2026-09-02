---
{
  "id": "ADR-STATE-0002",
  "title": "Define the PTO architectural state contract",
  "title_zh": "定义 PTO 架构状态契约",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "007844f182ca87c843ebf274d7c9509188e68e01",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-REQ-BUNDLE-STATE-001",
    "PTO-REQ-SHARED-TILE-001",
    "PTO-REQ-STATE-001",
    "PTO-REQ-TILE-001",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS",
    "PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS",
    "PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS",
    "PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS",
    "PTO-ARCH-STATE-DEFINEDNESS",
    "PTO-ARCH-STATE-PROGRAM-COUNTER",
    "PTO-ARCH-STATE-TILE-DESCRIPTOR",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-ARCH-SYSTEM-REGISTERS-CONTEXT",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-MODEL-STATE-BINDING-STATE",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0008"
  ]
}
---
# ADR-STATE-0002: Define the PTO architectural state contract

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

> The `B.Z`/`B.NZ` consumer clause is superseded by ADR 0067. Those spellings
> are extension-reserved and are not active PTO instructions.

- Decision date: 2026-07-28
- Requirement: PTO-REQ-STATE-001

## Context

The architecture requires a scalar-bundle and tile-state contract with explicit
register, predicate, access-control, trap, system-register, and tile descriptor
state. Older bridge and pipe-management wording did not match that contract.

## Decision

- The five-bit scalar register namespace contains 24 absolute GPRs and eight
  temporary operands: T#1..T#4 and U#1..U#4. A queue push shifts older entries
  toward `#4` and discards the previous `#4` value.
- The architecture exposes eight 32-bit per-warp predicate registers. P0 is
  hardwired all-ones; P1 through P7 are independent trap-preserved state with
  no accepted PTO instruction consumer. Scalar `B.Z` and `B.NZ` consume the
  bundle commit argument established by `SETC.*`.
- Access is governed by ACR0..ACR15. PTO v0 resets to ACR0, restricts extended
  system-register families to ACR0, and applies its protected memory region to
  ACR2 through ACR15.
- Trap status, trap cause, and trap argument are banked by ACR. A fault or
  interrupt records the active bank, and the context-family system-register
  address selects which bank ACR0 software observes.
- The base system-register names include `THREAD_PTR`, `GLOBAL_PTR`,
  `BLOCKID`, `THREAD_ID`, `CORE_STATE`, `CORE_ID`, and `TILE_CAPACITY`.
- Bundle execution state includes TPC, BPC, bundle active/body flags, bundle
  condition, bundle arguments, dimensions, IO bindings, control attributes, and
  data attributes.
- Each tile register has a `TileInfo` descriptor. Allocation or reconfiguration
  makes its contents undefined until an architectural write defines them.
- An implementation-defined layout may be recorded in `TileInfo`, but the
  portable generic indexing operation rejects that layout. A profile-specific
  operation must define any access to it.
- Aggregate tile capacity is bounded by the read-only `TILE_CAPACITY` system
  register. PTO v0 sets that register to 256 KiB; the ASL verification model
  supports values up to that bound.
- Pipe state is not architectural. PTO models allocation, definedness, and
  handoff through scalar queues, bundle bindings, and `TileInfo`.

## Consequences

- The accepted direct Tile catalog contains 109 operations: 87 use the
  unchanged TEPL Mode/Function carrier, 10 use TLSU, and 12 use CUBE. The TEPL
  carrier operations are classified architecturally as VEC or SFU.
- Vector instruction execution is outside PTO.
- Implementations may use physical queues, layouts, or pipelines, but they must
  preserve the state and fault behavior defined by the ASL.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

PTO needs one explicit state contract spanning scalar, bundle, Tile, predicates, access control, traps, and system registers. Older bridge and pipeline language did not identify which state is architecturally visible or what an implementation must preserve.

PTO 需要一套显式状态契约，统一覆盖标量、Bundle、Tile、谓词、访问控制、陷阱和系统寄存器。旧有 bridge 与 pipeline 表述没有明确哪些状态属于架构可见状态，也没有说明实现必须保存什么。

### Detailed decision / 详细决策

The record defines the scalar register and temporary-queue namespaces, predicate state, ACR banks, trap state, base system registers, bundle state, TileInfo allocation and definedness, layout boundaries, and aggregate Tile capacity. Physical pipe state is excluded; implementations may choose queues, layouts, and pipelines only while preserving the ASL-defined state and fault behavior.

本记录定义标量寄存器与临时队列命名空间、谓词状态、ACR bank、陷阱状态、基础系统寄存器、Bundle 状态、TileInfo 分配与 definedness、布局边界以及 Tile 总容量。物理 pipe 状态被排除；实现可以选择队列、布局和流水线，但必须保持 ASL 定义的状态与故障行为。

### What changed / 改动内容

#### English

- Replaced bridge/pipe wording with an explicit architecture-visible state inventory.
- Defined register, predicate, ACR, trap, bundle, and Tile descriptor responsibilities.
- Made physical pipelines non-architectural while retaining observable allocation, definedness, and handoff.

#### 中文

- 以显式的架构可见状态清单替代 bridge/pipe 表述。
- 定义寄存器、谓词、ACR、陷阱、Bundle 和 Tile 描述符职责。
- 将物理流水线排除出架构，同时保留可观察的分配、definedness 和 handoff。

### Scope and boundaries / 范围与边界

The contract states what is visible and preserved; it does not prescribe a physical register file, queue, layout, or pipeline. Vector instruction execution remains outside PTO.

该契约规定哪些状态可见且必须保持，但不规定物理寄存器文件、队列、布局或流水线。Vector 指令执行仍不属于 PTO。
