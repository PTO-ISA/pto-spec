---
{
  "id": "ADR-0067",
  "title": "conditional branch extension reservation",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-18",
  "accepted": "2026-08-18",
  "rejected": null,
  "superseded": null,
  "baseline": "090126925e955f90cc1e23b07c1dbbd0f108b6f4",
  "target_releases": [
    "0.58.2"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-0046"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0067: conditional branch extension reservation

- Scope: `B.EQ`, `B.NE`, `B.LT`, `B.GE`, `B.LTU`, `B.GEU`, `B.Z`, `B.NZ`
- Requirement: PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001
- Supersedes: only the active-PTO conditional-branch clauses of ADR 0008,
  ADR 0027, and ADR 0046

## Decision

The eight named conditional branch families are not active PTO instructions.
Their complete 32-bit encoding forms are occupied extension space. PTO scalar
decode rejects every matching form before operand reads or architectural
effects, and PTO assembly/disassembly does not expose their spellings.

This reservation does not remove scalar comparison, `SETC.*`, `J`, `JR`, or
the block commit-target mechanisms. It changes no encoding outside the eight
reserved families.

## Rationale

The forms belong to the two-level block-body architecture. Keeping them in the
active PTO scalar catalog would contradict that ownership boundary and allow a
PTO implementation to consume extension encodings that must remain
collision-protected.
