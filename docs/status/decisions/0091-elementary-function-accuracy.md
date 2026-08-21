---
{
  "id": "ADR-0091",
  "title": "Elementary-function accuracy",
  "status": "draft",
  "authors": ["Kevin Zhou <zhoubot@gmail.com>"],
  "approvers": [],
  "created": "2026-08-21",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": ["unassigned"],
  "affected_ndf": [],
  "affected_units": [],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": ["PD-08"]
}
---
# ADR 0091: Elementary-function accuracy

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
