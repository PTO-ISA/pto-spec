---
{
  "id": "ADR-NUM-0021",
  "title": "Matrix numeric contract",
  "title_zh": "矩阵数值契约",
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
    "PD-11",
    "ADR-0094"
  ]
}
---
# ADR-NUM-0021: Matrix numeric contract

## Context

CPU evidence uses host arithmetic and fused accumulation for selected types, while target paths use matrix hardware and A5 adds MX scale formats. Review must define product precision, accumulator width, accumulation order, intermediate rounding, saturation, bias order, source-accumulator order, MX scale interpretation, and special-value behavior per type tuple.

The proposal under review publishes legal type tuples and, for each tuple/profile, product precision, accumulator width and order, intermediate rounding, saturation, source-accumulator and bias order, MX scale interpretation, and special-value results. Unsupported MX tuples reject before effects.

## Affected domains

- `cube-matrix`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- unsupported-in-profile dispositions.

## Blockers

- Complete the legal type-tuple table.
- Freeze dot-product, HF32/TF32 selection, and accumulation arithmetic.
- Resolve the public A5 MX E4M3-only versus implementation FP4/mixed-FP8 conflict.
- Define MX scale layout, logical versus capacity K multiples, and non-A5 rejection.

## Acceptance obligations

- A legal type-tuple and accumulator table.
- Dot-product cancellation and halfway vectors.
- Bias, accumulate, MX scale, overflow, saturation, and exceptional-value vectors.

## Decision

No matrix numeric rule is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Host fused arithmetic and target matrix hardware do not establish
one PTO product, accumulator, ordering, scale, or special-value contract.

**中文。** Host fused 算术与目标矩阵硬件不能自动建立统一 PTO 乘积、累加器、顺序、
scale 或特殊值契约。

### Detailed decision / 详细决策

**English.** The draft requires a legal type-tuple table and, for each accepted
tuple, exact product precision, accumulator behavior, ordering, rounding,
saturation, bias/C order, MX scale meaning, and special-value vectors.

**中文。** 本 draft 要求合法类型组合表，并为每个接受组合精确定义乘积精度、累加器
行为、顺序、舍入、饱和、Bias/C 顺序、MX scale 含义及特殊值 vector。

### What changed / 改动内容

#### English

- Recorded the unresolved matrix numeric dimensions and conflicts.
- Defined tuple, arithmetic, and verification obligations.
- Authorized no matrix numeric implementation.

#### 中文

- 记录未解决矩阵数值维度与冲突。
- 定义类型组合、算术与验证义务。
- 不授权矩阵数值实现。

### Scope and boundaries / 范围与边界

**English.** Existing structural CUBE contracts remain; this draft adds no
arithmetic, scale, or supported tuple. Host fused behavior and hardware matrix
results remain evidence only and cannot select precision or accumulation
semantics. This draft does not authorize implementation.

**中文。** 既有结构性 CUBE 契约保持有效；本 draft 不新增算术、scale 或支持组合，
host fused 行为与硬件矩阵结果仅是证据，不能选择精度或累加语义。本 draft 不授权实现。
