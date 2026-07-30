# ADR 0017: Classify every visible system register behavior

## Status

Accepted.

## Context

The system-register catalog already fixed 72 identities, addresses, and access
classes, but those fields did not state reset values, read behavior, write
behavior, side effects, or whether a register was active in `pto-v0`. That made
generic backing storage indistinguishable from an implemented architectural
effect and prevented a defensible Stage 2 closure claim.

The PTO v0 memory profile uses identity translation. Its debug matcher is not
implemented. The corresponding visible registers still need deterministic
access and reset behavior without implying that stored values affect address
translation or instruction/data matching.

## Decision

- `spec/catalog/system-registers.json` assigns every one of the 72 register
  definitions to exactly one behavior class. A class defines reset, read,
  write, side effects, and profile status.
- The catalog checker rejects missing, duplicate, unknown, access-inconsistent,
  or malformed classifications.
- Generated executable witnesses check reset for every visible base address,
  every bank of each ACR-family register, and every fixed-context register.
  They also prove read-only rejection and preservation, write-only rejection,
  and read/write round trips.
- `TIME`, `CYCLE`, and `TIMER_TIME` expose the architectural execution-attempt
  counter. `VERSION` resets to one, `TILE_CAPACITY` resets to the profile model
  limit, and `ECONFIG` resets with external and timer collection enabled. All
  other visible storage resets to zero unless a later profile decision changes
  its declared class.
- Translation configuration registers are readable and writable storage in
  `pto-v0`, but identity translation does not consume their values.
- `XBINFO` and `ACR_PARAM` are readable and writable storage in `pto-v0`; no
  current profile operation consumes their values.
- Debug identity, breakpoint, comparator, and watchpoint registers are visible
  storage in `pto-v0`, but debug matching is disabled. Consequently, storing a
  value does not itself produce a hardware breakpoint or watchpoint trap.
- Storage-only is an explicit profile behavior, not shorthand for an omitted
  definition. A future active translation or debug profile needs a distinct
  profile identity, defined field layouts and effects, and executable
  conformance evidence.

The catalog is normative PTO material. Comparison implementations remain
evidence only and cannot silently activate a storage-only class.

## Consequences

The generated system-register reference now displays reset, read, write, and
profile status for every register. Stage target `S2-T1` is mechanically and
behaviorally closed for `pto-v0`; trap-producer closure remains a separate
`S2-T3` obligation. In particular, the storage-only debug decision does not by
itself define producers for hardware breakpoint or watchpoint trap identities.
