---
{
  "id": "ADR-TYPE-0000",
  "title": "Replace with the architecture decision title",
  "title_zh": "替换为架构决策中文标题",
  "status": "draft",
  "authors": ["github-handle"],
  "approvers": [],
  "created": "2026-08-21",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "4be7d809e79af23401073edaf80d8cca82ccef95",
  "target_releases": ["unassigned"],
  "affected_ndf": [],
  "affected_units": [],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "release_boundary": false,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---
# ADR-TYPE-0000: Replace with the architecture decision title

Replace `TYPE` with one of `GOV`, `STATE`, `MEM`, `BLOCK`, `SCALAR`, `TILE`,
`CUBE`, or `NUM`, then allocate the next serial within that category.

## Summary

## Context

## Decision

## Normative delta

## Externally visible interface delta

State the encoding, operand/schema, architectural state, legality/fault,
ordering/commit, profile, or other software-visible interface that changes.
If there is no such delta, do not allocate an ADR; fix the owning ASL/tests and
record the correction in the issue and commit history.

## Defaults and intentionally unspecified behavior

## Compatibility and dependent-toolchain impact

## Alternatives considered

## Risks and mitigations

## Implementation obligations

## Verification obligations

## Release consequences

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Explain the architectural problem, why the current owner cannot
remain ambiguous, and why a reviewed decision is required.

**中文。** 说明架构问题、为什么现有 owner 不能继续保持歧义，以及为什么需要正式评审决策。

### Detailed decision / 详细决策

**English.** State the chosen architecture boundary and the invariants that
later ADRs and implementations inherit.

**中文。** 说明选定的架构边界，以及后续 ADR 与实现必须继承的不变量。

### What changed / 改动内容

#### English

- List each changed public contract, NDF clause, ASL owner, or evidence surface.

#### 中文

- 逐项列出发生变化的公开契约、NDF 条款、ASL owner 或证据表面。

### Scope and boundaries / 范围与边界

**English.** Identify preserved behavior, explicit exclusions, intentionally
unspecified behavior, and follow-up decisions.

**中文。** 说明保持不变的行为、明确排除项、有意未规定的行为以及后续决策。
