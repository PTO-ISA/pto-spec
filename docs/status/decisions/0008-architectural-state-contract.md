---
{
  "id": "ADR-0008",
  "title": "Define the PTO architectural state contract",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "007844f182ca87c843ebf274d7c9509188e68e01",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-REQ-BUNDLE-STATE-001",
    "PTO-REQ-SHARED-TILE-001",
    "PTO-REQ-STATE-001",
    "PTO-REQ-TILE-001",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS",
    "PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS",
    "PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS",
    "PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS",
    "PTO-ARCH-STATE-DEFINEDNESS",
    "PTO-ARCH-STATE-PROGRAM-COUNTER",
    "PTO-ARCH-STATE-TILE-DESCRIPTOR",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-ARCH-SYSTEM-REGISTERS-CONTEXT",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-MODEL-STATE-BINDING-STATE",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR-0008: Define the PTO architectural state contract

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

> The `B.Z`/`B.NZ` consumer clause is superseded by ADR 0067. Those spellings
> are extension-reserved and are not active PTO instructions.

- Decision date: 2026-07-28
- Requirement: PTO-REQ-STATE-001

## Context

The architecture requires a scalar-bundle and tile-state contract with explicit
register, predicate, access-control, trap, system-register, and tile descriptor
state. Older bridge and pipe-management wording did not match that contract.

## Decision

- The five-bit scalar register namespace contains 24 absolute GPRs and eight
  temporary operands: T#1..T#4 and U#1..U#4. A queue push shifts older entries
  toward `#4` and discards the previous `#4` value.
- The architecture exposes eight 32-bit per-warp predicate registers. P0 is
  hardwired all-ones; P1 through P7 are independent trap-preserved state with
  no accepted PTO instruction consumer. Scalar `B.Z` and `B.NZ` consume the
  bundle commit argument established by `SETC.*`.
- Access is governed by ACR0..ACR15. PTO v0 resets to ACR0, restricts extended
  system-register families to ACR0, and applies its protected memory region to
  ACR2 through ACR15.
- Trap status, trap cause, and trap argument are banked by ACR. A fault or
  interrupt records the active bank, and the context-family system-register
  address selects which bank ACR0 software observes.
- The base system-register names include `THREAD_PTR`, `GLOBAL_PTR`,
  `BLOCKID`, `THREAD_ID`, `CORE_STATE`, `CORE_ID`, and `TILE_CAPACITY`.
- Bundle execution state includes TPC, BPC, bundle active/body flags, bundle
  condition, bundle arguments, dimensions, IO bindings, control attributes, and
  data attributes.
- Each tile register has a `TileInfo` descriptor. Allocation or reconfiguration
  makes its contents undefined until an architectural write defines them.
- An implementation-defined layout may be recorded in `TileInfo`, but the
  portable generic indexing operation rejects that layout. A profile-specific
  operation must define any access to it.
- Aggregate tile capacity is bounded by the read-only `TILE_CAPACITY` system
  register. PTO v0 sets that register to 256 KiB; the ASL verification model
  supports values up to that bound.
- Pipe state is not architectural. PTO models allocation, definedness, and
  handoff through scalar queues, bundle bindings, and `TileInfo`.

## Consequences

- The accepted direct Tile catalog contains 109 operations: 87 use the
  unchanged TEPL Mode/Function carrier, 10 use TLSU, and 12 use CUBE. The TEPL
  carrier operations are classified architecturally as VEC or SFU.
- Vector instruction execution is outside PTO.
- Implementations may use physical queues, layouts, or pipelines, but they must
  preserve the state and fault behavior defined by the ASL.
