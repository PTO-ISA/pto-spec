// PTO-TEST: {"id":"PTO-AVS-ARCH-KERNEL-RUNTIME-STARTUP-LEADER-004","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-ARCH-RUNTIME-STARTUP-ABI-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-THREAD-ID-PE-IDENTITY-001"],"kind":"state-transition","summary":"a focused common-entry boundary witness lets PE0 publish shared initialization while PE1 through PE3 remain parked at startup generation zero","pass_condition":"all PEs begin at one entry with their own identity; workers preserve private preparation and do not advance past the encoded startup barrier; PE0 alone publishes shared initialization, arrives last, and releases every PE to observe the publication after the same collective","related_sources":["asl/arch/state/core-synchronization.asl","asl/scalar/model/sys/semantics.asl","asl/scalar/sys/SYNC.CORE.asl"]}
func WriteRuntimeStartupSyncProgram(entry: Word)
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

func main() => integer
begin
    ResetProfileState();
    StartMemoryEventCapture(0);
    let entry = Zeros{PTO_XLEN} + 0x400;
    let startup_site = entry + 4;
    let shared_address = Zeros{PTO_XLEN} + 0x900;
    let initialized_value = Zeros{PTO_XLEN} + 0x5a;
    WriteRuntimeStartupSyncProgram(entry);
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;

    // The leader establishes the common startup Block before any worker
    // arrives at its barrier, but does not perform shared initialization yet.
    SelectExecutionContext(0, 0);
    assert ReadTPC() == entry;
    let leader_identity = ReadSystemRegister(SystemRegister_THREAD_ID);
    assert leader_identity == Zeros{PTO_XLEN};
    WriteGPR(1, Zeros{PTO_XLEN} + 0x10);
    let leader_start = ExecuteNextPTOInstruction();
    assert leader_start == PTOInstruction_Executed;
    assert ReadTPC() == startup_site;

    // PE1 through PE3 perform only private preparation and arrive first at
    // generation zero. None may execute the post-startup body yet.
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        assert ReadTPC() == entry;
        let worker_identity = ReadSystemRegister(SystemRegister_THREAD_ID);
        assert worker_identity == Zeros{PTO_XLEN} + pe_number;
        WriteGPR(1, Zeros{PTO_XLEN} + pe_number + 0x10);
        let worker_start = ExecuteNextPTOInstruction();
        assert worker_start == PTOInstruction_Executed;
        let waiting = ExecuteNextPTOInstruction();
        assert waiting == PTOInstruction_Blocked;
        assert ReadTPC() == startup_site;
        assert ReadGPR(1) == Zeros{PTO_XLEN} + pe_number + 0x10;
        assert _PEBarrierNextGeneration[[0]][[pe]] == 0;
    end;
    let startup_slot = FindCoreSyncGenerationRecord(
        0, _KernelInvocationByCore[[0]], 0);
    assert startup_slot < PTO_MODEL_SYNC_GENERATIONS;
    assert _CoreSyncRecords[[0]][[startup_slot]].arrived == '0111';
    assert !_CoreSyncRecords[[0]][[startup_slot]].released;

    // PE0 is the sole shared initializer. Its store precedes its arrival at
    // the same encoded startup barrier used by every worker.
    SelectExecutionContext(0, 0);
    assert ReadTPC() == startup_site;
    StoreWithOrder(shared_address, 8, initialized_value,
        MemoryOrder_Relaxed);
    assert _MemoryEventCount == 1;
    let leader_release = ExecuteNextPTOInstruction();
    assert leader_release == PTOInstruction_Executed;
    assert ReadTPC() == startup_site + 4;
    assert _CoreSyncRecords[[0]][[startup_slot]].arrived == '1111';
    assert _CoreSyncRecords[[0]][[startup_slot]].released;

    // Every worker consumes its own release token once. A focused post-release
    // load observes PE0's committed publication and collective provenance.
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        let released = ExecuteNextPTOInstruction();
        assert released == PTOInstruction_Executed;
        assert ReadTPC() == startup_site + 4;
        assert _PEBarrierNextGeneration[[0]][[pe]] == 1;
        let observed = LoadWithOrder(shared_address, 8,
            MemoryOrder_Relaxed);
        assert observed == initialized_value;
        let read_event = (_MemoryEventCount - 1) as MemoryEventIndex;
        assert MemoryCollectiveSyncBefore(0 as MemoryEventIndex, read_event);
        assert ReadGPR(1) == Zeros{PTO_XLEN} + pe_number + 0x10;
    end;
    SelectExecutionContext(0, 0);
    let leader_observed = LoadWithOrder(shared_address, 8,
        MemoryOrder_Relaxed);
    assert leader_observed == initialized_value;
    let leader_read_event = (_MemoryEventCount - 1) as MemoryEventIndex;
    assert MemoryCollectiveSyncBefore(
        0 as MemoryEventIndex, leader_read_event);
    assert _PEBarrierNextGeneration[[0]][[0]] == 1;
    assert _PEReleaseValid[[0]] == Zeros{4};
    StopMemoryEventCapture();
    return 0;
end;

