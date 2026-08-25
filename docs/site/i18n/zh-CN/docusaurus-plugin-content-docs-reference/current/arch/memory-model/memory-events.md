<!-- GENERATED FROM: asl/arch/memory-model/memory-events.asl -->
# Memory Events

**Normative ASL source:** `asl/arch/memory-model/memory-events.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-events-purpose role=purpose-scope -->
## 用途与范围

本单元定义用于构造和检查 PTO 全存储排序候选执行的有界事件记录。它既支持显式构造事件，也支持从实际内存辅助函数进行可选捕获。

<!-- PTO-READER-BLOCK: arch-memory-events-concepts role=concepts-state -->
## 事件种类与字段

- 读取和原子操作属于读；初始写入、存储以及执行写入的原子操作属于写。
- 两个事件只有在地址和 `size_bytes` 都相同时才共享一个位置。
- 数据事件类别使用 `0001` 表示读，`0010` 表示写，`0011` 表示原子操作；栅栏事件另行携带前驱与后继掩码。

<!-- PTO-READER-BLOCK: arch-memory-events-rules role=rules-interactions -->
## 捕获生命周期

- `StartMemoryEventCapture` 重置序列、选择一个 `MemoryAgentId` 并启用捕获。
- `SelectMemoryEventAgent` 修改后续包装函数使用的代理。
- `StopMemoryEventCapture` 禁用自动记录，但不会删除已捕获序列。
- `AddMemoryEvent` 追加一个事件并推进 `_MemoryEventCount`；专用辅助函数会在追加前规范化访问值。

<!-- PTO-READER-BLOCK: arch-memory-events-boundaries role=boundaries -->
## 验证边界

事件数组边界与 `PTO_MODEL_MEMORY_EVENTS` 断言属于模型检查基础设施。它们不对真实执行中的代理数量或执行长度施加架构限制。尽管当前候选模型记录数据事件，指令与设备栅栏类别仍保留显式掩码空间。

<!-- PTO-READER-BLOCK: arch-memory-events-example role=example-usage -->
## 非规范捕获示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-memory-events-related role=related-owners-navigation -->
## 相关所有者

- 地址空间辅助函数为产生事件的操作提供底层有界字节存储。
- 原子性单元分配一致性与读自数据；排序单元评估完整候选执行。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/memory-events.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS","surface":"arch","classification":["memory-model","memory-events"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}
// PTO-REQ-MEMORY-TSO-001: bounded executable candidate-execution checker for
// PTO total store order. The event bound is verification infrastructure, not
// an architectural limit on agents or executions.

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

pure func MemoryEventsShareLocation(left: MemoryEvent,
                                    right: MemoryEvent) => boolean
begin
    return left.address == right.address && left.size_bytes == right.size_bytes;
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
