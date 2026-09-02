---
{
  "id": "ADR-GOV-0007",
  "title": "PTO ISA 0.58.3 to 0.58.4 compatibility boundary",
  "title_zh": "PTO ISA 0.58.3 至 0.58.4 兼容性边界",
  "status": "accepted",
  "authors": [
    "ckwllawliet <641433195@qq.com>"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-22",
  "accepted": "2026-08-22",
  "rejected": null,
  "superseded": null,
  "baseline": "23ca8833fef3f97dbc65beef4924b0b4671cdfdf",
  "target_releases": [
    "0.58.4"
  ],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-B-IOT-STREAM-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-ASSEMBLE-RANGE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-B-ASSEMBLE",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/123",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0099"
  ]
}
---


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Published architecture `0.58.3` is immutable, while accepted range-command and PE-level changes require new artifacts and compatibility metadata. Reusing the published identity would obscure which instruction and ABI contract a consumer selected.

已发布的架构 `0.58.3` 不可变，而已接受的 range command 和 PE 级变更需要新的制品及兼容性元数据。复用已发布身份会使使用者无法明确自己选择的是哪套指令与 ABI 契约。

### Detailed decision / 详细决策

The candidate advances to architecture `0.58.4` and ABI `pto-isa-0.58.4-mode-function-v1`, using the published `0.58.3` commit as baseline. Candidate changes target the new identity, while all published `0.58.3` artifacts remain unchanged.

候选版本推进到架构 `0.58.4` 和 ABI `pto-isa-0.58.4-mode-function-v1`，并以已发布的 `0.58.3` commit 为基线。候选变更归入新身份，所有已发布的 `0.58.3` 制品保持不变。

### What changed / 改动内容

#### English

- Assigned a new architecture and ABI identity to the accepted delta.
- Bound evaluation to the published baseline without regenerating old artifacts.
- Separated compatibility metadata from release authorization.

#### 中文

- 为已接受的差异分配新的架构与 ABI 身份。
- 将评估绑定到已发布基线，同时不重新生成旧制品。
- 将兼容性元数据与发布授权分离。

### Scope and boundaries / 范围与边界

This record assigns compatibility identity only. It does not redefine underlying semantics or authorize validation, tagging, publication, push, or mutation of `0.58.3` artifacts.

本记录只分配兼容性身份。它不重新定义底层语义，也不授权验证、打标签、发布、推送或修改 `0.58.3` 制品。
# ADR-GOV-0007: PTO ISA 0.58.3 to 0.58.4 compatibility boundary

## Context

Published PTO ISA `0.58.3` is an immutable release identity. The accepted
range-command and PE-level programming-model delta is a new working candidate
and must not mutate the published `0.58.3` manifest, ABI vectors, encoding
evidence, or release provenance. The candidate therefore needs an explicit
compatibility boundary and a distinct release identity.

## Decision

The working candidate advances from architecture version `0.58.3` to
`0.58.4` and uses the repository-convention encoding ABI
`pto-isa-0.58.4-mode-function-v1`. ADR-CUBE-0010 capacity/M-sharding, ADR-BLOCK-0016
range commands, and the accepted PE-level programming-model delta target
`0.58.4`.

Published `0.58.3` remains immutable: its release manifest, `0.58.3` ABI
vectors, `0.58.3` encoding-totality evidence, release-input registry, and
published encoding ABI are not regenerated or rewritten by this candidate.
The candidate's release selection uses the published `0.58.3` commit as its
baseline and evaluates the accepted candidate NDF set under the new `0.58.4`
identity, so the published-NDF-set blocker does not apply across identities.

This decision assigns release compatibility metadata only. It does not
authorize V2 release validation, manifest regeneration, tagging, publication,
push, or pull-request creation.

## Consequences

- `0.58.3` consumers retain the published instruction and ABI contract.
- `0.58.4` is the only working candidate identity for the range-command and
  PE-level programming-model changes.
- Ordinary PR projections may advance to `0.58.4`; published `0.58.3`
  artifacts remain byte-for-byte unchanged.

## Rejected Alternatives

- Mutating the published `0.58.3` manifest or evidence is rejected because a
  published release identity is immutable.
- Reusing the `0.58.3` architecture version or encoding ABI is rejected because
  it would make the candidate content-addressed identity ambiguous.
