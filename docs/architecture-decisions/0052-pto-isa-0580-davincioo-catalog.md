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

PTO also reserves, but does not execute, the exact Linx-only two-level vector
encodings for `BSTART.VPAR`, `BSTART.VSEQ`, `C.BSTART.VPAR`,
`C.BSTART.VSEQ`, `V.QPOP`, and `V.QPUSH`. The authoritative masks, matches,
split fields, and widths are published in
`spec/catalog/linx-vector-reservations.json`. No accepted PTO scalar or command
form may overlap those patterns. Linx ISA 0.58.0 consumes the same reservation
catalog when enabling its additional vector architecture.

The reviewed 0.58.0 scalar/command encoded-form projection contains exactly
570 forms and has SHA-256 fingerprint
`aaaf95c76cacd6843637ebc7ce5b9939ed82d4bafe18f65660bd809dd02acf8c`.
The binary-closure gate pins this value so any later encoding drift requires a
new normative decision instead of silently changing the release ABI.

The release replaces the v4 compressed `C.B.DIM RegSrc` slot with the 8-bit
`C.B.IOS SharedTID` binder. `S0` through `S255` name absolute Core-local Shared
registers with persistent descriptor/payload plus a four-quarter initialization
mask. Shared TLOAD/TSTORE accept optional mask-only B.IOT, TMOV Functions 8–11
and cooperative TMATMUL consume the binder schemas defined by the public 0.58.0
architecture and instruction pages. Destination updates are atomic RMWs;
uninitialized reads have undefined-register semantics. TGEMV rejects every
Shared binder.

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
- The normative Tile/Bundle ASL assertion inventory is pinned at 180 after the
  removed operations and replacement Shared-register model are accounted for.
- Removed operations remain reserved or explicitly absent; they do not retain
  formal instruction pages in the Complete site.
- The six Linx-only vector encodings are fail-closed canonical release inputs;
  PTO decoders must continue to reject them while Linx may define them.
- The 0.57.1 decision remains historical evidence and is not rewritten.
- DavinciOO consumes this repository as a later integration step; no profile
  fork is introduced in pto-spec.
