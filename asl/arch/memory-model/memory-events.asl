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
