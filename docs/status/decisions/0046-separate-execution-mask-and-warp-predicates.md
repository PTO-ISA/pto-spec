---
{
  "id": "ADR-0046",
  "title": "Separate execution-mask and predicate domains (superseded)",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": "2026-08-11",
  "baseline": "2f3f605e289b09d56ef5a9ba39fc80b52948a5f5",
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
    "ADR-0077",
    "ADR-0067"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0046: Separate execution-mask and predicate domains (superseded)

> The historical `B.Z`/`B.NZ` consumer clause is also superseded by ADR 0067.
> PTO has no accepted conditional-branch consumer for the machine execution
> mask.

- Decision date: 2026-07-31

## Superseding decision

The earlier decision modeled a separate execution mask for machine-parallel
and machine-sequential block bodies. PTO no longer accepts those block-start
families and reserves their complete encoding space. PTO therefore has no
machine-body execution-mask state, entry behavior, trap payload, or branch
selection rule.

P0 through P7 remain distinct 32-bit predicate registers. P0 reads all ones
and ignores writes; P1 through P7 reset to zero and are trap-preserved. No
accepted PTO instruction produces or consumes them. `B.Z` and `B.NZ` consume
the bundle commit argument established by `SETC.*`.

This file records the superseded decision only. The current executable
contract is defined by the ASL architecture and scalar BRU units.
