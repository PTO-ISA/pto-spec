---
{
  "id": "ADR-NUM-0016",
  "title": "Numeric exception flags",
  "title_zh": "数值异常标志",
  "status": "draft",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-08-21",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [],
  "affected_units": [],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PD-06",
    "ADR-0089"
  ]
}
---
# ADR-NUM-0016: Numeric exception flags

## Context

The formal scalar surface owns NV, DZ, OF, UF, and NX hooks, but the audited public numeric contract does not define a complete producer, stickiness, or priority rule. Review must define per-operation flag production, simultaneous flags, stickiness, reset, and trap interaction for every scalar numeric domain.

The proposal under review treats NV, DZ, OF, UF, and NX as portable sticky architectural flags with the state, lifecycle, trap envelope, and 30-form producer ownership fixed by ADR 0038. Each of the 19 profile-owned forms still requires an exact produced flag set for every supported operation/type rule.

## Affected domains

- `scalar-binary`
- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-fused`
- `scalar-integer-to-fp`
- `scalar-unary`

## Alternatives considered

- portable normative rules; and
- named target-profile rules.

## Blockers

- Accept exact flag conditions for all 19 profile-owned scalar forms.
- Define tininess detection and NX coupling in every affected operation/type rule.
- Publish independent simultaneous-flag and special-value vectors.

## Acceptance obligations

- A flag-production matrix.
- Multi-flag priority and stickiness vectors.
- Reset and trap-preservation tests.

## Decision

No flag-production result is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Flag storage and producer ownership are closed, but exact
NV/DZ/OF/UF/NX conditions for delegated scalar forms remain missing.

**中文。** 标志存储与产生者归属已闭合，但委托 scalar 形式的精确 NV/DZ/OF/UF/NX
条件仍缺失。

### Detailed decision / 详细决策

**English.** This draft requires a complete production matrix, simultaneous-
flag behavior, tininess/NX coupling, and independent reset/trap vectors before
any production rule can be accepted.

**中文。** 本 draft 要求在接受任何产生规则前补齐生产矩阵、同时多标志行为、
tininess/NX coupling 及独立 reset/trap vector。

### What changed / 改动内容

#### English

- Isolated remaining flag-production decisions from closed state mechanics.
- Listed exact matrix and verification obligations.
- Authorized no flag-production implementation.
- Preserved the accepted sticky state, reset, system-write, and trap lifecycle.

#### 中文

- 将剩余标志产生决策与已闭合状态机制分离。
- 列出精确矩阵与验证义务。
- 不授权标志产生实现。

### Scope and boundaries / 范围与边界

**English.** Existing state lifecycle remains valid; no new producer condition
is normative until a later accepted decision. The draft neither selects target
conditions nor changes sticky accumulation, reset, software write, or trap
recovery. This draft does not authorize implementation.

**中文。** 既有状态生命周期保持有效；后续决策接受前，不新增任何规范产生条件，
也不选择目标条件或改变 sticky 累积、reset、软件写与 trap 恢复。本 draft 不授权实现。
