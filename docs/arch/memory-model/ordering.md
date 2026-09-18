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

This unit decides whether a captured candidate memory execution is allowed by PTO-RC with preserved Store-to-Store order. It validates the event set, builds the required ordering relations, and rejects any candidate whose required relation contains a cycle.

The final query, `MemoryExecutionAllowedRC`, requires candidate validity and acyclicity of both the same-location execution relation and the externally visible preserved-order relation.

<!-- PTO-READER-BLOCK: arch-memory-ordering-concepts-state role=concepts-state -->
## Event relations

- Coherence orders writes to the same location by increasing `coherence_rank`; reads-from connects a write to a read whose `read_from` field names that write.
- External reads-from keeps reads whose source is an initial write or belongs to a different agent; from-read connects a read to a distinct coherence successor of the write it observed.
- Same-agent program order at one location and preserved program order across locations provide the two program-order views used by the acyclicity checks.
- A fence contributes an edge only when it lies between two events from the same agent and both event classes match its predecessor and successor masks.

<!-- PTO-READER-BLOCK: arch-memory-ordering-rules-interactions role=rules-interactions -->
## Candidate rules

Every accessed location has exactly one initial-write event, and each initial write has coherence rank `0`.

Every later write to a location has a unique nonzero coherence rank with an immediate predecessor at the preceding rank.

Every read names an in-range write to the same location and carries the value written by that source. A successful atomic write immediately follows its read source in coherence order.

PTO-RC preserves Store-to-Store program order. Load-to-Load, Load-to-Store, and Store-to-Load pairs to different locations are relaxed unless an atomic event, acquire/release order, dependency, conflict, qualifier, or matching fence restores the edge.

<!-- PTO-READER-BLOCK: arch-memory-ordering-boundaries role=boundaries -->
## Boundaries and fail-closed cases

Mixed-size or partially overlapping accesses are rejected when their ranges overlap but they do not describe the same location. This owner therefore does not silently invent byte-level coherence for such candidates.

An atomic event does not create a from-read edge to its own write side; from-read considers only a distinct coherence successor.

An empty event set is not a valid candidate execution, although the acyclicity helper itself treats an empty relation as acyclic.

<!-- PTO-READER-BLOCK: arch-memory-ordering-example-usage role=example-usage -->
## Non-normative analysis example

For a store-buffering candidate, record each agent's store and later read, assign each read to the initial write it observed, and run the validity and acyclicity queries. The relaxed write-to-read pair can leave the candidate allowed when no stronger edge closes a cycle.

If matching fences are inserted between each store and read, `MemoryFenceOrders` contributes preserved-program-order edges. Each read of an initial write also has a from-read edge, which `MemoryFromReadBefore` derives from the read's `read_from` source and the later coherence successor at that location; together these edges form a cycle, so `MemoryExecutionAllowedRC` rejects the observed outcome.

<!-- PTO-READER-BLOCK: arch-memory-ordering-related-owners role=related-owners-navigation -->
## Related owners

- [Atomicity](atomicity.md) is this unit's declared dependency and defines the event properties on which ordering relies.
- [Memory events](memory-events.md) defines event construction and capture.
- [Execution context](../programming-model/execution-context.md) owns the captured event array, event count, fence selectors, and current memory agent.
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
