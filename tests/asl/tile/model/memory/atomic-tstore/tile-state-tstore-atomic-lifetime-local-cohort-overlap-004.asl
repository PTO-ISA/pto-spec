// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-LIFETIME-LOCAL-COHORT-OVERLAP-004","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"Same-site Atomic Local occurrences pair by participant order and cross-pin exact source tuples until all cohorts complete","pass_condition":"PE0 completes two same-site relative-source occurrences before PE1 joins either; PE1's first later capture joins the earlier ordinal and its second joins the later ordinal; after the first cohort finishes while the second has one committed beat, both exact source tuples remain live and pinned; completing the second cohort consumes each source tuple once and retires both rows","related_sources":["asl/block/model/state/atomic-tstore-source-lifetime.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func CohortOverlapParticipants() => bits(4)
begin
    return '1100';
end;

pure func CohortOverlapStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func CohortOverlapDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000'; instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    return instruction;
end;

pure func CohortOverlapLastUse() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00007013;
    instruction[31:26] = Zeros{6} + 4;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '101'; instruction[19] = '1';
    return instruction;
end;

pure func CohortOverlapStop() => bits(64)
begin
    return Zeros{64} + 1;
end;

pure func CohortOverlapIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3; return instruction;
end;

func PrepareCohortOverlapPE(pe: MemoryAgentId, entry: Word, base: Word,
                            columns: integer {1..2}, order: integer,
                            fresh: boolean)
begin
    SelectExecutionContext(0, pe);
    if fresh then
        ResetBundleControlState();
        _PC = entry; _BPC = entry;
    end;
    _CurrentProgramOrder = order;
    _PEProgramOrder[[0]][[pe]] = order;
    WriteTPC(entry);
    WriteGPR(2, base); WriteGPR(3, Zeros{PTO_XLEN} + 4);
    let started = ExecutePTOInstruction(CohortOverlapStart(), 32);
    let attributes = ExecuteCommandInstruction(CohortOverlapDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(CohortOverlapLastUse(), 32);
    let address = ExecuteCommandInstruction(CohortOverlapIOR(), 32);
    assert started == PTOInstruction_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed && BundleAtomicTStoreSelected() &&
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
    Store(Zeros{PTO_XLEN} + 0x800, 4, Zeros{PTO_XLEN} + 50);
    Store(Zeros{PTO_XLEN} + 0x804, 4, Zeros{PTO_XLEN} + 60);
    Store(Zeros{PTO_XLEN} + 0x900, 4, Zeros{PTO_XLEN} + 70);
    Store(Zeros{PTO_XLEN} + 0x904, 4, Zeros{PTO_XLEN} + 80);
    StartMemoryEventCapture(0);
    SelectExecutionContext(0, 0);
    let source0_ready = ConfigureCubeTileForMaskWithPhysical(5, 128,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16,
        CohortOverlapParticipants());
    let mask0_ready = ConfigurePredicateCellForMask(4, 128, 1, 2,
        TileDataType_U32, TileLayout_CUBE_M16, CohortOverlapParticipants());
    assert source0_ready && mask0_ready;
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 4);
    MarkTileValidRegionDefined(5);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(4);
    InstallRelativeTileFixture(0, 5); InstallRelativeTileFixture(4, 4);
    let epoch0 = LocalTilePayloadGeneration(0, 5);
    PrepareCohortOverlapPE(0, entry, Zeros{PTO_XLEN} + 0x600, 2, 7, TRUE);
    let domain0a = _BundleExecutionDomainToken;
    let admitted0a = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert admitted0a;
    assert _MemoryEventCount == 1;
    let slot0a = FindCurrentAtomicTStoreOccurrence();
    assert slot0a >= 0;
    let request0a = _GMObligations[[0]][[0]][[slot0a as GMObligationIndex]];
    let ordinal_a = request0a.atomic_tstore_source_lifetime_ordinal;
    assert request0a.captured_atomic_tstore &&
           request0a.state == GMObligation_Completed && ordinal_a > 0;
    assert ordinal_a > 0 && _MemoryEventCount == 1;
    let stopped0a = ExecutePTOInstruction(CohortOverlapStop(), 32);
    assert stopped0a == PTOInstruction_Executed && !_BundleActive &&
           ReadBPC() == Zeros{PTO_XLEN};
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 1);
    PrepareCohortOverlapPE(0, entry, Zeros{PTO_XLEN} + 0x800, 2, 8, FALSE);
    let domain0b = _BundleExecutionDomainToken;
    assert domain0b != domain0a;
    let admitted0b = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert admitted0b;
    assert _MemoryEventCount == 3;
    let slot0b = FindCurrentAtomicTStoreOccurrence();
    assert slot0b >= 0;
    let request0b = _GMObligations[[0]][[0]][[slot0b as GMObligationIndex]];
    let ordinal_b = request0b.atomic_tstore_source_lifetime_ordinal;
    assert request0b.captured_atomic_tstore &&
           request0b.state == GMObligation_Completed && ordinal_b > ordinal_a &&
           request0b.execution_domain_token == domain0b &&
           request0b.identity != request0a.identity;
    assert ordinal_b > ordinal_a && _MemoryEventCount == 3 &&
           LocalSourceLifetimePinned(0, 5);

    SelectExecutionContext(0, 1);
    let source1_ready = ConfigureCubeTileForMaskWithPhysical(6, 128,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16,
        CohortOverlapParticipants());
    let mask1_ready = ConfigurePredicateCellForMask(4, 128, 1, 2,
        TileDataType_U32, TileLayout_CUBE_M16, CohortOverlapParticipants());
    assert source1_ready && mask1_ready;
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 6);
    MarkTileValidRegionDefined(6);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(4);
    InstallRelativeTileFixture(0, 6); InstallRelativeTileFixture(4, 4);
    let epoch1 = LocalTilePayloadGeneration(1, 6);
    SetVerificationGMProgressDeferred(TRUE);
    PrepareCohortOverlapPE(1, entry, Zeros{PTO_XLEN} + 0x700, 2, 7, TRUE);
    let admitted1a = ExecuteBundleTileOperation();
    assert admitted1a && _LastFault == Fault_None && _MemoryEventCount == 3;
    let slot1a = FindCurrentAtomicTStoreObligation();
    assert slot1a >= 0;
    let request1a = _GMObligations[[0]][[1]][[slot1a as GMObligationIndex]];
    let joined_a = request1a.atomic_tstore_source_lifetime_ordinal;
    SetVerificationGMProgressDeferred(FALSE);
    ProgressKernelGMObligationsForCore(0, invocation);
    assert _MemoryEventCount == 4 &&
           _GMObligations[[0]][[1]][[slot1a as GMObligationIndex]].state ==
               GMObligation_Completed;
    let completed1a = _GMObligations[[0]][[1]]
        [[slot1a as GMObligationIndex]];
    let row_a_after_first_cohort =
        FindBundleSourceLifetimeOrdinal(ordinal_a);
    assert row_a_after_first_cohort >= 0 &&
           _BundleSourceLifetimes[[row_a_after_first_cohort]].completed_mask ==
               '1100' && LocalSourceLifetimePinned(0, 5) &&
           !LocalSourceLifetimePinned(1, 6);
    let stopped1a = ExecutePTOInstruction(CohortOverlapStop(), 32);
    assert stopped1a == PTOInstruction_Executed && !_BundleActive &&
           ReadBPC() == Zeros{PTO_XLEN};
    let source1b_ready = ConfigureCubeTileForMaskWithPhysical(6, 128,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16,
        CohortOverlapParticipants());
    assert source1b_ready;
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 8);
    MarkTileValidRegionDefined(6);
    let epoch1b = LocalTilePayloadGeneration(1, 6);
    assert epoch1b != epoch1;
    SetVerificationGMProgressDeferred(TRUE);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 1);
    PrepareCohortOverlapPE(1, entry, Zeros{PTO_XLEN} + 0x900, 2, 8, FALSE);
    let admitted1b = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert admitted1b;
    assert _MemoryEventCount == 4;
    let slot1b = FindCurrentAtomicTStoreObligation();
    assert slot1b >= 0;
    let request1b = _GMObligations[[0]][[1]][[slot1b as GMObligationIndex]];
    let joined_b = request1b.atomic_tstore_source_lifetime_ordinal;
    assert joined_a == ordinal_a && joined_b == ordinal_b &&
           joined_a != joined_b &&
           _BundleSourceLifetimes[[FindBundleSourceLifetimeOrdinal(ordinal_a)]]
               .captured_mask == '1100' &&
           _BundleSourceLifetimes[[FindBundleSourceLifetimeOrdinal(ordinal_b)]]
               .captured_mask == '1100' && _MemoryEventCount == 4;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let row_a = FindBundleSourceLifetimeOrdinal(ordinal_a);
    let row_b = FindBundleSourceLifetimeOrdinal(ordinal_b);
    assert row_a >= 0 && row_b >= 0 &&
           _BundleSourceLifetimes[[row_a]].completed_mask == '1100' &&
           _BundleSourceLifetimes[[row_b]].completed_mask == '1000' &&
           _BundleSourceLifetimes[[row_b]].local_epochs[[1]] == epoch1b &&
           _BundleSourceLifetimes[[row_a]].local_epochs[[0]] == epoch0 &&
           _BundleSourceLifetimes[[row_a]].local_epochs[[1]] == epoch1 &&
           LocalSourceLifetimePinned(0, 5) &&
           LocalSourceLifetimePinned(1, 6) && _MemoryEventCount == 5;
    SelectExecutionContext(0, 0);
    assert _TilePayloadLiveMasks[[5]] == CohortOverlapParticipants();
    SelectExecutionContext(0, 1);
    assert _TilePayloadLiveMasks[[6]] == CohortOverlapParticipants();

    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let done0a = request0a;
    let done0b = request0b;
    let done1a = completed1a;
    let done1b = _GMObligations[[0]][[1]][[slot1b as GMObligationIndex]];
    assert done0a.state == GMObligation_Completed &&
           done0b.state == GMObligation_Completed &&
           done1a.state == GMObligation_Completed &&
           done1b.state == GMObligation_Completed &&
           done0a.atomic_tstore_committed_count == 1 &&
           done0b.atomic_tstore_committed_count == 2 &&
           done1a.atomic_tstore_committed_count == 1 &&
           done1b.atomic_tstore_committed_count == 2 &&
           FindBundleSourceLifetimeOrdinal(ordinal_a) < 0 &&
           FindBundleSourceLifetimeOrdinal(ordinal_b) < 0 &&
           !LocalSourceLifetimePinned(0, 5) &&
           !LocalSourceLifetimePinned(1, 6) && _MemoryEventCount == 6;
    let event3 = _MemoryEvents[[3 as MemoryEventIndex]];
    let event4 = _MemoryEvents[[4 as MemoryEventIndex]];
    let event5 = _MemoryEvents[[5 as MemoryEventIndex]];
    assert event3.kind == MemoryEvent_Atomic && event3.agent == 1 &&
           event3.address == Zeros{PTO_XLEN} + 0x700 &&
           event3.read_value == Zeros{PTO_XLEN} + 30 &&
           event3.write_value == Zeros{PTO_XLEN} + 35;
    assert event4.kind == MemoryEvent_Atomic && event4.agent == 1 &&
           event4.address == Zeros{PTO_XLEN} + 0x900 &&
           event4.read_value == Zeros{PTO_XLEN} + 70 &&
           event4.write_value == Zeros{PTO_XLEN} + 77;
    assert event5.kind == MemoryEvent_Atomic && event5.agent == 1 &&
           event5.address == Zeros{PTO_XLEN} + 0x904 &&
           event5.read_value == Zeros{PTO_XLEN} + 80 &&
           event5.write_value == Zeros{PTO_XLEN} + 88;
    SelectExecutionContext(0, 0);
    assert _TilePayloadLiveMasks[[5]][PTOPEMaskBitOfPEIdentity(0)] == '0';
    SelectExecutionContext(0, 1);
    assert _TilePayloadLiveMasks[[6]][PTOPEMaskBitOfPEIdentity(1)] == '0';
    StopMemoryEventCapture();
    return 0;
end;
