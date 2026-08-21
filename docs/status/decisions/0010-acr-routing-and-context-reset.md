---
{
  "id": "ADR-0010",
  "title": "PTO v0 ACR routing and context reset",
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
    "PTO-REQ-STATE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-RESET",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-ARCH-SYSTEM-REGISTERS-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT",
    "PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE",
    "PTO-ARCH-SYSTEM-REGISTERS-TIMER"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0010: PTO v0 ACR routing and context reset

## Context

PTO exposes ACR0 through ACR15, banked context-family system registers, and a
shared trap envelope. The earlier reference profile routed an ACR1 fault to
ACR0, routed only ACR2 to ACR1, left ACR3 through ACR15 implicit, and reset only
the ACR0 extended-register bank. It also assigned the system-call trap number
to bundle-control faults even though the catalog defines separate bundle-trap
and system-call identities.

## Decision

- ACR0 is the root manager, ACR1 is the system manager, and ACR2 through ACR15
  are managed rings in the PTO v0 profile.
- A synchronous fault or interrupt sourced in ACR0 targets ACR0.
- A synchronous fault or interrupt sourced in ACR1 targets ACR1.
- A synchronous fault or interrupt sourced in ACR2 through ACR15 targets ACR1.
- Reset clears the complete catalog-defined context-family low-index range in
  all 16 ACR banks.
- Reset also clears every live GPR, T/U queue, P1 through P7, the bundle
  descriptor, tile descriptor and definedness bit, reservation, memory/event,
  fault, trap, and saved-context field. P0 is
  hardwired all-ones. Profile constants are then installed explicitly.
- Bundle-format and bundle-control faults report `BUNDLE_TRAP` (5).
- `SCALL` (6) remains reserved for the separately specified `ACRC` service-
  request transition and is not used as a bundle-control surrogate.

ADRs 0011, 0012, 0018, and 0019 define the visible trap snapshot, `ACRC`
request routing, `ACRE` restoration, trap disposition, and predicate
preservation that complete this reset envelope.

## Consequences

The routing function is total over all 16 ACRs. Reset cannot leak architectural
state between executions through a nonzero ACR bank, high register index,
predicate, tile, bundle descriptor, reservation, or saved context. Nonzero-seed
tests cover the lowest and highest boundaries and every trap bank.
