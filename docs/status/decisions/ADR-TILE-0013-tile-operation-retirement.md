---
{
  "id": "ADR-TILE-0013",
  "title": "Retire software-replaceable tile operations",
  "title_zh": "退役可由软件替代的 Tile 操作",
  "status": "accepted",
  "authors": [
    "PTO ISA maintainers"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-09-03",
  "accepted": "2026-09-03",
  "rejected": null,
  "superseded": null,
  "baseline": "97f61030f08c8435275125d7797a0be438a18dd9",
  "target_releases": [
    "0.58.6.0"
  ],
  "affected_ndf": [
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-INST-TILE-GMOV",
    "PTO-INST-TILE-MGATHER",
    "PTO-INST-TILE-MGATHER-MASK",
    "PTO-INST-TILE-MSCATTER",
    "PTO-INST-TILE-MSCATTER-MASK",
    "PTO-INST-TILE-TCI",
    "PTO-INST-TILE-TCONCAT",
    "PTO-INST-TILE-TDEQUANT",
    "PTO-INST-TILE-TEXTRACT",
    "PTO-INST-TILE-TGATHER",
    "PTO-INST-TILE-TGPR2T",
    "PTO-INST-TILE-THISTOGRAM",
    "PTO-INST-TILE-TIMG2COL",
    "PTO-INST-TILE-TINSERT",
    "PTO-INST-TILE-TLOAD",
    "PTO-INST-TILE-TMOV",
    "PTO-INST-TILE-TMRGSORT",
    "PTO-INST-TILE-TPACK",
    "PTO-INST-TILE-TPERMUTE",
    "PTO-INST-TILE-TPREFETCH",
    "PTO-INST-TILE-TQUANT",
    "PTO-INST-TILE-TSCATTER",
    "PTO-INST-TILE-TSHUF",
    "PTO-INST-TILE-TSORT",
    "PTO-INST-TILE-TSTORE",
    "PTO-INST-TILE-TTRI",
    "PTO-INST-TILE-TUNPACK",
    "PTO-TCONCAT-CONTRACT-001",
    "PTO-TDEQUANT-CONTRACT-001",
    "PTO-TEXTRACT-CONTRACT-001",
    "PTO-THISTOGRAM-CONTRACT-001",
    "PTO-TINSERT-CONTRACT-001",
    "PTO-TMRGSORT-CONTRACT-001",
    "PTO-TQUANT-CONTRACT-001",
    "PTO-TSORT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY",
    "PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA",
    "PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX",
    "PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT",
    "PTO-TILE-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-TILE-MODEL-EXECUTION-COMPLEX",
    "PTO-TILE-MODEL-EXECUTION-REARRANGEMENT",
    "PTO-TILE-MODEL-EXECUTION-SORTING",
    "PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT",
    "PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT",
    "PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-SORTING",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TCI",
    "PTO-TILE-TCONCAT",
    "PTO-TILE-TDEQUANT",
    "PTO-TILE-TEXTRACT",
    "PTO-TILE-TGATHER",
    "PTO-TILE-TGPR2T",
    "PTO-TILE-THISTOGRAM",
    "PTO-TILE-TIMG2COL",
    "PTO-TILE-TINSERT",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TMOV",
    "PTO-TILE-TMRGSORT",
    "PTO-TILE-TPACK",
    "PTO-TILE-TPERMUTE",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TQUANT",
    "PTO-TILE-TSCATTER",
    "PTO-TILE-TSHUF",
    "PTO-TILE-TSORT",
    "PTO-TILE-TSTORE",
    "PTO-TILE-TTRI",
    "PTO-TILE-TUNPACK"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-NUM-0020"
  ],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/237",
  "release_impact": "required",
  "interface_change": true,
  "legacy_ids": [
    "ADR-0114"
  ],
  "release_boundary": true
}
---
# ADR-TILE-0013: Retire software-replaceable tile operations

- **Date**: 2026-09-03
- **Deciders**: PTO ISA maintainers

## Decision

The PTO ISA retires these eight direct tile operations from the active ISA,
catalog, dispatch, and generated instruction surface:

- `TCONCAT`
- `TEXTRACT`
- `TINSERT`
- `THISTOGRAM`
- `TQUANT`
- `TDEQUANT`
- `TSORT`
- `TMRGSORT`

Their former complete direct encodings have no compatibility aliases. In
publication 0.58.5.1, those encodings reject with
`Fault_IllegalInstruction` before
operand reads, bundle state changes, allocation, memory, numeric status,
publication, or any other architectural effect.

The former selector/function slots are not permanently `reserved-in-pto`.
They remain available for reallocation by a later accepted encoding-allocation
ADR. This decision does not create a permanent reservation for any released
slot.

Software replacements are outside PTO ISA ownership. This ADR specifies no
software lowering, runtime ABI, scratch or synchronization contract, numeric
library behavior, compiler lowering, layout fallback, radix sort, or histogram
scan. The historical TSORT BF16/helper mismatch sunsets with TSORT and is not
replaced by a software sort contract.

## Scoped provenance

This ADR scope-replaces only the affected decisions while preserving the
unrelated decisions in the earlier records:

- In `ADR-TILE-0007` (legacy `ADR-0053`), only the TSORT decision and the
  THISTOGRAM portion of the restoration decision are replaced. TRANDOM
  removal, MGATHER_MASK, MSCATTER_MASK, MGATHER_CAS, TLSU naming, and all
  unrelated decisions remain valid.
- In `ADR-TILE-0008`, only the TCONCAT, TEXTRACT, and TINSERT decisions are
  replaced.
- In `ADR-TILE-0011`, only the TQUANT, TDEQUANT, TSORT, and TMRGSORT
  decisions are replaced.

Those ADRs are not wholly superseded. Their `supersedes` and
`superseded_by` relationships remain empty for this ADR; the scoped
replacement is recorded here and in the affected owners' provenance.

## Active-surface closure

The active ASL owners, semantic handlers, direct decoder witnesses, catalogs,
dispatch schemas, generated instruction pages, navigation, and inventories
for the eight operations are removed. Historical ADR and NDF provenance is
retained in the decision index and evidence projections without retaining an
active owner or compatibility alias.

The unaffected GM atom/red and movement operations, layout and conversion
operations that remain active, numeric status, CUBE/TLSU behavior, and all
unrelated ADR decisions are unchanged.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The eight direct tile operations are retired from the active PTO ISA because
the accepted architecture decision no longer assigns them active direct encodings.
由于已接受的发布契约不再为这八个直接 Tile 操作分配活动直接编码，因此将其从活动 PTO ISA 中退役。

### Detailed decision / 详细决策

The former complete encodings fault before any operand read or architectural
effect, with no compatibility alias and no permanent reservation of the former
slots. 旧完整编码在读取操作数或产生任何架构效果之前触发 fault；不存在兼容别名，也不永久保留旧槽位。

### What changed / 改动内容

#### English

The active owners, catalog rows, dispatch paths, generated instruction pages,
and direct semantic handlers for the eight operations are removed.

#### 中文

八个操作的活动 owner、目录行、dispatch 路径、生成指令页面和直接语义 handler 均被移除。

### Scope and boundaries / 范围与边界

This decision preserves unrelated GM movement and atomic operations, B.SUBVIEW,
B.ASSEMBLE, TMOV, TSHUF, TCVT, numeric status, CUBE/TLSU behavior, and historical
ADR/NDF provenance. 该决定保留无关的 GM 移动与原子操作、B.SUBVIEW、B.ASSEMBLE、TMOV、TSHUF、TCVT、数值状态、CUBE/TLSU 行为以及历史 ADR/NDF provenance。
