<!-- GENERATED FROM: asl/arch/memory-model/gm-obligations.asl -->
# Gm Obligations

**Normative ASL source:** `asl/arch/memory-model/gm-obligations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gm-obligations-purpose role=purpose-scope -->
## Purpose and scope

GM obligations track kernel memory requests whose effects or faults are not yet fully resolved. They connect precise retry, asynchronous producer progress, `SYNC.CORE`, and kernel retirement so a request cannot disappear merely because its instruction wrapper returned or its PE reached a collective.

The owner records request identity and lifecycle. Individual scalar, tile, TLSU, atomic, and prefetch owners still define the memory operation itself.

<!-- PTO-READER-BLOCK: arch-gm-obligations-concepts role=concepts-state -->
## Identity and state

An obligation identifies the Core, PE, invocation, dynamic instruction occurrence, execution-domain token, program order, request class, and encoded request. Its state moves among submitted, validated, issued, completed, faulted, and cancelled. Captured TSTORE progress also stores the accepted source snapshot, address, strides, mask, memory order, and access-control ring.

Registration and retry of the same occurrence reuse one identity. A later dynamic occurrence at the same PC receives another identity. The first successful executable capture is immutable, which keeps a retry from silently adopting new operands or a new access-control ring.

<!-- PTO-READER-BLOCK: arch-gm-obligations-rules role=rules-interactions -->
## Interaction with synchronization and lifecycle

An obligation that may still fault or require recovery prevents its PE from making an irrevocable collective arrival. Validated work may permit arrival, but collective release still waits until all qualifying earlier obligations complete through their real producer, issue, and completion paths.

Kernel end waits for every obligation of the invocation to become quiescent. Abort cancels reversible work but retains irrevocable work until it completes. Completion is checked against the recorded identity, so a stale completion from an old invocation cannot resolve a new request.

<!-- PTO-READER-BLOCK: arch-gm-obligations-boundaries role=boundaries -->
## Boundaries

The verification progress controls in this unit only schedule the ordinary producer path; they are not ISA-visible gates. Likewise, the bounded slot bank is model capacity rather than a portable software limit.

Only a validated Local TSTORE uses the captured progress executor. Other fault-capable requests remain with their instruction owner until that real owner reports validation, issue, fault, retry, or completion.

<!-- PTO-READER-BLOCK: arch-gm-obligations-example role=example-usage -->
## Reading example

Consider two encoded TSTORE occurrences at the same TPC. The first is admitted under ACR2 and captures source generation 4 and address A. After recovery, the second occurrence is admitted under ACR0 with source generation 5 and address B. They retain different obligation identities and immutable captures; progressing the first cannot write B or clear the second. A following `SYNC.CORE` cannot release until both earlier obligations complete.

<!-- PTO-READER-BLOCK: arch-gm-obligations-related role=related-owners-navigation -->
## Related owners

- [Core synchronization](../state/core-synchronization.md) uses obligation state to gate arrival and release.
- [Kernel lifecycle](../state/kernel-lifecycle.md) waits for quiescence and cancels reversible work on abort.
- [GM-obligation dispatch](../../block/model/dispatch/gm-obligation-dispatch.md) registers Block tile operations and drives accepted execution.
- [Memory events](memory-events.md) records the effects and provenance produced by completed operations.
- [Fault precision](fault-precision.md) owns fault and recovery behavior around retryable requests.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/gm-obligations.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","surface":"arch","classification":["memory-model","gm-obligations"],"depends_on":["PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-STATE-TYPES"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-GM-OBLIGATIONS","classification":["architecture","memory","gm-obligations"],"scope":"pe","owner":"PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","members":["_GMObligations","_NextGMObligationIdentity"],"depends_on":["PTO-STATE-ARCH-PE-EXECUTION-CONTEXT","PTO-STATE-ARCH-KERNEL-LIFECYCLE"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-GM-PROGRESS-SCHEDULER","classification":["architecture","memory","gm-progress-scheduler"],"scope":"system","owner":"PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","members":["_VerificationGMProgressDeferred","_VerificationGMProgressBeatBudget"],"depends_on":[]}
// NDF-BEGIN: PTO-ARCH-GM-OBLIGATIONS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A kernel participant's irrevocable collective arrival MUST be withheld while
// an earlier request can still fault or require recovery. Validated but
// incomplete work may remain outstanding after arrival, but it MUST prevent
// collective completion until its actual producer, issue, and completion path
// resolves it. Obligation identity includes Core, PE, invocation, dynamic
// instruction occurrence, and program-order provenance. Wrapper/producer
// registration and retry of one occurrence retain its identity, while a new
// occurrence at the same PC receives a distinct identity. The first
// executable capture binds the ACR and operands of its successful admission
// and remains immutable.
// NDF-END: PTO-ARCH-GM-OBLIGATIONS-001

type GMRequestClass of enumeration {
    GMRequest_Scalar,
    GMRequest_Tile,
    GMRequest_TLSU,
    GMRequest_Atomic,
    GMRequest_Prefetch
};

type GMObligationState of enumeration {
    GMObligation_Empty,
    GMObligation_Submitted,
    GMObligation_Validated,
    GMObligation_Issued,
    GMObligation_Completed,
    GMObligation_Faulted,
    GMObligation_Cancelled
};

type GMObligationIndex of integer {0..PTO_MODEL_GM_OBLIGATIONS-1};
type GMObligationSlot of record {
    active: boolean,
    identity: integer,
    core_identity: PTOModelCoreIdentity,
    agent: MemoryAgentId,
    invocation: integer,
    instruction_pc: Word,
    execution_domain_token: integer,
    submission_order: integer,
    collective_epoch: integer,
    collective_history_sequence: integer,
    request_class: GMRequestClass,
    encoded_request: bits(64),
    descriptor: BundleOperationDescriptor,
    bundle_argument: Word,
    bundle_tile_bindings: BundleTileBindingSnapshot,
    bundle_scalar_bindings: BundleScalarBindingSnapshot,
    bundle_shared_bindings: BundleSharedBindingSnapshot,
    bundle_dimensions: BundleDimensionSnapshot,
    source_tile: TileIndex,
    source_generation: Word,
    source_snapshot: TileInfo,
    // Only a validated Local TSTORE snapshot may use the captured progress
    // executor. Other fault-capable GM requests remain with their instruction
    // owner until the real producer/retry path resolves them.
    captured_tstore_progress: boolean,
    executable_capture_valid: boolean,
    submission_acr: AccessControlRing,
    progress_element: integer {0..32768},
    execution_mask: BundleExecutionMaskBinding,
    base_address: Word,
    row_stride_bytes: Word,
    memory_order: MemoryOrder,
    may_fault: boolean,
    state: GMObligationState,
    irrevocable: boolean,
    reversible: boolean
};
type GMObligationSlots of array [[PTO_MODEL_GM_OBLIGATIONS]]
    of GMObligationSlot;
type GMObligationCoreBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of GMObligationSlots;
type GMObligationIdentityBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of integer;

var _GMObligations : GMObligationCoreBank;
var _NextGMObligationIdentity : GMObligationIdentityBank;
// Verification scheduling controls only when the ordinary producer/issue
// path runs. Its reset value is immediate progress and it is not an ISA gate.
var _VerificationGMProgressDeferred : boolean;
// Zero means that one progress call may run the complete captured request.
// Positive values bound the number of real tile-memory beats per call.
var _VerificationGMProgressBeatBudget : integer {0..32768};

func ResetKernelGMObligations()
begin
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            _NextGMObligationIdentity[[core]][[pe]] = 0;
            for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
                _GMObligations[[core]][[pe]][[slot]].active = FALSE;
                _GMObligations[[core]][[pe]][[slot]].identity = 0;
                _GMObligations[[core]][[pe]][[slot]].execution_domain_token = 0;
                _GMObligations[[core]][[pe]][[slot]].executable_capture_valid = FALSE;
                _GMObligations[[core]][[pe]][[slot]].state =
                    GMObligation_Empty;
            end;
        end;
    end;
    _VerificationGMProgressDeferred = FALSE;
    _VerificationGMProgressBeatBudget = 0;
end;

func SetVerificationGMProgressDeferred(deferred: boolean)
begin
    _VerificationGMProgressDeferred = deferred;
end;

func SetVerificationGMProgressBeatBudget(budget:
    integer {0..32768})
begin
    _VerificationGMProgressBeatBudget = budget;
end;

readonly func VerificationGMProgressIsDeferred() => boolean
begin
    return _VerificationGMProgressDeferred;
end;

func RegisterKernelGMObligation(
    request_class: GMRequestClass,
    encoded_request: bits(64),
    instruction_pc: Word,
    descriptor: BundleOperationDescriptor,
    bundle_argument: Word,
    bundle_tile_bindings: BundleTileBindingSnapshot,
    bundle_scalar_bindings: BundleScalarBindingSnapshot,
    bundle_shared_bindings: BundleSharedBindingSnapshot,
    bundle_dimensions: BundleDimensionSnapshot,
    source_tile: TileIndex,
    source_generation: Word,
    source_snapshot: TileInfo,
    execution_mask: BundleExecutionMaskBinding,
    base_address: Word,
    row_stride_bytes: Word,
    memory_order: MemoryOrder,
    may_fault: boolean,
    validated: boolean,
    issued: boolean,
    irrevocable: boolean,
    reversible: boolean) => GMObligationIndex
begin
    let core = _CurrentModelCore;
    let pe = _CurrentMemoryAgent;
    var found = FALSE;
    var reuse_incomplete = FALSE;
    var selected: GMObligationIndex = 0;
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let previous = _GMObligations[[core]][[pe]][[slot]];
        if previous.active && previous.invocation == _CurrentKernelInvocation &&
           previous.instruction_pc == instruction_pc &&
           previous.execution_domain_token == _BundleExecutionDomainToken &&
           previous.request_class == request_class &&
           previous.encoded_request == encoded_request &&
           previous.state != GMObligation_Completed &&
           previous.state != GMObligation_Cancelled then
            selected = slot as GMObligationIndex;
            reuse_incomplete = TRUE;
            found = TRUE;
        elsif !found && (!previous.active ||
           _GMObligations[[core]][[pe]][[slot]].state ==
               GMObligation_Completed ||
           _GMObligations[[core]][[pe]][[slot]].state ==
               GMObligation_Cancelled) then
            selected = slot as GMObligationIndex;
            found = TRUE;
        end;
    end;
    assert found;
    let old = _GMObligations[[core]][[pe]][[selected]];
    let identity = if reuse_incomplete then old.identity
        else _NextGMObligationIdentity[[core]][[pe]];
    let preserve_capture = reuse_incomplete &&
        old.executable_capture_valid;
    if !reuse_incomplete then
        _NextGMObligationIdentity[[core]][[pe]] = identity + 1;
    end;
    _GMObligations[[core]][[pe]][[selected]] = GMObligationSlot {
        active = TRUE,
        identity = identity,
        core_identity = core,
        agent = pe,
        invocation = _CurrentKernelInvocation,
        instruction_pc = instruction_pc,
        execution_domain_token = _BundleExecutionDomainToken,
        submission_order = if reuse_incomplete then old.submission_order
            else _CurrentProgramOrder,
        collective_epoch = _CurrentCollectiveEpoch,
        collective_history_sequence = if reuse_incomplete then
            old.collective_history_sequence
            else _CoreCollectiveHistorySequence[[core]],
        request_class = if preserve_capture then old.request_class
            else request_class,
        encoded_request = if preserve_capture then old.encoded_request
            else encoded_request,
        descriptor = if preserve_capture then old.descriptor else descriptor,
        bundle_argument = if preserve_capture then old.bundle_argument
            else bundle_argument,
        bundle_tile_bindings = if preserve_capture then old.bundle_tile_bindings
            else bundle_tile_bindings,
        bundle_scalar_bindings = if preserve_capture then old.bundle_scalar_bindings
            else bundle_scalar_bindings,
        bundle_shared_bindings = if preserve_capture then old.bundle_shared_bindings
            else bundle_shared_bindings,
        bundle_dimensions = if preserve_capture then old.bundle_dimensions
            else bundle_dimensions,
        source_tile = if preserve_capture then old.source_tile else source_tile,
        source_generation = if preserve_capture then old.source_generation
            else source_generation,
        source_snapshot = if preserve_capture then old.source_snapshot
            else source_snapshot,
        captured_tstore_progress = if reuse_incomplete then
            old.captured_tstore_progress else FALSE,
        executable_capture_valid = if reuse_incomplete then
            old.executable_capture_valid else FALSE,
        submission_acr = if preserve_capture then old.submission_acr
            else CurrentACR(),
        progress_element = if reuse_incomplete then old.progress_element else 0,
        execution_mask = if preserve_capture then old.execution_mask
            else execution_mask,
        base_address = if preserve_capture then old.base_address
            else base_address,
        row_stride_bytes = if preserve_capture then old.row_stride_bytes
            else row_stride_bytes,
        memory_order = if preserve_capture then old.memory_order
            else memory_order,
        may_fault = may_fault,
        state = if issued then GMObligation_Issued
            else if validated then GMObligation_Validated
            else GMObligation_Submitted,
        irrevocable = if reuse_incomplete then old.irrevocable else irrevocable,
        reversible = if reuse_incomplete then old.reversible else reversible
    };
    return selected;
end;

func MarkGMObligationCapturedTStoreProgress(core: PTOModelCoreIdentity,
                                            pe: MemoryAgentId,
                                            slot: GMObligationIndex)
begin
    if _GMObligations[[core]][[pe]][[slot]].active then
        _GMObligations[[core]][[pe]][[slot]].captured_tstore_progress = TRUE;
    end;
end;

func UpdateGMObligationState(core: PTOModelCoreIdentity,
                             pe: MemoryAgentId,
                             slot: GMObligationIndex,
                             state: GMObligationState)
begin
    if _GMObligations[[core]][[pe]][[slot]].active then
        _GMObligations[[core]][[pe]][[slot]].state = state;
    end;
end;

func ValidateGMObligation(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                          slot: GMObligationIndex)
begin
    UpdateGMObligationState(core, pe, slot, GMObligation_Validated);
end;

func IssueGMObligation(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                       slot: GMObligationIndex)
begin
    UpdateGMObligationState(core, pe, slot, GMObligation_Issued);
end;

func MarkGMObligationIrrevocable(core: PTOModelCoreIdentity,
                                 pe: MemoryAgentId,
                                 slot: GMObligationIndex)
begin
    if _GMObligations[[core]][[pe]][[slot]].active then
        _GMObligations[[core]][[pe]][[slot]].irrevocable = TRUE;
        _GMObligations[[core]][[pe]][[slot]].reversible = FALSE;
    end;
end;

func CompleteGMObligationForIdentity(core: PTOModelCoreIdentity,
                                     pe: MemoryAgentId,
                                     slot: GMObligationIndex,
                                     invocation: integer,
                                     identity: integer)
begin
    let obligation = _GMObligations[[core]][[pe]][[slot]];
    if obligation.active && obligation.invocation == invocation &&
       obligation.identity == identity then
        _GMObligations[[core]][[pe]][[slot]].may_fault = FALSE;
        UpdateGMObligationState(core, pe, slot, GMObligation_Completed);
    end;
end;

func FaultGMObligation(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                       slot: GMObligationIndex)
begin
    UpdateGMObligationState(core, pe, slot, GMObligation_Faulted);
end;

func RetryGMObligation(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                       slot: GMObligationIndex)
begin
    UpdateGMObligationState(core, pe, slot, GMObligation_Submitted);
end;

func ResolveGMObligationFaultRisk(core: PTOModelCoreIdentity,
                                  pe: MemoryAgentId,
                                  slot: GMObligationIndex)
begin
    if _GMObligations[[core]][[pe]][[slot]].active then
        if !_GMObligations[[core]][[pe]][[slot]].executable_capture_valid then
            // This real producer check follows complete request-footprint
            // validation. Failed attempts keep their occurrence identity but
            // may retry under a recovered CurrentACR.
            _GMObligations[[core]][[pe]][[slot]].submission_acr = _CurrentACR;
            _GMObligations[[core]][[pe]][[slot]].executable_capture_valid = TRUE;
        end;
        _GMObligations[[core]][[pe]][[slot]].may_fault = FALSE;
        _GMObligations[[core]][[pe]][[slot]].state = GMObligation_Validated;
    end;
end;

readonly func CoreGMObligationsPermitArrival(core: PTOModelCoreIdentity,
                                   pe: MemoryAgentId,
                                   invocation: integer,
                                   program_order_cut: integer) => boolean
begin
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let obligation = _GMObligations[[core]][[pe]][[slot]];
        if obligation.active && obligation.invocation == invocation &&
           obligation.submission_order <= program_order_cut then
            if obligation.state == GMObligation_Faulted ||
               (obligation.may_fault &&
                obligation.state != GMObligation_Completed &&
                obligation.state != GMObligation_Cancelled) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func CoreGMObligationsComplete(core: PTOModelCoreIdentity,
                                        pe: MemoryAgentId,
                                        invocation: integer,
                                        program_order_cut: integer)
                                        => boolean
begin
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let obligation = _GMObligations[[core]][[pe]][[slot]];
        if obligation.active && obligation.invocation == invocation &&
           obligation.submission_order <= program_order_cut &&
           obligation.state != GMObligation_Completed then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func KernelGMObligationsQuiescent(core: PTOModelCoreIdentity,
                                           invocation: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
            let obligation = _GMObligations[[core]][[pe]][[slot]];
            if obligation.active && obligation.invocation == invocation &&
               obligation.state != GMObligation_Completed &&
               obligation.state != GMObligation_Cancelled then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func AbortKernelGMObligations(core: PTOModelCoreIdentity,
                              invocation: integer)
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
            let obligation = _GMObligations[[core]][[pe]][[slot]];
            if obligation.active && obligation.invocation == invocation &&
               obligation.reversible && !obligation.irrevocable &&
               obligation.state != GMObligation_Completed then
                _GMObligations[[core]][[pe]][[slot]].state =
                    GMObligation_Cancelled;
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
