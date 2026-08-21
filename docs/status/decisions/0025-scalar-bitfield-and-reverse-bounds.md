---
{
  "id": "ADR-0025",
  "title": "Scalar bitfield and byte-reversal bounds",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-BCNT-DECISION-BINDING-001",
    "PTO-BIC-DECISION-BINDING-001",
    "PTO-BIS-DECISION-BINDING-001",
    "PTO-BXS-DECISION-BINDING-001",
    "PTO-BXU-DECISION-BINDING-001",
    "PTO-CLZ-DECISION-BINDING-001",
    "PTO-CTZ-DECISION-BINDING-001",
    "PTO-REV-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-SCALAR-BCNT",
    "PTO-SCALAR-BIC",
    "PTO-SCALAR-BIS",
    "PTO-SCALAR-BXS",
    "PTO-SCALAR-BXU",
    "PTO-SCALAR-CLZ",
    "PTO-SCALAR-CTZ",
    "PTO-SCALAR-REV"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0025: Scalar bitfield and byte-reversal bounds

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

- Scope: scalar `BXS`, `BXU`, `BIC`, `BIS`, `CLZ`, `CTZ`, `BCNT`, `REV`, and `HL.BFI`

## Decision

For the scalar bitfield forms, the six-bit `imml` field encodes the field
width minus one, so every encoded value selects a width from 1 through 64.
The six-bit `imms` or `immr` field independently selects the least-significant
source bit from 0 through 63. A field that crosses bit 63 wraps to bit 0.

`REV` extracts the selected wrapping field and reverses its bytes into the low
bits of the result. Bits above the selected width are zero. A selected width
that is not a multiple of eight completes normally and returns zero; it is not
an illegal instruction and raises no fault. `imml` and `immr` remain independent
encoded operands and must not be collapsed or substituted for one another.

`HL.BFI` uses its independently encoded `immr` as the first destination bit and
`imms` as the last destination bit. The inclusive destination interval wraps
through bit 63 when the last bit precedes the first bit. Source bit zero is
inserted at the first destination bit, with ascending source bits following the
wrapping destination interval.

All source values are read before the first destination write. Consequently,
an absolute or temporary-queue destination that aliases a source observes the
pre-instruction source value.

## Rationale

This disposition makes every value of the two six-bit bounds total without
silently treating adjacent fields as one operand. It preserves the existing PTO
catalog and executable reference behavior while making the non-byte `REV` result
an explicit architecture rule rather than an incidental implementation choice.

## Verification

`tests/asl/scalar/model/alu/semantics/scalar-bound-bitfield-contract-001.asl`
varies `imml` while holding `immr` fixed, varies
`immr` while holding `imml` fixed, exercises minimum, byte-aligned, wrapping,
non-byte, and full-width selections, and uses an aliased source/destination.
The catalog checker requires this ADR and the decoded boundary witness to remain
traceable from `PTO-REQ-SCALAR-ALU-001`.
