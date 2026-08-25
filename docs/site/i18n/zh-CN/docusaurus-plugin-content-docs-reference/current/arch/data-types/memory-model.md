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

本单元定义表示数据访问探测、内存顺序、内存事件和事件关系所需的记录与枚举。

这些类型为可执行的内存归属单元提供统一词汇，但本身不决定一个完整执行是否可接受。

<!-- PTO-READER-BLOCK: arch-memory-model-types-concepts-state role=concepts-state -->
## 概念与可见状态

- `DataAccessProbe` 将 `FaultCode` 与转换后的 `Word` 地址组成一条记录。
- `MemoryOrder` 区分 `Relaxed`、`Acquire`、`Release` 和 `AcquireRelease`；`MemoryEventKind` 区分初始写、加载、存储、原子操作和屏障事件。
- `MemoryEvent` 记录执行体、地址、大小、读写值、是否执行写入、顺序、读自索引、一致性序位以及屏障前驱/后继掩码。

<!-- PTO-READER-BLOCK: arch-memory-model-types-rules-interactions role=rules-interactions -->
## 规则与交互

内存事件大小只能是 `1`、`2`、`4` 或 `8` 字节。

执行体 ID、事件索引和一致性序位分别受 `PTO_MODEL_MEMORY_AGENTS` 与 `PTO_MODEL_MEMORY_EVENTS` 限定。

`MemoryRelationMatrix` 为每个建模事件保存一行关系，其类型为 `bits(PTO_MODEL_MEMORY_EVENTS)`。

<!-- PTO-READER-BLOCK: arch-memory-model-types-boundaries role=boundaries -->
## 架构边界

这些声明只规定表示形式，不规定排序接受条件。程序顺序、读自有效性、一致性、屏障和环检测由内存排序 ASL 归属单元定义。

`PTO_MODEL_MEMORY_EVENTS` 是模型边界，不是硬件可移植的最大事件数。

<!-- PTO-READER-BLOCK: arch-memory-model-types-example-usage role=example-usage -->
## 非规范阅读示例

`MemoryEvent_Load` 条目通过 `read_from` 携带来源；执行写入的事件通过 `coherence_rank` 携带一致性序位。排序归属单元会在完整关系集合中验证这两个字段。

调试内存结果时，应先检查事件记录，再沿其中的索引查看排序归属单元构建的关系矩阵。

<!-- PTO-READER-BLOCK: arch-memory-model-types-related-owners role=related-owners-navigation -->
## 相关归属单元

- [内存排序](../memory-model/ordering.md)
- [内存操作选择器](memory-operations.md)
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
```
<!-- GENERATED-ASL-END: unit -->
