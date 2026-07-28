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
           event.kind == MemoryEvent_Store || event.kind == MemoryEvent_Atomic;
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
        write_value = value,
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
        read_value = value,
        write_value = Zeros{PTO_XLEN},
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
        write_value = value,
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
    return AddMemoryEvent(MemoryEvent {
        kind = MemoryEvent_Atomic,
        agent = agent,
        address = address,
        size_bytes = size_bytes,
        read_value = read_value,
        write_value = write_value,
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
        order = MemoryOrder_AcquireRelease,
        read_from = 0,
        coherence_rank = 0,
        fence_predecessor = predecessor,
        fence_successor = successor
    });
end;

func SetMemoryReadFrom(read: MemoryEventIndex, source: MemoryEventIndex)
begin
    assert read < _MemoryEventCount && source < _MemoryEventCount;
    _MemoryEvents[[read]].read_from = source;
end;

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
