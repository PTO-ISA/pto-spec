---
{
  "id": "ADR-MEM-0010",
  "title": "PTO relaxed consistency with preserved Store-to-Store order",
  "title_zh": "PTO 保留 Store-to-Store 顺序的 RC 内存模型",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-09-16",
  "accepted": "2026-09-16",
  "rejected": null,
  "superseded": "2026-09-17",
  "baseline": "9323e466512eb261eec084e5c5401214787fffe4",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-MEMORY-MODEL-SCOPE-001",
    "PTO-ARCH-MEMORY-MODEL-REQUEST-CLASS-001",
    "PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001",
    "PTO-ARCH-MEMORY-MODEL-RANGE-001",
    "PTO-ARCH-MEMORY-MODEL-CONFLICT-001",
    "PTO-ARCH-MEMORY-MODEL-DEPENDENCY-001",
    "PTO-ARCH-MEMORY-MODEL-QUALIFIER-001",
    "PTO-ARCH-MEMORY-MODEL-RC-001",
    "PTO-ARCH-MEMORY-MODEL-PREFETCH-001",
    "PTO-ARCH-MEMORY-MODEL-ATOMIC-001",
    "PTO-ARCH-MEMORY-MODEL-OPEN-001",
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TSTORE-MEMORY-001"
  ],
  "affected_units": [
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-MEMORY-RESTART",
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-MEM-0001"
  ],
  "superseded_by": [
    "ADR-MEM-0011"
  ],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/302",
  "release_impact": "required",
  "interface_change": true,
  "legacy_ids": [],
  "amendments": []
}
---
# ADR-MEM-0010: PTO relaxed consistency with preserved Store-to-Store order

- Decision date: 2026-09-16
- Baseline: `9323e466`
- Issues: [#302](https://github.com/PTO-ISA/pto-spec/issues/302),
  [#268](https://github.com/PTO-ISA/pto-spec/issues/268),
  [#140](https://github.com/PTO-ISA/pto-spec/issues/140), and the completed
  indexed-TLSU closure in [#301](https://github.com/PTO-ISA/pto-spec/issues/301)
- Supersedes: [ADR-MEM-0001](ADR-MEM-0001-pto-total-store-order.md)

## Context

The former accepted candidate checker was PTO-TSO. Its preserved program order
kept Load-to-Load and Load-to-Store edges, which makes speculative loads depend
on coherence-driven invalidation or commit-time revalidation. The selected PTO
architecture instead needs the performance freedom to issue independent loads
speculatively while retaining the software-useful producer-side Store-to-Store
ordering rule.

This decision also closes the memory-model ownership gap identified by #140. The
portable model is now represented by the owning ASL units rather than by a
removed external document or an implementation-specific cache description.

## Decision

PTO uses relaxed consistency with preserved Store-to-Store program order
(`PTO-RC+S→S`) as its default memory-model baseline:

- Load-to-Load, Load-to-Store, and Store-to-Load pairs to different locations
  are relaxed unless an explicit ordering relation applies.
- Store-to-Store pairs in one hardware thread remain preserved in program
  order. This is the default propagation rule for initialization-before-flag
  patterns; it does not provide consumer-side Load-to-Load ordering.
- Acquire, release, acquire-release, atomic, dependency, conflict, and matching
  fence relations add edges exactly where their owning contracts require them.
- Same-location reads-from, coherence, from-read, and atomic read-modify-write
  validity remain unchanged. Mixed-size and partial-overlap candidates remain
  fail-closed pending a byte-level coherence decision.
- Independent, otherwise unordered requests may be issued, completed, split,
  merged, coalesced, forwarded, cached, replayed, or internally reordered.
  These are implementation freedoms, not new architectural state.

The bounded executable witness is `MemoryExecutionAllowedRC` in
`asl/arch/memory-model/ordering.asl`. Its array bounds remain model bounds.

## Memory-domain projection

The architecture-visible GM domain covers scalar, Tile, indexed/generated, and
prefetch-like requests. Tile values are data dependencies, not memory
locations. Scalar accesses that may alias Tile or indexed/generated requests
must use an applicable shareability domain; marking such an access Private
provides no portable guarantee. Indexed/generated operations may use a
conservative base/range descriptor, and an omitted range does not protect the
omitted locations.

Read-read overlap is not a conflict. A conflict is an overlapping access set
with at least one write or atomic update in an applicable shareability domain.
Address, data, and control dependencies are separate ordering sources. The
`order_after_prior` and `order_before_later` qualifiers add directional same-
thread edges even for non-overlapping or undescribed ranges.

Prefetch remains a non-value-producing performance hint unless its instruction
owner explicitly gives it visible ordering. Atomic and read-modify-write
requests have both read and write effects and remain full ordering points unless
their named owner says otherwise.

## TLOAD/TSTORE fault boundary

TLOAD and TSTORE use first-fault-only reporting. A request stops at its first
translation, permission, alignment, or page fault; accesses completed before
that fault are not rolled back. TLOAD may leave a destination allocated with a
partially defined valid region and must not advertise it as complete. TSTORE
may leave earlier GM writes and their memory events visible. No order is implied
among internal lanes beyond the explicit iteration and memory-model relations.

This closure covers the ordinary Local/Shared and Local CUBE TLSU paths. The
specialized weight-mode Shared TLOAD remains under its existing complete-
preflight owner and is intentionally outside this ADR until its independent
partial-generation contract is approved.

The Block fault boundary remains precise for the faulting operation and blocks
younger work. This rule does not make a Tile operation internally restartable at
an arbitrary lane, and recovery must not assume that retrying is equivalent to
executing the original operation once.

## Compatibility and non-goals

No opcode, encoding, or ABI changes are introduced. Compiler, emulator, RTL,
and SSM projections must stop assuming implicit TSO Load-to-Load ordering and
must insert acquire/release or fences where required. No named target profile is
created for a legacy TSO mode by this ADR.

The following remain intentionally open: inter-core visibility and
synchronization strength, transport of shareability and qualifiers, fence
instruction encoding/strength, mixed-size overlap, repeated-target scatter
order, cross-agent atomic order, and precise exception/replay/flush semantics.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

PTO needs independent loads to issue speculatively without paying a
coherence-driven Load-to-Load validation cost in the common case. Preserving
Store-to-Store order keeps producer-side publication useful while leaving
consumer-side observation to explicit acquire/release or fences.

PTO 需要允许独立 Load 投机发射，避免在常见路径上为 Load-to-Load 保序支付
coherence 驱动的验证成本。保留 Store-to-Store 顺序可以继续支持生产者侧的
发布顺序，而消费者侧观察必须通过显式 acquire/release 或 fence 建立。

### Detailed decision / 详细决策

The normative baseline is RC+S→S. Load-to-Load and Load-to-Store are relaxed;
Store-to-Store is preserved; Store-to-Load remains relaxed for different
locations. Existing atomic, acquire/release, fence, dependency, conflict, and
same-location coherence rules continue to add their own edges.

规范基线是 RC+S→S。Load-to-Load 与 Load-to-Store 放松，Store-to-Store 保序，
不同地址的 Store-to-Load 仍放松。现有 atomic、acquire/release、fence、依赖、
冲突和同址 coherence 规则继续按各自 owner 增加顺序边。

### What changed / 改动内容

#### English

- Replaced the accepted TSO candidate checker with `MemoryExecutionAllowedRC`.
- Added the complete PTO-owned memory-domain projection for #140.
- Changed TLOAD/TSTORE fault behavior to first-fault-only with retained prior
  effects as requested by #268.
- Kept the indexed byte-displacement and unified CUBE layout closure from #301
  under ADR-MEM-0009; this ADR changes ordering and fault boundaries only.

#### 中文

- 以 `MemoryExecutionAllowedRC` 替换原先已接受的 TSO 候选执行检查器。
- 为 #140 增加由 PTO 拥有的完整内存域投影，包括请求类别、可共享性、范围、冲突、依赖与顺序限定符。
- 按 #268 将 TLOAD/TSTORE 改为只报告首个故障，并保留故障前已经完成的效果。
- 保留 #301 在 ADR-MEM-0009 中确定的索引字节位移与统一 CUBE 布局；本 ADR 只改变顺序和故障边界。

### Scope and boundaries / 范围与边界

This ADR owns the PTO-wide ordering baseline, request classes, shareability,
conservative access ranges, qualifiers, and the TLOAD/TSTORE first-fault
boundary. It does not define opcode encodings, inter-core coherence, fence
transport, mixed-size byte coherence, or backend cache policy.

本 ADR 负责 PTO 全局内存顺序基线、请求类别、可共享性、保守访问范围、顺序
限定符以及普通 Local/Shared 与 Local CUBE TLOAD/TSTORE 的首故障边界。专用
weight-mode Shared TLOAD 仍由现有完整预检 owner 负责，待单独闭合部分代际契约后再纳入。
它不定义 opcode 编码、跨核 coherence、
fence 传输、混合宽度字节 coherence 或后端缓存策略。

## Verification

Evidence must cover RC store buffering, relaxed Load-to-Load and Load-to-Store,
preserved Store-to-Store, acquire/release message passing, IRIW behavior, same-
location coherence, atomicity, request classification, shareability mismatch,
conservative ranges, qualifiers, prefetch non-interference, and first-fault
partial TLOAD/TSTORE effects. The final candidate requires `make pr-check`,
`git diff --check`, and `make repo-check` when the release surface is closed.
