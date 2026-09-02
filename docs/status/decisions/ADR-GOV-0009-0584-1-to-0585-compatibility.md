---
{
  "id": "ADR-GOV-0009",
  "title": "PTO ISA 0.58.4.1 to 0.58.5 compatibility boundary",
  "title_zh": "PTO ISA 0.58.4.1 至 0.58.5 兼容性边界",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-27",
  "accepted": "2026-08-27",
  "rejected": null,
  "superseded": null,
  "baseline": "f97db03077b3363358854d5c8fafdb9c9b3b9503",
  "target_releases": [
    "0.58.5"
  ],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-ARCH-GM-ACCESS-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-B-SHARED-WHOLE-PARENT-READY-001",
    "PTO-B-SUBVIEW-SHARED-PER-PE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-INST-BLOCK-B-IOS",
    "PTO-INST-BLOCK-B-IOT",
    "PTO-INST-BLOCK-BSTART-TLOAD",
    "PTO-INST-BLOCK-BSTART-TMATMUL",
    "PTO-INST-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-INST-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-INST-BLOCK-BSTART-TMATMULMX",
    "PTO-INST-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-INST-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-INST-BLOCK-BSTART-TMOV",
    "PTO-INST-BLOCK-BSTART-TSTORE",
    "PTO-INST-TILE-GMOV",
    "PTO-INST-TILE-MGATHER",
    "PTO-INST-TILE-MGATHER-CAS",
    "PTO-INST-TILE-MGATHER-MASK",
    "PTO-INST-TILE-MSCATTER",
    "PTO-INST-TILE-MSCATTER-MASK",
    "PTO-INST-TILE-TCI",
    "PTO-INST-TILE-TCONCAT",
    "PTO-INST-TILE-TDEQUANT",
    "PTO-INST-TILE-TEXTRACT",
    "PTO-INST-TILE-TFILLPAD",
    "PTO-INST-TILE-TGATHER",
    "PTO-INST-TILE-TGEMV",
    "PTO-INST-TILE-TGEMV-ACC",
    "PTO-INST-TILE-TGEMV-BIAS",
    "PTO-INST-TILE-TGEMV-MX",
    "PTO-INST-TILE-TGEMV-MX-ACC",
    "PTO-INST-TILE-TGEMV-MX-BIAS",
    "PTO-INST-TILE-THISTOGRAM",
    "PTO-INST-TILE-TINSERT",
    "PTO-INST-TILE-TLOAD",
    "PTO-INST-TILE-TMATMUL",
    "PTO-INST-TILE-TMATMUL-ACC",
    "PTO-INST-TILE-TMATMUL-BIAS",
    "PTO-INST-TILE-TMATMUL-MX",
    "PTO-INST-TILE-TMATMUL-MX-ACC",
    "PTO-INST-TILE-TMATMUL-MX-BIAS",
    "PTO-INST-TILE-TMOV",
    "PTO-INST-TILE-TMRGSORT",
    "PTO-INST-TILE-TPACK",
    "PTO-INST-TILE-TPARTADD",
    "PTO-INST-TILE-TPARTMAX",
    "PTO-INST-TILE-TPARTMIN",
    "PTO-INST-TILE-TPARTMUL",
    "PTO-INST-TILE-TPERMUTE",
    "PTO-INST-TILE-TPREFETCH",
    "PTO-INST-TILE-TQUANT",
    "PTO-INST-TILE-TSCATTER",
    "PTO-INST-TILE-TSHUF",
    "PTO-INST-TILE-TSORT",
    "PTO-INST-TILE-TSTORE",
    "PTO-INST-TILE-TTRANS",
    "PTO-INST-TILE-TTRI",
    "PTO-INST-TILE-TUNPACK",
    "PTO-ISA-LEGACY-SHARED-MOVEMENT-001",
    "PTO-TFILLPAD-CONTRACT-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001",
    "PTO-TPACK-CONTRACT-001",
    "PTO-TPARTADD-CONTRACT-001",
    "PTO-TPARTMAX-CONTRACT-001",
    "PTO-TPARTMIN-CONTRACT-001",
    "PTO-TPARTMUL-CONTRACT-001",
    "PTO-TPERMUTE-CONTRACT-001",
    "PTO-TSHUF-CONTRACT-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-TTRANS-CONTRACT-001",
    "PTO-TUNPACK-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-FEATURES-TILE-ALLOCATION",
    "PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS",
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-PARTIAL-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TCI",
    "PTO-TILE-TCONCAT",
    "PTO-TILE-TDEQUANT",
    "PTO-TILE-TEXTRACT",
    "PTO-TILE-TFILLPAD",
    "PTO-TILE-TGATHER",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-THISTOGRAM",
    "PTO-TILE-TINSERT",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TMATMUL",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS",
    "PTO-TILE-TMOV",
    "PTO-TILE-TMRGSORT",
    "PTO-TILE-TPACK",
    "PTO-TILE-TPARTADD",
    "PTO-TILE-TPARTMAX",
    "PTO-TILE-TPARTMIN",
    "PTO-TILE-TPARTMUL",
    "PTO-TILE-TPERMUTE",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TQUANT",
    "PTO-TILE-TSCATTER",
    "PTO-TILE-TSHUF",
    "PTO-TILE-TSORT",
    "PTO-TILE-TSTORE",
    "PTO-TILE-TTRANS",
    "PTO-TILE-TTRI",
    "PTO-TILE-TUNPACK",
    "PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX",
    "PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT",
    "PTO-TILE-MODEL-EXECUTION-COMPLEX",
    "PTO-TILE-MODEL-EXECUTION-GENERATION",
    "PTO-TILE-MODEL-EXECUTION-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY",
    "PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT",
    "PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT",
    "PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/18",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0108"
  ]
}
---


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Accepted Shared-range, cooperative-group, and CUBE changes after `0.58.4.1` altered the active NDF set and instruction-contract digests. Publishing them under the old immutable identity would merge incompatible operation surfaces.

`0.58.4.1` 之后接受的 Shared range、cooperative group 和 CUBE 变更改变了活动 NDF 集合及指令契约摘要。若仍以旧的不可变身份发布，就会合并不兼容的操作表面。

### Detailed decision / 详细决策

The consolidated candidate advances to architecture `0.58.5`, publication `0.58.5.0`, and ABI `pto-isa-0.58.5-mode-function-v1`, using the exact `v0.58.4.1` commit as baseline. Decode, legality, effects, faults, and rollback remain owned by affected ASL/NDF sources.

合并后的候选版本推进到架构 `0.58.5`、出版 `0.58.5.0` 和 ABI `pto-isa-0.58.5-mode-function-v1`，并以精确的 `v0.58.4.1` commit 为基线。解码、合法性、效果、故障和回滚仍归受影响的 ASL/NDF 来源所有。

### What changed / 改动内容

#### English

- Created new architecture, publication, and ABI identities for the accepted delta.
- Declared no binary aliases for retired operations or legacy Shared movement.
- Required fresh exact-commit validation and regenerated evidence.

#### 中文

- 为已接受差异创建新的架构、出版和 ABI 身份。
- 明确不为已退役操作或旧 Shared movement 提供二进制别名。
- 要求全新的精确 commit 验证并重新生成证据。

### Scope and boundaries / 范围与边界

This record does not restate instruction semantics or itself publish a release. `0.58.4.1` artifacts remain immutable, and consumers needing the retired surface must keep selecting that publication.

本记录不重述指令语义，也不自行发布版本。`0.58.4.1` 制品保持不可变；需要已退役表面的使用者必须继续选择该出版版本。
# ADR-GOV-0009: PTO ISA 0.58.4.1 to 0.58.5 compatibility boundary

## Context

Publication `0.58.4.1` is immutable. Since that publication, accepted
architecture work changed Shared range and cooperative-group behavior, retired
legacy Shared movement functions, and added private CUBE vector/CELL
rearrangement operations while retiring their replaced operation identities.
The current accepted NDF set and instruction-contract digests therefore cannot
be published under the old architecture or publication identity.

## Decision

The consolidated candidate advances to architecture version `0.58.5`, first
publication revision `0.58.5.0`, and encoding ABI
`pto-isa-0.58.5-mode-function-v1`. The release selection baseline is the exact
published `v0.58.4.1` commit
`5114fb699fa510abd9a3c42bcfa5c592cd724961`.

This decision assigns only the compatibility and release identity. Current
decode, legality, operation, state-transition, no-effect, and fault behavior
remain owned by the affected ASL/NDF sources and their focused AVS evidence.
It does not restate or replace those normative contracts.

## Compatibility

Published `0.58.4.1` artifacts, tags, evidence, and manifests remain immutable.
Consumers that require the retired operation identities or legacy Shared
movement functions must continue selecting `0.58.4.1`; there are no binary
aliases in `0.58.5`. Consumers selecting the new operation set and Shared
behavior select architecture `0.58.5` and publication `0.58.5.0`.

## Verification and release impact

The release requires regenerated content-addressed evidence, ABI vectors,
release manifest, complete exact-commit ASL validation, static-site validation,
an immutable `v0.58.5.0` tag, and publication from the exact validated site
artifact. A different-commit, stale, skipped, failed, or partial run is not
release evidence.
