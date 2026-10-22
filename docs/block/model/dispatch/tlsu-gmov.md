<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gmov.asl -->
# TLSU Gmov

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gmov.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `GMOV`, the peer move between Local Tiles of the four PEs in one core. A bundle is the group of header commands that starts at `BSTART` and executes when it commits at `BSTOP` or the next `BSTART`.

`BundleGMOVSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `13`. `ExecuteBundleGMOVOperation` then validates the complete bundle, resolves one Local destination, and calls the Tile-level `GMOV` effect.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-concepts role=concepts-state -->
## Concepts and visible state

The handler reads the collected bundle state and copies from the actual selected source PE into the executing destination PE. Source retirement is a separate successful-completion effect, charged to the source bank rather than the destination bank.

- Exactly one `B.IOT` binding, with a destination, `source0`, no `source1`, and the `last` flag. No `B.IOS` Shared binding is allowed.
- Every `B.DIM` dimension must have value `1`. Omitted dimensions default to `1`, so the usual form encodes none.
- The optional `B.IOR` `source0` names a GPR that holds the peer identifier. Each PE reads that selector from its own register file with `ReadPEAbsoluteGPROperand`. With no `B.IOR` the peer value is zero.
- The operation data type and the `B.DATR` layout must match the source Tile, and the data type must pass `TileCarrierOrPackedBaselineDataTypeSupported`.
- The destination size must equal the source Tile capacity in bytes.

The destination copies the source valid rows, valid columns, physical columns, and data type. `GMOV` copies payload and definedness from the source.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-rules role=rules-interactions -->
## Rules and interactions

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Every schema failure raises `Fault_TileLegality`, and all these checks happen before the destination is resolved.

The handler checks, in order: no Shared bindings and complete, legal `B.IOR` values; a uniform PE mask across bindings; exactly one Tile binding; data attributes; the binding shape and source readiness; the byte size, type, and layout matches; dimensions equal `1`; and each PE's peer identifier below `4`.

Independent PE execution resolves the raw relative source in each actual peer bank. The captured selection keeps physical indices and generation identities stable while destinations publish new relative generations. Aggregate verification callers retain their existing Core-wide view; that representation does not replace private PE ownership.

Design point: the peer range check loops over all four PEs even when the PE mask would suppress a PE's write. The ASL comment states that every PE takes part in peer selection and readiness preflight. Repeated peer identifiers are legal; only the range `0..3` is constrained.

After preflight, the destination is allocated using the captured source shape and type, and the move copies payload and definedness before publication. Repeated selections of one peer remain separate consumers of one source generation: last-use accounting keeps that payload until its selected consumers finish, and `.reuse` retains it. Retry, recovery and stale completion use captured request identities rather than a reused table slot.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decide that the bundle is a GMOV bundle at commit. `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` tests the specialized selectors in a fixed order and calls this handler only when the TIMG2COL, weight-load, matrix, and CUBE layout-conversion selectors did not match first. That caller also commits or aborts Local generations after this handler returns.

The unit does not itself test for a zero PE mask. A `B.IOT` with PE mode giving mask `0000` never creates a binding, and the caller returns early for a bundle that saw only zero participation.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose source Tile `t3` is allocated on all four PEs (mask `1111`), holds a defined FP16 RowMajor payload of 16 valid rows by 64 columns, and has a capacity of 2048 bytes. The bundle has one `B.IOT` with destination size code for 2048 bytes and source `t3`, no `B.DIM`, and one `B.IOR` whose `source0` is `a0`. If PE 0 through PE 3 hold `a0` values `1`, `2`, `3`, and `0`, all are below `4`, so the check passes. The destination receives 16 valid rows, 64 columns, and FP16.

If PE 2 instead held `a0` equal to `4`, the bundle raises `Fault_TileLegality` before any destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) orders the specialized selectors and commits Local generations.
- [Shared movement](../../../tile/model/memory/shared-movement.md) defines the Tile-level `GMOV` effect.
- [Rollback](../faults/rollback.md) defines how a bundle-allocated destination is released.
- [BSTART.GMOV](../../execution/BSTART.GMOV.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gmov.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","tlsu-gmov"],"depends_on":["PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION","PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS","PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-BLOCK-MODEL-STATE-ATOMIC-TSTORE-SOURCE-LIFETIME","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-VALUES"],"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","surface":"block"}

readonly func BundleGMOVSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 13;
end;

readonly func BundleGMOVPESourceTile(source: TileIndex,
                                     pe: MemoryAgentId) => TileInfo
begin
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _Tiles[[source]];
    end;
    return _PEExecutionContexts[[_CurrentModelCore]][[pe]].tiles[[source]];
end;

readonly func BundleGMOVPESourceAvailable(selector: TileIndex,
                                          relative: boolean,
                                          pe: MemoryAgentId) => boolean
begin
    if !relative then
        return BundleGMOVPESourceTile(selector, pe).allocated;
    end;
    let hand = RelativeTileHandIndex(selector);
    let distance = RelativeTileDistance(selector);
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        if _TileRelativeValid[[hand]][distance] == '0' then return FALSE; end;
        return _Tiles[[_TileRelativeOrder[[hand]][[distance]]]].allocated;
    end;
    let context = _PEExecutionContexts[[_CurrentModelCore]][[pe]];
    if context.tile_relative_valid[[hand]][distance] == '0' then
        return FALSE;
    end;
    return context.tiles[[context.tile_relative_order[[hand]][[distance]]]]
        .allocated;
end;

readonly func BundleGMOVPESourceIndex(selector: TileIndex,
                                      relative: boolean,
                                      pe: MemoryAgentId) => TileIndex
begin
    assert BundleGMOVPESourceAvailable(selector, relative, pe);
    if !relative then return selector; end;
    let hand = RelativeTileHandIndex(selector);
    let distance = RelativeTileDistance(selector);
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _TileRelativeOrder[[hand]][[distance]];
    end;
    return _PEExecutionContexts[[_CurrentModelCore]][[pe]]
        .tile_relative_order[[hand]][[distance]];
end;

readonly func BundleGMOVPESourcePayloadLive(source: TileIndex,
                                            pe: MemoryAgentId) => boolean
begin
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _Tiles[[source]].allocated &&
               _TilePayloadLiveMasks[[source]][mask_bit] == '1';
    end;
    let context = _PEExecutionContexts[[_CurrentModelCore]][[pe]];
    return context.tiles[[source]].allocated &&
           context.tile_payload_live_masks[[source]][mask_bit] == '1';
end;

readonly func BundleGMOVSourceSelectionIdentityMatches(
    selection: BundleGMOVSourceSelection, selector: TileIndex,
    relative: boolean, participant_mask: bits(4)) => boolean
begin
    return selection.valid && selection.core == _CurrentModelCore &&
           selection.invocation == _CurrentKernelInvocation &&
           selection.origin == _CurrentMemoryOrigin &&
           selection.source_acr == CurrentACR() &&
           selection.producer_site == ReadBPC() &&
           selection.start_instruction == _BundleStartEncodedInstruction &&
           selection.operation_form == _BundleOperation.form_identity &&
           selection.operation_selector == _BundleOperation.selector &&
           selection.raw_selector == selector &&
           selection.relative == relative &&
           selection.participant_mask == participant_mask;
end;

readonly func FindBundleGMOVSourceSelectionOrdinal(ordinal: integer)
    => integer {-1..63}
begin
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].ordinal == ordinal then
            return slot;
        end;
    end;
    return -1;
end;

func CaptureBundleGMOVSourceSelection(selector: TileIndex,
                                      relative: boolean,
                                      participant_mask: bits(4),
                                      prior_ordinal: integer) => integer
begin
    let current_pe = _CurrentMemoryAgent as integer {0..3};
    let current_mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if prior_ordinal > 0 then
        for slot = 0 to 63 do
            if _BundleGMOVSourceSelections[[slot]].valid &&
               _BundleGMOVSourceSelections[[slot]].ordinal == prior_ordinal &&
               BundleGMOVSourceSelectionIdentityMatches(
                   _BundleGMOVSourceSelections[[slot]], selector, relative,
                   participant_mask) &&
               _BundleGMOVSourceSelections[[slot]].captured_mask[
                   current_mask_bit] == '1' &&
               _BundleGMOVSourceSelections[[slot]].domain_tokens[[current_pe]] ==
                   _BundleExecutionDomainToken then return prior_ordinal; end;
        end;
        return 0;
    end;
    var candidate: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if BundleGMOVSourceSelectionIdentityMatches(
               _BundleGMOVSourceSelections[[slot]], selector, relative,
               participant_mask) then
            if _BundleGMOVSourceSelections[[slot]].captured_mask[
                   current_mask_bit] == '1' &&
               _BundleGMOVSourceSelections[[slot]].domain_tokens[[current_pe]] ==
                   _BundleExecutionDomainToken then
                return _BundleGMOVSourceSelections[[slot]].ordinal;
            elsif _BundleGMOVSourceSelections[[slot]].captured_mask[
                      current_mask_bit] == '0' then
                if candidate < 0 ||
                   _BundleGMOVSourceSelections[[slot]].ordinal <
                       _BundleGMOVSourceSelections[[candidate]].ordinal then
                    candidate = slot;
                end;
            end;
        end;
    end;
    if candidate >= 0 then
        _BundleGMOVSourceSelections[[candidate]].captured_mask[
            current_mask_bit] = '1';
        _BundleGMOVSourceSelections[[candidate]].domain_tokens[[current_pe]] =
            _BundleExecutionDomainToken;
        return _BundleGMOVSourceSelections[[candidate]].ordinal;
    end;
    for slot = 0 to 63 do
        if !_BundleGMOVSourceSelections[[slot]].valid then
            _BundleGMOVSourceSelections[[slot]].valid = TRUE;
            _BundleGMOVSourceSelections[[slot]].ordinal =
                _NextBundleGMOVSourceSelectionOrdinal;
            _NextBundleGMOVSourceSelectionOrdinal =
                _NextBundleGMOVSourceSelectionOrdinal + 1;
            _BundleGMOVSourceSelections[[slot]].core = _CurrentModelCore;
            _BundleGMOVSourceSelections[[slot]].invocation =
                _CurrentKernelInvocation;
            _BundleGMOVSourceSelections[[slot]].origin = _CurrentMemoryOrigin;
            _BundleGMOVSourceSelections[[slot]].source_acr = CurrentACR();
            _BundleGMOVSourceSelections[[slot]].producer_site = ReadBPC();
            _BundleGMOVSourceSelections[[slot]].start_instruction =
                _BundleStartEncodedInstruction;
            _BundleGMOVSourceSelections[[slot]].operation_form =
                _BundleOperation.form_identity;
            _BundleGMOVSourceSelections[[slot]].operation_selector =
                _BundleOperation.selector;
            _BundleGMOVSourceSelections[[slot]].raw_selector = selector;
            _BundleGMOVSourceSelections[[slot]].relative = relative;
            _BundleGMOVSourceSelections[[slot]].participant_mask =
                participant_mask;
            _BundleGMOVSourceSelections[[slot]].completed_mask = Zeros{4};
            _BundleGMOVSourceSelections[[slot]].captured_mask = Zeros{4};
            for agent = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                _BundleGMOVSourceSelections[[slot]].domain_tokens[[agent]] = 0;
            end;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let destination_pe = pe as MemoryAgentId;
                let peer_word = ReadPEAbsoluteGPROperand(destination_pe,
                    _BundleScalarBindings[[0]].source0);
                if UInt(peer_word) >= PTO_MODEL_MEMORY_AGENTS then
                    _BundleGMOVSourceSelections[[slot]].valid = FALSE;
                    return 0;
                end;
                let source_pe = UInt(peer_word) as MemoryAgentId;
                if (source_pe != _CurrentMemoryAgent &&
                    _PEContextBankValid[[_CurrentModelCore]][source_pe] !=
                        '1') ||
                   !BundleGMOVPESourceAvailable(
                       selector, relative, source_pe) then
                    _BundleGMOVSourceSelections[[slot]].valid = FALSE;
                    return 0;
                end;
                let source = BundleGMOVPESourceIndex(
                    selector, relative, source_pe);
                _BundleGMOVSourceSelections[[slot]].source_pes[[pe]] =
                    source_pe;
                _BundleGMOVSourceSelections[[slot]].sources[[pe]] = source;
                _BundleGMOVSourceSelections[[slot]].source_epochs[[pe]] =
                    LocalTilePayloadGeneration(source_pe, source);
            end;
            _BundleGMOVSourceSelections[[slot]].captured_mask[
                current_mask_bit] = '1';
            _BundleGMOVSourceSelections[[slot]].domain_tokens[[current_pe]] =
                _BundleExecutionDomainToken;
            return _BundleGMOVSourceSelections[[slot]].ordinal;
        end;
    end;
    return 0;
end;

func CompleteBundleGMOVSourceSelection(ordinal: integer)
begin
    var selected: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].ordinal == ordinal then
            selected = slot;
        end;
    end;
    if selected < 0 then return; end;
    let current_pe = _CurrentMemoryAgent as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if !BundleGMOVSourceSelectionIdentityMatches(
           _BundleGMOVSourceSelections[[selected]],
           _BundleGMOVSourceSelections[[selected]].raw_selector,
           _BundleGMOVSourceSelections[[selected]].relative,
           _BundleGMOVSourceSelections[[selected]].participant_mask) ||
       _BundleGMOVSourceSelections[[selected]].captured_mask[mask_bit] != '1' ||
       _BundleGMOVSourceSelections[[selected]].domain_tokens[[current_pe]] !=
           _BundleExecutionDomainToken then return; end;
    if _BundleGMOVSourceSelections[[selected]].participant_mask[mask_bit] ==
       '1' then
        _BundleGMOVSourceSelections[[selected]].completed_mask[mask_bit] = '1';
    end;
    if _BundleGMOVSourceSelections[[selected]].completed_mask ==
       _BundleGMOVSourceSelections[[selected]].participant_mask then
        _BundleGMOVSourceSelections[[selected]].valid = FALSE;
    end;
end;

readonly func BundleGMOVCore4SourceReady(selector: TileIndex,
                                         relative: boolean,
                                         selection_ordinal: integer) => boolean
begin
    // Standalone aggregate callers retain the established Core4 batch view.
    // Encoded PE streams instead resolve each destination's private peer_tid
    // against that peer's actual Local bank before any destination effect.
    if !_CurrentPEContextValid then
        return TileElementwiseSourceContentsDefined(selector) &&
               _TileAllocationMasks[[selector]] == '1111';
    end;
    if !_BundleScalarBindings[[0]].valid || selection_ordinal <= 0 then
        return FALSE;
    end;
    let selection_slot = FindBundleGMOVSourceSelectionOrdinal(
        selection_ordinal);
    if selection_slot < 0 then return FALSE; end;
    let selection = _BundleGMOVSourceSelections[[selection_slot]];
    if !BundleGMOVSourceSelectionIdentityMatches(selection, selector,
           relative, _BundleTileBindings[[0]].pe_mask) then return FALSE; end;
    var reference_valid = FALSE;
    var reference: TileInfo;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let destination_pe = pe as MemoryAgentId;
        let source_pe = selection.source_pes[[pe]];
        if source_pe != _CurrentMemoryAgent &&
           _PEContextBankValid[[_CurrentModelCore]][source_pe] != '1' then
            return FALSE;
        end;
        let source = selection.sources[[pe]];
        let source_tile = BundleGMOVPESourceTile(source, source_pe);
        if !BundleGMOVPESourceTileReady(source_tile) ||
           LocalTilePayloadGeneration(source_pe, source) !=
               selection.source_epochs[[pe]] then
            return FALSE;
        end;
        let destination_mask_bit = PTOPEMaskBitOfPEIdentity(destination_pe);
        if selection.participant_mask[destination_mask_bit] == '1' &&
           selection.completed_mask[destination_mask_bit] == '0' &&
           !BundleGMOVPESourcePayloadLive(source, source_pe) then
            return FALSE;
        end;
        if !reference_valid then
            reference = source_tile;
            reference_valid = TRUE;
        elsif !BundleGMOVSourceDescriptorsMatch(reference, source_tile) then
            return FALSE;
        end;
    end;
    return reference_valid;
end;

readonly func BundleGMOVSourceParticipantMask(
    selection_ordinal: integer, source_pe: MemoryAgentId,
    source: TileIndex, source_epoch: integer) => bits(4)
begin
    var participants = Zeros{4};
    assert selection_ordinal > 0;
    let selection_slot = FindBundleGMOVSourceSelectionOrdinal(
        selection_ordinal);
    assert selection_slot >= 0;
    let selection = _BundleGMOVSourceSelections[[selection_slot]];
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let destination_pe = pe as MemoryAgentId;
        let mask_bit = PTOPEMaskBitOfPEIdentity(destination_pe);
        if selection.participant_mask[mask_bit] == '1' &&
           selection.source_pes[[pe]] == source_pe &&
           selection.sources[[pe]] == source &&
           selection.source_epochs[[pe]] == source_epoch then
            participants[mask_bit] = '1';
        end;
    end;
    return participants;
end;

func ExecuteBundleGMOVOperation() => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var result_writer_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       BundleTileBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return (FALSE, result_writer_effects); end;
    let binding = _BundleTileBindings[[0]];
    if _CurrentPEContextValid then
        // Capture every destination's peer-selected physical generation before
        // any destination allocation can push a new relative hand entry.
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            let peer_tid = if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            if UInt(peer_tid) >= PTO_MODEL_MEMORY_AGENTS then
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
        end;
    end;
    let selection_ordinal = if _CurrentPEContextValid then
        CaptureBundleGMOVSourceSelection(binding.source0,
            binding.source0_relative, binding.pe_mask,
            binding.gmov_selection_ordinal)
        else 0;
    if _CurrentPEContextValid && selection_ordinal == 0 then return (FALSE, result_writer_effects); end;
    if _CurrentPEContextValid then
        _BundleTileBindings[[0]].gmov_selection_captured = TRUE;
        _BundleTileBindings[[0]].gmov_selection_ordinal = selection_ordinal;
    end;
    let selection_slot = if selection_ordinal > 0 then
        FindBundleGMOVSourceSelectionOrdinal(selection_ordinal) else 0;
    if _CurrentPEContextValid && selection_slot < 0 then return (FALSE, result_writer_effects); end;
    let current_destination = _CurrentMemoryAgent as integer {0..3};
    let current_source_pe = if _CurrentPEContextValid then
        _BundleGMOVSourceSelections[[selection_slot]]
            .source_pes[[current_destination]]
        else 0 as MemoryAgentId;
    let current_source = if _CurrentPEContextValid then
        _BundleGMOVSourceSelections[[selection_slot]]
            .sources[[current_destination]]
        else binding.source0;
    let current_source_tile = if _CurrentPEContextValid then
        BundleGMOVPESourceTile(current_source, current_source_pe)
        else _Tiles[[current_source]];
    if !binding.destination_valid || !binding.source0_valid ||
       binding.source1_valid || !binding.last ||
       !BundleGMOVCore4SourceReady(binding.source0,
           binding.source0_relative, selection_ordinal) ||
       BundleTileDestinationSizeBytes(0) !=
           current_source_tile.capacity_bytes ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding)) ||
       current_source_tile.data_type != TileDataTypeFromEncoding(
           CurrentBundleTileOperationDataTypeCode()
               as TileDataTypeEncoding) ||
       current_source_tile.layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) != 1 then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
    end;
    let current_mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    // A nonparticipant still performs the immutable Core4 peer, descriptor,
    // generation and readiness preflight above, but has no destination,
    // publication or source-lifetime effect in its private bank.
    if _CurrentPEContextValid &&
       binding.pe_mask[current_mask_bit] == '0' then return (TRUE, result_writer_effects); end;
    if _CurrentPEContextValid && _CurrentKernelInvocation != 0 &&
       binding.pe_mask[current_mask_bit] == '1' &&
       !binding.source0_reuse then
        let source_epoch = _BundleGMOVSourceSelections[[selection_slot]]
            .source_epochs[[current_destination]];
        let participants = BundleGMOVSourceParticipantMask(
            selection_ordinal, current_source_pe, current_source,
            source_epoch);
        let ordinal = CaptureBundleSourceLifetime(FALSE,
            current_source_pe, current_source, source_epoch, 0,
            participants, binding.source0_lifetime_ordinal);
        if ordinal == 0 then return (FALSE, result_writer_effects); end;
        _BundleTileBindings[[0]].source0_lifetime_captured = TRUE;
        _BundleTileBindings[[0]].source0_lifetime_ordinal = ordinal;
    end;
    // GMOV has no dimensions that describe a new shape: the destination
    // carries the resolved peer source shape while B.DATR.Layout selects its
    // physical representation.
    let (destinations_resolved, resolved_writer_effects) =
        ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, current_source_tile.valid_rows,
            current_source_tile.valid_columns,
            current_source_tile.columns, TRUE,
            current_source_tile.data_type);
    if !destinations_resolved then return (FALSE, result_writer_effects); end;
    var writer_effects = resolved_writer_effects;
    if !ValidateBundleLocalGenerationWritersWithWriterEffects(
           writer_effects) then
        RollBackBundleTileDestinations(); return (FALSE, result_writer_effects);
    end;
    let destination = _BundleTileBindings[[0]].destination;
    let source = current_source;
    let selected_source = if _CurrentPEContextValid then
        current_source_tile else _Tiles[[source]];
    let (writer_found, writer_value) =
        BundleLocalGenerationCubeWriterValueForDestination(
            writer_effects, destination, _Tiles[[destination]]);
    let destination_value = if writer_found then writer_value
        else _Tiles[[destination]];
    if !BundleGMOVPESourceTileReady(selected_source) ||
       !(if writer_found then BundleGMOVDestinationValueMatches(
                 destination_value, selected_source)
          else TileElementwiseDescriptorLegal(destination) &&
               _Tiles[[destination]].rows == selected_source.rows &&
               _Tiles[[destination]].columns == selected_source.columns &&
               _Tiles[[destination]].valid_rows == selected_source.valid_rows &&
               _Tiles[[destination]].valid_columns == selected_source.valid_columns &&
               _Tiles[[destination]].data_type == selected_source.data_type &&
               _Tiles[[destination]].layout == selected_source.layout) ||
       !TileElementwiseLayoutSupported(selected_source.layout) ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           selected_source.data_type) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if writer_found then
        let target = TileOutputValueTarget {
            destination = destination,
            value = writer_value
        };
        let result = GMOVFromSourceTileToValue(target, selected_source);
        writer_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
            writer_effects, destination, result);
    else
        if _CurrentPEContextValid then
            GMOVFromSourceTile(destination, selected_source);
        else
            GMOV(destination, source, Zeros{PTO_XLEN});
        end;
    end;
    result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
    if _BundleTileBindings[[0]].source0_lifetime_captured then
        CompleteBundleSourceLifetime(
            _BundleTileBindings[[0]].source0_lifetime_ordinal);
    elsif !_CurrentPEContextValid && !binding.source0_reuse then
        ConsumeTilePayloadForMask(source, binding.pe_mask);
    end;
    if _CurrentPEContextValid then
        CompleteBundleGMOVSourceSelection(selection_ordinal);
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return (TRUE, result_writer_effects);
end;
```
<!-- GENERATED-ASL-END: unit -->
