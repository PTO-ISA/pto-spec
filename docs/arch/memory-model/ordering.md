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

This unit decides whether a captured candidate memory execution is allowed by PTO-TSO. It validates the event set, builds the required ordering relations, and rejects any candidate whose required relation contains a cycle.

The final query, `MemoryExecutionAllowedTSO`, requires candidate validity and acyclicity of both the same-location execution relation and the externally visible preserved-order relation.

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

PTO-TSO preserves read-to-memory and memory-to-write program order. A write followed by a read of another location is the relaxed pair unless an atomic event, acquire/release order, or a matching fence restores the edge.

<!-- PTO-READER-BLOCK: arch-memory-ordering-boundaries role=boundaries -->
## Boundaries and fail-closed cases

Mixed-size or partially overlapping accesses are rejected when their ranges overlap but they do not describe the same location. This owner therefore does not silently invent byte-level coherence for such candidates.

An atomic event does not create a from-read edge to its own write side; from-read considers only a distinct coherence successor.

An empty event set is not a valid candidate execution, although the acyclicity helper itself treats an empty relation as acyclic.

<!-- PTO-READER-BLOCK: arch-memory-ordering-example-usage role=example-usage -->
## Non-normative analysis example

For a store-buffering candidate, record each agent's store and later read, assign each read to the initial write it observed, and run the validity and acyclicity queries. The relaxed write-to-read pair can leave the candidate allowed when no stronger edge closes a cycle.

If matching fences are inserted between each store and read, `MemoryFenceOrders` contributes preserved-program-order edges. Each read of an initial write also has a from-read edge, which `MemoryFromReadBefore` derives from the read's `read_from` source and the later coherence successor at that location; together these edges form a cycle, so `MemoryExecutionAllowedTSO` rejects the observed outcome.

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
