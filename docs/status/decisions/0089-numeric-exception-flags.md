---
{
  "id": "ADR-0089",
  "title": "Numeric exception flags",
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
  "legacy_ids": ["PD-06"]
}
---
# ADR 0089: Numeric exception flags

## Context

The formal scalar surface owns NV, DZ, OF, UF, and NX hooks, but the audited public numeric contract does not define a complete producer, stickiness, or priority rule. Review must define per-operation flag production, simultaneous flags, stickiness, reset, and trap interaction for every scalar numeric domain.

The proposal under review treats NV, DZ, OF, UF, and NX as portable sticky architectural flags with the state, lifecycle, trap envelope, and 30-form producer ownership fixed by ADR 0038. Each of the 19 profile-owned forms still requires an exact produced flag set for every supported operation/type rule.

## Affected domains

- `scalar-binary`
- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-fused`
- `scalar-integer-to-fp`
- `scalar-unary`

## Alternatives considered

- portable normative rules; and
- named target-profile rules.

## Blockers

- Accept exact flag conditions for all 19 profile-owned scalar forms.
- Define tininess detection and NX coupling in every affected operation/type rule.
- Publish independent simultaneous-flag and special-value vectors.

## Acceptance obligations

- A flag-production matrix.
- Multi-flag priority and stickiness vectors.
- Reset and trap-preservation tests.

## Decision

No flag-production result is accepted by this draft.
