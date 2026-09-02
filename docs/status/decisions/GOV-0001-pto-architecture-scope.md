---
{
  "id": "ADR-GOV-0001",
  "title": "Define PTO as a scalar, bundle/command, and tile ISA",
  "title_zh": "将 PTO 定义为标量、Bundle/Command 与 Tile 统一 ISA",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "007844f182ca87c843ebf274d7c9509188e68e01",
  "target_releases": [
    "unassigned",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001",
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-ARCH-TEPL-ALIAS-001",
    "PTO-ARCH-TILE-EXECUTION-ENGINE-001",
    "PTO-ARCH-TILE-INSTRUCTION-CLASS-001",
    "PTO-RELEASE-VERIFICATION",
    "PTO-SOURCE-HIERARCHY",
    "PTO-TILE-CAPACITY-PER-PE",
    "PTO-REQ-INSTRUCTION-DISPATCH-001",
    "PTO-REQ-INSTRUCTION-FETCH-001",
    "PTO-REQ-PHYSICAL-MEMORY-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/4",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0001"
  ],
  "amendments": [
    {
      "date": "2026-08-31",
      "baseline": "e9b621ddce041ff2c770bef67adc41946db87295",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/179",
      "affected_ndf": [
        "PTO-REQ-INSTRUCTION-DISPATCH-001",
        "PTO-REQ-INSTRUCTION-FETCH-001",
        "PTO-REQ-PHYSICAL-MEMORY-BINDING-001"
      ],
      "affected_units": [
        "PTO-ARCH-DISPATCH-TOP-LEVEL",
        "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
        "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
        "PTO-ARCH-PROFILE-REFERENCE-PROFILE"
      ]
    }
  ]
}
---
# ADR-GOV-0001: Define PTO as a scalar, bundle/command, and tile ISA

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

- Formal-model issue: [#4](https://github.com/PTO-ISA/pto-spec/issues/4)
- Decision date: 2026-07-28

## Context

PTO needs scalar execution, visible bundle/command state, and direct tile
operations in one coherent architectural state. The ISA must define exact
instruction encodings and state transitions without depending on backend
pipelines, hidden command streams, or implementation scheduling.

## Decision

Scalar instructions, bundle/command forms, and direct tile instructions update
the same architecture-visible state. Bundle state is explicit through TPC, BPC,
active/body flags, arguments, dimensions, IO bindings, and attributes. Tile
registers are explicit operands.

The canonical catalogs contain 466 Scalar forms, 94 active Block forms, 126
direct Tile operations, and 46 occupied extension reservations. Exact
admission, selector allocation, reservation, and semantic coverage are machine
checked.

## Consequences

- Binary encodings preserve PTO selector facts without prescribing physical
  queues or pipeline structure.
- Scalar selector values outside R0..R23 are not extra GPRs.
- Tile operands use a separate six-bit register domain.
- Vector instruction execution is outside the PTO ISA. Vector-only forms require
  a new architecture decision, catalog revision, ASL state definition, and
  precise fault/restart model before they can be accepted.

## Executable-specification boundary update

PTO-SPEC owns the architecture-visible instruction fetch, length selection,
decode dispatch, translation, access preflight, precise faults, and physical
memory profile hooks used by its executable ASL. A consumer must invoke those
owners rather than privately redefining them.

ELF loading, model instances, run manifests, stop policy, snapshots, worker
lifecycle, host storage, and C/C++ APIs are downstream model interfaces. The
ASL-Model repository owns their NDF identifiers and lifecycle. PTO-SPEC may
link to those downstream records as non-normative integration evidence, but it
must not mint, mirror, or carry ASL-Model NDF identifiers in PTO ADR metadata.

This boundary was closed through issues
[#179](https://github.com/PTO-ISA/pto-spec/issues/179) and
[#185](https://github.com/PTO-ISA/pto-spec/issues/185). The PTO-owned ASL
actions remain normative here; downstream initialization and execution policy
remain outside the PTO ISA.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

PTO needs one architecture-level account of scalar execution, visible bundle control, and direct Tile execution. Without this boundary, hidden queues, backend pipelines, or scheduler behavior could become accidental architecture and make encodings and state transitions impossible to review as one ISA.

PTO 需要在同一架构层次上说明标量执行、可见的 Bundle 控制和 Direct Tile 执行。若没有这一边界，隐藏队列、后端流水线或调度行为就可能意外成为架构内容，使编码和状态转换无法作为一套 ISA 统一审查。

### Detailed decision / 详细决策

Scalar, bundle/command, and direct Tile forms participate in one architecture-visible state machine. Bundle state and Tile operands are explicit, selector spaces remain distinct, and catalog admission, reservations, and semantic coverage are mechanically checked. PTO-SPEC also owns fetch, dispatch, translation, access preflight, precise faults, and physical-memory hooks; downstream lifecycle and host interfaces remain outside the ISA.

标量、Bundle/Command 和 Direct Tile 形式共同参与一套架构可见状态机。Bundle 状态和 Tile 操作数必须显式表示，各选择器空间保持区分，目录准入、保留空间和语义覆盖由机械检查约束。PTO-SPEC 还拥有取指、分派、地址转换、访问预检、精确故障和物理内存钩子；下游生命周期及宿主接口仍在 ISA 之外。

### What changed / 改动内容

#### English

- Established the three PTO instruction classes as one coherent architectural surface.
- Made bundle state and Tile-register operands explicit instead of relying on hidden implementation mechanisms.
- Separated PTO-owned executable actions from downstream loader, runtime, snapshot, and host-API responsibilities.

#### 中文

- 确立三类 PTO 指令共享同一连贯的架构表面。
- 将 Bundle 状态和 Tile 寄存器操作数显式化，不再依赖隐藏的实现机制。
- 区分 PTO 自有的可执行动作与下游加载器、运行时、快照及宿主 API 职责。

### Scope and boundaries / 范围与边界

This record defines the architecture and ownership boundary reflected by its listed NDF clauses and ASL units. Inventory counts are historical snapshots only. It does not prescribe a physical queue, pipeline, scheduler, loader lifecycle, model API, or vector execution semantics.

本记录定义其所列 NDF 条款和 ASL 单元所体现的架构与所有权边界。目录数量只是历史快照。它不规定物理队列、流水线、调度器、加载器生命周期、模型 API 或 Vector 执行语义。
