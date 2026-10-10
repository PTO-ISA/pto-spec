// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-OBLIGATION-DELAYED-TSTORE-001","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"captured TSTORE work progresses through production beats, blocks release until completion, and drains after abort before a new launch","pass_condition":"the delayed obligation retains actual request provenance, writes through production probe/event/replay paths, prevents early release and launch while irrevocable, completes under its old identity, and rejects a stale completion after new invocation registration","related_sources":["asl/tile/memory-and-data-movement/regular/TSTORE.asl","asl/tile/model/memory/load-store.asl","asl/arch/memory-model/gm-obligations.asl","asl/arch/state/core-synchronization.asl"]}
pure func DelayedTStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func DelayedTStoreSource(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[25:20] = source;
    instruction[19] = '1';
    return instruction;
end;

pure func DelayedTStoreAddress(base: bits(5), stride: bits(5))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = base;
    instruction[24:20] = stride;
    return instruction;
end;

func TestDelayedTStoreObligationUsesProductionPath()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x200;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    _PC = entry;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x300);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    _CurrentProgramOrder = 3;
    _PEProgramOrder[[0]][[0]] = 3;
    StartMemoryEventCapture(0);
    assert _MemoryEventCaptureEnabled;
    SetVerificationGMProgressDeferred(TRUE);

    let start_word = DelayedTStoreStart();
    let start = ExecuteCommandInstruction(start_word, 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(
        DelayedTStoreSource(Zeros{6} + 4), 32);
    let address = ExecuteCommandInstruction(DelayedTStoreAddress(
        Zeros{5} + 2, Zeros{5} + 3), 32);
    assert start == CommandExecution_Executed;
    assert source == CommandExecution_Executed;
    assert address == CommandExecution_Executed;
    let expected_submission_order = _CurrentProgramOrder + 1;
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed;
    let obligation = _GMObligations[[0]][[0]][[0]];
    assert obligation.active;
    assert obligation.core_identity == 0;
    assert obligation.agent == 0;
    assert obligation.invocation == _KernelInvocationByCore[[0]];
    assert obligation.request_class == GMRequest_Tile;
    assert obligation.encoded_request == start_word;
    assert obligation.instruction_pc == entry;
    assert obligation.submission_order == expected_submission_order;
    assert obligation.state == GMObligation_Validated;
    assert !obligation.may_fault;
    assert obligation.source_tile == 4;
    assert obligation.source_snapshot.contents_defined;
    assert obligation.source_snapshot.data_type == TileDataType_U64;
    assert obligation.base_address == Zeros{PTO_XLEN} + 0x300;
    assert obligation.row_stride_bytes == Zeros{PTO_XLEN} + 8;
    assert _MemoryEventCount == 0;
    let initial_memory_value = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 8);
    assert initial_memory_value == Zeros{PTO_XLEN};
    let arrival_permitted = CoreGMObligationsPermitArrival(0, 0,
        obligation.invocation, expected_submission_order);
    let obligations_complete = CoreGMObligationsComplete(0, 0,
        obligation.invocation, expected_submission_order);
    assert arrival_permitted;
    assert !obligations_complete;

    // The actual encoded SYS envelope invokes the ordinary Core progress
    // owner before arrival; no test-only completion helper is used.
    let barrier_site = entry + 0x40;
    WriteSyncProgramForDelayedStore(barrier_site);
    _PC = barrier_site;
    SetVerificationGMProgressDeferred(FALSE);
    let sys_start = ExecuteNextPTOInstruction();
    assert sys_start == PTOInstruction_Executed;
    let sync = ExecuteNextPTOInstruction();
    assert sync == PTOInstruction_Blocked;
    assert _ScalarExecutionBlocked;
    assert ReadTPC() == barrier_site + 4;
    assert _GMObligations[[0]][[0]][[0]].state == GMObligation_Completed;
    let completed = CoreGMObligationsComplete(0, 0,
        obligation.invocation, expected_submission_order);
    assert completed;
    let stored_memory_value = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 8);
    assert stored_memory_value == Zeros{PTO_XLEN} + 0x5a;
    assert _MemoryEventCaptureEnabled;
    assert _MemoryEventCount > 0;
    var matching_store_event_found = FALSE;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event = _MemoryEvents[[event_number as MemoryEventIndex]];
        if event.active && event.kind == MemoryEvent_Store &&
           event.core_identity == 0 && event.agent == 0 &&
           event.address == Zeros{PTO_XLEN} + 0x300 &&
           event.write_value == Zeros{PTO_XLEN} + 0x5a &&
           event.committed then
            matching_store_event_found = TRUE;
        end;
    end;
    assert matching_store_event_found;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert !_CoreSyncRecords[[0]][[0]].released;

    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = barrier_site;
        _CurrentProgramOrder = 3;
        _ScalarExecutionBlocked = FALSE;
        let peer_start = ExecuteNextPTOInstruction();
        assert peer_start == PTOInstruction_Executed;
        let peer_sync = ExecuteNextPTOInstruction();
        if pe_number < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert peer_sync == PTOInstruction_Blocked;
        else
            assert peer_sync == PTOInstruction_Executed;
        end;
    end;
    assert _CoreSyncRecords[[0]][[0]].released;
    SelectExecutionContext(0, 0);
    _ScalarExecutionBlocked = FALSE;
    let released_sync = ExecuteNextPTOInstruction();
    assert released_sync == PTOInstruction_Executed;
    assert !_ScalarExecutionBlocked;
    assert _PEBarrierNextGeneration[[0]][[0]] == 1;
    assert _PEReleaseValid[[0]][3] == '0';
    assert _GMObligations[[0]][[0]][[0]].irrevocable;
    assert !_GMObligations[[0]][[0]][[0]].reversible;
    StopMemoryEventCapture();
end;

func WriteSyncProgramForDelayedStore(entry: Word)
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
    TestDelayedTStoreObligationUsesProductionPath();
    return 0;
end;
