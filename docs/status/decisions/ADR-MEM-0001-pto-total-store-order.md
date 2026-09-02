---
{
  "id": "ADR-MEM-0001",
  "title": "PTO total store order candidate model",
  "title_zh": "PTO 全存储序候选模型",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "e4b8d240e358eff9aacc38235f1de8f2a4c5582e",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001"
  ],
  "affected_units": [
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-ATOMICITY",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-ARCH-OVERVIEW-ARCHITECTURE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0006"
  ]
}
---
# ADR-MEM-0001: PTO total store order candidate model

- Date: 2026-07-28
- Requirement: PTO-REQ-MEMORY-TSO-001

## Context

Acquire and release counters can show that an instruction touched an ordering
path, but they cannot distinguish a permitted concurrent outcome from a
forbidden one. PTO needs an executable relation over candidate memory events
that covers scalar and tile accesses without introducing a second instruction
execution level.

PTO needs a public, reviewable relation shape that is owned by this repository.
External event taxonomies and instruction semantics are not PTO authority.

## Decision

PTO defines the multi-copy-atomic `PTO-TSO` model in `asl/concurrency.asl`.
Candidate executions contain explicit initial writes, loads, stores, atomics,
and masked data fences from multiple agents. Program order is derived per
agent, reads-from is explicit, and coherence is a total rank per exact
address-and-size location.

A candidate is allowed when both `po-loc | rf | fr | co` and
`ppo | rfe | fr | co` are acyclic. PTO `ppo` preserves read-to-memory and
memory-to-write order while normally relaxing store-to-load. Atomics are full
ordering points. Acquire, release, acquire-release, and applicable `FENCE.D`
masks can add preserved order but cannot weaken TSO.

The executable checker is bounded to 16 events and four agents. These are
verification bounds. Mixed-size and partially overlapping candidate accesses
fail closed pending a byte-level coherence rule.

## Consequences

- Allowed and forbidden concurrency outcomes have executable witnesses.
- Scalar and tile accesses share one ordering relation without hidden replay
  state.
- Epoch counters are removed because they are not concurrency evidence.
- A future mixed-size extension must define byte-level coherence and add
  litmus evidence before those candidates can become valid.
- Every retained rule is stated as a PTO-owned ASL predicate and test.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Counters can show that an ordering path was touched, but they cannot decide whether a concurrent outcome is permitted. PTO therefore needs an executable, repository-owned relation over scalar and Tile memory events rather than an external taxonomy or hidden replay model.

计数器只能表明某条顺序路径被触及，却不能判断并发结果是否允许。因此，PTO 需要一套由本仓库拥有、覆盖标量和 Tile 内存事件的可执行关系，而不是外部事件分类或隐藏重放模型。

### Detailed decision / 详细决策

`PTO-TSO` models initial writes, loads, stores, atomics, and masked data fences across agents. It derives program order per agent, uses explicit reads-from and per-location coherence, and accepts only candidates satisfying both acyclicity checks. Atomics are full ordering points; acquire, release, acquire-release, and applicable fence masks can strengthen but never weaken TSO.

`PTO-TSO` 对多 agent 的初始写、加载、存储、原子操作和带掩码的数据栅栏建模。它逐 agent 推导程序顺序，显式表示 reads-from 和逐位置 coherence，并仅接受满足两项无环检查的候选。原子操作是完整顺序点；acquire、release、acquire-release 和适用的栅栏掩码只能加强、不能削弱 TSO。

### What changed / 改动内容

#### English

- Replaced ordering-path counters with executable allowed/forbidden candidate checks.
- Unified scalar and Tile accesses under one event relation.
- Failed mixed-size and partially overlapping candidates closed pending byte-level coherence.

#### 中文

- 以可执行的允许/禁止候选检查取代顺序路径计数器。
- 将标量和 Tile 访问统一到一套事件关系中。
- 在字节级 coherence 尚未定义前，对混合宽度和部分重叠候选 fail-closed。

### Scope and boundaries / 范围与边界

The 16-event and four-agent limits are verification bounds, not implementation limits. This decision does not define byte-level mixed-size coherence or introduce architectural replay state.

16 个事件和 4 个 agent 的限制是验证边界，不是实现上限。本决策不定义字节级混合宽度 coherence，也不引入架构重放状态。
