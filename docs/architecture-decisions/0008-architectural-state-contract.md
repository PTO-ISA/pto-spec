# ADR-0008: Define the PTO architectural state contract

- Status: accepted
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
  no PTO ISA 0.57.1 instruction consumer. A separate 64-bit execution mask is
  active only in MPAR and MSEQ bodies, where scalar B.Z and B.NZ consume it.
  See ADR 0046.
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

- The accepted direct Tile catalog contains 109 operations: 87 use the TEPL
  encoding carrier, 10 use TLSU functions, and 12 use CUBE functions. The
  execution-engine partition is 35 VEC, 52 SFU, 10 TLSU, and 12 CUBE.
- Vector instruction execution is outside PTO.
- Implementations may use physical queues, layouts, or pipelines, but they must
  preserve the state and fault behavior defined by the ASL.
