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

本单元决定一个已捕获的候选内存执行是否被保留 Store-to-Store 顺序的 PTO-RC 允许。它验证事件集合、构建必需的排序关系，并拒绝必需关系中存在环的任何候选执行。

最终查询 `MemoryExecutionAllowedRC` 同时要求候选执行有效，并要求同一位置的执行关系和外部可见的保序关系都无环。

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

PTO-RC 只保留 Store-to-Store 程序顺序。不同位置的 Load-to-Load、Load-to-Store 与 Store-to-Load 默认放宽，除非原子事件、acquire/release 顺序、依赖、冲突、限定符或匹配的屏障恢复这条边。

<!-- PTO-READER-BLOCK: arch-memory-ordering-boundaries role=boundaries -->
## 边界与保守拒绝情形

当不同大小或部分重叠的访问，其范围相交却并未描述同一位置时，候选执行会被拒绝。因此这个所有者不会为此类候选执行静默补充字节级一致性规则。

原子事件不会为自身的写入侧创建读后边；读后关系只考虑另一个一致性后继写。

空事件集合不是有效的候选执行，尽管无环性辅助函数本身会把空关系视为无环。

<!-- PTO-READER-BLOCK: arch-memory-ordering-example-usage role=example-usage -->
## 非规范分析示例

对于存储缓冲（store-buffering）候选执行，记录每个内存主体的写和后续读，把每个读指向它观察到的初始写，然后运行有效性与无环性查询。在没有更强边闭合成环时，可放宽的“写后读”组合可以使候选执行仍被允许。

如果在每组写与读之间插入匹配的屏障，`MemoryFenceOrders` 会贡献保留程序顺序边。每个读取初始写的读还带有一条读后边；`MemoryFromReadBefore` 根据该读的 `read_from` 来源以及同一位置上后续的一致性后继写推导这条边。这些边共同形成环，因此 `MemoryExecutionAllowedRC` 会拒绝该观察结果。

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
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-SCOPE-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO defines one architecture-visible GM domain for scalar, Tile,
// indexed/generated, atomic/RMW, and prefetch-like requests. Backend queues,
// caches, coalescers, replay buffers, splitting, and merging are not
// architectural state and MUST preserve the result required by PTO-RC.
// NDF-END: PTO-ARCH-MEMORY-MODEL-SCOPE-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-REQUEST-CLASS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Every request belongs to Scalar, Tile, IndexedGenerated, or Prefetch.
// TNDDMA remains provisional and this classification assigns no opcode or
// final instruction-specific behavior. Tile values are data dependencies, not
// memory locations.
// NDF-END: PTO-ARCH-MEMORY-MODEL-REQUEST-CLASS-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Scalar accesses use Private, IntraCore, or InterCore shareability. Tile and
// IndexedGenerated requests are IntraCore-shareable. A scalar access that may
// alias either class MUST NOT be marked Private; such a mismatch has no
// portable guarantee and need not be diagnosed by hardware.
// NDF-END: PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-RANGE-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A location is one GM byte. Access sets may be contiguous, multi-range, or
// generated. A conservative base plus signed index_limit descriptor MUST cover
// every location whose ordering matters; an omitted location receives no
// range-based guarantee. Coarser implementation comparisons MUST be
// conservative.
// NDF-END: PTO-ARCH-MEMORY-MODEL-RANGE-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-CONFLICT-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Requests conflict when their access sets overlap in an applicable
// shareability domain and at least one writes or atomically updates. Read-read
// overlap is not a conflict. Mixed-size partial overlap remains fail-closed.
// NDF-END: PTO-ARCH-MEMORY-MODEL-CONFLICT-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-DEPENDENCY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Address, data, and control dependencies are distinct ordering sources. A
// dependency does not replace conflict ordering and a conflict does not
// replace a dependency. Control ordering is limited to an explicit owner.
// NDF-END: PTO-ARCH-MEMORY-MODEL-DEPENDENCY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-QUALIFIER-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// order_after_prior and order_before_later add same-thread directional edges
// without requiring overlap. They are intended for unknown or broad access
// sets and do not by themselves define inter-core synchronization.
// NDF-END: PTO-ARCH-MEMORY-MODEL-QUALIFIER-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-RC-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO uses relaxed consistency with preserved Store->Store program order.
// Load->Load, Load->Store, and Store->Load pairs to different locations MAY
// reorder unless atomics, acquire/release, dependency, conflict, fence, or an
// explicit qualifier adds an edge.
// NDF-END: PTO-ARCH-MEMORY-MODEL-RC-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-PREFETCH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Prefetch-like requests are performance hints unless their instruction owner
// defines visible ordering. They MUST NOT change values returned by correctly
// ordered memory operations; placement and residency are implementation-defined.
// NDF-END: PTO-ARCH-MEMORY-MODEL-PREFETCH-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-ATOMIC-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Atomic and RMW requests have read and write effects and are full ordering
// points unless a named instruction owner explicitly defines another rule.
// Cross-agent atomic ordering is owned by
// PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001; relaxed atomics add no global
// order beyond the per-location coherence order.
// NDF-END: PTO-ARCH-MEMORY-MODEL-ATOMIC-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-OPEN-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Repeated scatter-target order remains implementation-defined. All other
// memory-model boundaries are closed by the visibility, fence, overlap,
// atomicity, and replay contracts in the owning units.
// NDF-END: PTO-ARCH-MEMORY-MODEL-OPEN-001
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

readonly func MemorySynchronizesWith(write_index: MemoryEventIndex,
                                     read_index: MemoryEventIndex) => boolean
begin
    if !MemoryReadsFromBefore(write_index, read_index) then return FALSE; end;
    let write = _MemoryEvents[[write_index]];
    let read = _MemoryEvents[[read_index]];
    if write.agent == read.agent then return FALSE; end;
    let write_release = write.order == MemoryOrder_Release ||
        write.order == MemoryOrder_AcquireRelease;
    let read_acquire = read.order == MemoryOrder_Acquire ||
        read.order == MemoryOrder_AcquireRelease;
    return write_release && read_acquire;
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
    // PTO-RC preserves only Store->Store in the relaxed baseline. Load->Load,
    // Load->Store, and Store->Load to another location may be reordered unless
    // a matching fence, acquire/release order, or atomic event restores it.
    if (MemoryEventIsWrite(left) && MemoryEventIsWrite(right)) ||
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
                   MemoryEventPartialOverlap(event, candidate) then
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
            if event.kind == MemoryEvent_Atomic && event.write_performed then
                if source.coherence_rank + 1 != event.coherence_rank then
                    return FALSE;
                end;
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
                MemoryFromReadBefore(left, right) ||
                MemorySynchronizesWith(left, right);
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

readonly func MemoryExecutionAllowedRC() => boolean
begin
    return MemoryCandidateExecutionValid() &&
           MemoryRelationAcyclic(TRUE) && MemoryRelationAcyclic(FALSE);
end;
```
<!-- GENERATED-ASL-END: unit -->
