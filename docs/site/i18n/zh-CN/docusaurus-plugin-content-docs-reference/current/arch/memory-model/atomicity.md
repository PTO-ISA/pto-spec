<!-- GENERATED FROM: asl/arch/memory-model/atomicity.asl -->
# Atomicity

**Normative ASL source:** `asl/arch/memory-model/atomicity.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ATOMICITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-atomicity-purpose role=purpose-scope -->
## 目的与范围

本单元在真实内存操作与有界候选执行事件数组之间架桥，补齐原始事件记录不携带的字段：每位置相干序 rank、reads-from 来源索引与栅栏类别掩码，并拥有四个生产记录入口。

本单元自身没有 `NDF-BEGIN` 条款：它唯一内嵌的元数据是第 1 行的 `PTO-UNIT` JSON，其中声明 `PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS` 为其依赖。

<!-- PTO-READER-BLOCK: arch-atomicity-concepts role=concepts-state -->
## 三个派生字段

- `NextMemoryCoherenceRank` 遍历 `_MemoryEventCount` 以下的每个事件槽，返回同一 `address` 与 `size_bytes` 的写入所持有的最大 `coherence_rank` 加一。
- `ResolveCapturedReadFrom` 遍历事件槽 `0` 到 `read - 1`，保留最后一个位置匹配且 `write_value` 等于该读的 `read_value` 的写入。
- `SetMemoryReadFrom` 断言 `read < _MemoryEventCount && source < _MemoryEventCount`，并赋值 `_MemoryEvents[[read]].read_from = source`。
- `MemoryEventIsWrite` 计入 `MemoryEvent_InitialWrite`、`MemoryEvent_Store`，以及 `write_performed` 为真的 `MemoryEvent_Atomic`，因此初始写入虽然携带 rank `0`，也参与 rank 分配。
- 每个 `Word` 值字段都经 `NormalizeMemoryAccessValue` 存入：`size_bytes` 为 `1`、`2`、`4` 时分别零扩展 `value[7:0]`、`value[15:0]`、`value[31:0]`，八字节值原样通过。

<!-- PTO-READER-BLOCK: arch-atomicity-rules role=rules-interactions -->
## 每个记录入口做什么

- `RecordLoadEventForAgent` 追加一个 load 事件，然后对新索引调用 `ResolveCapturedReadFrom`。
- `RecordStoreEventForAgent` 计算 `NextMemoryCoherenceRank(address, size_bytes)` 并把它传给 `AddStoreEvent`。
- `RecordAtomicEvent` 仅在 `write_performed` 为真时计算 rank，否则传 `0`；它通过 `AddAtomicOutcomeEvent` 追加，然后调用 `ResolveCapturedReadFrom`。
- `RecordDataFenceEvent` 用两个 `bits(4)` 掩码追加一个 fence 事件，不做 rank 分配，也不做来源解析。
- `RecordLoadEvent`、`RecordStoreEvent` 与 `RecordAtomicEvent` 是一行包装，它们代入 `_CurrentMemoryAgent`。

设计要点：返回的 rank 是同一 `address` 与 `size_bytes` 上最大 rank 加一，因此 rank 从不复用。rank `k` 的写入只有在 rank `k - 1` 的写入仍留在数组中时才有前驱；`FlushMemoryReplay` 截断该序列之后，该前驱可能消失，`MemoryCandidateExecutionValid` 就会拒绝该候选。

设计要点：`ResolveCapturedReadFrom` 比较的是值而不是顺序标注，并保留最后一个匹配，因此取值等于更早的同位置写入的 load 即使在 `MemoryOrder_Relaxed` 下也从那次写入读取。当什么都匹配不到时，`read_from` 保留其 `0`，而槽 `0` 是否存放匹配的写入由 `MemoryCandidateExecutionValid` 决定。

设计要点：`RecordAtomicEvent` 给未执行的原子写入 rank `0` 而不分配新 rank，因为 `NextMemoryCoherenceRank` 只在 `write_performed` 分支中运行。失败的 compare-and-swap 仍占用一个事件槽，其读侧仍被解析，但它不会取走该位置下一次真实写入将使用的 rank。

<!-- PTO-READER-BLOCK: arch-atomicity-boundaries role=boundaries -->
## 边界

本单元只决定被捕获的读指向哪个来源；候选执行是否合法由排序单元中的 `MemoryCandidateExecutionValid` 与 `MemoryExecutionAllowedRC` 决定，它们自己会重新检查来源索引、位置与取值相等。

`NextMemoryCoherenceRank` 断言 `next_rank < PTO_MODEL_MEMORY_EVENTS`，因此一个需要等于该上界的 rank 的序列会让模型运行失败，而不是复用某个 rank。`PTO_MODEL_MEMORY_EVENTS` 为 `16`，所以能返回的最大 rank 是 `15`；若某位置的写入占满 rank `0` 到 `15`，该位置的下一次 store 就会让这条断言失败；该限制属于有界事件数组，而不属于排序规则。

当 `_MemoryEventCaptureEnabled` 为假时，这里的每个函数都直接返回，不触及 `_MemoryEvents` 或 `_MemoryEventCount`，因此在捕获会话之外的生产执行不记录任何内容。

<!-- PTO-READER-BLOCK: arch-atomicity-example role=example-usage -->
## 非规范性捕获示例

在一次 `StartMemoryEventCapture(0)` 会话之内，`0x40` 只有初始写入，随后跟一次 `0x55` 的 store。初始写入取 rank `0`，`NextMemoryCoherenceRank(0x40, 8)` 为该 store 返回 `1`，因此该位置上的两次写入携带 `0` 与 `1`。

之后一次读取 `0x55` 的 `0x40` load 解析到该 store 的索引，即最后一个位置与取值都匹配的更早写入；若读到 `0x66` 则什么都匹配不到，于是 `read_from` 保持为 `0`。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-atomicity-related role=related-owners-navigation -->
## 相关拥有者

- [内存事件](memory-events.md) 定义 `MemoryEvent` 记录、事件数组、捕获标志以及追加助手。
- [排序](ordering.md) 在判定候选执行是否被允许时消费 `coherence_rank` 与 `read_from`。
- [故障精确性](fault-precision.md) 拥有重放状态，由它决定这些记录在故障后能存活多少。
- 生产调用者例如包括 `asl/scalar/model/amo/semantics.asl`、`asl/tile/model/memory/load-store.asl` 与 `asl/tile/model/memory/gather-scatter.asl`。
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
