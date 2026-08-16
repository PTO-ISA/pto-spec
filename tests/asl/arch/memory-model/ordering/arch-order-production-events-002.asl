// PTO-TEST: {"id":"PTO-AVS-ARCH-PRODUCTION-EVENTS-ORDER-002","source":"asl/arch/memory-model/ordering.asl","requirements":[],"kind":"ordering","summary":"scalar, reservation, pair, and DMA execution emit production events","pass_condition":"production event extraction assertions hold","related_sources":[]}
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
    // Pair-load execution below selects PE0, so initialize PE0's private GPR
    // explicitly instead of inheriting the preceding reservation test's PE1.
    WritePEGPR(0, 2, source);
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

func main() => integer
begin
    ResetProfileState();
    TestProductionScalarEventExtraction();
    TestProductionReservationEventsAndCorners();
    TestProductionPairAndDMAEventExtraction();
    return 0;
end;
