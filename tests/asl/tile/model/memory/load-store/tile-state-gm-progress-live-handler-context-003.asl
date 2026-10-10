// PTO-TEST: {"id":"PTO-AVS-ARCH-GM-PROGRESS-LIVE-HANDLER-CONTEXT-003","source":"asl/tile/model/memory/load-store.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001"],"kind":"state-transition","summary":"captured TSTORE progress preserves live nested-handler context on its owner and across Core selection","pass_condition":"encoded captured TSTORE progress commits a production Store event under its original request identity while restoring a nested handler on the same PE and a caller handler on another Core/PE; real returns restore saved origins/continuations and real reservation invalidation survives","related_sources":["asl/arch/state/pe-execution-context.asl","asl/arch/memory-model/gm-obligations.asl","asl/arch/memory-model/fault-precision.asl","asl/tile/model/memory/load-store.asl"]}
pure func LiveHandlerTStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 25;
    return instruction;
end;

pure func LiveHandlerTStoreSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '111';
    instruction[25:20] = Zeros{6} + 4;
    instruction[19] = '1';
    return instruction;
end;

pure func LiveHandlerTStoreAddress() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func TestOtherCoreProgressRestoresCallerHandler()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x800;
    let launch0 = LaunchKernelInvocation(0, entry);
    let launch1 = LaunchKernelInvocation(1, entry);
    assert launch0 == KernelLifecycle_Started &&
           launch1 == KernelLifecycle_Started;
    let invocation0 = _KernelInvocationByCore[[0]];
    let invocation1 = _KernelInvocationByCore[[1]];
    SelectExecutionContext(1, 2);
    assert _CurrentModelCore == 1 && _CurrentMemoryAgent == 2 &&
           _CurrentKernelInvocation == invocation1 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x6b);
    _PC = entry;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x900);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    _CurrentProgramOrder = 5;
    _PEProgramOrder[[1]][[2]] = 5;
    StartMemoryEventCapture(2);
    SetVerificationGMProgressDeferred(TRUE);
    let start = ExecuteCommandInstruction(LiveHandlerTStoreStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(LiveHandlerTStoreSource(), 32);
    let address = ExecuteCommandInstruction(LiveHandlerTStoreAddress(), 32);
    let request_pc = ReadBPC();
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert start == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           stop == CommandExecution_Executed && _LastFault == Fault_None;
    SelectExecutionContext(1, 2);
    assert _CurrentModelCore == 1 && _CurrentMemoryAgent == 2 &&
           _CurrentKernelInvocation == invocation1;
    var request_found = FALSE;
    var request_core : integer {0..3} = 0;
    var request_pe : integer {0..3} = 0;
    var request_slot : integer {0..PTO_MODEL_GM_OBLIGATIONS-1} = 0;
    for core_probe = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        for pe_probe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            for slot_probe = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
                let probe = _GMObligations[[core_probe]][[pe_probe]]
                    [[slot_probe]];
                if probe.active && probe.invocation == invocation1 then
                    request_found = TRUE;
                    request_core = core_probe;
                    request_pe = pe_probe;
                    request_slot = slot_probe;
                end;
            end;
        end;
    end;
    assert request_found;
    assert request_core == 1;
    assert request_pe == 2;
    let request = _GMObligations[[request_core as PTOModelCoreIdentity]]
        [[request_pe as MemoryAgentId]]
        [[request_slot as GMObligationIndex]];
    assert request.active;
    assert request.state == GMObligation_Validated;
    assert request.captured_tstore_progress;
    assert request.invocation == invocation1;
    assert request.instruction_pc == request_pc;
    let request_identity = request.identity;
    assert _MemoryEventCount == 0;
    SetVerificationGMProgressDeferred(FALSE);

    SelectExecutionContext(0, 0);
    WriteTPC(Zeros{PTO_XLEN} + 0xa00);
    WriteBPC(Zeros{PTO_XLEN} + 0xa04);
    let caller_tpc = ReadTPC();
    let caller_bpc = ReadBPC();
    _CurrentProgramOrder = 19;
    _PEProgramOrder[[0]][[0]] = 19;
    _CurrentEncodedInstruction = Zeros{64} + 0x3456;
    _BundleStartEncodedInstruction = Zeros{64} + 0x789a;
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x900;
    _ReservationSize = 8;
    SaveSelectedPEExecutionContext();
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 10);
    assert _TrapContexts[[0]].valid &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    let handler_tpc = Zeros{PTO_XLEN} + 0xb00;
    let handler_bpc = Zeros{PTO_XLEN} + 0xb04;
    WriteTPC(handler_tpc);
    WriteBPC(handler_bpc);
    _CurrentProgramOrder = 29;
    _PEProgramOrder[[0]][[0]] = 29;
    _CurrentEncodedInstruction = Zeros{64} + 0x4567;
    _BundleStartEncodedInstruction = Zeros{64} + 0x89ab;
    SaveSelectedPEExecutionContext();

    ProgressKernelGMObligationsForCore(1, invocation1);
    assert _CurrentModelCore == 0 && _CurrentMemoryAgent == 0 &&
           _CurrentKernelInvocation == invocation0;
    assert CurrentACR() == 0;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert _CurrentProgramOrder == 29;
    assert ReadTPC() == handler_tpc;
    assert ReadBPC() == handler_bpc;
    assert _CurrentEncodedInstruction == Zeros{64} + 0x4567 &&
           _BundleStartEncodedInstruction == Zeros{64} + 0x89ab;
    assert _TrapContexts[[0]].valid && _LastFault == Fault_None;
    assert !_ReservationValid &&
           !_PEExecutionContexts[[0]][[0]].reservation_valid;
    assert _GMObligations[[request_core as PTOModelCoreIdentity]]
               [[request_pe as MemoryAgentId]]
               [[request_slot as GMObligationIndex]].state ==
               GMObligation_Completed &&
           _GMObligations[[request_core as PTOModelCoreIdentity]]
               [[request_pe as MemoryAgentId]]
               [[request_slot as GMObligationIndex]].identity ==
               request_identity &&
           _GMObligations[[request_core as PTOModelCoreIdentity]]
               [[request_pe as MemoryAgentId]]
               [[request_slot as GMObligationIndex]].invocation ==
               invocation1;
    assert _MemoryEventCount == 1;
    let store = _MemoryEvents[[0]];
    assert store.active && store.committed &&
           store.kind == MemoryEvent_Store &&
           store.core_identity == 1 && store.agent == 2 &&
           store.origin == MemoryEventOrigin_Kernel &&
           store.invocation == invocation1 && store.address ==
               Zeros{PTO_XLEN} + 0x900 &&
           store.write_value == Zeros{PTO_XLEN} + 0x6b;

    let recovered = RecoverTrapContext(0);
    assert recovered && CurrentACR() == 0 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    assert ReadTPC() == caller_tpc && ReadBPC() == caller_bpc;
    assert _MemoryEventCount == 1;
    StopMemoryEventCapture();
end;

func main() => integer
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x200;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f07,
        Zeros{PTO_XLEN} + 3);
    SetCurrentACR(2);
    ConfigureTile(4, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x5a);
    _PC = entry;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x700);
    WriteGPR(3, Zeros{PTO_XLEN} + 8);
    _CurrentProgramOrder = 3;
    _PEProgramOrder[[0]][[0]] = 3;
    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let start = ExecuteCommandInstruction(LiveHandlerTStoreStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let source = ExecuteCommandInstruction(LiveHandlerTStoreSource(), 32);
    let address = ExecuteCommandInstruction(LiveHandlerTStoreAddress(), 32);
    assert start == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed;
    let request_pc = ReadBPC();
    let stop = ExecuteCommandInstruction(Zeros{64}, 16);
    assert stop == CommandExecution_Executed && _LastFault == Fault_None;
    let submitted = _GMObligations[[0]][[0]][[0]];
    assert submitted.active;
    assert submitted.state == GMObligation_Validated;
    assert submitted.captured_tstore_progress;
    assert submitted.invocation == invocation;
    assert submitted.instruction_pc == request_pc;
    assert _MemoryEventCount == 0;
    let request_identity = submitted.identity;
    let continuation_tpc = ReadTPC();
    let continuation_bpc = ReadBPC();
    SetVerificationGMProgressDeferred(FALSE);

    // The handler context is entered by the architectural interrupt owner;
    // the test does not manually relabel the request or its memory events.
    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _TrapContexts[[1]].valid &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert CurrentACR() == 1 && _TrapContexts[[1]].source_acr == 2;
    let handler_tpc = Zeros{PTO_XLEN} + 0x500;
    let handler_bpc = Zeros{PTO_XLEN} + 0x504;
    WriteTPC(handler_tpc);
    WriteBPC(handler_bpc);
    _CurrentProgramOrder = 77;
    _CurrentEncodedInstruction = Zeros{64} + 0x1234;
    _BundleStartEncodedInstruction = Zeros{64} + 0x5678;
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x700;
    _ReservationSize = 8;
    SaveSelectedPEExecutionContext();
    let nested_entered = RaiseServiceRequest('0000');
    assert nested_entered && CurrentACR() == 0 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler &&
           _LastFault == Fault_ServiceRequest;
    let nested_fault_address = _FaultAddress;
    let nested_tpc = Zeros{PTO_XLEN} + 0x600;
    let nested_bpc = Zeros{PTO_XLEN} + 0x604;
    WriteTPC(nested_tpc);
    WriteBPC(nested_bpc);
    _CurrentProgramOrder = 88;
    _CurrentEncodedInstruction = Zeros{64} + 0x2345;
    _BundleStartEncodedInstruction = Zeros{64} + 0x6789;
    SaveSelectedPEExecutionContext();

    ProgressKernelGMObligationsForCore(0, invocation);
    assert _CurrentModelCore == 0 && _CurrentMemoryAgent == 0 &&
           _CurrentKernelInvocation == invocation;
    assert CurrentACR() == 0 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler &&
           _CurrentProgramOrder == 88 && ReadTPC() == nested_tpc &&
           ReadBPC() == nested_bpc;
    assert _CurrentEncodedInstruction == Zeros{64} + 0x2345 &&
           _BundleStartEncodedInstruction == Zeros{64} + 0x6789;
    assert _TrapContexts[[0]].valid && _TrapContexts[[1]].valid &&
           _LastFault == Fault_ServiceRequest &&
           _FaultAddress == nested_fault_address;
    assert !_ReservationValid &&
           !_PEExecutionContexts[[0]][[0]].reservation_valid;
    assert _GMObligations[[0]][[0]][[0]].state ==
               GMObligation_Completed &&
           _GMObligations[[0]][[0]][[0]].identity == request_identity &&
           _GMObligations[[0]][[0]][[0]].invocation == invocation;
    let stored_value = LoadUnsigned(Zeros{PTO_XLEN} + 0x700, 8);
    assert stored_value == Zeros{PTO_XLEN} + 0x5a;
    assert _MemoryEventCount == 2;
    let store = _MemoryEvents[[0]];
    assert store.active && store.committed &&
           store.kind == MemoryEvent_Store &&
           store.core_identity == 0 && store.agent == 0 &&
           store.origin == MemoryEventOrigin_Kernel &&
           store.invocation == invocation && store.address ==
               Zeros{PTO_XLEN} + 0x700 &&
           store.write_value == Zeros{PTO_XLEN} + 0x5a;

    let nested_recovered = RecoverTrapContext(0);
    assert nested_recovered && CurrentACR() == 1 &&
           _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert ReadTPC() == handler_tpc + (Zeros{PTO_XLEN} + 4) &&
           ReadBPC() == handler_bpc;
    let recovered = RecoverTrapContext(1);
    assert recovered && CurrentACR() == 2;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    assert ReadTPC() == continuation_tpc;
    assert ReadBPC() == continuation_bpc;
    assert _GMObligations[[0]][[0]][[0]].state ==
        GMObligation_Completed;
    assert _MemoryEventCount == 2;
    StopMemoryEventCapture();
    TestOtherCoreProgressRestoresCallerHandler();
    return 0;
end;
