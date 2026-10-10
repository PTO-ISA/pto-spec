// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-UNDEF-001","source":"asl/block/model/dispatch/gm-obligation-dispatch.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-INST-BLOCK-BSTART-TSTORE","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"An unpublished Shared TSTORE source keeps its captured kernel request fault-capable and blocks collective arrival until producer publication and real store completion.","pass_condition":"The encoded block's first attempt retains request, invocation, and Shared source identity without fault, GM effect, or binding consumption; SYNC.CORE cannot arrive while the source is unpublished; completing the real producer publication lets the unchanged request retry through actual probe/store/event completion, after which the collective can release.","related_sources":["asl/block/execution/BSTART.TSTORE.asl","asl/block/model/dispatch/shared-tlsu.asl","asl/tile/model/memory/shared-movement.asl","asl/tile/model/state/shared-registers.asl","asl/arch/memory-model/gm-obligations.asl","asl/arch/state/core-synchronization.asl"]}
pure func WaitingTSTORESharedSource(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[11:9] = '001';
    return instruction;
end;

func WriteUnreadyTStoreBarrier(entry: Word)
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
    let entry = Zeros{PTO_XLEN} + 0x200;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    StartMemoryEventCapture(0);
    let shared_tile_id = (Zeros{6} + 42) as SharedTileID;
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    let pending = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, _Tiles[[0]], '1000', FALSE);
    assert pending;
    assert SharedTileRecord(shared_tile_id).descriptor_valid;
    assert !SharedTilePublished(shared_tile_id);
    assert !SharedTileRecord(shared_tile_id).whole_parent_ready;

    let invocation = _KernelInvocationByCore[[0]];
    _PC = entry;
    var start = Zeros{64} + 0x00111181;
    start[31:27] = Zeros{5} + 27;
    let started = ExecuteCommandInstruction(start, 32);
    let bound = ExecuteCommandInstruction(
        WaitingTSTORESharedSource(Zeros{6} + 42), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    _CurrentProgramOrder = 3;
    _PEProgramOrder[[0]][[0]] = 3;
    let expected_submission_order = _CurrentProgramOrder + 1;
    let parked_tpc = ReadTPC();
    let waiting = ExecuteCommandInstruction(Zeros{64}, 16);
    assert waiting == CommandExecution_Executed &&
           _LastFault == Fault_None;
    assert _BundleActive;
    assert ReadTPC() == parked_tpc;
    assert !_BundleSharedBindings[[0]].consumed;
    let pending_obligation = _GMObligations[[0]][[0]][[0]];
    assert pending_obligation.active;
    assert pending_obligation.invocation == _KernelInvocationByCore[[0]];
    assert pending_obligation.instruction_pc == entry;
    assert pending_obligation.submission_order == expected_submission_order;
    assert pending_obligation.request_class == GMRequest_Tile;
    assert pending_obligation.may_fault;
    assert pending_obligation.state == GMObligation_Issued;
    assert pending_obligation.bundle_shared_bindings[[0]].valid;
    assert pending_obligation.bundle_shared_bindings[[0]].shared_tile_id ==
        shared_tile_id;
    assert _MemoryEventCount == 0;
    assert _Memory[[0]] == Zeros{8};

    let barrier_site = entry + 0x40;
    WriteUnreadyTStoreBarrier(barrier_site);
    // Other real PE streams reach the encoded barrier. Its automatic progress
    // walk must skip the unpublished-source generic request rather than run a
    // placeholder Local snapshot as a completed store.
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = barrier_site;
        let system_start = ExecuteNextPTOInstruction();
        assert system_start == PTOInstruction_Executed;
        let barrier_status = ExecuteNextPTOInstruction();
        assert barrier_status == PTOInstruction_Blocked;
        assert ReadTPC() == barrier_site + 4;
    end;
    SelectExecutionContext(0, 0);
    assert ReadTPC() == parked_tpc && _BundleActive;
    assert FindCoreSyncGenerationRecord(0, _KernelInvocationByCore[[0]], 0) ==
        0;
    assert _CoreSyncRecords[[0]][[0]].arrived == '0111';
    assert !_CoreSyncRecords[[0]][[0]].released;
    assert !CoreGMObligationsPermitArrival(0, 0,
        pending_obligation.invocation, pending_obligation.submission_order);
    assert !CoreGMObligationsComplete(0, 0, pending_obligation.invocation,
        pending_obligation.submission_order);
    assert pending_obligation.state == GMObligation_Issued;
    assert pending_obligation.may_fault;
    assert !pending_obligation.captured_tstore_progress;
    assert _MemoryEventCount == 0;

    let producer_completed = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, _Tiles[[0]], '1000', TRUE);
    assert producer_completed;
    assert SharedTileDescriptorLegal(shared_tile_id);
    assert SharedTileReadSchemaLegal(shared_tile_id, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor);
    let completed = ExecuteCommandInstruction(Zeros{64}, 16);
    assert _LastFault == Fault_None;
    assert completed == CommandExecution_Executed;
    let completed_obligation = _GMObligations[[0]][[0]][[0]];
    assert completed_obligation.identity == pending_obligation.identity;
    assert completed_obligation.invocation == pending_obligation.invocation;
    assert completed_obligation.state == GMObligation_Completed;
    assert !completed_obligation.may_fault;
    assert _MemoryEventCount > 0;
    var attributed_store_event_found = FALSE;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event = _MemoryEvents[[event_number as MemoryEventIndex]];
        if event.active && event.kind == MemoryEvent_Store &&
           event.core_identity == 0 &&
           event.origin == MemoryEventOrigin_Kernel &&
           event.invocation == invocation &&
           event.collective_history_sequence ==
               pending_obligation.collective_history_sequence &&
           event.address == Zeros{PTO_XLEN} &&
           event.write_value == Zeros{PTO_XLEN} + 0x5a &&
           event.committed then
            attributed_store_event_found = TRUE;
        end;
    end;
    assert attributed_store_event_found;
    assert !_BundleActive;
    assert _Memory[[0]] == Zeros{8} + 0x5a;

    _PC = barrier_site;
    let own_system_start = ExecuteNextPTOInstruction();
    assert own_system_start == PTOInstruction_Executed;
    let own_barrier = ExecuteNextPTOInstruction();
    assert own_barrier == PTOInstruction_Executed;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1111';
    assert _CoreSyncRecords[[0]][[0]].released;
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        let release_status = ExecuteNextPTOInstruction();
        assert release_status == PTOInstruction_Executed;
    end;
    assert _PEBarrierNextGeneration[[0]][[0]] == 1;
    assert _GMObligations[[0]][[0]][[0]].invocation == invocation;
    let ended = EndKernelInvocation(0);
    assert ended == KernelLifecycle_Started;
    StopMemoryEventCapture();
    return 0;
end;
