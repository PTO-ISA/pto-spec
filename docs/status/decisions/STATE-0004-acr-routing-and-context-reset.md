---
{
  "id": "ADR-STATE-0004",
  "title": "PTO v0 ACR routing and context reset",
  "title_zh": "PTO v0 ACR 路由与上下文复位",
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
    "PTO-REQ-STATE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-RESET",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-ARCH-SYSTEM-REGISTERS-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT",
    "PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE",
    "PTO-ARCH-SYSTEM-REGISTERS-TIMER"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0010"
  ]
}
---
# ADR-STATE-0004: PTO v0 ACR routing and context reset

## Context

PTO exposes ACR0 through ACR15, banked context-family system registers, and a
shared trap envelope. The earlier reference profile routed an ACR1 fault to
ACR0, routed only ACR2 to ACR1, left ACR3 through ACR15 implicit, and reset only
the ACR0 extended-register bank. It also assigned the system-call trap number
to bundle-control faults even though the catalog defines separate bundle-trap
and system-call identities.

## Decision

- ACR0 is the root manager, ACR1 is the system manager, and ACR2 through ACR15
  are managed rings in the PTO v0 profile.
- A synchronous fault or interrupt sourced in ACR0 targets ACR0.
- A synchronous fault or interrupt sourced in ACR1 targets ACR1.
- A synchronous fault or interrupt sourced in ACR2 through ACR15 targets ACR1.
- Reset clears the complete catalog-defined context-family low-index range in
  all 16 ACR banks.
- Reset also clears every live GPR, T/U queue, P1 through P7, the bundle
  descriptor, tile descriptor and definedness bit, reservation, memory/event,
  fault, trap, and saved-context field. P0 is
  hardwired all-ones. Profile constants are then installed explicitly.
- Bundle-format and bundle-control faults report `BUNDLE_TRAP` (5).
- `SCALL` (6) remains reserved for the separately specified `ACRC` service-
  request transition and is not used as a bundle-control surrogate.

ADRs 0011, 0012, 0018, and 0019 define the visible trap snapshot, `ACRC`
request routing, `ACRE` restoration, trap disposition, and predicate
preservation that complete this reset envelope.

## Consequences

The routing function is total over all 16 ACRs. Reset cannot leak architectural
state between executions through a nonzero ACR bank, high register index,
predicate, tile, bundle descriptor, reservation, or saved context. Nonzero-seed
tests cover the lowest and highest boundaries and every trap bank.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Earlier routing covered only part of ACR0..ACR15, reset only one extended bank, and reused the system-call trap number for bundle faults. That left manager routing partial, allowed state leakage between executions, and conflated distinct trap identities.

早期路由只覆盖 ACR0..ACR15 的一部分，复位也只清除一个扩展 bank，并把 system-call 陷阱号用于 Bundle 故障。这会造成 manager 路由不完整、执行之间状态泄漏，并混淆不同陷阱身份。

### Detailed decision / 详细决策

ACR0 is root, ACR1 is system manager, and ACR2..ACR15 route synchronous faults and interrupts to ACR1. Reset clears all catalog-defined context banks and all listed live scalar, predicate, bundle, Tile, reservation, memory/event, fault, trap, and saved-context state before installing constants. Bundle faults use `BUNDLE_TRAP`; `SCALL` remains for ACRC.

ACR0 是 root，ACR1 是 system manager，ACR2..ACR15 的同步故障和中断路由到 ACR1。复位先清除所有目录定义的上下文 bank，以及所列的标量、谓词、Bundle、Tile、保留、内存/事件、故障、陷阱和保存上下文状态，再安装常量。Bundle 故障使用 `BUNDLE_TRAP`；`SCALL` 保留给 ACRC。

### What changed / 改动内容

#### English

- Made routing total across all 16 ACRs.
- Expanded reset to every visible and saved state class named by the decision.
- Separated bundle-control faults from the ACRC service-call trap identity.

#### 中文

- 使路由完整覆盖全部 16 个 ACR。
- 将复位扩展到决策中列出的所有可见与保存状态类别。
- 区分 Bundle 控制故障与 ACRC 服务调用陷阱身份。

### Scope and boundaries / 范围与边界

This record defines routing and reset envelopes. Visible snapshot encoding, ACRC requests, ACRE recovery, trap disposition, and predicate preservation remain owned by their linked decisions.

本记录定义路由与复位包络。可见快照编码、ACRC 请求、ACRE 恢复、陷阱处置和谓词保存仍由所链接的决策所有。
