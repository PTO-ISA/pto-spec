---
{
  "id": "ADR-CUBE-0011",
  "title": "Cooperative Group-M Distribution and Inactive PE Semantics",
  "title_zh": "协作式 Group-M 分配与非活动 PE 语义",
  "status": "accepted",
  "authors": [
    "Kevin Zhou"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-24",
  "accepted": "2026-08-24",
  "rejected": null,
  "superseded": null,
  "baseline": "a39ab0075a7d60bea7002d941bd8ee80158ee0dc",
  "target_releases": [
    "0.58.4"
  ],
  "affected_ndf": [
    "PTO-CUBE-GROUP-M-DISTRIBUTION-001",
    "PTO-B-ASSEMBLE-CONSUMER-READINESS-001"
  ],
  "affected_units": [
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/136",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0100"
  ]
}
---

# ADR-CUBE-0011: Cooperative Group-M Distribution and Inactive PE Semantics

## Context

Cooperative TMATMUL needs one Core-total row count while Local descriptors,
capacity, dependencies, subviews, and destination generations remain private
to one PE. Earlier decisions treated LB0 as a uniform per-PE M and permitted
arbitrary nonzero masks. That cannot represent tail groups with zero-row PEs
without observing invalid compute-only Local values.

## Decision

For Local-A/Shared-B and Shared-A/Shared-B TMATMUL ordinary, ACC, BIAS, MX,
MX+ACC, and MX+BIAS forms, LB0 is `group_M`, the Core-total valid output-row
count in 1 through 128. LB1 remains N and LB2 remains K. Every executing form
uses encoded `PE_MASK=1111`; every sparse nonzero mask raises
`Fault_TileLegality` before effects. `PE_MASK=0000` retains the existing strict
no-op. All-Local TMATMUL keeps per-PE M and TGEMV remains Local-only.

The fixed distribution is:

```text
M_per_PE = 16, when 1 <= group_M <= 64
M_per_PE = 32, when 65 <= group_M <= 128
valid_M[i] = clamp(group_M - i*M_per_PE, 0, M_per_PE)
```

Shared A has shape `[group_M,K]`; Shared B has shape `[K,N]`. Active PE `i`
consumes Shared-A rows beginning at `i*M_per_PE`, or its own Local A fragment,
and publishes one Local `[valid_M[i],N]` fragment. The formal single-PE
execution view charges only that current PE's Local pool.

All four PEs retain decode, raw binder/schema completeness, dimensions,
topology, mask, rendezvous, every Shared descriptor/view/readiness/capacity
check, common fault selection, and atomic collective completion. When
`valid_M[i]=0`, PE `i` does not resolve or inspect compute-only Local mappings,
descriptors, payloads, dependencies, subviews, aliases, allocation, generation,
parameters, reductions, or outputs. Required encoded roles remain present and
raw-legal. Invalid Shared state still rejects the collective.

Group-level and Shared preflight therefore precedes generic Local Stage2 work.
For an active PE, the accepted B.SUBVIEW/B.ASSEMBLE dependency, generation,
rollback, and publication rules apply unchanged to the derived `valid_M`
fragment. For an inactive PE, those Local mechanisms are not entered.

## Partial supersession

This decision supersedes only the cooperative M and nonzero-mask clauses of
ADR-CUBE-0007 and ADR-CUBE-0010. Their independent 256 KiB Local pools, one 256 KiB
Core-wide Shared pool, fixed PE identities, SizeCode and SharedTileID rules,
Shared persistence/readiness, transpose, precise fault, rollback, and atomic
publication decisions remain accepted. ADR-BLOCK-0016 active-role range and
generation semantics remain protected.

## Verification

Independent decoded AVS points prove group sizes 1, 17, 64, 65, and 128;
exact sparse-mask rejection; strict zero-mask no-effect; current-PE Shared-A
row selection; active-fragment allocation; inactive unallocated Local
source/subview/assemble suppression; structural-negative rejection; and
Shared-negative rejection without Local effects.

## Release impact

This is an architecture-visible interpretation and mask change for the 0.58.4
candidate. It does not regenerate the 0.58.3 release or authorize 0.58.4
validation, tagging, or publication.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Uniform per-PE M cannot express a tail group containing zero-row
PEs without inspecting nonexistent Local compute state. The collective needs
one Core-total row count and deterministic active fragments.

**中文。** 统一逐 PE M 无法表示含零行 PE 的尾组，否则会检查不存在的 Local 计算
状态。collective 需要一个 Core 总行数和确定的活动片段。

### Detailed decision / 详细决策

**English.** LB0 becomes `group_M` for cooperative TMATMUL. The fixed formula
derives `M_per_PE` and `valid_M[i]`; all executing forms use mask 1111, zero is
a strict no-op, and sparse masks reject. Zero-row PEs retain structural and
Shared checks but skip compute-only Local resolution and output effects.

**中文。** 协作 TMATMUL 的 LB0 改为 `group_M`。固定公式派生 `M_per_PE` 与
`valid_M[i]`；执行形式使用 mask 1111，零 mask 严格无操作，稀疏 mask 拒绝。
零行 PE 保留结构与 Shared 检查，但跳过仅计算所需的 Local 解析及输出副作用。

### What changed / 改动内容

#### English

- Reinterpreted cooperative LB0 as Core-total group_M.
- Added deterministic per-PE row fragments and inactive-PE suppression.
- Replaced arbitrary nonzero masks with full participation or strict zero.

#### 中文

- 将协作 LB0 重新解释为 Core 总 `group_M`。
- 增加确定的逐 PE 行片段和非活动 PE 抑制。
- 以全参与或严格零 mask 替代任意非零 mask。

### Scope and boundaries / 范围与边界

**English.** All-Local TMATMUL and Local-only TGEMV keep their earlier M rules;
this ADR does not authorize release publication.

**中文。** 全 Local TMATMUL 与仅 Local 的 TGEMV 保持原 M 规则；本 ADR 不授权发布。
本决策也不改变独立容量池、Shared 发布、transpose、rollback 或输出原子性契约，
这些规则继续由其现有 owner 管理。
