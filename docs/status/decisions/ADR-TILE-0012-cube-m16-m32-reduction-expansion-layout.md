---
{
  "id": "ADR-TILE-0012",
  "title": "CUBE_M16/CUBE_M32 layout closure for tile reduction and expansion",
  "title_zh": "Tile 归约与扩展的 CUBE_M16/CUBE_M32 布局闭合",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-09-03",
  "accepted": "2026-09-03",
  "rejected": null,
  "superseded": null,
  "baseline": "ae04395a024046e2b77395ffc2e732804181c22f",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-TROWARGMAX-CONTRACT-001",
    "PTO-TROWARGMIN-CONTRACT-001",
    "PTO-TROWMAX-CONTRACT-001",
    "PTO-TROWMIN-CONTRACT-001",
    "PTO-TROWPROD-CONTRACT-001",
    "PTO-TROWSUM-CONTRACT-001",
    "PTO-TCOLARGMAX-CONTRACT-001",
    "PTO-TCOLARGMIN-CONTRACT-001",
    "PTO-TCOLMAX-CONTRACT-001",
    "PTO-TCOLMIN-CONTRACT-001",
    "PTO-TCOLPROD-CONTRACT-001",
    "PTO-TCOLSUM-CONTRACT-001",
    "PTO-TROWEXPAND-CONTRACT-001",
    "PTO-TROWEXPANDADD-CONTRACT-001",
    "PTO-TROWEXPANDDIV-CONTRACT-001",
    "PTO-TROWEXPANDEXPDIF-CONTRACT-001",
    "PTO-TROWEXPANDMAX-CONTRACT-001",
    "PTO-TROWEXPANDMIN-CONTRACT-001",
    "PTO-TROWEXPANDMUL-CONTRACT-001",
    "PTO-TROWEXPANDSUB-CONTRACT-001",
    "PTO-TCOLEXPAND-CONTRACT-001",
    "PTO-TCOLEXPANDADD-CONTRACT-001",
    "PTO-TCOLEXPANDDIV-CONTRACT-001",
    "PTO-TCOLEXPANDEXPDIF-CONTRACT-001",
    "PTO-TCOLEXPANDMAX-CONTRACT-001",
    "PTO-TCOLEXPANDMIN-CONTRACT-001",
    "PTO-TCOLEXPANDMUL-CONTRACT-001",
    "PTO-TCOLEXPANDSUB-CONTRACT-001",
    "PTO-TEXPANDS-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-TILE-TROWARGMAX",
    "PTO-TILE-TROWARGMIN",
    "PTO-TILE-TROWMAX",
    "PTO-TILE-TROWMIN",
    "PTO-TILE-TROWPROD",
    "PTO-TILE-TROWSUM",
    "PTO-TILE-TCOLARGMAX",
    "PTO-TILE-TCOLARGMIN",
    "PTO-TILE-TCOLMAX",
    "PTO-TILE-TCOLMIN",
    "PTO-TILE-TCOLPROD",
    "PTO-TILE-TCOLSUM",
    "PTO-TILE-TROWEXPAND",
    "PTO-TILE-TROWEXPANDADD",
    "PTO-TILE-TROWEXPANDDIV",
    "PTO-TILE-TROWEXPANDEXPDIF",
    "PTO-TILE-TROWEXPANDMAX",
    "PTO-TILE-TROWEXPANDMIN",
    "PTO-TILE-TROWEXPANDMUL",
    "PTO-TILE-TROWEXPANDSUB",
    "PTO-TILE-TCOLEXPAND",
    "PTO-TILE-TCOLEXPANDADD",
    "PTO-TILE-TCOLEXPANDDIV",
    "PTO-TILE-TCOLEXPANDEXPDIF",
    "PTO-TILE-TCOLEXPANDMAX",
    "PTO-TILE-TCOLEXPANDMIN",
    "PTO-TILE-TCOLEXPANDMUL",
    "PTO-TILE-TCOLEXPANDSUB",
    "PTO-TILE-TEXPANDS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/228",
  "release_impact": "required",
  "interface_change": true,
  "legacy_ids": []
}
---
# ADR-TILE-0012: CUBE_M16/CUBE_M32 layout closure for tile reduction and expansion

## Context

Issue #228 closes the direct Local CUBE layout contract for the tile reduction,
row/column expansion, and scalar expansion operations. The decision is based on
baseline `ae04395a024046e2b77395ffc2e732804181c22f`. It extends the existing
mnemonic contracts without changing the generic CUBE descriptor or the existing
GM/Local CUBE transport selectors.

## Decisions

### Direct Local layout selectors

`B.DATR.Layout=29` selects direct Local `M32`, represented by
`TileLayout_CUBE_M32`. `B.DATR.Layout=31` selects direct Local `M16`, represented
by `TileLayout_CUBE_M16`. These values select the layout of the Local Tiles
participating in the operation; they are not GM/Local conversions and are not
legal TLOAD/TSTORE conversion selectors.

Existing codes `21..26` remain unchanged:

- `ND2M32`, `ND2M16`, `ND2N8` for GM-to-Local CUBE loads;
- `M322ND`, `M162ND`, `N82ND` for Local CUBE-to-GM stores.

### Operation layout closure

The reduction and expansion family supports `RowMajor`, `CUBE_M16`, and
`CUBE_M32`. The closure includes all `TROW*` and `TCOL*` reductions listed in
the affected clauses, all `TROWEXPAND*` and `TCOLEXPAND*` operations, and
`TEXPANDS`.

All Tile operands participating in one operation use the same layout. Mixed
RowMajor/CUBE and mixed M16/M32 operands are illegal. These operations do not
perform M16-to-M32 or M32-to-M16 conversion.

Omitted `B.DATR` and `B.DATR.Layout=NORM` preserve the existing RowMajor
behavior.

### Operation-specific CUBE row limits

For this operation family, `CUBE_M16` requires `valid_rows <= 16` and
`CUBE_M32` requires `valid_rows <= 32`. This is an operation-specific limit;
the generic CUBE descriptor remains unchanged and may represent multiple
32-row blocks for operations whose contracts allow them. This operation family
exposes only one row block. A shape exceeding the selected limit is illegal;
software splitting is outside the ISA semantics.

### Reduction shapes and source capacity

`TROW*` reductions map logical `[R,C]` to `[R,1]`. `TCOL*` reductions map
logical `[R,C]` to `[1,C]`. Arg reductions return logical axis indices as
`U32`: row reductions return column indices and column reductions return row
indices. The reduction result uses the selected operation layout.

In addition to ordinary descriptor legality, every reduction source has
`TSize/allocated capacity <= 2048` bytes. This bound is on the source Tile
allocation, not on its logical element byte count, destination size, or generic
CUBE required-byte calculation. The source must still satisfy the existing
required-byte and capacity rules. A source above 2KB is rejected before source
snapshot, destination allocation, or payload effects; software must split it
before issuing the operation.

### Expansion shapes

`TROWEXPAND*` uses a full source `[R,C]`, a logical row-broadcast source
`[R,1]`, and a destination `[R,C]`. `TCOLEXPAND*` uses a full source `[R,C]`,
a logical column-broadcast source `[1,C]`, and a destination `[R,C]`.

Broadcast legality is checked against logical `valid_rows` and
`valid_columns`, not aligned physical extents. In particular, row broadcast
requires `valid_columns == 1`; it does not require physical `columns == 1`.

Expansion has no 2KB source restriction. All expansion sources and destinations
remain subject to ordinary descriptor, valid-region, capacity, definedness,
and encoding legality, including the operation-specific M16/M32 row limits.

### Scalar expansion

`TEXPANDS` has no Tile source from which to infer a CUBE layout. Its explicit
`B.DATR` selector therefore chooses the newly allocated destination layout:
`M16` selects `CUBE_M16` and `M32` selects `CUBE_M32`. The destination logical
shape is `[R,C]`, with the corresponding `valid_rows` limit. `TEXPANDS` is not
subject to the reduction-source 2KB limit.

## Protected behavior and exclusions

- Existing RowMajor reduction, expansion, and `TEXPANDS` behavior is unchanged.
- Existing CUBE physical geometry, Cell ordering, physical tails, PadValue, and
definedness rules remain authoritative.
- Reduction and expansion semantics are defined by logical coordinates.
- `EXPDIF` retains its existing source/destination type-pair rules.
- Existing atomic preflight, rejection, rollback, and publication behavior is
  unchanged.
- The generic CUBE descriptor is not globally narrowed.
- No new opcode, backend implementation, compiler lowering, emulator behavior,
  RTL mechanism, scheduler rule, or software-splitting algorithm is specified.
- No GM/Shared CUBE transport behavior is changed.

## Acceptance criteria

The implementation and generated projections must prove:

1. Layout codes `29` and `31` decode and select the stated direct Local layouts.
2. Transport codes `21..26` retain their existing meanings and direction rules.
3. RowMajor behavior regresses unchanged.
4. M16 accepts 16 rows and rejects 17; M32 accepts 32 rows and rejects 33.
5. Reduction source capacity accepts 2048 bytes and rejects values above 2048.
6. Expansion and `TEXPANDS` do not inherit the reduction 2KB restriction.
7. Same-layout positive cases and mixed-layout negative cases are covered.
8. Reduction logical shapes, arg-index dtype, broadcast geometry, physical tails,
   PadValue, definedness, and atomic rejection are covered.
9. NDF, ASL, generated catalog/documentation, decoder, AVS, ADR-index, and
   release-traceability projections remain consistent.

## Release boundary

This accepted ADR is a normative ISA change with release impact `required`.
The target release remains `unassigned` until release planning assigns one.
Current semantic meaning is owned by the affected ASL/NDF clauses and their
generated projections.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The affected Tile operations previously specified RowMajor behavior only, while the existing CUBE model and transport selectors left direct Local CUBE operation layout selection incomplete.

受影响的 Tile 操作此前仅规定 RowMajor 行为，而现有 CUBE 模型和传输选择器未闭合直接 Local CUBE 操作的布局选择。

### Detailed decision / 详细决策

The accepted contract adds direct Local M32 and M16 selectors and closes same-layout CUBE operation behavior without changing generic CUBE geometry or transport semantics.

已接受的契约增加直接 Local M32 和 M16 选择器，并闭合相同布局的 CUBE 操作行为，同时不改变通用 CUBE 几何或传输语义。

### What changed / 改动内容

#### English

- Added direct Local Layout 29/31 mapping and operation-specific reduction/expansion legality.
- Preserved RowMajor defaults, transport codes 21..26, and atomic rejection behavior.

#### 中文

- 增加直接 Local Layout 29/31 映射以及归约/扩展操作特定的合法性。
- 保留 RowMajor 默认值、21..26 传输代码和原子拒绝行为。

### Scope and boundaries / 范围与边界

This decision is limited to the affected PTO ASL/NDF owners and their required generated projections, focused executable evidence, and catalogs. It does not specify backend behavior, software splitting, or unrelated operations.

本决策仅限于受影响的 PTO ASL/NDF 所有者及其所需生成投影、重点可执行证据和目录；不规定后端行为、软件拆分或无关操作。
