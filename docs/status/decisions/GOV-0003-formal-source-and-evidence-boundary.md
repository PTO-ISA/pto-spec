---
{
  "id": "ADR-GOV-0003",
  "title": "Formal source and evidence boundary",
  "title_zh": "形式化来源与证据边界",
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
    "PTO-SOURCE-HIERARCHY"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0036"
  ]
}
---
# ADR-GOV-0003: Formal source and evidence boundary


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Generated pages, catalogs, test ledgers, and release manifests can reveal drift, but they cannot safely supply missing architecture meaning. A clear authority boundary is required so reviewers know where a rule must be authored and how disagreement among projections is resolved.

生成页面、目录、测试账本和发布清单能够揭示漂移，却不能安全地补足缺失的架构含义。必须明确权威边界，让审查者知道规则应在哪里编写，以及不同投影出现冲突时如何处理。

### Detailed decision / 详细决策

The four-surface PTO ASL tree is the sole authored architecture source. Every architectural fact has one ASL owner. Catalogs, generated documentation, AVS, evidence, and release artifacts are derived checks; disagreement means a projection is stale or defective rather than authoritative.

PTO 的四表面 ASL 树是唯一手写架构来源，每项架构事实只有一个 ASL owner。目录、生成文档、AVS、证据和发布制品都是派生检查；出现不一致表示投影陈旧或有缺陷，而不是投影拥有权威。

### What changed / 改动内容

#### English

- Established one authored owner for every architectural fact.
- Classified catalogs, generated documentation, AVS, evidence ledgers, and manifests as projections or checks.
- Required unresolved ASL gaps to remain explicit until the owning unit is updated.

#### 中文

- 为每项架构事实确立唯一的手写 owner。
- 将目录、生成文档、AVS、证据账本和清单归类为投影或检查。
- 要求未解决的 ASL 缺口保持显式，直至更新对应 owner 单元。

### Scope and boundaries / 范围与边界

This governance decision centers on `PTO-SOURCE-HIERARCHY` and the architecture overview. It does not itself define instruction behavior, and formal review records remain limited to method, outcome, and covered subjects.

本治理决策围绕 `PTO-SOURCE-HIERARCHY` 和架构概览。它本身不定义指令行为；形式化审查记录仍仅限于方法、结论和所覆盖主题。
## Context

Architecture meaning must not be reconstructed from generated artifacts,
tool behavior, maturity ledgers, or documentation prose. Those artifacts can
detect drift, but they cannot fill an absent ASL rule.

## Decision

- The four-surface PTO ASL tree is the only authored architecture source.
- Every accepted instruction, rejected form, field domain, default, state
  effect, memory effect, ordering rule, fault, and reservation has one ASL
  owner.
- Catalogs, generated pages, navigation, AVS points, evidence ledgers, and
  release manifests are derived artifacts or checks.
- A derived artifact that disagrees with ASL is stale or defective and must
  fail closed. It never changes the architecture definition.
- An ASL gap remains incomplete or ambiguous until a PTO architecture decision
  resolves it and updates the owning ASL unit first.
- Formal review records contain only review method, outcome, and covered formal
  subjects. They contain no repository, path, page, branch, commit, or blob
  provenance.

## Consequences

PTO release closure proves that the projections agree with the authored ASL;
it does not promote any projection into a second source. Architecture review
therefore remains mnemonic-local, reproducible from this repository, and
independent of the availability or behavior of another implementation.
