---
{
  "id": "ADR-CUBE-0013",
  "title": "Private CUBE vector execution and CELL rearrangement",
  "title_zh": "私有 CUBE 向量执行与 CELL 重排",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-25",
  "accepted": "2026-08-25",
  "rejected": null,
  "superseded": null,
  "baseline": "b2c6ada1c80611d5eb56aee1d40d0bb1cfa82196",
  "target_releases": [
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-TPACK-CONTRACT-001",
    "PTO-TPERMUTE-CONTRACT-001",
    "PTO-TSHUF-CONTRACT-001",
    "PTO-TUNPACK-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-TILE-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-TILE-TPACK",
    "PTO-TILE-TPERMUTE",
    "PTO-TILE-TSHUF",
    "PTO-TILE-TUNPACK"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/151",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0103"
  ]
}
---

# ADR-CUBE-0013: Private CUBE vector execution and CELL rearrangement

## Context

Issue #151 was accepted by the architecture owner on 2026-08-25. This record
keeps one coherent decision for private Local CUBE vector execution and the
four CELL rearrangement operations, and establishes accepted ADR ownership for
their four contract clauses and instruction subjects. Current normative
meaning remains in the accepted ASL contracts and their generated projections.

## Decision

The six old tile selectors are retired: `TPARTADD`, `TPARTMUL`, `TPARTMAX`, and
`TPARTMIN` (`0x071..0x074`), `TFILLPAD` (`0x065`), and `TTRANS` (`0x06E`). Their
selectors remain reserved-illegal. No alias or replacement is introduced.
This retires only the corresponding decisions in ADR-TILE-0010 and ADR-TILE-0011; those
ADRs are not retired wholesale. This ADR intentionally does not use metadata
`supersedes` for that scoped retirement.

The following 34 existing element-wise instructions accept ordinary Local
`CUBE_M32` and Local `CUBE_M16` execution:

```text
TADD TAND TDIV TMAX TMIN TMUL TOR TREM TSHL TSHR TSUB TXOR
TABS TEXP TLOG TNEG TNOT TRECIP TRELU TRSQRT TSQRT
TADDS TANDS TDIVS TMAXS TMINS TMULS TORS TREMS
TSHLS TSHRS TSUBS TXORS TFMA
```

`CUBE_N8`, Shared layouts, mixed layouts, and the excluded `TCMP`, `TCMPS`,
`TSEL`, `TSELS`, and `TCVT` forms remain illegal. Existing logical-coordinate
element-wise contracts continue to define shape, type, valid-region, and value
behavior; this decision does not introduce a new element-wise spelling.

The SFU TEPL `Mode=3` selectors for CELL rearrangement are frozen as follows:

- `TPERMUTE` is selector `0x075`, a raw two-source per-row byte lookup using a
  U8 index Tile.
- `TSHUF` is selector `0x076`, a raw U32-word shuffle with `UP`, `DOWN`,
  `BFLY`, and `IDX` modes, `SELF`/`ZERO` selection, and M32/M16 grouping.
- `TPACK` is selector `0x077`, U32 byte-field assembly.
- `TUNPACK` is selector `0x078`, U32 zero-extended byte-field extraction.

Controls, operand bindings, source-definedness, valid-region and padding
inspection, and fresh-destination allocation follow and agree with the
accepted ASL contracts and the issue handoff. This ADR does not add alternate
control encodings or operand forms.

For a decoded bundle, missing, repeated, or surplus `B.IOR` structure is a
`BundleControl` fault. Invalid controls, indices, dtypes, layouts, or shapes
are `TileLegality` faults. An unallocated selector is an
`IllegalInstruction`. `PE_MASK=0000` is a strict no-op after legal decode and
does not read operands, allocate a destination, or raise a later semantic
fault.

## Compatibility and protected behavior

Raw CELL order is observable only for `TPERMUTE`, `TSHUF`, `TPACK`, and
`TUNPACK`. Ordinary element-wise operations remain logical-coordinate based.
This decision does not add reductions, replace transpose, enable GM
conversion, add predicate behavior, or define numeric conversion semantics.

The selector retirement is an assembly and compatibility break: the retired
encodings are rejected and have no compatibility aliases. Compiler intrinsic,
emulator, and RTL adoption remain separate follow-ups to the PTO-ASL contract.

## Release boundary

The change has required release impact and is selected for architecture
release `0.58.5`. ADR-GOV-0009 owns the compatibility and publication boundary;
this ADR continues to own only the accepted architecture decision.

## Verification

Focused decoded and direct AVS evidence covers the accepted vector and CELL
rearrangement paths, rejection/no-effect boundaries, and the bundle fault
boundary. The ordinary PR V1 gates are the applicable repository verification;
release validation and V2 evidence are not claimed by this decision.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Private CUBE data needs selected logical element-wise execution
and a small set of operations that intentionally observe raw CELL order. The
legacy partial and movement selectors did not provide that coherent boundary.

**中文。** 私有 CUBE 数据既需要选定的逻辑逐元素执行，也需要少量有意观察 raw
CELL 顺序的操作。旧 partial 与 movement selector 无法形成一致边界。

### Detailed decision / 详细决策

**English.** Six legacy selectors retire as reserved-illegal. Thirty-four
listed element-wise instructions accept Local M16/M32 through logical
coordinates, while four frozen TEPL selectors implement raw CELL permutation,
shuffle, pack, and unpack. Decode, controls, bindings, fault classes, and zero
mask behavior follow the accepted ASL contracts.

**中文。** 六个旧 selector 退役并保留为非法。列出的 34 个逐元素指令通过逻辑坐标
接受 Local M16/M32，四个冻结 TEPL selector 实现 raw CELL permute、shuffle、
pack 与 unpack。decode、控制、绑定、故障类别和零 mask 行为遵循已接受 ASL。

### What changed / 改动内容

#### English

- Retired six legacy selectors without aliases.
- Enabled 34 logical-coordinate operations on private M16/M32 CUBE data.
- Added four exact raw-CELL rearrangement operation contracts.

#### 中文

- 无 alias 地退役六个旧 selector。
- 允许 34 个逻辑坐标操作处理私有 M16/M32 CUBE 数据。
- 增加四个精确 raw-CELL 重排操作契约。

### Scope and boundaries / 范围与边界

**English.** CUBE_N8, Shared and mixed layouts, excluded compare/select/TCVT
forms, reductions, GM conversion, predicates, and new numeric conversion stay
outside scope.

**中文。** CUBE_N8、Shared/混合布局、被排除的 compare/select/TCVT、归约、GM
转换、predicate 及新数值转换不在范围内。
