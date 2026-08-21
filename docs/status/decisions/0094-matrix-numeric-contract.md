---
{
  "id": "ADR-0094",
  "title": "Matrix numeric contract",
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
  "legacy_ids": ["PD-11"]
}
---
# ADR 0094: Matrix numeric contract

## Context

CPU evidence uses host arithmetic and fused accumulation for selected types, while target paths use matrix hardware and A5 adds MX scale formats. Review must define product precision, accumulator width, accumulation order, intermediate rounding, saturation, bias order, source-accumulator order, MX scale interpretation, and special-value behavior per type tuple.

The proposal under review publishes legal type tuples and, for each tuple/profile, product precision, accumulator width and order, intermediate rounding, saturation, source-accumulator and bias order, MX scale interpretation, and special-value results. Unsupported MX tuples reject before effects.

## Affected domains

- `cube-matrix`

## Alternatives considered

- portable normative rules;
- named target-profile rules; and
- unsupported-in-profile dispositions.

## Blockers

- Complete the legal type-tuple table.
- Freeze dot-product, HF32/TF32 selection, and accumulation arithmetic.
- Resolve the public A5 MX E4M3-only versus implementation FP4/mixed-FP8 conflict.
- Define MX scale layout, logical versus capacity K multiples, and non-A5 rejection.

## Acceptance obligations

- A legal type-tuple and accumulator table.
- Dot-product cancellation and halfway vectors.
- Bias, accumulate, MX scale, overflow, saturation, and exceptional-value vectors.

## Decision

No matrix numeric rule is accepted by this draft.
