// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","surface":"arch","classification":["memory-model","fault-precision"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT"]}
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-REPLAY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A scalar fault is precise: effects committed by older instructions remain,
// the faulting instruction is the restart point, and younger work has no
// architectural effect.  A Tile memory request is precise at its Block
// boundary; completed TLOAD/TSTORE beats remain visible, while retrying a
// fault re-executes the whole logical request and never exposes an internal
// lane or cursor as architectural state.
// NDF-END: PTO-ARCH-MEMORY-MODEL-REPLAY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-FLUSH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A replay flush discards only uncommitted event records and younger pending
// work.  It MUST NOT roll back committed GM writes, committed Tile payload
// elements, or a memory event already admitted before the fault.  Recovery
// retries from the saved instruction/request template.
// NDF-END: PTO-ARCH-MEMORY-MODEL-FLUSH-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// Trap return restores only the interrupted PE's precise instruction and
// Block restart carriers. It MUST NOT rewind shared GM/event history, Core
// synchronization, shared Tile generations, or another PE's cooperative local
// generation progress. An instruction owner performs any required scoped
// abort or squash before saving its restart point.
// NDF-END: PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001

func BeginMemoryReplay(request: Word)
begin
    _MemoryReplayState.active = TRUE;
    _MemoryReplayState.request = request;
    _MemoryReplayState.committed_event_count = _MemoryEventCount;
    _MemoryReplayState.epoch = _MemoryReplayState.epoch + 1;
    _MemoryReplayState.owner_core = _CurrentModelCore;
    _MemoryReplayState.owner_agent = _CurrentMemoryAgent;
    _MemoryReplayState.owner_origin = _CurrentMemoryOrigin;
    _MemoryReplayState.owner_invocation = _CurrentKernelInvocation;
    _MemoryReplayState.owner_program_order = _CurrentProgramOrder;
end;

func CommitMemoryReplayEffect()
begin
    if _MemoryReplayState.active then
        for event_number = 0 to _MemoryEventCount - 1 do
            let event_index = event_number as MemoryEventIndex;
            if _MemoryEvents[[event_index]].active &&
               _MemoryEvents[[event_index]].replay_epoch ==
                   _MemoryReplayState.epoch &&
               _MemoryEvents[[event_index]].core_identity ==
                   _MemoryReplayState.owner_core &&
               _MemoryEvents[[event_index]].agent ==
                   _MemoryReplayState.owner_agent &&
               _MemoryEvents[[event_index]].origin ==
                   _MemoryReplayState.owner_origin &&
               _MemoryEvents[[event_index]].invocation ==
                   _MemoryReplayState.owner_invocation &&
               _MemoryEvents[[event_index]].program_order ==
                   _MemoryReplayState.owner_program_order then
                _MemoryEvents[[event_index]].committed = TRUE;
            end;
        end;
        _MemoryReplayState.committed_event_count = _MemoryEventCount;
    end;
end;

func FlushMemoryReplay()
begin
    if _MemoryReplayState.active then
        // Event slots are stable because surviving events and saved contexts
        // can refer to them through read_from. Deactivate only this owner's
        // uncommitted records from this replay epoch; never rewind the shared
        // event log or disturb another PE/Core's event references.
        for event_number = 0 to _MemoryEventCount - 1 do
            let event_index = event_number as MemoryEventIndex;
            if _MemoryEvents[[event_index]].active &&
               !_MemoryEvents[[event_index]].committed &&
               _MemoryEvents[[event_index]].replay_epoch ==
                   _MemoryReplayState.epoch &&
               _MemoryEvents[[event_index]].core_identity ==
                   _MemoryReplayState.owner_core &&
               _MemoryEvents[[event_index]].agent ==
                   _MemoryReplayState.owner_agent &&
               _MemoryEvents[[event_index]].origin ==
                   _MemoryReplayState.owner_origin &&
               _MemoryEvents[[event_index]].invocation ==
                   _MemoryReplayState.owner_invocation &&
               _MemoryEvents[[event_index]].program_order ==
                   _MemoryReplayState.owner_program_order then
                _MemoryEvents[[event_index]].active = FALSE;
            end;
        end;
        _MemoryReplayState.active = FALSE;
    end;
end;

func CompleteMemoryReplay()
begin
    if _MemoryReplayState.active then
        CommitMemoryReplayEffect();
        _MemoryReplayState.committed_event_count = _MemoryEventCount;
        _MemoryReplayState.active = FALSE;
    end;
end;

readonly func MemoryReplayCanRetryWholeRequest(request: Word) => boolean
begin
    return !_MemoryReplayState.active &&
           (_MemoryReplayState.request == request ||
            _MemoryReplayState.request == Zeros{PTO_XLEN});
end;
func SetFaultWithCause(code: FaultCode, address: Word, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = if code == Fault_None then source_ring
        else TrapTargetForFault(source_ring);
    if code != Fault_None then
        SaveTrapContext(ring, source_ring);
        // Subsequent event capture belongs to the handler until recovery
        // restores the interrupted PE's saved provenance.
        _CurrentMemoryOrigin = MemoryEventOrigin_Handler;
    end;
    _LastFault = code;
    _FaultAddress = address;
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = code != Fault_None;
    _ACRTrapCause[[ring]] = cause;
    case code of
        when Fault_None => _ACRTrapNumber[[ring]] = Zeros{6};
        when Fault_ExecutionStateCheck => _ACRTrapNumber[[ring]] = Zeros{6};
        when Fault_IllegalInstruction => _ACRTrapNumber[[ring]] = Zeros{6} + 4;
        when Fault_InstructionPC => _ACRTrapNumber[[ring]] = Zeros{6} + 32;
        when Fault_InstructionPage => _ACRTrapNumber[[ring]] = Zeros{6} + 33;
        when Fault_DataAlignment => _ACRTrapNumber[[ring]] = Zeros{6} + 34;
        when Fault_DataPage => _ACRTrapNumber[[ring]] = Zeros{6} + 35;
        when Fault_HardwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 49;
        when Fault_SoftwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 50;
        when Fault_HardwareWatchpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 51;
        when Fault_Assert => _ACRTrapNumber[[ring]] = Zeros{6} + 52;
        when Fault_TileLegality => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_TileAllocation => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_BundleControl => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        // B.CATR.trap is a successful-commit boundary trap, not a failed
        // instruction.  It uses the bundle exception class while preserving
        // the already selected continuation in the saved clean context.
        when Fault_BundlePostCommit => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_ServiceRequest => _ACRTrapNumber[[ring]] = Zeros{6} + 6;
    end;
    _ACRTrapArgument0[[ring]] = address;
    if code != Fault_None then
        SetCurrentACR(ring);
        WriteTPC(TrapVectorEntry(ring, address));
    end;
end;

func SetFault(code: FaultCode, address: Word)
begin
    SetFaultWithCause(code, address, Zeros{24});
end;

func RaiseServiceRequest(request_type: bits(4)) => boolean
begin
    let source_ring = CurrentACR();
    if !ServiceRequestPermitted(source_ring, request_type) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    let source_tpc = ReadTPC();
    let resume_tpc = source_tpc + (Zeros{PTO_XLEN} + 4);
    let target_ring = ServiceRequestTarget(source_ring, request_type);
    SaveTrapContext(target_ring, source_ring);
    _TrapContexts[[target_ring]].tpc = resume_tpc;
    let ebarg_tpc_index = ((target_ring * 4096) + 0x0f43)
        as SystemRegisterFileIndex;
    _ExtendedSystemRegisters[[ebarg_tpc_index]] = resume_tpc;

    _LastFault = Fault_ServiceRequest;
    _FaultAddress = source_tpc;
    _ACRTrapAsynchronous[[target_ring]] = FALSE;
    _ACRTrapArgumentValid[[target_ring]] = TRUE;
    _ACRTrapCause[[target_ring]] = ZeroExtend{24}(request_type);
    _ACRTrapNumber[[target_ring]] = Zeros{6} + 6;
    _ACRTrapArgument0[[target_ring]] = source_tpc;
    // SaveTrapContext records the origin to restore.  Once entry succeeds,
    // subsequent memory events are handler work and cannot participate in a
    // kernel collective.
    _CurrentMemoryOrigin = MemoryEventOrigin_Handler;
    SetCurrentACR(target_ring);
    WriteTPC(TrapVectorEntry(target_ring, source_tpc));
    return TRUE;
end;

func ClearFault()
begin
    let ring = CurrentACR();
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = FALSE;
    _ACRTrapCause[[ring]] = Zeros{24};
    _ACRTrapNumber[[ring]] = Zeros{6};
    _ACRTrapArgument0[[ring]] = Zeros{PTO_XLEN};
end;

func RaiseInterrupt(interrupt_id: InterruptID, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = TrapTargetForInterrupt(source_ring);
    SetInterruptPending(ring, interrupt_id);
    if !InterruptEnabled(ring, interrupt_id) then return; end;
    SaveTrapContext(ring, source_ring);
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = TRUE;
    _ACRTrapArgumentValid[[ring]] = TRUE;
    _ACRTrapCause[[ring]] = cause;
    _ACRTrapNumber[[ring]] = Zeros{6} + 44;
    _ACRTrapArgument0[[ring]] =
        NaturalToWord(interrupt_id as integer {0..262144});
    // SaveTrapContext preserves the interrupted origin.  Establish handler
    // provenance only after the enabled interrupt has actually entered.
    _CurrentMemoryOrigin = MemoryEventOrigin_Handler;
    SetCurrentACR(ring);
    WriteTPC(TrapVectorEntry(ring, ReadTPC()));
end;

readonly func PackTrapStatus(ring: AccessControlRing) => Word
begin
    var value: Word = Zeros{PTO_XLEN};
    value[63] = if _ACRTrapAsynchronous[[ring]] then '1' else '0';
    value[62] = if _ACRTrapArgumentValid[[ring]] then '1' else '0';
    value[24 +: 24] = _ACRTrapCause[[ring]];
    value[0 +: 6] = _ACRTrapNumber[[ring]];
    return value;
end;

func UnpackTrapStatus(ring: AccessControlRing, value: Word)
begin
    _ACRTrapAsynchronous[[ring]] = value[63] == '1';
    _ACRTrapArgumentValid[[ring]] = value[62] == '1';
    _ACRTrapCause[[ring]] = value[24 +: 24];
    _ACRTrapNumber[[ring]] = value[0 +: 6];
end;
