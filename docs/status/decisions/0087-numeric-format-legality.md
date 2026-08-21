---
{
  "id": "ADR-0087",
  "title": "Numeric format legality",
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
  "legacy_ids": ["PD-02"]
}
---
# ADR 0087: Numeric format legality

## Context

The public type names span IEEE, BF16, FP8, specialized eight-bit, four-bit, and integer carriers, but target availability and conversion paths differ. Review must freeze every format encoding, supported operation/type pair, widening or reinterpretation rule, and profile rejection before numeric vectors are generated.

The proposal under review observes that the 0.58.0 contract closes five distinct code namespaces and all 25 `TileDataType` identities, raw widths, reserved codes, and packed four-bit order. All 16 published public type identities have unambiguous catalog bindings and retain the A2/A3-versus-A5 availability baseline. Operation/type/profile legality and implementation conformance remain open; backend carrier types cannot create implicit PTO formats.

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

- Bind the specialized floating raw carriers and decide the public roles of F64 and E8M0.
- Publish bit-exact payload fields and exceptional-value classes for every floating type.
- Complete the scalar and tile operation/type legality matrix.
- Resolve the E5M2/E5M3FN spelling conflict.
- Publish positive and negative target-availability vectors for every accepted tuple.

## Acceptance obligations

- A bit-level format table.
- A complete operation/type legality matrix.
- Positive and reserved-format vectors.

## Decision

No format-legality result is accepted by this draft.
