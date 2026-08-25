<!-- GENERATED FROM: asl/arch/memory-model/atomicity.asl -->
# Atomicity

**Normative ASL source:** `asl/arch/memory-model/atomicity.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ATOMICITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-atomicity-purpose role=purpose-scope -->
## 用途与范围

本单元把实际内存操作连接到有界候选执行事件模型。捕获启用时，它记录读取、存储、原子操作和数据栅栏，并维护逐位置的一致性与读自信息。

<!-- PTO-READER-BLOCK: arch-atomicity-concepts role=concepts-state -->
## 事件关系

- `NextMemoryCoherenceRank` 扫描地址和 `size_bytes` 相同的较早写事件，为新写事件分配下一个一致性序号。
- `ResolveCapturedReadFrom` 查找同一位置上较早且 `write_value` 等于已捕获 `read_value` 的写事件。
- `SetMemoryReadFrom` 检查两个事件索引都已存在后，写入所选来源索引。

<!-- PTO-READER-BLOCK: arch-atomicity-rules role=rules-interactions -->
## 记录规则

- 读取记录先加入事件序列，找到来源时再解析捕获的来源。
- 存储记录在发布前获得新的一致性序号。
- 原子操作记录只有在 `write_performed` 为真时才获得一致性序号；它仍会记录读取结果并尝试解析读自关系。
- 包装形式使用 `_CurrentMemoryAgent`；显式形式接收 `MemoryAgentId`。

<!-- PTO-READER-BLOCK: arch-atomicity-boundaries role=boundaries -->
## 边界

当 `_MemoryEventCaptureEnabled` 为假时，所有记录辅助函数都没有效果。捕获的来源依据较早事件、相同位置和相同值选择；完整的候选执行合法性判断仍由内存排序所有者负责。

<!-- PTO-READER-BLOCK: arch-atomicity-example role=example-usage -->
## 非规范事件示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-atomicity-related role=related-owners-navigation -->
## 相关所有者

- `PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS` 定义事件记录和捕获存储。
- 内存排序使用一致性与读自关系检查候选执行。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/atomicity.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ATOMICITY","surface":"arch","classification":["memory-model","atomicity"],"depends_on":["PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS"]}
readonly func NextMemoryCoherenceRank(address: Word,
                                      size_bytes: integer {1,2,4,8})
                                      => MemoryCoherenceRank
begin
    var next_rank: integer {1..PTO_MODEL_MEMORY_EVENTS} = 1;
    if _MemoryEventCount > 0 then
        for event_number = 0 to _MemoryEventCount - 1 do
            let event = _MemoryEvents[[event_number as MemoryEventIndex]];
            if MemoryEventIsWrite(event) && event.address == address &&
               event.size_bytes == size_bytes &&
               event.coherence_rank >= next_rank then
                next_rank = (event.coherence_rank + 1) as
                    integer {1..PTO_MODEL_MEMORY_EVENTS};
            end;
        end;
    end;
    assert next_rank < PTO_MODEL_MEMORY_EVENTS;
    return next_rank as MemoryCoherenceRank;
end;

func ResolveCapturedReadFrom(read: MemoryEventIndex)
begin
    let read_event = _MemoryEvents[[read]];
    var found = FALSE;
    var source: MemoryEventIndex = 0;
    if read > 0 then
        for candidate_number = 0 to read - 1 do
            let candidate_index = candidate_number as MemoryEventIndex;
            let candidate = _MemoryEvents[[candidate_index]];
            if MemoryEventIsWrite(candidate) &&
               MemoryEventsShareLocation(read_event, candidate) &&
               candidate.write_value == read_event.read_value then
                found = TRUE;
                source = candidate_index;
            end;
        end;
    end;
    if found then SetMemoryReadFrom(read, source); end;
end;

func RecordLoadEvent(address: Word, size_bytes: integer {1,2,4,8},
                     value: Word, order: MemoryOrder)
begin
    RecordLoadEventForAgent(_CurrentMemoryAgent, address, size_bytes, value,
        order);
end;

func RecordLoadEventForAgent(agent: MemoryAgentId, address: Word,
                             size_bytes: integer {1,2,4,8}, value: Word,
                             order: MemoryOrder)
begin
    if _MemoryEventCaptureEnabled then
        let event = AddLoadEvent(agent, address, size_bytes,
            value, order);
        ResolveCapturedReadFrom(event);
    end;
end;

func RecordStoreEvent(address: Word, size_bytes: integer {1,2,4,8},
                      value: Word, order: MemoryOrder)
begin
    RecordStoreEventForAgent(_CurrentMemoryAgent, address, size_bytes, value,
        order);
end;

func RecordStoreEventForAgent(agent: MemoryAgentId, address: Word,
                              size_bytes: integer {1,2,4,8}, value: Word,
                              order: MemoryOrder)
begin
    if _MemoryEventCaptureEnabled then
        - = AddStoreEvent(agent, address, size_bytes, value,
            order, NextMemoryCoherenceRank(address, size_bytes));
    end;
end;

func RecordAtomicEvent(address: Word, size_bytes: integer {1,2,4,8},
                       read_value: Word, write_value: Word,
                       order: MemoryOrder, write_performed: boolean)
begin
    if _MemoryEventCaptureEnabled then
        let rank = if write_performed then
            NextMemoryCoherenceRank(address, size_bytes) else 0;
        let event = AddAtomicOutcomeEvent(_CurrentMemoryAgent, address,
            size_bytes, read_value, write_value, order,
            rank as MemoryCoherenceRank, write_performed);
        ResolveCapturedReadFrom(event);
    end;
end;

func RecordDataFenceEvent(predecessor: bits(4), successor: bits(4))
begin
    if _MemoryEventCaptureEnabled then
        - = AddDataFenceEvent(_CurrentMemoryAgent, predecessor, successor);
    end;
end;

func SetMemoryReadFrom(read: MemoryEventIndex, source: MemoryEventIndex)
begin
    assert read < _MemoryEventCount && source < _MemoryEventCount;
    _MemoryEvents[[read]].read_from = source;
end;
```
<!-- GENERATED-ASL-END: unit -->
