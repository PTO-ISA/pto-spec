// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-LIFETIME-LOCAL-COHORT-CONSUME-003","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"A successful Atomic Local PE cohort consumes every captured payload only after the final participant succeeds","pass_condition":"encoded relative Function 1 requests capture PE0:T#5 and PE1:T#6 with their distinct epochs in one 1100 cohort; after PE0 completes and PE1 makes one beat both original payloads remain live and pinned; after PE1's final beat both requests complete, all three Atomic events have literal expected old/new values, both original live masks are cleared, and the cohort retires","related_sources":["asl/block/model/state/atomic-tstore-source-lifetime.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func CohortConsumeMask(pe: MemoryAgentId) => bits(4)
begin
    var mask = Zeros{4};
    mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
    return mask;
end;

pure func CohortConsumeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func CohortConsumeDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func CohortConsumeLastUse() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '101';
    instruction[19] = '1';
    instruction[26] = '1';
    return instruction;
end;

pure func CohortConsumeIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareCohortConsumePE(pe: MemoryAgentId, entry: Word, base: Word,
                            columns: integer {1..2})
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 7;
    _PEProgramOrder[[0]][[pe]] = 7;
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let started = ExecuteCommandInstruction(CohortConsumeStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + columns);
    let attributes = ExecuteCommandInstruction(CohortConsumeDATR(), 32);
    let source = ExecuteCommandInstruction(CohortConsumeLastUse(), 32);
    let address = ExecuteCommandInstruction(CohortConsumeIOR(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed && BundleAtomicTStoreSelected() &&
           BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].pe_mask == '1100' &&
           _BundleTileBindings[[0]].source0_selector == 0 &&
           _BundleTileBindings[[0]].source0_selector_relative &&
           _BundleTileBindings[[0]].source0 == 0 &&
           !_BundleTileBindings[[0]].source0_reuse;
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xb80;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    Store(Zeros{PTO_XLEN} + 0x600, 4, Zeros{PTO_XLEN} + 10);
    Store(Zeros{PTO_XLEN} + 0x700, 4, Zeros{PTO_XLEN} + 30);
    Store(Zeros{PTO_XLEN} + 0x704, 4, Zeros{PTO_XLEN} + 40);
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);

    SelectExecutionContext(0, 0);
    ConfigureTileForMask(5, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, CohortConsumeMask(0));
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(5);
    InstallRelativeTileFixture(0, 5);
    let epoch0 = LocalTilePayloadGeneration(0, 5);
    PrepareCohortConsumePE(0 as MemoryAgentId, entry,
        Zeros{PTO_XLEN} + 0x600, 1);
    let admitted0 = ExecuteBundleTileOperation();
    assert admitted0 && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot0 = FindCurrentAtomicTStoreObligation();
    assert slot0 >= 0;
    let request0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    assert request0.state == GMObligation_Issued &&
           request0.captured_atomic_tstore && request0.source_tile == 5 &&
           request0.atomic_tstore_source_payload_epoch == epoch0;
    let ordinal = request0.atomic_tstore_source_lifetime_ordinal;
    let lifetime_slot = FindBundleSourceLifetimeOrdinal(ordinal);
    assert ordinal > 0 && lifetime_slot >= 0 &&
           _BundleSourceLifetimes[[lifetime_slot]].participant_mask == '1100' &&
           _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1000';

    SelectExecutionContext(0, 1);
    ConfigureTileForMask(6, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, CohortConsumeMask(1));
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(6);
    InstallRelativeTileFixture(0, 6);
    let epoch1 = LocalTilePayloadGeneration(1, 6);
    PrepareCohortConsumePE(1 as MemoryAgentId, entry,
        Zeros{PTO_XLEN} + 0x700, 2);
    let admitted1 = ExecuteBundleTileOperation();
    assert admitted1 && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot1 = FindCurrentAtomicTStoreObligation();
    assert slot1 >= 0;
    let request1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert request1.state == GMObligation_Issued &&
           request1.captured_atomic_tstore && request1.source_tile == 6 &&
           request1.atomic_tstore_source_payload_epoch == epoch1 &&
           request1.atomic_tstore_source_lifetime_ordinal == ordinal;
    assert _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1100' &&
           _BundleSourceLifetimes[[lifetime_slot]].local_sources[[0]] == 5 &&
           _BundleSourceLifetimes[[lifetime_slot]].local_epochs[[0]] == epoch0 &&
           _BundleSourceLifetimes[[lifetime_slot]].local_sources[[1]] == 6 &&
           _BundleSourceLifetimes[[lifetime_slot]].local_epochs[[1]] == epoch1;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let done0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    let partial1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert done0.state == GMObligation_Completed &&
           partial1.state == GMObligation_Issued && partial1.irrevocable &&
           partial1.atomic_tstore_committed_count == 1 &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == '1000' &&
           LocalSourceLifetimePinned(0, 5) &&
           LocalSourceLifetimePinned(1, 6) && _MemoryEventCount == 2;
    SelectExecutionContext(0, 0);
    assert _TilePayloadLiveMasks[[5]] == CohortConsumeMask(0);
    SelectExecutionContext(0, 1);
    assert _TilePayloadLiveMasks[[6]] == CohortConsumeMask(1);

    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let complete0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    let complete1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert complete0.state == GMObligation_Completed &&
           complete1.state == GMObligation_Completed &&
           complete1.atomic_tstore_committed_count == 2 &&
           complete1.atomic_tstore_committed_elements[0] == '1' &&
           complete1.atomic_tstore_committed_elements[1] == '1' &&
           !_BundleSourceLifetimes[[lifetime_slot]].valid &&
           !LocalSourceLifetimePinned(0, 5) &&
           !LocalSourceLifetimePinned(1, 6) && _MemoryEventCount == 3;
    let event0 = _MemoryEvents[[0 as MemoryEventIndex]];
    let event1 = _MemoryEvents[[1 as MemoryEventIndex]];
    let event2 = _MemoryEvents[[2 as MemoryEventIndex]];
    assert event0.kind == MemoryEvent_Atomic && event0.committed &&
           event0.agent == 0 && event0.invocation == invocation &&
           event0.address == Zeros{PTO_XLEN} + 0x600 &&
           event0.read_value == Zeros{PTO_XLEN} + 10 &&
           event0.write_value == Zeros{PTO_XLEN} + 13;
    assert event1.kind == MemoryEvent_Atomic && event1.committed &&
           event1.agent == 1 && event1.invocation == invocation &&
           event1.address == Zeros{PTO_XLEN} + 0x700 &&
           event1.read_value == Zeros{PTO_XLEN} + 30 &&
           event1.write_value == Zeros{PTO_XLEN} + 34;
    assert event2.kind == MemoryEvent_Atomic && event2.committed &&
           event2.agent == 1 && event2.invocation == invocation &&
           event2.address == Zeros{PTO_XLEN} + 0x704 &&
           event2.read_value == Zeros{PTO_XLEN} + 40 &&
           event2.write_value == Zeros{PTO_XLEN} + 45;
    SelectExecutionContext(0, 0);
    assert LocalTilePayloadGeneration(0, 5) == epoch0 &&
           _TilePayloadLiveMasks[[5]] == Zeros{4};
    SelectExecutionContext(0, 1);
    assert LocalTilePayloadGeneration(1, 6) == epoch1 &&
           _TilePayloadLiveMasks[[6]] == Zeros{4};
    StopMemoryEventCapture();
    return 0;
end;
