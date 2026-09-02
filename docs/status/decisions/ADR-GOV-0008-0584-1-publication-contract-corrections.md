---
{
  "id": "ADR-GOV-0008",
  "title": "PTO ISA 0.58.4.1 publication-contract correction boundary",
  "title_zh": "PTO ISA 0.58.4.1 出版契约修正边界",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "2052214b8e4b046aa77f68dc0ba8ca23447ae00d",
  "target_releases": [
    "0.58.4.1"
  ],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-SETRET-ADR-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSORT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-SETRET",
    "PTO-TILE-MGATHER",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSORT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/18",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0102"
  ]
}
---


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Some generated instruction contracts contradicted behavior already fixed by executable ASL and AVS. Correcting owner text changes content-addressed NDF digests even when architecture behavior and encoding stay unchanged, so publication provenance needs a distinct identity.

部分生成的指令契约与可执行 ASL 和 AVS 已确定的行为相矛盾。即使架构行为和编码不变，修正 owner 文本也会改变按内容寻址的 NDF 摘要，因此出版来源需要独立身份。

### Detailed decision / 详细决策

Corrected artifacts use publication `0.58.4.1` while retaining architecture `0.58.4` and the existing ABI. Corrections are limited to documentation facts already fixed by executable owners and tests, including operand names, absent fields, DataType sets, and terminology.

修正后的制品使用出版 `0.58.4.1`，同时保留架构 `0.58.4` 和现有 ABI。修正仅限于可执行 owner 与测试已确定的文档事实，包括操作数名称、不存在的字段、DataType 集合和术语。

### What changed / 改动内容

#### English

- Corrected contradictory contract prose under a new publication revision.
- Kept encoding, handlers, state transitions, faults, ordering, algorithms, and ABI unchanged.
- Separated publication revision from architecture-version selection.

#### 中文

- 在新出版修订下修正相互矛盾的契约文字。
- 保持编码、handler、状态转换、故障、顺序、算法和 ABI 不变。
- 区分出版修订与架构版本选择。

### Scope and boundaries / 范围与边界

The record covers publication-contract corrections and evidence digests. It changes no executable semantics and authorizes no release operation or reuse of an old artifact identity for changed content.

本记录覆盖出版契约修正及证据摘要。它不改变可执行语义，不授权发布操作，也不允许对已变化内容复用旧制品身份。
# ADR-GOV-0008: PTO ISA 0.58.4.1 publication-contract correction boundary

## Context

Bilingual reader-guide review found contradictions inside several structured
`PTO-INSTRUCTION` contracts. Executable ASL handlers and discriminating AVS
already agreed on the behavior, but generated contract prose named a wrong base
operand, an absent field, a stale DataType set, or an imprecise operation label.
Because synthetic instruction-contract NDF clauses include that metadata,
correcting the owner text changes their content digests even though execution
does not change.

Published architecture version `0.58.4` and its encoding ABI remain the current
architectural identity. Reusing the exact published artifact identity for
changed documentation contracts would make release provenance ambiguous.

## Decision

The corrected documentation and evidence use publication revision `0.58.4.1`
while retaining architecture version `0.58.4` and encoding ABI
`pto-isa-0.58.4-mode-function-v1`. Release selection records both identities
and freezes NDF digests by publication revision.

Accepted corrections are limited to statements already determined by the
current executable owner and AVS:

- no-operand system forms no longer describe a nonexistent encoded-zero operand;
- AGU contracts name the executable `SrcR` base, fixed scaling, and aligned TPC;
- `SETRET` and `FCVTA` terminology matches the selected immediate and rounding mode;
- Tile instruction DataType and definedness contracts match active helpers.

No opcode, mask/match, operand encoding, semantic handler, state transition,
fault selection, ordering rule, profile algorithm, or ABI changes in this
publication revision. Current meaning remains in the affected ASL/NDF owners;
this ADR records only the compatibility and publication boundary.

## Compatibility

Software and implementations conforming to architecture `0.58.4` observe no
behavioral delta. The corrected artifacts no longer contradict the already
executable contract. Consumers that content-address documentation or NDF
projections select publication `0.58.4.1`; consumers selecting architectural
behavior continue to select architecture `0.58.4`.

## Verification

Focused AVS covers every corrected contract family. The complete ASL inventory,
generated contracts, catalogs, bilingual projections, release traceability, and
site gates are rerun at the publication commit.

## Release impact

A distinct publication revision and regenerated content-addressed evidence are
required. This decision does not itself authorize tagging, GitHub Release
publication, Pages deployment, or mutation of a previously published artifact.
