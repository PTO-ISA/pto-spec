---
{
  "id": "ADR-MEM-0002",
  "title": "Production memory events and atomic corners",
  "title_zh": "生产内存事件与原子操作边界",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-29",
  "accepted": "2026-07-29",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-GM-ACCESS-001",
    "PTO-BSTART-GMOV-COLLECTIVE-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TPREFETCH-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-GMOV-CORE4-PEER-001",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001",
    "PTO-MGATHER-MASK-PREDICATE-001",
    "PTO-MGATHER-MASK-PUBLICATION-001",
    "PTO-MGATHER-MASK-TYPE-002",
    "PTO-MSCATTER-BYTE-DISPLACEMENT-001",
    "PTO-MSCATTER-DUPLICATE-ORDER-001",
    "PTO-MSCATTER-MASK-DUPLICATE-001",
    "PTO-MSCATTER-MASK-PREDICATE-001",
    "PTO-MSCATTER-MASK-TYPE-002",
    "PTO-SD-XOR-ADR-CONTRACT-001",
    "PTO-SW-ADD-ADR-CONTRACT-001",
    "PTO-SW-AND-ADR-CONTRACT-001",
    "PTO-SW-OR-ADR-CONTRACT-001",
    "PTO-SW-SMAX-ADR-CONTRACT-001",
    "PTO-SW-SMIN-ADR-CONTRACT-001",
    "PTO-SW-UMAX-ADR-CONTRACT-001",
    "PTO-SW-UMIN-ADR-CONTRACT-001",
    "PTO-SW-XOR-ADR-CONTRACT-001",
    "PTO-SWAPB-ADR-CONTRACT-001",
    "PTO-SWAPD-ADR-CONTRACT-001",
    "PTO-SWAPH-ADR-CONTRACT-001",
    "PTO-SWAPW-ADR-CONTRACT-001",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-TPREFETCH-FOOTPRINT-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001"
  ],
  "affected_units": [
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-ATOMICITY",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS",
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-BLOCK-BSTART-GMOV",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TPREFETCH",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-SCALAR-CASB",
    "PTO-SCALAR-CASD",
    "PTO-SCALAR-CASH",
    "PTO-SCALAR-CASW",
    "PTO-SCALAR-DMA",
    "PTO-SCALAR-HL-CASB",
    "PTO-SCALAR-HL-CASD",
    "PTO-SCALAR-HL-CASH",
    "PTO-SCALAR-HL-CASW",
    "PTO-SCALAR-LD-ADD",
    "PTO-SCALAR-LD-AND",
    "PTO-SCALAR-LD-OR",
    "PTO-SCALAR-LD-SMAX",
    "PTO-SCALAR-LD-SMIN",
    "PTO-SCALAR-LD-UMAX",
    "PTO-SCALAR-LD-UMIN",
    "PTO-SCALAR-LD-XOR",
    "PTO-SCALAR-LR-B",
    "PTO-SCALAR-LR-D",
    "PTO-SCALAR-LR-H",
    "PTO-SCALAR-LR-W",
    "PTO-SCALAR-LW-ADD",
    "PTO-SCALAR-LW-AND",
    "PTO-SCALAR-LW-OR",
    "PTO-SCALAR-LW-SMAX",
    "PTO-SCALAR-LW-SMIN",
    "PTO-SCALAR-LW-UMAX",
    "PTO-SCALAR-LW-UMIN",
    "PTO-SCALAR-LW-XOR",
    "PTO-SCALAR-SC-B",
    "PTO-SCALAR-SC-D",
    "PTO-SCALAR-SC-H",
    "PTO-SCALAR-SC-W",
    "PTO-SCALAR-SD-ADD",
    "PTO-SCALAR-SD-AND",
    "PTO-SCALAR-SD-OR",
    "PTO-SCALAR-SD-SMAX",
    "PTO-SCALAR-SD-SMIN",
    "PTO-SCALAR-SD-UMAX",
    "PTO-SCALAR-SD-UMIN",
    "PTO-SCALAR-SD-XOR",
    "PTO-SCALAR-SW-ADD",
    "PTO-SCALAR-SW-AND",
    "PTO-SCALAR-SW-OR",
    "PTO-SCALAR-SW-SMAX",
    "PTO-SCALAR-SW-SMIN",
    "PTO-SCALAR-SW-UMAX",
    "PTO-SCALAR-SW-UMIN",
    "PTO-SCALAR-SW-XOR",
    "PTO-SCALAR-SWAPB",
    "PTO-SCALAR-SWAPD",
    "PTO-SCALAR-SWAPH",
    "PTO-SCALAR-SWAPW",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TMOV",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TSTORE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0020"
  ]
}
---
# ADR-MEM-0002: Production memory events and atomic corners

- Date: 2026-07-29
- Requirement: PTO-REQ-MEMORY-TSO-001

## Context

The PTO-TSO checker initially accepted only candidates assembled directly by
tests. Production scalar and tile semantics changed memory without exposing the
corresponding event kind, location, value, agent, or ordering annotation. The
architecture also needed one owned answer for reservation scope, failed store-
conditional behavior, conditional CAS writes, tile prefetch, gather-CAS lane
atomicity, and mixed-size overlap.

Comparison implementations are not consistent enough to serve as PTO
authority. Available models disagree between line-granular and exact-address
reservations, omit ordering modifiers, and leave mixed-size coherence unstated.
PTO therefore defines and tests the rules below directly.

## Decision

Production semantics use the same `MemoryEvent` record and PTO-TSO relations as
manually constructed candidates. Event capture is an explicit verification
mode selected with a bounded agent identifier. It is disabled during ordinary
architectural execution, so exhausting the 16-event checker bound cannot become
an ISA-visible exception. Event indices give program order only for events with
the same selected agent.

Events use the translated address. Successful scalar singles, pairs, LR/SC,
RMW, CAS, DMA, `FENCE.D`, and tile memory operations record at their commit
points after complete access preflight. Raw values are normalized to the event
size before reads-from comparison. A concrete sequential capture assigns the
next observed coherence rank and resolves a read from the latest matching
captured write; manually constructed concurrent candidates retain explicit
reads-from and coherence control.

The remaining rules are:

- `aq=0,rl=0` is relaxed, `aq` is acquire, `rl` is release, and both bits are
  acquire-release. These annotations never weaken PTO-TSO.
- `FENCE.D` emits one masked fence event. `FENCE.I` has instruction-visibility
  and reservation effects but no data-memory event.
- The local LR/SC reservation granule is 64 bytes. LR records its exact access
  address and size for inspection, while SC success depends on the containing
  64-byte line. A different byte address or width in the same line can succeed.
- Any completed store overlapping the reserved line invalidates it. Every SC
  attempt clears it. An SC whose reservation check fails performs no alignment,
  translation, or permission probe and emits no event. When the line check
  succeeds, the store access is probed; a resulting fault clears the reservation
  and emits no event.
- RMW and successful CAS emit one indivisible read/write atomic event. Failed
  CAS emits one atomic event with `write_performed = FALSE`; it participates as
  a read and ordering point but contributes no coherence write.
- DMA is represented as eight ordered 8-byte loads followed by eight ordered
  8-byte stores. This exactly fills the current verification bound and does not
  change its single-instruction, snapshot-before-commit behavior.
- Each active gather-CAS lane emits one atomic event. The complete instruction
  is not globally atomic. The portable profile uses logical row-major lane
  order, including duplicate addresses, after instruction-wide preflight.
- Scalar prefetch is a non-faulting hint and emits no event. Tile `TPREFETCH`
  is deliberately different: it preflights the complete footprint, faults and
  restarts like a tile load, and records the same typed-element load events as
  destination-producing `TLOAD` when capture is enabled. Packed four-bit
  logical elements retain the same byte-addressed event decomposition as
  `TLOAD`.
- PTO-TSO locations remain exact translated address-and-size pairs. A candidate
  with mixed-size or partially overlapping accesses fails validity until PTO
  owns a byte-level coherence extension.

## Consequences

- Production and litmus evidence now exercise one normative event taxonomy.
- Faulting multi-access instructions leave no partial event prefix.
- The bounded recorder is verification infrastructure, not hidden
  architectural state or an implementation capacity.
- Line-granular cross-width SC, no-probe failed SC, row-major gather-CAS lanes,
  and faulting tile prefetch are deliberate PTO choices and require an ADR
  change plus updated executable witnesses to revise.
- Wider DMA events, byte-level mixed-size coherence, and alternative tile-lane
  schedules require explicit model extensions rather than silent inference.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The initial TSO checker only saw test-constructed candidates, while production instructions changed memory without exposing comparable events. Reservation scope, failed SC behavior, CAS writes, prefetch faults, gather-CAS lane order, and overlap also required one PTO-owned answer.

最初的 TSO 检查器只能看到测试直接构造的候选，而生产指令改变内存时没有暴露可比较事件。保留粒度、失败 SC 行为、CAS 写入、prefetch 故障、gather-CAS lane 顺序和重叠访问也需要一套 PTO 自有答案。

### Detailed decision / 详细决策

Production scalar and Tile semantics record the same `MemoryEvent` form at commit after complete preflight, using translated addresses and normalized values. Capture is verification-only and disabled in ordinary execution. The record fixes ordering modifiers, a 64-byte LR/SC reservation line, no-probe failed SC, conditional CAS writes, prefetch behavior, row-major gather-CAS atomic lanes, and fail-closed mixed-size overlap.

生产标量和 Tile 语义在完整预检后的提交点记录同一种 `MemoryEvent`，使用转换后地址和规范化值。捕获仅用于验证，在普通执行中关闭。本记录固定顺序修饰、64 字节 LR/SC 保留行、失败 SC 不探测、条件 CAS 写入、prefetch 行为、按行优先的 gather-CAS 原子 lane，以及混合宽度重叠的 fail-closed 处理。

### What changed / 改动内容

#### English

- Connected production memory effects to the TSO event taxonomy.
- Specified atomic and reservation corner cases, commit points, and no-partial-prefix guarantees.
- Kept bounded capture infrastructure non-architectural.

#### 中文

- 将生产内存效果接入 TSO 事件分类。
- 规定原子与保留边界、提交点和无部分事件前缀保证。
- 明确有界捕获基础设施不是架构状态。

### Scope and boundaries / 范围与边界

Wider DMA events, byte-level mixed-size coherence, and alternative Tile-lane schedules remain outside this decision and require explicit model extensions and new evidence.

更宽的 DMA 事件、字节级混合宽度 coherence 和其他 Tile lane 调度不在本决策范围内，必须通过显式模型扩展和新证据引入。
