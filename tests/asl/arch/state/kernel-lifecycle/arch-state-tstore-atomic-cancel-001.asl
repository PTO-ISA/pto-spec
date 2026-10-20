// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-CANCEL-001","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-KERNEL-LIFECYCLE-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"an admitted but not yet irrevocable Atomic TSTORE cancels without effects on invocation abort","pass_condition":"a valid encoded Local last-use Function 1 request is admitted with service deferred, then abort cancels its reversible obligation, clears its pending source lifetime without marking the PE successful, preserves GM sentinels, and emits no Atomic event","related_sources":["asl/arch/memory-model/atomic-tstore-obligations.asl","asl/tile/model/memory/atomic-tstore.asl","asl/block/model/state/source-lifetime.asl"]}

pure func CancelAtomicStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func CancelAtomicDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func CancelAtomicSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[26] = '1';
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func CancelAtomicAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xa80;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    assert TileDescriptorLegal(0);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 9);
    MarkTileValidRegionDefined(0);
    let base = Zeros{PTO_XLEN} + 0x700;
    Store(base - 4, 4, Zeros{PTO_XLEN} + 0x55);
    Store(base, 4, Zeros{PTO_XLEN} + 5);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 0x66);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = 5;
    _PEProgramOrder[[0]][[0]] = 5;

    let start = ExecuteCommandInstruction(CancelAtomicStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(CancelAtomicDATR(), 32);
    let source = ExecuteCommandInstruction(CancelAtomicSource(), 32);
    let address = ExecuteCommandInstruction(CancelAtomicAddress(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           _BundleTileBindings[[0]].source0_valid &&
           _BundleTileBindings[[0]].last;

    SetVerificationGMProgressDeferred(TRUE);
    StartMemoryEventCapture(0);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let pending = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert pending.active && pending.captured_atomic_tstore &&
           pending.state == GMObligation_Issued &&
           pending.invocation == invocation && !pending.irrevocable &&
           pending.atomic_tstore_target_count == 1 &&
           pending.atomic_tstore_committed_count == 0 &&
           pending.atomic_tstore_source_lifetime_ordinal != 0;
    let ordinal = pending.atomic_tstore_source_lifetime_ordinal;
    var lifetime_slot: integer {-1..63} = -1;
    for index = 0 to 63 do
        if _BundleSourceLifetimes[[index]].valid &&
           _BundleSourceLifetimes[[index]].ordinal == ordinal then
            lifetime_slot = index as integer {-1..63};
        end;
    end;
    assert lifetime_slot >= 0 &&
           _BundleSourceLifetimes[[lifetime_slot]].captured_mask == '1000' &&
           _BundleSourceLifetimes[[lifetime_slot]].completed_mask == Zeros{4};
    StopMemoryEventCapture();

    let cancelled = AbortKernelInvocation(0);
    assert cancelled == KernelLifecycle_Started &&
           !_KernelInvocationActiveByCore[[0]] &&
           _RetiredKernelInvocationByCore[[0]] == invocation;
    let after_abort = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert after_abort.active &&
           after_abort.state == GMObligation_Cancelled &&
           after_abort.invocation == invocation &&
           after_abort.atomic_tstore_committed_count == 0 &&
           after_abort.atomic_tstore_finalization_pending;
    assert !_BundleSourceLifetimes[[lifetime_slot]].valid &&
           _MemoryEventCount == 0;
    let guard_before = LoadUnsigned(base - 4, 4);
    let target_after = LoadUnsigned(base, 4);
    let guard_after = LoadUnsigned(base + 4, 4);
    assert guard_before == Zeros{PTO_XLEN} + 0x55 &&
           target_after == Zeros{PTO_XLEN} + 5 &&
           guard_after == Zeros{PTO_XLEN} + 0x66;
    SetVerificationGMProgressDeferred(FALSE);
    return 0;
end;
