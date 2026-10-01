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

This unit bridges real memory operations and the bounded candidate-execution event array, filling in the fields a raw event record does not carry: a per-location coherence rank, a reads-from source index and the fence class masks, and owns the four production recording entry points.

It has no `NDF-BEGIN` clause of its own: its only embedded metadata is the `PTO-UNIT` JSON on line 1, which declares `PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS` as its dependency.

<!-- PTO-READER-BLOCK: arch-atomicity-concepts role=concepts-state -->
## The three derived fields

- `NextMemoryCoherenceRank` walks every event slot below `_MemoryEventCount` and returns one above the largest `coherence_rank` held by a write with the same `address` and `size_bytes`.
- `ResolveCapturedReadFrom` walks event slots `0` through `read - 1`, keeping the last write whose location matches and whose `write_value` equals the read's `read_value`.
- `SetMemoryReadFrom` asserts `read < _MemoryEventCount && source < _MemoryEventCount` and assigns `_MemoryEvents[[read]].read_from = source`.
- `MemoryEventIsWrite` counts `MemoryEvent_InitialWrite`, `MemoryEvent_Store` and a `MemoryEvent_Atomic` with `write_performed` true, so an initial write takes part in rank allocation though it carries rank `0`.
- Every `Word` value field is stored through `NormalizeMemoryAccessValue`, which zero-extends `value[7:0]`, `value[15:0]` or `value[31:0]` for `size_bytes` `1`, `2` or `4` and passes eight-byte values through.

<!-- PTO-READER-BLOCK: arch-atomicity-rules role=rules-interactions -->
## What each recording entry point does

- `RecordLoadEventForAgent` appends a load event and then calls `ResolveCapturedReadFrom` on the new index.
- `RecordStoreEventForAgent` computes `NextMemoryCoherenceRank(address, size_bytes)` and passes it to `AddStoreEvent`.
- `RecordAtomicEvent` computes a rank only when `write_performed` is true, passes `0` otherwise, appends through `AddAtomicOutcomeEvent` and then calls `ResolveCapturedReadFrom`.
- `RecordDataFenceEvent` appends a fence event with the two `bits(4)` masks and does no ranking or resolution.
- `RecordLoadEvent`, `RecordStoreEvent` and `RecordAtomicEvent` are one-line wrappers that substitute `_CurrentMemoryAgent`.

Design point: the rank returned is one above the largest rank at the same `address` and `size_bytes`, so a rank is never reused. A write at rank `k` has a predecessor only while the rank `k - 1` write is still in the array; after `FlushMemoryReplay` truncates that sequence the predecessor can be gone, and `MemoryCandidateExecutionValid` rejects the candidate.

Design point: `ResolveCapturedReadFrom` compares values rather than order annotations and keeps the last match, so a load whose value equals an earlier same-location write reads from that write even under `MemoryOrder_Relaxed`. When nothing matches, `read_from` keeps its `0`, and whether slot `0` holds a matching write is decided by `MemoryCandidateExecutionValid`.

Design point: `RecordAtomicEvent` gives a not-performed atomic write the rank `0` instead of allocating one, because `NextMemoryCoherenceRank` runs only in the `write_performed` branch. A failed compare-and-swap still occupies an event slot and has its read side resolved, but it leaves the next real write's rank untouched.

<!-- PTO-READER-BLOCK: arch-atomicity-boundaries role=boundaries -->
## Boundaries

This unit decides only which source a captured read names; whether the candidate execution is legal is decided by `MemoryCandidateExecutionValid` and `MemoryExecutionAllowedRC` in the ordering unit, which re-check the source index, location and value equality themselves.

`NextMemoryCoherenceRank` asserts `next_rank < PTO_MODEL_MEMORY_EVENTS`, so a sequence needing a rank equal to the bound fails the model run rather than reusing a rank. `PTO_MODEL_MEMORY_EVENTS` is `16`, so the largest rank returned is `15`, and a location whose writes fill ranks `0` through `15` fails the next store's assert; that limit belongs to the bounded event array, not to the ordering rule.

While `_MemoryEventCaptureEnabled` is false every function here returns without touching `_MemoryEvents` or `_MemoryEventCount`, so production execution outside a capture session records nothing.

<!-- PTO-READER-BLOCK: arch-atomicity-example role=example-usage -->
## Non-normative capture example

Inside one `StartMemoryEventCapture(0)` session, `0x40` holds only the initial write, then a store of `0x55`. The initial write takes rank `0`, and `NextMemoryCoherenceRank(0x40, 8)` returns `1` for the store, so the two writes there carry `0` and `1`.

A later load of `0x40` reading `0x55` resolves to the store's index, the last earlier write with matching location and value; reading `0x66` matches nothing, so `read_from` stays `0`.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-atomicity-related role=related-owners-navigation -->
## Related owners

- [Memory events](memory-events.md) defines the `MemoryEvent` record, the event array, the capture flag and the append helpers.
- [Ordering](ordering.md) consumes `coherence_rank` and `read_from` when deciding whether a candidate execution is allowed.
- [Fault precision](fault-precision.md) owns the replay state deciding how many of those records survive a fault.
- Production callers include for example `asl/scalar/model/amo/semantics.asl`, `asl/tile/model/memory/load-store.asl` and `asl/tile/model/memory/gather-scatter.asl`.
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
