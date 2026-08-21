# ADR-0033: TLSU four-bit memory packing and totality

> **Partially superseded:** ADR 0058 replaces logical-element row stride and
> indexed packed-transfer addressing. Regular TLOAD/TSTORE keep the packing
> rules below within each byte-strided row; indexed TLSU rejects packed
> four-bit transfer data until a separate nibble selector is architected.

- Status: Accepted
- Date: 2026-07-30
- Requirements: PTO-REQ-TLSU-001, PTO-REQ-MEMORY-COMPLETION-001,
  PTO-REQ-MEMORY-TSO-001

## Context

ADR-0013 defines packed storage for tile allocation capacity, but the tile
memory instructions still need an architectural byte-addressing rule for
sub-byte formats. The executable model carries every tile payload element in a
64-bit slot, so using `TileElementBytes` directly would make four-bit formats
look like byte formats during `TLOAD`, `TSTORE`, gather, scatter, masked
operations, and CAS.

That behavior is not a harmless implementation detail. It changes the address
footprint, makes odd tails consume a full extra byte incorrectly, hides sibling
nibble preservation obligations, and produces memory events that do not match
the intended PTO-v0 packed layout.

## Decision

For PTO v0 tile memory operations, four-bit tile data types use packed
byte-addressed memory:

- logical element `i` resides in byte `base + floor(i / 2)`;
- even logical elements use the low nibble;
- odd logical elements use the high nibble;
- loads zero-extend the selected nibble to XLEN, including signed four-bit
  formats;
- stores write only the selected nibble and preserve the sibling nibble;
- an odd final element writes its selected nibble and preserves the unused
  sibling bits in the containing byte.

ADR 0058 scopes this rule to regular TLOAD/TSTORE coordinates within each
byte-strided row. Indexed TLSU uses byte displacements and has no independent
nibble selector, so packed four-bit transfer data rejects before effects.

Every regular-transfer logical four-bit lane emits one byte-sized memory event.
Loads record the containing byte that was read. Stores record the containing
byte after the selected nibble update.

The complete containing-byte footprint is probed before the first payload,
memory, event, or reservation effect. This applies to regular TLOAD/TSTORE.
A failing probe leaves destination tiles, memory, events, and sibling nibbles
unchanged; recovery is full reissue. Indexed and TPREFETCH preflight remains
defined independently for their byte footprints.

TMOV does not access memory, but it is part of the TLSU function closure. It
copies payload, element definedness, valid-defined count, and whole-tile
definedness from source to destination.

## Consequences

- PTO-v0 TLSU no longer aliases the executable model's payload carrier width
  with architectural memory layout.
- Four-bit events are compatible with the byte-granular memory model while
  preserving exact nibble values in tile payloads.
- The packed layout is PTO-v0 architecture. A future profile may add another
  layout only by defining a profile-specific TLSU contract and preserving the
  generic totality, preflight, event, and restart guarantees.
- `spec/evidence/tlsu-totality.json` and `TestTlsuTotality()` are the closure
  hooks for this decision.

The executable matrix reaches all ten TLSU functions through decoded tile
dispatch. It also injects first, middle, and last footprint faults across the
contiguous, indexed, masked, prefetch, and conditional-atomic classes and
checks that no payload, memory, or event prefix escapes preflight.
E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 each execute regular load/store
witnesses, while indexed legality evidence rejects them as transfer data before
their payload can be observed.
