<!-- GENERATED FROM: asl/arch/memory-model/atomicity.asl -->
# Atomicity

**Normative ASL source:** `asl/arch/memory-model/atomicity.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ATOMICITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-atomicity-purpose role=purpose-scope -->
## Purpose and scope

This unit connects production memory operations to the bounded candidate-execution event model. It records loads, stores, atomics, and data fences when capture is enabled, and maintains per-location coherence and reads-from information.

<!-- PTO-READER-BLOCK: arch-atomicity-concepts role=concepts-state -->
## Event relationships

- `NextMemoryCoherenceRank` scans earlier writes with the same address and `size_bytes` to allocate the next rank.
- `ResolveCapturedReadFrom` searches earlier same-location writes whose `write_value` equals the captured `read_value`.
- `SetMemoryReadFrom` writes the selected source index after checking that both event indices already exist.

<!-- PTO-READER-BLOCK: arch-atomicity-rules role=rules-interactions -->
## Recording rules

- Load records are added first and then resolved to a captured source when one is found.
- Store records receive a fresh coherence rank before publication.
- Atomic records receive a rank only when `write_performed` is true; they still record the read outcome and attempt reads-from resolution.
- Wrapper forms use `_CurrentMemoryAgent`; explicit forms accept a `MemoryAgentId`.

<!-- PTO-READER-BLOCK: arch-atomicity-boundaries role=boundaries -->
## Boundaries

All record helpers are effect-free while `_MemoryEventCaptureEnabled` is false. Captured source selection is based on preceding events, equal locations, and equal values; the complete candidate-execution legality decision remains in the memory-ordering owners.

<!-- PTO-READER-BLOCK: arch-atomicity-example role=example-usage -->
## Non-normative event example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-atomicity-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS` defines event records and capture storage.
- Memory ordering consumes coherence and reads-from relations to check a candidate execution.
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
