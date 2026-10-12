// PTO-UNIT: {"id":"PTO-ARCH-STATE-KERNEL-LIFECYCLE","surface":"arch","classification":["state","kernel-lifecycle"],"depends_on":["PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-ARCH-STATE-CORE-SYNCHRONIZATION","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION"]}
// NDF-BEGIN: PTO-ARCH-KERNEL-LIFECYCLE-001
// ndf: kind=contract level=L1 layer=state status=accepted
// A Core has at most one active kernel invocation. Launch establishes one
// common entry PC and new invocation identity for PE0..PE3, invalidating all
// target-Core prelaunch recovery frames. Successful End and
// Abort retire invocation-owned active-PE Shared candidate/release metadata
// while preserving any published Shared parent and committed effects. Abort
// discards incomplete collective state and cancels reversible work, but
// preserves committed effects and waits for irrevocable older work to quiesce
// before a later launch. Completion from an earlier invocation MUST NOT
// update the current invocation's synchronization state. Lifecycle retirement
// MUST clear active-PE Shared generation and release metadata matching the
// retiring Core/invocation while preserving published Shared payloads and
// operation ordinals; aggregate records and another identity remain untouched.
// NDF-END: PTO-ARCH-KERNEL-LIFECYCLE-001

type KernelLifecycleResult of enumeration {
    KernelLifecycle_Started,
    KernelLifecycle_Waiting,
    KernelLifecycle_Rejected
};

func ResetKernelLifecycleState()
begin
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        _KernelInvocationByCore[[core]] = 0;
        _NextKernelInvocationIdByCore[[core]] = 1;
        _RetiredKernelInvocationByCore[[core]] = 0;
        _KernelInvocationActiveByCore[[core]] = FALSE;
    end;
end;

readonly func KernelInvocationIsActive(core: PTOModelCoreIdentity)
    => boolean
begin
    return _KernelInvocationActiveByCore[[core]];
end;

func InitializePEForKernelEntry(core: PTOModelCoreIdentity,
                                pe: MemoryAgentId,
                                entry: Word)
begin
    SelectExecutionContext(core, pe);
    InvalidatePETrapRecoveryFramesForFreshKernelEntry();
    _PC = entry;
    _BPC = Zeros{PTO_XLEN};
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    _BARG.block_type = BundleKind_Standard;
    _BARG.transfer_type = BundleTransfer_Fallthrough;
    _BARG.taken = FALSE;
    _BARG.bpcn = Zeros{PTO_XLEN};
    ClearBundleHeaderState();
    _BundleSequentialPC = Zeros{PTO_XLEN};
    _FrameStackReturnTarget = Zeros{PTO_XLEN};
    _ReturnAddress = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = Zeros{PTO_XLEN};
        _TQueueValid[[index]] = FALSE;
        _UQueue[[index]] = Zeros{PTO_XLEN};
        _UQueueValid[[index]] = FALSE;
    end;
    for predicate = 0 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        _PredicateRegisters[[predicate]] = Zeros{PTO_PREDICATE_WIDTH};
    end;
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    _CurrentProgramOrder = 0;
    _CurrentCollectiveEpoch = 0;
    _ScalarExecutionBlocked = FALSE;
    _PEProgramOrder[[core]][[pe]] = 0;
    _PECollectiveEpoch[[core]][[pe]] = 0;
    _PEBarrierNextGeneration[[core]][[pe]] = 0;
    SaveSelectedPEExecutionContext();
end;

func LaunchKernelInvocation(core: PTOModelCoreIdentity, entry: Word)
    => KernelLifecycleResult
begin
    if _KernelInvocationActiveByCore[[core]] then
        return KernelLifecycle_Waiting;
    end;
    let retired = _RetiredKernelInvocationByCore[[core]];
    if retired != 0 && !KernelGMObligationsQuiescent(core, retired) then
        return KernelLifecycle_Waiting;
    end;
    if entry[0] == '1' then return KernelLifecycle_Rejected; end;

    let previous_core = _CurrentModelCore;
    let previous_pe = _CurrentMemoryAgent;
    let invocation = _NextKernelInvocationIdByCore[[core]];
    _NextKernelInvocationIdByCore[[core]] = invocation + 1;
    _KernelInvocationByCore[[core]] = invocation;
    _KernelInvocationActiveByCore[[core]] = TRUE;
    _RetiredKernelInvocationByCore[[core]] = 0;
    _VerificationGMProgressDeferred = FALSE;
    BeginCoreSynchronizationInvocation(core, invocation);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        InitializePEForKernelEntry(core, pe as MemoryAgentId, entry);
    end;
    SelectExecutionContext(previous_core, previous_pe);
    return KernelLifecycle_Started;
end;

func EndKernelInvocation(core: PTOModelCoreIdentity)
    => KernelLifecycleResult
begin
    if !_KernelInvocationActiveByCore[[core]] then
        return KernelLifecycle_Rejected;
    end;
    let invocation = _KernelInvocationByCore[[core]];
    if !KernelGMObligationsQuiescent(core, invocation) then
        return KernelLifecycle_Waiting;
    end;
    RetirePEOwnedSharedGenerationsForInvocation(core, invocation);
    RetireSourceLifetimes(core, invocation);
    _RetiredKernelInvocationByCore[[core]] = invocation;
    RetireCoreSynchronizationInvocation(core, invocation);
    _KernelInvocationByCore[[core]] = 0;
    _KernelInvocationActiveByCore[[core]] = FALSE;
    return KernelLifecycle_Started;
end;

func AbortKernelInvocation(core: PTOModelCoreIdentity)
    => KernelLifecycleResult
begin
    if !_KernelInvocationActiveByCore[[core]] then
        return KernelLifecycle_Rejected;
    end;
    let invocation = _KernelInvocationByCore[[core]];
    AbortKernelGMObligations(core, invocation);
    AbortCoreSynchronizationInvocation(core, invocation);
    RetirePEOwnedSharedGenerationsForInvocation(core, invocation);
    RetireSourceLifetimes(core, invocation);
    _RetiredKernelInvocationByCore[[core]] = invocation;
    _KernelInvocationByCore[[core]] = 0;
    _KernelInvocationActiveByCore[[core]] = FALSE;
    return if KernelGMObligationsQuiescent(core, invocation) then
        KernelLifecycle_Started else KernelLifecycle_Waiting;
end;
