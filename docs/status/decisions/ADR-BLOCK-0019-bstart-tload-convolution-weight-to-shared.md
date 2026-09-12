---
{
  "id": "ADR-BLOCK-0019",
  "title": "BSTART.TLOAD convolution weights to Shared NK",
  "title_zh": "BSTART.TLOAD 卷积权重到 Shared NK",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-09-09",
  "accepted": "2026-09-11",
  "rejected": null,
  "superseded": null,
  "baseline": "226b5806d8ed8d03c38ee6ec6ff3f880b381ddaf",
  "target_releases": [
    "unassigned"
  ],
  "interface_change": true,
  "affected_ndf": [
    "PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001",
    "PTO-BSTART-TLOAD-WEIGHT-SOURCE-001",
    "PTO-BSTART-TLOAD-WEIGHT-KORDER-001",
    "PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001",
    "PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC",
    "PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM",
    "PTO-BLOCK-MODEL-OPERANDS-WEIGHT-PARAMETERS",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-TILE-TLOAD"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/99",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR-BLOCK-0019: BSTART.TLOAD convolution weights to Shared NK

## Context

Issue #99 requires a bounded first-version contract for loading convolution
weights from GM into an existing Shared matrix destination. The change must
reuse `BSTART.TLOAD`, the existing B.DATR/B.DIM/B.IOR/B.IOS carriers, and the
existing Shared generation protocol without changing ordinary TLOAD or
TMATMUL semantics.

## Decision

An explicit B.DATR layout code 10 (`OHWI2NK`) or 11 (`OIHW2NK`) selects the
weight-mode TLOAD form. The inherited BSTART DataType is used when B.DATR
DataType is `DTYPE_NONE`; the remaining B.DATR fields are fixed to zero
padding, EQ, default rounding, saturation disabled, and canonicalization
disabled. LB0, LB1, and LB2 retain their generic names and mean ValidK,
ValidN, and TotalK for the row-major Shared `[N][K]` destination view.

ShapeGPR packs Cin, Cout, KernelH, and KernelW; StartGPR packs NStart and
KStart. OHWI and OIHW sources are projected into canonical
`[kh][kw][c1][c0]` K order, with c0 fastest. Cin padding lanes are defined raw
zero and perform no GM access. KStart and ValidK are C0-aligned, while NStart
and ValidN select a valid Cout window without a C0 alignment requirement.

A singleton Shared issuer publishes without B.ASSEMBLE. A multi-participant
Shared mask uses the existing B.ASSEMBLE phases and assigns contiguous N-row
ranges in selected-PE order. Complete footprint preflight precedes GM reads,
allocation, payload, definedness, and publication; failed attempts preserve
the previously published generation and restart at the operation boundary.

The implementation is limited to the supported non-packed DataType domain
owned by ordinary TLOAD. The reserved future layouts `OHWI2KN` and `OIHW2KN`
remain unassigned, and Local/CUBE destinations, batch greater than one,
grouped/depthwise convolution, and new assembly/publication protocols are out
of scope.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

This decision is needed because convolution weights have source layouts that do not match the existing Shared NK consumer view. A bounded BSTART.TLOAD extension keeps the carrier stable, gives the two source layouts one canonical K order, and makes the source crop and destination geometry executable without changing ordinary TLOAD.

之所以需要该决策，是因为卷积权重的源布局与现有 Shared NK 消费者视图不同。受限的 BSTART.TLOAD 扩展保持载体稳定，为两种源布局规定统一的 K 顺序，并使源裁剪与目标几何可执行，同时不改变普通 TLOAD。

### Detailed decision / 详细决策

The implemented forms are OHWI2NK and OIHW2NK. They use DTYPE_NONE, zero padding, EQ, default rounding, Sat=0, and Canonicalize=0. ShapeGPR and StartGPR carry the frozen parameters, K windows are C0-aligned, and N windows may start at any valid Cout row. GM is fully preflighted before a singleton or cooperative Shared publication.

已实现的形式为 OHWI2NK 与 OIHW2NK。它们使用 DTYPE_NONE、零填充、EQ、默认舍入、Sat=0 和 Canonicalize=0。ShapeGPR 与 StartGPR 携带冻结参数，K 窗口按 C0 对齐，N 窗口可以从任意有效 Cout 行开始。单例或协作式 Shared 发布之前，必须完成全部 GM 访问预检。

### What changed / 改动内容

#### English

- Added the two weight-only layout names and their decode/legality ownership.
- Added dedicated schema, packed-parameter, GM-address, execution, NDF, and AVS owners.
- Regenerated documentation, catalogs, traceability, and focused evidence.

#### 中文

- 增加两个仅用于权重的布局名称及其解码和合法性归属。
- 增加专用 schema、打包参数、GM 地址、执行、NDF 与 AVS owner。
- 重新生成文档、目录、可追溯性和聚焦证据。

### Scope and boundaries / 范围与边界

This accepted decision authorizes the named OHWI2NK and OIHW2NK implementation in its affected ASL/NDF owners. Release assignment, publication, and implementation-issue closure remain separate actions. TWEIGHT, a new Shared descriptor, a new assembly protocol, KN layouts, Local/CUBE destinations, batch greater than one, grouped convolution, and depthwise convolution remain outside this decision. Ordinary TLOAD and TMATMUL TransB semantics remain unchanged.

本已批准决策授权在其受影响的 ASL/NDF owner 中实现指定的 OHWI2NK 与 OIHW2NK 形式。发布版本分配、发布与实现 issue 关闭仍是独立操作。TWEIGHT、新的 Shared 描述符、新的 assembly 协议、KN 布局、Local/CUBE 目标、大于一的 batch、分组卷积与 depthwise 卷积仍不在本决策范围内。普通 TLOAD 与 TMATMUL TransB 语义保持不变。

## Consequences

The weight transformation has a dedicated ASL schema, parameter, GM address,
and execution owner. Generated instruction documentation, catalogs, NDF
supplements, and evidence must be regenerated from those owners. Focused AVS
coverage proves source-layout equivalence, canonical K order and padding,
window crops, cooperative publication, and legality/failure preservation.

This accepted record supersedes the earlier unaccepted weight-layout sketch in
Issue #99. Release assignment and publication remain separate decisions.

## Traceability

- Implementation issue: #99.
- Baseline: `226b5806d8ed8d03c38ee6ec6ff3f880b381ddaf`.
- The candidate encoded-form projection fingerprint is `09d2fa91f3c9dac5b2cf9867d19b80e9268be813339035467f390fdbe4775b16`; this is the mechanical review binding for the frozen layout/contract projection.
- NDF owners: `PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001`,
  `PTO-BSTART-TLOAD-WEIGHT-SOURCE-001`,
  `PTO-BSTART-TLOAD-WEIGHT-KORDER-001`,
  `PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001`, and
  `PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001`.
