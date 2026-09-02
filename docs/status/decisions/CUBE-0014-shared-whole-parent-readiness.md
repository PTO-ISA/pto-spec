---
{
  "id": "ADR-CUBE-0014",
  "title": "Shared whole-parent readiness and single-issuer publication",
  "title_zh": "Shared 完整父对象就绪与单发布者发布",
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
    "PTO-B-SHARED-WHOLE-PARENT-READY-001",
    "PTO-B-ASSEMBLE-SHARED-GENERATION-001"
  ],
  "affected_units": [
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0105"
  ]
}
---

# ADR-CUBE-0014: Shared whole-parent readiness and single-issuer publication

## Context

Shared producer participation is not the same thing as Shared parent coverage or
consumer visibility. A producer mask such as `0001` can describe one PE that
writes a complete Shared parent, while a later consumer may use a different
mask. The previous model conflated fixed-quarter initialization with readiness.

## Decision

`B.IOS` without `B.ASSEMBLE` is legal only for one participating issuer PE. That
issuer writes and publishes the complete logical Shared parent; `PE_MASK` never
creates implicit quarters or offsets. A multi-PE producer must use `B.ASSEMBLE`
with explicit per-PE offsets, non-overlap checks, complete coverage, and an
atomic `LAST` publication.

Shared generation state records producer participation/metadata, logical
coverage, parent-level `whole_parent_ready`, and consumer-visible `published`
separately. Readiness is hardware-maintained. A pending or incomplete
assembled generation does not replace the prior published generation and is
not readable by a Shared consumer. Every Shared consumer waits/no-ops before
payload access until both `whole_parent_ready` and `published` are true.

No READY instruction or READY encoding field is added.

## Consequences

- A producer mask is independent of a consumer mask.
- A one-PE full writer can publish a 32 KiB or larger Shared parent without
  requiring all four PE bits.
- Undefined Shared words are not a legal pending-source path for TSTORE, TMOV,
  or Shared-input TMATMUL.

## Verification

Focused AVS points cover single-PE whole-parent publication, sparse producer
masks, atomic assembled `LAST`, incomplete-generation waiting, and preservation
of the prior published generation.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Producer participation does not prove whole-parent coverage or
consumer visibility. Conflating masks with implicit quarters could expose an
incomplete generation or replace a still-valid published parent too early.

**中文。** 生产者参与不等于完整父对象覆盖或消费者可见。把 mask 与隐式 quarter
混为一谈，可能暴露未完成 generation，或过早替换仍有效的已发布父对象。

### Detailed decision / 详细决策

**English.** A non-assembled `B.IOS` has one issuer that writes the complete
parent. Multi-PE production uses explicit `B.ASSEMBLE` offsets, coverage, and
atomic LAST publication. Generation metadata separately tracks participation,
coverage, `whole_parent_ready`, and `published`; consumers wait before payload
access until both readiness and publication hold.

**中文。** 不带 `B.ASSEMBLE` 的 `B.IOS` 只有一个发布者并写完整父对象。多 PE
生产使用显式 `B.ASSEMBLE` offset、覆盖检查和原子 LAST 发布。generation 元数据
分别跟踪参与、覆盖、`whole_parent_ready` 与 `published`；两者均成立前消费者等待。

### What changed / 改动内容

#### English

- Replaced implicit producer quarters with whole-parent single-issuer writes.
- Required explicit assembly for multi-PE production.
- Separated readiness from publication and preserved prior generations.

#### 中文

- 以单发布者完整父对象写替代隐式生产者 quarter。
- 要求多 PE 生产使用显式 assemble。
- 分离就绪与发布，并保留先前 generation。

### Scope and boundaries / 范围与边界

**English.** No READY instruction or encoding is added; this decision governs
Shared parent publication, not unrelated Local execution.

**中文。** 不增加 READY 指令或编码；本决策只管理 Shared 父对象发布，不涉及无关
Local 执行。
