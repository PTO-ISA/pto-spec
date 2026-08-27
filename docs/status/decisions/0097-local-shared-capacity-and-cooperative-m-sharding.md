---
{
  "id": "ADR-0097",
  "title": "Local and Shared capacity pools with cooperative M-sharding",
  "status": "accepted",
  "authors": ["Kevin Zhou <zhoubot@gmail.com>"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-23",
  "accepted": "2026-08-23",
  "rejected": null,
  "superseded": null,
  "baseline": "e599a3d36ebfad43362ff591ea5e128816c684c7",
  "target_releases": ["0.58.4"],
  "affected_ndf": [
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-CUBE-GROUP-M-DISTRIBUTION-001",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-INTEGER",
    "PTO-ARCH-FEATURES-TILE-ALLOCATION",
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-CAPACITY-LOCAL",
    "PTO-TILE-MODEL-CAPACITY-SHARED",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/132",
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0097: Local and Shared capacity pools with cooperative M-sharding

## Context

Local Tile state belongs to one PE, while Shared Tile state belongs to one
Core.  Using one combined capacity counter makes one PE's Local allocation
consume another PE's capacity and makes a Shared allocation scale with the
number of participating PEs.  Cooperative Matrix execution also requires one
explicit rule that maps per-PE M/N/K dimensions onto the Core-wide Shared-A
matrix.

## Decision

Each of the four PEs owns an independent 256 KiB Local capacity pool.  The
Core owns a separate 256 KiB Shared capacity pool.  Local and Shared
allocations do not compete for one combined budget.

`B.IOT` and `B.IOS` use the same SizeCode byte table.  Code zero is the source
role, codes 1 through 12 encode 128 B through 256 KiB, and codes 13 through 15
are reserved.  A Local `B.IOT` destination charges the selected size once in
each PE named by decoded PEMode.  A Shared `B.IOS` destination charges the
complete encoded size once in the Core-wide Shared pool; decoded PEMode
controls participation and payload-quarter updates but does not multiply the
Shared allocation.

A single Local object or destination is capped at 64 KiB (SizeCode 1..10).
The independent Local pool remains 256 KiB per PE, so multiple Local objects
may jointly consume that aggregate pool. A Shared parent remains capped at
256 KiB per Core.

`B.IOS` renames the identifier field to `SharedTileID`.  The field is six bits
at instruction bits 25:20 and names the absolute Core-private registers
`S0..S63`.  Bits 27:26 are reserved zero.  A nonzero reserved bit rejects as
`Fault_IllegalInstruction` before identifier, binder, descriptor, allocation,
payload, or memory effects.

For cooperative four-PE TMATMUL with a Shared left primary, `LB0`, `LB1`, and
`LB2` denote per-PE M, N, and K.  Shared A has logical shape
`(4 * LB0) x LB2`; Shared B has logical shape `LB2 x LB1`; PE `i` consumes
Shared-A rows `[i * LB0, (i + 1) * LB0)` and publishes one Local result of
shape `LB0 x LB1`.  The same rule applies to ordinary, ACC, BIAS, and MX forms
whenever their left matrix primary is Shared.  A Shared-B-only form retains
its PE-local A and common Shared B.  TGEMV remains Local-only.

Every encoding, capacity, group-shape, descriptor, readiness, alias, and
destination check completes before a source is consumed or any output becomes
visible.  Shared sources remain persistent and the existing complete-output
atomicity and restart rules remain in force.

## Consequences

- Multiple Local destinations may jointly consume one PE's complete 256 KiB
  pool, while each individual Local destination remains capped at SizeCode 10
  (64 KiB); other PEs retain their independent capacity.
- A Shared SizeCode-12 destination consumes the complete 256 KiB Shared pool.
- Reducing the Shared namespace changes the accepted B.IOS encoding mask and
  requires decoder, assembler, disassembler, compiler, model, and test updates.
- Cooperative Shared-A tests must distinguish the four fixed PE row slices;
  a broadcast of the first LB0 rows is not conforming behavior.
- The architecture and encoding ABI are incompatible with prior Shared
  capacity and identifier semantics.  The eventual release name is assigned
  only when the maintainers combine this decision with the remaining queued
  architecture changes; no release is created by this implementation.

## Supersession

This decision supersedes the per-PE Shared-capacity, combined-capacity-budget,
eight-bit Shared identifier, and cooperative Shared-A broadcast behavior in
the active model.  The B.IOT/B.IOS SizeCode and PEMode bit positions, PEMode
decode table, absolute Shared naming, strict zero-mode no-op, immutable first
allocation mask, and precise preflight/rollback rules remain in force.


## Amendment for 0.58.4.1

ADR-0102 owns the Shared whole-parent readiness and single-issuer publication
closure. ADR-0106 owns per-PE Shared source range derivation. The independent
Local object cap is 64 KiB while the aggregate Local pool remains 256 KiB per PE.
