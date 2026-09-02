---
{
  "id": "ADR-NUM-0014",
  "title": "Numeric format legality",
  "title_zh": "数值格式合法性",
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
    "PD-02",
    "ADR-0087"
  ]
}
---
# ADR-NUM-0014: Numeric format legality

## Context

The public type names span IEEE, BF16, FP8, specialized eight-bit, four-bit, and integer carriers, but target availability and conversion paths differ. Review must freeze every format encoding, supported operation/type pair, widening or reinterpretation rule, and profile rejection before numeric vectors are generated.

The proposal under review observes that the 0.58.0 contract closes five distinct code namespaces and all 25 `TileDataType` identities, raw widths, reserved codes, and packed four-bit order. All 16 published public type identities have unambiguous catalog bindings and retain the A2/A3-versus-A5 availability baseline. Operation/type/profile legality and implementation conformance remain open; backend carrier types cannot create implicit PTO formats.

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

- Bind the specialized floating raw carriers and decide the public roles of F64 and E8M0.
- Publish bit-exact payload fields and exceptional-value classes for every floating type.
- Complete the scalar and tile operation/type legality matrix.
- Resolve the E5M2/E5M3FN spelling conflict.
- Publish positive and negative target-availability vectors for every accepted tuple.

## Acceptance obligations

- A bit-level format table.
- A complete operation/type legality matrix.
- Positive and reserved-format vectors.

## Decision

No format-legality result is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Public names, raw carriers, and target availability do not by
themselves define bit formats or legal operation/type pairs.

**中文。** 公开名称、raw carrier 与目标可用性本身不能定义位格式或合法操作/类型对。

### Detailed decision / 详细决策

**English.** The draft frames the required format table, specialized carrier
bindings, legality matrix, conflict resolution, and positive/reserved vectors.
These are acceptance obligations, not current semantics.

**中文。** 本 draft 界定所需格式表、专用 carrier 绑定、合法性矩阵、冲突解决及
positive/reserved vector；这些是接受义务，不是当前语义。

### What changed / 改动内容

#### English

- Documented unresolved format-legality decisions and blockers.
- Preserved namespace facts as inputs, not conclusions.
- Authorized no format or operation/type implementation.

#### 中文

- 记录未解决格式合法性决策与 blocker。
- 将命名空间事实保留为输入而非结论。
- 不授权任何格式或操作/类型实现。

### Scope and boundaries / 范围与边界

**English.** No bit-level layout, target support tuple, or conversion path is
accepted by this draft. Existing namespace and carrier-width facts remain
inputs only and do not close any listed blocker.
This draft does not authorize implementation.

**中文。** 本 draft 不接受任何位级布局、目标支持组合或转换路径；既有命名空间与
carrier 宽度仅是输入，不关闭任何 blocker。本 draft 不授权实现。
