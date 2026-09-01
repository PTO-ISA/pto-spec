---
{
  "id": "ADR-0056",
  "title": "PTO Encoding Ownership and Per-PE GM Access",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-08",
  "accepted": "2026-08-08",
  "rejected": null,
  "superseded": null,
  "baseline": "488955c9918d89dc710719c3c981ff273312915f",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-ARCH-GM-ACCESS-001",
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
    "PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS",
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
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
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
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
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/54",
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0056: PTO Encoding Ownership and Per-PE GM Access

> Superseded in part by ADR 0074: the retained TLOAD/TSTORE per-PE row-stride
> selector carries bytes rather than logical elements. Encoding ownership,
> PE-private resolution, masks, preflight, and ordering remain in force.

- **Date**: 2026-08-08
- **Deciders**: PTO ISA maintainers
- **Issue**: [#54](https://github.com/PTO-ISA/pto-spec/issues/54)

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

## Context

The PTO instruction set had accumulated three ownership defects: retired
spellings were represented as if they still owned encoding space, vector
extension reservations covered only individual examples rather than the
complete extension root, and Shared TLSU execution resolved one dispatching
PE's scalar values for all four Shared quarters.

## Decision

The normative contracts are owned by
`asl/arch/overview/encoding-ownership.asl` and
`asl/arch/memory-model/global-memory-access.asl`; this ADR records rationale
and does not create a second instruction definition.

PTO owns every accepted scalar, block, and Tile encoding in this repository.
It also reserves all four two-level vector block starts and the complete 64-bit
vector opcode root. PTO must not allocate future instructions in those spaces
and assigns them no PTO semantics.

`B.IOD`, `BSTART.PAR`, and `C.B.IOS` are permanently deleted assembler
spellings, not encoding reservations. The active 32-bit `B.IOS` owns the former
`B.IOD` slot. `TFMA` remains active at TEPL selector `0x01C`, Mode 0,
Function 28. `B.IOT` remains Local-only; the obsolete mask-only Shared use is
removed.

For TLOAD and TSTORE, `B.IOR.RegSrc0` is the GM base selector and
`B.IOR.RegSrc1` is row stride in logical elements. Both are absolute GPR
selectors, and every selected PE resolves the same selector in its private GPR
file. An omitted B.IOR uses base zero and dense row stride; an explicitly
encoded zero stride remains zero. Packed four-bit accesses use logical indices
to select the containing byte and nibble.

Shared TSTORE Function 1 requires `PE_MASK=1111`; Function 14
(`TSTORE.SPART`) accepts any nonzero subset. Mask zero is a strict no-op for
both. Selected accesses are preflighted before effects. The architecture does
not order the selected PEs, so software must avoid conflicting GM regions.

## Consequences

- The extension reservation catalog is projected from ASL instead of being
  manually maintained.
- Shared TLSU reads base and stride from four private PE GPR files and records
  each memory event with the PE that owns the fixed Shared quarter.
- Every mnemonic page projects operand roles, legality, effects, restart
  behavior, encoding fields, and embedded operation ASL from the same source.
- The reviewed 573-form binary-closure fingerprint is rebound from
  `5f2855a4a9d8fe8fc2908a3940b9d9153f7232222fdd486a675217106142b4a3` to
  `a46ed057b3bce69ccd19e9085a2ed11f2a47d8d57c79e9190f90232aa922872c`.
  The only fingerprinted field that changes is B.IOR canonical assembly text;
  its form identity, length, mask, match, fields, and constraints are unchanged.
- PTO release checks prove that accepted forms and reserved extension spaces
  remain disjoint.

## Supersession

This decision narrows ADR 0054's remaining ambiguity about Shared GM operand
resolution and replaces example-only vector reservations with complete
namespace ownership. It does not change ADR 0054's Shared allocation,
definedness, rename, or per-PE size contracts.
