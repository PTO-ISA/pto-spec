---
{
  "id": "ADR-0012",
  "title": "Define PTO v0 ACRC service requests",
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
    "PTO-ACRC-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-SCALAR-ACRC"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0012: Define PTO v0 ACRC service requests

## Context

`ACRC` has an accepted 32-bit encoding and the trap catalog assigns `SCALL`
(6), but the previous semantic handler only incremented a diagnostic epoch. It
did not validate the request, save a return snapshot, route to a manager, or
take the architectural trap. Bundle-control faults incorrectly occupied the
same trap number before ADR 0010 corrected their identity.

## Decision

`ACRC request_type` takes a synchronous trap immediately after the instruction:

- ACR1 accepts machine request 0 and security request 2; both route to ACR0.
- ACR2 through ACR15 accept machine request 0, system request 1, and security
  request 2. System request 1 routes to ACR1; the others route to ACR0.
- ACR0 and all other request values are illegal and raise `ILLEGAL_INST` (4).
- A valid request reports `SCALL` (6), records the four-bit request in the low
  `CAUSE` bits, and records the ACRC instruction TPC in `TRAPARG0`.
- Because ACRC is a 32-bit instruction, `EBARG_TPC` records the following
  instruction at source TPC + 4. Recovery therefore advances past ACRC unless
  manager software deliberately rewrites the visible resume word.
- A valid ACRC returns the internal scalar execution status `Rejected` because
  control transferred through a synchronous trap; no sequential dispatch
  update occurs after the trap handler vector is installed.

The ACR2 rule from the reconciled public contract is extended uniformly to the
PTO v0 managed-ring range ACR2 through ACR15, consistent with ADR 0010.

## Consequences

The SCALL trap identity now has an architectural producer. Request legality,
routing, cause, argument, return snapshot, and recovery position are directly
testable. The broader bundle rule requiring ACRC placement next to a terminator
remains a bundle-formation closure target rather than an instruction-local
effect.
