// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-LIFETIME-LOCAL-COHORT-002","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"Atomic Local last-use joins the declared PE cohort while pinning and consuming each PE's captured generation independently","pass_condition":"encoded relative Function 1 requests from PE0 and PE1 resolve selector 0 to different physical source banks and capture distinct epochs in one 1100 cohort; after PE0 completes and PE1 makes one partial beat only PE0's completion bit is set and both original tuples remain pinned; replacing both banks before PE1's final beat leaves both replacement epochs intact while each original tuple is consumed exactly once and the lifetime row retires","related_sources":["asl/block/model/state/atomic-tstore-source-lifetime.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func LocalCohortAllocationMask(pe: MemoryAgentId) => bits(4)
begin
    var mask = Zeros{4};
    mask[PTOPEMaskBitOfPEIdentity(pe)] = '1';
    return mask;
end;

pure func LocalCohortStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func LocalCohortDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func LocalCohortLastUse() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '101';
    instruction[19] = '1';
    instruction[26] = '1';
    return instruction;
end;

pure func LocalCohortIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func PrepareLocalCohortPE(pe: MemoryAgentId, entry: Word, base: Word,
                          physical_source: TileIndex,
                          columns: integer {1..2}, value: Word)
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 7;
    _PEProgramOrder[[0]][[pe]] = 7;
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(LocalCohortStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + columns);
    let attributes = ExecuteCommandInstruction(LocalCohortDATR(), 32);
    let source = ExecuteCommandInstruction(LocalCohortLastUse(), 32);
    let address = ExecuteCommandInstruction(LocalCohortIOR(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() && BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].pe_mask == '1100' &&
           _BundleTileBindings[[0]].source0_valid &&
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
    Store(Zeros{PTO_XLEN} + 0x604, 4, Zeros{PTO_XLEN} + 20);
    Store(Zeros{PTO_XLEN} + 0x700, 4, Zeros{PTO_XLEN} + 30);
    Store(Zeros{PTO_XLEN} + 0x704, 4, Zeros{PTO_XLEN} + 40);
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);

    SelectExecutionContext(0, 0);
    ConfigureTileForMask(5, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, LocalCohortAllocationMask(0));
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(5);
    InstallRelativeTileFixture(0, 5);
    let epoch0 = LocalTilePayloadGeneration(0, 5);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x600);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    PrepareLocalCohortPE(0 as MemoryAgentId, entry,
        Zeros{PTO_XLEN} + 0x600, 5 as TileIndex, 1,
        Zeros{PTO_XLEN} + 3);
    let admitted0 = ExecuteBundleTileOperation();
    assert admitted0 && _LastFault == Fault_None && _MemoryEventCount == 0 &&
           _BundleTileBindings[[0]].source0 == 5;
    let slot0 = FindCurrentAtomicTStoreObligation();
    assert slot0 >= 0;
    let request0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    assert request0.state == GMObligation_Issued;
    assert request0.captured_atomic_tstore;
    assert request0.atomic_tstore_target_count == 1;
    assert request0.source_tile == 5;
    assert request0.atomic_tstore_source_payload_epoch ==
           LocalTilePayloadGeneration(0, request0.source_tile);
    let ordinal = request0.atomic_tstore_source_lifetime_ordinal;
    assert ordinal > 0 && LocalSourceLifetimePinned(0, 5);
    let lifetime_slot = FindBundleSourceLifetimeOrdinal(ordinal);
    assert lifetime_slot >= 0 &&
           _BundleSourceLifetimes[[lifetime_slot]].participant_mask == '1100' &&
           _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1000' &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};

    SelectExecutionContext(0, 1);
    ConfigureTileForMask(6, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, LocalCohortAllocationMask(1));
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 5);
    MarkTileValidRegionDefined(6);
    InstallRelativeTileFixture(0, 6);
    let epoch1 = LocalTilePayloadGeneration(1, 6);
    PrepareLocalCohortPE(1 as MemoryAgentId, entry,
        Zeros{PTO_XLEN} + 0x700, 6 as TileIndex, 2,
        Zeros{PTO_XLEN} + 4);
    let admitted1 = ExecuteBundleTileOperation();
    assert admitted1 && _LastFault == Fault_None && _MemoryEventCount == 0 &&
           _BundleTileBindings[[0]].source0 == 6;
    let slot1 = FindCurrentAtomicTStoreObligation();
    assert slot1 >= 0;
    let request1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert request1.state == GMObligation_Issued;
    assert request1.captured_atomic_tstore;
    assert request1.atomic_tstore_target_count == 2;
    assert request1.source_tile == 6;
    assert request1.atomic_tstore_source_payload_epoch ==
           LocalTilePayloadGeneration(1, request1.source_tile);
    assert request1.atomic_tstore_source_lifetime_ordinal == ordinal;
    assert _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1100';
    assert _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};
    assert _BundleSourceLifetimes[[lifetime_slot]].local_sources[[0]] == 5;
    assert _BundleSourceLifetimes[[lifetime_slot]].local_epochs[[0]] == epoch0;
    assert _BundleSourceLifetimes[[lifetime_slot]].local_sources[[1]] == 6;
    assert _BundleSourceLifetimes[[lifetime_slot]].local_epochs[[1]] == epoch1;
    assert LocalSourceLifetimePinned(1, 6);

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let after_first = _BundleSourceLifetimes[[lifetime_slot]];
    let done0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    let partial1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert done0.state == GMObligation_Completed &&
           done0.atomic_tstore_committed_count == 1 &&
           partial1.state == GMObligation_Issued && partial1.irrevocable &&
           partial1.atomic_tstore_committed_count == 1 &&
           after_first.completed_mask == '1000' &&
           after_first.captured_mask == '1100' &&
           LocalSourceLifetimePinned(0, 5) &&
           LocalSourceLifetimePinned(1, 6) &&
           _MemoryEventCount == 2;
    let event0 = _MemoryEvents[[0 as MemoryEventIndex]];
    let event1 = _MemoryEvents[[1 as MemoryEventIndex]];
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

    SelectExecutionContext(0, 0);
    ConfigureTileForMask(5, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, LocalCohortAllocationMask(0));
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 99);
    MarkTileValidRegionDefined(5);
    let replacement0 = LocalTilePayloadGeneration(0, 5);
    assert replacement0 != epoch0 && ReadTileElement(5, 0, 0) ==
           Zeros{PTO_XLEN} + 99;
    SelectExecutionContext(0, 1);
    ConfigureTileForMask(6, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, LocalCohortAllocationMask(1));
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 109);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 110);
    MarkTileValidRegionDefined(6);
    let replacement1 = LocalTilePayloadGeneration(1, 6);
    assert replacement1 != epoch1 && ReadTileElement(6, 0, 0) ==
           Zeros{PTO_XLEN} + 109;
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
           _MemoryEventCount == 3;
    let event2 = _MemoryEvents[[2 as MemoryEventIndex]];
    assert event2.kind == MemoryEvent_Atomic && event2.committed &&
           event2.agent == 1 && event2.invocation == invocation &&
           event2.address == Zeros{PTO_XLEN} + 0x704 &&
           event2.read_value == Zeros{PTO_XLEN} + 40 &&
           event2.write_value == Zeros{PTO_XLEN} + 45;
    SelectExecutionContext(0, 0);
    assert LocalTilePayloadGeneration(0, 5) == replacement0 &&
           _TilePayloadLiveMasks[[5]] != Zeros{4} &&
           ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 99;
    SelectExecutionContext(0, 1);
    assert LocalTilePayloadGeneration(1, 6) == replacement1 &&
           _TilePayloadLiveMasks[[6]] != Zeros{4} &&
           ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 109 &&
           ReadTileElement(6, 0, 1) == Zeros{PTO_XLEN} + 110;
    StopMemoryEventCapture();
    return 0;
end;
