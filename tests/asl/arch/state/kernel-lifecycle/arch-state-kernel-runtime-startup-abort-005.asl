// PTO-TEST: {"id":"PTO-AVS-ARCH-KERNEL-RUNTIME-STARTUP-ABORT-005","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-ARCH-RUNTIME-STARTUP-ABI-001","PTO-ARCH-RUNTIME-STARTUP-LIFETIME-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","summary":"a focused startup boundary witness keeps workers parked without their leader and isolates a same-entry relaunch from stale synchronization state","pass_condition":"all PEs begin at one entry with their own identity; workers remain parked when PE0 never arrives; abort preserves PE0's committed initialization effect while retiring the incomplete generation, and a same-entry fresh invocation requires all four new arrivals before release","related_sources":["asl/arch/state/core-synchronization.asl","asl/scalar/model/sys/semantics.asl","asl/scalar/sys/SYNC.CORE.asl"]}
func WriteRuntimeAbortSyncProgram(entry: Word)
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

func ParkRuntimeWorkers(entry: Word)
begin
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        assert ReadTPC() == entry;
        let worker_identity = ReadSystemRegister(SystemRegister_THREAD_ID);
        assert worker_identity == Zeros{PTO_XLEN} + pe_number;
        let worker_start = ExecuteNextPTOInstruction();
        assert worker_start == PTOInstruction_Executed;
        let waiting = ExecuteNextPTOInstruction();
        assert waiting == PTOInstruction_Blocked;
        assert ReadTPC() == entry + 4;
        assert _PEBarrierNextGeneration[[0]][[pe]] == 0;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    let first_entry = Zeros{PTO_XLEN} + 0x400;
    let shared_address = Zeros{PTO_XLEN} + 0xa00;
    let initialized_value = Zeros{PTO_XLEN} + 0x71;
    WriteRuntimeAbortSyncProgram(first_entry);

    let launched = LaunchKernelInvocation(0, first_entry);
    assert launched == KernelLifecycle_Started;
    let first_invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    assert ReadTPC() == first_entry;
    let first_leader_identity = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert first_leader_identity == Zeros{PTO_XLEN};
    let first_leader_start = ExecuteNextPTOInstruction();
    assert first_leader_start == PTOInstruction_Executed;
    StoreWithOrder(shared_address, 8, initialized_value,
        MemoryOrder_Relaxed);
    // A fatal startup failure prevents PE0 from arriving. Workers cannot infer
    // success from the committed initialization fragment or from elapsed time.
    ParkRuntimeWorkers(first_entry);
    let first_slot = FindCoreSyncGenerationRecord(0, first_invocation, 0);
    assert first_slot < PTO_MODEL_SYNC_GENERATIONS;
    assert _CoreSyncRecords[[0]][[first_slot]].arrived == '0111';
    assert !_CoreSyncRecords[[0]][[first_slot]].released;
    assert _PEReleaseValid[[0]] == Zeros{4};

    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
    assert !_KernelInvocationActiveByCore[[0]];
    assert FindCoreSyncGenerationRecord(0, first_invocation, 0) ==
        PTO_MODEL_SYNC_GENERATIONS;
    assert _PEReleaseValid[[0]] == Zeros{4};
    let preserved_after_abort = LoadUnsigned(shared_address, 8);
    assert preserved_after_abort == initialized_value;

    let relaunched = LaunchKernelInvocation(0, first_entry);
    assert relaunched == KernelLifecycle_Started;
    let second_invocation = _KernelInvocationByCore[[0]];
    assert second_invocation != first_invocation;
    SelectExecutionContext(0, 0);
    assert ReadTPC() == first_entry;
    let second_leader_identity = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert second_leader_identity == Zeros{PTO_XLEN};
    let fresh_leader_start = ExecuteNextPTOInstruction();
    assert fresh_leader_start == PTOInstruction_Executed;
    assert ReadTPC() == first_entry + 4;
    ParkRuntimeWorkers(first_entry);
    let second_slot = FindCoreSyncGenerationRecord(0, second_invocation, 0);
    assert second_slot < PTO_MODEL_SYNC_GENERATIONS;
    assert _CoreSyncRecords[[0]][[second_slot]].arrived == '0111';
    assert !_CoreSyncRecords[[0]][[second_slot]].released;
    assert _PEReleaseValid[[0]] == Zeros{4};

    // The new leader must execute the fresh common entry and arrive in the new
    // invocation. No arrival or release token from the aborted run counts.
    SelectExecutionContext(0, 0);
    let fresh_leader_release = ExecuteNextPTOInstruction();
    assert fresh_leader_release == PTOInstruction_Executed;
    assert _CoreSyncRecords[[0]][[second_slot]].arrived == '1111';
    assert _CoreSyncRecords[[0]][[second_slot]].released;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        let released = ExecuteNextPTOInstruction();
        assert released == PTOInstruction_Executed;
        assert ReadTPC() == first_entry + 8;
    end;
    SelectExecutionContext(0, 0);
    assert _PEBarrierNextGeneration[[0]][[0]] == 1;
    assert _PEReleaseValid[[0]] == Zeros{4};
    let preserved_after_relaunch = LoadUnsigned(shared_address, 8);
    assert preserved_after_relaunch == initialized_value;
    return 0;
end;
