---
{
  "id": "ADR-GOV-0010",
  "title": "PTO ISA 0.58.5.0 to 0.58.6 compatibility and release identity",
  "title_zh": "PTO ISA 0.58.5.0 至 0.58.6 的兼容性与发布身份",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-05",
  "accepted": "2026-09-05",
  "rejected": null,
  "superseded": null,
  "baseline": "ae04395a024046e2b77395ffc2e732804181c22f",
  "target_releases": ["0.58.6.0"],
  "affected_ndf": ["PTO-ARCH-ENCODING-OWNERSHIP-001"],
  "affected_units": ["PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP"],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/251",
  "release_impact": "required",
  "release_boundary": true,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---

# ADR-GOV-0010: PTO ISA 0.58.5.0 to 0.58.6 compatibility and release identity

## Summary

Publish the accepted post-`v0.58.5.0` architecture delta as PTO ISA `0.58.6`,
publication `0.58.6.0`, with encoding ABI
`pto-isa-0.58.6-mode-function-v1`.

## Context

The `0.58.5.1` candidate was fully validated but not published. It contains
accepted interface changes, including operation retirement and
`BSTART.TIMG2COL`, that require a new architecture identity instead of a
revision under the published `0.58.5` line.

## Decision

Advance the architecture identity to `0.58.6` and its first publication to
`0.58.6.0`. Retarget the accepted but unpublished `0.58.5.1` decision set to
this publication. Keep `v0.58.5.0` immutable and use its exact commit as the
release-selection baseline.

## Normative delta

This record changes release identity and compatibility classification. The
owning ASL/NDF and accepted topic ADRs remain the sole source of instruction
semantics.

## Externally visible interface delta

The published operation inventory and accepted instruction contracts differ
from `v0.58.5.0`. Object identity advances to
`pto-isa-0.58.6-mode-function-v1`; old binaries are not silently relabeled or
accepted through an alias.

## Defaults and intentionally unspecified behavior

Defaults and intentionally unspecified behavior remain those of the accepted
ASL/NDF owners. This decision adds no target-specific behavior and no
compatibility decoder.

## Compatibility and dependent-toolchain impact

Consumers needing retired `v0.58.5.0` operations remain pinned to that release.
Consumers adopting `0.58.6` update the exact ABI identity, LLVM header and
ASL-MODEL lock. Instruction assignments and the form fingerprint remain
unchanged. The canonical encoding projection intentionally advances from
`bc0718ee31162ba7f6ea04d2a5853c49fe30e7cb36b33c0704c58678710a0c87` to
`a757f2e50ec8050d2131b6b9ad38657511df80cf3f9424d5f009ea6e0cc35839`
because the projection includes the encoding ABI identity. Any projection drift
beyond this reviewed identity transition requires a new architecture audit and
fresh dependent evidence.

## Alternatives considered

Publishing as `0.58.5.1` was rejected because operation-surface changes merit a
new architecture version. Relabeling the successful candidate run was rejected
because release evidence is bound to its exact identity.

## Risks and mitigations

Identity can drift across repositories. Preflight binds PTO-SPEC, LLVM and
ASL-MODEL before expensive validation. Artifact certification downloads and
rechecks every result before a run becomes release-eligible.

## Implementation obligations

- Retarget unpublished `0.58.5.1` decisions to `0.58.6.0`.
- Regenerate PTO release, numeric-profile, readiness and manifest evidence.
- Update LLVM and ASL-MODEL identities without changing instruction behavior.

## Verification obligations

Each repository lands signed reviewed commits. The PTO release workflow then
validates the final tuple, every AVS point, site artifact and model closure.

## Release consequences

The first publication tag is `v0.58.6.0`. No existing tag or asset is moved or
replaced.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Accepted post-`v0.58.5.0` changes alter the public operation
surface. They need a new architecture identity; the completed `0.58.5.1`
validation remains evidence for its original candidate only.

**中文。** `v0.58.5.0` 之后已接受的改动改变了公开操作表面，因此需要新的架构身份；
已经完成的 `0.58.5.1` 验证仍只属于原候选身份。

### Detailed decision / 详细决策

**English.** PTO advances to architecture `0.58.6`, publication `0.58.6.0`,
and ABI `pto-isa-0.58.6-mode-function-v1`. The exact `v0.58.5.0` commit remains
the immutable baseline; all downstream repositories consume the new identity
before a fresh release run.

**中文。** PTO 推进到架构 `0.58.6`、出版 `0.58.6.0` 和 ABI
`pto-isa-0.58.6-mode-function-v1`。精确的 `v0.58.5.0` commit 继续作为不可变基线；
所有下游仓必须先采用新身份，再执行全新的发布验证。

### What changed / 改动内容

The release identity and compatibility boundary advance while the accepted
topic decisions retain their original rationale and semantic owners.

发布身份与兼容性边界向前推进，同时各已接受主题决策保留原有理由及语义 owner。

#### English

- Added the `0.58.5.0` to `0.58.6` compatibility boundary.
- Assigned unpublished accepted candidate changes to `0.58.6.0`.
- Required exact cross-repository validation and permanent evidence.

#### 中文

- 新增 `0.58.5.0` 至 `0.58.6` 的兼容性边界。
- 将尚未出版的已接受候选改动归入 `0.58.6.0`。
- 要求精确跨仓验证与永久证据。

### Scope and boundaries / 范围与边界

**English.** This record owns version identity, compatibility and release
closure. It does not restate instruction semantics, authorize an alias, or make
the earlier candidate run sufficient for `0.58.6.0` publication.

**中文。** 本记录负责版本身份、兼容性和发布闭包；它不重述指令语义，不授权兼容别名，
也不使较早候选的验证足以支持 `0.58.6.0` 出版。
