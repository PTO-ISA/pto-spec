<!-- GENERATED FROM: asl/arch/memory-model/ordering.asl -->
# Ordering

**Normative ASL source:** `asl/arch/memory-model/ordering.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ORDERING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-ordering-purpose-scope role=purpose-scope -->
## 目的与范围

本单元判定一个被捕获的候选执行是否被 PTO-RC 允许。它的入口是 `MemoryExecutionAllowedRC`，即 `MemoryCandidateExecutionValid()`、`MemoryRelationAcyclic(TRUE)` 与 `MemoryRelationAcyclic(FALSE)` 的合取；没有任何 ASL 单元调用它，它的调用者是 `tests/asl/arch/memory-model/ordering/` 下的归档一致性测试。

它带有九个已接受条款，从 `PTO-ARCH-MEMORY-MODEL-SCOPE-001` 到 `PTO-ARCH-MEMORY-MODEL-OPEN-001`，并依赖 `PTO-ARCH-MEMORY-MODEL-ATOMICITY`。

<!-- PTO-READER-BLOCK: arch-memory-ordering-concepts-state role=concepts-state -->
## 本单元建立的关系

- `MemoryCoherenceBefore` 需要两次写入、一个共享位置，以及 `left.coherence_rank < right.coherence_rank`。
- `MemoryReadsFromBefore` 需要一次写入、一次读，以及 `read.read_from == write_index`；`MemoryExternalReadsFromBefore` 还要求该写入是初始写入或具有不同的 `agent`。
- `MemorySynchronizesWith` 需要 reads-from、两个代理、一次 `MemoryOrder_Release` 或 `MemoryOrder_AcquireRelease` 的写入，以及一次 `MemoryOrder_Acquire` 或 `MemoryOrder_AcquireRelease` 的读。
- `MemoryProgramOrderLocationBefore` 需要索引递增、同一代理、两次非初始写入的访问，以及共享位置。
- `MemoryPreservedProgramOrderBefore` 需要索引递增、同一代理与两次非初始写入的访问，然后接受两者都是写入、任一是 `MemoryEvent_Atomic`、左侧 `order` 为 acquire 或右侧 `order` 为 release，或由 `MemoryFenceOrders` 找到的栅栏。
- `MemoryFenceOrders` 要求该对之间至少有一个事件，并接受该区间内第一个 `agent` 同时匹配两者、且 `fence_predecessor` 与 `fence_successor` 掩码都与对应类别相交的栅栏。

<!-- PTO-READER-BLOCK: arch-memory-ordering-rules-interactions role=rules-interactions -->
## 候选有效性规则

- 每个访问事件在其地址与 `size_bytes` 上必须恰好有一个 `MemoryEvent_InitialWrite`；零个或两个都会拒绝该候选。
- 每个非初始写入都需要非零的 `coherence_rank`，该 rank 不被该位置上任何其他写入共享，并且该位置上另有写入处于 rank `coherence_rank - 1`。
- 每次读都必须指名同一位置上一个在范围内、且 `write_value` 相等的写入；执行了自身写入的原子读还额外需要 `source.coherence_rank + 1 == event.coherence_rank`。
- `MemoryRelationAcyclic(uniproc)` 在 `uniproc` 为真时把 `MemoryProgramOrderLocationBefore` 与 `MemoryReadsFromBefore` 加入公共边，在为假时加入 `MemoryPreservedProgramOrderBefore` 与 `MemoryExternalReadsFromBefore`，然后传递地闭合该关系，并在出现任何自环时拒绝该候选。

设计要点：`MemoryPreservedProgramOrderBefore` 对两个事件都以 `MemoryEventIsAccess` 把关，因此栅栏永远不会成为保序边的一端；栅栏只能通过 `MemoryFenceOrders` 起作用，这也是两个之间没有事件严格相隔时返回假的原因。

设计要点：两次无环性调用使用不同的程序序关系，且两者都必须通过：`MemoryProgramOrderLocationBefore` 只在单个位置内成立，而 `MemoryPreservedProgramOrderBefore` 跨位置，是原子与匹配栅栏所强化的关系，因此在任一视图中有环的候选都会被拒绝。

<!-- PTO-READER-BLOCK: arch-memory-ordering-boundaries role=boundaries -->
## 边界与失败关闭情形

一旦两个不同访问部分重叠，即它们的区间重叠但地址与 `size_bytes` 并非都相同时，`MemoryCandidateExecutionValid` 就返回假。扫描会跳过事件自身的索引，而空事件集也无效，因为该函数在进入循环之前就返回假。

设计要点：同一位置上的两次写入不能共享 rank，且每个非初始写入都需要处于前一个 rank 的前驱，因此某位置的 rank 从初始写入的 `0` 起构成无缺口的链。若一次捕获中的写入因冲刷失去了前驱，则没有任何候选能通过该检查。

这些条款点名了主体并不包含的关系来源：`PTO-ARCH-MEMORY-MODEL-REQUEST-CLASS-001`（Scalar、Tile、IndexedGenerated、Prefetch）、`PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001`（`MemoryShareability_Private`、`MemoryShareability_IntraCore`、`MemoryShareability_InterCore`）、`PTO-ARCH-MEMORY-MODEL-RANGE-001`（`index_limit`）、`PTO-ARCH-MEMORY-MODEL-DEPENDENCY-001`（地址、数据与控制依赖）以及 `PTO-ARCH-MEMORY-MODEL-QUALIFIER-001`（`order_after_prior`、`order_before_later`）；这些名字没有一个出现在此处的可执行语句中。

<!-- PTO-READER-BLOCK: arch-memory-ordering-example-usage role=example-usage -->
## 非规范性分析示例

同一位置、同一代理：先一次 `MemoryOrder_Relaxed` 的 store 写入 `1`，随后一次 `MemoryOrder_Relaxed` 的 load 读回初始写入的 `0`。该候选是有效的，但 `MemoryProgramOrderLocationBefore` 给出 store 到 load 的边，`MemoryFromReadBefore` 给出反向边，因为该 store 是 load 所读到的写入的相干后继。这个自环使 `MemoryRelationAcyclic(TRUE)` 失败，于是 `MemoryExecutionAllowedRC` 拒绝该执行。

把该 load 指向那次 store 并把 `read_value` 设为 `1`，from-read 边就会消失，只剩同一位置的程序序边，因此该候选被允许：同一位置内的 Store 到 Load 次序是可见的，尽管跨位置的 Load 到 Load 对被放松。

本示例仅作为阅读辅助：先应用上面的规则，再到规范性 ASL 拥有者中确认结果。它不增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-memory-ordering-related-owners role=related-owners-navigation -->
## 相关拥有者

- [原子性](atomicity.md) 是声明的依赖；它分配 `coherence_rank` 与 `read_from`。
- [内存事件](memory-events.md) 定义记录字段、类别掩码，以及谓词 `MemoryEventIsRead`、`MemoryEventIsWrite`、`MemoryEventIsAccess`、`MemoryEventsShareLocation` 与 `MemoryEventPartialOverlap`。
- [故障精确性](fault-precision.md) 拥有 `FlushMemoryReplay`，它可能移除后续写入所需的相干前驱。
- [全局内存访问](global-memory-access.md) 与 [地址空间](address-space.md) 描述事件最终到达本单元的层。
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
