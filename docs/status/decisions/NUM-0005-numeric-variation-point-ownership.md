---
{
  "id": "ADR-NUM-0005",
  "title": "Numeric variation-point ownership",
  "title_zh": "数值变化点归属",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-MATRIX-QUANT-BITEXACT-001",
    "PTO-TCVT-E8M0-PROFILE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-APPLICABILITY",
    "PTO-ARCH-PROFILE-E8M0-CONVERSION",
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-ARCH-PROFILE-MATRIX-QUANTIZATION",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0042"
  ]
}
---
# ADR-NUM-0005: Numeric variation-point ownership

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

Numeric result rules and allowed-result sets remain open.

## Context

`ADR 0095` requires every target-dependent or implementation-defined numeric
result to have a discoverable selector and a finite or mathematically testable
allowed-result contract. The closed numeric inventory already assigns 108
operations to 20 domains and 30 hooks, but it did not enumerate the individual
open dimensions within those domains. In PTO ISA 0.58.0 that inventory contains
104 operations, 18 domains, and 28 hooks. That made it possible to discuss a
profile or hook without proving ownership of every unresolved result choice.

The PTO architecture identifies target profiles and numeric variation but does
not yet supply complete allowed-result sets. No profile name, equal numeric
code, tool behavior, or implementation behavior becomes a numeric owner by
implication.

## Decision

The generated
`spec/evidence/numeric-variation-point-ownership.json` ledger is the
fail-closed discovery and ownership checkpoint for `ADR 0095`.

1. A variation point is one exact `(numeric domain, open dimension)` pair from
   `spec/evidence/numeric-contracts.json`. The current inventory contains 99
   points across all 20 domains.
2. Every point remains owned by the portable `pto-numeric-v1` architecture
   contract until an accepted PTO decision explicitly delegates that exact
   point to a named target profile or visible numeric selector, or marks the
   applicable operation/type/profile tuple unsupported.
3. The ledger maps every point to its complete operation and hook reachability.
   Separate operation and hook tables prove that all 108 operations and all 30
   hooks, including two library-only helpers, have one explicit owner boundary.
4. A target profile identity, selector namespace, backend behavior, or equal
   numeric code does not create a result rule. Delegation requires an accepted
   record, exact applicability, selector identity, and bounded allowed-result
   contract.
5. Unknown profiles, modes, formats, tuples, or missing delegated rules reject
   before architectural effects. The existing A2/A3 MX applicability decision
   remains the only accepted unsupported numeric slice: 150 tuples and zero
   result rules.

## Consequences

`S5-T2-A4` closes variation-point discovery and current-owner assignment. It
does not accept a numeric result, delegate a variation point, populate an
allowed-result set, or close `ADR 0095`. The generated ledger therefore records
99 portable-owner rows, zero accepted delegations, zero bounded result
contracts, and zero accepted domain result rules.

`ADR 0095` closes only after every non-portable row names its accepted profile or
visible selector, bounds its results, and has unknown-selection and
missing-rule rejection evidence. The other 11 numeric decisions, all 20 domain
rules, oracle qualification, vectors, differential execution, adjudication,
and independent approval remain open. The maturity floor remains M4.

The current ASL model has no generic named-target-profile selection boundary.
This checkpoint therefore proves evidence ownership only; it does not claim
executable rejection of an unknown profile. When that selection surface is
introduced, its unknown-profile and missing-rule paths require explicit
pre-effect tests before `ADR 0095` can close.

## Evidence

- `spec/evidence/numeric-variation-point-ownership.json`
- `scripts/generate-numeric-variation-point-ownership`
- `spec/evidence/numeric-contracts.json`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/catalog/numeric-profile-identities.json`
- `spec/evidence/numeric-rounding-selector-contract.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/numeric-profile-applicability-closure.json`
- `spec/profile-hooks.json`
- `scripts/check-catalogs`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Naming a domain or hook did not prove ownership of every open
result dimension. A point-level ledger is needed so no implementation-selected
numeric choice remains undiscovered.

**中文。** 仅命名 domain 或 hook 不能证明每个开放结果维度都有 owner。需要逐变化点
台账，确保不存在未被发现的实现自选数值行为。

### Detailed decision / 详细决策

**English.** Each `(domain, open dimension)` pair has one portable owner until
an accepted decision delegates that exact point with applicability, selector,
and bounded results. The ledger maps all points to reachable operations and
hooks; unknown or missing rules reject before effects.

**中文。** 每个 `(domain, open dimension)` 对在被接受决策以适用范围、selector 和
有界结果精确委托前，只有一个可移植 owner。台账把全部点映射到可达操作与 hook；
未知或缺失规则在副作用前拒绝。

### What changed / 改动内容

#### English

- Enumerated 99 variation points and their reachability.
- Assigned one explicit owner boundary to all operations and hooks.
- Required accepted, bounded delegation for any future variation.

#### 中文

- 枚举 99 个变化点及其可达关系。
- 为全部操作与 hook 指定唯一 owner 边界。
- 要求未来变化必须经接受且有界的委托。

### Scope and boundaries / 范围与边界

**English.** Ownership discovery does not choose any still-open numeric result.
It does not authorize a target-specific value, relax fail-closed rejection, or
replace the accepted decision required for a bounded delegation.

**中文。** owner 发现机制不选择任何仍开放的数值结果，也不授权目标专用数值、放宽
默认拒绝，或取代有界委托所必需的已接受决策与验证证据。
