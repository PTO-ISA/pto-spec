// PTO-REQ-MEMORY-TSO-001: litmus-style allowed and forbidden candidate
// executions for PTO total store order.

func TestTSOStoreBufferingAllowed()
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
    assert MemoryExecutionAllowedTSO();
end;

func TestTSOStoreBufferingFenceForbidden()
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
    assert !MemoryExecutionAllowedTSO();

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
    assert MemoryExecutionAllowedTSO();
end;

func TestTSOMessagePassing()
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
    assert !MemoryExecutionAllowedTSO();

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
    assert MemoryExecutionAllowedTSO();
end;

func TestTSOSameLocationAndAtomicity()
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
    assert !MemoryExecutionAllowedTSO();

    SetMemoryReadFrom(stale_read, write_x);
    _MemoryEvents[[stale_read]].read_value = Zeros{PTO_XLEN} + 1;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();

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
    assert !MemoryExecutionAllowedTSO();

    SetMemoryReadFrom(atomic, atomic_predecessor);
    _MemoryEvents[[atomic]].read_value = Zeros{PTO_XLEN} + 1;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();

    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 4, 4,
        Zeros{PTO_XLEN});
    assert !MemoryCandidateExecutionValid();
    assert !MemoryExecutionAllowedTSO();
end;

func TestTSOIRIWForbidden()
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
    assert !MemoryExecutionAllowedTSO();
end;

func TestTSOConcurrency()
begin
    TestTSOStoreBufferingAllowed();
    TestTSOStoreBufferingFenceForbidden();
    TestTSOMessagePassing();
    TestTSOSameLocationAndAtomicity();
    TestTSOIRIWForbidden();
end;
