<!-- GENERATED FROM: asl/block/model/state/atomic-tstore-source-lifetime.asl -->
# Atomic Tstore Source Lifetime

**Normative ASL source:** `asl/block/model/state/atomic-tstore-source-lifetime.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-ATOMIC-TSTORE-SOURCE-LIFETIME}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/atomic-tstore-source-lifetime.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-ATOMIC-TSTORE-SOURCE-LIFETIME","surface":"block","classification":["model","state","atomic-tstore-source-lifetime"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
// Atomic Local last-use uses the source-lifetime cohort owned by
// source-lifetime.asl, with one generation tuple per PE. Shared Atomic and
// Local GMOV continue through the generic exact-tuple path.
readonly func AtomicLocalSourceLifetimeIdentityMatches(
    occurrence: BundleSourceLifetimeOccurrence, source_selector: TileIndex,
    source_selector_relative: boolean,
    participant_mask: bits(4)) => boolean
begin
    return occurrence.valid && occurrence.atomic_local_cohort &&
           occurrence.core == _CurrentModelCore &&
           occurrence.invocation == _CurrentKernelInvocation &&
           occurrence.origin == _CurrentMemoryOrigin &&
           occurrence.source_acr == CurrentACR() &&
           occurrence.producer_site == ReadBPC() &&
           occurrence.start_instruction == _BundleStartEncodedInstruction &&
           occurrence.operation_form == _BundleOperation.form_identity &&
           occurrence.operation_selector == _BundleOperation.selector &&
           !occurrence.shared &&
           occurrence.resource == source_selector &&
           occurrence.source_selector_relative == source_selector_relative &&
           occurrence.participant_mask == participant_mask;
end;

// Atomic Local sources share one collective occurrence, but each PE owns a
// distinct physical payload bank and generation. Generic Local consumers
// keep their exact scalar tuple matching in CaptureBundleSourceLifetime.
func CaptureAtomicLocalTStoreSourceLifetime(source: TileIndex,
    local_epoch: integer, source_selector: TileIndex,
    source_selector_relative: boolean, participant_mask: bits(4),
    prior_ordinal: integer) => integer
begin
    let pe = _CurrentMemoryAgent as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if participant_mask == Zeros{4} || participant_mask[mask_bit] != '1' then
        return 0;
    end;
    if prior_ordinal > 0 then
        let prior = FindBundleSourceLifetimeOrdinal(prior_ordinal);
        if prior < 0 ||
           !AtomicLocalSourceLifetimeIdentityMatches(
               _BundleSourceLifetimes[[prior]], source_selector,
               source_selector_relative, participant_mask) then
            return 0;
        end;
        if _BundleSourceLifetimes[[prior]].captured_mask[mask_bit] == '1' &&
           _BundleSourceLifetimes[[prior]].retry_only_mask[mask_bit] == '0' &&
           _BundleSourceLifetimes[[prior]].domain_tokens[[pe]] ==
               _BundleExecutionDomainToken &&
           _BundleSourceLifetimes[[prior]].local_source_pes[[pe]] ==
               _CurrentMemoryAgent &&
           _BundleSourceLifetimes[[prior]].local_sources[[pe]] == source &&
           _BundleSourceLifetimes[[prior]].local_epochs[[pe]] == local_epoch then
            return prior_ordinal;
        end;
        // A squash marker is a terminal abandoned participant position, not
        // authority to revive a Cancelled GM request. No production retry
        // path reattaches an Atomic TSTORE source capture after domain squash.
        return 0;
    end;

    var candidate: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if AtomicLocalSourceLifetimeIdentityMatches(
               _BundleSourceLifetimes[[slot]], source_selector,
               source_selector_relative, participant_mask) &&
           _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] == '0' &&
           _BundleSourceLifetimes[[slot]].retry_only_mask[mask_bit] == '0' &&
           _BundleSourceLifetimes[[slot]].completed_mask[mask_bit] == '0' then
            if candidate < 0 then
                candidate = slot;
            elsif _BundleSourceLifetimes[[slot]].ordinal <
                  _BundleSourceLifetimes[[candidate]].ordinal then
                candidate = slot;
            end;
        end;
    end;
    if candidate >= 0 then
        _BundleSourceLifetimes[[candidate]].local_source_pes[[pe]] =
            _CurrentMemoryAgent;
        _BundleSourceLifetimes[[candidate]].local_sources[[pe]] = source;
        _BundleSourceLifetimes[[candidate]].local_epochs[[pe]] = local_epoch;
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
            _BundleSourceLifetimes[[slot]].shared = FALSE;
            _BundleSourceLifetimes[[slot]].resource = source_selector;
            _BundleSourceLifetimes[[slot]].source_pe =
                _CurrentMemoryAgent;
            _BundleSourceLifetimes[[slot]].local_epoch = local_epoch;
            _BundleSourceLifetimes[[slot]].shared_epoch = 0;
            _BundleSourceLifetimes[[slot]].participant_mask =
                participant_mask;
            _BundleSourceLifetimes[[slot]].captured_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].completed_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].atomic_local_cohort = TRUE;
            _BundleSourceLifetimes[[slot]].source_selector_relative =
                source_selector_relative;
            _BundleSourceLifetimes[[slot]].consumed_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].retry_only_mask = Zeros{4};
            for agent = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                _BundleSourceLifetimes[[slot]].local_source_pes[[agent]] =
                    agent as MemoryAgentId;
                _BundleSourceLifetimes[[slot]].local_sources[[agent]] = 0;
                _BundleSourceLifetimes[[slot]].local_epochs[[agent]] = 0;
                _BundleSourceLifetimes[[slot]].domain_tokens[[agent]] = 0;
            end;
            _BundleSourceLifetimes[[slot]].local_source_pes[[pe]] =
                _CurrentMemoryAgent;
            _BundleSourceLifetimes[[slot]].local_sources[[pe]] = source;
            _BundleSourceLifetimes[[slot]].local_epochs[[pe]] = local_epoch;
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
    let ordinal = CaptureAtomicLocalTStoreSourceLifetime(source,
        local_epoch, _BundleTileBindings[[0]].source0_selector,
        _BundleTileBindings[[0]].source0_selector_relative,
        _BundleTileBindings[[0]].pe_mask,
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

readonly func BundleSourceLifetimeCapturesLocalTuple(
    occurrence: BundleSourceLifetimeOccurrence,
    source_pe: MemoryAgentId, source: TileIndex, local_epoch: integer)
    => boolean
begin
    if !occurrence.valid || occurrence.shared then return FALSE; end;
    let pe = source_pe as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(source_pe);
    if occurrence.atomic_local_cohort then
        return occurrence.local_source_pes[[pe]] == source_pe &&
               occurrence.local_sources[[pe]] == source &&
               occurrence.local_epochs[[pe]] == local_epoch &&
               occurrence.consumed_mask[mask_bit] == '0' &&
               occurrence.captured_mask[mask_bit] == '1';
    end;
    return occurrence.source_pe == source_pe &&
           occurrence.resource == source &&
           occurrence.local_epoch == local_epoch &&
           (occurrence.captured_mask != Zeros{4} ||
            occurrence.completed_mask != Zeros{4});
end;

readonly func OtherIncompleteSourceLifetimePinsLocalTuple(
    core: PTOModelCoreIdentity, ordinal: integer,
    source_pe: MemoryAgentId, source: TileIndex,
    local_epoch: integer) => boolean
begin
    for other = 0 to 63 do
        if _BundleSourceLifetimes[[other]].valid &&
           _BundleSourceLifetimes[[other]].core == core &&
           _BundleSourceLifetimes[[other]].ordinal != ordinal &&
           _BundleSourceLifetimes[[other]].completed_mask !=
               _BundleSourceLifetimes[[other]].participant_mask &&
           BundleSourceLifetimeCapturesLocalTuple(
               _BundleSourceLifetimes[[other]], source_pe, source,
               local_epoch) then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func MarkBundleSourceLifetimeLocalTupleConsumed(
    core: PTOModelCoreIdentity, source_pe: MemoryAgentId,
    source: TileIndex, local_epoch: integer)
begin
    let mask_bit = PTOPEMaskBitOfPEIdentity(source_pe);
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].core == core &&
           BundleSourceLifetimeCapturesLocalTuple(
               _BundleSourceLifetimes[[slot]], source_pe, source,
               local_epoch) then
            if _BundleSourceLifetimes[[slot]].atomic_local_cohort then
                _BundleSourceLifetimes[[slot]].consumed_mask[mask_bit] = '1';
            elsif _BundleSourceLifetimes[[slot]].completed_mask ==
                  _BundleSourceLifetimes[[slot]].participant_mask then
                _BundleSourceLifetimes[[slot]].valid = FALSE;
            end;
        end;
    end;
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].atomic_local_cohort &&
           _BundleSourceLifetimes[[slot]].completed_mask ==
               _BundleSourceLifetimes[[slot]].participant_mask then
            var every_tuple_consumed = TRUE;
            for agent = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let agent_bit = PTOPEMaskBitOfPEIdentity(agent);
                if _BundleSourceLifetimes[[slot]].participant_mask[
                       agent_bit] == '1' &&
                   _BundleSourceLifetimes[[slot]].consumed_mask[
                       agent_bit] == '0' then
                    every_tuple_consumed = FALSE;
                end;
            end;
            if every_tuple_consumed then
                _BundleSourceLifetimes[[slot]].valid = FALSE;
            end;
        end;
    end;
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
        if _BundleSourceLifetimes[[slot]].atomic_local_cohort then
            for participant = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let participant_bit = PTOPEMaskBitOfPEIdentity(participant);
                let source_pe = participant as MemoryAgentId;
                if _BundleSourceLifetimes[[slot]].participant_mask[
                       participant_bit] == '1' &&
                   _BundleSourceLifetimes[[slot]].captured_mask[
                       participant_bit] == '1' &&
                   _BundleSourceLifetimes[[slot]].consumed_mask[
                       participant_bit] == '0' then
                    let source = _BundleSourceLifetimes[[slot]]
                        .local_sources[[participant]];
                    let epoch = _BundleSourceLifetimes[[slot]]
                        .local_epochs[[participant]];
                    if !OtherIncompleteSourceLifetimePinsLocalTuple(
                           _BundleSourceLifetimes[[slot]].core,
                           _BundleSourceLifetimes[[slot]].ordinal,
                           source_pe, source, epoch) then
                        ConsumeLocalTilePayloadGeneration(source_pe,
                            source, epoch);
                        MarkBundleSourceLifetimeLocalTupleConsumed(
                            _BundleSourceLifetimes[[slot]].core, source_pe,
                            source, epoch);
                    end;
                end;
            end;
        elsif _BundleSourceLifetimes[[slot]].shared then
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
        let shared_id = (Zeros{6} +
            _BundleSourceLifetimes[[slot]].resource) as SharedTileID;
        let shared_record = SharedTileRecord(shared_id);
        if shared_record.payload_generation ==
           _BundleSourceLifetimes[[slot]].shared_epoch then
            ConsumeSharedTilePayload(shared_id);
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
        else
            let source_pe = _BundleSourceLifetimes[[slot]].source_pe;
            let source = _BundleSourceLifetimes[[slot]].resource;
            let epoch = _BundleSourceLifetimes[[slot]].local_epoch;
            if !OtherIncompleteSourceLifetimePinsLocalTuple(
                   _BundleSourceLifetimes[[slot]].core,
                   _BundleSourceLifetimes[[slot]].ordinal,
                   source_pe, source, epoch) then
                ConsumeLocalTilePayloadGeneration(source_pe, source, epoch);
                MarkBundleSourceLifetimeLocalTupleConsumed(
                    _BundleSourceLifetimes[[slot]].core, source_pe, source,
                    epoch);
            end;
        end;
    end;
end;

readonly func LocalSourceLifetimePinned(pe: MemoryAgentId,
                                         source: TileIndex) => boolean
begin
    let epoch = LocalTilePayloadGeneration(pe, source);
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].core == _CurrentModelCore &&
           BundleSourceLifetimeCapturesLocalTuple(
               _BundleSourceLifetimes[[slot]], pe, source, epoch) then
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
                    _BundleSourceLifetimes[[slot]].domain_tokens[[pe]] = 0;
                    if _BundleSourceLifetimes[[slot]].atomic_local_cohort then
                        // Keep an unpinned tombstone for this abandoned
                        // participant position. Fresh same-PC work skips it;
                        // this marker cannot revive a cancelled GM request.
                        _BundleSourceLifetimes[[slot]].retry_only_mask[
                            mask_bit] = '1';
                    else
                        _BundleSourceLifetimes[[slot]].completed_mask[
                            mask_bit] = '0';
                    end;
                end;
            end;
            if _BundleSourceLifetimes[[slot]].captured_mask == Zeros{4} &&
               _BundleSourceLifetimes[[slot]].retry_only_mask == Zeros{4} then
                _BundleSourceLifetimes[[slot]].valid = FALSE;
            end;
        end;
    end;
    SquashBundleGMOVSourceSelections(core, invocation, domain);
end;
```
<!-- GENERATED-ASL-END: unit -->
