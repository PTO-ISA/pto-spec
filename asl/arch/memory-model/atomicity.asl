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
    RecordAtomicEventForAgent(_CurrentMemoryAgent, address, size_bytes,
        read_value, write_value, order, write_performed);
end;

func RecordAtomicEventForAgent(agent: MemoryAgentId, address: Word,
                       size_bytes: integer {1,2,4,8},
                       read_value: Word, write_value: Word,
                       order: MemoryOrder, write_performed: boolean)
begin
    if _MemoryEventCaptureEnabled then
        let rank = if write_performed then
            NextMemoryCoherenceRank(address, size_bytes) else 0;
        let event = AddAtomicOutcomeEvent(agent, address,
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

func RecordTileLoadEvent(address: Word, size_bytes: integer {1,2,4,8},
                        value: Word, order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Tile;
    RecordLoadEvent(address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordTileLoadEventForAgent(agent: MemoryAgentId, address: Word,
                        size_bytes: integer {1,2,4,8}, value: Word,
                        order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Tile;
    RecordLoadEventForAgent(agent, address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordTileStoreEvent(address: Word, size_bytes: integer {1,2,4,8},
                         value: Word, order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Tile;
    RecordStoreEvent(address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordTileStoreEventForAgent(agent: MemoryAgentId, address: Word,
                         size_bytes: integer {1,2,4,8}, value: Word,
                         order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Tile;
    RecordStoreEventForAgent(agent, address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordTileAtomicEvent(address: Word, size_bytes: integer {1,2,4,8},
                           read_value: Word, write_value: Word,
                           order: MemoryOrder, write_performed: boolean)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Tile;
    RecordAtomicEvent(address, size_bytes, read_value, write_value, order,
        write_performed);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordTileAtomicEventForAgent(agent: MemoryAgentId, address: Word,
                           size_bytes: integer {1,2,4,8}, read_value: Word,
                           write_value: Word, order: MemoryOrder,
                           write_performed: boolean)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Tile;
    RecordAtomicEventForAgent(agent, address, size_bytes, read_value,
        write_value, order, write_performed);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordIndexedLoadEvent(address: Word, size_bytes: integer {1,2,4,8},
                            value: Word, order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_IndexedGenerated;
    RecordLoadEvent(address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordIndexedLoadEventForAgent(agent: MemoryAgentId, address: Word,
                            size_bytes: integer {1,2,4,8}, value: Word,
                            order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_IndexedGenerated;
    RecordLoadEventForAgent(agent, address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordIndexedStoreEvent(address: Word, size_bytes: integer {1,2,4,8},
                             value: Word, order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_IndexedGenerated;
    RecordStoreEvent(address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordIndexedAtomicEvent(address: Word, size_bytes: integer {1,2,4,8},
                              read_value: Word, write_value: Word,
                              order: MemoryOrder, write_performed: boolean)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_IndexedGenerated;
    RecordAtomicEvent(address, size_bytes, read_value, write_value, order,
        write_performed);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordPrefetchLoadEventForAgent(agent: MemoryAgentId, address: Word,
                            size_bytes: integer {1,2,4,8}, value: Word,
                            order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_Private;
    _CurrentMemoryRequestClass = MemoryRequestClass_Prefetch;
    RecordLoadEventForAgent(agent, address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordLegacyExcludedLoadEvent(address: Word, size_bytes: integer {1,2,4,8},
                           value: Word, order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_Private;
    _CurrentMemoryRequestClass = MemoryRequestClass_LegacyExcluded;
    RecordLoadEvent(address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func RecordLegacyExcludedStoreEvent(address: Word, size_bytes: integer {1,2,4,8},
                            value: Word, order: MemoryOrder)
begin
    let old_scope = _CurrentMemoryShareability;
    let old_class = _CurrentMemoryRequestClass;
    _CurrentMemoryShareability = MemoryShareability_Private;
    _CurrentMemoryRequestClass = MemoryRequestClass_LegacyExcluded;
    RecordStoreEvent(address, size_bytes, value, order);
    _CurrentMemoryShareability = old_scope;
    _CurrentMemoryRequestClass = old_class;
end;

func SetMemoryReadFrom(read: MemoryEventIndex, source: MemoryEventIndex)
begin
    assert read < _MemoryEventCount && source < _MemoryEventCount;
    _MemoryEvents[[read]].read_from = source;
end;
