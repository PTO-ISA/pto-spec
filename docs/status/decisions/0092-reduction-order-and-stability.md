---
{
  "id": "ADR-0092",
  "title": "Reduction order and stability",
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
  "legacy_ids": ["PD-09"]
}
---
# ADR 0092: Reduction order and stability

## Context

CPU and target reduction trees differ, optimized shapes may change grouping, and selected integer paths widen then narrow with wrap behavior. Review must freeze accumulation width and order, overflow behavior, NaN and signed-zero selection, argument tie-breaking, partial merge behavior, and stable ordering requirements.

The proposal under review makes integer widths, overflow, comparison order, argument ties, and stable ordering portable and exact. Floating reductions would define an exact tree per profile or a finite and testable allowed-result contract, including NaNs, signed zero, and partial merge order.

## Affected domains

- `tile-compare`
- `tile-order`
- `tile-partial`
- `tile-reduction`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- implementation-defined rules with explicit allowed sets.

## Blockers

- Freeze accumulator widths and trees.
- Define argument and equal-value ties.
- Bound floating permutation sensitivity and partial merges.

## Acceptance obligations

- A reduction-tree or allowed-result contract.
- Permutation and tie vectors.
- Widening, overflow, NaN, zero, and partial-merge vectors.

## Decision

No reduction rule is accepted by this draft.
