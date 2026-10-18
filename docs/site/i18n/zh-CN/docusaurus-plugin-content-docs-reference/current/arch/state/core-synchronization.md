<!-- GENERATED FROM: asl/arch/state/core-synchronization.asl -->
# Core Synchronization

**Normative ASL source:** `asl/arch/state/core-synchronization.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-CORE-SYNCHRONIZATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-core-sync-purpose role=purpose-scope -->
## 目的和范围

本单元将 `SYNC.CORE` 实现为一个 Core 和一个活跃 kernel invocation 内的四 PE rendezvous。该 rendezvous 延迟每个 participant，直到四个 PE 都抵达同一 static site，且更早的 GM obligation 已完成。

显式 generation 和 release record 使快慢 PE 能够独立推进而不丢失 release。active generation record 回收后，保留的 memory-event provenance 继续承载 ordering effect。

<!-- PTO-READER-BLOCK: arch-core-sync-concepts role=concepts-state -->
## Generation、arrival 和 release

一个 generation record 包含 Core、invocation、generation number、static site、arrival mask、每个 PE 的 arrival program order、release state 和 consumed mask。每个 PE 还分别跟踪其 next generation 和一个可选的 once-only release token。

participant mask 始终是全部四个 PE。`PE_MASK` 不会减少成员。`_CoreCollectiveHistorySequence` 在 release 时递增，并复制到 memory-event provenance，因此 completed relation 能在 record reuse 后继续存在。

<!-- PTO-READER-BLOCK: arch-core-sync-rules role=rules-interactions -->
## Rendezvous 规则

`SyncCore` 首先通过停驻 scalar path 拒绝 handler-origin execution 和 active invocation 之外的执行。若已有 release token，则先消费。否则，它要求更早的 fault-capable GM work 允许 arrival，再按当前 TPC 查找或分配该 PE 的 generation record。

位于不同 static site 的 arrival 不能加入该 record。四个 arrival bit 全部设置后，completion 仍会等待每个 participant 在其记录 arrival order 之前的 GM obligation 完成。release 为每个 PE 提供一个 token，使 Core PE reservation 失效，并仅在该 PE 消费 token 时推进其 generation。

<!-- PTO-READER-BLOCK: arch-core-sync-boundaries role=boundaries -->
## 边界

participant 在停驻时不会推进 PC。后续 generation 不能覆盖未消费的 release token，lifecycle retirement 只清除 closing invocation 的 active record 和 token。此 helper 描述 dispatch 已选择它之后的同步；encoded `SYNC.CORE` envelope 的 legality 和 fault 仍属于 scalar instruction 和 dispatch owner。

有界 generation ring 是模型存储，并不构成软件可见的许可，不能据此跳过 participant 或合并 site。completed ordering 不属于可重用 ring slot：`MemoryCollectiveSyncBefore` 比较同一 Core 和 invocation 中 kernel event 所保留的 provenance。

<!-- PTO-READER-BLOCK: arch-core-sync-example role=example-usage -->
## 阅读示例

PE0、PE1 和 PE2 可以抵达 generation 0，并在 PE3 仍有一个更早的 fault-capable store 时保持停驻。一旦该 store 的 fault risk 已解除且验证成功，PE3 即使在 store 尚未完成时也可以不可逆地抵达同一 TPC。generation 只在 store 完成后 release，随后每个 PE 都收到自己的 token。PE0 可以立即消费并进入 generation 1，而 PE2 仍持有 generation-0 token；PE2 必须恰好消费一次旧 token，才能加入 generation 1。

<!-- PTO-READER-BLOCK: arch-core-sync-related role=related-owners-navigation -->
## 相关所有者

- [Kernel lifecycle](kernel-lifecycle.md) 开始和退役 invocation-scoped synchronization state。
- [GM obligations](../memory-model/gm-obligations.md) 按更早 memory request gate arrival 和 completion。
- [Memory events](../memory-model/memory-events.md) 在 active record reuse 后保留 collective history。
- [PE execution context](pe-execution-context.md) 在选择切换时保持 per-PE program order 和 blocked execution 一致。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/core-synchronization.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-CORE-SYNCHRONIZATION","surface":"arch","classification":["state","core-synchronization"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-CORE-SYNCHRONIZATION","classification":["architecture","core-synchronization"],"scope":"core","owner":"PTO-ARCH-STATE-CORE-SYNCHRONIZATION","members":["_CoreSyncRecords","_CoreCollectiveHistorySequence"],"depends_on":["PTO-STATE-ARCH-KERNEL-LIFECYCLE"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-CORE-SYNCHRONIZATION-PE","classification":["architecture","core-synchronization","pe-progress"],"scope":"pe","owner":"PTO-ARCH-STATE-CORE-SYNCHRONIZATION","members":["_PEBarrierNextGeneration","_PEReleaseValid","_PEReleaseGeneration","_PEProgramOrder","_PECollectiveEpoch"],"depends_on":["PTO-STATE-ARCH-PE-EXECUTION-CONTEXT","PTO-STATE-ARCH-CORE-SYNCHRONIZATION"]}
// NDF-BEGIN: PTO-ARCH-CORE-SYNCHRONIZATION-001
// ndf: kind=contract level=L1 layer=state status=accepted
// Each modeled Core MUST rendezvous exactly PE0 through PE3 at one static
// SYNC.CORE site and generation in one active invocation. A participant MUST
// remain parked without advancing its PC until all arrivals and earlier GM
// obligations are complete. Completion is irrevocable; each PE retains its
// own release token until consumed once, and a later generation cannot replace
// an unconsumed token. PE_MASK does not change membership. Memory-event
// provenance for a completed collective MUST survive release consumption,
// generation-record reuse, Core selection, and later invocation setup.
// NDF-END: PTO-ARCH-CORE-SYNCHRONIZATION-001

type CoreSyncArrivalOrders of array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
type CoreSyncGenerationRecord of record {
    valid: boolean,
    core_identity: PTOModelCoreIdentity,
    invocation: integer,
    generation: integer,
    site: Word,
    arrived: bits(PTO_MODEL_MEMORY_AGENTS),
    arrival_orders: CoreSyncArrivalOrders,
    released: boolean,
    consumed: bits(PTO_MODEL_MEMORY_AGENTS)
};
type CoreSyncGenerationRing of array [[PTO_MODEL_SYNC_GENERATIONS]]
    of CoreSyncGenerationRecord;
type CoreSyncCoreBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of CoreSyncGenerationRing;
type CoreSyncGenerationByPE of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of integer;
type CoreSyncReleaseMaskByCore of array [[PTO_MODEL_CORE_INSTANCES]]
    of bits(PTO_MODEL_MEMORY_AGENTS);
type CoreSyncProgramOrderByPE of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of integer;

var _CoreSyncRecords : CoreSyncCoreBank;
var _PEBarrierNextGeneration : CoreSyncGenerationByPE;
var _PEReleaseGeneration : CoreSyncGenerationByPE;
var _PEReleaseValid : CoreSyncReleaseMaskByCore;
var _PEProgramOrder : CoreSyncProgramOrderByPE;
var _PECollectiveEpoch : CoreSyncProgramOrderByPE;
// Retained collective provenance is Core-scoped architectural model state.
var _CoreCollectiveHistorySequence :
    array [[PTO_MODEL_CORE_INSTANCES]] of integer;

readonly func CoreSyncAllParticipantsMask() => bits(4)
begin
    return Ones{4};
end;

func ResetCoreSynchronizationState()
begin
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        _CoreCollectiveHistorySequence[[core]] = 0;
        _PEReleaseValid[[core]] = Zeros{PTO_MODEL_MEMORY_AGENTS};
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            _PEBarrierNextGeneration[[core]][[pe]] = 0;
            _PEReleaseGeneration[[core]][[pe]] = 0;
            _PEProgramOrder[[core]][[pe]] = 0;
            _PECollectiveEpoch[[core]][[pe]] = 0;
        end;
        for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
            _CoreSyncRecords[[core]][[slot]].valid = FALSE;
            _CoreSyncRecords[[core]][[slot]].core_identity = core;
            _CoreSyncRecords[[core]][[slot]].invocation = 0;
            _CoreSyncRecords[[core]][[slot]].generation = 0;
            _CoreSyncRecords[[core]][[slot]].site = Zeros{PTO_XLEN};
            _CoreSyncRecords[[core]][[slot]].arrived = Zeros{4};
            _CoreSyncRecords[[core]][[slot]].released = FALSE;
            _CoreSyncRecords[[core]][[slot]].consumed = Zeros{4};
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                _CoreSyncRecords[[core]][[slot]].arrival_orders[[pe]] = 0;
            end;
        end;
    end;
end;

readonly func FindCoreSyncGenerationRecord(
    core: PTOModelCoreIdentity,
    invocation: integer,
    generation: integer) => integer {0..PTO_MODEL_SYNC_GENERATIONS}
begin
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        if _CoreSyncRecords[[core]][[slot]].valid &&
           _CoreSyncRecords[[core]][[slot]].invocation == invocation &&
           _CoreSyncRecords[[core]][[slot]].generation == generation then
            return slot as integer {0..PTO_MODEL_SYNC_GENERATIONS};
        end;
    end;
    return PTO_MODEL_SYNC_GENERATIONS;
end;

func AllocateCoreSyncGenerationRecord(core: PTOModelCoreIdentity,
                                      invocation: integer,
                                      generation: integer,
                                      site: Word)
                                      => integer {0..PTO_MODEL_SYNC_GENERATIONS}
begin
    var selected: integer {0..PTO_MODEL_SYNC_GENERATIONS} =
        PTO_MODEL_SYNC_GENERATIONS;
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        let old = _CoreSyncRecords[[core]][[slot]];
        if !old.valid ||
           (old.released && old.consumed == CoreSyncAllParticipantsMask()) then
            if selected == PTO_MODEL_SYNC_GENERATIONS then
                selected = slot;
            end;
        end;
    end;
    if selected == PTO_MODEL_SYNC_GENERATIONS then return selected; end;
    let index = selected as integer {0..PTO_MODEL_SYNC_GENERATIONS-1};
    _CoreSyncRecords[[core]][[index]].valid = TRUE;
    _CoreSyncRecords[[core]][[index]].core_identity = core;
    _CoreSyncRecords[[core]][[index]].invocation = invocation;
    _CoreSyncRecords[[core]][[index]].generation = generation;
    _CoreSyncRecords[[core]][[index]].site = site;
    _CoreSyncRecords[[core]][[index]].arrived = Zeros{4};
    _CoreSyncRecords[[core]][[index]].released = FALSE;
    _CoreSyncRecords[[core]][[index]].consumed = Zeros{4};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        _CoreSyncRecords[[core]][[index]].arrival_orders[[pe]] = 0;
    end;
    return selected;
end;

func InvalidateCorePEReservations(core: PTOModelCoreIdentity)
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        if core == _CurrentModelCore &&
           pe == (_CurrentMemoryAgent as integer {0..3}) then
            _ReservationValid = FALSE;
        end;
        if _PEContextBankValid[[core]][pe] == '1' then
            _PEExecutionContexts[[core]][[pe]].reservation_valid = FALSE;
        elsif core == _CurrentModelCore &&
              !_CurrentPEContextValid && pe == 0 then
            _DefaultPEExecutionContext.reservation_valid = FALSE;
        end;
    end;
end;

func ReleaseCoreSyncGeneration(core: PTOModelCoreIdentity,
                               slot: integer {0..PTO_MODEL_SYNC_GENERATIONS-1})
begin
    _CoreSyncRecords[[core]][[slot]].released = TRUE;
    _CoreCollectiveHistorySequence[[core]] =
        _CoreCollectiveHistorySequence[[core]] + 1;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let bit_index = PTOPEMaskBitOfPEIdentity(pe as integer {0..3});
        _PEReleaseValid[[core]][bit_index] = '1';
        _PEReleaseGeneration[[core]][[pe]] =
            _CoreSyncRecords[[core]][[slot]].generation;
    end;
    InvalidateCorePEReservations(core);
end;

func TryCompleteCoreSynchronization(core: PTOModelCoreIdentity)
begin
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        let generation_record = _CoreSyncRecords[[core]][[slot]];
        if generation_record.valid && !generation_record.released &&
           generation_record.arrived == CoreSyncAllParticipantsMask() then
            var obligations_complete = TRUE;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                if !CoreGMObligationsComplete(core,
                       pe as MemoryAgentId, generation_record.invocation,
                       generation_record.arrival_orders[[pe]]) then
                    obligations_complete = FALSE;
                end;
            end;
            if obligations_complete then
                ReleaseCoreSyncGeneration(core,
                    slot as integer {0..PTO_MODEL_SYNC_GENERATIONS-1});
            end;
        end;
    end;
end;

func ConsumeCoreSyncRelease(core: PTOModelCoreIdentity,
                            pe: MemoryAgentId) => boolean
begin
    let bit_index = PTOPEMaskBitOfPEIdentity(pe as integer {0..3});
    if _PEReleaseValid[[core]][bit_index] != '1' ||
       _PEReleaseGeneration[[core]][[pe]] !=
           _PEBarrierNextGeneration[[core]][[pe]] then
        return FALSE;
    end;
    let invocation = _KernelInvocationByCore[[core]];
    let generation = _PEBarrierNextGeneration[[core]][[pe]];
    let slot = FindCoreSyncGenerationRecord(core, invocation, generation);
    if slot < PTO_MODEL_SYNC_GENERATIONS then
        _CoreSyncRecords[[core]][[slot]].consumed[bit_index] = '1';
    end;
    _PEReleaseValid[[core]][bit_index] = '0';
    _PEBarrierNextGeneration[[core]][[pe]] = generation + 1;
    _PECollectiveEpoch[[core]][[pe]] = generation + 1;
    if core == _CurrentModelCore && pe == _CurrentMemoryAgent then
        _CurrentCollectiveEpoch = generation + 1;
    end;
    return TRUE;
end;

func SyncCore()
begin
    if _CurrentMemoryOrigin == MemoryEventOrigin_Handler ||
       !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 then
        _ScalarExecutionBlocked = TRUE;
        return;
    end;
    if ConsumeCoreSyncRelease(_CurrentModelCore, _CurrentMemoryAgent) then
        return;
    end;

    let core = _CurrentModelCore;
    let pe = _CurrentMemoryAgent;
    let invocation = _CurrentKernelInvocation;
    let generation = _PEBarrierNextGeneration[[core]][[pe]];
    let site = ReadTPC();
    let bit_index = PTOPEMaskBitOfPEIdentity(pe as integer {0..3});
    if !CoreGMObligationsPermitArrival(core, pe, invocation,
                                      _CurrentProgramOrder) then
        _ScalarExecutionBlocked = TRUE;
        return;
    end;
    var slot = FindCoreSyncGenerationRecord(core, invocation, generation);
    if slot == PTO_MODEL_SYNC_GENERATIONS then
        slot = AllocateCoreSyncGenerationRecord(
            core, invocation, generation, site);
    end;
    if slot == PTO_MODEL_SYNC_GENERATIONS then
        _ScalarExecutionBlocked = TRUE;
        return;
    end;
    let index = slot as integer {0..PTO_MODEL_SYNC_GENERATIONS-1};
    if _CoreSyncRecords[[core]][[index]].site != site then
        _ScalarExecutionBlocked = TRUE;
        return;
    end;
    if _CoreSyncRecords[[core]][[index]].arrived[bit_index] == '0' then
        _CoreSyncRecords[[core]][[index]].arrived[bit_index] = '1';
        _CoreSyncRecords[[core]][[index]].arrival_orders[[pe]] =
            _CurrentProgramOrder;
    end;
    TryCompleteCoreSynchronization(core);
    if !ConsumeCoreSyncRelease(core, pe) then
        _ScalarExecutionBlocked = TRUE;
    end;
end;

func ProgressCoreSynchronization(core: PTOModelCoreIdentity)
begin
    TryCompleteCoreSynchronization(core);
end;

func RetireCoreSynchronizationInvocation(core: PTOModelCoreIdentity,
                                         invocation: integer)
begin
    for slot = 0 to PTO_MODEL_SYNC_GENERATIONS - 1 do
        if _CoreSyncRecords[[core]][[slot]].valid &&
           _CoreSyncRecords[[core]][[slot]].invocation == invocation then
            _CoreSyncRecords[[core]][[slot]].valid = FALSE;
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let bit_index = PTOPEMaskBitOfPEIdentity(pe as integer {0..3});
        _PEReleaseValid[[core]][bit_index] = '0';
        _PEReleaseGeneration[[core]][[pe]] = 0;
        _PEBarrierNextGeneration[[core]][[pe]] = 0;
        _PECollectiveEpoch[[core]][[pe]] = 0;
    end;
end;

func AbortCoreSynchronizationInvocation(core: PTOModelCoreIdentity,
                                        invocation: integer)
begin
    // Active collective records and release tokens belong to the closing
    // invocation.  Completed memory ordering remains in retained event
    // provenance and is deliberately not rewound here.
    RetireCoreSynchronizationInvocation(core, invocation);
end;

func BeginCoreSynchronizationInvocation(core: PTOModelCoreIdentity,
                                        invocation: integer)
begin
    // Launch is admitted only after the retired invocation is quiescent.
    // Retain consumed release records for memory-history checking; the new
    // invocation is isolated by its unique invocation identity.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        _PEBarrierNextGeneration[[core]][[pe]] = 0;
        _PEReleaseValid[[core]][PTOPEMaskBitOfPEIdentity(
            pe as integer {0..3})] = '0';
        _PEReleaseGeneration[[core]][[pe]] = 0;
        _PEProgramOrder[[core]][[pe]] = 0;
        _PECollectiveEpoch[[core]][[pe]] = 0;
    end;
end;

readonly func MemoryCollectiveSyncBefore(left_index: MemoryEventIndex,
                                         right_index: MemoryEventIndex)
                                         => boolean
begin
    let left = _MemoryEvents[[left_index]];
    let right = _MemoryEvents[[right_index]];
    if !left.active || !right.active ||
       left.origin != MemoryEventOrigin_Kernel ||
       right.origin != MemoryEventOrigin_Kernel ||
       left.core_identity != right.core_identity ||
       left.invocation != right.invocation ||
       left_index == right_index then return FALSE; end;
    return left.collective_history_sequence <
        right.collective_history_sequence;
end;
```
<!-- GENERATED-ASL-END: unit -->
