---
{
  "id": "ADR-CUBE-0017",
  "title": "TCVT CUBE_M16 and CUBE_M32 layout closure",
  "title_zh": "TCVT CUBE_M16 与 CUBE_M32 布局闭合",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-28",
  "accepted": "2026-08-28",
  "rejected": null,
  "superseded": null,
  "baseline": "93a4b9e34c0bd80767077b41dac85b26b3e59934",
  "target_releases": [
    "0.58.5"
  ],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-INST-TILE-TCVT",
    "PTO-TCVT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/167",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0110"
  ]
}
---

# ADR-CUBE-0017: TCVT CUBE_M16 and CUBE_M32 layout closure

## Context

Issue #167 closes the TCVT destination-layout contract for Matrix `CUBE_M16`
and `CUBE_M32` sources. The implementation is based on the frozen issue
contract at baseline `52befcc1d6be2907708381b930a4eaf0242c204c` and keeps the
existing private CUBE representation boundary separate.

## Decision

For a Matrix source with `Layout=NORM` and `Canonicalize=0`, `TCVT` maps
`CUBE_M16` to `CUBE_M16` and `CUBE_M32` to `CUBE_M32`. The destination keeps
the source `valid_rows` and `valid_columns`, while its physical shape, CELL
count, required bytes, and minimum legal TSize are independently derived from
the destination `DataType`; the destination TSize may differ from the source
TSize.

The CUBE M-format path requires Matrix location, `Layout=NORM`, and
`Canonicalize=0`. Private CUBE canonicalization remains a separate
`Canonicalize=1` representation boundary. `CUBE_N8` is outside this decision.
For this path LB0 and LB1 must equal the source `ValidCol` and `ValidRow`;
LB1 omission still selects one row. LB2 must be omitted because CUBE physical
columns are derived independently for each DataType and TSize. Any mismatch or
present LB2 raises `Fault_TileLegality` before destination allocation. Once the
logical shape is accepted, an insufficient destination TSize raises
`Fault_TileAllocation` with no destination effect.

For example, a `CUBE_M16` FP32 source with `ValidRow=16`, `ValidCol=1`, and
TSize 128 B may convert to BF16 with the same valid region and TSize 128 B.
The source and destination logical payloads are 64 B and 32 B, respectively;
their remaining physical coordinates are padding. With `PadValue=Null`, every
destination padding coordinate remains undefined.
Local destination capacity continues to require 128-byte alignment, a capacity
between 128 B and 64 KiB inclusive, the PE limit, and enough bytes for the
target descriptor. TCVT remains a per-logical-element conversion; this ADR
introduces no FP16x2/FP8x2 pair DataType and no pair opcode.

## Release boundary

This accepted ADR is targeted to PTO ISA `0.58.5` and is a release-boundary
record for the issue #167 NDF and ASL drift. Current semantic meaning remains
owned by the affected ASL/NDF clauses and their generated projections.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** TCVT changes element type, so destination CELL geometry and
capacity cannot be copied from the source even when the logical valid region
is unchanged. The M-format path needs an explicit representation boundary.

**中文。** TCVT 改变元素类型，因此即使逻辑有效区域不变，也不能从源直接复制目标
CELL 几何与容量。M-format 路径需要显式表示边界。

### Detailed decision / 详细决策

**English.** With Matrix location, NORM layout, and Canonicalize=0, M16 maps to
M16 and M32 to M32. Valid rows and columns persist, but destination geometry,
CELL count, required bytes, and minimum TSize derive from destination dtype.
LB0/LB1 must match the source and LB2 is absent; legality precedes allocation.

**中文。** 在 Matrix location、NORM 布局且 Canonicalize=0 时，M16 映射到 M16，
M32 映射到 M32。有效行列保持不变，但目标几何、CELL 数、所需字节与最小 TSize
由目标 dtype 派生。LB0/LB1 必须匹配源，LB2 必须省略，合法性检查先于分配。

### What changed / 改动内容

#### English

- Closed M16/M32 TCVT destination-layout preservation.
- Made destination storage and capacity independently dtype-derived.
- Fixed dimension-field and fault ordering for this path.

#### 中文

- 闭合 M16/M32 TCVT 目标布局保持规则。
- 使目标存储与容量独立地由 dtype 派生。
- 固定该路径的维度字段与故障顺序。

### Scope and boundaries / 范围与边界

**English.** CUBE_N8, private canonicalization, pair DataTypes, and pair
opcodes remain outside this ADR. Current meaning stays with affected ASL/NDF.

**中文。** CUBE_N8、私有 canonicalization、pair DataType 与 pair opcode 不在
本 ADR 范围；当前语义仍由相关 ASL/NDF 持有。
