---
{
  "id": "ADR-TILE-0007",
  "title": "PTO ISA 0.58.0 Tile Operation Cleanup",
  "title_zh": "PTO ISA 0.58.0 Tile 操作整理",
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
    "PTO-MSCATTER-MASK-TYPE-002"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0053"
  ]
}
---
# ADR-TILE-0007: PTO ISA 0.58.0 Tile Operation Cleanup

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

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The 0.58.0 Tile inventory contained an unsupported random operation, an over-specialized sort name, missing masked/CAS memory forms, and an inconsistent TMA family name. Keeping that mixture would make the public catalog diverge from the intended executable operation set.

0.58.0 Tile 清单包含不受支持的随机操作、过度专用的排序名称、缺失的 masked/CAS 内存形式以及不一致的 TMA 族名称。保留这些内容会使公开目录偏离预期可执行操作集。

### Detailed decision / 详细决策

The cleanup removes `TRANDOM`, keeps `TSORT` with sort width as an operand-controlled parameter, restores `THISTOGRAM` and the listed masked/CAS gather/scatter forms, and renames the TMA family to TLSU. The record fixes the resulting selector/family inventory and requires generated catalogs and evidence to follow it.

整理删除 `TRANDOM`；保留 `TSORT` 并把排序宽度作为操作数控制参数；恢复 `THISTOGRAM` 及所列 masked/CAS gather/scatter 形式；将 TMA 族更名为 TLSU。本记录固定调整后的 selector/族清单，并要求生成目录与证据同步。

### What changed / 改动内容

#### English

- Removed one unsupported operation and restored the specified histogram and memory forms.
- Normalized sort parameterization and renamed the memory-operation family to TLSU.

#### 中文

- 删除一个不受支持操作，并恢复指定 histogram 与内存形式。
- 统一排序参数化，并将内存操作族更名为 TLSU。

### Scope and boundaries / 范围与边界

This ADR changes the public inventory and naming stated in its decisions. It does not supply detailed execution semantics for the restored operations; those remain in their affected ASL/NDF owners.

本 ADR 改变其决策所列的公开清单与命名；不提供恢复操作的详细执行语义，这些语义仍由受影响 ASL/NDF owner 管理。
