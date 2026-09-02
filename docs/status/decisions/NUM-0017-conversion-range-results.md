---
{
  "id": "ADR-NUM-0017",
  "title": "Conversion range results",
  "title_zh": "转换范围结果",
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
    "PD-07",
    "ADR-0090"
  ]
}
---
# ADR-NUM-0017: Conversion range results

## Context

The public contract records undefined hardware overflow where CPU simulation may saturate, and backend paths expose non-saturating wrap and target-specific control combinations. Review must choose a deterministic result or a bounded implementation-defined result set for every source, destination, rounding, saturation, NaN, infinity, and out-of-range combination.

The proposal under review requires every conversion cross-product to have one deterministic result, an enumerated profile-specific allowed-result set, or pre-effect rejection. Public undefined-overflow wording and CPU-only saturation cannot remain architectural outcomes.

## Affected domains

- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-integer-to-fp`
- `tile-convert`
- `tile-dequantize`
- `tile-quantize`

## Alternatives considered

- portable normative rules;
- named target-profile rules;
- implementation-defined rules with explicit allowed sets; and
- unsupported-in-profile dispositions.

## Blockers

- Complete the source/destination/rounding/saturation cross-product.
- Resolve the public CPU-saturation versus implementation default-OFF conflict.
- Choose overflow, NaN, and infinity results.
- Define non-saturating narrowing, wrap behavior, and omitted-saturation defaults per profile/type pair.

## Acceptance obligations

- A complete conversion cross-product.
- Minimum, maximum, one-past, NaN, and infinity vectors.
- Saturation-off wrap vectors.

## Decision

No conversion range result is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Out-of-range, NaN, infinity, saturation, and wrap observations
differ across implementations; undefined wording cannot serve as architecture.

**中文。** 越界、NaN、infinity、saturation 与 wrap 的实现观测不同；undefined
措辞不能充当架构语义。

### Detailed decision / 详细决策

**English.** The draft demands a complete source/destination/rounding/
saturation cross-product with deterministic results, bounded allowed sets, or
pre-effect rejection. No disposition is selected yet.

**中文。** 本 draft 要求完整 source/destination/rounding/saturation 交叉表，每项
必须是确定结果、有界允许集合或副作用前拒绝；当前尚未选择 disposition。

### What changed / 改动内容

#### English

- Recorded all unresolved conversion range dimensions.
- Required boundary, NaN, infinity, and wrap vectors.
- Authorized no conversion-range implementation.

#### 中文

- 记录全部未解决转换范围维度。
- 要求边界、NaN、infinity 与 wrap vector。
- 不授权转换范围实现。

### Scope and boundaries / 范围与边界

**English.** Existing accepted conversion subsets remain unchanged; this draft
adds no overflow, saturation, or wrap result.
This draft does not authorize implementation.

**中文。** 既有已接受转换子集保持不变；本 draft 不新增 overflow、saturation 或 wrap 结果。
本 draft 不授权实现。
