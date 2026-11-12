// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-RESERVATION-INVALIDATION-001","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001"],"kind":"state-transition","summary":"conflicting writes invalidate LR reservations only in matching request domains, while explicitly excluded legacy writers preserve broad baseline invalidation","pass_condition":"InterCore Scalar, same-Core IntraCore Tile/IndexedGenerated/AMO, and capture-disabled IndexedGenerated/block memory-set writes invalidate matching live, saved, and trap-returning reservation contexts; incompatible scoped writes do not invalidate through the new scope rule","related_sources":["asl/scalar/model/agu/memory.asl","asl/scalar/model/amo/semantics.asl","asl/tile/model/memory/load-store.asl","asl/block/model/commit/effects.asl","asl/arch/state/trap-context.asl"]}
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
    _CurrentMemoryShareability = MemoryShareability_InterCore;
    let reserved = LoadReserved(address, 8, MemoryOrder_Relaxed);
    assert reserved == Zeros{PTO_XLEN} + 0x11;
    assert _ReservationValid;
    assert !_MemoryEventCaptureEnabled;

    SelectExecutionContext(1, 2);
    _CurrentMemoryShareability = MemoryShareability_InterCore;
    Store(address + 4, 4, Zeros{PTO_XLEN} + 0x22);
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    _CurrentMemoryShareability = MemoryShareability_InterCore;
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
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    - = LoadReserved(address, 8, MemoryOrder_Acquire);
    assert _ReservationValid;
    SetFault(Fault_IllegalInstruction, ReadTPC());
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert _ReservationValid;
    Store(address + 4, 4, Zeros{PTO_XLEN} + 0x33);
    assert !_ReservationValid;

    SelectExecutionContext(0, 1);
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
    SelectExecutionContext(0, 1);
    TSTORE(address, Zeros{PTO_XLEN} + 8, 0);
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    let failed_tstore = StoreConditional(address, 8,
        Zeros{PTO_XLEN} + 0x67, MemoryOrder_Relaxed);
    assert failed_tstore == Zeros{PTO_XLEN} + 1;

    - = LoadReserved(address, 8, MemoryOrder_Relaxed);
    SelectExecutionContext(0, 1);
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    let old = AtomicReadModifyWrite(address, 8, Atomic_ADD,
        Zeros{PTO_XLEN} + 1, MemoryOrder_AcquireRelease);
    assert old == Zeros{PTO_XLEN} + 0x55;
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;
    let failed_amo = StoreConditional(address, 8,
        Zeros{PTO_XLEN} + 0x77, MemoryOrder_Relaxed);
    assert failed_amo == Zeros{PTO_XLEN} + 1;
end;

func TestMismatchedScopeScalarWriteDoesNotInvalidateReservation()
begin
    ResetProfileState();
    let address = Zeros{PTO_XLEN} + 0xb00;
    Store(address, 8, Zeros{PTO_XLEN} + 0x11);
    SelectExecutionContext(0, 0);
    _CurrentMemoryShareability = MemoryShareability_Private;
    - = LoadReserved(address, 8, MemoryOrder_Relaxed);
    assert _ReservationValid;

    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    Store(address, 8, Zeros{PTO_XLEN} + 0x22);

    assert _ReservationValid;
    assert _ReservationShareability == MemoryShareability_Private;
end;

func TestLegacyExcludedMemorySetInvalidatesInactiveReservationCaptureOff()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x300;
    let core0 = LaunchKernelInvocation(0, entry);
    let core1 = LaunchKernelInvocation(1, entry);
    assert core0 == KernelLifecycle_Started;
    assert core1 == KernelLifecycle_Started;
    let address = Zeros{PTO_XLEN} + 0xa00;
    Store(address, 8, Zeros{PTO_XLEN} + 0x8877665544332211);

    SelectExecutionContext(1, 3);
    _CurrentMemoryShareability = MemoryShareability_Private;
    - = LoadReserved(address, 8, MemoryOrder_Relaxed);
    assert _ReservationValid;
    assert !_MemoryEventCaptureEnabled;

    SelectExecutionContext(0, 0);
    assert _PEExecutionContexts[[1]][[3]].reservation_valid;
    ExecuteMemorySet(address + 3, Zeros{PTO_XLEN} + 0xaa,
        Zeros{PTO_XLEN} + 1);
    assert !_PEExecutionContexts[[1]][[3]].reservation_valid;
    assert LoadTranslatedUnsigned(address + 3, 1) ==
        Zeros{PTO_XLEN} + 0xaa;

    SelectExecutionContext(1, 3);
    assert !_ReservationValid;
    _CurrentMemoryShareability = MemoryShareability_Private;
    let failed = StoreConditional(address, 8, Zeros{PTO_XLEN} + 0x99,
        MemoryOrder_Relaxed);
    assert failed == Zeros{PTO_XLEN} + 1;
end;

func TestIndexedGeneratedWriteInvalidatesSavedReservationCaptureOff()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x380;
    let started = LaunchKernelInvocation(0, entry);
    assert started == KernelLifecycle_Started;
    let address = Zeros{PTO_XLEN} + 0xc00;
    Store(address, 8, Zeros{PTO_XLEN} + 0x1122334455667788);

    SelectExecutionContext(0, 3);
    _CurrentMemoryShareability = MemoryShareability_IntraCore;
    - = LoadReserved(address, 8, MemoryOrder_Relaxed);
    assert _ReservationValid;
    assert _ReservationShareability == MemoryShareability_IntraCore;
    assert !_MemoryEventCaptureEnabled;

    SelectExecutionContext(0, 0);
    assert _PEExecutionContexts[[0]][[3]].reservation_valid;
    let written = StoreIndexedMemoryElement(address + 8, address + 8,
        TileDataType_U64, FALSE, Zeros{PTO_XLEN} + 0xaabbccddeeff0011);
    assert written == Zeros{PTO_XLEN} + 0xaabbccddeeff0011;
    assert !_PEExecutionContexts[[0]][[3]].reservation_valid;
    assert LoadTranslatedUnsigned(address + 8, 8) == written;
    assert _MemoryEventCount == 0;

    SelectExecutionContext(0, 3);
    assert !_ReservationValid;
    let failed = StoreConditional(address, 8, Zeros{PTO_XLEN} + 0x99,
        MemoryOrder_Relaxed);
    assert failed == Zeros{PTO_XLEN} + 1;
    assert _MemoryEventCount == 0;
end;

func main() => integer
begin
    TestRemoteScalarWriteInvalidatesOtherCoreReservation();
    TestTileAMOWritesInvalidateSavedAndTrapReservations();
    TestMismatchedScopeScalarWriteDoesNotInvalidateReservation();
    TestLegacyExcludedMemorySetInvalidatesInactiveReservationCaptureOff();
    TestIndexedGeneratedWriteInvalidatesSavedReservationCaptureOff();
    return 0;
end;
