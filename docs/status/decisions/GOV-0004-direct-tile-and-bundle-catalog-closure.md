---
{
  "id": "ADR-GOV-0004",
  "title": "Direct Tile and bundle catalog closure",
  "title_zh": "Direct Tile 与 Bundle 目录闭合",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-15",
  "accepted": "2026-08-15",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
  ],
  "affected_ndf": [
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-ARCH-TEPL-ALIAS-001",
    "PTO-ARCH-TILE-EXECUTION-ENGINE-001",
    "PTO-ARCH-TILE-INSTRUCTION-CLASS-001",
    "PTO-B-CATR-CONTROL-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DIM-WRITE-001",
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-B-HINT-LIFECYCLE-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BLOCK-ERCOV-RESERVED-001",
    "PTO-BLOCK-ESAVE-RESERVED-001",
    "PTO-BLOCK-MSET-FILL-001",
    "PTO-BLOCK-XB-RESERVED-001",
    "PTO-BSTART-CALL-DECISION-BINDING-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTART-FP-CONTROL-001",
    "PTO-BSTART-GMOV-COLLECTIVE-001",
    "PTO-BSTART-ICALL-DECISION-BINDING-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-BSTART-SFU-DECISION-BINDING-001",
    "PTO-BSTART-STD-CONTROL-001",
    "PTO-BSTART-SYS-CONTROL-001",
    "PTO-BSTART-TEPL-DECISION-BINDING-001",
    "PTO-BSTART-TGEMV-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMV-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMV-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-CONTRACT-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMUL-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-BSTART-TPREFETCH-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-BSTART-VEC-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTART-CONTROL-001",
    "PTO-C-BSTART-FP-CONTROL-001",
    "PTO-C-BSTART-STD-CONTROL-001",
    "PTO-C-BSTART-SYS-CONTROL-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-FENTRY-RESTARTABLE-FRAME-001",
    "PTO-FEXIT-RESTARTABLE-FRAME-001",
    "PTO-FRET-RA-RESTARTABLE-FRAME-001",
    "PTO-FRET-STK-RESTARTABLE-FRAME-001",
    "PTO-GMOV-CORE4-PEER-001",
    "PTO-HL-QMT-GQM-001",
    "PTO-HL-QPOP-GQM-001",
    "PTO-HL-QPUSH-GQM-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-MCOPY-RESTART-001",
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
    "PTO-TCONCAT-CONTRACT-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-TDEQUANT-CONTRACT-001",
    "PTO-TDIV-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TEXP-CONTRACT-001",
    "PTO-TEXPANDS-CONTRACT-001",
    "PTO-TEXTRACT-CONTRACT-001",
    "PTO-TFMA-CONTRACT-001",
    "PTO-TGATHER-CONTRACT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-BIAS-CONTRACT-001",
    "PTO-TGEMV-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-THISTOGRAM-CONTRACT-001",
    "PTO-TIMG2COL-CONTRACT-001",
    "PTO-TINSERT-CONTRACT-001",
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
    "PTO-TMRGSORT-CONTRACT-001",
    "PTO-TMUL-CONTRACT-001",
    "PTO-TMULS-CONTRACT-001",
    "PTO-TNEG-CONTRACT-001",
    "PTO-TNOT-CONTRACT-001",
    "PTO-TOR-CONTRACT-001",
    "PTO-TORS-CONTRACT-001",
    "PTO-TPREFETCH-FOOTPRINT-001",
    "PTO-TQUANT-CONTRACT-001",
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
    "PTO-TSORT-CONTRACT-001",
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
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION",
    "PTO-BLOCK-B-CATR",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-DIM",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTART-CALL",
    "PTO-BLOCK-BSTART-FP",
    "PTO-BLOCK-BSTART-GMOV",
    "PTO-BLOCK-BSTART-ICALL",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-SFU",
    "PTO-BLOCK-BSTART-STD",
    "PTO-BLOCK-BSTART-SYS",
    "PTO-BLOCK-BSTART-TEPL",
    "PTO-BLOCK-BSTART-TGEMV",
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMV-BIAS",
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TPREFETCH",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-BLOCK-BSTART-VEC",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-B-DIMI",
    "PTO-BLOCK-C-BSTART",
    "PTO-BLOCK-C-BSTART-FP",
    "PTO-BLOCK-C-BSTART-STD",
    "PTO-BLOCK-C-BSTART-SYS",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-ERCOV",
    "PTO-BLOCK-ESAVE",
    "PTO-BLOCK-FENTRY",
    "PTO-BLOCK-FEXIT",
    "PTO-BLOCK-FRET-RA",
    "PTO-BLOCK-FRET-STK",
    "PTO-BLOCK-HL-QMT",
    "PTO-BLOCK-HL-QPOP",
    "PTO-BLOCK-HL-QPUSH",
    "PTO-BLOCK-L-BSTOP",
    "PTO-BLOCK-MCOPY",
    "PTO-BLOCK-MSET",
    "PTO-BLOCK-XB",
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
    "PTO-TILE-TCONCAT",
    "PTO-TILE-TCVT",
    "PTO-TILE-TDEQUANT",
    "PTO-TILE-TDIV",
    "PTO-TILE-TDIVS",
    "PTO-TILE-TEXP",
    "PTO-TILE-TEXPANDS",
    "PTO-TILE-TEXTRACT",
    "PTO-TILE-TFMA",
    "PTO-TILE-TGATHER",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-THISTOGRAM",
    "PTO-TILE-TIMG2COL",
    "PTO-TILE-TINSERT",
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
    "PTO-TILE-TMRGSORT",
    "PTO-TILE-TMUL",
    "PTO-TILE-TMULS",
    "PTO-TILE-TNEG",
    "PTO-TILE-TNOT",
    "PTO-TILE-TOR",
    "PTO-TILE-TORS",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TQUANT",
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
    "PTO-TILE-TSORT",
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
    "ADR-0052"
  ]
}
---
# ADR-GOV-0004: Direct Tile and bundle catalog closure


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The direct Tile catalog, bundle forms, ASL handlers, decoder witnesses, generated pages, and independent tests describe the same instruction surface. Divergent selectors, names, engine classes, reservations, or operand contracts would create conflicting definitions of PTO.

Direct Tile 目录、Bundle 形式、ASL handler、解码见证、生成页面和独立测试共同描述同一指令表面。若选择器、名称、执行引擎分类、保留空间或操作数契约不一致，就会产生相互冲突的 PTO 定义。

### Detailed decision / 详细决策

The record closes the accepted direct Tile set, assigns canonical selectors and VEC/SFU/TLSU/CUBE classifications, identifies absent operations, and keeps extension encodings fail-closed. Bundle starts and direct operations use the same catalog identities, with consistent decode, operands, handlers, documentation, and tests.

本记录闭合已接受的 Direct Tile 集合，分配规范选择器及 VEC/SFU/TLSU/CUBE 分类，标明不存在的操作，并让扩展编码保持 fail-closed。Bundle start 与 Direct Tile 操作使用同一目录身份，并在解码、操作数、handler、文档和测试中保持一致。

### What changed / 改动内容

#### English

- Fixed the accepted direct Tile inventory and selector ownership.
- Recorded additions, removals, and reserved holes with rejection before effects.
- Bound bundle and Tile projections to the same operand, handler, destination, and engine facts.

#### 中文

- 固定已接受的 Direct Tile 清单及选择器所有权。
- 记录新增、删除和保留空洞，并要求在产生效果前拒绝。
- 将 Bundle 与 Tile 投影绑定到相同的操作数、handler、目的和执行引擎事实。

### Scope and boundaries / 范围与边界

The decision covers the listed Tile, bundle, encoding, and instruction-contract owners. It assigns no semantics to reserved extension space, revives no removed spelling, and does not make prose catalogs normative.

该决策覆盖所列 Tile、Bundle、编码和指令契约 owner。它不为保留扩展空间分配语义，不恢复已删除拼写，也不把文字目录变为规范来源。
> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

## Context

The direct Tile catalog, bundle forms, ASL handlers, decoder witnesses,
instruction pages, and independent tests describe one architecture surface.
Changing only one projection would create a second, drifting instruction-set
definition.

## Decision

PTO accepts exactly 109 direct Tile operations: 87 operations on the TEPL raw
Mode/Function carrier, 10 TLSU operations, and 12 CUBE operations. The TEPL
carrier does not define the execution engine: each accepted operation is
classified canonically as VEC or SFU by its architectural hardware contract.

`BSTART.ACCCVT` is absent. `BSTART.GMOV`, `BSTART.MGATHER.MASK`,
`BSTART.MSCATTER.MASK`, and `BSTART.MGATHER.CAS` are accepted TLSU starts.
`GMOV`, `TFMA`, and `THISTOGRAM` are accepted direct operations. `TRANDOM` and
`TADDC` are absent. `TSORT` owns selector `0x06C` and carries an explicit
`sort_width` operand.

`TMOV` remains accepted at Local Function 2. `TSEL` owns Mode 0 / Function 26
(`0x01A`), `TSELS` owns Mode 1 / Function 26 (`0x03A`), and `TFMA` owns Mode 0
/ Function 28 (`0x01C`). Mode 3 / Function 9 (`0x069`) is reserved and rejects
before effects.

The complete two-level extension encoding space is reserved but not executed
by PTO. Its masks, matches, split fields, and widths are owned by
`asl/arch/overview/encoding-ownership.asl`. No accepted PTO scalar, block, or
Tile form may overlap those patterns, and PTO assigns no execution semantics
to them.

Every CUBE operation writes an explicit Local destination D. ACC variants also
read an explicit Local accumulator C. C is snapshotted before D is written, so
`D == C` has read-old/write-new behavior. PTO has no implicit accumulator
singleton.

ASL is the sole semantic owner. Catalogs, generated pages, decoder witnesses,
requirements, and AVS points are projections or evidence and must regenerate
together from the current ASL owners.

## Consequences

- The direct Tile catalog and all derived surfaces must report exactly 109
  operations with the same selectors, operand roles, and handlers.
- Removed spellings are absent unless a separate current decision explicitly
  reserves their raw space.
- Reserved extension encodings remain fail-closed and cannot be reassigned by
  a later PTO operation without a new architecture decision.
- CUBE destination and accumulator behavior is always explicit in the owning
  mnemonic contract.
- Current instruction pages embed the exact ASL decode and operation regions;
  no parallel prose catalog defines instruction behavior.
