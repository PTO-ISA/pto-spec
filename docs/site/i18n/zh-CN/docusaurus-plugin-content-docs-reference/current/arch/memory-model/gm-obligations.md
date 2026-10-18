<!-- GENERATED FROM: asl/arch/memory-model/gm-obligations.asl -->
# Gm Obligations

**Normative ASL source:** `asl/arch/memory-model/gm-obligations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gm-obligations-purpose role=purpose-scope -->
## 目的和范围

GM obligation 跟踪其效果或 fault 尚未完全解决的 kernel memory request。它们连接 precise retry、asynchronous producer progress、`SYNC.CORE` 和 kernel retirement，使 request 不会只因其 instruction wrapper 已返回或其 PE 已抵达 collective 而消失。

该所有者记录 request identity 和 lifecycle。各 scalar、tile、TLSU、atomic 和 prefetch owner 仍定义 memory operation 本身。

<!-- PTO-READER-BLOCK: arch-gm-obligations-concepts role=concepts-state -->
## 标识和状态

一个 obligation 标识 Core、PE、invocation、dynamic instruction occurrence、execution-domain token、program order、request class 和 encoded request。其状态在 submitted、validated、issued、completed、faulted 和 cancelled 之间变化。captured TSTORE progress 还保存获准的 source snapshot、address、stride、mask、memory order 和 access-control ring。

同一 occurrence 的 registration 和 retry 复用一个 identity。同一 PC 上较晚的 dynamic occurrence 获得另一个 identity。首次成功的 executable capture 不可变，因此 retry 不会悄然采用新 operand 或新 access-control ring。

<!-- PTO-READER-BLOCK: arch-gm-obligations-rules role=rules-interactions -->
## 与同步和生命周期的交互

仍可能 fault 或需要 recovery 的 obligation 会阻止其 PE 形成 irrevocable collective arrival。validated work 可以允许 arrival，但 collective release 仍会等待所有符合条件的更早 obligation 通过其真实 producer、issue 和 completion path 完成。

kernel end 等待该 invocation 的每个 obligation 静止。abort 取消 reversible work，但保留 irrevocable work 直至其完成。completion 按记录的 identity 检查，因此旧 invocation 的 stale completion 不能解决新 request。

<!-- PTO-READER-BLOCK: arch-gm-obligations-boundaries role=boundaries -->
## 边界

本单元中的 verification progress control 只调度普通 producer path；它们不是 ISA-visible gate。同样，有界 slot bank 是模型容量，而非软件可移植限制。

只有 validated Local TSTORE 使用 captured progress executor。其他 fault-capable request 留在其 instruction owner 中，直到真实所有者报告 validation、issue、fault、retry 或 completion。

<!-- PTO-READER-BLOCK: arch-gm-obligations-example role=example-usage -->
## 阅读示例

考虑同一 TPC 上两个 encoded TSTORE occurrence。第一个在 ACR2 下获准并捕获 source generation 4 和地址 A。恢复后，第二个 occurrence 在 ACR0 下获准，使用 source generation 5 和地址 B。它们保留不同 obligation identity 和 immutable capture；推进第一个不能写入 B 或清除第二个。后续 `SYNC.CORE` 只有在两个更早 obligation 都完成后才能 release。

<!-- PTO-READER-BLOCK: arch-gm-obligations-related role=related-owners-navigation -->
## 相关所有者

- [Core synchronization](../state/core-synchronization.md) 使用 obligation state gate arrival 和 release。
- [Kernel lifecycle](../state/kernel-lifecycle.md) 在 abort 时等待 quiescence 并取消 reversible work。
- [GM-obligation dispatch](../../block/model/dispatch/gm-obligation-dispatch.md) 注册 Block tile operation 并驱动 accepted execution。
- [Memory events](memory-events.md) 记录 completed operation 产生的 effect 和 provenance。
- [Fault precision](fault-precision.md) 拥有 retryable request 周围的 fault 和 recovery 行为。
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
