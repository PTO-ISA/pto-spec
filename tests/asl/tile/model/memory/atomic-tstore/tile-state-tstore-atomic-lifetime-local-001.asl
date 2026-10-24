// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-LIFETIME-LOCAL-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001","PTO-ARCH-GM-OBLIGATIONS-001"],"kind":"state-transition","summary":"Local Atomic TSTORE reuse, deferred last-use and replacement-generation isolation follow source lifetime rules","pass_condition":"actual TLSU Function 1 Atomic TSTORE emits one committed Atomic event in reuse and last-use cases; reuse retains the source and immediate last-use consumes it only after the update; deferred admission captures and pins the exact ordinary Local payload epoch, and after the production allocation API installs a newer generation the original request drains exactly once without clearing or overwriting the newer live payload","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/block/model/operands/tile-bindings.asl","asl/block/model/state/source-lifetime.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func LocalLifetimeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func LocalLifetimeDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '000';
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func LocalLifetimeSource(last_use: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    instruction[26] = if last_use then '1' else '0';
    return instruction;
end;

pure func LocalLifetimeIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

pure func LocalLifetimeSinglePELastUse() => bits(64)
begin
    var instruction = LocalLifetimeSource(TRUE);
    instruction[11:9] = '001';
    return instruction;
end;

func TestLocalAtomicLifetime(last_use: boolean)
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    let live_before = _TilePayloadLiveMasks[[0]];
    assert live_before != Zeros{4};
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x200, Zeros{8} + 5);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x201, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x202, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x203, Zeros{8});
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);

    let start = ExecuteCommandInstruction(LocalLifetimeStart(), 32);
    let attributes = ExecuteCommandInstruction(LocalLifetimeDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(LocalLifetimeSource(last_use), 32);
    let address = ExecuteCommandInstruction(LocalLifetimeIOR(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() && BundleTileBindingCount() == 1 &&
           _BundleTileBindings[[0]].source0_reuse == !last_use;

    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None && _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.active && event.kind == MemoryEvent_Atomic &&
           event.address == Zeros{PTO_XLEN} + 0x200 && event.committed &&
           event.read_value == Zeros{PTO_XLEN} + 5 &&
           event.write_value == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
    let actual_gm = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert actual_gm == Zeros{PTO_XLEN} + 7;
    assert _Tiles[[0]].allocated && ReadTileElement(0, 0, 0) ==
           Zeros{PTO_XLEN} + 2;
    if last_use then
        assert _TilePayloadLiveMasks[[0]] == Zeros{4};
    else
        assert _TilePayloadLiveMasks[[0]] == live_before;
    end;
end;

func TestDeferredLocalAtomicLifetimeReplacement()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x980;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(0);
    let admitted_epoch = LocalTilePayloadGeneration(0, 0);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 5);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);

    let started = ExecuteCommandInstruction(LocalLifetimeStart(), 32);
    let attributes = ExecuteCommandInstruction(LocalLifetimeDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(LocalLifetimeSinglePELastUse(), 32);
    let address = ExecuteCommandInstruction(LocalLifetimeIOR(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           _BundleTileBindings[[0]].pe_mask == '1000' &&
           !_BundleTileBindings[[0]].source0_reuse;

    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let captured = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert captured.captured_atomic_tstore &&
           captured.atomic_tstore_source_lifetime_ordinal > 0 &&
           !captured.atomic_tstore_source_shared &&
           captured.atomic_tstore_source_pe == 0 &&
           captured.atomic_tstore_source_payload_epoch == admitted_epoch &&
           LocalSourceLifetimePinned(0, 0);
    let lifetime_ordinal = captured.atomic_tstore_source_lifetime_ordinal;
    let lifetime_slot = FindBundleSourceLifetimeOrdinal(lifetime_ordinal);
    assert lifetime_slot >= 0 &&
           _BundleSourceLifetimes[[lifetime_slot]].local_epoch == admitted_epoch &&
           _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1000' &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};

    // Model an architecturally later allocation in the same physical source
    // slot while the admitted request still owns only the older epoch.
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 99);
    MarkTileValidRegionDefined(0);
    SaveSelectedPEExecutionContext();
    let replacement_epoch = LocalTilePayloadGeneration(0, 0);
    assert replacement_epoch != admitted_epoch &&
           ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99 &&
           _TilePayloadLiveMasks[[0]] != Zeros{4} &&
           !LocalSourceLifetimePinned(0, 0) &&
           _BundleSourceLifetimes[[lifetime_slot]].valid &&
           _BundleSourceLifetimes[[lifetime_slot]].local_epoch == admitted_epoch;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let completed = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert completed.state == GMObligation_Completed &&
           completed.atomic_tstore_committed_count == 1 &&
           completed.atomic_tstore_committed_elements[0] == '1' &&
           !completed.atomic_tstore_finalization_pending &&
           !LocalSourceLifetimePinned(0, 0) &&
           !_BundleSourceLifetimes[[lifetime_slot]].valid;
    assert _MemoryEventCount == 1;
    let event = _MemoryEvents[[0 as MemoryEventIndex]];
    assert event.kind == MemoryEvent_Atomic && event.committed &&
           event.core_identity == 0 && event.agent == 0 &&
           event.origin == MemoryEventOrigin_Kernel &&
           event.invocation == invocation &&
           event.address == Zeros{PTO_XLEN} + 0x200 &&
           event.read_value == Zeros{PTO_XLEN} + 5 &&
           event.write_value == Zeros{PTO_XLEN} + 7;
    let current_epoch = LocalTilePayloadGeneration(0, 0);
    let actual_gm = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    assert current_epoch == replacement_epoch &&
           _Tiles[[0]].allocated &&
           _TilePayloadLiveMasks[[0]] != Zeros{4} &&
           ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 99 &&
           actual_gm == Zeros{PTO_XLEN} + 7;
    StopMemoryEventCapture();
    SetVerificationGMProgressBeatBudget(0);
end;

func main() => integer
begin
    TestLocalAtomicLifetime(FALSE);
    TestLocalAtomicLifetime(TRUE);
    TestDeferredLocalAtomicLifetimeReplacement();
    return 0;
end;
