---
{
  "id": "ADR-0051",
  "title": "Predicate state namespace boundary (superseded)",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-08-01",
  "accepted": "2026-08-01",
  "rejected": null,
  "superseded": "2026-08-11",
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
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
# ADR 0051: Predicate state namespace boundary (superseded)

- Decision date: 2026-08-01

## Current boundary

PTO exposes P0 through P7 as eight independent 32-bit predicate registers.
P0 is hardwired to all ones; P1 through P7 reset to zero and are independently
trap-preserved. No accepted instruction produces or consumes this register
file.

Machine-parallel and machine-sequential block encodings are extension-reserved
and have no PTO execution semantics. Their former execution-mask model is not
architectural PTO state. Any future predicate namespace or instruction mapping
requires an explicit encoding, state, reset, trap, producer, consumer, and
executable-test contract.

This file records the superseded decision only. The current executable
contract is defined by the ASL programming-model and scalar BRU units.
