# ADR 0056: PTO/Linx Common Encoding Ownership and Per-PE GM Access

- **Status**: accepted
- **Date**: 2026-08-08
- **Deciders**: PTO ISA maintainers
- **Issue**: [#54](https://github.com/PTO-ISA/pto-spec/issues/54)

## Context

The common PTO/Linx instruction subset had accumulated three forms of drift:
retired spellings were represented as if they still owned encoding space,
Linx-only vector reservations covered only individual examples rather than the
complete extension root, and Shared TLSU execution resolved one dispatching
PE's scalar values for all four Shared quarters.

## Decision

The normative contracts are owned by
`asl/arch/overview/encoding-ownership.asl` and
`asl/arch/memory-model/global-memory-access.asl`; this ADR records rationale
and does not create a second instruction definition.

PTO and Linx use identical encodings and semantics for their common scalar,
block, and Tile instructions. Linx may add its two-level vector architecture,
but PTO reserves all four Linx vector block starts and the complete 64-bit
vector opcode root. PTO must not allocate future instructions in those spaces.

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

- The Linx reservation catalog is projected from ASL instead of being manually
  maintained.
- Shared TLSU reads base and stride from four private PE GPR files and records
  each memory event with the PE that owns the fixed Shared quarter.
- Every mnemonic page projects operand roles, legality, effects, restart
  behavior, encoding fields, and embedded operation ASL from the same source.
- The reviewed 573-form binary-closure fingerprint is rebound from
  `5f2855a4a9d8fe8fc2908a3940b9d9153f7232222fdd486a675217106142b4a3` to
  `a46ed057b3bce69ccd19e9085a2ed11f2a47d8d57c79e9190f90232aa922872c`.
  The only fingerprinted field that changes is B.IOR canonical assembly text;
  its form identity, length, mask, match, fields, and constraints are unchanged.
- PTO and Linx release checks can compare the common subset mechanically while
  treating the declared Linx vector reservations as additive-only.

## Supersession

This decision narrows ADR 0054's remaining ambiguity about Shared GM operand
resolution and replaces example-only Linx vector reservations with complete
namespace ownership. It does not change ADR 0054's Shared allocation,
definedness, rename, or per-PE size contracts.
