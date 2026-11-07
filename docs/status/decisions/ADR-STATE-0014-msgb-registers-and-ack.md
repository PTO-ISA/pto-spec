---
{
  "id": "ADR-STATE-0014",
  "title": "Opt-in MSGB registers, BSE admission and exact SSRSET ACK",
  "title_zh": "显式启用的 MSGB 寄存器、BSE 接纳与精确 SSRSET ACK",
  "status": "accepted",
  "authors": [
    "zhoubot"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-11-07",
  "accepted": "2026-11-07",
  "rejected": null,
  "superseded": null,
  "baseline": "42067d0f2890b8c013a868bd1247ebc6437b3179",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-MSGB-IDENTITY-001",
    "PTO-ARCH-MSGB-STATE-001",
    "PTO-ARCH-MSGB-SSR-001",
    "PTO-ARCH-MSGB-ACK-001",
    "PTO-ARCH-MSGB-SEND-001",
    "PTO-ARCH-MSGB-LIFECYCLE-001",
    "PTO-BSE-DECISION-BINDING-001",
    "PTO-ARCH-MSGB-REGISTER-FIELDS-001"
  ],
  "affected_units": [
    "PTO-ARCH-STATE-MESSAGE-BUFFER-STATE",
    "PTO-ARCH-STATE-MESSAGE-BUFFER",
    "PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS",
    "PTO-SCALAR-MODEL-SYS-REGISTERS",
    "PTO-SCALAR-MODEL-DISPATCH-SYS",
    "PTO-ARCH-STATE-KERNEL-LIFECYCLE",
    "PTO-SCALAR-BSE"
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
# ADR-STATE-0014: MSGB register and ACK interface

## Summary

The repository owner requested normative implementation of the message protocol and explicitly selected current-kernel-ACR operations with ACR0-only configuration, SSRSET data staging followed by BSE admission, and SSRSET exact-token ACK. Issue #425 records the immutable baseline and scope. This decision accepts that implementation direction; its acceptance is not a PR review receipt or a release authorization.

## Context and alternatives

ADR-STATE-0013 owns the existing nonblocking execution-control boundary and explicitly leaves mailbox state to a separate contract. Replacing every legacy BSE would silently change existing clients. This new state interface therefore has explicit enablement and disabled reset defaults; BWE/BWI/BWT remain under their existing owner.

Stable message identity alone cannot safely identify an ACK after a claim is cancelled and reacquired. The selected protocol retains a stable transport identity and allocates a fresh receive token for every claim. Implicit read-to-pop and unqualified clear-current-head alternatives were rejected because partial reads, concurrent contexts and delayed acknowledgements could consume the wrong message.

## Decision and owning sources

Current meaning is defined by the NDF clauses in the message-buffer state/operation units, the system-register catalog owner, and BSE/SSR dispatch. The register family is explicitly enabled per execution context. Configuration is privileged and quiescence checked; ordinary mailbox access belongs to the current kernel ACR. BSE selects an endpoint and valid word count without encoding a service opcode. ACK consumes an exact read-complete snapshot, with independent status and last-success records.

Committed messaging state is separate from PE/trap snapshots. Side effects cannot bypass atomic/far Block semantics or older fault-capable GM obligations. End/abort requests freeze new message admission while allowing existing snapshots to drain; a pending mailbox prevents destructive lifecycle retirement. The bounded model maps endpoint identities to its modeled contexts and delivers messages atomically without specifying physical HSCB timing or queue topology.

## Defaults, compatibility and release impact

Disabled contexts preserve legacy BSE behavior. Enabling the profile opts into new register, control-word, permission, precision and lifecycle rules. New SSR addresses previously rejected as unknown become assigned; compatibility is additive for clients that never opt in, and profile-dependent for enabled clients. Configuration/domain binding and incarnation changes are explicit and cannot silently reset counters. Publication requires full exact-commit evidence; this development PR only supplies focused evidence.

## Implementation and verification obligations

Implement ASL state and instruction paths, catalog access classes, fault-before-destination behavior, claim-specific identities, ACK replay, no-wrap counters, lifecycle admission closure, and precise access/state failures. Add independent direct ASL and encoded instruction tests, regenerate catalog/decoder/mirror/NDF projections, and preserve the required PR handoff. Downstream compiler/runtime and ASL-Model adoption are separate obligations referenced by repository URL.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** The previous scheduling-request profile cannot express payload staging, receive ownership or safe acknowledgement. An explicit interface is required before software can depend on these effects.

**中文。** 原有调度请求接口没有载荷暂存、接收所有权和安全确认语义。本次按用户明确要求建立可执行的寄存器接口，避免把提案或历史文档当成已经实现的行为。

### Detailed decision / 详细决策

**English.** Keep legacy behavior when disabled; bind enabled operations to the current kernel context, privileged configuration and exact message/snapshot identities. Preserve committed effects across recovery and stop new admission during lifecycle drain.

**中文。** 未启用时保持原行为；启用后按当前 kernel 执行上下文隔离，配置由 ACR0 管理。消息身份与读取快照身份分别维护，恢复不回滚已提交消息，生命周期排空时关闭新接纳。

### What changed / 改动内容

#### English

- Introduce the MSGB architectural state and assigned system-register family.
- Extend BSE under explicit enablement and connect SSR reads/writes to real state transitions.
- Add focused independent tests and downstream integration obligations.

#### 中文

- 新增 MSGB 架构状态及系统寄存器族。
- 在显式启用下扩展 BSE，并将 SSR 读写连接到真实状态转换。
- 增加独立验证点，明确下游集成责任。

### Scope and boundaries / 范围与边界

**English.** No instruction encoding changes or implicit nested execution bodies are introduced. Physical transport timing, full synchronization services, device execution and release readiness are outside this decision's completion claim.

**中文。** 不改变指令编码，不引入嵌套指令体。物理互连时序、完整同步服务、设备执行和发布就绪不由本次局部实现证明。
