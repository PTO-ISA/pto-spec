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

func TestTileCASOrderCase(block_atomic: boolean, acquire: boolean,
                          release: boolean, expected_order: MemoryOrder)
begin
    Store(Zeros{PTO_XLEN} + 256, 8, Zeros{PTO_XLEN} + 10);
    ResetMemoryExecution();
    let initial = AddInitialWriteEvent(Zeros{PTO_XLEN} + 256, 8,
        Zeros{PTO_XLEN} + 10);
    SetBlockControlAttributeState(FALSE, block_atomic, acquire, release,
        FALSE, FALSE);
    assert CurrentBlockAtomic() == block_atomic;
    assert CurrentBlockMemoryOrder() == expected_order;
    ClearFault();
    MGATHER_CAS(0, Zeros{PTO_XLEN} + 256, 1, 2, 3);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[1]].order == expected_order;
    assert _MemoryEvents[[1]].read_value == Zeros{PTO_XLEN} + 10;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 11;
    assert _MemoryEvents[[1]].read_from == initial;
    assert MemoryCandidateExecutionValid();
end;

func TestTileMemoryEventOrdering()
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 11);

    // MGATHER.CAS is represented as an indivisible atomic event even without
    // the block-atomic hint. aq/rl select the exact event order.
    TestTileCASOrderCase(FALSE, FALSE, FALSE, MemoryOrder_Relaxed);
    TestTileCASOrderCase(TRUE, TRUE, FALSE, MemoryOrder_Acquire);
    TestTileCASOrderCase(TRUE, FALSE, TRUE, MemoryOrder_Release);
    TestTileCASOrderCase(TRUE, TRUE, TRUE, MemoryOrder_AcquireRelease);

    ConfigureTile(4, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    Store(Zeros{PTO_XLEN} + 320, 8, Zeros{PTO_XLEN} + 0x55);
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 320, 8,
        Zeros{PTO_XLEN} + 0x55);
    SetBlockControlAttributeState(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE);
    TLOAD(4, Zeros{PTO_XLEN} + 320);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].order == MemoryOrder_Acquire;

    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 328, 8,
        Zeros{PTO_XLEN});
    SetBlockControlAttributeState(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE);
    TSTORE(Zeros{PTO_XLEN} + 328, 4);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].order == MemoryOrder_Release;

    ConfigureTile(5, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(6, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 22);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 384, 8, Zeros{PTO_XLEN});
    ResetMemoryExecution();
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 384, 8,
        Zeros{PTO_XLEN});
    SetBlockControlAttributeState(FALSE, TRUE, TRUE, TRUE, FALSE, FALSE);
    MSCATTER(Zeros{PTO_XLEN} + 384, 5, 6);
    let atomic_scatter_winner = LoadUnsigned(
        Zeros{PTO_XLEN} + 384, 8);
    assert atomic_scatter_winner == Zeros{PTO_XLEN} + 22;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].order == MemoryOrder_AcquireRelease;
    assert _MemoryEvents[[2]].order == MemoryOrder_AcquireRelease;
    assert _MemoryEvents[[1]].coherence_rank == 1;
    assert _MemoryEvents[[2]].coherence_rank == 2;
    assert MemoryCandidateExecutionValid();

    ResetMemoryExecution();
    ClearFault();
    TLOAD(4, Zeros{PTO_XLEN} + 4096);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
end;

func TestDependencyMetadataIsNotFence()
begin
    ResetMemoryExecution();
    let initial_x = AddInitialWriteEvent(Zeros{PTO_XLEN}, 8,
        Zeros{PTO_XLEN});
    let initial_y = AddInitialWriteEvent(Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN});
    - = AddStoreEvent(0, Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 1,
        MemoryOrder_Relaxed, 1);
    NoteDependencyMetadata();
    - = AddStoreEvent(1, Zeros{PTO_XLEN} + 8, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    NoteDependencyMetadata();
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

func TestTileEventBoundIsPrecise()
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xaa);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 11);

    Store(Zeros{PTO_XLEN} + 400, 8, Zeros{PTO_XLEN} + 0x77);
    _MemoryEventCount = PTO_MODEL_MEMORY_EVENTS;
    ClearFault();
    TLOAD(0, Zeros{PTO_XLEN} + 400);
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xaa;

    ClearFault();
    TSTORE(Zeros{PTO_XLEN} + 400, 0);
    assert _LastFault == Fault_TileLegality;
    ClearFault();
    let preserved_store = LoadUnsigned(Zeros{PTO_XLEN} + 400, 8);
    assert preserved_store == Zeros{PTO_XLEN} + 0x77;

    ConfigureTile(4, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(5, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 22);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 416, 8, Zeros{PTO_XLEN} + 0x44);
    _MemoryEventCount = PTO_MODEL_MEMORY_EVENTS;
    ClearFault();
    MSCATTER(Zeros{PTO_XLEN} + 416, 4, 5);
    assert _LastFault == Fault_TileLegality;
    ClearFault();
    let preserved_scatter = LoadUnsigned(Zeros{PTO_XLEN} + 416, 8);
    assert preserved_scatter == Zeros{PTO_XLEN} + 0x44;

    Store(Zeros{PTO_XLEN} + 432, 8, Zeros{PTO_XLEN} + 10);
    _MemoryEventCount = PTO_MODEL_MEMORY_EVENTS;
    ClearFault();
    MGATHER_CAS(0, Zeros{PTO_XLEN} + 432, 1, 2, 3);
    assert _LastFault == Fault_TileLegality;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xaa;
    ClearFault();
    let preserved_cas = LoadUnsigned(Zeros{PTO_XLEN} + 432, 8);
    assert preserved_cas == Zeros{PTO_XLEN} + 10;

    ConfigureTile(10, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x99);
    WriteGPR(2, Zeros{PTO_XLEN} + 448);
    Store(Zeros{PTO_XLEN} + 448, 8, Zeros{PTO_XLEN} + 0x55);
    ResetBlockControlState();
    SetBlockScalarBinding(0, 0, 2, 0, 0, 1);
    SetBlockTileBinding(0, FALSE, 0, 0, TRUE, FALSE, 10, 0,
        FALSE, FALSE, TRUE);
    SetBlockTileOperationSelection('01', '000000000001',
        Zeros{5} + 24);
    _MemoryEventCount = PTO_MODEL_MEMORY_EVENTS;
    ClearFault();
    let status = ExecuteSelectedBlockTileOperation();
    FinalizeBlockTileAttempt(status);
    assert status == TileExecution_Faulted;
    assert _LastFault == Fault_TileLegality;
    assert _Tiles[[10]].allocated;
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 0x99;
    ClearFault();
    let preserved_lifetime_store = LoadUnsigned(
        Zeros{PTO_XLEN} + 448, 8);
    assert preserved_lifetime_store == Zeros{PTO_XLEN} + 0x55;
    ResetMemoryExecution();
end;

func TestTSOConcurrency()
begin
    TestTSOStoreBufferingAllowed();
    TestTSOStoreBufferingFenceForbidden();
    TestTSOMessagePassing();
    TestTSOSameLocationAndAtomicity();
    TestTSOIRIWForbidden();
    TestTileMemoryEventOrdering();
    TestDependencyMetadataIsNotFence();
    TestTileEventBoundIsPrecise();
end;
