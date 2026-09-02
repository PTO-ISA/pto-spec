---
{
  "id": "ADR-BLOCK-0001",
  "title": "Define the PTO predicate-register contract",
  "title_zh": "定义 PTO 谓词寄存器契约",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": "2026-08-11",
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
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
    "ADR-BLOCK-0014"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0019"
  ]
}
---
# ADR-BLOCK-0001: Define the PTO predicate-register contract

## Historical context

This decision identified that every visible predicate needs explicit reset,
preservation, producer, and consumer rules. The current PTO contract retains
only P0 through P7: P0 is hardwired all ones, P1 through P7 are independently
trap-preserved, and no accepted instruction consumes them. Machine-block
encodings and their former execution-mask model are outside PTO.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Every architecturally visible predicate needs an explicit identity, reset value, trap-preservation rule, producer, and consumer. Without that contract, software and implementations could disagree about whether predicate state exists or affects execution.

每个架构可见谓词都需要明确的身份、复位值、陷阱保留规则、生产者和消费者。缺少这些约束时，软件与实现会对谓词状态是否存在、是否影响执行产生不同理解。

### Detailed decision / 详细决策

This historical record established that predicate state must be closed explicitly. Its surviving boundary is P0 through P7: P0 reads as all ones, P1 through P7 are independently trap-preserved, and no accepted instruction consumes them. Machine-block execution masks are outside PTO.

本历史记录确立了谓词状态必须显式闭合。其保留边界是 P0 至 P7：P0 读为全一，P1 至 P7 分别在陷阱中保留，且当前没有已接受指令消费它们。机器 Block 执行掩码不属于 PTO。

### What changed / 改动内容

#### English

- Made predicate reset, preservation, producer, and consumer obligations explicit.
- Removed machine-block execution-mask semantics from the PTO boundary.

#### 中文

- 明确了谓词复位、保留、生产者和消费者的闭合义务。
- 将机器 Block 执行掩码语义移出 PTO 边界。

### Scope and boundaries / 范围与边界

This superseded ADR explains the historical requirement only. Current behavior is owned by the affected predicate-register and encoding-ownership units and by ADR-BLOCK-0014; this record does not introduce a predicate consumer.

本 ADR 已被废止，仅解释历史要求。现行行为由受影响的谓词寄存器、编码归属单元及 ADR-BLOCK-0014 定义；本记录不新增谓词消费者。
