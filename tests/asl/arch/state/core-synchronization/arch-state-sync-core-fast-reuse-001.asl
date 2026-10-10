// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYNC-CORE-FAST-REUSE-001","source":"asl/arch/state/core-synchronization.asl","requirements":["PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"fast PEs consume and reuse a released generation while an interrupted PE still holds its prior once-only release","pass_condition":"the slow handler preserves its generation-zero token while peers arrive at generation one; returning consumes generation zero once, joins the matching next site, releases generation one, and all participants consume the retained token once","related_sources":["asl/arch/state/core-synchronization.asl","asl/arch/state/trap-context.asl","asl/scalar/sys/SYNC.CORE.asl"]}
func TestFastPeersReuseWhileSlowPEHoldsRelease()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x600;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    _PC = entry + 4;
    _CurrentProgramOrder = 1;
    _PEProgramOrder[[0]][[0]] = 1;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    let old_parked_pc = ReadTPC();

    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _TrapContexts[[0]].valid;
    assert _ACRTrapAsynchronous[[0]];
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = entry + 4;
        _CurrentProgramOrder = 1;
        _PEProgramOrder[[0]][[pe]] = 1;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
    end;
    assert _CoreSyncRecords[[0]][[0]].released;
    assert _CoreSyncRecords[[0]][[0]].consumed == '0001';
    assert _PEReleaseValid[[0]][3] == '1';
    assert _PEReleaseGeneration[[0]][[0]] == 0;

    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
        assert _PEBarrierNextGeneration[[0]][[pe]] == 1;
        _PC = entry + 8;
        _CurrentProgramOrder = 2;
        _PEProgramOrder[[0]][[pe]] = 2;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
        assert _ScalarExecutionBlocked;
    end;
    assert _CoreSyncRecords[[0]][[0]].consumed == '0111';
    assert _CoreSyncRecords[[0]][[1]].valid;
    assert _CoreSyncRecords[[0]][[1]].arrived == '0111';
    assert !_CoreSyncRecords[[0]][[1]].released;
    assert _PEReleaseValid[[0]][3] == '1';
    assert _PEReleaseGeneration[[0]][[0]] == 0;

    SelectExecutionContext(0, 0);
    let recovered = RecoverTrapContext(0);
    assert recovered;
    assert ReadTPC() == old_parked_pc;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _PEBarrierNextGeneration[[0]][[0]] == 1;
    assert _CoreSyncRecords[[0]][[0]].consumed[3] == '1';
    _PC = entry + 8;
    _CurrentProgramOrder = 2;
    _PEProgramOrder[[0]][[0]] = 2;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert !_ScalarExecutionBlocked;
    assert _CoreSyncRecords[[0]][[1]].arrived == '1111';
    assert _CoreSyncRecords[[0]][[1]].released;
    assert _PEBarrierNextGeneration[[0]][[0]] == 2;

    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
        assert !_ScalarExecutionBlocked;
        assert _PEBarrierNextGeneration[[0]][[pe]] == 2;
    end;
    assert _CoreSyncRecords[[0]][[1]].consumed == '1111';
end;

func main() => integer
begin
    TestFastPeersReuseWhileSlowPEHoldsRelease();
    return 0;
end;
