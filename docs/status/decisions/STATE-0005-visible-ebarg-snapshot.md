---
{
  "id": "ADR-STATE-0005",
  "title": "Make EBARG the visible PTO v0 trap snapshot",
  "title_zh": "将 EBARG 定义为可见的 PTO v0 陷阱快照",
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
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-STATE-TRAP-CONTEXT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0011"
  ]
}
---
# ADR-STATE-0005: Make EBARG the visible PTO v0 trap snapshot

## Context

The system-register contract exposes 18 banked `EBARG` registers, while the
earlier reference model saved all return state only in an internal record. That
made the visible register values observationally unrelated to `ACRE`: software
could inspect or edit an `EBARG` word, but recovery ignored the edit.

The architecture also permits profile-defined extended execution state beyond
the first-layer register snapshot. PTO v0 needs bounded executable storage for
bundle arguments and other state that has no allocated `EBARG` word.

## Decision

In PTO v0, `EBARG` is the editable first-layer trap snapshot:

- `EBARG0[3:0]` records the source ACR, bit 4 is snapshot valid, bits 5 and 6
  record bundle-active and bundle-body-active, bits 10:7 record bundle kind,
  bits 13:11 record transfer kind, and bit 14 records the bundle condition.
  Bits 63:15 are reserved zero.
- `EBARG_BPC_CUR`, `EBARG_BPC_TGT`, `EBARG_TPC`, and `EBARG_LRA` record the
  current BPC, next target, resume TPC, and local return address.
- `EBARG_TQ0` through `EBARG_TQ3` and `EBARG_UQ0` through `EBARG_UQ3` record all
  temporary queue entries in newest-to-oldest order.
- PTO v0 has no first-layer loop-boundary or loop-counter registers, so trap
  save writes zero to `EBARG_LB` and `EBARG_LC`; software may still read and
  write those context words, but recovery does not consume them.
- `EBARG_EXTCTX_PTR`, `EBARG_EXTCTX_META`, and `EBARG_TPLFLAGS` are persistent
  read/write context words. Ordinary trap save does not overwrite them.
- `ECSTATE` records the source `CORE_STATE`; bits 3:0 select the recovery ACR
  and bit 4 records whether the source was in a bundle body.

`ACRE` consumes the visible `ECSTATE` and `EBARG` PC, queue, return, and bundle-
control fields. ACR0 software may therefore edit those fields before recovery.
Recovery clears `EBARG0.VALID`. A missing snapshot, reserved control encoding,
body-active without bundle-active, inconsistent source ACR, or odd BPC/TPC is
an execution-state-check fault rather than a silent no-op. An unsupported ACRE
request-type encoding remains an illegal-instruction fault.

The internal saved context also preserves bundle dimensions, scalar and tile
bindings, control/data attributes, fallthrough state, the bundle return target,
the bundle-argument kind, and all eight 32-bit predicate registers. The bundle
return target is distinct from the local
return address held in `EBARG_LRA`. These fields have no complete EBARG encoding
in PTO v0, so successful recovery restores their saved values. EBARG-covered
fields remain authoritative and may be deliberately edited by manager software
before recovery.

The bounded `_TrapContexts` record is PTO v0 profile-defined extended `EBSTATE`,
not an alternative visible register file. It retains bundle argument, bundle-
argument kind, bundle return target, and commit state that have no allocated
first-layer `EBARG` words. Those fields remain an explicit extended-context
profile dependency.

## Consequences

Trap recovery observes software edits to the visible return PC and queue state,
and every `EBARG` address has a defined reset and access behavior. Complete
portable serialization of the remaining extended bundle state is still tracked
separately from this first-layer snapshot closure.

The system-register behavior catalog therefore partitions the range rather
than assigning one over-broad behavior to all 18 words: 13 recovery-active
snapshot registers, two save-zero/recovery-inert loop-context words, and three
save-preserved/recovery-inert extended-context words. Tests exercise all five
tail registers across reset, software write, trap save, and recovery.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The architecture exposed banked EBARG registers while recovery used only an internal record. Software edits to visible return state were therefore ignored, and extended bundle state without EBARG words had no bounded executable storage contract.

架构暴露 banked EBARG 寄存器，但恢复只使用内部记录。因此，软件对可见返回状态的修改会被忽略，而没有 EBARG 字的扩展 Bundle 状态也缺少有界可执行存储契约。

### Detailed decision / 详细决策

EBARG becomes the editable first-layer trap snapshot for source ACR, validity, bundle control, BPC/TPC/LRA, and T/U queues. ACRE consumes visible recovery-active fields and validates consistency. Loop words are save-zero/recovery-inert, three tail words are save-preserved/recovery-inert, and the bounded internal context retains only extended state without complete EBARG encoding.

EBARG 成为可编辑的第一层陷阱快照，保存源 ACR、有效位、Bundle 控制、BPC/TPC/LRA 及 T/U 队列。ACRE 消费可见且参与恢复的字段并验证一致性。loop 字段保存为零且恢复时忽略，三个尾部字保存保持且恢复时忽略；有界内部上下文只保留没有完整 EBARG 编码的扩展状态。

### What changed / 改动内容

#### English

- Connected visible EBARG words to trap save and ACRE recovery.
- Defined bit fields, active recovery words, inert tail classes, validation failures, and snapshot invalidation.
- Separated editable first-layer state from profile-defined extended context.

#### 中文

- 将可见 EBARG 字连接到陷阱保存与 ACRE 恢复。
- 定义位字段、参与恢复的字、惰性尾部类别、验证失败和快照失效。
- 区分可编辑第一层状态与 Profile 定义的扩展上下文。

### Scope and boundaries / 范围与边界

The record does not claim complete portable serialization of all extended bundle state. Fields without allocated EBARG encoding remain an explicit extended-context dependency.

本记录不声称对全部扩展 Bundle 状态实现完整可移植序列化。没有分配 EBARG 编码的字段仍是显式扩展上下文依赖。
