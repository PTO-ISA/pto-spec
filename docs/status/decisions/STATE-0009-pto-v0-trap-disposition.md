---
{
  "id": "ADR-STATE-0009",
  "title": "Define the PTO v0 disposition of every trap identity",
  "title_zh": "定义每个陷阱标识在 PTO v0 中的处置",
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
    "PTO-ACRC-DECISION-BINDING-001",
    "PTO-ACRE-IMPLICIT-STOP-001",
    "PTO-BSE-DECISION-BINDING-001",
    "PTO-BWE-DECISION-BINDING-001",
    "PTO-BWI-DECISION-BINDING-001",
    "PTO-BWT-DECISION-BINDING-001",
    "PTO-C-EBREAK-CAUSE-001",
    "PTO-C-SSRGET-DIRECT-IDS-001",
    "PTO-EBREAK-DECISION-BINDING-001",
    "PTO-FENCE-D-DECISION-BINDING-001",
    "PTO-FENCE-I-DECISION-BINDING-001",
    "PTO-HL-SSRGET-DECISION-BINDING-001",
    "PTO-HL-SSRSET-DECISION-BINDING-001",
    "PTO-LSRGET-BARG-001",
    "PTO-SETC-TGT-ADR-CONTRACT-001",
    "PTO-SSRGET-ADR-CONTRACT-001",
    "PTO-SSRSET-ADR-CONTRACT-001",
    "PTO-SSRSWAP-ADR-CONTRACT-001",
    "PTO-TLB-IA-ADR-CONTRACT-001",
    "PTO-TLB-IALL-ADR-CONTRACT-001",
    "PTO-TLB-IAV-ADR-CONTRACT-001",
    "PTO-TLB-IV-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FAULT",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-SCALAR-ACRC",
    "PTO-SCALAR-ACRE",
    "PTO-SCALAR-ASSERT",
    "PTO-SCALAR-BC-IALL",
    "PTO-SCALAR-BC-IVA",
    "PTO-SCALAR-BSE",
    "PTO-SCALAR-BWE",
    "PTO-SCALAR-BWI",
    "PTO-SCALAR-BWT",
    "PTO-SCALAR-C-EBREAK",
    "PTO-SCALAR-C-SSRGET",
    "PTO-SCALAR-DC-CISW",
    "PTO-SCALAR-DC-CIVA",
    "PTO-SCALAR-DC-CSW",
    "PTO-SCALAR-DC-CVA",
    "PTO-SCALAR-DC-IALL",
    "PTO-SCALAR-DC-ISW",
    "PTO-SCALAR-DC-IVA",
    "PTO-SCALAR-DC-ZVA",
    "PTO-SCALAR-EBREAK",
    "PTO-SCALAR-FENCE-D",
    "PTO-SCALAR-FENCE-I",
    "PTO-SCALAR-HL-SSRGET",
    "PTO-SCALAR-HL-SSRSET",
    "PTO-SCALAR-IC-IALL",
    "PTO-SCALAR-IC-IVA",
    "PTO-SCALAR-LSRGET",
    "PTO-SCALAR-SETC-TGT",
    "PTO-SCALAR-SSRGET",
    "PTO-SCALAR-SSRSET",
    "PTO-SCALAR-SSRSWAP",
    "PTO-SCALAR-TLB-IA",
    "PTO-SCALAR-TLB-IALL",
    "PTO-SCALAR-TLB-IAV",
    "PTO-SCALAR-TLB-IV"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0018"
  ]
}
---
# ADR-STATE-0009: Define the PTO v0 disposition of every trap identity

## Context

The canonical catalog assigns 13 trap numbers, but mnemonic presence did not
prove a production trigger or a complete entry and restart contract. The
initial review identified four identities without justified PTO v0 triggers:
execution-state check, instruction page fault, hardware breakpoint, and
hardware watchpoint. Execution-state check now has a defined recovery trigger;
the other three remain envelope-only. Assigning them to convenient instructions
or inventing debug and translation field layouts would import behavior that PTO
has not defined.

Trap number zero also cannot use a zero number alone to indicate “no trap.” The
visible argument-valid state distinguishes an execution-state-check entry from
an empty trap bank.

## Decision

- Every catalog row defines its PTO v0 status, producer envelope, cause,
  argument, and restart class.
- `EXEC_STATE_CHECK`, `ILLEGAL_INST`, `BUNDLE_TRAP`, `SCALL`, `INST_PC_FAULT`,
  `DATA_ALIGN_FAULT`, `DATA_PAGE_FAULT`, `INTERRUPT`, `SW_BREAKPOINT`, and
  `ASSERT_FAIL` are production-active in PTO v0.
- `INST_PAGE_FAULT`, `HW_BREAKPOINT`, and `HW_WATCHPOINT` have complete
  synchronous `SetFault` envelopes but no PTO v0
  production trigger. They remain visible identities for a future profile.
- An unsupported ACRE request-type encoding produces `ILLEGAL_INST`. A legal
  ACRE request with missing, inconsistent, reserved, or otherwise unrecoverable
  saved execution state produces `EXEC_STATE_CHECK`. This follows the canonical
  trap identity while documenting that the comparison Sail implementation
  currently routes its analogous target check through illegal instruction.
- PTO v0 receives already-decoded instruction bits and uses identity
  translation; it therefore has no instruction-fetch translation source for
  `INST_PAGE_FAULT`.
- ADR 0017 disables debug matching in PTO v0; writes to debug storage do not
  produce hardware breakpoint or watchpoint traps.
- Synchronous envelopes route through the normal manager policy, save the
  complete source context, report their declared argument, and recover to the
  saved TPC. `SCALL` additionally uses its established next-instruction resume
  rule. Interrupt entry retains its asynchronous status, source-supplied cause,
  pending ID argument, and saved-context recovery.
- Generated/catalog checks reject a missing producer declaration, missing
  cause/argument/restart contract, or a change to the three envelope-only
  identities without an explicit normative update.
- Stable per-trap witness IDs bind every catalog row to its exact executable
  envelope case and number, argument, cause, and restart assertions. `SCALL`
  has a dedicated `RaiseServiceRequest` witness for source-TPC argument,
  request-type cause, and next-instruction recovery rather than sharing the
  ordinary synchronous `SetFault` helper. A fail-closed guard permits
  `INST_PAGE_FAULT`, `HW_BREAKPOINT`, and `HW_WATCHPOINT` only in the
  `FaultCode` declaration and `SetFault` mapping, and content-addresses every
  normative trap producer/mutator plus every function mentioning canonical
  numbers 33, 49, or 51. Direct-number, helper, and indirect-`SetFault`
  negative canaries must all reject.

## Consequences

All 13 trap identities have a machine-readable disposition and executable
entry/routing/recovery evidence. “Envelope only” is not a claim that the event
can occur in PTO v0; a future active MMU or debug profile must define trigger
conditions, precedence, and conformance tests before changing that status.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

A trap number in a catalog does not prove that PTO can produce it or define entry and restart. Inventing producers for missing debug or translation behavior would import semantics the architecture had not accepted.

目录中的陷阱编号并不能证明 PTO 能产生该陷阱，也不能证明进入与重启行为完整。为缺失的 debug 或地址转换行为臆造 producer，会导入架构尚未接受的语义。

### Detailed decision / 详细决策

Each of 13 trap identities receives a status, producer envelope, cause, argument, and restart class. Ten are production-active; instruction page fault, hardware breakpoint, and hardware watchpoint retain complete envelopes but no current production trigger. Generated checks bind every row to executable entry, routing, and recovery evidence.

13 个陷阱身份中的每一个都获得状态、producer 包络、cause、argument 和重启类别。十个为生产活动状态；instruction page fault、hardware breakpoint 和 hardware watchpoint 保留完整包络，但没有当前生产触发源。生成检查把每一行绑定到可执行的进入、路由和恢复证据。

### What changed / 改动内容

#### English

- Classified every trap as active or envelope-only with complete metadata.
- Defined production triggers and recovery contracts without inventing absent MMU/debug behavior.
- Added per-trap executable evidence and catalog consistency checks.

#### 中文

- 以完整元数据把每个陷阱分类为活动或仅包络。
- 定义生产触发和恢复契约，同时不臆造缺失的 MMU/debug 行为。
- 增加逐陷阱可执行证据和目录一致性检查。

### Scope and boundaries / 范围与边界

An envelope-only identity is not an event that can currently occur. Activating one requires explicit trigger, precedence, and conformance decisions.

仅包络身份并不表示该事件当前能够发生。要激活它，必须显式决定触发条件、优先级和一致性要求。
