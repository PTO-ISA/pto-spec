# ADR 0010: PTO v0 ACR routing and context reset

## Status

Accepted.

## Context

PTO exposes ACR0 through ACR15, banked context-family system registers, and a
shared trap envelope. The earlier reference profile routed an ACR1 fault to
ACR0, routed only ACR2 to ACR1, left ACR3 through ACR15 implicit, and reset only
the ACR0 extended-register bank. It also assigned the system-call trap number
to bundle-control faults even though the catalog defines separate bundle-trap
and system-call identities.

The public source reconciliation establishes the three-level behavior for
ACR0, ACR1, and ACR2. PTO extends the managed application-ring role uniformly
from ACR2 through ACR15, matching the existing PTO v0 access and protected-
memory policy.

## Decision

- ACR0 is the root manager, ACR1 is the system manager, and ACR2 through ACR15
  are managed rings in the PTO v0 profile.
- A synchronous fault or interrupt sourced in ACR0 targets ACR0.
- A synchronous fault or interrupt sourced in ACR1 targets ACR1.
- A synchronous fault or interrupt sourced in ACR2 through ACR15 targets ACR1.
- Reset clears the complete catalog-defined context-family low-index range in
  all 16 ACR banks.
- Reset also clears every live GPR, T/U queue, P1 through P7, the stored
  machine execution mask, bundle descriptor, tile descriptor and definedness
  bit, reservation, memory/event, fault, trap, and saved-context field. P0 is
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
