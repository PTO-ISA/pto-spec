---
{
  "id": "ADR-CUBE-0007",
  "title": "Cooperative Shared CUBE Inputs and Transpose",
  "title_zh": "协作式 Shared CUBE 输入与转置",
  "status": "accepted",
  "authors": [
    "Kevin Zhou"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-20",
  "accepted": "2026-08-20",
  "rejected": null,
  "superseded": null,
  "baseline": "30cd155cf635f0bf41429dbd5751fc7737268fb4",
  "target_releases": [
    "0.58.3"
  ],
  "affected_ndf": [
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-B-SUBVIEW-SHARED-PER-PE-001",
    "PTO-CUBE-GROUP-M-DISTRIBUTION-001",
    "PTO-CUBE-SHARED-TRANSPOSE-001",
    "PTO-BSTART-TGEMV-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMV-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMV-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-CONTRACT-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMUL-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-TGEMV-CONTRACT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-RESET",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMV-BIAS",
    "PTO-BLOCK-BSTART-TGEMV",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-TMATMUL",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/105",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0072"
  ],
  "amendments": [
    {
      "date": "2026-09-08",
      "baseline": "dea0b75e803cffa873982c90f9aa0cd17c6d243b",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/255",
      "affected_ndf": [
        "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
        "PTO-B-SUBVIEW-SHARED-PER-PE-001",
        "PTO-CUBE-SHARED-TRANSPOSE-001",
        "PTO-CUBE-GROUP-M-DISTRIBUTION-001",
        "PTO-BSTART-TMATMUL-CONTRACT-001",
        "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
        "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
        "PTO-BSTART-TMATMULMX-CONTRACT-001",
        "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
        "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001"
      ],
      "affected_units": [
        "PTO-BLOCK-B-FPATR",
        "PTO-BLOCK-BSTART-TMATMUL",
        "PTO-BLOCK-BSTART-TMATMUL-ACC",
        "PTO-BLOCK-BSTART-TMATMUL-BIAS",
        "PTO-BLOCK-BSTART-TMATMULMX",
        "PTO-BLOCK-BSTART-TMATMULMX-ACC",
        "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
        "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
        "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
        "PTO-TILE-MODEL-STATE-SHARED-REGISTERS"
      ]
    }
  ]
}
---

# ADR-CUBE-0007: Cooperative Shared CUBE Inputs and Transpose

Accepted with implementation by pull request 110. It depends on the accepted
`PTO-CUBE-CELL-STATE-001` and `PTO-CUBE-LOCAL-MATRIX-001` contracts.

## Decision

Shared Tiles remain ordinary two-dimensional descriptors. They never persist a
CUBE CELL layout, ND/DN orientation, transpose state, or per-operation Matrix
role.

Cooperative TMATMUL-family operations may bind the right primary operand, or
both A and B primary operands, from published Shared Tiles according to the
operation's complete-bundle schema. Local C/D and every Local primary operand
continue to use the CUBE layout contract. TGEMV remains Local-only and rejects
every Shared primary binding.

When only B is Shared, D inherits the `CUBE_M16` or `CUBE_M32` layout class of
Local A. When both A and B are Shared, an ACC form inherits the layout class of
Local C. A non-ACC all-Shared form selects `CUBE_M16` for `1 <= M <= 16` and
`CUBE_M32` for `17 <= M <= 32`. No additional layout selector is encoded.

## Transpose encoding

The existing `B.FPATR` command assigns two previously reserved bits:

- bit 7 is `TransA`;
- bit 8 is `TransB`; and
- bits 9 and 10 remain reserved zero.

The canonical no-transpose command encodes both controls as zero. `TransA=1`
is legal only when A is Shared. `TransB=1` is legal only when B is Shared. A
transpose request for a corresponding Local input raises Tile legality before
source snapshots, consumption, or destination allocation.

Shared inputs are read through their ordinary logical descriptor. After all
four PEs have completed rendezvous and Shared-readiness preflight, the selected
transpose is applied to the logical input consumed by CUBE. The transformation
does not modify the Shared descriptor, payload, publication state, or lifetime.

## PE mask and rendezvous

LB0=M remains the logical row count for one PE. It is not a core-total M. Each
participating PE computes M result rows. The group-visible row count is derived
from the number and fixed identity of participating PEs.

Any nonzero four-bit PE mask is legal. Multiple set bits are allowed. All four
PEs reach the cooperative rendezvous and perform complete Shared source
readiness and schema preflight. Only PEs whose bit is set perform the selected
computation, allocate Local destinations, and publish output state.

PE mask zero is a strict no-op before descriptor reads, Shared readiness,
dimension/layout/type checks, faults, allocation, source effects, or output
publication.

## Preflight and ordering

The cooperative operation completes these checks before any selected PE
snapshots a source or allocates a destination:

- exact Local/Shared operand schema and role ordering;
- B.FPATR presence, field legality, and reserved bits;
- TransA/TransB correspondence to Shared inputs;
- all four PEs' rendezvous participation;
- publication and complete readiness of every referenced Shared Tile;
- selected PEs' Local descriptor, dimension, layout, dtype, capacity, and
  destination availability; and
- operation-specific auxiliary and post-process schema.

Rejection preserves all Local and Shared state. A successful cooperative read
does not create GM ordering and does not define an order among unrelated Shared
or Local accesses.

## Defaults and protected behavior

- `TransA=0` and `TransB=0` select no logical transpose.
- Existing B.FPATR post-processing fields and their numeric semantics remain
  unchanged.
- Fixed PE identities, per-PE TSize, and Shared core-private visibility remain
  unchanged.
- Partial masks select destination producers; they do not change logical M for
  an individual selected PE.
- Existing Matrix function numbers and start encodings remain unchanged.

## Explicit exclusions

This decision adds no persistent Shared CUBE layout, GM/Shared CUBE conversion,
Shared TGEMV form, hidden orientation state, or implicit memory fence.

## Acceptance criteria

The accepted ASL, generated documentation, and independent decoded tests
prove:

1. B.FPATR 00, 01, 10, and 11 transpose controls and exact logical results;
2. bits 9 and 10 remain decode-reserved;
3. transpose acceptance only for the corresponding Shared input;
4. right-only and two-Shared primary schemas;
5. all single-bit and representative multi-bit nonzero masks;
6. four-PE rendezvous/readiness with selected-PE-only allocation and publish;
7. strict zero-mask no-effect before all legality and readiness checks;
8. unchanged Shared descriptors and payload after successful reads;
9. TGEMV Shared rejection; and
10. rollback on every late cooperative preflight failure.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Cooperative Matrix execution needs Shared inputs without turning
Shared descriptors into persistent CUBE state. Explicit transpose controls
also avoid hidden orientation and keep Local and Shared roles distinguishable.

**中文。** 协作式矩阵执行需要 Shared 输入，但不能把 Shared 描述符变成持久 CUBE
状态。显式转置控制还能避免隐藏方向，并保持 Local 与 Shared 角色可区分。

### Detailed decision / 详细决策

**English.** Shared Tiles remain ordinary descriptors; TMATMUL may bind Shared
B or Shared A+B, while TGEMV remains Local-only. `B.FPATR` bits 7 and 8 apply
logical transpose only to corresponding Shared operands. Rendezvous,
readiness, selected-PE effects, and rollback are checked as one cooperative
preflight.

**中文。** Shared Tile 保持普通描述符；TMATMUL 可绑定 Shared B 或 Shared A+B，
TGEMV 仍仅支持 Local。`B.FPATR` 位 7、8 只对对应 Shared 操作数执行逻辑转置。
rendezvous、就绪、选中 PE 副作用与回滚作为一个协作预检处理。

### What changed / 改动内容

#### English

- Added Shared-primary Matrix binding forms and logical transpose controls.
- Defined four-PE rendezvous with selected-PE-only compute and publication.
- Preserved Shared descriptors and payloads across successful reads.

#### 中文

- 增加 Shared 主操作数矩阵绑定形式与逻辑转置控制。
- 定义四 PE rendezvous，仅选中 PE 计算并发布。
- 成功读取后保持 Shared 描述符与 payload 不变。

### Scope and boundaries / 范围与边界

**English.** No persistent Shared CUBE layout, Shared TGEMV, GM conversion,
hidden orientation, or memory fence is introduced.

**中文。** 不引入持久 Shared CUBE 布局、Shared TGEMV、GM 转换、隐藏方向或内存栅栏。

## 2026-09-08 amendment: Issue #255 current Shared TMATMUL semantics

This amendment is evaluated from baseline `dea0b75e803cffa873982c90f9aa0cd17c6d243b`.
It preserves the accepted decision and history above while fixing the current
physical schema used by Shared TMATMUL-family consumers. For logical A `[M,K]`,
`TransA=0` maps to physical `[M,K]` and `TransA=1` maps to `[K,M]`. For logical
B `[K,N]`, `TransB=0` maps to physical `[N,K]` and `TransB=1` maps to `[K,N]`.
The same side-specific major mapping applies to an independently bound MX
scale: A scale is `[M,G_A]` or `[G_A,M]`, and B scale is `[N,G_B]` or
`[G_B,N]` for control zero or one respectively. Every source exposes its exact
physical valid shape with a legal padded major pitch.

The Shared-A source remains split by `group_M`; active PE `i` reads rows from
`m_global = i*M_per_PE + local_row`, while zero-row PEs produce no compute
effects. Existing CELL `B.SUBVIEW` offset/size geometry is retained. A matrix
consumer derives each participating PE's view metadata before payload
snapshot or destination allocation and preflights all four PEs under the
current cooperative nonzero mask `1111`; one invalid view raises
`Fault_TileLegality` atomically. Shared readiness remains parent-level
`whole_parent_ready && published`. TLOAD, Shared descriptor/state/payload/
lifetime, Local-A transpose rejection, and all post-processing, numeric,
readiness, and atomic-output behavior remain unchanged. No legacy selector,
arbitrary nonzero mask, Shared TGEMV, or new descriptor is introduced.
Square matrices can remain shape-legal under either control, so an old layout
may be numerically reinterpreted without a fault; migration must explicitly
arrange the physical payload or select the matching control, and this
amendment does not promise detection of that case.

中文：本修订基于 `dea0b75e803cffa873982c90f9aa0cd17c6d243b`，保留上述已接受决定及其
历史，仅修正 Shared TMATMUL 当前使用的物理 schema。逻辑 A `[M,K]` 在 `TransA=0`
时为物理 `[M,K]`、在 `TransA=1` 时为 `[K,M]`；逻辑 B `[K,N]` 在 `TransB=0`
时为物理 `[N,K]`、在 `TransB=1` 时为 `[K,N]`。独立绑定的 MX scale 采用同侧
major 映射：A 为 `[M,G_A]`/`[G_A,M]`，B 为 `[N,G_B]`/`[G_B,N]`。所有来源
必须提供精确 physical valid shape，并允许合法 padded major pitch。Shared-A 仍按
`group_M` 分片并以 `m_global` 取数；零行 PE 不产生计算副作用。既有 CELL
`B.SUBVIEW` 几何保持不变，矩阵消费者先完成所有参与 PE 的 view metadata 预检，
当前协作非零 mask 固定为 `1111`；任一非法 view 都以 `Fault_TileLegality` 原子拒绝。
Shared 就绪仍为 parent-level `whole_parent_ready && published`。TLOAD、Shared
descriptor/state/payload/lifetime、Local-A 转置拒绝及后处理、数值、就绪和原子输出
语义保持不变；不引入 legacy selector、任意非零 mask、Shared TGEMV 或新 descriptor。
方阵在任一控制下都可能满足 shape 合法性，因此旧布局可能无 fault 而发生数值重解释；
迁移时必须明确安排 physical payload 或选择匹配控制，本修订不承诺检测此情形。
