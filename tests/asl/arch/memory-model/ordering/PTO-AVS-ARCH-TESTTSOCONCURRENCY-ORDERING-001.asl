// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-ARCH-TESTTSOCONCURRENCY-ORDERING-001","source":"asl/arch/memory-model/ordering.asl","requirements":[],"kind":"ordering","summary":"migrated independent behavior point for TestTSOConcurrency","pass_condition":"TestTSOConcurrency completes without assertion failure","related_sources":[]}
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

func TestProductionScalarEventExtraction()
begin
    let address = Zeros{PTO_XLEN} + 0x300;
    StopMemoryEventCapture();
    Store(address, 8, Zeros{PTO_XLEN} + 10);
    StartMemoryEventCapture(2);
    let initial = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN} + 10);
    let loaded = LoadUnsigned(address, 8);
    assert loaded == Zeros{PTO_XLEN} + 10;
    StoreWithOrder(address, 8, Zeros{PTO_XLEN} + 11,
        MemoryOrder_Release);
    FenceData('0010', '0001');
    let old = AtomicReadModifyWrite(address, 8, Atomic_ADD,
        Zeros{PTO_XLEN} + 1, MemoryOrder_AcquireRelease);
    assert old == Zeros{PTO_XLEN} + 11;
    assert _MemoryEventCount == 5;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].agent == 2;
    assert _MemoryEvents[[1]].address == address;
    assert _MemoryEvents[[1]].size_bytes == 8;
    assert _MemoryEvents[[1]].order == MemoryOrder_Relaxed;
    assert _MemoryEvents[[1]].read_from == initial;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[2]].order == MemoryOrder_Release;
    assert _MemoryEvents[[2]].coherence_rank == 1;
    assert _MemoryEvents[[3]].kind == MemoryEvent_Fence;
    assert _MemoryEvents[[3]].fence_predecessor == '0010';
    assert _MemoryEvents[[3]].fence_successor == '0001';
    assert _MemoryEvents[[4]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[4]].order == MemoryOrder_AcquireRelease;
    assert _MemoryEvents[[4]].read_value == Zeros{PTO_XLEN} + 11;
    assert _MemoryEvents[[4]].write_value == Zeros{PTO_XLEN} + 12;
    assert _MemoryEvents[[4]].write_performed;
    assert _MemoryEvents[[4]].coherence_rank == 2;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();
    StopMemoryEventCapture();
end;

func TestProductionReservationEventsAndCorners()
begin
    let line = Zeros{PTO_XLEN} + 0x380;
    StopMemoryEventCapture();
    Store(line, 8, Zeros{PTO_XLEN} + 0x1122334455667788);
    StartMemoryEventCapture(1);
    let reserved = LoadReserved(line, 8, MemoryOrder_Acquire);
    assert reserved == Zeros{PTO_XLEN} + 0x1122334455667788;
    let cross_width = StoreConditional(line + 4, 4,
        Zeros{PTO_XLEN} + 0xaabbccdd, MemoryOrder_Release);
    assert cross_width == Zeros{PTO_XLEN};
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].order == MemoryOrder_Acquire;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].address == line + 4;
    assert _MemoryEvents[[1]].size_bytes == 4;
    assert _MemoryEvents[[1]].order == MemoryOrder_Release;

    ClearFault();
    let failed_without_probe = StoreConditional(Ones{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    assert failed_without_probe == Zeros{PTO_XLEN} + 1;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert !_ReservationValid;
    StopMemoryEventCapture();

    - = LoadReserved(line, 8, MemoryOrder_Relaxed);
    assert _ReservationValid;
    Store(line + 63, 1, Zeros{PTO_XLEN} + 1);
    assert !_ReservationValid;
    - = LoadReserved(line, 8, MemoryOrder_Relaxed);
    Store(line + 64, 1, Zeros{PTO_XLEN} + 1);
    assert _ReservationValid;
    let next_line = StoreConditional(line + 64, 1,
        Zeros{PTO_XLEN} + 2, MemoryOrder_Relaxed);
    assert next_line == Zeros{PTO_XLEN} + 1;
    assert !_ReservationValid;

    - = LoadReserved(line, 8, MemoryOrder_Relaxed);
    assert _ReservationValid;
    ClearFault();
    let faulting_sc = StoreConditional(line + 1, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    assert faulting_sc == Zeros{PTO_XLEN};
    assert _LastFault == Fault_DataAlignment;
    assert !_ReservationValid;
end;

func TestProductionPairAndDMAEventExtraction()
begin
    let source = Zeros{PTO_XLEN} + 0x100;
    let destination = Zeros{PTO_XLEN} + 0x180;
    StopMemoryEventCapture();
    Store(source, 4, Zeros{PTO_XLEN} + 0x11);
    Store(source + 4, 4, Zeros{PTO_XLEN} + 0x22);
    WriteGPR(2, source);
    StartMemoryEventCapture(0);
    ExecuteScalarLoadPair(3, 4, 2, Zeros{PTO_XLEN}, 4, FALSE);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == source;
    assert _MemoryEvents[[1]].address == source + 4;
    StopMemoryEventCapture();

    for byte_index = 0 to 63 do
        Store(source + NaturalToWord(byte_index as integer {0..262144}),
            1, Zeros{PTO_XLEN} + byte_index);
    end;
    StartMemoryEventCapture(3);
    ExecuteScalarDMACopy64(source, destination);
    assert _MemoryEventCount == PTO_MODEL_MEMORY_EVENTS;
    for event_index = 0 to 7 do
        assert _MemoryEvents[[event_index]].kind == MemoryEvent_Load;
        assert _MemoryEvents[[event_index]].agent == 3;
        assert _MemoryEvents[[event_index]].size_bytes == 8;
    end;
    for event_index = 8 to 15 do
        assert _MemoryEvents[[event_index]].kind == MemoryEvent_Store;
        assert _MemoryEvents[[event_index]].agent == 3;
        assert _MemoryEvents[[event_index]].size_bytes == 8;
    end;
    StopMemoryEventCapture();
end;

func ConfigureOneElementMemoryTile(index: TileIndex)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestProductionTileEventExtraction()
begin
    ResetProfileState();
    let source_address = Zeros{PTO_XLEN} + 0x500;
    let destination_address = Zeros{PTO_XLEN} + 0x508;
    StopMemoryEventCapture();
    Store(source_address, 8, Zeros{PTO_XLEN} + 7);
    ConfigureOneElementMemoryTile(40);
    ConfigureOneElementMemoryTile(41);
    ConfigureOneElementMemoryTile(42);
    WriteTileElement(41, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(42, 0, 0, Zeros{PTO_XLEN});

    StartMemoryEventCapture(3);
    TLOAD(40, source_address, Zeros{PTO_XLEN} + 1);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].agent == 3;
    assert _MemoryEvents[[0]].address == source_address;
    StopMemoryEventCapture();

    StartMemoryEventCapture(3);
    TSTORE(destination_address, Zeros{PTO_XLEN} + 1, 41);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[0]].address == destination_address;
    StopMemoryEventCapture();

    StartMemoryEventCapture(2);
    MGATHER(40, source_address, 42);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    StopMemoryEventCapture();

    StartMemoryEventCapture(2);
    MSCATTER(destination_address, 41, 42);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    StopMemoryEventCapture();

    // Scalar and tile accesses occupy one event domain and one same-agent
    // program order; the tile load reads from the preceding scalar store.
    Store(source_address, 8, Zeros{PTO_XLEN} + 7);
    StartMemoryEventCapture(2);
    - = AddInitialWriteEvent(source_address, 8, Zeros{PTO_XLEN} + 7);
    Store(source_address, 8, Zeros{PTO_XLEN} + 8);
    TLOAD(40, source_address, Zeros{PTO_XLEN} + 1);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].agent == _MemoryEvents[[2]].agent;
    assert _MemoryEvents[[2]].read_from == 1;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();
    StopMemoryEventCapture();

    ClearFault();
    StartMemoryEventCapture(0);
    TPREFETCH(Ones{PTO_XLEN}, 2);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();

    ClearFault();
    StartMemoryEventCapture(0);
    TPREFETCH(source_address, 2);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    StopMemoryEventCapture();
end;

func TestTSOMixedSizeAndConditionalAtomicPolicy()
begin
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 4, Zeros{PTO_XLEN});
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();

    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 4, 4, Zeros{PTO_XLEN});
    assert !MemoryCandidateExecutionValid();

    ResetMemoryExecution();
    let initial = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1);
    let failed_cas = AddAtomicOutcomeEvent(0, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        MemoryOrder_Acquire, 0, FALSE);
    SetMemoryReadFrom(failed_cas, initial);
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();
end;

func TestTileMemoryEventOrdering()
begin
    ResetProfileState();
    ConfigureTile(4, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    StopMemoryEventCapture();
    Store(Zeros{PTO_XLEN} + 320, 8, Zeros{PTO_XLEN} + 0x55);
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 320, 8,
        Zeros{PTO_XLEN} + 0x55);
    SetBundleControlAttributeState(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE);
    TLOAD(4, Zeros{PTO_XLEN} + 320, Zeros{PTO_XLEN} + 1);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].order == MemoryOrder_Acquire;
    StopMemoryEventCapture();

    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 328, 8,
        Zeros{PTO_XLEN});
    SetBundleControlAttributeState(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE);
    TSTORE(Zeros{PTO_XLEN} + 328, Zeros{PTO_XLEN} + 1, 4);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].order == MemoryOrder_Release;
    StopMemoryEventCapture();

    ConfigureTile(5, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(6, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 22);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 384, 8, Zeros{PTO_XLEN});
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 384, 8,
        Zeros{PTO_XLEN});
    SetBundleControlAttributeState(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);
    MSCATTER(Zeros{PTO_XLEN} + 384, 5, 6);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].order == MemoryOrder_AcquireRelease;
    assert _MemoryEvents[[2]].order == MemoryOrder_AcquireRelease;
    assert _MemoryEvents[[1]].coherence_rank == 1;
    assert _MemoryEvents[[2]].coherence_rank == 2;
    assert MemoryCandidateExecutionValid();
    StopMemoryEventCapture();

    ClearFault();
    StartMemoryEventCapture(0);
    TLOAD(4, Zeros{PTO_XLEN} + 4096, Zeros{PTO_XLEN} + 1);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
end;

func TestDependencyMetadataIsNotFence()
begin
    StopMemoryEventCapture();
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    // Dependency annotations are scheduling metadata, not architectural
    // events. The candidate therefore contains only the memory operations.
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    - = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    let read_y = AddLoadEvent(0, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    let read_x = AddLoadEvent(1, Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN}, MemoryOrder_Relaxed);
    SetMemoryReadFrom(read_y, initial_y);
    SetMemoryReadFrom(read_x, initial_x);
    assert _MemoryEventCount == 6;
    for event_number = 0 to _MemoryEventCount - 1 do
        assert _MemoryEvents[[event_number]].kind != MemoryEvent_Fence;
    end;
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedTSO();
end;

func TestTSOConcurrency()
begin
    StopMemoryEventCapture();
    TestTSOStoreBufferingAllowed();
    TestTSOStoreBufferingFenceForbidden();
    TestTSOMessagePassing();
    TestTSOSameLocationAndAtomicity();
    TestTSOIRIWForbidden();
    TestProductionScalarEventExtraction();
    TestProductionReservationEventsAndCorners();
    TestProductionPairAndDMAEventExtraction();
    TestProductionTileEventExtraction();
    TestTSOMixedSizeAndConditionalAtomicPolicy();
    TestTileMemoryEventOrdering();
    TestDependencyMetadataIsNotFence();

    // Verifier bookkeeping accepts the last representable event, coherence
    // rank, source index, and read index. Overflow remains a nonarchitectural
    // assertion pinned by scripts/check-assertion-boundaries.
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
    assert _MemoryEventCount == PTO_MODEL_MEMORY_EVENTS - 1;
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
    TestTSOConcurrency();
    return 0;
end;
