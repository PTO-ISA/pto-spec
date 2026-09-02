---
{
  "id": "ADR-BLOCK-0010",
  "title": "conditional branch extension reservation",
  "title_zh": "条件分支扩展编码保留",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-18",
  "accepted": "2026-08-18",
  "rejected": null,
  "superseded": null,
  "baseline": "090126925e955f90cc1e23b07c1dbbd0f108b6f4",
  "target_releases": [
    "0.58.2"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-BLOCK-0002"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0067"
  ]
}
---
# ADR-BLOCK-0010: conditional branch extension reservation

- Scope: `B.EQ`, `B.NE`, `B.LT`, `B.GE`, `B.LTU`, `B.GEU`, `B.Z`, `B.NZ`
- Requirement: PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001
- Supersedes: only the active-PTO conditional-branch clauses of ADR 0008,
  ADR 0027, and ADR 0046

## Decision

The eight named conditional branch families are not active PTO instructions.
Their complete 32-bit encoding forms are occupied extension space. PTO scalar
decode rejects every matching form before operand reads or architectural
effects, and PTO assembly/disassembly does not expose their spellings.

This reservation does not remove scalar comparison, `SETC.*`, `J`, `JR`, or
the block commit-target mechanisms. It changes no encoding outside the eight
reserved families.

## Rationale

The forms belong to the two-level block-body architecture. Keeping them in the
active PTO scalar catalog would contradict that ownership boundary and allow a
PTO implementation to consume extension encodings that must remain
collision-protected.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Conditional branch forms inherited from a two-level machine-body design conflict with PTO's accepted ownership boundary. Leaving them active would assign portable semantics to encodings reserved for an extension model.

源自两级机器 Body 设计的条件分支形式与 PTO 已接受的归属边界冲突。若继续激活这些形式，就会为本应保留给扩展模型的编码赋予可移植语义。

### Detailed decision / 详细决策

The complete conditional-branch encoding space identified by this record is extension-reserved. PTO does not decode it as an active scalar branch, does not define a machine execution-mask consumer for it, and protects the space from collisions. Current Bundle conditional selection uses the BARG commit path instead.

本记录识别的完整条件分支编码空间保留给扩展。PTO 不把它解码为现行标量分支，不为其定义机器执行掩码消费者，并保护该空间免于编码冲突。当前 Bundle 条件选择改用 BARG 提交路径。

### What changed / 改动内容

#### English

- Removed conditional machine-body branch forms from the active PTO catalog.
- Reserved and collision-protected their complete encoding space.

#### 中文

- 从现行 PTO 目录移除条件机器 Body 分支形式。
- 保留并防冲突保护其完整编码空间。

### Scope and boundaries / 范围与边界

The reservation defines no execution semantics. Any future use requires a separate extension decision; existing scalar and Bundle continuation instructions are unaffected except for ownership clarity.

该保留不定义执行语义。未来使用必须经过独立扩展决策；既有标量及 Bundle continuation 指令除归属更清晰外不受影响。
