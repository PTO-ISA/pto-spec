// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYNC-CORE-RENDEZVOUS-001","source":"asl/scalar/sys/SYNC.CORE.asl","requirements":["PTO-SYNC-CORE-DECISION-BINDING-001","PTO-INST-SCALAR-SYNC-CORE","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"the encoded SYNC.CORE blocks without advancing and releases all four Core participants once","pass_condition":"four PE contexts execute the exact SYS envelope, remain at the barrier until completion, and consume the retained release once","related_sources":["asl/arch/state/core-synchronization.asl","asl/arch/state/kernel-lifecycle.asl","asl/arch/dispatch/top-level.asl"]}
func WriteSyncProgram(entry: Word)
begin
    WriteMemoryByte(entry, Zeros{8} + 0x81);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x10);
    WriteMemoryByte(entry + 2, Zeros{8});
    WriteMemoryByte(entry + 3, Zeros{8});
    WriteMemoryByte(entry + 4, Zeros{8} + 0x2b);
    WriteMemoryByte(entry + 5, Zeros{8} + 0xa0);
    WriteMemoryByte(entry + 6, Zeros{8} + 0x30);
    WriteMemoryByte(entry + 7, Zeros{8} + 0x03);
    WriteMemoryByte(entry + 8, Zeros{8} + 1);
    WriteMemoryByte(entry + 9, Zeros{8});
    WriteMemoryByte(entry + 10, Zeros{8});
    WriteMemoryByte(entry + 11, Zeros{8});
    WriteMemoryByte(entry + 12, Zeros{8});
    WriteMemoryByte(entry + 13, Zeros{8});
end;

func TestEncodedHandlerSyncCannotJoin()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x300;
    let handler_entry = Zeros{PTO_XLEN} + 0x500;
    WriteSyncProgram(handler_entry);
    _ExtendedSystemRegisters[[0x0f01]] = handler_entry;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    StartMemoryEventCapture(0);
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 7);
    assert CurrentACR() == 0;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    let handler_store_address = Zeros{PTO_XLEN} + 0x780;
    StoreWithOrder(handler_store_address, 8, Zeros{PTO_XLEN} + 0x99,
        MemoryOrder_Relaxed);
    assert _MemoryEventCount == 1;
    let handler_store = _MemoryEvents[[0]];
    assert handler_store.kind == MemoryEvent_Store;
    assert handler_store.origin == MemoryEventOrigin_Handler;

    let start_status = ExecuteNextPTOInstruction();
    assert start_status == PTOInstruction_Executed;
    let sync_status = ExecuteNextPTOInstruction();
    assert sync_status == PTOInstruction_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert FindCoreSyncGenerationRecord(0, _CurrentKernelInvocation, 0) ==
        PTO_MODEL_SYNC_GENERATIONS;
    assert _MemoryEvents[[0]].origin == MemoryEventOrigin_Handler;
    StopMemoryEventCapture();
end;

func TestEncodedFourPEBarrier()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    WriteSyncProgram(entry);
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        let start_status = ExecuteNextPTOInstruction();
        assert start_status == PTOInstruction_Executed;
        assert ReadTPC() == entry + 4;
        let status = ExecuteNextPTOInstruction();
        if pe_number < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert status == PTOInstruction_Blocked;
            assert ReadTPC() == entry + 4;
            assert _PEBarrierNextGeneration[[0]][[pe]] == 0;
        else
            assert status == PTOInstruction_Executed;
            assert ReadTPC() == entry + 8;
        end;
    end;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        assert ReadTPC() == entry + 4;
        let release_status = ExecuteNextPTOInstruction();
        assert release_status == PTOInstruction_Executed;
        assert ReadTPC() == entry + 8;
        assert _PEBarrierNextGeneration[[0]][[pe]] == 1;
    end;
    assert _PEBarrierNextGeneration[[0]][[3]] == 1;
    assert _PEReleaseValid[[0]] == Zeros{4};
    let ended = EndKernelInvocation(0);
    assert ended == KernelLifecycle_Started;
end;

func TestHandlerCannotJoinCoreBarrier()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    assert FindCoreSyncGenerationRecord(0, _CurrentKernelInvocation, 0) ==
        PTO_MODEL_SYNC_GENERATIONS;
    let recovered = RecoverTrapContext(CurrentACR());
    assert recovered;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
end;

func main() => integer
begin
    TestEncodedFourPEBarrier();
    TestHandlerCannotJoinCoreBarrier();
    TestEncodedHandlerSyncCannotJoin();
    return 0;
end;
