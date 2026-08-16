// PTO-TEST: {"id":"PTO-AVS-ARCH-DEPENDENCIES-ORDER-004","source":"asl/arch/memory-model/ordering.asl","requirements":[],"kind":"ordering","summary":"tile ordering and dependency metadata remain distinct from fences","pass_condition":"tile ordering and dependency assertions hold","related_sources":[]}
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

func main() => integer
begin
    ResetProfileState();
    TestTileMemoryEventOrdering();
    TestDependencyMetadataIsNotFence();
    return 0;
end;
