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
