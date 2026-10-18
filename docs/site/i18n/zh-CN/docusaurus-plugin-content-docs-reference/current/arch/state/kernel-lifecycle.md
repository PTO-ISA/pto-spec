<!-- GENERATED FROM: asl/arch/state/kernel-lifecycle.asl -->
# Kernel Lifecycle

**Normative ASL source:** `asl/arch/state/kernel-lifecycle.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-KERNEL-LIFECYCLE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-purpose role=purpose-scope -->
## 目的和范围

本单元控制一个建模 Core 上一次内核调用的生命周期：启动、正常结束和中止。它确保一次调用遗留的工作不会被误认为属于后续调用，同时已经提交的效果仍然可见。

生命周期所有者协调 PE 初始化、Core 同步、GM obligation、Shared generation 元数据和 source lifetime。这些机制的详细行为仍由各自的所有者定义。

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-concepts role=concepts-state -->
## 调用状态

每个 Core 记录调用是否活跃、当前标识、下一个待分配标识和最近退役的标识。启动为 PE0 到 PE3 设置相同的入口 PC 和新的调用标识，初始化 `InitializePEForKernelEntry` 所列的 entry、Block-header、queue、predicate、fault、origin 和 ordering 字段，并开始同步 generation 0。

调用标识是隔离的关键。同步记录、GM obligation、Shared generation 请求和 source-lifetime occurrence 都携带该标识，因此旧调用的完成不能更新当前调用。

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-rules role=rules-interactions -->
## 生命周期交互

当 Core 已有活跃调用，或已退役调用仍有未静止的 GM obligation 时，`LaunchKernelInvocation` 会等待。奇数入口地址会被拒绝。获准后，它初始化所有 PE 并返回 `KernelLifecycle_Started`。

`EndKernelInvocation` 等待活跃标识的全部 GM obligation 静止，然后在关闭同步状态前退役调用拥有的 Shared generation 元数据和 source-lifetime 记录。`AbortKernelInvocation` 先取消可逆 GM 工作和未完成同步，执行同样按标识限定的退役；如果不可逆的旧工作仍需完成，则报告等待。

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-boundaries role=boundaries -->
## 边界

结束和中止不会清除已提交的内存效果或已经发布的 Shared parent。它们清除与退役 Core 和调用匹配的活跃元数据；其他标识的记录保持不变。中止也不会假装不可逆工作已经取消：在该工作静止前，后续启动保持阻塞。

建模 Core、PE 和有界记录的固定数量是模型容量。本页不会在所有者 ASL 所述行为之外增加软件可见的可移植限制。

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-example role=example-usage -->
## 阅读示例

假设 Core 0 启动调用 7，PE0 有一个未完成的可逆 store，而调用 7 的 Shared parent 已经发布。中止会取消该可逆 store，并移除调用 7 的 candidate 和 release 元数据，但保留已发布 parent。若另一个 store 已经不可逆，中止可以返回 `KernelLifecycle_Waiting`；在该 obligation 完成前，Core 0 不能启动调用 8。

<!-- PTO-READER-BLOCK: arch-kernel-lifecycle-related role=related-owners-navigation -->
## 相关所有者

- [PE execution context](pe-execution-context.md) 定义启动时为每个 PE 初始化的私有状态。
- [Core synchronization](core-synchronization.md) 拥有按调用限定的 rendezvous 和 release token。
- [GM obligations](../memory-model/gm-obligations.md) 决定结束、中止和后续启动何时可以继续。
- [Shared-generation PE requests](../../block/model/operands/shared-generation-pe-requests.md) 拥有此处退役的 candidate 和 release 元数据。
- [Source lifetime](../../block/model/state/source-lifetime.md) 拥有此处退役的捕获 occurrence。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/kernel-lifecycle.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
