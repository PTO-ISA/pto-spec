---
{
  "id": "ADR-NUM-0018",
  "title": "Elementary-function accuracy",
  "title_zh": "初等函数精度",
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
    "PD-08",
    "ADR-0091"
  ]
}
---
# ADR-NUM-0018: Elementary-function accuracy

## Context

CPU and target implementations use different library, intrinsic, or custom approximation paths, so matching operation names do not establish equal numeric results. Review must define exact rounding or an explicit accuracy bound, monotonicity requirement, domain errors, and special-value results for division, reciprocal, square root, reciprocal square root, logarithm, exponential, and exponential difference.

The proposal under review uses a versioned independent high-precision oracle plus a named per-profile ULP or relative-error bound, domain table, monotonicity rule, and special-value table. CPU host-library and hardware primitive results remain observations, not the oracle.

## Affected domains

- `scalar-binary`
- `scalar-unary`
- `tile-binary`
- `tile-expand`
- `tile-unary`

## Alternatives considered

- correctly rounded portable rules;
- named profile error bounds; and
- unsupported-in-profile dispositions.

## Blockers

- Choose the oracle and version.
- Set per-operation/type/profile error bounds.
- Define domain boundaries and monotonic intervals.

## Acceptance obligations

- A versioned high-precision oracle.
- A ULP or relative-error rule.
- Domain-boundary and monotonicity vectors.

## Decision

No accuracy bound is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Host libraries and hardware approximations can differ even when
operation names match, so accuracy requires an independent oracle and explicit
bounds.

**中文。** 即使操作名相同，host library 与硬件近似也可能不同，因此精度需要独立
oracle 与显式界限。

### Detailed decision / 详细决策

**English.** The draft scopes division, reciprocal, roots, log, exp, and exp-
difference and requires oracle versioning, per-operation bounds, domains,
monotonicity, and special-value vectors. No bound is chosen.

**中文。** 本 draft 覆盖除法、倒数、根、log、exp 与 exp-difference，并要求 oracle
版本、逐操作界限、domain、单调性和特殊值 vector；当前不选择任何界限。

### What changed / 改动内容

#### English

- Recorded the elementary-function conformance gap.
- Defined oracle and vector acceptance obligations.
- Authorized no approximation or accuracy implementation.

#### 中文

- 记录初等函数符合性缺口。
- 定义 oracle 与 vector 接受义务。
- 不授权任何近似或精度实现。

### Scope and boundaries / 范围与边界

**English.** CPU or hardware outputs remain observations, not normative results
or validation oracles. No ULP bound, relative-error bound, monotonic interval,
domain result, or special-value rule may be inferred from them.
This draft does not authorize implementation.

**中文。** CPU 或硬件输出仍是观测，不是规范结果或验证 oracle；不得据此推断 ULP
界限、相对误差、单调区间、domain 结果或特殊值规则。本 draft 不授权实现。
