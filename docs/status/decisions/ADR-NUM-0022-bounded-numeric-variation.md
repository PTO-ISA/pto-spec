---
{
  "id": "ADR-NUM-0022",
  "title": "Bounded numeric variation",
  "title_zh": "有界数值变化",
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
    "PD-12",
    "ADR-0095"
  ]
}
---
# ADR-NUM-0022: Bounded numeric variation

## Context

The public contract permits target variation but does not provide a complete allowed-result set or discovery mechanism for each numeric variation point. Review must name the selecting profile or visible mode for every non-portable result, bound the allowed results, and require generic validation to reject an unknown profile or unconfigured implementation-defined rule.

ADR 0042 inventories all 99 domain/dimension variation points and assigns their current decision owner to `pto-numeric-v1`. The proposal under review permits no unbounded implementation-defined numeric result. A future delegation must name a profile or visible mode, enumerate or mathematically bound allowed results, and provide discovery metadata. Generic validation rejects unknown profiles, unknown modes, and missing rules before effects.

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

- named target-profile rules;
- implementation-defined rules with explicit allowed sets; and
- unsupported-in-profile dispositions.

## Blockers

- Select one admissible route for every non-portable variation point.
- Populate a bounded allowed-result contract for every selected delegation.
- Add unknown-profile, unknown-mode, and missing-rule rejection vectors.

## Acceptance obligations

- A profile discovery and selection contract.
- Allowed-result sets for every implementation-defined rule.
- Unknown-profile and missing-rule rejection tests.

## Decision

No variation route or numeric result is accepted by this draft.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** A statement that targets may vary is unusable without a selector,
discoverable applicability, bounded results, and unknown-rule rejection.

**中文。** 若没有 selector、可发现适用性、有界结果与未知规则拒绝，仅声明目标可以
变化是不可验证的。

### Detailed decision / 详细决策

**English.** The draft proposes that every non-portable point choose a named
route with finite or mathematical result bounds and validation metadata. It
lists blockers and tests but accepts no delegation or result.

**中文。** 本 draft 提议每个非可移植变化点选择具名路线，并提供有限或数学可检验的
结果界与验证元数据；它列出 blocker 与测试，但不接受任何委托或结果。

### What changed / 改动内容

#### English

- Recorded required discovery and bounded-result contracts.
- Required unknown-profile, unknown-mode, and missing-rule rejection evidence.
- Authorized no implementation-defined numeric behavior.

#### 中文

- 记录所需发现机制与有界结果契约。
- 要求 unknown-profile、unknown-mode 与 missing-rule 拒绝证据。
- 不授权任何 implementation-defined 数值行为。

### Scope and boundaries / 范围与边界

**English.** Draft status means all proposed variation routes remain
non-normative and must not drive implementation. No selector, allowed-result
set, discovery record, unknown-rule disposition, or delegated owner is accepted.
This draft does not authorize implementation.

**中文。** Draft 状态意味着所有提议变化路线均非规范，不得驱动实现；当前不接受
selector、allowed-result set、发现记录、未知规则 disposition 或委托 owner。
本 draft 不授权实现。
