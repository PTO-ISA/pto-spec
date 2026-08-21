---
{
  "id": "ADR-0095",
  "title": "Bounded numeric variation",
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
  "legacy_ids": ["PD-12"]
}
---
# ADR 0095: Bounded numeric variation

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
