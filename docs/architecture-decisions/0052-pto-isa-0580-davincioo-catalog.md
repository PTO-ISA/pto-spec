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

As amended by ADRs 0053 and 0054, PTO ISA 0.58.0 accepts exactly 109 direct
Tile operations: 87 TEPL-carrier operations, 10 TLSU operations, and 12 CUBE
operations. The execution-engine partition is 35 VEC, 52 SFU, 10 TLSU, and
12 CUBE. It accepts 99 bundle/command forms. `BSTART.GMOV` is the named TLSU
start for Function 13.

The release adds `GMOV` and `TFMA`. `TRANDOM` is deleted and `TSORT` is the
canonical spelling for selector `0x06C`. `TMOV` remains accepted only at Local
Function 2. `TSEL` is fixed at Mode 0 / Function 26 (`0x01A`), while `TSELS`
remains Mode 1 / Function 26 (`0x03A`). `TFMA` is Mode 0 / Function 28
(`0x01C`). `MGATHER.MASK`, `MSCATTER.MASK`, and `MGATHER.CAS` occupy TLSU
Functions 6, 7, and 8; Functions 9–12 and 14 remain reserved in PTO.

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

The release assigns the former B.IOD 32-bit slot to `B.IOS`. `S0` through
`S255` name absolute Core-local Shared registers with persistent
descriptor/payload plus a four-PE initialization mask. Shared TLOAD/TSTORE use
`B.IOS` for identity, mask, and destination per-PE size; `B.IOT` is Local-only.
Cooperative TMATMUL consumes the operation-defined B.IOS binder sequence.
Destination updates are atomic RMWs; uninitialized reads have
undefined-register semantics. TGEMV rejects every Shared binder. `B.IOD` and
`C.B.IOS` are permanently deleted spellings.

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
  Markdown, HTML, and Excel inventories must all report 109.
- The normative Tile/Bundle ASL assertion inventory is pinned at 196 after the
  removed operations and replacement Shared-register model are accounted for.
- Removed operations remain reserved or explicitly absent; they do not retain
  formal instruction pages in the Complete site.
- The six Linx-only vector encodings are fail-closed canonical release inputs;
  PTO decoders must continue to reject them while Linx may define them.
- The 0.57.1 decision remains historical evidence and is not rewritten.
- DavinciOO consumes this repository as a later integration step; no profile
  fork is introduced in pto-spec.
