---
{
  "id": "ADR-STATE-0006",
  "title": "Define PTO v0 ACRC service requests",
  "title_zh": "定义 PTO v0 ACRC 服务请求",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ACRC-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-SCALAR-ACRC"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0012"
  ]
}
---
# ADR-STATE-0006: Define PTO v0 ACRC service requests

## Context

`ACRC` has an accepted 32-bit encoding and the trap catalog assigns `SCALL`
(6), but the previous semantic handler only incremented a diagnostic epoch. It
did not validate the request, save a return snapshot, route to a manager, or
take the architectural trap. Bundle-control faults incorrectly occupied the
same trap number before ADR 0010 corrected their identity.

## Decision

`ACRC request_type` takes a synchronous trap immediately after the instruction:

- ACR1 accepts machine request 0 and security request 2; both route to ACR0.
- ACR2 through ACR15 accept machine request 0, system request 1, and security
  request 2. System request 1 routes to ACR1; the others route to ACR0.
- ACR0 and all other request values are illegal and raise `ILLEGAL_INST` (4).
- A valid request reports `SCALL` (6), records the four-bit request in the low
  `CAUSE` bits, and records the ACRC instruction TPC in `TRAPARG0`.
- Because ACRC is a 32-bit instruction, `EBARG_TPC` records the following
  instruction at source TPC + 4. Recovery therefore advances past ACRC unless
  manager software deliberately rewrites the visible resume word.
- A valid ACRC returns the internal scalar execution status `Rejected` because
  control transferred through a synchronous trap; no sequential dispatch
  update occurs after the trap handler vector is installed.

The ACR2 rule from the reconciled public contract is extended uniformly to the
PTO v0 managed-ring range ACR2 through ACR15, consistent with ADR 0010.

## Consequences

The SCALL trap identity now has an architectural producer. Request legality,
routing, cause, argument, return snapshot, and recovery position are directly
testable. The broader bundle rule requiring ACRC placement next to a terminator
remains a bundle-formation closure target rather than an instruction-local
effect.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

ACRC had an encoding and a reserved SCALL trap identity, but its handler only updated a diagnostic counter. It lacked request validation, manager routing, return snapshot, cause/argument reporting, and actual trap entry.

ACRC 已有编码和预留的 SCALL 陷阱身份，但 handler 只更新诊断计数器。它缺少请求验证、manager 路由、返回快照、cause/argument 报告和实际陷阱进入。

### Detailed decision / 详细决策

ACRC validates request type against the source ACR, routes valid requests to ACR0 or ACR1, raises `ILLEGAL_INST` for invalid combinations, and reports `SCALL` with request cause and source TPC. The saved resume TPC is source TPC + 4, and valid service transfer returns internal `Rejected` because synchronous trap control replaces sequential dispatch.

ACRC 根据源 ACR 验证请求类型，把合法请求路由到 ACR0 或 ACR1，对非法组合产生 `ILLEGAL_INST`，并以请求 cause 和源 TPC 报告 `SCALL`。保存的恢复 TPC 为源 TPC + 4；合法服务转移返回内部 `Rejected`，因为同步陷阱控制取代顺序分派。

### What changed / 改动内容

#### English

- Turned SCALL from a catalog identity into an executable ACRC producer.
- Defined request legality, manager routing, cause, argument, and resume position.
- Separated instruction-local service semantics from bundle-placement legality.

#### 中文

- 把 SCALL 从目录身份变为可执行的 ACRC producer。
- 定义请求合法性、manager 路由、cause、argument 和恢复位置。
- 区分指令局部服务语义与 Bundle 放置合法性。

### Scope and boundaries / 范围与边界

The decision covers ACRC execution only. The rule requiring ACRC placement next to a bundle terminator remains a separate bundle-formation obligation.

本决策只覆盖 ACRC 执行。要求 ACRC 紧邻 Bundle terminator 的规则仍属于独立的 Bundle formation 义务。
