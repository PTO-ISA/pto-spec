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

// NDF-BEGIN: PTO-ARCH-RUNTIME-STARTUP-ABI-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// The four-PE runtime startup ABI MUST preserve the common entry and invocation
// identity of [[PTO-ARCH-KERNEL-LIFECYCLE-001]]. All four independently executing
// contexts enter the same runtime entry; it MUST select PE0 as the sole shared
// initialization leader using [[PTO-THREAD-ID-PE-IDENTITY-001]]. Separate initial
// leader/worker PCs are not this ABI; branching after common entry is permitted.
// Before using a stack, private storage, or launch arguments, each PE MUST have
// valid bootstrap bindings supplied by the loader/platform or established by
// private entry code. Worker bootstrap MUST NOT read unfinished leader-produced
// state or overlap storage being initialized by PE0. Concrete bindings belong
// to the platform ABI, not to LaunchKernelInvocation's state initialization.
// PE0 MUST perform the invocation's shared initialization. PE1..PE3 MUST perform
// only necessary private bootstrap, then wait at the startup SYNC.CORE. They
// MUST NOT duplicate shared initialization or enter the kernel work phase early.
// Every PE MUST execute the same static startup SYNC.CORE site at generation
// zero of this invocation, in its legal Scalar SYS envelope. PE0 MUST arrive
// only after its shared initialization has succeeded. That initialization MUST
// NOT require a four-PE collective while workers wait at the startup barrier.
// Each PE may enter the kernel work phase only after consuming its startup
// release under [[PTO-ARCH-CORE-SYNCHRONIZATION-001]]. Its preceding GM effects
// and following accesses retain the existing collective memory-order contract.
// PE_MASK, local fences, a ready flag, elapsed time, or loader return MUST NOT
// substitute for four actual arrivals and completion of earlier GM obligations.
// SYNC.CORE is a rendezvous, not a mechanism for creating or waking unlaunched
// PE contexts. Single-context hosted execution MUST NOT use this startup path.
// NDF-END: PTO-ARCH-RUNTIME-STARTUP-ABI-001

// NDF-BEGIN: PTO-ARCH-RUNTIME-STARTUP-LIFETIME-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Shared startup initialization has one software owner, PE0. Process-lifetime
// initialization, including libc/constructor and process-service setup when
// present, MUST NOT be repeated by worker PEs or merely because another kernel
// invocation begins. The hosted ABI owns process lifetime; each invocation
// still performs its own shared preparation and startup rendezvous. Workers
// MUST NOT use libc/TLS/host services during bootstrap unless their separate
// ABI explicitly supplies valid PE-private state and permits that use.
// A recoverable startup fault or interrupt MUST resume through the existing
// precise instruction/request restart contract in the same invocation, preserving
// committed effects. Normal request replay retains its existing semantics; this
// ABI does not promise exactly-once memory beats. Trap return MUST NOT by itself
// restart completed process constructors or manufacture an additional arrival.
// On unrecoverable initialization failure or a missing participant, the runtime
// MUST NOT report startup success or allow peers into the kernel work phase.
// Missing arrivals remain blocked; a platform/runtime may request the existing
// invocation abort, but MUST NOT fabricate a release or silently run fewer PEs.
// Abort, committed-effect preservation and quiescence before relaunch follow
// [[PTO-ARCH-KERNEL-LIFECYCLE-001]]. Relaunch MUST use a fresh invocation and a
// fresh startup rendezvous; stale ready flags, arrivals or release tokens MUST
// NOT authorize entry. The runtime owns repairing or reinitializing partially
// prepared application data before a later successful startup; abort does not
// roll back committed stores. External failure reporting and process exit are
// platform/hosted ABI obligations, not new instruction fault or exit semantics.
// NDF-END: PTO-ARCH-RUNTIME-STARTUP-LIFETIME-001

// NDF-BEGIN: PTO-ARCH-RUNTIME-STARTUP-ADAPTATION-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Consumers claiming four-PE runtime startup ABI support MUST implement
// [[PTO-ARCH-RUNTIME-STARTUP-ABI-001]] and
// [[PTO-ARCH-RUNTIME-STARTUP-LIFETIME-001]] together. Compiler/linker and startup
// objects MUST preserve common entry, legal THREAD_ID/SYNC.CORE placement,
// PE0-only shared initialization, and the startup memory-order boundary.
// Runtime/libc integration MUST separate process/shared initialization from
// PE-private bootstrap and invocation preparation. Platform loaders MUST bind
// entry, arguments, isolated private stacks/storage, context creation, invocation
// identity, and completion/failure/abort interfaces explicitly before use.
// Functional/timing models MUST execute four real independent PE contexts and
// preserve waiting, fault, abort and relaunch behavior. Creating host/OS threads
// alone or repeatedly invoking one architectural context does not satisfy this
// requirement; a simulator may use host threads to implement independent contexts.
// Validation MUST include a common-entry runtime-only ELF that demonstrates
// distinct PE identities and private stacks, exactly one shared initializer,
// workers blocked before release, initialized-data visibility after release,
// both leader-first and workers-first arrival, missing-participant blocking,
// startup failure, and abort/relaunch isolation. Benchmark adoption additionally
// requires the same ELF and launch bindings across compared models, independent
// golden output, and declared toolchain/runtime/model revisions. Instruction
// tests alone MUST NOT be reported as complete runtime or hardware validation.
// Numeric entry/argument/stack/TLS layouts, ELF identification, launch transport,
// syscall/fd/exit policy and platform status/reset interfaces remain separately
// owned ABI decisions; this contract assigns no new values or fallback behavior.
// NDF-END: PTO-ARCH-RUNTIME-STARTUP-ADAPTATION-001

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
