---
{
  "id": "ADR-BLOCK-0002",
  "title": "Separate execution-mask and predicate domains (superseded)",
  "title_zh": "分离执行掩码与谓词域（已废止）",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": "2026-08-11",
  "baseline": "2f3f605e289b09d56ef5a9ba39fc80b52948a5f5",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [
    "ADR-BLOCK-0014",
    "ADR-BLOCK-0010"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0046"
  ]
}
---
# ADR-BLOCK-0002: Separate execution-mask and predicate domains (superseded)

> The historical `B.Z`/`B.NZ` consumer clause is also superseded by ADR 0067.
> PTO has no accepted conditional-branch consumer for the machine execution
> mask.

- Decision date: 2026-07-31

## Superseding decision

The earlier decision modeled a separate execution mask for machine-parallel
and machine-sequential block bodies. PTO no longer accepts those block-start
families and reserves their complete encoding space. PTO therefore has no
machine-body execution-mask state, entry behavior, trap payload, or branch
selection rule.

P0 through P7 remain distinct 32-bit predicate registers. P0 reads all ones
and ignores writes; P1 through P7 reset to zero and are trap-preserved. No
accepted PTO instruction produces or consumes them. `B.Z` and `B.NZ` consume
the bundle commit argument established by `SETC.*`.

This file records the superseded decision only. The current executable
contract is defined by the ASL architecture and scalar BRU units.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The earlier model conflated machine-body execution selection with architectural predicate registers. Separating the domains was necessary to state reset, trap, and branch behavior independently and to prevent an implementation detail from becoming portable PTO state.

早期模型混合了机器 Body 的执行选择与架构谓词寄存器。分离两者才能分别定义复位、陷阱和分支行为，并避免将实现细节提升为可移植 PTO 状态。

### Detailed decision / 详细决策

The historical decision distinguished a machine execution mask from P0 through P7. The superseding architecture later reserved the machine-parallel and machine-sequential encodings, so the execution-mask domain, its entry rules, and its trap payload are no longer PTO semantics. P0 through P7 remain independent state, while `B.Z` and `B.NZ` use the `SETC.*` commit argument.

历史决策曾区分机器执行掩码与 P0 至 P7。后续架构保留了机器并行和机器顺序编码，因此执行掩码域及其进入规则、陷阱载荷不再是 PTO 语义。P0 至 P7 仍是独立状态，而 `B.Z`、`B.NZ` 使用 `SETC.*` 建立的提交参数。

### What changed / 改动内容

#### English

- Recorded the former separation between execution-mask and predicate domains.
- Superseding decisions removed the machine-mask state and redirected conditional commit selection to BARG.

#### 中文

- 记录了原先执行掩码域与谓词域的分离。
- 后续决策删除机器掩码状态，并将条件提交选择转向 BARG。

### Scope and boundaries / 范围与边界

This ADR is historical and must not be read as authorizing machine-body execution masks. Current encoding reservations and branch behavior are defined by ADR-BLOCK-0010 and ADR-BLOCK-0014.

本 ADR 仅为历史记录，不得解释为授权机器 Body 执行掩码。现行编码保留与分支行为由 ADR-BLOCK-0010 和 ADR-BLOCK-0014 定义。
