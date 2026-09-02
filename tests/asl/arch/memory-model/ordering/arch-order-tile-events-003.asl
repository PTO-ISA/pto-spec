// PTO-TEST: {"id":"PTO-AVS-ARCH-TILE-EVENTS-ORDER-003","source":"asl/arch/memory-model/ordering.asl","requirements":[],"kind":"ordering","summary":"tile and mixed-size memory operations emit ordered events","pass_condition":"tile and mixed-size event assertions hold","related_sources":[]}
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
    ConfigureTile(42, 256, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
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
    MGATHER(40, source_address, Zeros{PTO_XLEN} + 1, 42);
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    StopMemoryEventCapture();

    StartMemoryEventCapture(2);
    MSCATTER(destination_address, Zeros{PTO_XLEN} + 1, 41, 42);
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
    TPREFETCHAllPEs(Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 2,
        2, 1, 2, TileDataType_U8);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();

    ClearFault();
    StartMemoryEventCapture(0);
    TPREFETCHAllPEs(source_address, Zeros{PTO_XLEN} + 2,
        2, 1, 2, TileDataType_U8);
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 8;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].agent == 0;
    assert _MemoryEvents[[2]].agent == 1;
    assert _MemoryEvents[[4]].agent == 2;
    assert _MemoryEvents[[6]].agent == 3;
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

func main() => integer
begin
    ResetProfileState();
    TestProductionTileEventExtraction();
    TestTSOMixedSizeAndConditionalAtomicPolicy();
    return 0;
end;
