---
{
  "id": "ADR-CUBE-0015",
  "title": "Shared source B.SUBVIEW uses per-PE offsets",
  "title_zh": "Shared 源 B.SUBVIEW 使用逐 PE 偏移",
  "status": "accepted",
  "authors": [
    "PTO ISA maintainers"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "5114fb699fa510abd9a3c42bcfa5c592cd724961",
  "target_releases": [
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-SUBVIEW-SHARED-PER-PE-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0106"
  ]
}
---

# ADR-CUBE-0015: Shared source B.SUBVIEW uses per-PE offsets

## Decision

`B.SUBVIEW` remains a source modifier and does not allocate a new architectural
Tile. For a bound Shared parent, the effective offset for selected PE `i` is
computed from that PE's private GPR plus the encoded unsigned immediate:

```text
OffsetCells[i] = ReadPELocalGPR(i, RegSrc) + ZeroExtend(uimm11)
```

The encoded subview size is common, but selected PEs may derive different ranges
of the same already-published parent. `PE_MASK` selects consumer side effects;
it does not select fixed quarters or imply a common offset.

## Boundary

The parent must already satisfy the whole-parent readiness/publication gate.
Out-of-bounds, misaligned, or schema-incompatible per-PE ranges reject before
payload or memory effects. The same rule applies to TSTORE, Shared-to-Local
TMOV, and Shared-input cooperative TMATMUL.

## Verification

Focused AVS points use distinct PE-local GPR values for four selected PEs and
prove that each derived range is evaluated independently while the parent
identity remains common.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Cooperative consumers may need different ranges of one published
Shared parent. A common offset or fixed-quarter interpretation cannot express
PE-private address selection.

**中文。** 协作消费者可能需要同一已发布 Shared 父对象的不同范围。公共 offset 或
固定 quarter 解释无法表达 PE 私有地址选择。

### Detailed decision / 详细决策

**English.** For each selected PE, `B.SUBVIEW` adds that PE's Local GPR value to
the common unsigned immediate. The parent identity and encoded size stay
common, while range, alignment, and schema legality are checked independently
after whole-parent readiness.

**中文。** 对每个选中 PE，`B.SUBVIEW` 将该 PE 的 Local GPR 值与公共无符号立即数
相加。父对象标识与编码 size 保持公共；完整父对象就绪后，各 PE 独立检查范围、
对齐与 schema 合法性。

### What changed / 改动内容

#### English

- Defined per-PE effective offsets for Shared source subviews.
- Kept the published parent and encoded subview size common.
- Applied the rule to TSTORE, Shared-to-Local TMOV, and cooperative TMATMUL.

#### 中文

- 定义 Shared 源 subview 的逐 PE 有效 offset。
- 保持已发布父对象和编码 subview size 公共。
- 将规则用于 TSTORE、Shared-to-Local TMOV 与协作 TMATMUL。

### Scope and boundaries / 范围与边界

**English.** `B.SUBVIEW` remains a source modifier and allocates no new
architectural Tile; PE masks select effects, not implicit quarters.

**中文。** `B.SUBVIEW` 仍是源 modifier，不分配新架构 Tile；PE mask 选择副作用，
不选择隐式 quarter。
