---
{
  "id": "ADR-NUM-0013",
  "title": "Numeric profile applicability",
  "title_zh": "数值配置适用性",
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
    "PD-01",
    "ADR-0086"
  ]
}
---
# ADR-NUM-0013: Numeric profile applicability

## Context

The public contract names CPU, A2A3, and A5 capability profiles and says that profiles narrow support, while the numeric contract also exposes target-dependent result variation. The unresolved question is whether portable numeric results exist for each domain and which remaining differences are named target-profile rules rather than support restrictions.

ADR 0041 already closes the A2A3 unsupported-in-profile rule for all six MX CUBE selectors and all 25 `TileDataType` identities. The proposal under review is that legal PTO operations otherwise use `pto-numeric-v1` results, A2A3 and A5 reject only documented operation/type tuples, every accepted target-dependent result is selected by a named profile and bounded rule, and CPU observations are never normative.

## Affected domains

- `cube-matrix`
- `scalar-binary`
- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-fused`
- `scalar-integer-to-fp`
- `scalar-unary`
- `tile-binary`
- `tile-compare`
- `tile-convert`
- `tile-dequantize`
- `tile-expand`
- `tile-fused`
- `tile-order`
- `tile-partial`
- `tile-quantize`
- `tile-reduction`
- `tile-unary`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- unsupported-in-profile dispositions.

## Blockers

- Complete every remaining domain operation/type applicability table after the accepted A2A3 MX negative slice.
- Accept one portable or target disposition for every supported and rejected tuple.

## Acceptance obligations

- An accepted profile taxonomy and version identifiers.
- A complete domain-to-profile applicability matrix.

## Decision

No rule is accepted by this draft. Review must choose and record the disposition for every affected tuple before implementation or maturity promotion.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Support restrictions and target-dependent results must be separated
for every operation/type tuple; otherwise catalog presence or observed target
behavior could be mistaken for portable support.

**中文。** 每个操作/类型组合的支持限制与目标相关结果必须分开，否则目录存在性或
目标观测行为可能被误认为可移植支持。

### Detailed decision / 详细决策

**English.** This draft lists affected domains, alternatives, blockers, and the
required complete applicability matrix. It proposes dispositions for review
but accepts none.

**中文。** 本 draft 列出受影响 domain、备选方案、blocker 与所需完整适用性矩阵，
仅提出待审 disposition，不接受任何规则。

### What changed / 改动内容

#### English

- Recorded the unresolved applicability question and review scope.
- Identified matrix-completion and disposition obligations.
- Authorized no implementation or maturity promotion.

#### 中文

- 记录未解决的适用性问题与审查范围。
- 明确矩阵补全与 disposition 义务。
- 不授权任何实现或成熟度提升。

### Scope and boundaries / 范围与边界

**English.** Draft status is normative: no positive support, rejection, or
numeric-result rule may be implemented from this ADR.
This draft does not authorize implementation.

**中文。** Draft 状态具有明确边界：不得依据本 ADR 实现正向支持、拒绝或数值结果规则。
本 draft 不授权实现。
