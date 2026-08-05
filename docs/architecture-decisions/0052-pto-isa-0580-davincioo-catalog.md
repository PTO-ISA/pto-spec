# ADR 0052: PTO ISA 0.58.0 DavinciOO catalog

## Status

Accepted.

## Context

ADR 0045 froze the 0.57.1 Mode/Function ABI with 120 direct Tile operations.
The implementation architecture and the public intrinsic inventory have since
converged on a smaller DavinciOO catalog.  PTO-spec is the architecture source
of truth, not a target-profile overlay, so the formal catalog, instruction
pages, encoding workbook, decoder witnesses, handlers, and tests must move as
one release boundary.

## Decision

PTO ISA 0.58.0 accepts exactly 106 direct Tile operations: 87 TEPL, 7 TMA, and
12 CUBE. It accepts 96 bundle/command forms: the predecessor's 99-form set,
minus removed `BSTART.ACCCVT`, `BSTART.MGATHER.CAS`, `BSTART.MGATHER.MASK`, and
`BSTART.MSCATTER.MASK`, plus the new `BSTART.GMOV` form. `BSTART.GMOV` is the
named TMA start for TLSU Function 13.

The release adds `GMOV`, `TFMA`, and `TRANDOM`, and uses `TSORT32` as the sole
canonical spelling for selector `0x06C`.  `TMOV` remains accepted at Local
Function 2; Shared modes use Functions 8 through 11 at the command/lowering
boundary.  `TSEL` is fixed at Mode 0 / Function 26 (`0x01A`), while `TSELS`
remains Mode 1 / Function 26 (`0x03A`).  `TFMA` is Mode 0 / Function 28
(`0x01C`), and `TRANDOM` is Mode 3 / Function 9 (`0x069`).

`TADDC` is not accepted.  Its DavinciOO encoding observation is Mode 0 /
Function 24; the encoding remains reserved and is not conflated with `TFMA`.
`SYNCALL` remains a scalar/system scheduling operation and is not a Tile
operation.

The release replaces the v4 compressed `C.B.DIM RegSrc` slot with the 8-bit
`C.B.IOS SharedTID` binder. `S#0` through `S#255` name Core-local SharedTile
versions with descriptor/payload plus immutable four-region `defined_mask` and
internal `ready_mask`. Shared TLOAD, full/partition TSTORE, TMOV Functions
8–11, and cooperative TMATMUL consume the binder schemas defined by the public
0.58.0 architecture and instruction pages. Partial versions remain eligible
for movement and partition store, while Broadcast, full store, and cooperative
CUBE require fully-defined versions. TGEMV rejects every Shared binder.

All 12 CUBE operations write explicit Local D. ACC variants additionally read
explicit Local C with read-old/write-new alias behavior; PTO ISA 0.58.0 has no
architectural implicit ACC singleton.

The formal Markdown instruction pages live only under
`docs/instructions/tile/`.  The catalogs and ASL remain normative; each page is
the single human-facing description for that operation.  Generated Complete
HTML is tracked under `docs/html/`, with
`docs/DavinciOO_PTO_Intrinsic_Complete.html` as the stable entry point.

## Consequences

- Catalog, ASL decoder, semantic handler, operand binding, executable witness,
  Markdown, HTML, and Excel inventories must all report 106.
- Removed operations remain reserved or explicitly absent; they do not retain
  formal instruction pages in the Complete site.
- The 0.57.1 decision remains historical evidence and is not rewritten.
- DavinciOO consumes this repository as a later integration step; no profile
  fork is introduced in pto-spec.
