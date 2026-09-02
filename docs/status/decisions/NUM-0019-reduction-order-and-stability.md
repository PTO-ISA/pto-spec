---
{
  "id": "ADR-NUM-0019",
  "title": "Reduction order and stability",
  "title_zh": "归约顺序与稳定性",
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
    "PD-09",
    "ADR-0092"
  ]
}
---
# ADR-NUM-0019: Reduction order and stability

## Context

CPU and target reduction trees differ, optimized shapes may change grouping, and selected integer paths widen then narrow with wrap behavior. Review must freeze accumulation width and order, overflow behavior, NaN and signed-zero selection, argument tie-breaking, partial merge behavior, and stable ordering requirements.

The proposal under review makes integer widths, overflow, comparison order, argument ties, and stable ordering portable and exact. Floating reductions would define an exact tree per profile or a finite and testable allowed-result contract, including NaNs, signed zero, and partial merge order.

## Affected domains

- `tile-compare`
- `tile-order`
- `tile-partial`
- `tile-reduction`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- implementation-defined rules with explicit allowed sets.

## Blockers

- Freeze accumulator widths and trees.
- Define argument and equal-value ties.
- Bound floating permutation sensitivity and partial merges.

## Acceptance obligations

- A reduction-tree or allowed-result contract.
- Permutation and tie vectors.
- Widening, overflow, NaN, zero, and partial-merge vectors.

## Decision

No reduction rule is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Reduction trees, widths, ties, and partial merges affect visible
results. Optimized grouping cannot silently choose these contracts.

**中文。** 归约树、宽度、tie 与 partial merge 会影响可见结果；优化分组不能静默
选择这些契约。

### Detailed decision / 详细决策

**English.** The draft requires exact integer behavior and either fixed
floating trees or finite testable result sets, including permutation, ties,
NaNs, signed zero, overflow, and partial-merge evidence.

**中文。** 本 draft 要求精确整数行为，并为浮点规定固定树或有限可测试结果集，覆盖
permutation、tie、NaN、有符号零、overflow 与 partial merge 证据。

### What changed / 改动内容

#### English

- Enumerated unresolved reduction ordering and stability dimensions.
- Defined tree/allowed-set and vector obligations.
- Authorized no reduction implementation from this draft.

#### 中文

- 枚举未解决归约顺序与稳定性维度。
- 定义 tree/allowed-set 与 vector 义务。
- 不授权依据本 draft 实现归约规则。

### Scope and boundaries / 范围与边界

**English.** No accumulator tree, tie result, or stability promise is accepted.
Existing operation identities and structural schemas remain, but they provide
no permission to select an optimized grouping or allowed-result set. This draft
does not authorize implementation.

**中文。** 当前不接受任何累加树、tie 结果或稳定性承诺；既有操作标识与结构 schema
也不允许选择优化分组或 allowed-result set。本 draft 不授权实现。
