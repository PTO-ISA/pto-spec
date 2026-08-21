---
{
  "id": "ADR-0033",
  "title": "TLSU four-bit memory packing and totality",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-30",
  "accepted": "2026-07-30",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-BSTART-GMOV-COLLECTIVE-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TPREFETCH-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-GMOV-CORE4-PEER-001",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001",
    "PTO-MGATHER-MASK-PREDICATE-001",
    "PTO-MGATHER-MASK-PUBLICATION-001",
    "PTO-MGATHER-MASK-TYPE-002",
    "PTO-MSCATTER-BYTE-DISPLACEMENT-001",
    "PTO-MSCATTER-DUPLICATE-ORDER-001",
    "PTO-MSCATTER-MASK-DUPLICATE-001",
    "PTO-MSCATTER-MASK-PREDICATE-001",
    "PTO-MSCATTER-MASK-TYPE-002",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-TPREFETCH-FOOTPRINT-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-PACKED",
    "PTO-ARCH-STATE-TILE-DESCRIPTOR",
    "PTO-BLOCK-BSTART-GMOV",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TPREFETCH",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TMOV",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TSTORE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR-0033: TLSU four-bit memory packing and totality

> Refined by ADR 0074 for regular TLOAD/TSTORE: packing restarts at each
> byte-strided row base, and column parity selects the nibble within that row.
> The containing-byte and sibling-preservation rules remain in force.

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

Indexed TLSU operations apply the same rule to the logical index payload. For an
index value `j`, the accessed byte is `base + floor(j / 2)` and the selected
nibble is low for even `j` and high for odd `j`. Duplicate lane indices are
deterministic in row-major lane order. A later lane observes the byte state
left by earlier lanes in the same instruction after all lanes have passed the
instruction-wide preflight.

Every logical four-bit lane emits one byte-sized memory event. Loads and failed
CAS outcomes record the containing byte that was read. Stores and successful
CAS outcomes record the containing byte after the selected nibble update.
Failed CAS records the containing-byte value that would have been written if
the selected nibble comparison had succeeded, but it performs no write.

The complete containing-byte footprint is probed before the first payload,
memory, event, or reservation effect. This applies to contiguous TLOAD/TSTORE,
gather/scatter, masked gather/scatter for active lanes, CAS read/write probes,
and TPREFETCH byte footprints. A failing probe leaves destination tiles, memory,
events, and sibling nibbles unchanged; recovery is full reissue.

Masked gather is a read-modify-preserve operation over destination tile state:
inactive lanes retain their existing destination elements. Direct helper use
therefore requires the destination valid region to already be defined.

TMOV does not access memory, but it is part of the TLSU selector closure. It
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

The executable matrix reaches all ten TLSU selectors through decoded Tile
dispatch. It also injects first, middle, and last footprint faults across the
contiguous, indexed, masked, prefetch, and conditional-atomic classes and
checks that no payload, memory, or event prefix escapes preflight.
FP4, FPL4, S4, and U4 each execute load, store, and indexed-gather witnesses;
source-like direct helper operands assert allocated, defined tile state before
their payload can be observed.
