# ADR 0052: Direct Tile and bundle catalog closure

## Status

Accepted.

## Context

The direct Tile catalog, bundle forms, ASL handlers, decoder witnesses,
instruction pages, and independent tests describe one architecture surface.
Changing only one projection would create a second, drifting instruction-set
definition.

## Decision

PTO accepts exactly 109 direct Tile operations: 87 operations on the TEPL raw
Mode/Function carrier, 10 TLSU operations, and 12 CUBE operations. The TEPL
carrier does not define the execution engine: each accepted operation is
classified canonically as VEC or SFU by its architectural hardware contract.

`BSTART.ACCCVT` is absent. `BSTART.GMOV`, `BSTART.MGATHER.MASK`,
`BSTART.MSCATTER.MASK`, and `BSTART.MGATHER.CAS` are accepted TLSU starts.
`GMOV`, `TFMA`, and `THISTOGRAM` are accepted direct operations. `TRANDOM` and
`TADDC` are absent. `TSORT` owns selector `0x06C` and carries an explicit
`sort_width` operand.

`TMOV` remains accepted at Local Function 2. `TSEL` owns Mode 0 / Function 26
(`0x01A`), `TSELS` owns Mode 1 / Function 26 (`0x03A`), and `TFMA` owns Mode 0
/ Function 28 (`0x01C`). Mode 3 / Function 9 (`0x069`) is reserved and rejects
before effects.

The complete two-level extension encoding space is reserved but not executed
by PTO. Its masks, matches, split fields, and widths are owned by
`asl/arch/overview/encoding-ownership.asl`. No accepted PTO scalar, block, or
Tile form may overlap those patterns, and PTO assigns no execution semantics
to them.

Every CUBE operation writes an explicit Local destination D. ACC variants also
read an explicit Local accumulator C. C is snapshotted before D is written, so
`D == C` has read-old/write-new behavior. PTO has no implicit accumulator
singleton.

ASL is the sole semantic owner. Catalogs, generated pages, decoder witnesses,
requirements, and AVS points are projections or evidence and must regenerate
together from the current ASL owners.

## Consequences

- The direct Tile catalog and all derived surfaces must report exactly 109
  operations with the same selectors, operand roles, and handlers.
- Removed spellings are absent unless a separate current decision explicitly
  reserves their raw space.
- Reserved extension encodings remain fail-closed and cannot be reassigned by
  a later PTO operation without a new architecture decision.
- CUBE destination and accumulator behavior is always explicit in the owning
  mnemonic contract.
- Current instruction pages embed the exact ASL decode and operation regions;
  no parallel prose catalog defines instruction behavior.
