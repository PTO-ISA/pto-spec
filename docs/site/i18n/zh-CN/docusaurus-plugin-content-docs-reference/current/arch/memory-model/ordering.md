<!-- GENERATED FROM: asl/arch/memory-model/ordering.asl -->
# Ordering

**Normative ASL source:** `asl/arch/memory-model/ordering.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ORDERING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-ordering-purpose-scope role=purpose-scope -->
## 用途与范围

本单元决定一个已捕获的候选内存执行是否被 PTO-TSO 允许。它验证事件集合、构建必需的排序关系，并拒绝必需关系中存在环的任何候选执行。

最终查询 `MemoryExecutionAllowedTSO` 同时要求候选执行有效，并要求同一位置的执行关系和外部可见的保序关系都无环。

<!-- PTO-READER-BLOCK: arch-memory-ordering-concepts-state role=concepts-state -->
## 事件关系

- 一致性关系（coherence）按递增的 `coherence_rank` 排序同一位置上的写；读自关系（reads-from）把一次写连接到 `read_from` 字段指向该写的读。
- 外部读自关系（external reads-from）只保留两类读：其来源写是初始写，或者来源写与该读属于不同的内存主体；读后关系（from-read）把一次读连接到它所观察写之后的另一个一致性后继写。
- 同一内存主体在一个位置上的程序顺序，以及跨位置的保留程序顺序，构成两个无环检查所使用的程序顺序视图。
- 只有当屏障位于同一内存主体的两个事件之间，并且两个事件类别分别匹配其前驱掩码和后继掩码时，该屏障才会贡献一条边。

<!-- PTO-READER-BLOCK: arch-memory-ordering-rules-interactions role=rules-interactions -->
## 候选执行规则

每个被访问的位置恰好有一个初始写事件，并且每个初始写的 coherence rank 都是 `0`。

同一位置上的每个后续写都具有唯一的非零 coherence rank，并且在前一 rank 上存在直接前驱。

每个读都指向一个范围内、同位置的写，并携带该来源写入的值。成功的原子写在一致性顺序中紧接其读取来源。

PTO-TSO 保留“读到后续内存操作”和“内存操作到后续写”的程序顺序。写后读取另一个位置是可放宽的组合，除非原子事件、acquire/release 顺序或匹配的屏障恢复这条边。

<!-- PTO-READER-BLOCK: arch-memory-ordering-boundaries role=boundaries -->
## 边界与保守拒绝情形

当不同大小或部分重叠的访问，其范围相交却并未描述同一位置时，候选执行会被拒绝。因此这个所有者不会为此类候选执行静默补充字节级一致性规则。

原子事件不会为自身的写入侧创建读后边；读后关系只考虑另一个一致性后继写。

空事件集合不是有效的候选执行，尽管无环性辅助函数本身会把空关系视为无环。

<!-- PTO-READER-BLOCK: arch-memory-ordering-example-usage role=example-usage -->
## 非规范分析示例

对于存储缓冲（store-buffering）候选执行，记录每个内存主体的写和后续读，把每个读指向它观察到的初始写，然后运行有效性与无环性查询。在没有更强边闭合成环时，可放宽的“写后读”组合可以使候选执行仍被允许。

如果在每组写与读之间插入匹配的屏障，`MemoryFenceOrders` 会贡献保留程序顺序边。每个读取初始写的读还带有一条读后边；`MemoryFromReadBefore` 根据该读的 `read_from` 来源以及同一位置上后续的一致性后继写推导这条边。这些边共同形成环，因此 `MemoryExecutionAllowedTSO` 会拒绝该观察结果。

<!-- PTO-READER-BLOCK: arch-memory-ordering-related-owners role=related-owners-navigation -->
## 相关所有者

- [原子性](atomicity.md)是本单元声明的依赖项，并定义排序所依赖的事件属性。
- [内存事件](memory-events.md)定义事件的构造与捕获。
- [执行上下文](../programming-model/execution-context.md)拥有已捕获的事件数组、事件计数、屏障选择器和当前内存主体。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/ordering.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ORDERING","surface":"arch","classification":["memory-model","ordering"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}
readonly func MemoryCoherenceBefore(left_index: MemoryEventIndex,
                                    right_index: MemoryEventIndex) => boolean
begin
    let left = _MemoryEvents[[left_index]];
    let right = _MemoryEvents[[right_index]];
    return MemoryEventIsWrite(left) && MemoryEventIsWrite(right) &&
           MemoryEventsShareLocation(left, right) &&
           left.coherence_rank < right.coherence_rank;
end;

readonly func MemoryReadsFromBefore(write_index: MemoryEventIndex,
                                    read_index: MemoryEventIndex) => boolean
begin
    let write = _MemoryEvents[[write_index]];
    let read = _MemoryEvents[[read_index]];
    return MemoryEventIsWrite(write) && MemoryEventIsRead(read) &&
           read.read_from == write_index;
end;

readonly func MemoryExternalReadsFromBefore(write_index: MemoryEventIndex,
                                            read_index: MemoryEventIndex)
                                            => boolean
begin
    if !MemoryReadsFromBefore(write_index, read_index) then return FALSE; end;
    let write = _MemoryEvents[[write_index]];
    let read = _MemoryEvents[[read_index]];
    return write.kind == MemoryEvent_InitialWrite || write.agent != read.agent;
end;

readonly func MemoryFromReadBefore(read_index: MemoryEventIndex,
                                   write_index: MemoryEventIndex) => boolean
begin
    let read = _MemoryEvents[[read_index]];
    // An atomic event contains its read and write sides. Its own write is not a
    // later event in from-read; only a distinct coherence successor is.
    if read_index == write_index || !MemoryEventIsRead(read) then return FALSE; end;
    return MemoryCoherenceBefore(read.read_from, write_index);
end;

readonly func MemoryProgramOrderLocationBefore(
    left_index: MemoryEventIndex, right_index: MemoryEventIndex) => boolean
begin
    let left = _MemoryEvents[[left_index]];
    let right = _MemoryEvents[[right_index]];
    return left_index < right_index && left.agent == right.agent &&
           left.kind != MemoryEvent_InitialWrite &&
           right.kind != MemoryEvent_InitialWrite &&
           MemoryEventIsAccess(left) && MemoryEventIsAccess(right) &&
           MemoryEventsShareLocation(left, right);
end;

readonly func MemoryFenceOrders(left_index: MemoryEventIndex,
                                right_index: MemoryEventIndex) => boolean
begin
    if left_index + 1 >= right_index then return FALSE; end;
    let left = _MemoryEvents[[left_index]];
    let right = _MemoryEvents[[right_index]];
    for fence_number = left_index + 1 to right_index - 1 do
        let fence_index = fence_number as MemoryEventIndex;
        let fence = _MemoryEvents[[fence_index]];
        if fence.kind == MemoryEvent_Fence && fence.agent == left.agent &&
           fence.agent == right.agent &&
           (MemoryEventClass(left) AND fence.fence_predecessor) != Zeros{4} &&
           (MemoryEventClass(right) AND fence.fence_successor) != Zeros{4} then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func MemoryPreservedProgramOrderBefore(
    left_index: MemoryEventIndex, right_index: MemoryEventIndex) => boolean
begin
    let left = _MemoryEvents[[left_index]];
    let right = _MemoryEvents[[right_index]];
    if left_index >= right_index || left.agent != right.agent ||
       left.kind == MemoryEvent_InitialWrite ||
       right.kind == MemoryEvent_InitialWrite ||
       !MemoryEventIsAccess(left) || !MemoryEventIsAccess(right) then
        return FALSE;
    end;
    // PTO-TSO preserves R->M and M->W. W->R to another location is the one
    // relaxed program-order pair unless a matching fence or stronger event
    // ordering restores it. Atomics are full ordering points.
    if MemoryEventIsRead(left) || MemoryEventIsWrite(right) ||
       left.kind == MemoryEvent_Atomic || right.kind == MemoryEvent_Atomic then
        return TRUE;
    end;
    if left.order == MemoryOrder_Acquire ||
       left.order == MemoryOrder_AcquireRelease ||
       right.order == MemoryOrder_Release ||
       right.order == MemoryOrder_AcquireRelease then
        return TRUE;
    end;
    return MemoryFenceOrders(left_index, right_index);
end;

readonly func MemoryCandidateExecutionValid() => boolean
begin
    if _MemoryEventCount == 0 then return FALSE; end;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event_index = event_number as MemoryEventIndex;
        let event = _MemoryEvents[[event_index]];
        if MemoryEventIsAccess(event) then
            var initial_count: integer = 0;
            for candidate_number = 0 to _MemoryEventCount - 1 do
                let candidate_index = candidate_number as MemoryEventIndex;
                let candidate = _MemoryEvents[[candidate_index]];
                if candidate.kind == MemoryEvent_InitialWrite &&
                   MemoryEventsShareLocation(event, candidate) then
                    initial_count = initial_count + 1;
                end;
                if candidate_index != event_index &&
                   MemoryEventIsAccess(candidate) &&
                   RangesOverlap(event.address, event.size_bytes,
                       candidate.address, candidate.size_bytes) &&
                   !MemoryEventsShareLocation(event, candidate) then
                    // Mixed-size or partially overlapping candidates require
                    // a byte-level coherence extension and fail closed here.
                    return FALSE;
                end;
            end;
            if initial_count != 1 then return FALSE; end;
        end;
        if event.kind == MemoryEvent_InitialWrite && event.coherence_rank != 0 then
            return FALSE;
        end;
        if MemoryEventIsWrite(event) &&
           event.kind != MemoryEvent_InitialWrite then
            if event.coherence_rank == 0 then return FALSE; end;
            var predecessor_found = FALSE;
            for candidate_number = 0 to _MemoryEventCount - 1 do
                let candidate_index = candidate_number as MemoryEventIndex;
                let candidate = _MemoryEvents[[candidate_index]];
                if candidate_index != event_index &&
                   MemoryEventIsWrite(candidate) &&
                   MemoryEventsShareLocation(event, candidate) then
                    if candidate.coherence_rank == event.coherence_rank then
                        return FALSE;
                    end;
                    if candidate.coherence_rank + 1 == event.coherence_rank then
                        predecessor_found = TRUE;
                    end;
                end;
            end;
            if !predecessor_found then return FALSE; end;
        end;
        if MemoryEventIsRead(event) then
            if event.read_from >= _MemoryEventCount then return FALSE; end;
            let source = _MemoryEvents[[event.read_from]];
            if !MemoryEventIsWrite(source) ||
               !MemoryEventsShareLocation(event, source) ||
               event.read_value != source.write_value then
                return FALSE;
            end;
            if event.kind == MemoryEvent_Atomic &&
               event.write_performed &&
               source.coherence_rank + 1 != event.coherence_rank then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func MemoryRelationAcyclic(uniproc: boolean) => boolean
begin
    if _MemoryEventCount == 0 then return TRUE; end;
    var closure: MemoryRelationMatrix;
    for index = 0 to PTO_MODEL_MEMORY_EVENTS - 1 do
        closure[[index]] = Zeros{PTO_MODEL_MEMORY_EVENTS};
    end;
    for left_number = 0 to _MemoryEventCount - 1 do
        let left = left_number as MemoryEventIndex;
        for right_number = 0 to _MemoryEventCount - 1 do
            let right = right_number as MemoryEventIndex;
            var edge = MemoryCoherenceBefore(left, right) ||
                MemoryFromReadBefore(left, right);
            if uniproc then
                edge = edge || MemoryProgramOrderLocationBefore(left, right) ||
                    MemoryReadsFromBefore(left, right);
            else
                edge = edge || MemoryPreservedProgramOrderBefore(left, right) ||
                    MemoryExternalReadsFromBefore(left, right);
            end;
            if edge then closure[[left]][right] = '1'; end;
        end;
    end;
    for via_number = 0 to _MemoryEventCount - 1 do
        let via = via_number as MemoryEventIndex;
        for source_number = 0 to _MemoryEventCount - 1 do
            let source = source_number as MemoryEventIndex;
            if closure[[source]][via] == '1' then
                closure[[source]] = closure[[source]] OR closure[[via]];
            end;
        end;
    end;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event = event_number as MemoryEventIndex;
        if closure[[event]][event] == '1' then return FALSE; end;
    end;
    return TRUE;
end;

readonly func MemoryExecutionAllowedTSO() => boolean
begin
    return MemoryCandidateExecutionValid() &&
           MemoryRelationAcyclic(TRUE) && MemoryRelationAcyclic(FALSE);
end;
```
<!-- GENERATED-ASL-END: unit -->
