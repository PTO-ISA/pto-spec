# ADR 0053: PTO ISA 0.58.0 Tile Operation Cleanup

- **Status**: accepted
- **Date**: 2026-08-05
- **Deciders**: PTO ISA maintainers

## Context

The 0.58.0 release performed a tile operation cleanup. This ADR records
four decisions that refine the operation set before release closure.

## Decisions

### D1: Remove TRANDOM

TRANDOM (hardware random number generation) is removed. It can be
adequately simulated in software via a scalar PRNG seeded from a
cycle counter or system entropy source. A dedicated tile instruction
for random number generation does not justify the encoding space and
implementation complexity at this maturity level.

### D2: Keep TSORT name, make sort width a parameter

`TSORT32` is renamed back to `TSORT`. The sort width (previously
hard-coded as 32 in the name) becomes an instruction parameter
(`sort_width`), allowing the same mnemonic to cover multiple sort
widths in future profiles without renaming.

### D3: Restore THISTOGRAM, MGATHER_MASK, MSCATTER_MASK, MGATHER_CAS

These four operations were removed in the initial 0.58.0 catalog but
are restored:
- `THISTOGRAM` — tile histogram computation is performance-critical
  for ML training profiling and cannot be efficiently emulated.
- `MGATHER_MASK`, `MSCATTER_MASK` — masked gather/scatter are
  required for sparse tensor operations.
- `MGATHER_CAS` — atomic compare-and-swap gather is required for
  lock-free data structure operations on global memory.

### D4: Rename the TMA encoding-family label to TLSU

The "Tile Memory Accelerator" (TMA) family is renamed to "Tile
Load-Store Unit" (TLSU). This name more accurately describes the
family's role (tile ↔ global memory data movement) and avoids
confusion with the hardware TMA unit naming.

All active `"family": "TMA"` references in catalogs, ASL sources, tests, and
generated evidence are renamed to `"family": "TLSU"`. The accepted commands
remain the operation-specific `BSTART.TLOAD`, `BSTART.TSTORE`,
`BSTART.TMOV`, and related spellings; this decision does not introduce a
generic `BSTART.TLSU` instruction.

### D5: Preserve the public/Linx TLSU allocation boundary

The three restored TLSU operations use Functions 6, 7, and 8:
`MGATHER_MASK`, `MSCATTER_MASK`, and `MGATHER_CAS`, respectively. `GMOV`
remains Function 13. PTO reserves Functions 9 through 12 and Function 14 for
the Linx-only Shared TMOV and `TSTORE.SPART` forms. PTO also reserves
Functions 15 through 31. Those Linx-only forms are not PTO command variants
and do not enter the PTO decoder.

`THISTOGRAM` uses the existing TEPL carrier selector `0x068`; the deleted
`TRANDOM` selector `0x069` is reserved. `TSORT` retains selector `0x06C`.

## Consequences

- Operation count changes: 106 → 109 (remove TRANDOM: −1, restore
  THISTOGRAM: +1, restore MGATHER_MASK/MSCATTER_MASK/MGATHER_CAS: +3)
- Encoding ABI: `TSORT` keeps selector `0x06C`; `THISTOGRAM` owns `0x068`;
  `MGATHER_MASK`, `MSCATTER_MASK`, and `MGATHER_CAS` own TLSU Functions 6, 7,
  and 8. Linx-only Functions 9–12 and 14 remain rejected by PTO.
- Generated evidence files must be regenerated to reflect the new
  family name and operation count.
