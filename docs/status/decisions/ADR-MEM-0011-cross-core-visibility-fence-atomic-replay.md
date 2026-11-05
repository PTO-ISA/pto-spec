---
{
  "id": "ADR-MEM-0011",
  "title": "Cross-agent visibility, fence transport, atomic ordering, and precise replay",
  "title_zh": "跨 agent 可见性、fence 传输、atomic 顺序与精确重放",
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
    "PTO-TLOAD-MEMORY-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-TSTORE-STRIDED-ATOMIC-RED-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-INDEXED-TLSU-STRIDE-001",
    "PTO-INDEXED-TLSU-RANGE-BINDING-001",
    "PTO-ATOM-RED-BODY-SCHEMA-001",
    "PTO-ATOM-RED-ENCODING-001",
    "PTO-ATOM-RED-TYPE-LEGALITY-001",
    "PTO-ATOM-RED-ORDERING-001",
    "PTO-ATOM-RED-FAULTS-001",
    "PTO-ATOM-RED-POPC-SEMANTICS-001",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001",
    "PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001",
    "PTO-ARCH-PE-EXECUTION-CONTEXT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-MEMORY-MODEL",
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TSTORE",
    "PTO-TILE-MODEL-MEMORY-ADDRESSING",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION",
    "PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED",
    "PTO-BLOCK-BSTART-MGATHER-ADD",
    "PTO-BLOCK-BSTART-MGATHER-AND",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-DEC",
    "PTO-BLOCK-BSTART-MGATHER-EXCH",
    "PTO-BLOCK-BSTART-MGATHER-INC",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MGATHER-MAX",
    "PTO-BLOCK-BSTART-MGATHER-MIN",
    "PTO-BLOCK-BSTART-MGATHER-OR",
    "PTO-BLOCK-BSTART-MGATHER-XOR",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MSCATTER-ADD",
    "PTO-BLOCK-BSTART-MSCATTER-AND",
    "PTO-BLOCK-BSTART-MSCATTER-DEC",
    "PTO-BLOCK-BSTART-MSCATTER-INC",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER-MAX",
    "PTO-BLOCK-BSTART-MSCATTER-MIN",
    "PTO-BLOCK-BSTART-MSCATTER-OR",
    "PTO-BLOCK-BSTART-MSCATTER-POPC",
    "PTO-BLOCK-BSTART-MSCATTER-XOR",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-ADD",
    "PTO-TILE-MGATHER-AND",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-DEC",
    "PTO-TILE-MGATHER-EXCH",
    "PTO-TILE-MGATHER-INC",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MGATHER-MAX",
    "PTO-TILE-MGATHER-MIN",
    "PTO-TILE-MGATHER-OR",
    "PTO-TILE-MGATHER-XOR",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-ADD",
    "PTO-TILE-MSCATTER-AND",
    "PTO-TILE-MSCATTER-DEC",
    "PTO-TILE-MSCATTER-INC",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-MSCATTER-MAX",
    "PTO-TILE-MSCATTER-MIN",
    "PTO-TILE-MSCATTER-OR",
    "PTO-TILE-MSCATTER-POPC",
    "PTO-TILE-MSCATTER-XOR",
    "PTO-ARCH-STATE-PE-EXECUTION-CONTEXT",
    "PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT",
    "PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-COMMAND-STREAM"
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
      "date": "2026-11-05",
      "baseline": "274d095260527a9a6a8991b26f8308f7713c253b",
      "approvers": [
        "ckwllawliet"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/414#issuecomment-6659291521",
      "affected_ndf": [
        "PTO-ARCH-MEMORY-MODEL-RANGE-001",
        "PTO-ARCH-MEMORY-MODEL-CONFLICT-001",
        "PTO-ARCH-MEMORY-MODEL-RC-001",
        "PTO-ARCH-MEMORY-MODEL-ATOMIC-001",
        "PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001",
        "PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001",
        "PTO-ARCH-MEMORY-MODEL-REPLAY-001",
        "PTO-ARCH-MEMORY-MODEL-FLUSH-001",
        "PTO-B-IOR-BINDING-001",
        "PTO-INDEXED-TLSU-STRIDE-001",
        "PTO-INDEXED-TLSU-RANGE-BINDING-001",
        "PTO-ATOM-RED-BODY-SCHEMA-001",
        "PTO-ATOM-RED-ENCODING-001",
        "PTO-ATOM-RED-TYPE-LEGALITY-001",
        "PTO-ATOM-RED-ORDERING-001",
        "PTO-ATOM-RED-FAULTS-001",
        "PTO-ATOM-RED-POPC-SEMANTICS-001",
        "PTO-MGATHER-CAS-ATOMIC-001",
        "PTO-MGATHER-CAS-PUBLICATION-001",
        "PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001",
        "PTO-ARCH-PE-EXECUTION-CONTEXT-001"
      ],
      "affected_units": [
        "PTO-ARCH-MEMORY-MODEL-ORDERING",
        "PTO-TILE-MODEL-MEMORY-ADDRESSING",
        "PTO-BLOCK-B-IOR",
        "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
        "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
        "PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION",
        "PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED",
        "PTO-BLOCK-BSTART-MGATHER-ADD",
        "PTO-BLOCK-BSTART-MGATHER-AND",
        "PTO-BLOCK-BSTART-MGATHER-CAS",
        "PTO-BLOCK-BSTART-MGATHER-DEC",
        "PTO-BLOCK-BSTART-MGATHER-EXCH",
        "PTO-BLOCK-BSTART-MGATHER-INC",
        "PTO-BLOCK-BSTART-MGATHER-MASK",
        "PTO-BLOCK-BSTART-MGATHER-MAX",
        "PTO-BLOCK-BSTART-MGATHER-MIN",
        "PTO-BLOCK-BSTART-MGATHER-OR",
        "PTO-BLOCK-BSTART-MGATHER-XOR",
        "PTO-BLOCK-BSTART-MGATHER",
        "PTO-BLOCK-BSTART-MSCATTER-ADD",
        "PTO-BLOCK-BSTART-MSCATTER-AND",
        "PTO-BLOCK-BSTART-MSCATTER-DEC",
        "PTO-BLOCK-BSTART-MSCATTER-INC",
        "PTO-BLOCK-BSTART-MSCATTER-MASK",
        "PTO-BLOCK-BSTART-MSCATTER-MAX",
        "PTO-BLOCK-BSTART-MSCATTER-MIN",
        "PTO-BLOCK-BSTART-MSCATTER-OR",
        "PTO-BLOCK-BSTART-MSCATTER-POPC",
        "PTO-BLOCK-BSTART-MSCATTER-XOR",
        "PTO-BLOCK-BSTART-MSCATTER",
        "PTO-TILE-MGATHER",
        "PTO-TILE-MGATHER-ADD",
        "PTO-TILE-MGATHER-AND",
        "PTO-TILE-MGATHER-CAS",
        "PTO-TILE-MGATHER-DEC",
        "PTO-TILE-MGATHER-EXCH",
        "PTO-TILE-MGATHER-INC",
        "PTO-TILE-MGATHER-MASK",
        "PTO-TILE-MGATHER-MAX",
        "PTO-TILE-MGATHER-MIN",
        "PTO-TILE-MGATHER-OR",
        "PTO-TILE-MGATHER-XOR",
        "PTO-TILE-MSCATTER",
        "PTO-TILE-MSCATTER-ADD",
        "PTO-TILE-MSCATTER-AND",
        "PTO-TILE-MSCATTER-DEC",
        "PTO-TILE-MSCATTER-INC",
        "PTO-TILE-MSCATTER-MASK",
        "PTO-TILE-MSCATTER-MAX",
        "PTO-TILE-MSCATTER-MIN",
        "PTO-TILE-MSCATTER-OR",
        "PTO-TILE-MSCATTER-POPC",
        "PTO-TILE-MSCATTER-XOR",
        "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
        "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
        "PTO-ARCH-STATE-PE-EXECUTION-CONTEXT",
        "PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA",
        "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
        "PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT",
        "PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS",
        "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
        "PTO-BLOCK-MODEL-STATE-TYPES",
        "PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-COMMAND-STREAM"
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

## 2026-11-05 accepted amendment — indexed TLSU range descriptor (Issue #414)

This amendment records the Issue #414 decision at the immutable 2026-11-05 baseline `274d095260527a9a6a8991b26f8308f7713c253b` ([accepted decision comment](https://github.com/PTO-ISA/pto-spec/issues/414#issuecomment-6659291521)). It replaces the prior one-sided signed 32-bit `index_limit` wording under `PTO-ARCH-MEMORY-MODEL-RANGE-001` with an optional pair of full-width S64 relative byte-displacement bounds for every indexed TLSU request, including ordinary, masked, CAS, atomic gather/reduction, and POPC forms.

A present descriptor describes the half-open mathematical byte interval `[UInt64(BaseGPR)+SInt64(MinIndexGPR), UInt64(BaseGPR)+SInt64(MaxIndexGPR)+AccessBytes)`. `AccessBytes` is the existing transaction width (1, 2, 4, or 8 bytes); packed four-bit ordinary transfer uses one containing byte and `MSCATTER.POPC` uses its existing four-byte U32 operation. Software certifies coverage of every participating active access start and every byte of each transaction, signed-bound representability, and nonwrapping endpoints. Hardware need not compare every IndexTile value against the declaration. Absence preserves conservative dependence handling. Comparisons are mathematical and may rule out only conflict edges already permitted by PTO-RC; uncertain translation aliases fail closed and never change exact memory-event addresses.

A present `MinIndex > MaxIndex` faults with `Fault_TileLegality` only for the current participating PE request, before that request's indexed memory or destination effects. Existing peer commits and progress remain. Each PE reads its own bounds when its request reaches the established operand boundary; the contract adds no rendezvous, peer sampling, rollback, or architectural range state. Atomic/RMW, Store-to-Store, fence, acquire/release, dependency, coherence, replay, shareability, and visibility rules remain unchanged.

The rejected alternatives were a one-sided limit, absolute rather than Base-relative bounds, hardware per-index certification checks, a new opcode/immediate encoding, treating the range as an ordering qualifier, and group-wide preflight or rollback. Compatibility retains all indexed instruction encodings, Base-only B.IOR, the legacy single-record GPR ExecutionMask form, existing IndexTile byte-displacement behavior, and exact MemoryEvent identity. The BLOCK schema and all affected BSTART/Tile operation owners carry the field interpretation; this MEM amendment owns range arithmetic, software certification, conservative alias fallback, and the local fault/order constraints.

Release impact is `required`; the target for this delta remains `unassigned`. The downstream SSM/compiler carrier work and the separate `order_after_prior` / `order_before_later` encoding gap remain tracked follow-ups and are not claimed complete by this PTO-Spec change.
