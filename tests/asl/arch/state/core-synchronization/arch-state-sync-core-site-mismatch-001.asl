// PTO-TEST: {"id":"PTO-AVS-ARCH-SYNC-CORE-SITE-MISMATCH-001","source":"asl/arch/state/core-synchronization.asl","requirements":["PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"a participant at a different static site cannot join or release an incomplete collective generation","pass_condition":"one mismatched site leaves only the matching participants arrived, no new site record pairs with the old generation, and the missing participant never completes automatically","related_sources":["asl/scalar/sys/SYNC.CORE.asl"]}
func TestMismatchedSiteDoesNotPairOrRelease()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x800;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;

    SelectExecutionContext(0, 0);
    _PC = entry + 4;
    _CurrentProgramOrder = 1;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert !_CoreSyncRecords[[0]][[0]].released;

    SelectExecutionContext(0, 1);
    _PC = entry + 8;
    _CurrentProgramOrder = 1;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert !_CoreSyncRecords[[0]][[0]].released;

    for pe_number = 2 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = entry + 4;
        _CurrentProgramOrder = 1;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
        assert _ScalarExecutionBlocked;
    end;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1011';
    assert !_CoreSyncRecords[[0]][[0]].released;
    assert FindCoreSyncGenerationRecord(0, _KernelInvocationByCore[[0]], 0)
        == 0;
    assert _CoreSyncRecords[[0]][[0]].site == entry + 4;
    var valid_record_count : integer {0..PTO_MODEL_SYNC_GENERATIONS} = 0;
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        if _CoreSyncRecords[[0]][[slot]].valid then
            valid_record_count = (valid_record_count + 1) as
                integer {0..PTO_MODEL_SYNC_GENERATIONS};
        end;
    end;
    assert valid_record_count == 1;

    let aborted = AbortKernelInvocation(0);
    assert aborted == KernelLifecycle_Started;
    assert !_CoreSyncRecords[[0]][[0]].valid;
end;

func main() => integer
begin
    TestMismatchedSiteDoesNotPairOrRelease();
    return 0;
end;
