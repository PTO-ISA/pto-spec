// PTO-TEST: {"id":"PTO-AVS-ARCH-RC-CONCURRENCY-ORDER-001","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-RC-001"],"kind":"ordering","summary":"RC concurrency outcomes obey Store->Store, fence, and atomic ordering","pass_condition":"RC concurrency assertions hold","related_sources":[]}
func TestRCStoreBufferingAllowed()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    let read_y = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    let read_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(read_y, initial_y);
    SetMemoryReadFrom(read_x, initial_x);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCStoreBufferingFenceForbidden()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(0, '0010', '0001');
    - = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(1, '0010', '0001');
    let read_y = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    let read_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(read_y, initial_y);
    SetMemoryReadFrom(read_x, initial_x);
    assert MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();

    // A read->write mask does not order either store->load pair.
    ResetMemoryExecution();
    let masked_initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let masked_initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(0, '0001', '0010');
    - = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddDataFenceEvent(1, '0001', '0010');
    let masked_read_y = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    let masked_read_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(masked_read_y, masked_initial_y);
    SetMemoryReadFrom(masked_read_x, masked_initial_x);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCMessagePassing()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let write_x = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let write_y = AddStoreEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Release, 1);
    let read_y = AddLoadEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Acquire);
    let read_x_zero = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(read_y, write_y);
    SetMemoryReadFrom(read_x_zero, initial_x);
    assert MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();

    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let allowed_write_x = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let allowed_write_y = AddStoreEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Release, 1);
    let allowed_read_y = AddLoadEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Acquire);
    let allowed_read_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed);
    SetMemoryReadFrom(allowed_read_y, allowed_write_y);
    SetMemoryReadFrom(allowed_read_x, allowed_write_x);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCSameLocationAndAtomicity()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let write_x = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let stale_read = AddLoadEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(stale_read, initial_x);
    assert MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();

    SetMemoryReadFrom(stale_read, write_x);
    _MemoryEvents[[stale_read]].read_value = Zeros{PTO_XLEN} + 1;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();

    ResetMemoryExecution();
    let atomic_initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let atomic_predecessor = AddStoreEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let atomic = AddAtomicEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 2,
        MemoryOrder_AcquireRelease, 2);
    SetMemoryReadFrom(atomic, atomic_initial);
    assert !MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();

    SetMemoryReadFrom(atomic, atomic_predecessor);
    _MemoryEvents[[atomic]].read_value = Zeros{PTO_XLEN} + 1;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();

    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 4, 4,
        Zeros{PTO_XLEN});
    assert !MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedRC();
end;

func TestRCIRIWAllowed()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let write_x = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let write_y = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let agent2_read_x = AddLoadEvent(2, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed);
    let agent2_read_y = AddLoadEvent(2, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    let agent3_read_y = AddLoadEvent(3, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed);
    let agent3_read_x = AddLoadEvent(3, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(agent2_read_x, write_x);
    SetMemoryReadFrom(agent2_read_y, initial_y);
    SetMemoryReadFrom(agent3_read_y, write_y);
    SetMemoryReadFrom(agent3_read_x, initial_x);
    assert MemoryCandidateExecutionValid();
    // RC deliberately relaxes Load->Load across different locations.
    assert MemoryExecutionAllowedRC();
end;

func TestRCStoreStoreAndRelaxedLoadPairs()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    let store_x = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let store_y = AddStoreEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let load_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    let load_y = AddLoadEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    assert MemoryPreservedProgramOrderBefore(store_x, store_y);
    assert !MemoryPreservedProgramOrderBefore(load_x, load_y);
    assert !MemoryPreservedProgramOrderBefore(store_x, load_x);
    assert !MemoryPreservedProgramOrderBefore(load_x, store_x);
    SetMemoryReadFrom(load_x, initial_x);
    SetMemoryReadFrom(load_y, initial_y);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCCrossAgentVisibilityAndFenceTransport()
begin
    ResetMemoryExecution();
    let initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let published = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 7, MemoryOrder_Release, 1);
    let observed = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 7, MemoryOrder_Acquire);
    SetMemoryReadFrom(observed, published);
    assert MemorySynchronizesWith(published, observed);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();

    ResetMemoryExecution();
    let relaxed_initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let relaxed_write = AddStoreEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 9, MemoryOrder_Relaxed, 1);
    let relaxed_read = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 9, MemoryOrder_Relaxed);
    SetMemoryReadFrom(relaxed_read, relaxed_write);
    assert !MemorySynchronizesWith(relaxed_write, relaxed_read);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();

    assert MemoryFenceStrengthOf(Zeros{4}, Zeros{4}) ==
        MemoryFenceStrength_None;
    assert MemoryFenceStrengthOf('0010', Zeros{4}) ==
        MemoryFenceStrength_Release;
    assert MemoryFenceStrengthOf(Zeros{4}, '0001') ==
        MemoryFenceStrength_Acquire;
    assert MemoryFenceStrengthOf('0010', '0001') ==
        MemoryFenceStrength_AcquireRelease;
end;

func TestRCCrossAgentAtomicOrdering()
begin
    ResetMemoryExecution();
    let initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let release_atomic = AddAtomicEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Release, 1);
    let acquire_atomic = AddAtomicEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        MemoryOrder_Acquire, 2);
    SetMemoryReadFrom(release_atomic, initial);
    SetMemoryReadFrom(acquire_atomic, release_atomic);
    assert MemorySynchronizesWith(release_atomic, acquire_atomic);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestRCConcurrencyBoundaries()
begin
    StopMemoryEventCapture();
    ResetMemoryExecution();
    let boundary_address = Zeros{PTO_XLEN} + 0x700;
    var boundary_source = AddInitialWriteEvent(
        boundary_address, 8, Zeros{PTO_XLEN});
    for boundary_rank = 1 to PTO_MODEL_MEMORY_EVENTS - 2 do
        boundary_source = AddStoreEvent(0, boundary_address, 8,
            Zeros{PTO_XLEN} + boundary_rank, MemoryOrder_Relaxed,
            boundary_rank as MemoryCoherenceRank);
    end;
    assert boundary_source ==
        ((PTO_MODEL_MEMORY_EVENTS - 2) as MemoryEventIndex);
    let boundary_final_rank = NextMemoryCoherenceRank(boundary_address, 8);
    assert boundary_final_rank == PTO_MODEL_MEMORY_EVENTS - 1;
    let boundary_read = AddLoadEvent(0, boundary_address, 8,
        Zeros{PTO_XLEN} + (PTO_MODEL_MEMORY_EVENTS - 2),
        MemoryOrder_Relaxed);
    assert boundary_read ==
        ((PTO_MODEL_MEMORY_EVENTS - 1) as MemoryEventIndex);
    assert _MemoryEventCount == PTO_MODEL_MEMORY_EVENTS;
    SetMemoryReadFrom(boundary_read, boundary_source);
    assert _MemoryEvents[[boundary_read]].read_from == boundary_source;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    ResetProfileState();
    TestRCStoreBufferingAllowed();
    TestRCStoreBufferingFenceForbidden();
    TestRCMessagePassing();
    TestRCSameLocationAndAtomicity();
    TestRCIRIWAllowed();
    TestRCStoreStoreAndRelaxedLoadPairs();
    TestRCCrossAgentVisibilityAndFenceTransport();
    TestRCCrossAgentAtomicOrdering();
    TestRCConcurrencyBoundaries();
    return 0;
end;
