---
{
  "id": "ADR-CUBE-0012",
  "title": "Matrix Scale Cell Layouts, HiF4 Scale Words, and CScale",
  "title_zh": "矩阵 Scale CELL 布局、HiF4 Scale 字与 CScale",
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
  "baseline": "633e4e24824bc84dfdf2ffffefb62042ad6492d1",
  "target_releases": [
    "0.58.4"
  ],
  "affected_ndf": [
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-CUBE-CSCALE-001",
    "PTO-CUBE-HIF4-SCALE-001",
    "PTO-CUBE-MATRIX-SCALE-001",
    "PTO-CUBE-MATRIX-SCALE-CELL-001",
    "PTO-CUBE-SHARED-TRANSPOSE-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE",
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE",
    "PTO-TILE-MODEL-SHAPE-CUBE-CELL"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/136",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0101"
  ],
  "amendments": [
    {
      "date": "2026-09-03",
      "baseline": "2b7ed44063272ad6958546eb2121f8fc8fb48c4b",
      "approvers": [
        "ckwllawliet"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/234",
      "affected_ndf": [
        "PTO-B-FPATR-MATRIX-POSTPROCESS-001"
      ],
      "affected_units": [
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
        "PTO-TILE-MODEL-EXECUTION-CUBE",
        "PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS"
      ]
    }
  ]
}
---

# ADR-CUBE-0012: Matrix Scale Cell Layouts, HiF4 Scale Words, and CScale

## Decision

Each Matrix-MX side independently selects scale group and carrier from its
primary type. MX FP8/FP4 uses group 32 and E8M0. HiF4X2 uses group 64 and one
raw U32 HiF4 scale word. HiF4X2 is added only to Matrix-MX input roles; ordinary
Matrix and every GEMV form retain their existing type sets.

Local A scale is CUBE_M32 storage `[M,G]`. Local B scale is CUBE_M32 storage
`[N,G]`, while its semantic view remains `BScale[g,n]`. One E8M0 CellReg stores
`[32,4]`; one U32 HiF4 CellReg stores `[32,1]`. Column/K repeat is fast and
32-row/N repeat is slow. A partial final group or row block is legal storage
tail and is not an operand. Primary B remains CUBE_N8.

Shared scales remain ordinary Tiles with normalized A-scale `[group_M,G]` and
B-scale `[G,N]`. TransA or TransB applies to the corresponding independently
bound primary and scale after any B.SUBVIEW resolution, without persistent
source mutation.

One HiF4 raw U32 scale word contains E6M2 in bits 7:0, E1_8 bits in 15:8, and
E1_16 bits in 31:16. E6M2 00..FE is finite with exponent bias 48 and two
fraction bits; FF is a legal quiet NaN. Group lane q adds E1_8[floor(q/8)] and
E1_16[floor(q/4)] to the base exponent.

B.FPATR bit 9 is CScaleEn and bit 10 remains reserved. CScaleEn is legal only
for FP32 TMATMUL.ACC and TMATMULMX.ACC. CScale is the final mathematical Local
source, uses U8 CUBE_M32 `[M,1]`, and may not alias D or an auxiliary output.
It scales C by `2^-CScale[m,0]` before reductions, activation, quantization, and
destination conversion. Omission defaults CScaleEn to zero and preserves prior
results. The maximum Matrix Local source count becomes nine.

## Compatibility and protected behavior

B.FPATR bit 9 was reserved, so zero retains binary meaning and one becomes
defined only for the accepted FP32 ACC forms. Bit 10 remains fixed zero.
Primary A/C/D M16/M32 legality remains capped at one row block even though the
generic M32 scale grid supports multiple row blocks. ADR-CUBE-0011 group-M and
inactive-PE behavior, ADR-BLOCK-0016 active-role range/generation behavior, distinct
C/D, rollback, and atomic output publication remain unchanged.

## Verification

Executable evidence covers MX G5/N33 and HiF4 multi-repeat CellReg order,
partial tails, E6M2 00/FE/FF, decoded HiF4X2 Matrix-MX acceptance, ordinary
Matrix rejection, decoded CScale success, and reserved/missing/surplus/alias/
opcode/accumulator-class rejection before effects.

## Release impact

The B.FPATR accepted mask and Matrix-MX type applicability change the 0.58.4
candidate encoding fingerprint. No release manifest, tag, or publication is
created by this decision.

The accepted encoded-form count remains 542. The reviewed scalar-plus-command
fingerprint after assigning B.FPATR bit 9 is
`e62de1b044c5b45ff4019cd19e3f545d4222e1ef6a69d2c26f93bcb128d54fee`.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** MX inputs need scale storage that follows CUBE CELL geometry,
including HiF4 grouping, while ACC needs an explicit row scale for C. Without
fixed carriers and layouts, scale interpretation would depend on implementation.

**中文。** MX 输入需要符合 CUBE CELL 几何的 scale 存储，包括 HiF4 分组；ACC
还需要显式 C 行 scale。若不固定 carrier 与布局，scale 解释将依赖实现。

### Detailed decision / 详细决策

**English.** The ADR selects group sizes and E8M0/U32 carriers, fixes Local and
Shared A/B scale shapes and CELL ordering, defines the HiF4 scale-word fields,
and assigns `B.FPATR` bit 9 to CScaleEn for accepted FP32 ACC forms. CScale is
the final Local source and precedes later post-processing stages.

**中文。** 本 ADR 选择分组大小及 E8M0/U32 carrier，固定 Local/Shared A/B scale
shape 与 CELL 顺序，定义 HiF4 scale 字字段，并将 `B.FPATR` 位 9 分配给受支持
FP32 ACC 形式的 CScaleEn。CScale 是最后一个 Local 源，作用于后续后处理之前。

### What changed / 改动内容

#### English

- Added exact MX and HiF4 scale CELL layouts and tail rules.
- Defined the raw HiF4 U32 scale word.
- Added CScaleEn and CScale binding for selected FP32 ACC operations.

#### 中文

- 增加精确 MX/HiF4 scale CELL 布局与尾部规则。
- 定义 HiF4 原始 U32 scale 字。
- 为选定 FP32 ACC 操作增加 CScaleEn 与 CScale 绑定。

### Scope and boundaries / 范围与边界

**English.** Ordinary Matrix and GEMV type sets, group-M behavior, and atomic
publication remain unchanged except where this ADR explicitly states otherwise.

**中文。** 除明确说明外，普通矩阵/GEMV 类型集、group-M 行为与原子发布保持不变。
