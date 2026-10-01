<!-- GENERATED FROM: asl/arch/memory-model/memory-events.asl -->
# Memory Events

**Normative ASL source:** `asl/arch/memory-model/memory-events.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-events-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the event vocabulary the rest of the memory model reasons over: read versus write kinds, shared locations, fence strength from two masks, and the bounded event array.

It carries four accepted clauses, `PTO-ARCH-MEMORY-MODEL-VISIBILITY-001`, `PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001`, `PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001` and `PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001`, plus a `PTO-REQ-MEMORY-RC-001` comment naming the event bound as verification infrastructure. The `MemoryEvent` record is declared in `asl/arch/data-types/memory-model.asl`, not here.

<!-- PTO-READER-BLOCK: arch-memory-events-concepts role=concepts-state -->
## Event kinds, fields and classes

- `MemoryEventIsRead` is true for `MemoryEvent_Load` and `MemoryEvent_Atomic`; `MemoryEventIsWrite` for `MemoryEvent_InitialWrite`, `MemoryEvent_Store` and an atomic with `write_performed` true.
- `MemoryEventsShareLocation` requires equal `address` and equal `size_bytes`; `MemoryEventRangesOverlap` calls `RangesOverlap` over both events' address and `size_bytes`, and `MemoryEventPartialOverlap` is overlap without shared location.
- `MemoryEventClass` maps `MemoryEvent_Load` to `'0001'`, both store kinds to `'0010'`, `MemoryEvent_Atomic` to `'0011'` and `MemoryEvent_Fence` to `Zeros{4}`.
- `MemoryFenceStrengthOf(predecessor, successor)` returns `MemoryFenceStrength_AcquireRelease` when both are nonzero, `MemoryFenceStrength_Release` for predecessor only, `MemoryFenceStrength_Acquire` for successor only, and `MemoryFenceStrength_None` when both are `Zeros{4}`.
- `AddLoadEvent` sets `write_performed = FALSE` with a zeroed `write_value`; `AddStoreEvent` sets `write_performed = TRUE`, the rank it is given and a zeroed `read_value`.
- `AddAtomicOutcomeEvent` normalizes both `read_value` and `write_value`; `AddDataFenceEvent` fixes `address = Zeros{PTO_XLEN}`, `size_bytes = 1` and `order = MemoryOrder_AcquireRelease`.
- Its state is `_MemoryEvents`, `_MemoryEventCount`, `_CurrentMemoryAgent` and `_MemoryEventCaptureEnabled`.

<!-- PTO-READER-BLOCK: arch-memory-events-rules role=rules-interactions -->
## Capture lifecycle

- `ResetMemoryExecution` sets `_MemoryEventCount = 0` and touches nothing else.
- `StartMemoryEventCapture(agent)` calls `ResetMemoryExecution`, sets `_CurrentMemoryAgent = agent` and `_MemoryEventCaptureEnabled = TRUE`.
- `SelectMemoryEventAgent(agent)` writes only `_CurrentMemoryAgent`, so it changes the agent of later wrapper calls without clearing the sequence.
- `StopMemoryEventCapture` sets the flag false and leaves the array and `_CurrentMemoryAgent` unchanged.
- `AddMemoryEvent` asserts `_MemoryEventCount < PTO_MODEL_MEMORY_EVENTS`, stores the record at the current count, increments the count and returns the index. It does not consult `_MemoryEventCaptureEnabled`; that check sits one level up in the atomicity unit's `Record` functions, so a direct `AddInitialWriteEvent` or `AddStoreEvent` call appends while capture is off.
- `AddInitialWriteEvent` always stores `agent = 0`, `order = MemoryOrder_Relaxed`, `read_from = 0` and `coherence_rank = 0`.

Design point: `MemoryEventClass` gives an atomic event `'0011'`, the OR of the read and write classes, because one record holds both sides. A fence naming `'0011'` as predecessor or successor matches an atomic event, and the ordering unit's `MemoryFenceOrders` only tests that the AND with the mask is nonzero.

Design point: strength is derived from the masks and never stored, because `MemoryFenceStrengthOf` reads only its arguments; a fence whose predecessor mask is `'0000'` cannot act as a release.

Design point: `ResetMemoryExecution` clears the count, not the contents, and `AddMemoryEvent` writes the slot before it increments. Every reader bounds its scan by `_MemoryEventCount`, so stale records above the count are unreachable and get overwritten by later appends.

<!-- PTO-READER-BLOCK: arch-memory-events-boundaries role=boundaries -->
## Verification boundary

The bounds `PTO_MODEL_MEMORY_EVENTS` of `16` and `PTO_MODEL_MEMORY_AGENTS` of `4` belong to this candidate-execution model, not to an implementation; the `PTO-REQ-MEMORY-RC-001` comment says so.

The clause `PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001` says GM locations are bytes, this revision defines no byte-level merge or tearing, and only exact address-and-size matches participate in the portable coherence relation. This unit supplies the predicates that draw that line, `MemoryEventsShareLocation` and `MemoryEventPartialOverlap`; the ordering unit's `MemoryCandidateExecutionValid` fails closed on a partial overlap.

`MemoryEventClass` returns `Zeros{4}` for `MemoryEvent_Fence`: its source comment records that instruction and device classes remain explicit mask space while the model records data events, so a fence contributes no class to any AND test.

<!-- PTO-READER-BLOCK: arch-memory-events-example role=example-usage -->
## Non-normative capture example

`StartMemoryEventCapture(1)` sets the agent to `1`, clears the count and enables capture. `AddInitialWriteEvent(0x40, 8, 0x55)` occupies index `0`; `AddLoadEvent(1, 0x40, 8, 0x55, MemoryOrder_Acquire)` occupies index `1`, and `_MemoryEventCount` becomes `2`.

`MemoryEventsShareLocation` on those records is true and `MemoryEventPartialOverlap` is false, so they describe one location. A load at `0x44` with `size_bytes` `8` overlaps without sharing, which `MemoryEventPartialOverlap` reports as true.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-memory-events-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-DATA-TYPES-MEMORY-MODEL` declares the `MemoryEvent` record, `MemoryEventKind`, `MemoryOrder` and `MemoryFenceStrength`.
- [Address space](address-space.md) supplies `ReadPhysicalMemoryByte`, used by `FetchPTOInstruction` and by writes.
- [Atomicity](atomicity.md) fills `coherence_rank` and `read_from` on the records this unit appends.
- [Ordering](ordering.md) consumes these predicates to decide `MemoryCandidateExecutionValid` and `MemoryExecutionAllowedRC`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/memory-events.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS","surface":"arch","classification":["memory-model","memory-events"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE"]}
// PTO-REQ-MEMORY-RC-001: bounded executable candidate-execution checker for
// PTO relaxed consistency with preserved Store->Store order. The event bound
// is verification infrastructure, not an architectural limit on agents or
// executions.
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-VISIBILITY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// The portable GM domain is multi-copy atomic: one location has one global
// coherence order and a completed write may be observed by every applicable
// agent. Release/acquire pairs add a cross-agent synchronizes-with relation;
// relaxed operations retain atomicity/coherence only and do not publish a
// cross-agent ordering guarantee.
// NDF-END: PTO-ARCH-MEMORY-MODEL-VISIBILITY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Fence predecessor/successor class masks are the architecture-visible
// transport of fence strength. A fence orders only matching classes in the
// same agent; it does not silently acquire a stronger implementation fence or
// create a cross-agent relation without a matching release/acquire access.
// NDF-END: PTO-ARCH-MEMORY-MODEL-FENCE-TRANSPORT-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// GM locations are bytes, but this revision does not define byte-level merge or
// tearing for mixed-size accesses. Any partial overlap between distinct access
// ranges fails closed; only exact address-and-size matches participate in the
// portable coherence relation.
// NDF-END: PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// An atomic/RMW access to one exact byte range is one indivisible read/write
// event in the global coherence order. Acquire/release atomic pairs may
// synchronize across agents; relaxed atomics do not imply a global SC order for
// different locations.
// NDF-END: PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001

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

pure func MemoryEventRangesOverlap(left: MemoryEvent,
                                   right: MemoryEvent) => boolean
begin
    return RangesOverlap(left.address, left.size_bytes,
                         right.address, right.size_bytes);
end;

pure func MemoryFenceStrengthOf(predecessor: bits(4), successor: bits(4))
                                => MemoryFenceStrength
begin
    let has_predecessor = predecessor != Zeros{4};
    let has_successor = successor != Zeros{4};
    if has_predecessor && has_successor then
        return MemoryFenceStrength_AcquireRelease;
    elsif has_predecessor then
        return MemoryFenceStrength_Release;
    elsif has_successor then
        return MemoryFenceStrength_Acquire;
    else
        return MemoryFenceStrength_None;
    end;
end;

pure func MemoryEventsShareLocation(left: MemoryEvent,
                                    right: MemoryEvent) => boolean
begin
    return left.address == right.address && left.size_bytes == right.size_bytes;
end;

pure func MemoryEventPartialOverlap(left: MemoryEvent,
                                    right: MemoryEvent) => boolean
begin
    return MemoryEventRangesOverlap(left, right) &&
           !MemoryEventsShareLocation(left, right);
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
```
<!-- GENERATED-ASL-END: unit -->
