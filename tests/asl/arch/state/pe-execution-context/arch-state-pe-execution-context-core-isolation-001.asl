// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYNC-CORE-CORE-ISOLATION-001","source":"asl/arch/state/pe-execution-context.asl","requirements":["PTO-REQ-STATE-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-MEMORY-MODEL-COLLECTIVE-SYNC-001"],"kind":"state-transition","summary":"two modeled Cores retain separate PE state and synchronization records while sharing GM","pass_condition":"the fixed four-PE membership is unchanged, Core-local registers and Tiles do not alias, event agent equality includes Core identity, and GM remains system-shared","related_sources":["asl/arch/state/core-synchronization.asl","asl/arch/memory-model/memory-events.asl"]}
func TestCoreExecutionStateIsIsolatedAndGMIsShared()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x500;
    let launch0 = LaunchKernelInvocation(0, entry);
    let launch1 = LaunchKernelInvocation(1, entry);
    assert launch0 == KernelLifecycle_Started;
    assert launch1 == KernelLifecycle_Started;
    assert PTO_MODEL_MEMORY_AGENTS == 4;

    SelectExecutionContext(0, 0);
    _PC = entry + 0x10;
    WriteGPR(5, Zeros{PTO_XLEN} + 0x11);
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x101);

    SelectExecutionContext(1, 0);
    assert ReadTPC() == entry;
    assert !_Tiles[[4]].allocated;
    WriteGPR(5, Zeros{PTO_XLEN} + 0x22);
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x202);

    SelectExecutionContext(0, 0);
    assert ReadTPC() == entry + 0x10;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 0x101;
    _PC = entry + 4;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _CoreSyncRecords[[0]][[0]].valid;
    assert _CoreSyncRecords[[0]][[0]].core_identity == 0;

    SelectExecutionContext(1, 0);
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x22;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 0x202;
    _PC = entry + 4;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _CoreSyncRecords[[1]][[0]].valid;
    assert _CoreSyncRecords[[1]][[0]].core_identity == 1;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert _CoreSyncRecords[[1]][[0]].arrived == '1000';

    ResetMemoryExecution();
    SelectExecutionContext(0, 0);
    let event0 = AddStoreEvent(0, Zeros{PTO_XLEN} + 0x900, 8,
        Zeros{PTO_XLEN} + 1, MemoryOrder_Relaxed, 1);
    SelectExecutionContext(1, 0);
    let event1 = AddStoreEvent(0, Zeros{PTO_XLEN} + 0x900, 8,
        Zeros{PTO_XLEN} + 2, MemoryOrder_Relaxed, 1);
    assert _MemoryEvents[[event0]].core_identity == 0;
    assert _MemoryEvents[[event1]].core_identity == 1;
    assert !MemoryEventsSameAgent(_MemoryEvents[[event0]],
        _MemoryEvents[[event1]]);

    let gm_address = Zeros{PTO_XLEN} + 0x600;
    WriteMemoryByte(gm_address, Zeros{8} + 0x6d);
    SelectExecutionContext(1, 2);
    let shared_gm = LoadUnsigned(gm_address, 1);
    assert shared_gm == Zeros{PTO_XLEN} + 0x6d;

    let aborted0 = AbortKernelInvocation(0);
    let aborted1 = AbortKernelInvocation(1);
    assert aborted0 == KernelLifecycle_Started;
    assert aborted1 == KernelLifecycle_Started;
end;

func main() => integer
begin
    TestCoreExecutionStateIsIsolatedAndGMIsShared();
    return 0;
end;
