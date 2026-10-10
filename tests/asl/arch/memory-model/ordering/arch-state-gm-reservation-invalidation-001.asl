// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-RESERVATION-INVALIDATION-001","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001"],"kind":"state-transition","summary":"committed ordinary writes invalidate conflicting LR reservations in live, saved, and trap-returning PE contexts","pass_condition":"Scalar, Tile, and AMO writes from another PE/Core invalidate the shared GM line reservation before SC or trap return can reuse it; nonconflicting lines remain independent","related_sources":["asl/scalar/model/agu/memory.asl","asl/scalar/model/amo/semantics.asl","asl/tile/model/memory/load-store.asl","asl/arch/state/trap-context.asl"]}
func TestRemoteScalarWriteInvalidatesOtherCoreReservation()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let core0 = LaunchKernelInvocation(0, entry);
    let core1 = LaunchKernelInvocation(1, entry);
    assert core0 == KernelLifecycle_Started;
    assert core1 == KernelLifecycle_Started;
    let address = Zeros{PTO_XLEN} + 0x800;
    Store(address, 8, Zeros{PTO_XLEN} + 0x11);
    SelectExecutionContext(0, 0);
    let reserved = LoadReserved(address, 8, MemoryOrder_Relaxed);
    assert reserved == Zeros{PTO_XLEN} + 0x11;
    assert _ReservationValid;

    SelectExecutionContext(1, 2);
    Store(address + 4, 4, Zeros{PTO_XLEN} + 0x22);
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    let failed = StoreConditional(address, 8, Zeros{PTO_XLEN} + 0x33,
        MemoryOrder_Relaxed);
    assert failed == Zeros{PTO_XLEN} + 1;
    let combined = LoadUnsigned(address, 8);
    assert combined == Zeros{PTO_XLEN} + 0x0000002200000011;
end;

func TestTileAMOWritesInvalidateSavedAndTrapReservations()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x200;
    let core0 = LaunchKernelInvocation(0, entry);
    let core1 = LaunchKernelInvocation(1, entry);
    assert core0 == KernelLifecycle_Started;
    assert core1 == KernelLifecycle_Started;
    let address = Zeros{PTO_XLEN} + 0x900;
    Store(address, 8, Zeros{PTO_XLEN} + 0x44);

    SelectExecutionContext(0, 0);
    - = LoadReserved(address, 8, MemoryOrder_Acquire);
    assert _ReservationValid;
    SetFault(Fault_IllegalInstruction, ReadTPC());
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert _ReservationValid;
    Store(address + 4, 4, Zeros{PTO_XLEN} + 0x33);
    assert !_ReservationValid;

    SelectExecutionContext(1, 1);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x55);
    TSTORE(address, Zeros{PTO_XLEN} + 8, 0);
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    assert !_ReservationValid;
    let failed_tile = StoreConditional(address, 8,
        Zeros{PTO_XLEN} + 0x66, MemoryOrder_Relaxed);
    assert failed_tile == Zeros{PTO_XLEN} + 1;

    - = LoadReserved(address, 8, MemoryOrder_Relaxed);
    SelectExecutionContext(1, 1);
    TSTORE(address, Zeros{PTO_XLEN} + 8, 0);
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    let failed_tstore = StoreConditional(address, 8,
        Zeros{PTO_XLEN} + 0x67, MemoryOrder_Relaxed);
    assert failed_tstore == Zeros{PTO_XLEN} + 1;

    - = LoadReserved(address, 8, MemoryOrder_Relaxed);
    SelectExecutionContext(1, 1);
    let old = AtomicReadModifyWrite(address, 8, Atomic_ADD,
        Zeros{PTO_XLEN} + 1, MemoryOrder_AcquireRelease);
    assert old == Zeros{PTO_XLEN} + 0x55;
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    let failed_amo = StoreConditional(address, 8,
        Zeros{PTO_XLEN} + 0x77, MemoryOrder_Relaxed);
    assert failed_amo == Zeros{PTO_XLEN} + 1;
end;

func main() => integer
begin
    TestRemoteScalarWriteInvalidatesOtherCoreReservation();
    TestTileAMOWritesInvalidateSavedAndTrapReservations();
    return 0;
end;
