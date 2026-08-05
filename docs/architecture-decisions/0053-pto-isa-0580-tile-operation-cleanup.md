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

### D4: Rename TMA family to TLSU

The "Tile Memory Accelerator" (TMA) family is renamed to "Tile
Load-Store Unit" (TLSU). This name more accurately describes the
family's role (tile ↔ global memory data movement) and avoids
confusion with the hardware TMA unit naming.

All `"family": "TMA"` references in catalogs, ASL sources, and tests
are renamed to `"family": "TLSU"`. Bundle command mnemonics
(`BSTART.TMA`) are renamed to `BSTART.TLSU`.

## Consequences

- Operation count changes: 106 → 109 (remove TRANDOM: −1, restore
  THISTOGRAM: +1, restore MGATHER_MASK/MSCATTER_MASK/MGATHER_CAS: +3)
- Encoding ABI: TSORT selector unchanged, sort width becomes a
  parameter. TLSU selectors unchanged.
- Generated evidence files must be regenerated to reflect the new
  family name and operation count.
