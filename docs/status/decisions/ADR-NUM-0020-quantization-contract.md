---
{
  "id": "ADR-NUM-0020",
  "title": "Quantization contract",
  "title_zh": "量化契约",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-08-21",
  "accepted": null,
  "rejected": null,
  "superseded": "2026-09-04",
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [],
  "affected_units": [],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [
    "ADR-TILE-0013"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PD-10",
    "ADR-0093"
  ]
}
---
# ADR-NUM-0020: Quantization contract

## Context

Implementation evidence contains multiple format, shared-exponent, scale, zero-point, clamping, and special-value paths that are not one portable arithmetic rule. Review must define scale and zero-point encoding, grouping axis and size, exponent selection, rounding, clamping, exceptional sentinels, packing, and inverse dequantization for every accepted format.

The proposal under review gives every accepted quantized format equations for scale, zero point, grouping, exponent selection, rounding, clamping, packing, tails, special values, and inverse dequantization. Formats without a complete rule reject in that profile.

## Affected domains

- `tile-dequantize`
- `tile-quantize`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- unsupported-in-profile dispositions.

## Blockers

- Resolve whether the affine parameter is scale or inverse-scale/pre-quant multiplier.
- Freeze format-specific equations and stochastic-rounding state.
- Define group axes, sizes, and tails.
- Define sentinels, packing, round-trip tolerances, and whether `SET_QUANT` configuration is architectural state.

## Acceptance obligations

- Format-specific quantization equations.
- Group and tail-boundary vectors.
- NaN, infinity, zero, maximum, tie, clamp, pack, and round-trip vectors.

## Decision

No quantization rule is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Scale, zero point, grouping, stochastic state, clamping, packing,
and inverse behavior vary across evidence and cannot be merged by assumption.

**中文。** Scale、zero point、分组、随机状态、clamping、packing 与逆变换在证据中
存在差异，不能通过假设合并。

### Detailed decision / 详细决策

**English.** The draft requires format-specific equations and complete group,
tail, special-value, tie, clamp, pack, and round-trip vectors. Formats lacking
a complete accepted rule would reject, but no such rule is accepted here.

**中文。** 本 draft 要求逐格式方程及完整 group、tail、特殊值、tie、clamp、pack 与
round-trip vector。缺少完整已接受规则的格式应拒绝，但本 draft 尚未接受该规则。

### What changed / 改动内容

#### English

- Recorded all unresolved quantization contract dimensions.
- Defined equation and boundary-vector obligations.
- Authorized no quantization implementation.
- Kept implementation observations from selecting scale or grouping semantics.

#### 中文

- 记录全部未解决量化契约维度。
- 定义方程与边界 vector 义务。
- 不授权量化实现。

### Scope and boundaries / 范围与边界

**English.** No scale interpretation, grouping, stochastic state, sentinel, or
inverse tolerance is normative from this draft. Existing format names and
operation identities do not supply missing equations, packing, tail, or round-
trip rules. This draft does not authorize implementation.

**中文。** 本 draft 不使任何 scale 解释、分组、随机状态、sentinel 或逆变换容差成为
规范；既有格式名与操作标识也不补足方程、packing、tail 或 round-trip 规则。
本 draft 不授权实现。
