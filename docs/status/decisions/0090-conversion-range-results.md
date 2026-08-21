---
{
  "id": "ADR-0090",
  "title": "Conversion range results",
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
  "legacy_ids": ["PD-07"]
}
---
# ADR 0090: Conversion range results

## Context

The public contract records undefined hardware overflow where CPU simulation may saturate, and backend paths expose non-saturating wrap and target-specific control combinations. Review must choose a deterministic result or a bounded implementation-defined result set for every source, destination, rounding, saturation, NaN, infinity, and out-of-range combination.

The proposal under review requires every conversion cross-product to have one deterministic result, an enumerated profile-specific allowed-result set, or pre-effect rejection. Public undefined-overflow wording and CPU-only saturation cannot remain architectural outcomes.

## Affected domains

- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-integer-to-fp`
- `tile-convert`
- `tile-dequantize`
- `tile-quantize`

## Alternatives considered

- portable normative rules;
- named target-profile rules;
- implementation-defined rules with explicit allowed sets; and
- unsupported-in-profile dispositions.

## Blockers

- Complete the source/destination/rounding/saturation cross-product.
- Resolve the public CPU-saturation versus implementation default-OFF conflict.
- Choose overflow, NaN, and infinity results.
- Define non-saturating narrowing, wrap behavior, and omitted-saturation defaults per profile/type pair.

## Acceptance obligations

- A complete conversion cross-product.
- Minimum, maximum, one-past, NaN, and infinity vectors.
- Saturation-off wrap vectors.

## Decision

No conversion range result is accepted by this draft.
