---
{
  "id": "ADR-STATE-0015",
  "title": "High Speed Config Bus delivery and Message Buffer worker dispatch",
  "title_zh": "High Speed Config Bus 投递与 Message Buffer 工作线程调度",
  "status": "draft",
  "authors": ["zhoubot"],
  "approvers": [],
  "created": "2026-11-11",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "42067d0f2890b8c013a868bd1247ebc6437b3179",
  "target_releases": ["unassigned"],
  "affected_ndf": [
    "PTO-ARCH-HSCB-ENDPOINT-001",
    "PTO-ARCH-HSCB-TRANSPORT-001",
    "PTO-ARCH-HSCB-DISPATCH-001"
  ],
  "affected_units": [
    "PTO-ARCH-STATE-MESSAGE-BUFFER-STATE",
    "PTO-ARCH-STATE-MESSAGE-BUFFER-SEND",
    "PTO-ARCH-STATE-HSCB-DISPATCH"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/425",
  "release_impact": "required",
  "release_boundary": false,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---
# ADR-STATE-0015: High Speed Config Bus and Message Buffer dispatch

## Summary

The High Speed Config Bus (HSCB) carries control messages between the scheduler
and execution contexts. A Message Buffer (MSGB) is the endpoint state through
which a context stages a send or claims a stable incoming message. ADR-STATE-0014
owns the register interface and the exact-token acknowledgement. This decision
proposes the delivery contract and the resident-worker protocol that uses it.

## Decision and rationale

In the four-PE reference core each PE has two independently scheduled hardware
threads. Each thread needs its own mailbox state even when both run at ACR0.
Otherwise one sibling could acknowledge the other's message, or consume its
kernel PC. The reference numbering groups the four PEs of one thread slot
together; slot zero on core zero retains its earlier endpoint numbers.
A distinct scheduler endpoint allows a worker to authenticate a dispatch
using the transport source identity.

After initialization each worker sends READY. The scheduler submits LAUNCH with
a dispatch ID, entry PC and argument; DONE returns the same ID and the kernel's
return value. Receipt of a message and completion of a job are different
events. A successful mailbox ACK makes queue space available before the kernel
returns. The scheduler associates completion with the sending worker and its
outstanding ID. The worker can then wait for a subsequent dispatch.

## Defaults, compatibility and evidence

The MSGB profile resets disabled. Enabled workers use BWE's existing WaitEvent
handoff and recheck their inbox. The three message tags use payload words and
require no new opcode. The reference mapping allocates 128 ACR-qualified
addresses per core. A consumer of the earlier multi-core draft that hard-coded
a 64-address stride must update. Bus pins, arbitration policy, service latency
and ordering of unrelated GM accesses remain platform decisions.

The ASL owners listed above define the executable rules. Review requires
evidence for sibling isolation, delivery and backpressure, dispatch identity,
and a second dispatch after completion. The decision has no release assignment.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Two threads on a PE may simultaneously have pending work. A PE
number alone cannot identify the owner of a configuration command or its reply.

**中文。** 同一 PE 的两个硬件线程可同时持有待办任务。单独使用 PE 编号无法确定哪条线程应当接收命令、领取快照或返回完成消息。

### Detailed decision / 详细决策

**English.** HSCB delivers control traffic through endpoint Message Buffers.
A successful send captures a bounded payload and identifies its source.
The scheduler tracks READY, LAUNCH and DONE per worker and invocation.

**中文。** HSCB（High Speed Config Bus，高速配置总线）承载调度控制消息。MSGB 是端点上的收发状态，发送成功时固定载荷并赋予来源身份。调度器按工作线程和调用跟踪就绪、任务下发及完成回报。

### What changed / 改动内容

#### English

- Give the four-PE reference model two independently addressable worker slots per PE.
- Route messages to the scheduler through the same admission and acknowledgement protocol as messages to workers.
- Define the payloads for READY, LAUNCH and DONE, the correlation of completions and the wait boundary.

#### 中文

- 四个物理 PE 各有两个可独立寻址的工作线程，同级线程分别持有暂存、队列、快照和确认状态。
- 调度服务端点使用同一套消息接纳和确认协议，运行时可根据传输身份识别来源。
- READY 报告启动就绪，LAUNCH 携带调度 ID、kernel PC 和参数，DONE 回传 ID 和返回值。完成后，工作线程可等待下一次调度。

### Scope and boundaries / 范围与边界

**English.** The contract specifies observable delivery, ownership and service
state. Implementations choose the bus width, physical routing, buffering and
timing consistent with those observations. Dispatch completion alone gives no
additional visibility guarantee for unrelated memory operations.

**中文。** 本决策规定可观察的投递结果、邮箱归属和调度状态。实现自行确定总线宽度、物理连线、缓冲容量及耗时。与任务无关的内存访问仍遵循其原有可见性规则。
