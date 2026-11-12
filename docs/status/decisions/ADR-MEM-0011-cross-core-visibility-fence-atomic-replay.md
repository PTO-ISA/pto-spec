---
{
  "id": "ADR-MEM-0011",
  "title": "Cross-agent visibility, fence transport, atomic ordering, and precise replay",
  "title_zh": "\u8de8 agent \u53ef\u89c1\u6027\u3001fence \u4f20\u8f93\u3001atomic \u987a\u5e8f\u4e0e\u7cbe\u786e\u91cd\u653e",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-09-17",
  "accepted": "2026-09-17",
  "rejected": null,
  "superseded": null,
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
    "PTO-ARCH-MEMORY-MODEL-VISIBILITY-001",
    "PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001",
    "PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001",
    "PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001",
    "PTO-ARCH-MEMORY-MODEL-REPLAY-001",
    "PTO-ARCH-MEMORY-MODEL-FLUSH-001",
    "PTO-ARCH-MEMORY-MODEL-ATOMIC-001",
    "PTO-ARCH-MEMORY-MODEL-OPEN-001",
    "PTO-ARCH-GM-OBLIGATIONS-001",
    "PTO-ARCH-PE-EXECUTION-CONTEXT-001",
    "PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-TSTORE-STRIDED-ATOMIC-RED-001",
    "PTO-REQ-INSTRUCTION-DISPATCH-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-MEMORY-MODEL",
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-ARCH-MEMORY-MODEL-ATOMICITY",
    "PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-ATOMIC-TSTORE",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TSTORE",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-SCALAR-MODEL-AGU-MEMORY",
    "PTO-SCALAR-MODEL-AMO-SEMANTICS",
    "PTO-ARCH-STATE-PE-EXECUTION-CONTEXT"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-MEM-0010"
  ],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/302",
  "release_impact": "required",
  "interface_change": true,
  "legacy_ids": [],
  "amendments": [
    {
      "date": "2026-11-11",
      "baseline": "42067d0f2890b8c013a868bd1247ebc6437b3179",
      "approvers": [
        "ckwllawliet"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/416",
      "affected_ndf": [
        "PTO-ARCH-MEMORY-MODEL-SCOPE-001",
        "PTO-ARCH-MEMORY-MODEL-REQUEST-CLASS-001",
        "PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001",
        "PTO-ARCH-MEMORY-MODEL-CONFLICT-001",
        "PTO-ARCH-MEMORY-MODEL-VISIBILITY-001",
        "PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001",
        "PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001",
        "PTO-ARCH-MEMORY-MODEL-RC-001",
        "PTO-ARCH-MEMORY-MODEL-REPLAY-001",
        "PTO-ARCH-GM-OBLIGATIONS-001",
        "PTO-ARCH-PE-EXECUTION-CONTEXT-001",
        "PTO-REQ-INSTRUCTION-DISPATCH-001",
        "PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001"
      ],
      "affected_units": [
        "PTO-ARCH-DATA-TYPES-MEMORY-MODEL",
        "PTO-ARCH-MEMORY-MODEL-ATOMICITY",
        "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
        "PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS",
        "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
        "PTO-ARCH-MEMORY-MODEL-ORDERING",
        "PTO-ARCH-DISPATCH-TOP-LEVEL",
        "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL",
        "PTO-SCALAR-MODEL-AGU-MEMORY",
        "PTO-SCALAR-MODEL-AMO-SEMANTICS",
        "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
        "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER",
        "PTO-TILE-MODEL-MEMORY-ATOMICS",
        "PTO-TILE-MODEL-MEMORY-ATOMIC-TSTORE",
        "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
        "PTO-ARCH-STATE-PE-EXECUTION-CONTEXT"
      ]
    }
  ]
}
---
# ADR-MEM-0011: Cross-agent visibility, fence transport, atomic ordering, and precise replay

- Decision date: 2026-09-17
- Baseline: `9323e466`
- Issues: [#301](https://github.com/PTO-ISA/pto-spec/issues/301),
  [#268](https://github.com/PTO-ISA/pto-spec/issues/268),
  [#140](https://github.com/PTO-ISA/pto-spec/issues/140), and the RC choice in
  [ADR-MEM-0010](ADR-MEM-0010-relaxed-consistency-store-store-order.md)
- Supersedes: [ADR-MEM-0010](ADR-MEM-0010-relaxed-consistency-store-store-order.md)

## Decision

PTO-RC+S→S uses a multi-copy atomic GM domain. A completed write has one global
coherence position for its exact byte range and may be observed by every agent
in the applicable shareability domain. A release write read by an acquire load
from another agent establishes synchronizes-with; relaxed operations provide no
cross-agent publication ordering beyond ordinary coherence.

Fence predecessor/successor class masks are the portable transport and strength
contract. A fence orders only the matching classes in the same agent. An
implementation may use stronger internal machinery, but it cannot expose a
weaker result or infer a cross-agent synchronization edge without a matching
release/acquire access.

GM locations remain byte-addressed, but byte-level tearing, merge, or value
assembly is not defined here. Any partial overlap between distinct access
ranges fails closed; only exact address-and-size matches participate in the
portable coherence relation.

Atomic and RMW events are indivisible read/write events for one exact range and
occupy the same global coherence order as ordinary writes. Acquire/release
atomics may synchronize across agents. Relaxed atomics guarantee atomicity and
coherence only; they do not impose a global sequentially consistent order on
different locations.

Fault and recovery are precise at the owning architectural boundary. Scalar
faults retire no younger effects. Tile memory requests retain beats completed
before the first fault, leave partial destinations or generations incomplete,
and replay the whole logical request from its saved template. Internal lane,
cursor, queue, and cache progress is not architectural state. Flush removes
only uncommitted event records and younger work; it never rolls back a
committed GM write, Tile payload element, or admitted memory event.

## Compatibility and non-goals

No opcode or ABI encoding changes are introduced. Existing FENCE.D masks and
aq/rl qualifiers are the observable inputs. Repeated-target scatter order and
backend cache/interconnect mechanisms remain implementation-defined.

## 中文摘要

PTO-RC+S→S 的 GM 域采用 multi-copy atomic。精确字节范围具有一个全局
coherence 顺序；跨 agent 的 release 写被 acquire 读到时建立
synchronizes-with，relaxed 操作只提供普通 coherence，不提供发布顺序。

FENCE.D 的 predecessor/successor 类别掩码就是可移植的传输与强度契约。
部分重叠继续 fail-closed，不定义字节撕裂、拼接或隐式合并。Atomic/RMW
对单一精确范围是不可分割的读写事件，并按 acquire/release 与 relaxed
分级，不为不同地址强行建立全局 SC 顺序。

标量 fault 精确到指令边界；Tile 请求在首 fault 前已完成的 beat 保留，
重放必须整条逻辑请求执行，不暴露内部 lane/cursor。flush 只丢弃未提交
事件和年轻工作，不能回滚已提交的 GM 或 Tile 效果。

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

ADR-MEM-0010 left cross-agent visibility, fence transport, mixed-size overlap,
cross-agent atomic ordering, and precise replay and flush outside the RC
baseline, while implementations, tests, and projections already assumed some
backend behavior at those boundaries. This decision closes them under one
PTO-owned contract so that scalar and Tile memory effects, atomics, fences, and
fault recovery share a single portable answer.

ADR-MEM-0010 将跨 agent 可见性、fence 传输、混合宽度重叠、跨 agent atomic 顺序
以及精确重放与 flush 留在 RC 基线之外，而实现、测试与投影在这些边界上已经默认
依赖某些后端行为。本决策用一份由 PTO 拥有的契约闭合这些边界，使标量与 Tile 的
内存效果、atomic、fence 和故障恢复共享同一个可移植答案。

### Detailed decision / 详细决策

GM is one multi-copy atomic domain. Every completed write to an exact byte range
takes one global coherence position and is observable by every agent in the
applicable shareability domain. A release write observed by an acquire read from
another agent establishes synchronizes-with, while relaxed operations carry no
publication order beyond ordinary coherence. Fence predecessor and successor
class masks are the portable transport and strength contract and order only the
matching classes within one agent. Partial overlap between distinct ranges fails
closed, and only exact address-and-size matches participate in the coherence
relation. Atomic and RMW events are indivisible read and write events for one
exact range in the same global coherence order, and fault, replay, and flush
remain precise at the owning architectural boundary.

GM 是单一 multi-copy atomic 域。对精确字节范围完成的写入只有一个全局 coherence
位置，可被适用共享域内的所有 agent 观察到。跨 agent 的 release 写被 acquire 读
到时建立 synchronizes-with，relaxed 操作除普通 coherence 外不提供发布顺序。
Fence 的 predecessor/successor 类别掩码是可移植的传输与强度契约，只对同一 agent
中匹配的类别排序。不同范围之间的部分重叠 fail-closed，只有地址与宽度完全一致的
访问才进入 coherence 关系。Atomic 与 RMW 对单一精确范围是不可分割的读写事件，
处于同一个全局 coherence 顺序中；故障、重放与 flush 在所属架构边界上保持精确。

### What changed / 改动内容

#### English

- Closed the six open memory-model clauses for cross-agent visibility, fence
  transport, mixed-size overlap, cross-agent atomics, replay, and flush.
- Added the multi-copy atomic GM coherence position, synchronizes-with, and
  fence class-mask contracts to the owning ASL units.
- Extended precise fault, retained-effect, whole-request replay, and
  committed-effect-preserving flush rules.
- Retargeted the concurrency AVS point to `MemoryExecutionAllowedRC` and removed
  the superseded TSO identifiers from metadata, tests, and evidence.

#### 中文

- 闭合跨 agent 可见性、fence 传输、混合宽度重叠、跨 agent atomic、重放与 flush 六个开放的内存模型条款。
- 在所属 ASL 单元中加入 multi-copy atomic 的 GM coherence 位置、synchronizes-with 与 fence 类别掩码契约。
- 扩展精确故障、保留已完成效果、整请求重放以及保留已提交效果的 flush 规则。
- 将并发 AVS 测试点改为 `MemoryExecutionAllowedRC`，并清除元数据、测试与证据中已被取代的 TSO 标识。

### Scope and boundaries / 范围与边界

This ADR owns cross-agent visibility, fence transport and strength, mixed-size
overlap, cross-agent atomic ordering, and precise replay and flush. It does not
change opcode or ABI encodings, does not define byte-level tearing, merge, or
value-assembly rules, and leaves repeated-target scatter order and backend cache
or interconnect mechanisms implementation-defined. It does not restate the
RC+S→S relaxed baseline owned by ADR-MEM-0010.

本 ADR 负责跨 agent 可见性、fence 传输与强度、混合宽度重叠、跨 agent atomic 顺序
以及精确重放与 flush。它不改变 opcode 或 ABI 编码，不定义字节级撕裂、拼接或取值
装配规则，并将重复目标的 scatter 顺序和后端缓存或互连机制保留为实现定义。它不
重述由 ADR-MEM-0010 负责的 RC+S→S 放松基线。

## Verification

Evidence covers multi-copy release/acquire visibility, relaxed negative cases,
mask transport and strength, partial-overlap rejection, exact-range atomic RMW,
and replay/flush retention of prior effects. `make pr-check`, `make repo-check`,
and `git diff --check` are required for the candidate.


## Issue #416 accepted architecture amendment (2026-11-11)

At baseline `42067d0f2890b8c013a868bd1247ebc6437b3179`, the delegated
architecture owner accepted Scalar ordinary and atomic/LR-SC request scope with
Private default; Tile/IndexedGenerated retain IntraCore. Strict equality of
scope and issuing domain is required, including same-PE cross-scope interactions.
Private identifies one PE; InterCore covers one PTO device. Scope selects portable
participation, not a cache tier, ordering mode, host coherence, or handoff.

The carrier is an independent 64-bit form preserving an original 16/32/48-bit
payload in bits[63:16]. Low-halfword mask/match is 0xf0ff/0x001f, scope[9:8]
is Private/IntraCore/InterCore/reserved, and inner-length[11:10] is
16/32/48/reserved. Padding is zero. Assembly uses .private/.intra/.inter.
Existing binaries retain their decode/default. One envelope retires once at TPC+8;
full fetch and recovery use the envelope. DMA/Prefetch and .brg are excluded.
This decision avoids stealing existing operand bits or losing compressed/HL
addressing behavior; current normative meaning belongs to the ASL/NDF owners.

Keep one physical memory. Scope-conformance checks reject portable proof claims
for overlapping, differently keyed access pairs involving a write, not hardware
execution. Initial writes are neutral. DMA retains explicit legacy provenance.
General program-order/fence/collective ordering remains independent. LR scope
is saved with PE context; actual matching-domain writes invalidate overlapping
64B reservations across active/inactive PE/Core contexts even without event capture.
Mismatched-scope SC deterministically takes the existing no-access miss path in
the reference model. Existing faults, CAS nonwrite, SC reporting and granule
rules remain; no additional progress promise is introduced.

Affected owners include memory events/relations, scalar request and decoder
transport, architecture dispatch, GM obligations/replay and PE reservation
contexts. Focused evidence must include real encoded ordinary/atomic effects,
Scalar/Tile/IndexedGenerated interaction, cross-Core InterCore communication,
capture-disabled reservation safety, malformed envelopes and legacy exclusions.
No Tile.InterCore, domain conversion, cache maintenance or host coherence is
added. Target release is unassigned; release evidence refresh and downstream
assembler/compiler/ASL-model integration remain release obligations. Issue #416
remains open until implementation/evidence acceptance. ADR-MEM-0010 remains
superseded historical rationale; this accepted topic owns the amendment.

### Software aliasing obligation and example / 软件别名义务与示例

When Scalar and fixed-IntraCore Tile or IndexedGenerated requests may access
the same bytes, software assigns compatible IntraCore scope to each covered
Scalar access. If software cannot prove the accessed ranges disjoint, it treats
them as potentially aliasing. In a Top-K pipeline, the named `output`, `lane`,
`num`, and `hist` ranges may be prepared, selected, ranked, or consumed through
combinations of Scalar, Tile, and IndexedGenerated accesses. A compiler or
runtime that cannot prove which of those ranges are disjoint treats the
uncertain pair as potentially aliasing and uses IntraCore for the participating
Scalar access, matching the fixed-IntraCore Tile or IndexedGenerated request.
This applies independently to each range: a Scalar range proved disjoint from
those requests need not use IntraCore for this reason, while `InterCore` alone
does not match Tile or IndexedGenerated. This example illustrates the software
aliasing obligation; the normative compatibility rule remains in
`SHAREABILITY-001`.

当 Scalar 与固定为 IntraCore 的 Tile 或 IndexedGenerated 请求可能访问相同
字节时，软件应为每个受支持的 Scalar 访问选择兼容的 IntraCore scope。如果无法
证明访问范围互不重叠，软件必须按可能别名处理。在 Top-K 流程中，命名的
`output`、`lane`、`num` 和 `hist` 范围可能通过 Scalar、Tile 和 IndexedGenerated
访问的不同组合进行准备、筛选、排序或读取。如果编译器或运行时无法证明这些
范围中哪些互不重叠，就应将不确定的范围对视为可能别名，并为参与访问的 Scalar
选择 IntraCore，以匹配固定为 IntraCore 的 Tile 或 IndexedGenerated 请求。此规则
分别适用于每个范围：已证明与这些请求互不重叠的 Scalar 范围无需因此选择
IntraCore，而单独选择 `InterCore` 不能与 Tile 或 IndexedGenerated 匹配。此例说明
软件别名义务；规范性的兼容规则仍由 `SHAREABILITY-001` 定义。
