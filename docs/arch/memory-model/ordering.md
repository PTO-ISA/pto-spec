<!-- GENERATED FROM: asl/arch/memory-model/ordering.asl -->
# Ordering

**Normative ASL source:** `asl/arch/memory-model/ordering.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ORDERING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-ordering-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit decides whether a captured candidate execution is allowed by PTO-RC. Its entry point is `MemoryExecutionAllowedRC`, the conjunction of `MemoryCandidateExecutionValid()`, `MemoryRelationAcyclic(TRUE)` and `MemoryRelationAcyclic(FALSE)`, which no ASL unit calls; its callers are the archived conformance tests under `tests/asl/arch/memory-model/ordering/`.

It carries nine accepted clauses, from `PTO-ARCH-MEMORY-MODEL-SCOPE-001` through `PTO-ARCH-MEMORY-MODEL-OPEN-001`, and depends on `PTO-ARCH-MEMORY-MODEL-ATOMICITY`.

<!-- PTO-READER-BLOCK: arch-memory-ordering-concepts-state role=concepts-state -->
## The relations this unit builds

- `MemoryCoherenceBefore` needs two writes, a shared location and `left.coherence_rank < right.coherence_rank`.
- `MemoryReadsFromBefore` needs a write, a read and `read.read_from == write_index`; `MemoryExternalReadsFromBefore` adds an initial write or another `agent`.
- `MemorySynchronizesWith` needs reads-from, two agents, a `MemoryOrder_Release` or `MemoryOrder_AcquireRelease` write and a `MemoryOrder_Acquire` or `MemoryOrder_AcquireRelease` read.
- `MemoryProgramOrderLocationBefore` needs increasing indices, one agent, two non-initial-write accesses and a shared location.
- `MemoryPreservedProgramOrderBefore` needs increasing indices, one agent and two non-initial-write accesses, then accepts two writes, either event `MemoryEvent_Atomic`, an acquire left or release right `order`, or a fence found by `MemoryFenceOrders`.
- `MemoryFenceOrders` needs at least one event strictly between the pair and accepts the first fence in that span whose `agent` matches both and whose `fence_predecessor` and `fence_successor` masks intersect the matching class.

<!-- PTO-READER-BLOCK: arch-memory-ordering-rules-interactions role=rules-interactions -->
## Candidate validity rules

- Every access event must have exactly one `MemoryEvent_InitialWrite` at its address and `size_bytes`; zero or two reject the candidate.
- Every non-initial write needs a nonzero `coherence_rank` no other write at the location shares, with another write there at rank `coherence_rank - 1`.
- Every read must name an in-range write at the same location with an equal `write_value`; an atomic read that wrote additionally needs `source.coherence_rank + 1 == event.coherence_rank`.
- `MemoryRelationAcyclic(uniproc)` adds `MemoryProgramOrderLocationBefore` and `MemoryReadsFromBefore` when `uniproc` is true and `MemoryPreservedProgramOrderBefore` and `MemoryExternalReadsFromBefore` when it is false, then closes the relation transitively and rejects any self-loop.

Design point: `MemoryPreservedProgramOrderBefore` gates on `MemoryEventIsAccess` for both events, so a fence is never an end of a preserved-order edge; fences contribute only through `MemoryFenceOrders`, which is why two events with nothing strictly between them return false.

Design point: the two acyclicity calls use different program-order relations and both must pass: `MemoryProgramOrderLocationBefore` holds only within one location, while `MemoryPreservedProgramOrderBefore` spans locations and is what atomics and matching fences strengthen, so a candidate cyclic in either view is rejected.

<!-- PTO-READER-BLOCK: arch-memory-ordering-boundaries role=boundaries -->
## Boundaries and fail-closed cases

`MemoryCandidateExecutionValid` returns false as soon as two distinct accesses partially overlap: their ranges overlap but their address and `size_bytes` do not both match. The scan skips the event's own index, and an empty event set is invalid because the function returns false before its loop.

Design point: two writes at one location cannot share a rank and every non-initial write needs a predecessor at the preceding rank, so ranks at a location form a gapless chain from the initial write's `0`. A capture whose write lost its predecessor to a flush passes no candidate.

The clauses name relation sources the body does not contain: `PTO-ARCH-MEMORY-MODEL-REQUEST-CLASS-001` (Scalar, Tile, IndexedGenerated, Prefetch), `PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001` (`MemoryShareability_Private`, `MemoryShareability_IntraCore`, `MemoryShareability_InterCore`), `PTO-ARCH-MEMORY-MODEL-RANGE-001` (`index_limit`), `PTO-ARCH-MEMORY-MODEL-DEPENDENCY-001` (address, data and control dependencies) and `PTO-ARCH-MEMORY-MODEL-QUALIFIER-001` (`order_after_prior`, `order_before_later`); none of those names appears in an executable statement here.

<!-- PTO-READER-BLOCK: arch-memory-ordering-example-usage role=example-usage -->
## Non-normative analysis example

One location, one agent: a `MemoryOrder_Relaxed` store of `1`, then a `MemoryOrder_Relaxed` load that reads the initial write's `0`. The candidate is valid, but `MemoryProgramOrderLocationBefore` gives a store-to-load edge and `MemoryFromReadBefore` the reverse edge, because the store is the coherence successor of the write the load read. The self-loop fails `MemoryRelationAcyclic(TRUE)`, so `MemoryExecutionAllowedRC` rejects the execution.

Point the load at the store with `read_value` `1` and the from-read edge disappears, leaving only the same-location program-order edge, so the candidate is allowed: Store to Load order is visible within one location, though Load to Load pairs to different locations are relaxed.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-memory-ordering-related-owners role=related-owners-navigation -->
## Related owners

- [Atomicity](atomicity.md) is the declared dependency; it assigns `coherence_rank` and `read_from`.
- [Memory events](memory-events.md) defines the record fields, class masks and predicates `MemoryEventIsRead`, `MemoryEventIsWrite`, `MemoryEventIsAccess`, `MemoryEventsShareLocation` and `MemoryEventPartialOverlap`.
- [Fault precision](fault-precision.md) owns `FlushMemoryReplay`, which can remove the coherence predecessor a later write needs.
- [Global memory access](global-memory-access.md) and [Address space](address-space.md) describe the layers whose events reach this unit.
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
