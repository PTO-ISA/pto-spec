---
{
  "id": "ADR-0093",
  "title": "Quantization contract",
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
  "legacy_ids": ["PD-10"]
}
---
# ADR 0093: Quantization contract

## Context

Implementation evidence contains multiple format, shared-exponent, scale, zero-point, clamping, and special-value paths that are not one portable arithmetic rule. Review must define scale and zero-point encoding, grouping axis and size, exponent selection, rounding, clamping, exceptional sentinels, packing, and inverse dequantization for every accepted format.

The proposal under review gives every accepted quantized format equations for scale, zero point, grouping, exponent selection, rounding, clamping, packing, tails, special values, and inverse dequantization. Formats without a complete rule reject in that profile.

## Affected domains

- `tile-dequantize`
- `tile-quantize`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- unsupported-in-profile dispositions.

## Blockers

- Resolve whether the affine parameter is scale or inverse-scale/pre-quant multiplier.
- Freeze format-specific equations and stochastic-rounding state.
- Define group axes, sizes, and tails.
- Define sentinels, packing, round-trip tolerances, and whether `SET_QUANT` configuration is architectural state.

## Acceptance obligations

- Format-specific quantization equations.
- Group and tail-boundary vectors.
- NaN, infinity, zero, maximum, tie, clamp, pack, and round-trip vectors.

## Decision

No quantization rule is accepted by this draft.
