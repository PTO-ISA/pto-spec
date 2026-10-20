// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","surface":"block","classification":["model","state","source-lifetime"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
// PTO-STATE: {"id":"PTO-STATE-BLOCK-SOURCE-LIFETIME","classification":["block","source-lifetime"],"scope":"system","owner":"PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","members":["_BundleSourceLifetimes","_NextBundleSourceLifetimeOrdinal","_BundleGMOVSourceSelections","_NextBundleGMOVSourceSelectionOrdinal"],"depends_on":["PTO-STATE-BLOCK-CONTROL","PTO-STATE-TILE-LOCAL"]}
// NDF-BEGIN: PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Each dynamic last-use occurrence captures one immutable source generation
// and declared participant set. A successful participant returns immediately;
// the payload is consumed exactly once only after every declared participant
// completes successfully. Fault, retry, squash, and nonparticipation MUST NOT
// falsely complete an occurrence. An unmatched occurrence may retain payload,
// and an outstanding occurrence pins its captured generation against
// replacement. The bounded reference table is a model bound, not a portable
// rejection condition or conflicting-group restriction.
// A domain squash cancels only the matching PE capture token; successful
// completions from other PEs remain attached to the immutable occurrence.
// NDF-END: PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001
// A bounded reference table represents arbitrarily many sequential dynamic
// occurrences. Exhaustion waits without introducing a portable fault.
type BundleSourceLifetimeOccurrence of record {
    valid: boolean,
    ordinal: integer,
    core: PTOModelCoreIdentity,
    invocation: integer,
    origin: MemoryEventOrigin,
    source_acr: AccessControlRing,
    producer_site: Word,
    start_instruction: bits(64),
    operation_form: bits(7),
    operation_selector: bits(10),
    shared: boolean,
    resource: TileIndex,
    source_pe: MemoryAgentId,
    local_epoch: integer,
    shared_epoch: integer,
    participant_mask: bits(4),
    captured_mask: bits(4),
    completed_mask: bits(4),
    domain_tokens: array [[PTO_MODEL_MEMORY_AGENTS]] of integer
};

type BundleSourceLifetimeSnapshot of array [[64]]
    of BundleSourceLifetimeOccurrence;

var _BundleSourceLifetimes : BundleSourceLifetimeSnapshot;
var _NextBundleSourceLifetimeOrdinal : integer;

type BundleGMOVSourcePESelection of array [[PTO_MODEL_MEMORY_AGENTS]]
    of MemoryAgentId;
type BundleGMOVSourceTileSelection of array [[PTO_MODEL_MEMORY_AGENTS]]
    of TileIndex;
type BundleGMOVSourceEpochSelection of array [[PTO_MODEL_MEMORY_AGENTS]]
    of integer;

type BundleGMOVSourceSelection of record {
    valid: boolean,
    ordinal: integer,
    core: PTOModelCoreIdentity,
    invocation: integer,
    origin: MemoryEventOrigin,
    source_acr: AccessControlRing,
    producer_site: Word,
    start_instruction: bits(64),
    operation_form: bits(7),
    operation_selector: bits(10),
    raw_selector: TileIndex,
    relative: boolean,
    participant_mask: bits(4),
    captured_mask: bits(4),
    completed_mask: bits(4),
    domain_tokens: array [[PTO_MODEL_MEMORY_AGENTS]] of integer,
    source_pes: BundleGMOVSourcePESelection,
    sources: BundleGMOVSourceTileSelection,
    source_epochs: BundleGMOVSourceEpochSelection
};

type BundleGMOVSourceSelectionSnapshot of array [[64]]
    of BundleGMOVSourceSelection;

var _BundleGMOVSourceSelections : BundleGMOVSourceSelectionSnapshot;
var _NextBundleGMOVSourceSelectionOrdinal : integer;

readonly func BundleSourceLifetimeIdentityMatches(
    occurrence: BundleSourceLifetimeOccurrence,
    shared: boolean, source_pe: MemoryAgentId, source: TileIndex,
    local_epoch: integer, shared_epoch: integer,
    participant_mask: bits(4)) => boolean
begin
    return occurrence.valid &&
           occurrence.core == _CurrentModelCore &&
           occurrence.invocation == _CurrentKernelInvocation &&
           occurrence.origin == _CurrentMemoryOrigin &&
           occurrence.source_acr == CurrentACR() &&
           occurrence.producer_site == ReadBPC() &&
           occurrence.start_instruction == _BundleStartEncodedInstruction &&
           occurrence.operation_form == _BundleOperation.form_identity &&
           occurrence.operation_selector == _BundleOperation.selector &&
           occurrence.shared == shared && occurrence.resource == source &&
           occurrence.source_pe == source_pe &&
           occurrence.local_epoch == local_epoch &&
           occurrence.shared_epoch == shared_epoch &&
           occurrence.participant_mask == participant_mask;
end;

readonly func FindBundleSourceLifetimeOrdinal(ordinal: integer)
    => integer {-1..63}
begin
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].ordinal == ordinal then
            return slot;
        end;
    end;
    return -1;
end;

func CaptureBundleSourceLifetime(
    shared: boolean, source_pe: MemoryAgentId, source: TileIndex,
    local_epoch: integer, shared_epoch: integer,
    participant_mask: bits(4), prior_ordinal: integer) => integer
begin
    let pe = _CurrentMemoryAgent as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if participant_mask == Zeros{4} || participant_mask[mask_bit] != '1' then
        return 0;
    end;
    if prior_ordinal > 0 then
        let prior = FindBundleSourceLifetimeOrdinal(prior_ordinal);
        if prior >= 0 &&
           BundleSourceLifetimeIdentityMatches(
               _BundleSourceLifetimes[[prior]], shared, source_pe, source,
               local_epoch, shared_epoch, participant_mask) &&
           _BundleSourceLifetimes[[prior]].captured_mask[mask_bit] == '1' &&
           _BundleSourceLifetimes[[prior]].domain_tokens[[pe]] ==
               _BundleExecutionDomainToken then
            return prior_ordinal;
        end;
        return 0;
    end;
    var candidate: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if BundleSourceLifetimeIdentityMatches(
               _BundleSourceLifetimes[[slot]], shared, source_pe, source,
               local_epoch, shared_epoch, participant_mask) &&
           _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] == '0' then
            if candidate < 0 then
                candidate = slot;
            elsif _BundleSourceLifetimes[[slot]].ordinal <
                  _BundleSourceLifetimes[[candidate]].ordinal then
                candidate = slot;
            end;
        end;
    end;
    if candidate >= 0 then
        _BundleSourceLifetimes[[candidate]].captured_mask[mask_bit] = '1';
        _BundleSourceLifetimes[[candidate]].domain_tokens[[pe]] =
            _BundleExecutionDomainToken;
        return _BundleSourceLifetimes[[candidate]].ordinal;
    end;
    for slot = 0 to 63 do
        if !_BundleSourceLifetimes[[slot]].valid then
            let ordinal = _NextBundleSourceLifetimeOrdinal;
            _NextBundleSourceLifetimeOrdinal = ordinal + 1;
            _BundleSourceLifetimes[[slot]].valid = TRUE;
            _BundleSourceLifetimes[[slot]].ordinal = ordinal;
            _BundleSourceLifetimes[[slot]].core = _CurrentModelCore;
            _BundleSourceLifetimes[[slot]].invocation =
                _CurrentKernelInvocation;
            _BundleSourceLifetimes[[slot]].origin = _CurrentMemoryOrigin;
            _BundleSourceLifetimes[[slot]].source_acr = CurrentACR();
            _BundleSourceLifetimes[[slot]].producer_site = ReadBPC();
            _BundleSourceLifetimes[[slot]].start_instruction =
                _BundleStartEncodedInstruction;
            _BundleSourceLifetimes[[slot]].operation_form =
                _BundleOperation.form_identity;
            _BundleSourceLifetimes[[slot]].operation_selector =
                _BundleOperation.selector;
            _BundleSourceLifetimes[[slot]].shared = shared;
            _BundleSourceLifetimes[[slot]].resource = source;
            _BundleSourceLifetimes[[slot]].source_pe = source_pe;
            _BundleSourceLifetimes[[slot]].local_epoch = local_epoch;
            _BundleSourceLifetimes[[slot]].shared_epoch = shared_epoch;
            _BundleSourceLifetimes[[slot]].participant_mask = participant_mask;
            _BundleSourceLifetimes[[slot]].captured_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].completed_mask = Zeros{4};
            for agent = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                _BundleSourceLifetimes[[slot]].domain_tokens[[agent]] = 0;
            end;
            _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] = '1';
            _BundleSourceLifetimes[[slot]].domain_tokens[[pe]] =
                _BundleExecutionDomainToken;
            return ordinal;
        end;
    end;
    return 0;
end;

// Atomic TSTORE delays source success until the captured PE request has
// drained.  Capture its last-use source only after the address/read/write
// preflight succeeds, so a failed admission leaves no immutable lifetime
// occurrence behind and a same-dynamic retry can revalidate.
func CaptureAtomicTStoreSourceLifetime(shared: boolean,
    source: TileIndex, local_epoch: integer)
    => (boolean, integer)
begin
    if shared then
        if BundleSharedBindingPhysicalCount() != 1 ||
           _BundleSharedBindings[[0]].source_reuse then
            return (TRUE, 0);
        end;
        let shared_id = _BundleSharedBindings[[0]].shared_tile_id;
        let shared_record = SharedTileRecord(shared_id);
        let ordinal = CaptureBundleSourceLifetime(TRUE, 0,
            UInt(shared_id) as TileIndex, 0,
            shared_record.payload_generation,
            _BundleSharedBindings[[0]].pe_mask,
            _BundleSharedBindings[[0]].source_lifetime_ordinal);
        if ordinal == 0 then return (FALSE, 0); end;
        _BundleSharedBindings[[0]].source_lifetime_captured = TRUE;
        _BundleSharedBindings[[0]].source_lifetime_ordinal = ordinal;
        return (TRUE, ordinal);
    end;
    if BundleTileBindingCount() != 1 ||
       !_BundleTileBindings[[0]].source0_valid ||
       _BundleTileBindings[[0]].source0_reuse then
        return (TRUE, 0);
    end;
    let source_pe = _CurrentMemoryAgent;
    let ordinal = CaptureBundleSourceLifetime(FALSE, source_pe, source,
        local_epoch, 0, _BundleTileBindings[[0]].pe_mask,
        _BundleTileBindings[[0]].source0_lifetime_ordinal);
    if ordinal == 0 then return (FALSE, 0); end;
    _BundleTileBindings[[0]].source0_lifetime_captured = TRUE;
    _BundleTileBindings[[0]].source0_lifetime_ordinal = ordinal;
    return (TRUE, ordinal);
end;

readonly func AtomicTStoreOwnsSourceLifetime(
    core: PTOModelCoreIdentity, invocation: integer, pe: MemoryAgentId,
    domain: integer, ordinal: integer) => boolean
begin
    if ordinal == 0 then return FALSE; end;
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let obligation = _GMObligations[[core]][[pe]][[slot]];
        if obligation.active && obligation.captured_atomic_tstore &&
           obligation.invocation == invocation &&
           obligation.execution_domain_token == domain &&
           obligation.atomic_tstore_source_lifetime_ordinal == ordinal &&
           obligation.irrevocable &&
           obligation.state != GMObligation_Completed &&
           obligation.state != GMObligation_Cancelled then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func CompleteBundleSourceLifetime(ordinal: integer)
begin
    let slot = FindBundleSourceLifetimeOrdinal(ordinal);
    if slot < 0 then return; end;
    let pe = _CurrentMemoryAgent as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if _BundleSourceLifetimes[[slot]].core != _CurrentModelCore ||
       _BundleSourceLifetimes[[slot]].invocation != _CurrentKernelInvocation ||
       _BundleSourceLifetimes[[slot]].origin != _CurrentMemoryOrigin ||
       _BundleSourceLifetimes[[slot]].source_acr != CurrentACR() ||
       _BundleSourceLifetimes[[slot]].producer_site != ReadBPC() ||
       _BundleSourceLifetimes[[slot]].start_instruction !=
           _BundleStartEncodedInstruction ||
       _BundleSourceLifetimes[[slot]].operation_form !=
           _BundleOperation.form_identity ||
       _BundleSourceLifetimes[[slot]].operation_selector !=
           _BundleOperation.selector ||
       _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] != '1' ||
       _BundleSourceLifetimes[[slot]].completed_mask[mask_bit] == '1' ||
       _BundleSourceLifetimes[[slot]].domain_tokens[[pe]] !=
           _BundleExecutionDomainToken then return; end;
    _BundleSourceLifetimes[[slot]].completed_mask[mask_bit] = '1';
    if _BundleSourceLifetimes[[slot]].completed_mask ==
       _BundleSourceLifetimes[[slot]].participant_mask then
        var another_incomplete = FALSE;
        for other = 0 to 63 do
            if other != slot && _BundleSourceLifetimes[[other]].valid &&
               _BundleSourceLifetimes[[other]].core ==
                   _BundleSourceLifetimes[[slot]].core &&
               _BundleSourceLifetimes[[other]].shared ==
                   _BundleSourceLifetimes[[slot]].shared &&
               _BundleSourceLifetimes[[other]].resource ==
                   _BundleSourceLifetimes[[slot]].resource &&
               _BundleSourceLifetimes[[other]].source_pe ==
                   _BundleSourceLifetimes[[slot]].source_pe &&
               _BundleSourceLifetimes[[other]].local_epoch ==
                   _BundleSourceLifetimes[[slot]].local_epoch &&
               _BundleSourceLifetimes[[other]].shared_epoch ==
                   _BundleSourceLifetimes[[slot]].shared_epoch &&
               _BundleSourceLifetimes[[other]].completed_mask !=
                   _BundleSourceLifetimes[[other]].participant_mask then
                another_incomplete = TRUE;
            end;
        end;
        if another_incomplete then return; end;
        if _BundleSourceLifetimes[[slot]].shared then
            let shared_id = (Zeros{6} +
                _BundleSourceLifetimes[[slot]].resource) as SharedTileID;
            let shared_record = SharedTileRecord(shared_id);
            if shared_record.payload_generation ==
               _BundleSourceLifetimes[[slot]].shared_epoch then
                ConsumeSharedTilePayload(shared_id);
            end;
        else
            ConsumeLocalTilePayloadGeneration(
                _BundleSourceLifetimes[[slot]].source_pe,
                _BundleSourceLifetimes[[slot]].resource,
                _BundleSourceLifetimes[[slot]].local_epoch);
        end;
        for matching = 0 to 63 do
            if _BundleSourceLifetimes[[matching]].valid &&
               _BundleSourceLifetimes[[matching]].core ==
                   _BundleSourceLifetimes[[slot]].core &&
               _BundleSourceLifetimes[[matching]].shared ==
                   _BundleSourceLifetimes[[slot]].shared &&
               _BundleSourceLifetimes[[matching]].resource ==
                   _BundleSourceLifetimes[[slot]].resource &&
               _BundleSourceLifetimes[[matching]].source_pe ==
                   _BundleSourceLifetimes[[slot]].source_pe &&
               _BundleSourceLifetimes[[matching]].local_epoch ==
                   _BundleSourceLifetimes[[slot]].local_epoch &&
               _BundleSourceLifetimes[[matching]].shared_epoch ==
                   _BundleSourceLifetimes[[slot]].shared_epoch &&
               _BundleSourceLifetimes[[matching]].completed_mask ==
                   _BundleSourceLifetimes[[matching]].participant_mask then
                _BundleSourceLifetimes[[matching]].valid = FALSE;
            end;
        end;
    end;
end;

readonly func SharedSourceLifetimePinned(shared_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_id);
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].core == _CurrentModelCore &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) &&
           _BundleSourceLifetimes[[slot]].shared_epoch ==
               shared.payload_generation then return TRUE; end;
    end;
    return FALSE;
end;

readonly func LocalSourceLifetimePinned(pe: MemoryAgentId,
                                         source: TileIndex) => boolean
begin
    let epoch = LocalTilePayloadGeneration(pe, source);
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           !_BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].core == _CurrentModelCore &&
           _BundleSourceLifetimes[[slot]].source_pe == pe &&
           _BundleSourceLifetimes[[slot]].resource == source &&
           _BundleSourceLifetimes[[slot]].local_epoch == epoch then
            return TRUE;
        end;
    end;
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].core == _CurrentModelCore then
            for destination = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let destination_pe = destination as MemoryAgentId;
                let mask_bit = PTOPEMaskBitOfPEIdentity(destination_pe);
                if _BundleGMOVSourceSelections[[slot]].participant_mask[
                       mask_bit] == '1' &&
                   _BundleGMOVSourceSelections[[slot]].completed_mask[
                       mask_bit] == '0' &&
                   _BundleGMOVSourceSelections[[slot]].
                       source_pes[[destination]] == pe &&
                   _BundleGMOVSourceSelections[[slot]].
                       sources[[destination]] == source &&
                   _BundleGMOVSourceSelections[[slot]].
                       source_epochs[[destination]] == epoch then
                    return TRUE;
                end;
            end;
        end;
    end;
    return FALSE;
end;

func ResetBundleGMOVSourceSelections()
begin
    for slot = 0 to 63 do
        _BundleGMOVSourceSelections[[slot]].valid = FALSE;
    end;
end;

func RetireBundleGMOVSourceSelections(core: PTOModelCoreIdentity,
                                      invocation: integer)
begin
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].core == core &&
           _BundleGMOVSourceSelections[[slot]].invocation == invocation then
            _BundleGMOVSourceSelections[[slot]].valid = FALSE;
        end;
    end;
end;

func SquashBundleGMOVSourceSelections(core: PTOModelCoreIdentity,
                                      invocation: integer, domain: integer)
begin
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].core == core &&
           _BundleGMOVSourceSelections[[slot]].invocation == invocation then
            var captured_left = Zeros{4};
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
                if _BundleGMOVSourceSelections[[slot]].captured_mask[mask_bit] ==
                       '1' &&
                   _BundleGMOVSourceSelections[[slot]].domain_tokens[[pe]] ==
                       domain then
                    _BundleGMOVSourceSelections[[slot]].captured_mask[
                        mask_bit] = '0';
                    _BundleGMOVSourceSelections[[slot]].completed_mask[
                        mask_bit] = '0';
                    _BundleGMOVSourceSelections[[slot]].domain_tokens[[pe]] = 0;
                else
                    captured_left[mask_bit] =
                        _BundleGMOVSourceSelections[[slot]].captured_mask[
                            mask_bit];
                end;
            end;
            if captured_left == Zeros{4} then
                _BundleGMOVSourceSelections[[slot]].valid = FALSE;
            end;
        end;
    end;
end;

func ResetSourceLifetimeState()
begin
    for slot = 0 to 63 do
        _BundleSourceLifetimes[[slot]].valid = FALSE;
    end;
    _NextBundleSourceLifetimeOrdinal = 1;
    _NextBundleGMOVSourceSelectionOrdinal = 1;
    ResetBundleGMOVSourceSelections();
end;

func RetireSourceLifetimes(core: PTOModelCoreIdentity, invocation: integer)
begin
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].core == core &&
           _BundleSourceLifetimes[[slot]].invocation == invocation then
            _BundleSourceLifetimes[[slot]].valid = FALSE;
        end;
    end;
    RetireBundleGMOVSourceSelections(core, invocation);
end;

func SquashSourceLifetimes(core: PTOModelCoreIdentity, invocation: integer,
                           domain: integer)
begin
    // Keep only an uncompleted token owned by this exact irrevocable request.
    // Successful PE bits remain attached to their immutable cohort; unrelated
    // captures in the same invocation still follow ordinary domain squash.
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].core == core &&
           _BundleSourceLifetimes[[slot]].invocation == invocation then
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
                if _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] == '1' &&
                   _BundleSourceLifetimes[[slot]].domain_tokens[[pe]] == domain &&
                   _BundleSourceLifetimes[[slot]].completed_mask[mask_bit] == '0' &&
                   !AtomicTStoreOwnsSourceLifetime(core, invocation,
                       pe as MemoryAgentId, domain,
                       _BundleSourceLifetimes[[slot]].ordinal) then
                    _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] = '0';
                    _BundleSourceLifetimes[[slot]].completed_mask[mask_bit] = '0';
                    _BundleSourceLifetimes[[slot]].domain_tokens[[pe]] = 0;
                end;
            end;
            if _BundleSourceLifetimes[[slot]].captured_mask == Zeros{4} then
                _BundleSourceLifetimes[[slot]].valid = FALSE;
            end;
        end;
    end;
    SquashBundleGMOVSourceSelections(core, invocation, domain);
end;
