---
{
  "id": "ADR-0053",
  "title": "PTO ISA 0.58.0 Tile Operation Cleanup",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-05",
  "accepted": "2026-08-05",
  "rejected": null,
  "superseded": null,
  "baseline": "d07e1d7e2a9001a4d1c2a9c4a4f212b0ba767092",
  "target_releases": [
    "0.58.0"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001",
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
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
    "PTO-THISTOGRAM-CONTRACT-001",
    "PTO-TMRGSORT-CONTRACT-001",
    "PTO-TSORT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-THISTOGRAM",
    "PTO-TILE-TMRGSORT",
    "PTO-TILE-TSORT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0053: PTO ISA 0.58.0 Tile Operation Cleanup

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
are renamed to `"family": "TLSU"`. `BSTART.TLSU` is the family notation
used by explanatory assembly sequences; the accepted binary command forms
remain the exact named `BSTART.*` instructions. In particular, the restored
selectors use `BSTART.MGATHER.MASK`, `BSTART.MSCATTER.MASK`, and
`BSTART.MGATHER.CAS`; a generic `BSTART.TLSU` encoded form is not introduced.

## Consequences

- Operation count changes: 106 → 109 (remove TRANDOM: −1, restore
  THISTOGRAM: +1, restore MGATHER_MASK/MSCATTER_MASK/MGATHER_CAS: +3)
- Encoding ABI: TSORT selector unchanged, sort width becomes a
  parameter. The retained masked/CAS selectors keep Functions 6–8. To avoid
  an encoding collision, the newer Shared-TLSU variants use Functions 9–12
  for TMOV and Function 14 for `TSTORE.SPART`; Function 13 remains `GMOV`.
- Command-form count changes from 96 to 99 by restoring the three exact
  masked/CAS bundle-start forms.
- Generated evidence files must be regenerated to reflect the new family
  name and operation/command counts.
