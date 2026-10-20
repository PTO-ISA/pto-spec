// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-INTERLEAVED-001","source":"asl/arch/memory-model/atomic-tstore-obligations.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001"],"kind":"state-transition","summary":"two admitted PE-local producers interleave real atomic service beats across a positive short row stride","pass_condition":"two encoded Function 1 requests are admitted before service; four beat-budget-one scheduler passes alternate PE0/PE1 contributions to exact targets 0x200, 0x204, 0x204, and 0x208, preserving every RMW old/new pair, invocation and producer identity, all contributions, and surrounding sentinels","related_sources":["asl/block/model/dispatch/tlsu-atomic-tstore.asl","asl/tile/model/memory/atomic-tstore.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func InterleavedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func InterleavedDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func InterleavedSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func InterleavedAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func AdmitInterleavedProducer(pe: MemoryAgentId, entry: Word,
    program_order: integer {20..21}, value0: Word, value1: Word,
    value2: Word, value3: Word) => integer
begin
    SelectExecutionContext(0, pe);
    ResetBundleControlState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U32,
        TileLayout_RowMajor);
    assert TileDescriptorLegal(0);
    WriteTileElement(0, 0, 0, value0);
    WriteTileElement(0, 0, 1, value1);
    WriteTileElement(0, 1, 0, value2);
    WriteTileElement(0, 1, 1, value3);
    MarkTileValidRegionDefined(0);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x200);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry;
    _BPC = entry;
    _CurrentProgramOrder = program_order;
    _PEProgramOrder[[0]][[pe]] = _CurrentProgramOrder;

    let start = ExecuteCommandInstruction(InterleavedStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    let attributes = ExecuteCommandInstruction(InterleavedDATR(), 32);
    let source = ExecuteCommandInstruction(InterleavedSource(), 32);
    let address = ExecuteCommandInstruction(InterleavedAddress(), 32);
    assert start == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    assert BundleAtomicTStoreSelected() &&
           BundleAtomicTStoreCurrentPESelected() &&
           _BundleTileBindings[[0]].pe_mask == '1111' &&
           _BundleTileBindings[[0]].source0_valid &&
           TileElementwiseSourceContentsDefined(0);
    let (type_valid, effective_type) = ResolveBundleEffectiveDataType();
    assert type_valid && effective_type == TileDataType_U32 &&
           GMReductionOperationDataTypeLegal(GMReduction_ADD,
               effective_type);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None && _MemoryEventCount == 0;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let obligation = _GMObligations[[0]][[pe]][[slot as GMObligationIndex]];
    assert obligation.active && obligation.captured_atomic_tstore &&
           obligation.atomic_tstore_target_count == 4 &&
           obligation.atomic_tstore_committed_count == 0 &&
           obligation.atomic_tstore_translated_targets[[0]] ==
               Zeros{PTO_XLEN} + 0x200 &&
           obligation.atomic_tstore_translated_targets[[1]] ==
               Zeros{PTO_XLEN} + 0x204 &&
           obligation.atomic_tstore_translated_targets[[2]] ==
               Zeros{PTO_XLEN} + 0x204 &&
           obligation.atomic_tstore_translated_targets[[3]] ==
               Zeros{PTO_XLEN} + 0x208;
    return slot;
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x900;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    Store(Zeros{PTO_XLEN} + 0x1fc, 4, Zeros{PTO_XLEN} + 0x55);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 100);
    Store(Zeros{PTO_XLEN} + 0x204, 4, Zeros{PTO_XLEN} + 200);
    Store(Zeros{PTO_XLEN} + 0x208, 4, Zeros{PTO_XLEN} + 300);
    Store(Zeros{PTO_XLEN} + 0x20c, 4, Zeros{PTO_XLEN} + 0x66);
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let slot0 = AdmitInterleavedProducer(0 as MemoryAgentId, entry, 20,
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 4);
    let slot1 = AdmitInterleavedProducer(1 as MemoryAgentId, entry, 21,
        Zeros{PTO_XLEN} + 10, Zeros{PTO_XLEN} + 20,
        Zeros{PTO_XLEN} + 30, Zeros{PTO_XLEN} + 40);
    let before0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    let before1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert before0.invocation == invocation &&
           before1.invocation == invocation &&
           before0.agent == 0 && before1.agent == 1 &&
           before0.state == GMObligation_Issued &&
           before1.state == GMObligation_Issued &&
           _MemoryEventCount == 0;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    for tick = 0 to 3 looplimit 4 do
        ProgressKernelGMObligationsForCore(0, invocation);
        assert _MemoryEventCount == (tick + 1) * 2;
        let pe0_event = _MemoryEvents[[(tick * 2) as MemoryEventIndex]];
        let pe1_event = _MemoryEvents[[(tick * 2 + 1) as MemoryEventIndex]];
        assert pe0_event.active && pe0_event.committed &&
               pe0_event.kind == MemoryEvent_Atomic &&
               pe0_event.core_identity == 0 && pe0_event.agent == 0 &&
               pe0_event.origin == MemoryEventOrigin_Kernel &&
               pe0_event.invocation == invocation &&
               pe0_event.program_order == before0.submission_order &&
               pe1_event.active && pe1_event.committed &&
               pe1_event.kind == MemoryEvent_Atomic &&
               pe1_event.core_identity == 0 && pe1_event.agent == 1 &&
               pe1_event.origin == MemoryEventOrigin_Kernel &&
               pe1_event.invocation == invocation &&
               pe1_event.program_order == before1.submission_order;
        if tick == 0 then
            assert pe0_event.address == Zeros{PTO_XLEN} + 0x200 &&
                   pe0_event.read_value == Zeros{PTO_XLEN} + 100 &&
                   pe0_event.write_value == Zeros{PTO_XLEN} + 101 &&
                   pe1_event.address == Zeros{PTO_XLEN} + 0x200 &&
                   pe1_event.read_value == Zeros{PTO_XLEN} + 101 &&
                   pe1_event.write_value == Zeros{PTO_XLEN} + 111;
        elsif tick == 1 then
            assert pe0_event.address == Zeros{PTO_XLEN} + 0x204 &&
                   pe0_event.read_value == Zeros{PTO_XLEN} + 200 &&
                   pe0_event.write_value == Zeros{PTO_XLEN} + 202 &&
                   pe1_event.address == Zeros{PTO_XLEN} + 0x204 &&
                   pe1_event.read_value == Zeros{PTO_XLEN} + 202 &&
                   pe1_event.write_value == Zeros{PTO_XLEN} + 222;
        elsif tick == 2 then
            assert pe0_event.address == Zeros{PTO_XLEN} + 0x204 &&
                   pe0_event.read_value == Zeros{PTO_XLEN} + 222 &&
                   pe0_event.write_value == Zeros{PTO_XLEN} + 225 &&
                   pe1_event.address == Zeros{PTO_XLEN} + 0x204 &&
                   pe1_event.read_value == Zeros{PTO_XLEN} + 225 &&
                   pe1_event.write_value == Zeros{PTO_XLEN} + 255;
        else
            assert pe0_event.address == Zeros{PTO_XLEN} + 0x208 &&
                   pe0_event.read_value == Zeros{PTO_XLEN} + 300 &&
                   pe0_event.write_value == Zeros{PTO_XLEN} + 304 &&
                   pe1_event.address == Zeros{PTO_XLEN} + 0x208 &&
                   pe1_event.read_value == Zeros{PTO_XLEN} + 304 &&
                   pe1_event.write_value == Zeros{PTO_XLEN} + 344;
        end;
    end;
    let completed0 = _GMObligations[[0]][[0]][[slot0 as GMObligationIndex]];
    let completed1 = _GMObligations[[0]][[1]][[slot1 as GMObligationIndex]];
    assert completed0.state == GMObligation_Completed &&
           completed1.state == GMObligation_Completed &&
           completed0.atomic_tstore_committed_count == 4 &&
           completed1.atomic_tstore_committed_count == 4;
    for element = 0 to 3 looplimit 4 do
        assert completed0.atomic_tstore_committed_elements[element] == '1' &&
               completed1.atomic_tstore_committed_elements[element] == '1';
    end;
    assert _MemoryEventCount == 8;
    StopMemoryEventCapture();
    let guard_before = LoadUnsigned(Zeros{PTO_XLEN} + 0x1fc, 4);
    let result_first = LoadUnsigned(Zeros{PTO_XLEN} + 0x200, 4);
    let result_overlap = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 4);
    let result_last = LoadUnsigned(Zeros{PTO_XLEN} + 0x208, 4);
    let guard_after = LoadUnsigned(Zeros{PTO_XLEN} + 0x20c, 4);
    assert guard_before == Zeros{PTO_XLEN} + 0x55 &&
           result_first == Zeros{PTO_XLEN} + 111 &&
           result_overlap == Zeros{PTO_XLEN} + 255 &&
           result_last == Zeros{PTO_XLEN} + 344 &&
           guard_after == Zeros{PTO_XLEN} + 0x66;
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
