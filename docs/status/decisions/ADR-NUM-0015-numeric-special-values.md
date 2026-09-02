---
{
  "id": "ADR-NUM-0015",
  "title": "Numeric special values",
  "title_zh": "数值特殊值",
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
    "PD-05",
    "ADR-0088"
  ]
}
---
# ADR-NUM-0015: Numeric special values

## Context

ADR 0050 closes canonical produced NaNs plus comparison and min/max NaN and signed-zero selection for a bounded named-hardware operation set. Published and implementation evidence still distinguish propagation, sentinel, payload, infinity, conversion, reduction, quantization, matrix, and flag/status cases without one complete cross-operation rule.

The proposal under review extends the bit-exact rule beyond the bounded ADR 0050 checkpoint to infinity arithmetic, broader NaN creation, conversions, reductions, quantization, matrix operations, and the complete flag/status contract.

## Affected domains

- `cube-matrix`
- `scalar-binary`
- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-fused`
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
- implementation-defined rules with explicit allowed sets.

## Blockers

- Extend bit-exact NaN creation rules beyond comparison and min/max.
- Define infinity arithmetic and special results for conversions, reductions, quantization, and matrix operations.
- Complete signaling-NaN flag and status interactions for every affected family.

## Acceptance obligations

- A bit-exact special-value table extending ADR 0050.
- Coverage of all sign and payload classes.
- Binary, unary, conversion, compare, reduction, quantization, and matrix vectors.

## Decision

No additional special-value rule is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Existing checkpoints cover only bounded NaN, comparison, MIN/MAX,
and zero cases. Broader infinity, conversion, reduction, quantization, matrix,
and status behavior still needs one complete rule.

**中文。** 既有检查点只覆盖有界 NaN、比较、MIN/MAX 与零情况；更广泛的 infinity、
转换、归约、量化、矩阵与状态行为仍需完整规则。

### Detailed decision / 详细决策

**English.** The draft enumerates domains, alternatives, blockers, and vectors
needed to extend bit-exact special-value behavior. It does not extend the
already accepted bounded checkpoint.

**中文。** 本 draft 枚举扩展位精确特殊值行为所需的 domain、备选、blocker 与 vector，
但不扩展已经接受的有界检查点。

### What changed / 改动内容

#### English

- Recorded the missing cross-operation special-value contract.
- Identified payload, infinity, signaling, and status obligations.
- Authorized no new special-value implementation.

#### 中文

- 记录缺失的跨操作特殊值契约。
- 明确 payload、infinity、signaling 与状态义务。
- 不授权新的特殊值实现。

### Scope and boundaries / 范围与边界

**English.** Only prior accepted ADRs govern current special values; this draft
accepts no additional result. It does not extend canonical NaN, infinity,
payload, conversion, reduction, quantization, matrix, flag, or status behavior.
This draft does not authorize implementation.

**中文。** 当前特殊值仅由先前已接受 ADR 管理；本 draft 不接受附加结果，也不扩展
canonical NaN、infinity、payload、转换、归约、量化、矩阵、标志或状态行为。
本 draft 不授权实现。
