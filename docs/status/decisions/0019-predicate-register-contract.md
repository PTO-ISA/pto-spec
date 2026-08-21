---
{
  "id": "ADR-0019",
  "title": "Define the PTO predicate-register contract",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": "2026-08-11",
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [
    "ADR-0077"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0019: Define the PTO predicate-register contract

## Historical context

This decision identified that every visible predicate needs explicit reset,
preservation, producer, and consumer rules. The current PTO contract retains
only P0 through P7: P0 is hardwired all ones, P1 through P7 are independently
trap-preserved, and no accepted instruction consumes them. Machine-block
encodings and their former execution-mask model are outside PTO.
