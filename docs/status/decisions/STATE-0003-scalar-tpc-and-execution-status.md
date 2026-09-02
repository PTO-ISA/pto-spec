---
{
  "id": "ADR-STATE-0003",
  "title": "scalar TPC and execution status",
  "title_zh": "标量 TPC 与执行状态",
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
    "PTO-BARG-CONTINUATION-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-REQ-BUNDLE-STATE-001",
    "PTO-REQ-STATE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-STATE-PROGRAM-COUNTER",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-L-BSTOP",
    "PTO-BLOCK-MODEL-STATE-BARG",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0009"
  ]
}
---
# ADR-STATE-0003: scalar TPC and execution status

## Context

The scalar decoder previously invoked instruction semantics without advancing
TPC for ordinary instructions. It also returned `ScalarExecution_Executed`
after a semantic handler raised an architectural fault, while bundle and tile
dispatch returned a rejected status for the same condition. Those behaviors
made sequential execution and the public status contract ambiguous.

## Decision

- TPC contains the address of the scalar instruction being dispatched.
- A non-control scalar instruction that completes without a fault advances TPC
  by its encoded length in bytes.
- Relative branches and jumps, indirect jumps, and ACRE own the next-TPC write;
  the common dispatch path does not add a second sequential advance.
- Any architectural fault raised during scalar execution returns
  `ScalarExecution_Rejected` after the trap transition.
- `ScalarExecution_Executed` means the instruction completed without an
  architectural fault.
- An illegal scalar register selector raises `Fault_IllegalInstruction`; it is
  not a tile-legality fault.

## Consequences

Decoded tests must check both instruction effects and TPC movement. Fault tests
must expect a rejected status and verify trap state, fault address, and absence
of partial instruction effects. A handler that starts writing TPC must be added
to the explicit next-TPC ownership predicate before it can be accepted.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The scalar decoder previously failed to advance TPC for ordinary instructions and could report success after a semantic fault. That made sequential execution inconsistent with bundle and Tile dispatch and left the public status result ambiguous.

标量解码器此前不会为普通指令推进 TPC，并可能在语义故障后仍报告成功。这使顺序执行与 Bundle、Tile 分派不一致，也让公开执行状态含义模糊。

### Detailed decision / 详细决策

TPC is the address of the instruction being dispatched. Successful non-control instructions advance by encoded length; control-transfer and ACRE handlers own their next-TPC write. Any architectural fault returns `Rejected` after trap transition, while `Executed` means completion without fault. Illegal scalar selectors raise illegal-instruction faults.

TPC 表示当前被分派指令的地址。成功的非控制指令按编码长度推进；控制转移和 ACRE handler 自己拥有 next-TPC 写入。任何架构故障在陷阱转换后返回 `Rejected`；`Executed` 仅表示无故障完成。非法标量选择器产生 illegal-instruction 故障。

### What changed / 改动内容

#### English

- Added ordinary sequential TPC advancement at the common dispatch boundary.
- Separated handler-owned next-TPC writes from common advancement.
- Aligned scalar success/rejection status with architectural fault outcomes.

#### 中文

- 在公共分派边界增加普通顺序 TPC 推进。
- 区分 handler 自有的 next-TPC 写入与公共推进。
- 使标量成功/拒绝状态与架构故障结果一致。

### Scope and boundaries / 范围与边界

This record defines scalar dispatch TPC and status behavior. Each handler that writes TPC must be explicitly registered; instruction-specific rollback and trap details stay with their owners.

本记录定义标量分派的 TPC 和状态行为。每个写 TPC 的 handler 必须显式登记；指令特定回滚和陷阱细节仍归相应 owner 所有。
