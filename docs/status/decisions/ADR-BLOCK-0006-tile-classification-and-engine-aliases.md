---
{
  "id": "ADR-BLOCK-0006",
  "title": "Tile Classification and Execution-Engine Aliases",
  "title_zh": "Tile 分类与执行引擎别名",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-09",
  "accepted": "2026-08-09",
  "rejected": null,
  "superseded": null,
  "baseline": "f53f730332dfbfffee07021af8bcdf79d70f33fe",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-TEPL-ALIAS-001",
    "PTO-ARCH-TILE-EXECUTION-ENGINE-001",
    "PTO-ARCH-TILE-INSTRUCTION-CLASS-001",
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
    "PTO-TABS-CONTRACT-001",
    "PTO-TADD-CONTRACT-001",
    "PTO-TADDS-CONTRACT-001",
    "PTO-TAND-CONTRACT-001",
    "PTO-TANDS-CONTRACT-001",
    "PTO-TCI-CONTRACT-001",
    "PTO-TCMP-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TCOLARGMAX-CONTRACT-001",
    "PTO-TCOLARGMIN-CONTRACT-001",
    "PTO-TCOLEXPAND-CONTRACT-001",
    "PTO-TCOLEXPANDADD-CONTRACT-001",
    "PTO-TCOLEXPANDDIV-CONTRACT-001",
    "PTO-TCOLEXPANDEXPDIF-CONTRACT-001",
    "PTO-TCOLEXPANDMAX-CONTRACT-001",
    "PTO-TCOLEXPANDMIN-CONTRACT-001",
    "PTO-TCOLEXPANDMUL-CONTRACT-001",
    "PTO-TCOLEXPANDSUB-CONTRACT-001",
    "PTO-TCOLMAX-CONTRACT-001",
    "PTO-TCOLMIN-CONTRACT-001",
    "PTO-TCOLPROD-CONTRACT-001",
    "PTO-TCOLSUM-CONTRACT-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-TDIV-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TEXP-CONTRACT-001",
    "PTO-TEXPANDS-CONTRACT-001",
    "PTO-TFMA-CONTRACT-001",
    "PTO-TGATHER-CONTRACT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-BIAS-CONTRACT-001",
    "PTO-TGEMV-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-TIMG2COL-CONTRACT-001",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TLOG-CONTRACT-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001",
    "PTO-TMAX-CONTRACT-001",
    "PTO-TMAXS-CONTRACT-001",
    "PTO-TMIN-CONTRACT-001",
    "PTO-TMINS-CONTRACT-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-TMUL-CONTRACT-001",
    "PTO-TMULS-CONTRACT-001",
    "PTO-TNEG-CONTRACT-001",
    "PTO-TNOT-CONTRACT-001",
    "PTO-TOR-CONTRACT-001",
    "PTO-TORS-CONTRACT-001",
    "PTO-TPREFETCH-FOOTPRINT-001",
    "PTO-TRECIP-CONTRACT-001",
    "PTO-TRELU-CONTRACT-001",
    "PTO-TREM-CONTRACT-001",
    "PTO-TREMS-CONTRACT-001",
    "PTO-TROWARGMAX-CONTRACT-001",
    "PTO-TROWARGMIN-CONTRACT-001",
    "PTO-TROWEXPAND-CONTRACT-001",
    "PTO-TROWEXPANDADD-CONTRACT-001",
    "PTO-TROWEXPANDDIV-CONTRACT-001",
    "PTO-TROWEXPANDEXPDIF-CONTRACT-001",
    "PTO-TROWEXPANDMAX-CONTRACT-001",
    "PTO-TROWEXPANDMIN-CONTRACT-001",
    "PTO-TROWEXPANDMUL-CONTRACT-001",
    "PTO-TROWEXPANDSUB-CONTRACT-001",
    "PTO-TROWMAX-CONTRACT-001",
    "PTO-TROWMIN-CONTRACT-001",
    "PTO-TROWPROD-CONTRACT-001",
    "PTO-TROWSUM-CONTRACT-001",
    "PTO-TRSQRT-CONTRACT-001",
    "PTO-TSCATTER-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TSHL-CONTRACT-001",
    "PTO-TSHLS-CONTRACT-001",
    "PTO-TSHR-CONTRACT-001",
    "PTO-TSHRS-CONTRACT-001",
    "PTO-TSQRT-CONTRACT-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-TSUB-CONTRACT-001",
    "PTO-TSUBS-CONTRACT-001",
    "PTO-TTRI-CONTRACT-001",
    "PTO-TXOR-CONTRACT-001",
    "PTO-TXORS-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TABS",
    "PTO-TILE-TADD",
    "PTO-TILE-TADDS",
    "PTO-TILE-TAND",
    "PTO-TILE-TANDS",
    "PTO-TILE-TCI",
    "PTO-TILE-TCMP",
    "PTO-TILE-TCMPS",
    "PTO-TILE-TCOLARGMAX",
    "PTO-TILE-TCOLARGMIN",
    "PTO-TILE-TCOLEXPAND",
    "PTO-TILE-TCOLEXPANDADD",
    "PTO-TILE-TCOLEXPANDDIV",
    "PTO-TILE-TCOLEXPANDEXPDIF",
    "PTO-TILE-TCOLEXPANDMAX",
    "PTO-TILE-TCOLEXPANDMIN",
    "PTO-TILE-TCOLEXPANDMUL",
    "PTO-TILE-TCOLEXPANDSUB",
    "PTO-TILE-TCOLMAX",
    "PTO-TILE-TCOLMIN",
    "PTO-TILE-TCOLPROD",
    "PTO-TILE-TCOLSUM",
    "PTO-TILE-TCVT",
    "PTO-TILE-TDIV",
    "PTO-TILE-TDIVS",
    "PTO-TILE-TEXP",
    "PTO-TILE-TEXPANDS",
    "PTO-TILE-TFMA",
    "PTO-TILE-TGATHER",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-TIMG2COL",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TLOG",
    "PTO-TILE-TMATMUL",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS",
    "PTO-TILE-TMAX",
    "PTO-TILE-TMAXS",
    "PTO-TILE-TMIN",
    "PTO-TILE-TMINS",
    "PTO-TILE-TMOV",
    "PTO-TILE-TMUL",
    "PTO-TILE-TMULS",
    "PTO-TILE-TNEG",
    "PTO-TILE-TNOT",
    "PTO-TILE-TOR",
    "PTO-TILE-TORS",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TRECIP",
    "PTO-TILE-TRELU",
    "PTO-TILE-TREM",
    "PTO-TILE-TREMS",
    "PTO-TILE-TROWARGMAX",
    "PTO-TILE-TROWARGMIN",
    "PTO-TILE-TROWEXPAND",
    "PTO-TILE-TROWEXPANDADD",
    "PTO-TILE-TROWEXPANDDIV",
    "PTO-TILE-TROWEXPANDEXPDIF",
    "PTO-TILE-TROWEXPANDMAX",
    "PTO-TILE-TROWEXPANDMIN",
    "PTO-TILE-TROWEXPANDMUL",
    "PTO-TILE-TROWEXPANDSUB",
    "PTO-TILE-TROWMAX",
    "PTO-TILE-TROWMIN",
    "PTO-TILE-TROWPROD",
    "PTO-TILE-TROWSUM",
    "PTO-TILE-TRSQRT",
    "PTO-TILE-TSCATTER",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSELS",
    "PTO-TILE-TSHL",
    "PTO-TILE-TSHLS",
    "PTO-TILE-TSHR",
    "PTO-TILE-TSHRS",
    "PTO-TILE-TSQRT",
    "PTO-TILE-TSTORE",
    "PTO-TILE-TSUB",
    "PTO-TILE-TSUBS",
    "PTO-TILE-TTRI",
    "PTO-TILE-TXOR",
    "PTO-TILE-TXORS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0057"
  ],
  "release_boundary": true
}
---
# ADR-BLOCK-0006: Tile Classification and Execution-Engine Aliases

- **Date**: 2026-08-09
- **Deciders**: PTO ISA maintainers

## Context

The active Tile tree used migration-era categories such as `tile-tile-elementwise`,
`reduction`, and `complex-layout`, while the PTO programming surface already
defines eight stable instruction classes. The binary carrier name `TEPL` also
mixed an encoding identity with an execution-engine classification. That made
navigation, engine ownership, and downstream assembly terminology drift even
though the Mode/Function encoding itself remained valid.

## Decision

The normative owners are the mnemonic ASL records below `asl/tile/` and the
engine/alias clauses in `asl/arch/overview/`. This ADR records rationale only.

PTO uses these instruction classes: Sync and Config; Elementwise Tile-Tile;
Tile-Scalar and Immediate; Reduce and Expand; Memory and Data Movement; Matrix
and Matrix-Vector; Layout and Rearrangement; and Irregular and Complex. Direct
Tile operations currently occupy the latter seven classes. Classification is
semantic and remains independent of execution-engine selection.

Every direct Tile operation names exactly one engine: `VEC`, `TLSU`, `CUBE`, or
`SFU`. `VEC` is restricted to elementwise operations. Operations requiring
specialized or complex hardware use `SFU`; memory/data-transfer operations use
`TLSU`; matrix operations use `CUBE`. A semantic class does not imply an engine:
for example, a data-rearrangement operation may use TLSU, while a complex
elementwise operation may use SFU.

The existing TEPL Mode/Function bit encoding is unchanged. `BSTART.VEC` and
`BSTART.SFU` are accepted assembly aliases constrained by the selected Tile
operation's engine. `BSTART.TEPL` remains an accepted compatibility spelling.
Canonical assembly and disassembly render `BSTART.VEC` or `BSTART.SFU`, never
`BSTART.TEPL`. Alias selection cannot create a new encoding, change selector
ownership, or change instruction semantics.

## Consequences

- ASL paths, mirrored Markdown, and mirrored independent tests use the PTO
  instruction classes rather than encoding-family directories.
- Catalog projections expose both semantic class and execution engine while
  retaining Mode, Function, selector, mask, and match unchanged.
- Downstream assemblers may accept the TEPL compatibility spelling, but all new
  generated text and disassembly use the engine-specific canonical spelling.
- TEPL remains only the unchanged binary carrier and compatibility spelling;
  it is not an execution-engine classification.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Binary carriers and execution engines are different architectural concepts. Treating the legacy TEPL carrier name as an engine obscured which semantics execute on VEC, SFU, CUBE, or TLSU and made catalog and disassembly terminology inconsistent.

二进制载体与执行引擎是不同的架构概念。把旧 TEPL 载体名称当作引擎，会掩盖语义究竟由 VEC、SFU、CUBE 还是 TLSU 执行，并造成目录与反汇编术语不一致。

### Detailed decision / 详细决策

Each affected Tile operation receives an explicit instruction class and execution-engine classification. Engine-specific canonical aliases replace TEPL as the generated spelling while preserving the underlying Mode, Function, selector, mask, and match. TEPL remains a compatibility spelling and unchanged binary carrier only.

每个受影响 Tile 操作都获得明确的指令类别和执行引擎分类。生成文本采用引擎特定的规范别名替代 TEPL，同时保持底层 Mode、Function、selector、mask 和 match 不变。TEPL 仅保留为兼容拼写和未改变的二进制载体。

### What changed / 改动内容

#### English

- Assigned explicit Tile classes and VEC/SFU/CUBE/TLSU engine identities.
- Changed canonical generated names without changing binary encodings.

#### 中文

- 为 Tile 操作明确分配类别及 VEC/SFU/CUBE/TLSU 引擎身份。
- 在不改变二进制编码的前提下更新生成的规范名称。

### Scope and boundaries / 范围与边界

This is a classification and naming decision. It does not change selectors, operands, masks, matches, or operation results; compatibility assemblers may continue accepting TEPL spellings.

这是分类与命名决策，不改变 selector、操作数、mask、match 或操作结果；兼容汇编器仍可接受 TEPL 拼写。
