---
{
  "id": "ADR-0088",
  "title": "Numeric special values",
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
  "legacy_ids": ["PD-05"]
}
---
# ADR 0088: Numeric special values

## Context

ADR 0050 closes canonical produced NaNs plus comparison and min/max NaN and signed-zero selection for a bounded named-hardware operation set. Published and implementation evidence still distinguish propagation, sentinel, payload, infinity, conversion, reduction, quantization, matrix, and flag/status cases without one complete cross-operation rule.

The proposal under review extends the bit-exact rule beyond the bounded ADR 0050 checkpoint to infinity arithmetic, broader NaN creation, conversions, reductions, quantization, matrix operations, and the complete flag/status contract.

## Affected domains

- `cube-matrix`
- `scalar-binary`
- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-fused`
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
- implementation-defined rules with explicit allowed sets.

## Blockers

- Extend bit-exact NaN creation rules beyond comparison and min/max.
- Define infinity arithmetic and special results for conversions, reductions, quantization, and matrix operations.
- Complete signaling-NaN flag and status interactions for every affected family.

## Acceptance obligations

- A bit-exact special-value table extending ADR 0050.
- Coverage of all sign and payload classes.
- Binary, unary, conversion, compare, reduction, quantization, and matrix vectors.

## Decision

No additional special-value rule is accepted by this draft.
