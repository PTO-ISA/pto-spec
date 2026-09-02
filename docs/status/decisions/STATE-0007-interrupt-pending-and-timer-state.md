---
{
  "id": "ADR-STATE-0007",
  "title": "Define interrupt pending and timer state",
  "title_zh": "定义中断挂起与计时器状态",
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
    "PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT",
    "PTO-ARCH-SYSTEM-REGISTERS-TIMER"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0016"
  ]
}
---
# ADR-STATE-0007: Define interrupt pending and timer state

## Context

The visible ACR register family includes interrupt configuration, pending,
priority, acknowledgement, timer time, and timer comparison registers. The
previous model treated most of them as unrelated generic words. `EOIEI` cleared
trap-status flags without clearing the named pending interrupt, and timer
comparison had no observable effect.

PTO needs a self-contained rule for interrupt bit identity, priority, enable
gating, and reassertion.

## Decision

- `IPENDING_ACRn` is a read-only 64-bit bitmap. Bit `i` records pending
  interrupt ID `i` for the selected ACR.
- The complete architectural interrupt injection domain is ID 0 through ID 63,
  represented by the `InterruptID` type. Values outside that domain are not
  architectural interrupt events and do not enter the trap or fault model.
- `TOPEI_ACRn` is read-only and returns the numerically lowest set pending ID.
  It returns zero when the bitmap is empty; software uses `IPENDING` to
  distinguish no interrupt from pending ID zero.
- `ECONFIG_ACRn[0]` enables external interrupt entry and bit 1 enables timer
  interrupt entry. PTO v0 resets both bits to one in every ACR bank. Disabled
  interrupts become pending but do not enter a handler.
- ACR0 uses timer interrupt ID 1. ACR1 through ACR15 use timer interrupt ID 3.
- `TIMER_TIME_ACRn` reads the architectural monotonic counter.
  `TIMER_TIMECMP_ACRn` is zero at reset. A nonzero comparison sets the timer
  pending bit whenever unsigned time is greater than or equal to the compare
  value; zero or a future value clears it.
- `EOIEI_ACRn` is write-only. A canonical interrupt ID in bits 5:0 clears that
  pending bit and completes the bank's current interrupt status. A timer whose
  nonzero comparison remains reached reasserts when pending state is observed;
  software writes zero to the comparator to stop it.
- Interrupt injection sets pending state before enable checking. Enabled
  injection then uses the existing interrupt trap envelope and visible saved
  context.

## Consequences

Pending, top priority, enable, acknowledgement, timer threshold, reassertion,
all-bank reset, and trap entry are one coherent executable subsystem. Endpoint
IDs 0 and 63 have direct injection and acknowledgement witnesses. Writes to
`IPENDING` and `TOPEI` fault through their catalog-declared read-only access
class.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Visible interrupt and timer registers were previously unrelated storage: EOIEI did not clear a named pending interrupt, priority was undefined, enable gating was unclear, and timer comparison had no effect. PTO needed one executable subsystem.

可见的中断与计时器寄存器此前只是互不关联的存储：EOIEI 不会清除具名挂起中断，优先级未定义，使能门控不清楚，计时器比较也没有效果。PTO 需要一套统一可执行子系统。

### Detailed decision / 详细决策

Pending state is a 64-bit ID bitmap, top priority is the lowest set ID, and ECONIFG bits gate external and timer entry without suppressing pending state. Timer comparison selects fixed per-ACR IDs, EOIEI acknowledges a canonical ID, reached timers can reassert, and enabled injection enters the existing interrupt trap envelope.

挂起状态是 64 位 ID bitmap，最高优先级是最小的置位 ID；ECONFIG 位控制外部与计时器进入，但不抑制挂起状态。计时器比较为各 ACR 选择固定 ID，EOIEI 确认规范 ID，已到期计时器可以重新置位，已使能注入进入既有中断陷阱包络。

### What changed / 改动内容

#### English

- Unified pending, priority, enable, acknowledgement, timer threshold, and trap entry.
- Defined the complete architectural interrupt ID domain 0..63.
- Made access classes and timer reassertion directly testable.

#### 中文

- 统一挂起、优先级、使能、确认、计时器阈值和陷阱进入。
- 定义完整架构中断 ID 域 0..63。
- 使访问类别和计时器重新置位可直接测试。

### Scope and boundaries / 范围与边界

Values outside ID 0..63 are not architectural interrupts. This record does not define external interrupt-source hardware beyond injection into the architectural pending state.

0..63 之外的值不是架构中断。本记录不定义把事件注入架构挂起状态之前的外部中断源硬件。
