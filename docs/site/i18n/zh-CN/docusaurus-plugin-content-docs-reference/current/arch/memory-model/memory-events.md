<!-- GENERATED FROM: asl/arch/memory-model/memory-events.asl -->
# Memory Events

**Normative ASL source:** `asl/arch/memory-model/memory-events.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-events-purpose role=purpose-scope -->
## 目的与范围

本单元定义内存模型其余部分据以推理的事件词汇：读与写的类别、共享位置、由两个掩码得到的栅栏强度，以及有界事件数组。

它带有四个已接受条款 `PTO-ARCH-MEMORY-MODEL-VISIBILITY-001`、`PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001`、`PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001` 与 `PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001`，另有一条 `PTO-REQ-MEMORY-RC-001` 注释，把事件上界称为验证基础设施。`MemoryEvent` 记录声明在 `asl/arch/data-types/memory-model.asl` 中，而不在这里。

<!-- PTO-READER-BLOCK: arch-memory-events-concepts role=concepts-state -->
## 事件类别、字段与类别掩码

- `MemoryEventIsRead` 对 `MemoryEvent_Load` 与 `MemoryEvent_Atomic` 为真；`MemoryEventIsWrite` 对 `MemoryEvent_InitialWrite`、`MemoryEvent_Store` 以及 `write_performed` 为真的原子事件为真。
- `MemoryEventsShareLocation` 要求 `address` 相等且 `size_bytes` 相等；`MemoryEventRangesOverlap` 对两个事件的地址与 `size_bytes` 调用 `RangesOverlap`，而 `MemoryEventPartialOverlap` 是重叠但不共享位置。
- `MemoryEventClass` 把 `MemoryEvent_Load` 映射到 `'0001'`，把两种存入类别映射到 `'0010'`，把 `MemoryEvent_Atomic` 映射到 `'0011'`，把 `MemoryEvent_Fence` 映射到 `Zeros{4}`。
- 两者都非零时 `MemoryFenceStrengthOf(predecessor, successor)` 返回 `MemoryFenceStrength_AcquireRelease`，仅 predecessor 非零时返回 `MemoryFenceStrength_Release`，仅 successor 非零时返回 `MemoryFenceStrength_Acquire`，两者都是 `Zeros{4}` 时返回 `MemoryFenceStrength_None`。
- `AddLoadEvent` 置 `write_performed = FALSE` 与置零的 `write_value`；`AddStoreEvent` 置 `write_performed = TRUE`、传给它的 rank 与置零的 `read_value`。
- `AddAtomicOutcomeEvent` 同时规范化 `read_value` 与 `write_value`；`AddDataFenceEvent` 固定 `address = Zeros{PTO_XLEN}`、`size_bytes = 1` 与 `order = MemoryOrder_AcquireRelease`。
- 它的状态是 `_MemoryEvents`、`_MemoryEventCount`、`_CurrentMemoryAgent` 与 `_MemoryEventCaptureEnabled`。

<!-- PTO-READER-BLOCK: arch-memory-events-rules role=rules-interactions -->
## 捕获生命周期

- `ResetMemoryExecution` 只把 `_MemoryEventCount = 0`，别的都不动。
- `StartMemoryEventCapture(agent)` 调用 `ResetMemoryExecution`，设置 `_CurrentMemoryAgent = agent` 与 `_MemoryEventCaptureEnabled = TRUE`。
- `SelectMemoryEventAgent(agent)` 只写 `_CurrentMemoryAgent`，因此它改变后续包装调用的代理，而不清空序列。
- `StopMemoryEventCapture` 把标志置假，数组与 `_CurrentMemoryAgent` 都维持原样。
- `AddMemoryEvent` 断言 `_MemoryEventCount < PTO_MODEL_MEMORY_EVENTS`，把记录存入当前计数处，递增计数并返回索引。它不查询 `_MemoryEventCaptureEnabled`；该检查位于上一层的原子性单元 `Record` 函数中，因此直接调用 `AddInitialWriteEvent` 或 `AddStoreEvent` 即使捕获关闭也会追加。
- `AddInitialWriteEvent` 总是存入 `agent = 0`、`order = MemoryOrder_Relaxed`、`read_from = 0` 与 `coherence_rank = 0`。

设计要点：`MemoryEventClass` 给原子事件 `'0011'`，即读类别与写类别的按位或，因为一条记录同时持有两侧。把 `'0011'` 写成 predecessor 或 successor 的栅栏会匹配原子事件，而排序单元中的 `MemoryFenceOrders` 只检验与掩码做 AND 之后非零。

设计要点：强度由掩码派生且从不存储，因为 `MemoryFenceStrengthOf` 只读它的实参；predecessor 掩码为 `'0000'` 的栅栏无法充当 release。

设计要点：`ResetMemoryExecution` 清的是计数而不是内容，而 `AddMemoryEvent` 先写槽再递增。每个读取者都以 `_MemoryEventCount` 为界扫描，因此计数之上的陈旧记录不可达，并会被后续追加覆写。

<!-- PTO-READER-BLOCK: arch-memory-events-boundaries role=boundaries -->
## 验证边界

`PTO_MODEL_MEMORY_EVENTS` 为 `16` 与 `PTO_MODEL_MEMORY_AGENTS` 为 `4` 这两个边界属于本候选执行模型，而不属于某个实现；`PTO-REQ-MEMORY-RC-001` 注释说的正是这一点。

条款 `PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001` 说 GM 位置是字节，本修订不定义字节级合并或撕裂，并且只有地址与大小都精确匹配的访问才参与可移植相干关系。本单元提供划出这条线的谓词 `MemoryEventsShareLocation` 与 `MemoryEventPartialOverlap`；排序单元中的 `MemoryCandidateExecutionValid` 对部分重叠失败关闭。

`MemoryEventClass` 对 `MemoryEvent_Fence` 返回 `Zeros{4}`：其源码注释记录说，模型记录数据事件，而指令与设备类别仍保留为显式的掩码空间，因此栅栏不给任何按位与检验贡献类别。

<!-- PTO-READER-BLOCK: arch-memory-events-example role=example-usage -->
## 非规范性捕获示例

`StartMemoryEventCapture(1)` 把代理设为 `1`、清零计数并使能捕获。`AddInitialWriteEvent(0x40, 8, 0x55)` 占据索引 `0`；`AddLoadEvent(1, 0x40, 8, 0x55, MemoryOrder_Acquire)` 占据索引 `1`，`_MemoryEventCount` 变为 `2`。

对这两条记录，`MemoryEventsShareLocation` 为真而 `MemoryEventPartialOverlap` 为假，因此它们描述同一个位置。地址 `0x44`、`size_bytes` 为 `8` 的 load 是重叠但不共享，`MemoryEventPartialOverlap` 对它报真。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-memory-events-related role=related-owners-navigation -->
## 相关拥有者

- `PTO-ARCH-DATA-TYPES-MEMORY-MODEL` 声明 `MemoryEvent` 记录、`MemoryEventKind`、`MemoryOrder` 与 `MemoryFenceStrength`。
- [地址空间](address-space.md) 提供 `ReadPhysicalMemoryByte`，`FetchPTOInstruction` 与写入都使用它。
- [原子性](atomicity.md) 为本单元追加的记录填入 `coherence_rank` 与 `read_from`。
- [排序](ordering.md) 消费这些谓词，以判定 `MemoryCandidateExecutionValid` 与 `MemoryExecutionAllowedRC`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/memory-events.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS","surface":"arch","classification":["memory-model","memory-events"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}
// PTO-REQ-MEMORY-RC-001: bounded executable candidate-execution checker for
// PTO relaxed consistency with preserved Store->Store order. The event bound
// is verification infrastructure, not an architectural limit on agents or
// executions.
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-VISIBILITY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// The portable GM domain is multi-copy atomic: one location has one global
// coherence order and a completed write may be observed by every applicable
// agent. Release/acquire pairs add a cross-agent synchronizes-with relation;
// relaxed operations retain atomicity/coherence only and do not publish a
// cross-agent ordering guarantee.
// NDF-END: PTO-ARCH-MEMORY-MODEL-VISIBILITY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Fence predecessor/successor class masks are the architecture-visible
// transport of fence strength. A fence orders only matching classes in the
// same agent; it does not silently acquire a stronger implementation fence or
// create a cross-agent relation without a matching release/acquire access.
// NDF-END: PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// GM locations are bytes, but this revision does not define byte-level merge or
// tearing for mixed-size accesses. Any partial overlap between distinct access
// ranges fails closed; only exact address-and-size matches participate in the
// portable coherence relation.
// NDF-END: PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// An atomic/RMW access to one exact byte range is one indivisible read/write
// event in the global coherence order. Acquire/release atomic pairs may
// synchronize across agents; relaxed atomics do not imply a global SC order for
// different locations.
// NDF-END: PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001

pure func MemoryEventIsRead(event: MemoryEvent) => boolean
begin
    return event.kind == MemoryEvent_Load || event.kind == MemoryEvent_Atomic;
end;

pure func MemoryEventIsWrite(event: MemoryEvent) => boolean
begin
    return event.kind == MemoryEvent_InitialWrite ||
           event.kind == MemoryEvent_Store ||
           (event.kind == MemoryEvent_Atomic && event.write_performed);
end;

pure func MemoryEventIsAccess(event: MemoryEvent) => boolean
begin
    return MemoryEventIsRead(event) || MemoryEventIsWrite(event);
end;

pure func MemoryEventRangesOverlap(left: MemoryEvent,
                                   right: MemoryEvent) => boolean
begin
    return RangesOverlap(left.address, left.size_bytes,
                         right.address, right.size_bytes);
end;

pure func MemoryFenceStrengthOf(predecessor: bits(4), successor: bits(4))
                                => MemoryFenceStrength
begin
    let has_predecessor = predecessor != Zeros{4};
    let has_successor = successor != Zeros{4};
    if has_predecessor && has_successor then
        return MemoryFenceStrength_AcquireRelease;
    elsif has_predecessor then
        return MemoryFenceStrength_Release;
    elsif has_successor then
        return MemoryFenceStrength_Acquire;
    else
        return MemoryFenceStrength_None;
    end;
end;

pure func MemoryEventsShareLocation(left: MemoryEvent,
                                    right: MemoryEvent) => boolean
begin
    return left.address == right.address && left.size_bytes == right.size_bytes;
end;

pure func MemoryEventPartialOverlap(left: MemoryEvent,
                                    right: MemoryEvent) => boolean
begin
    return MemoryEventRangesOverlap(left, right) &&
           !MemoryEventsShareLocation(left, right);
end;

pure func MemoryEventClass(event: MemoryEvent) => bits(4)
begin
    // FENCE.D mask bits are: data read, data write, device, and instruction.
    // The current candidate model contains data events; atomic events are both
    // reads and writes. Instruction and device classes remain explicit masks.
    case event.kind of
        when MemoryEvent_Load => return '0001';
        when MemoryEvent_Store, MemoryEvent_InitialWrite => return '0010';
        when MemoryEvent_Atomic => return '0011';
        when MemoryEvent_Fence => return Zeros{4};
    end;
end;

func ResetMemoryExecution()
begin
    _MemoryEventCount = 0;
end;

// Production event extraction is an explicit verification mode because the
// bounded event array is model-checking infrastructure, not an architectural
// execution limit. Manual candidate construction remains available while
// capture is disabled.
func StartMemoryEventCapture(agent: MemoryAgentId)
begin
    ResetMemoryExecution();
    _CurrentMemoryAgent = agent;
    _MemoryEventCaptureEnabled = TRUE;
end;

func SelectMemoryEventAgent(agent: MemoryAgentId)
begin
    _CurrentMemoryAgent = agent;
end;

func StopMemoryEventCapture()
begin
    _MemoryEventCaptureEnabled = FALSE;
end;

func AddMemoryEvent(event: MemoryEvent) => MemoryEventIndex
begin
    assert _MemoryEventCount < PTO_MODEL_MEMORY_EVENTS;
    let index = _MemoryEventCount as MemoryEventIndex;
    _MemoryEvents[[index]] = event;
    _MemoryEventCount = (_MemoryEventCount + 1) as
        integer {0..PTO_MODEL_MEMORY_EVENTS};
    return index;
end;

func AddInitialWriteEvent(address: Word, size_bytes: integer {1,2,4,8},
                          value: Word) => MemoryEventIndex
begin
    return AddMemoryEvent(MemoryEvent {
        kind = MemoryEvent_InitialWrite,
        agent = 0,
        address = address,
        size_bytes = size_bytes,
        read_value = Zeros{PTO_XLEN},
        write_value = NormalizeMemoryAccessValue(value, size_bytes),
        write_performed = TRUE,
        order = MemoryOrder_Relaxed,
        read_from = 0,
        coherence_rank = 0,
        fence_predecessor = Zeros{4},
        fence_successor = Zeros{4}
    });
end;

func AddLoadEvent(agent: MemoryAgentId, address: Word,
                  size_bytes: integer {1,2,4,8}, value: Word,
                  order: MemoryOrder) => MemoryEventIndex
begin
    return AddMemoryEvent(MemoryEvent {
        kind = MemoryEvent_Load,
        agent = agent,
        address = address,
        size_bytes = size_bytes,
        read_value = NormalizeMemoryAccessValue(value, size_bytes),
        write_value = Zeros{PTO_XLEN},
        write_performed = FALSE,
        order = order,
        read_from = 0,
        coherence_rank = 0,
        fence_predecessor = Zeros{4},
        fence_successor = Zeros{4}
    });
end;

func AddStoreEvent(agent: MemoryAgentId, address: Word,
                   size_bytes: integer {1,2,4,8}, value: Word,
                   order: MemoryOrder, rank: MemoryCoherenceRank)
                   => MemoryEventIndex
begin
    return AddMemoryEvent(MemoryEvent {
        kind = MemoryEvent_Store,
        agent = agent,
        address = address,
        size_bytes = size_bytes,
        read_value = Zeros{PTO_XLEN},
        write_value = NormalizeMemoryAccessValue(value, size_bytes),
        write_performed = TRUE,
        order = order,
        read_from = 0,
        coherence_rank = rank,
        fence_predecessor = Zeros{4},
        fence_successor = Zeros{4}
    });
end;

func AddAtomicEvent(agent: MemoryAgentId, address: Word,
                    size_bytes: integer {1,2,4,8}, read_value: Word,
                    write_value: Word, order: MemoryOrder,
                    rank: MemoryCoherenceRank) => MemoryEventIndex
begin
    return AddAtomicOutcomeEvent(agent, address, size_bytes, read_value,
        write_value, order, rank, TRUE);
end;

func AddAtomicOutcomeEvent(agent: MemoryAgentId, address: Word,
                           size_bytes: integer {1,2,4,8}, read_value: Word,
                           write_value: Word, order: MemoryOrder,
                           rank: MemoryCoherenceRank,
                           write_performed: boolean) => MemoryEventIndex
begin
    return AddMemoryEvent(MemoryEvent {
        kind = MemoryEvent_Atomic,
        agent = agent,
        address = address,
        size_bytes = size_bytes,
        read_value = NormalizeMemoryAccessValue(read_value, size_bytes),
        write_value = NormalizeMemoryAccessValue(write_value, size_bytes),
        write_performed = write_performed,
        order = order,
        read_from = 0,
        coherence_rank = rank,
        fence_predecessor = Zeros{4},
        fence_successor = Zeros{4}
    });
end;

func AddDataFenceEvent(agent: MemoryAgentId, predecessor: bits(4),
                       successor: bits(4)) => MemoryEventIndex
begin
    return AddMemoryEvent(MemoryEvent {
        kind = MemoryEvent_Fence,
        agent = agent,
        address = Zeros{PTO_XLEN},
        size_bytes = 1,
        read_value = Zeros{PTO_XLEN},
        write_value = Zeros{PTO_XLEN},
        write_performed = FALSE,
        order = MemoryOrder_AcquireRelease,
        read_from = 0,
        coherence_rank = 0,
        fence_predecessor = predecessor,
        fence_successor = successor
    });
end;
```
<!-- GENERATED-ASL-END: unit -->
