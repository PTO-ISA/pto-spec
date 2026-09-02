---
{
  "id": "ADR-STATE-0010",
  "title": "Scalar PC-relative and return-address state",
  "title_zh": "标量 PC 相对与返回地址状态",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-29",
  "accepted": "2026-07-29",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ADDTPC-PAGE-001",
    "PTO-BARG-CONTINUATION-001",
    "PTO-C-SETRET-DECISION-BINDING-001",
    "PTO-HL-ADDTPC-PAGE-001",
    "PTO-HL-SETRET-DECISION-BINDING-001",
    "PTO-SETRET-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-STATE-PROGRAM-COUNTER",
    "PTO-BLOCK-MODEL-STATE-BARG",
    "PTO-SCALAR-ADDTPC",
    "PTO-SCALAR-C-SETRET",
    "PTO-SCALAR-HL-ADDTPC",
    "PTO-SCALAR-HL-SETRET",
    "PTO-SCALAR-SETRET"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0021"
  ]
}
---
# ADR-STATE-0010: Scalar PC-relative and return-address state

- Date: 2026-07-29
- Requirement: PTO-REQ-SCALAR-CONTROL-001

## Context

PTO exposes TPC as the current scalar instruction address and names R10 as the
ABI return-address register. Earlier reference code accidentally gave `ADDTPC`
page-relative behavior and made `SETRET` update only an internal bundle-local
return target. Those effects conflicted with the instruction spellings and the
rest of the TPC execution contract.

## Decision

- `ADDTPC` and `HL.ADDTPC` compute `TPC + (sign-extended immediate << 1)`.
- `SETRET`, `HL.SETRET`, and `C.SETRET` compute `TPC + (immediate << 1)`.
- `SETRET` writes the computed target to architectural R10 (`ra`) and mirrors
  it into the bundle-local return-address state used by return bundle starts,
  frame handling, trap snapshots, and recovery.
- The canonical compressed spelling is `c.setret uimm, ->ra`. The malformed
  historical text `c.setret uimm, - >Ra` is not an accepted assembly alias and
  MUST NOT be emitted by canonical disassembly.
- Normal sequential TPC advancement remains the responsibility of the scalar
  dispatch boundary after the instruction effect completes.

## Consequences

PC-relative scalar arithmetic no longer inherits page-address semantics from
another ISA family. R10 and the bundle-local return target cannot silently
diverge after `SETRET`; later direct writes to R10 remain ordinary GPR writes
and do not retroactively change an already captured bundle return target.

The reviewed 548-form scalar-plus-command projection has SHA-256 fingerprint
`2d85b0ed94f4e2777b82400a996f938b154f66ee6630a74060da64e02b030e5e`.
Relative to the preceding fingerprint, only the canonical `C.SETRET` assembly
text changes; its form identity, width, mask, match, fields, constraints, and
execution encoding are unchanged.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

ADDTPC had accidentally inherited page-relative behavior, and SETRET updated only internal bundle return state instead of architectural R10. Both contradicted instruction names and allowed visible and saved return targets to diverge.

ADDTPC 意外继承了 page-relative 行为，SETRET 也只更新内部 Bundle 返回状态而没有更新架构 R10。两者都与指令名称冲突，并允许可见返回地址与保存目标发生分歧。

### Detailed decision / 详细决策

ADDTPC and HL.ADDTPC add a sign-extended halfword-scaled immediate to TPC. SETRET forms compute a TPC-relative target, write architectural R10, and mirror it into bundle-local return state. Dispatch retains responsibility for ordinary sequential TPC advance, and the canonical compressed spelling is fixed.

ADDTPC 和 HL.ADDTPC 将按半字缩放的符号扩展立即数加到 TPC。SETRET 各形式计算 TPC 相对目标，写入架构 R10，并镜像到 Bundle 局部返回状态。普通顺序 TPC 推进仍由分派负责，同时修正规范压缩拼写。

### What changed / 改动内容

#### English

- Replaced accidental page-relative arithmetic with TPC-relative arithmetic.
- Kept R10 and captured bundle return state synchronized at SETRET.
- Corrected canonical C.SETRET assembly text without changing encoding.

#### 中文

- 以 TPC 相对算术替代意外的 page-relative 算术。
- 在 SETRET 时同步 R10 与捕获的 Bundle 返回状态。
- 修正规范 C.SETRET 汇编文本，但不改变编码。

### Scope and boundaries / 范围与边界

Later direct writes to R10 remain ordinary GPR writes and do not retroactively alter captured bundle state. This record changes no form identity, mask/match, field, or encoding.

后续直接写 R10 仍是普通 GPR 写入，不会追溯修改已捕获 Bundle 状态。本记录不改变形式身份、mask/match、字段或编码。
