<!-- GENERATED FROM: asl/arch/state/kernel-lifecycle.asl -->
# Kernel Lifecycle

**Normative ASL source:** `asl/arch/state/kernel-lifecycle.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-KERNEL-LIFECYCLE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-purpose role=purpose-scope -->
## Purpose and scope

This unit controls the lifetime of one kernel invocation on a modeled Core: launch, successful end, and abort. It exists so work left by one invocation cannot be mistaken for work belonging to a later invocation, while effects that have already committed remain visible.

The lifecycle owner coordinates PE initialization, Core synchronization, GM obligations, Shared-generation metadata, and source lifetimes. The owners of those mechanisms still define their detailed behavior.

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-concepts role=concepts-state -->
## Invocation state

Each Core records whether an invocation is active, its current identity, the next identity to allocate, and the most recently retired identity. Launch assigns the same entry PC and fresh invocation identity to PE0 through PE3, initializes the entry, Block-header, queue, predicate, fault, origin, and ordering fields named by `InitializePEForKernelEntry`, and starts synchronization generation zero.

The invocation identity is the key separation mechanism. Synchronization records, GM obligations, Shared-generation requests, and source-lifetime occurrences carry it, so a completion from an older invocation cannot update the current one.

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-rules role=rules-interactions -->
## Lifecycle interactions

`LaunchKernelInvocation` waits if the Core already has an active invocation or if the retired invocation still has non-quiescent GM obligations. It rejects an odd entry address. Once admitted, it initializes every PE and returns `KernelLifecycle_Started`.

`EndKernelInvocation` waits for all GM obligations of the active identity to become quiescent, then retires invocation-owned Shared-generation metadata and source-lifetime records before closing synchronization state. `AbortKernelInvocation` first cancels reversible GM work and incomplete synchronization, performs the same identity-scoped retirement, and reports waiting when irrevocable older work still has to finish.

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-boundaries role=boundaries -->
## Boundaries

End and abort do not erase committed memory effects or a published Shared parent. They clear active metadata that matches the retiring Core and invocation; records for another identity remain intact. Abort also does not pretend that irrevocable work was cancelled: a later launch stays blocked until that work is quiescent.

The fixed number of modeled Cores, PEs, and bounded records is a model capacity. This page does not add a portable software-visible limit beyond the behavior stated by the owning ASL.

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-example role=example-usage -->
## Reading example

Suppose Core 0 launches invocation 7 and PE0 has an incomplete reversible store while a Shared parent from invocation 7 has already published. An abort cancels the reversible store and removes invocation-7 candidate and release metadata, but preserves the published parent. If another store has already become irrevocable, the abort can return `KernelLifecycle_Waiting`; Core 0 cannot launch invocation 8 until that obligation completes.

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-related role=related-owners-navigation -->
## Related owners

- [PE execution context](pe-execution-context.md) defines the private state initialized for each PE.
- [Core synchronization](core-synchronization.md) owns invocation-scoped rendezvous and release tokens.
- [GM obligations](../memory-model/gm-obligations.md) decide when end, abort, and a later launch may proceed.
- [Shared-generation PE requests](../../block/model/operands/shared-generation-pe-requests.md) owns the candidate and release metadata retired here.
- [Source lifetime](../../block/model/state/source-lifetime.md) owns the captured occurrences retired here.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/kernel-lifecycle.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-KERNEL-LIFECYCLE","surface":"arch","classification":["state","kernel-lifecycle"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-STATE-CORE-SYNCHRONIZATION","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-BLOCK-MODEL-STATE-ATOMIC-TSTORE-SOURCE-LIFETIME","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION"]}
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
    if !KernelHasIrrevocableAtomicTStore(core, invocation) then
        RetireSourceLifetimes(core, invocation);
    end;
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
    if !KernelHasIrrevocableAtomicTStore(core, invocation) then
        RetireSourceLifetimes(core, invocation);
    end;
    _RetiredKernelInvocationByCore[[core]] = invocation;
    _KernelInvocationByCore[[core]] = 0;
    _KernelInvocationActiveByCore[[core]] = FALSE;
    return if KernelGMObligationsQuiescent(core, invocation) then
        KernelLifecycle_Started else KernelLifecycle_Waiting;
end;
```
<!-- GENERATED-ASL-END: unit -->
