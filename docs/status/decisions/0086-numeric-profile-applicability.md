---
{
  "id": "ADR-0086",
  "title": "Numeric profile applicability",
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
  "legacy_ids": ["PD-01"]
}
---
# ADR 0086: Numeric profile applicability

## Context

The public contract names CPU, A2A3, and A5 capability profiles and says that profiles narrow support, while the numeric contract also exposes target-dependent result variation. The unresolved question is whether portable numeric results exist for each domain and which remaining differences are named target-profile rules rather than support restrictions.

ADR 0041 already closes the A2A3 unsupported-in-profile rule for all six MX CUBE selectors and all 25 `TileDataType` identities. The proposal under review is that legal PTO operations otherwise use `pto-numeric-v1` results, A2A3 and A5 reject only documented operation/type tuples, every accepted target-dependent result is selected by a named profile and bounded rule, and CPU observations are never normative.

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

- portable normative rules;
- named target-profile rules; and
- unsupported-in-profile dispositions.

## Blockers

- Complete every remaining domain operation/type applicability table after the accepted A2A3 MX negative slice.
- Accept one portable or target disposition for every supported and rejected tuple.

## Acceptance obligations

- An accepted profile taxonomy and version identifiers.
- A complete domain-to-profile applicability matrix.

## Decision

No rule is accepted by this draft. Review must choose and record the disposition for every affected tuple before implementation or maturity promotion.
