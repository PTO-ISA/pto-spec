---
{
  "id": "ADR-STATE-0008",
  "title": "Classify every visible system register behavior",
  "title_zh": "对所有可见系统寄存器行为分类",
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
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-RELEASE-VERIFICATION",
    "PTO-SOURCE-HIERARCHY",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
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
    "ADR-0017"
  ]
}
---
# ADR-STATE-0008: Classify every visible system register behavior

## Context

The system-register catalog already fixed 72 identities, addresses, and access
classes, but those fields did not state reset values, read behavior, write
behavior, side effects, or whether a register was active in `pto-v0`. That made
generic backing storage indistinguishable from an implemented architectural
effect and prevented a defensible Stage 2 closure claim.

The PTO v0 memory profile uses identity translation. Its debug matcher is not
implemented. The corresponding visible registers still need deterministic
access and reset behavior without implying that stored values affect address
translation or instruction/data matching.

## Decision

- `spec/catalog/system-registers.json` assigns every one of the 72 register
  definitions to exactly one behavior class. A class defines reset, read,
  write, side effects, and profile status.
- The catalog checker rejects missing, duplicate, unknown, access-inconsistent,
  or malformed classifications.
- `spec/catalog/system-registers.json`, the mirrored system-register ASL units,
  and their independent tests own reset, access, and side-effect behavior for
  all 25 classes. `spec/evidence/release-traceability-readiness.json` derives
  the current ASL-to-test ownership without retaining a second behavioral
  ledger.
- Generated executable witnesses check reset for every visible base address,
  every bank of each ACR-family register, and every fixed-context register.
  They also prove read-only rejection and preservation, write-only rejection,
  and read/write round trips.
- `TIME`, `CYCLE`, and `TIMER_TIME` expose the architectural execution-attempt
  counter. `VERSION` resets to one, `TILE_CAPACITY` resets to the profile model
  limit, and `ECONFIG` resets with external and timer collection enabled. All
  other visible storage resets to zero unless a later profile decision changes
  its declared class.
- Translation configuration registers are readable and writable storage in
  `pto-v0`, but identity translation does not consume their values.
- `XBINFO` and `ACR_PARAM` are readable and writable storage in `pto-v0`; no
  current profile operation consumes their values.
- Debug identity, breakpoint, comparator, and watchpoint registers are visible
  storage in `pto-v0`, but debug matching is disabled. Consequently, storing a
  value does not itself produce a hardware breakpoint or watchpoint trap.
- Storage-only is an explicit profile behavior, not shorthand for an omitted
  definition. A future active translation or debug profile needs a distinct
  profile identity, defined field layouts and effects, and executable
  conformance evidence.
- The generated consumer-exclusion guard expands all 423 fixed and banked
  canonical addresses for the 33 storage-only definitions and content-addresses
  every normative function that can reach the extended backing store or a
  generic/context address API. A new literal address, computed index, symbolic
  helper call, or direct backing-store access fails closed. Negative canaries
  prove full-bank and symbolic additions are rejected; generic architectural
  reads and writes still do not consume the stored value.

The catalog is normative PTO material. Comparison implementations remain
evidence only and cannot silently activate a storage-only class.

## Consequences

The generated system-register reference now displays reset, read, write, and
profile status for every register. Stage target `S2-T1` is mechanically and
behaviorally closed for `pto-v0`; trap-producer closure remains a separate
`S2-T3` obligation. In particular, the storage-only debug decision does not by
itself define producers for hardware breakpoint or watchpoint trap identities.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Register identities, addresses, and access classes did not state reset, read, write, side effects, or active behavior. Generic backing storage could therefore be mistaken for an implemented architectural function.

寄存器身份、地址和访问类别没有说明复位、读取、写入、副作用或活动行为。因此，通用 backing storage 可能被误认为已经实现的架构功能。

### Detailed decision / 详细决策

Every visible register is assigned exactly one checked behavior class that defines reset, access, side effects, and profile status. Generated witnesses cover all banks and access classes. Time registers expose the attempt counter; translation, debug, and selected parameter registers can be storage-only without implying active translation or matching.

每个可见寄存器都被分配唯一且受检查的行为类别，定义复位、访问、副作用和 Profile 状态。生成见证覆盖所有 bank 和访问类别。时间寄存器暴露指令尝试计数器；地址转换、debug 和部分参数寄存器可以仅提供存储，而不暗示已启用转换或匹配。

### What changed / 改动内容

#### English

- Added total behavior classification for all 72 register definitions.
- Generated reset and access witnesses across fixed and banked addresses.
- Made storage-only behavior explicit for inactive translation and debug functions.

#### 中文

- 为全部 72 个寄存器定义增加全域行为分类。
- 为固定地址和 banked 地址生成复位与访问见证。
- 显式定义未启用地址转换和 debug 功能的 storage-only 行为。

### Scope and boundaries / 范围与边界

Storage-only does not define an MMU, debug matcher, breakpoint, or watchpoint producer. Trap-producer closure remains separate from register-behavior closure.

storage-only 不定义 MMU、debug matcher、breakpoint 或 watchpoint producer。陷阱 producer 闭合与寄存器行为闭合仍是不同任务。
