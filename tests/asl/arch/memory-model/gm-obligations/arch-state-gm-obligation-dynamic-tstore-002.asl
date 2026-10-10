// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-OBLIGATION-DYNAMIC-TSTORE-002","source":"asl/arch/memory-model/gm-obligations.asl","requirements":["PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"different encoded TSTORE occurrences at one static PC retain separate captures and produce both stores","pass_condition":"two independently encoded stops at the same PC create distinct domain and obligation identities with immutable distinct source/address/order captures; actual scheduler progress emits both stores and completes both obligations","related_sources":["asl/block/model/dispatch/gm-obligation-dispatch.asl","asl/tile/model/memory/load-store.asl"]}
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

func SubmitDynamicStore(address_value: Word, value: Word)
begin
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteGPR(2, address_value);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    WriteTileElement(4, 0, 0, value);
    let start = ExecuteCommandInstruction(DelayedTStoreStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(
        DelayedTStoreSource(Zeros{6} + 4), 32);
    let address = ExecuteCommandInstruction(DelayedTStoreAddress(
        Zeros{5} + 2, Zeros{5} + 3), 32);
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert start == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           stop == CommandExecution_Executed && !_BundleActive &&
           _LastFault == Fault_None;
end;

func main() => integer
begin
    ResetProfileState();
    let launch = LaunchKernelInvocation(0, Zeros{PTO_XLEN} + 0x200);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    SubmitDynamicStore(Zeros{PTO_XLEN} + 0x600,
        Zeros{PTO_XLEN} + 0xaa);
    let first = _GMObligations[[0]][[0]][[0]];
    SubmitDynamicStore(Zeros{PTO_XLEN} + 0x608,
        Zeros{PTO_XLEN} + 0xbb);
    let second = _GMObligations[[0]][[0]][[1]];
    assert _BundleExecutionDomainToken != first.execution_domain_token &&
           first.execution_domain_token != second.execution_domain_token &&
           first.identity != second.identity && first.active && second.active &&
           first.captured_tstore_progress &&
           second.captured_tstore_progress &&
           first.executable_capture_valid && second.executable_capture_valid;
    assert first.base_address == Zeros{PTO_XLEN} + 0x600 &&
           second.base_address == Zeros{PTO_XLEN} + 0x608 &&
           TileReadLogicalElement(first.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 0xaa &&
           TileReadLogicalElement(second.source_snapshot, 0) ==
               Zeros{PTO_XLEN} + 0xbb;
    let first_initial_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x600, 8);
    let second_initial_memory = LoadUnsigned(Zeros{PTO_XLEN} + 0x608, 8);
    assert first_initial_memory == Zeros{PTO_XLEN} &&
           second_initial_memory == Zeros{PTO_XLEN};
    SetVerificationGMProgressDeferred(FALSE);
    ProgressKernelGMObligationsForCore(0, _CurrentKernelInvocation);
    assert _GMObligations[[0]][[0]][[0]].state == GMObligation_Completed &&
           _GMObligations[[0]][[0]][[1]].state == GMObligation_Completed;
    let first_stored = LoadUnsigned(Zeros{PTO_XLEN} + 0x600, 8);
    let second_stored = LoadUnsigned(Zeros{PTO_XLEN} + 0x608, 8);
    assert first_stored == Zeros{PTO_XLEN} + 0xaa &&
           second_stored == Zeros{PTO_XLEN} + 0xbb;
    var first_event = FALSE;
    var second_event = FALSE;
    for event_number = 0 to _MemoryEventCount - 1 do
        let event = _MemoryEvents[[event_number as MemoryEventIndex]];
        if event.active && event.committed &&
           event.kind == MemoryEvent_Store &&
           event.invocation == first.invocation && event.agent == 0 then
            if event.address == first.base_address &&
               event.write_value == Zeros{PTO_XLEN} + 0xaa then
                first_event = TRUE;
            elsif event.address == second.base_address &&
                  event.write_value == Zeros{PTO_XLEN} + 0xbb then
                second_event = TRUE;
            end;
        end;
    end;
    assert first_event && second_event;
    return 0;
end;
