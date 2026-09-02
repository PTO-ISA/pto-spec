---
{
  "id": "ADR-BLOCK-0011",
  "title": "Extension first-use is a target-profile hook",
  "title_zh": "扩展首次使用由目标 profile 钩子定义",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-19",
  "accepted": "2026-08-19",
  "rejected": null,
  "superseded": null,
  "baseline": "69591e45f3aade7d0326da868420e0653894cb61",
  "target_releases": [
    "0.58.3"
  ],
  "affected_ndf": [
    "PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-EXTENSION-FIRST-USE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/100",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0068"
  ]
}
---
# ADR-BLOCK-0011: Extension first-use is a target-profile hook

- Scope: architecture profile boundary
- Requirement: PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001
- Issue: https://github.com/PTO-ISA/pto-spec/issues/100

## Context

Some targets allocate VECTOR or CUBE context lazily and need a precise trap
before the first instruction that would consume that context. PTO does not own
one portable enable-register layout, trap-number allocation, ACR route, or
software task-state policy. Encoding a particular target's values in the
portable model would turn an implementation profile into common PTO semantics.

## Decision

PTO defines two extension kinds and two target-profile hooks. The portable
default reports both kinds disabled. Its raise hook returns without changing
trap, bundle, queue, memory, or fault state.

An enabling target profile must define the covered instruction set, enable
state and ownership, source and manager ACRs, trap envelope and argument
mapping, and the ordering point. The trap must occur after decode and target
legality but before extension allocation or architectural effects. The saved
execution point must permit exact retry, and the target must guarantee forward
progress for its context-save path.

## Consequences

PTO implementations that do not select such a profile retain existing
behavior. Target profiles can bind a concrete first-use ABI without changing
PTO encodings or importing target register fields into the portable model. A
profile claim is incomplete without executable zero-effect, retry, and
independent-kind evidence.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

An extension may require target-specific work on its first architectural use, but portable PTO encodings cannot assume a particular target ABI. The hook separates that target obligation from the common instruction semantics.

扩展在首次架构使用时可能需要目标特定处理，但可移植 PTO 编码不能假定某个目标 ABI。该钩子把目标义务与通用指令语义分离。

### Detailed decision / 详细决策

The affected architecture unit exposes a first-use hook that a selected target profile may bind. The hook must preserve zero-effect rejection and retry behavior and distinguish independent extension kinds. If no such binding is selected, existing PTO behavior remains unchanged; the hook does not add target register fields to portable encodings.

受影响架构单元提供可由所选目标 profile 绑定的首次使用钩子。该钩子必须保持零副作用拒绝与重试行为，并区分相互独立的扩展种类。未选择绑定时，既有 PTO 行为不变；该钩子不会把目标寄存器字段加入可移植编码。

### What changed / 改动内容

#### English

- Added an explicit target-owned first-use integration point before extension effects become architecturally visible.
- Required zero-effect, precise retry, and independent-kind evidence for every concrete target binding.
- Kept the portable default disabled so an absent target binding cannot silently change PTO execution.

#### 中文

- 增加由目标负责的显式首次使用集成点。
- 要求任何绑定提供零副作用、重试和独立种类证据。

### Scope and boundaries / 范围与边界

This historical decision records an integration hook, not a concrete first-use ABI. It does not alter PTO encodings or authorize unspecified target behavior without an explicit binding.

本历史决策记录的是集成钩子，而非具体首次使用 ABI；它不改变 PTO 编码，也不在缺少显式绑定时授权未规定的目标行为。
