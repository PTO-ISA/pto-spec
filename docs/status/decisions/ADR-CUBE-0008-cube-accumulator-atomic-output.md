---
{
  "id": "ADR-CUBE-0008",
  "title": "CUBE Accumulator and Atomic Output Contract",
  "title_zh": "CUBE 累加器与原子输出契约",
  "status": "accepted",
  "authors": [
    "Kevin Zhou"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "a4eb5a570f4c87fed8c6fc8b931f07a51c6ac1c1",
  "target_releases": [
    "0.58.3"
  ],
  "affected_ndf": [
    "PTO-CUBE-ACCUMULATOR-OUTPUT-001",
    "PTO-BSTART-TGEMV-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/106",
  "release_impact": "required",
  "amendments": [
    {
      "date": "2026-09-04",
      "baseline": "5f1cb735aa00ad061ec77c691f6a913711316f92",
      "approvers": [
        "Kevin Zhou <zhoubot@gmail.com>"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/234#issuecomment-5529151834",
      "affected_ndf": [
        "PTO-CUBE-ACCUMULATOR-OUTPUT-001"
      ],
      "affected_units": [
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
        "PTO-TILE-MODEL-EXECUTION-CUBE",
        "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"
      ]
    }
  ],
  "legacy_ids": [
    "ADR-0073"
  ]
}
---

# ADR-CUBE-0008: CUBE Accumulator and Atomic Output Contract

Accepted with implementation by pull request 111. It depends on the accepted
`PTO-CUBE-CELL-STATE-001` and `PTO-CUBE-LOCAL-MATRIX-001` contracts.

## Decision

Each TMATMUL_ACC and MX ACC operation reads one explicit accumulator C and
publishes one explicit destination D. C and D must use different encoded
relative Tile indices. Equal input and output indices raise Tile legality
before destination allocation, source snapshots, or any other effect.

For a decoded block, C's encoded relative source selector is the stored
six-bit source `TileIndex`, while D's encoded relative destination index is the
zero-extended two-bit `DstTile` hand. These encoded values must differ before
physical destination renaming. For a direct Tile call, the destination and
accumulator `TileIndex` values must differ.

The architecture does not add a reuse bit, an implicit accumulator, or an
in-place output form. Hardware renaming cannot make an unencodable equal-index
input/output tuple legal.

## Accumulator C

C has logical shape M x N, uses the same `CUBE_M16` or `CUBE_M32` layout class
as A, and contains the operation's accumulator dtype:

- FP32 for floating Matrix input pairs;
- S32 for signed integer Matrix input pairs; or
- U32 for unsigned integer Matrix input pairs.

Every valid C element must be defined before execution. C is snapshotted before
the product and remains unchanged after success or rejection. C carries no
hidden partial-sum provenance; its explicit dtype, shape, layout, definedness,
and role establish accumulator legality.

## Destination D

D has logical shape M x N and the same M layout class as A and C. Its concrete
dtype is selected by the complete Matrix and B.FPATR contract. D may therefore
have a different dtype, aligned storage geometry, CELL count, and required
capacity from C while retaining the same logical result dimensions and M layout
class.

An accumulator-preserving D uses the accumulator dtype and may become C in a
later block through a new explicit binding. A converted or quantized D is not a
legal later accumulator unless its dtype independently equals the required
accumulator type.

## Computation and reductions

The mathematical order is:

```text
P = snapshot(C) + A * B
D = PostProcess(P)
```

The complete K reduction produces raw P before destination conversion.
RowMax and GroupMax observe the raw accumulator at their operation-defined
stage. Post-processing does not alter the already selected reduction source.

## Atomic publication

Complete schema, index, alias, dtype, layout, shape, capacity, parameter,
definedness, readiness, and output-allocation legality precedes every source
snapshot and output effect.

D, RowMaxOut, GroupMaxOut, destination descriptors, definedness, and numeric
status publish as one atomic output group. A late failure exposes none of the
new outputs and preserves C, A, B, auxiliary sources, prior numeric status, and
allocation state.

## Defaults and protected behavior

- ACC forms have no omitted C or D default.
- Existing Matrix input-class and accumulator-dtype selection remains intact.
- Existing B.FPATR conversion, activation, reduction, flag, and parameter
  semantics remain intact.
- Source Tiles persist after successful execution.
- Matrix start function numbers and encodings remain unchanged.

## Fault ordering

Equal relative C/D indices, accumulator-type mismatch, incompatible M layout
class, shape mismatch, insufficient C or D capacity, undefined valid C data,
invalid PostProcess parameters, and auxiliary-output failure raise Tile
legality before effects. Decode-reserved forms remain illegal instruction and
missing/duplicate complete-bundle attributes retain their bundle-control fault
class.

## Explicit exclusions

This decision defines no reuse encoding, physical in-place overwrite, implicit
C, hidden partial-sum provenance, output-by-output commit, or fallback identity
PostProcess path.

## Acceptance criteria

The accepted ASL, generated documentation, and independent decoded tests
prove:

1. FP32, S32, and U32 explicit C behavior;
2. equal relative C/D index rejection before effects;
3. preserved C and newly allocated accumulator-type D;
4. final converted D with the same M layout class and different CELL geometry;
5. later reuse of a prior explicit accumulator-type D through a new binding;
6. raw-accumulator RowMax and GroupMax behavior;
7. atomic D/auxiliary/status publication;
8. rollback on late output capacity and parameter failures; and
9. unchanged source lifetime and Matrix instruction encodings.

## 2026-09-04 amendment: raw D and transparent-cache hints

ADR-CUBE-0018 preserves this decision's explicit, distinct C and D boundary.
CCTRL[0]=1 selects raw accumulator-type D instead of final post-processing, but
D remains newly allocated and atomically published. CCTRL[1] may provide a
non-binding transparent-cache use or prefetch hint for explicit C, and
CCTRL[0]=1 may hint cache replacement with the identical published D value.
Cache behavior cannot replace C or D or alter results, faults, allocation,
publication, source lifetime, or ordering.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** ACC operations need an observable input accumulator and a clear
publication boundary. An implicit or in-place accumulator would hide aliasing
and make late output failure expose partial state.

**中文。** ACC 操作需要可观察的输入累加器和清晰的发布边界。隐式或原地累加器会
隐藏 alias，并可能在后期输出失败时暴露部分状态。

### Detailed decision / 详细决策

**English.** ACC forms read explicit C and publish explicit D with different
encoded relative indices. C uses the required accumulator dtype and M layout;
D may use a post-processed dtype but retains logical MxN. All result Tiles,
descriptors, and numeric status commit atomically after full preflight.

**中文。** ACC 形式读取显式 C 并发布显式 D，两者编码相对索引必须不同。C 使用
要求的累加器 dtype 与 M 布局；D 可使用后处理 dtype，但保持逻辑 MxN。完整预检
后，所有结果 Tile、描述符与数值状态原子提交。

### What changed / 改动内容

#### English

- Required explicit, distinct C and D bindings for ACC forms.
- Fixed C dtype, layout, shape, definedness, and snapshot behavior.
- Made D, auxiliary outputs, and status one atomic publication group.

#### 中文

- 要求 ACC 形式显式且不同地绑定 C 与 D。
- 固定 C 的 dtype、布局、shape、definedness 与快照行为。
- 将 D、辅助输出与状态组成一个原子发布组。

### Scope and boundaries / 范围与边界

**English.** No reuse bit, implicit C, physical in-place overwrite, hidden
partial sum, or output-by-output commit is defined. The decision also leaves
the existing Matrix encodings, source lifetime, and operation-specific numeric
rules under their established owners.

**中文。** 不定义 reuse 位、隐式 C、物理原地覆盖、隐藏部分和或逐输出提交。
