---
{
  "id": "ADR-NUM-0001",
  "title": "Numeric profile identity and bounded variation framework",
  "title_zh": "数值配置标识与有界变化框架",
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
    "ADR-0037"
  ]
}
---
# ADR-NUM-0001: Numeric profile identity and bounded variation framework

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Context

`S5-T2` requires target numeric conformance without allowing CPU, A2A3, or A5
implementation behavior to become PTO semantics implicitly. The public PTO
contract permits target profiles to narrow support and identifies numeric
variation points, while also stating that target profiles cannot redefine the
semantics of legal PTO operations.

The active `pto-v0` implementation profile is deterministic reference
behavior. Accepted finite scalar FP32/FP64 and shared conversion subsets use
their typed mathematical rules; remaining carrier or delegated hooks still do
not make `pto-v0` an IEEE or target-hardware profile. CPU simulation is also
an implementation under test, so its host arithmetic cannot qualify itself as
the independent oracle.

The numeric decision register retains 12 questions over 20 domains. Exact
format encodings, rounding modes, subnormal handling, special values, flags,
conversion overflow, elementary-function accuracy, reductions, quantization,
and matrix arithmetic remain unresolved. Identity and selection rules can be
closed without choosing those results.

## Decision

PTO defines four stable numeric configuration identities in
`spec/catalog/numeric-profile-identities.json`:

| Identity | Kind | Normative role |
| --- | --- | --- |
| `pto-numeric-v1` | Portable numeric contract | Defines the future portable result, legality, and rejection rules for accepted numeric operation/type tuples. |
| `pto-cpu-observation-v1` | Observation only | Names reproducible CPU implementation observations; it is neither an architecture profile nor an independent oracle. |
| `pto-a2a3-numeric-v1` | Target numeric profile | Names A2A3 support restrictions and explicitly delegated, bounded target rules. |
| `pto-a5-numeric-v1` | Target numeric profile | Names A5 support restrictions and explicitly delegated, bounded target rules. |

These identities are accepted independently of their still-open rule bodies.
Naming an identity does not claim that an operation/type tuple is supported,
that a numeric result is known, or that conformance has been demonstrated.

The following selection rules are normative:

1. PTO ASL, accepted architecture decisions, and the numeric identity catalog
   define the numeric profile boundary. Backend behavior is evidence only.
2. A target profile may reject an operation/type tuple through a complete,
   versioned support matrix. It may not silently change the portable result of
   an accepted tuple.
3. A portable rule may delegate a result dimension only to a named target
   profile or visible numeric mode with a finite or mathematically testable
   allowed-result contract. Unbounded `implementation-defined` numeric behavior
   is not a closure disposition.
4. Unknown identities, modes, formats, operation/type tuples, and missing
   delegated rules reject before architectural effects.
5. CPU observations are diagnostic evidence from an implementation under test.
   They cannot define a PTO result or serve as the independent S5-T2 oracle.

`pto-v0` remains the active executable reference profile. The new identities
do not alter, inherit, or re-label its arithmetic as target behavior.

## Consequences

The identity and selection-framework sub-stage `S5-T2-A1` is closed: all four
identities have stable spellings, kinds, selection boundaries, and this accepted
decision record. The remaining numeric decisions are not closed.

`ADR 0086` remains open until every domain has a complete portable/target support
and result-rule applicability matrix. `ADR 0095` remains open until every delegated
variation point has an accepted selector and allowed-result contract. The other
ten questions, all 20 domain rules, all six oracle qualifications, vectors,
target captures, differential dispositions, and independent approvals remain
open. The maturity floor therefore remains M4 and `S5-T2` remains open.

Future target profiles must implement the complete profile-hook registry for
their supported surface and provide profile, oracle, vector, result, and review
evidence without changing `pto-v0` silently.

## Evidence

- `spec/catalog/numeric-profile-identities.json`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/numeric-profile-decision-proposals.json`
- `spec/evidence/numeric-conformance-readiness.json`
- `asl/arch/profile/applicability.asl`
- `asl/arch/profile/reference-profile.asl`
- `asl/arch/profile/reset.asl`
- `scripts/check-catalogs`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Target observations must not silently become PTO numeric semantics.
Stable identities and explicit delegation boundaries make every variation
reviewable while leaving unresolved result rules visibly open.

**中文。** 目标观测不能静默变成 PTO 数值语义。稳定标识与显式委托边界使每个变化
都可审查，同时让尚未解决的结果规则保持明确开放。

### Detailed decision / 详细决策

**English.** The ADR names four configuration identities, separates portable
rules, CPU observations, and target restrictions, and requires complete support
matrices plus bounded delegated results. Unknown or missing rules reject before
effects; identity alone proves neither support nor conformance.

**中文。** 本 ADR 命名四个配置标识，区分可移植规则、CPU 观测和目标限制，并要求
完整支持矩阵及有界委托结果。未知或缺失规则在副作用前拒绝；标识本身既不证明
支持，也不证明符合性。

### What changed / 改动内容

#### English

- Added stable numeric configuration identities and selection boundaries.
- Required bounded, named delegation and fail-closed missing-rule handling.
- Kept unresolved numeric result bodies open.

#### 中文

- 增加稳定数值配置标识与选择边界。
- 要求有界、具名委托及缺失规则默认拒绝。
- 保持未解决数值结果正文开放。

### Scope and boundaries / 范围与边界

**English.** This framework does not choose format, rounding, flag, conversion,
reduction, quantization, or matrix results. Each such rule still requires its
own accepted decision, exact applicability, owning ASL, and independent
verification evidence.

**中文。** 本框架不选择格式、舍入、标志、转换、归约、量化或矩阵结果。
