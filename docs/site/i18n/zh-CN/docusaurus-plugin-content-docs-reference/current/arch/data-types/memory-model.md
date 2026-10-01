<!-- GENERATED FROM: asl/arch/data-types/memory-model.asl -->
# Memory Model

**Normative ASL source:** `asl/arch/data-types/memory-model.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-MEMORY-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-model-types-purpose-scope role=purpose-scope -->
## 目的与范围

本单元定义用于表示数据访问探测、内存顺序、内存事件以及内存请求重放状态的类型化记录与枚举。

它提供可执行内存所有者消费的词汇，本身不决定一次完整执行是否被接受。

<!-- PTO-READER-BLOCK: arch-memory-model-types-concepts-state role=concepts-state -->
## 概念与可见状态

`DataAccessProbe` 把 `FaultCode` 与转换后的 `Word` 地址组合起来，`MemoryReplayState` 记录重放是否处于活动状态、请求字、已提交事件数和纪元。

`MemoryOrder` 区分 `MemoryOrder_Relaxed`、`MemoryOrder_Acquire`、`MemoryOrder_Release` 和 `MemoryOrder_AcquireRelease`；`MemoryEventKind` 区分 `MemoryEvent_InitialWrite`、`MemoryEvent_Load`、`MemoryEvent_Store`、`MemoryEvent_Atomic` 和 `MemoryEvent_Fence`。

`MemoryEvent` 记录类别、执行体、地址、访问大小、读值与写值、是否执行写入、顺序、读自事件索引、一致性序位，以及屏障前驱和后继掩码。

<!-- PTO-READER-BLOCK: arch-memory-model-types-rules-interactions role=rules-interactions -->
## 规则与交互

设计要点：加载和存储都带有读值字段与写值字段，因此一种记录形状就能表达只读的加载、只写的存储和两者兼做的原子操作，而不需要三种记录。

内存事件大小只能是 `1`、`2`、`4` 或 `8` 字节，因此被建模的访问宽度总是这四种之一。

`MemoryShareability` 区分 `MemoryShareability_Private`、`MemoryShareability_IntraCore` 和 `MemoryShareability_InterCore`，`MemoryFenceStrength` 由一对掩码导出无、释放、获取或获取释放强度。

<!-- PTO-READER-BLOCK: arch-memory-model-types-boundaries role=boundaries -->
## 架构边界

执行体 ID、事件索引和一致性序位分别受 `PTO_MODEL_MEMORY_AGENTS` 与 `PTO_MODEL_MEMORY_EVENTS` 限定，`MemoryRelationMatrix` 为每个被建模事件保存一行 `bits(PTO_MODEL_MEMORY_EVENTS)`。

设计要点：共享性被表述为架构可见的分类，而不是缓存或互连层级，因此调用方推理的是谁观察到某次访问，而不是某种具体内存层次。

本单元只声明类型，没有函数，因此这里没有任何内容会在运行时求值：接受或拒绝一次完整执行的检查由内存排序单元拥有。

<!-- PTO-READER-BLOCK: arch-memory-model-types-example-usage role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

这些声明只描述表示形式，不描述排序接受条件；程序顺序、读自有效性、一致性、屏障和环检测属于内存排序 ASL。

`active` 为 false 的 `MemoryReplayState` 是重放结束之后留下的状态，因此调用方不得把重放窗口当作仍在进行。

<!-- PTO-READER-BLOCK: arch-memory-model-types-related-owners role=related-owners-navigation -->
## 相关归属单元

- [内存排序](../memory-model/ordering.md)消费这些事件记录。

- [内存操作选择器](memory-operations.md)命名原子操作与地址更新选择器。

- [整数类型](integer.md)定义这些记录使用的 `Word` 地址载体。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/memory-model.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-MEMORY-MODEL","surface":"arch","classification":["data-types","memory-model"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES"]}
type DataAccessProbe of record {
    fault: FaultCode,
    translated_address: Word
};

type MemoryOrder of enumeration {
    MemoryOrder_Relaxed,
    MemoryOrder_Acquire,
    MemoryOrder_Release,
    MemoryOrder_AcquireRelease
};

// Shareability is an architecture-visible classification used by the memory
// model.  It is deliberately independent of any cache or interconnect tier.
type MemoryShareability of enumeration {
    MemoryShareability_Private,
    MemoryShareability_IntraCore,
    MemoryShareability_InterCore
};

// Fences carry their predecessor/successor class masks as the portable
// transport contract.  Strength is derived from the pair of masks rather than
// from an implementation-specific opcode encoding.
type MemoryFenceStrength of enumeration {
    MemoryFenceStrength_None,
    MemoryFenceStrength_Release,
    MemoryFenceStrength_Acquire,
    MemoryFenceStrength_AcquireRelease
};

type MemoryAgentId of integer {0..PTO_MODEL_MEMORY_AGENTS-1};
type MemoryEventIndex of integer {0..PTO_MODEL_MEMORY_EVENTS-1};
type MemoryCoherenceRank of integer {0..PTO_MODEL_MEMORY_EVENTS-1};

type MemoryEventKind of enumeration {
    MemoryEvent_InitialWrite,
    MemoryEvent_Load,
    MemoryEvent_Store,
    MemoryEvent_Atomic,
    MemoryEvent_Fence
};

type MemoryEvent of record {
    kind: MemoryEventKind,
    agent: MemoryAgentId,
    address: Word,
    size_bytes: integer {1,2,4,8},
    read_value: Word,
    write_value: Word,
    write_performed: boolean,
    order: MemoryOrder,
    read_from: MemoryEventIndex,
    coherence_rank: MemoryCoherenceRank,
    fence_predecessor: bits(4),
    fence_successor: bits(4)
};

type MemoryRelationMatrix of array [[PTO_MODEL_MEMORY_EVENTS]]
    of bits(PTO_MODEL_MEMORY_EVENTS);

type MemoryReplayState of record {
    active: boolean,
    request: Word,
    committed_event_count: integer {0..PTO_MODEL_MEMORY_EVENTS},
    epoch: integer
};
```
<!-- GENERATED-ASL-END: unit -->
