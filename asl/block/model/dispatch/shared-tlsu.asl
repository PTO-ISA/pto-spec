// PTO-UNIT: {"classification":["model","dispatch","shared-tlsu"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU-HELPERS","PTO-BLOCK-MODEL-DISPATCH-SHARED-TMOV-CUBE-TO-ND","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-VALUES"],"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","surface":"block"}
readonly func BundleSharedTLSUSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return BundleSharedBindingPhysicalCount() > 0;
end;
readonly func BundleSharedTMOVLocalSchemaLegal() => boolean
begin
    if BundleSharedTMOVCubeToNDSelected() then
        return BundleSharedTMOVCubeToNDSchemaLegal();
    end;
    if BundleSharedBindingPhysicalCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_size = if BundleSharedBindingIsReusedDestination(0) then
        BundleSharedGenerationCapacity(0)
        else BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || binding.destination_valid ||
       !binding.source0_valid || binding.source1_valid || !binding.last ||
       binding.destination_size != 0 ||
       (!TileSizeCodeIsLegal(shared_size) &&
        !BundleSharedBindingIsReusedDestination(0)) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    if !BundleSharedTMOVGenerationModeLegal(0, FALSE) then return FALSE; end;
    if !TileSourceContentsDefined(binding.source0) ||
       _Tiles[[binding.source0]].capacity_bytes !=
           TileSizeCodeBytes(shared_size as integer {1..12}) then
        return FALSE;
    end;
    if !BundleSharedTMOVNormalCarrierCompatible(
           _Tiles[[binding.source0]].data_type) then return FALSE; end;
    var candidate = _Tiles[[binding.source0]];
    if _CurrentPEContextValid &&
       _BundleSharedBindings[[0]].destination_assemble.valid then
        // B.ASSEMBLE replaces a complete Shared parent only after matching
        // per-PE fragments have formed its candidate. The old published
        // descriptor describes that parent, not an individual writer's
        // private fragment, so candidate compatibility is checked against
        // the open Core-owned generation by its submission owner.
        return TRUE;
    end;
    return SharedTileUpdateCompatible(
        BundleSharedBindingId(0), candidate, shared_mask);
end;

readonly func BundleSharedTMOVDestinationSchemaLegal(
    shared_tile_id: SharedTileID, function: integer {0..31}) => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || !binding.destination_valid ||
       binding.source0_valid || binding.source1_valid || !binding.last ||
       !LocalTileSizeCodeIsLegal(binding.destination_size) ||
       BundleSharedBindingIsDestination(0) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let capacity_bytes = TileSizeCodeBytes(
        binding.destination_size as integer {1..12});
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    if valid_rows < 1 || valid_columns < 1 || columns < 1 ||
       valid_columns > columns then return FALSE; end;
    let (data_type_valid, operation_type) = ResolveBundleEffectiveDataType();
    if !data_type_valid then return FALSE; end;
    var data_type = operation_type;
    let source_interpretation = operation_type == TileDataType_E6M2 || operation_type == TileDataType_RCPE6M2;
    let layout = CurrentBundleTileLayout();
    if _BundleSharedBindings[[0]].source0_subview.valid then
        if !BundleSharedSubviewLegal(0) then return FALSE; end;
        let view = MaterializeBundleSharedSubview(0);
        if !BundleSharedTMOVNormalCarrierCompatible(view.data_type) then return FALSE; end;
        if source_interpretation then data_type = view.data_type; end;
        if view.capacity_bytes != capacity_bytes ||
           view.valid_rows != valid_rows ||
           view.valid_columns != valid_columns ||
           view.columns != columns || view.data_type != data_type ||
           view.layout != layout then
            return FALSE;
        end;
        return function == 2;
    end;
    let source_type = SharedTileRecord(shared_tile_id).tile.data_type;
    if !BundleSharedTMOVNormalCarrierCompatible(source_type) then return FALSE; end;
    if source_interpretation then data_type = source_type; end;
    if !SharedTileReadSchemaLegalAtCapacity(shared_tile_id, valid_rows, valid_columns, columns, data_type, layout, capacity_bytes) then return FALSE; end;
    return function == 2;
end;
func ExecuteBundleSharedTLSUOperation() => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var result_writer_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    let function = UInt(_BundleOperation.selector[4:0]);
    if BundleSharedBindingPhysicalCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let shared_tile_id = BundleSharedBindingId(0);
    let shared_size = if BundleSharedBindingIsReusedDestination(0) then
        BundleSharedGenerationCapacity(0)
        else BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if _CurrentPEContextValid &&
       _BundleSharedBindings[[0]].destination_assemble.valid &&
       _BundleSharedBindings[[0]].destination_assemble
           .shared_request_squashed then
        _BundleSharedBindings[[0]].destination_assemble
            .shared_request_waiting = TRUE;
        return (FALSE, result_writer_effects);
    end;
    if shared_mask == Zeros{4} then return (TRUE, result_writer_effects); end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    var transfer_data_type = TileDataType_FP64;
    if function == 0 || function == 1 then
        transfer_data_type = TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
        if !TileRegularTLSUDataTypeSupported(transfer_data_type) then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
    end;
    // Shared CUBE-to-ND TMOV has no ExecutionMask carrier. Reject its GPR
    // form here, before the generic mask-schema path derives a layout from a
    // conversion-only DATR selector.
    if BundleSharedTMOVCubeToNDSelected() &&
       (_BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present) then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return (FALSE, result_writer_effects);
    end;
    if _CurrentPEContextValid &&
       shared_mask[PTOPEMaskBitOfPEIdentity(
           _CurrentMemoryAgent as integer {0..3})] != '1' then
        ConsumeBundleSharedBindings(1);
        FinalizeBundleTileAttempt(TileExecution_Executed);
        return (TRUE, result_writer_effects);
    end;
    let replaces_shared = function == 0 ||
        (function == 2 && (BundleSharedBindingIsDestination(0) ||
         BundleSharedBindingIsReusedDestination(0)));
    if replaces_shared && SharedSourceLifetimePinned(shared_tile_id) then
        return (FALSE, result_writer_effects);
    end;
    if function == 0 then
        if (!BundleSharedBindingIsDestination(0) &&
            !BundleSharedBindingIsReusedDestination(0)) ||
           !TileSizeCodeIsLegal(shared_size) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = UInt(_BundleDimensions[[2]]);
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           columns < 1 || columns > 65535 || valid_columns > columns then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        var load_base_addresses: CorePEWords;
        var load_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            let actual_source = !_CurrentPEContextValid ||
                agent == _CurrentMemoryAgent;
            load_base_addresses[[agent]] =
                if actual_source && _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            load_row_stride_bytes[[agent]] =
                if actual_source && _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    columns as integer {0..65535}, transfer_data_type);
        end;
        let assembling =
            _BundleSharedBindings[[0]].destination_assemble.valid;
        var prior_shared = SharedTileRecord(shared_tile_id);
        if assembling then
            prior_shared = BeginBundleSharedGenerationProbe(shared_tile_id);
        end;
        TLOADShared(shared_tile_id, load_base_addresses, load_row_stride_bytes,
            shared_size as integer {1..12}, valid_rows as integer {1..65535},
            columns as integer {1..65535},
            valid_rows as integer {1..65535},
            valid_columns as integer {1..65535},
            transfer_data_type,
            CurrentBundleTileLayout(), shared_mask);
        if assembling then
            let candidate = SharedTileRecord(shared_tile_id);
            // On a first fault, leave the candidate record in place: prior
            // reads remain observable but the partial generation is not ready
            // or published. Successful candidates still commit atomically.
            if _LastFault == Fault_None then
                RestoreBundleSharedGenerationProbe(shared_tile_id, prior_shared);
                let committed = if _CurrentPEContextValid then
                    CommitBundleSharedGenerationCandidateForCurrentPE(
                        0, candidate)
                    else CommitBundleSharedGenerationCandidate(0, candidate);
                if !committed then
                    if BundleSharedGenerationRequestWaiting(0) then
                        return (FALSE, result_writer_effects);
                    end;
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
            end;
        end;
    elsif function == 1 then
        if !SharedStorePEMaskLegal(function, shared_mask) ||
           BundleSharedBindingIsDestination(0) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        // Shared source readiness is a parent-level hardware gate. Pending or
        // incomplete generations keep the block active for retry with no
        // payload read, binding consumption, or GM effect.
        if !SharedTilePublished(shared_tile_id) then
            return (FALSE, result_writer_effects);
        end;
        let store_valid_columns = BundleSharedStoreValidColumns(shared_tile_id);
        let store_valid_rows = BundleSharedStoreValidRows(shared_tile_id);
        let store_columns = BundleSharedStoreColumns(
            shared_tile_id, store_valid_columns);
        let store_data_type = transfer_data_type;
        let store_layout = CurrentBundleTileLayout();
        let has_subview =
            _BundleSharedBindings[[0]].source0_subview.valid;
        if has_subview && !BundleSharedSubviewLegal(0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        if !has_subview && (store_valid_columns < 1 || store_valid_rows < 1 ||
           store_columns < 1 || store_valid_columns > store_columns ||
           !SharedTileReadSchemaLegal(shared_tile_id, store_valid_rows,
               store_valid_columns, store_columns, store_data_type,
               store_layout)) then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        var store_base_addresses: CorePEWords;
        var store_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            store_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            store_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    store_columns as integer {0..65535}, store_data_type);
        end;
        if has_subview then
            var per_pe_store_tiles: CorePETileInfos;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let agent = pe as MemoryAgentId;
                per_pe_store_tiles[[agent]] =
                    MaterializeBundleSharedSubviewForPE(0, agent);
            end;
            TSTORESharedPerPE(store_base_addresses, store_row_stride_bytes,
                per_pe_store_tiles, shared_mask);
        else
            let store_tile = MaterializeSharedTileForReadSchema(
                shared_tile_id, store_valid_rows, store_valid_columns,
                store_columns, store_data_type, store_layout);
            TSTOREShared(store_base_addresses, store_row_stride_bytes,
                shared_tile_id, store_tile, shared_mask);
        end;
    elsif function == 2 then
        let shared_is_destination = BundleSharedBindingIsDestination(0) ||
            BundleSharedBindingIsReusedDestination(0);
        if BundleSharedTMOVCubeToNDSelected() && !shared_is_destination then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        if shared_is_destination then
            if !BundleSharedTMOVLocalSchemaLegal() then
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
            let binding = _BundleTileBindings[[0]];
            let assembling =
                _BundleSharedBindings[[0]].destination_assemble.valid;
            if BundleSharedTMOVCubeToNDSelected() then
                let candidate = BundleSharedTMOVCubeToNDCandidate(0);
                if assembling then
                    let assemble =
                        _BundleSharedBindings[[0]].destination_assemble;
                    let offset_cells =
                        (UInt(assemble.offset) * 4) as integer {0..8188};
                    let writer_cells =
                        (TileSizeCodeBytes(assemble.size_code as integer
                            {1..12}) DIVRM 32) as integer {4..8192};
                    let payload_elements =
                        ((writer_cells * 32 * 8) DIVRM
                            TileElementBits(candidate.tile.data_type))
                                as integer {1..524288};
                    let committed = if _CurrentPEContextValid then
                        CommitBundleSharedGenerationCandidateForCurrentPE(
                            0, candidate)
                        else CommitBundleSharedGenerationCandidateRangeWithPayloadElements(
                            0, candidate, offset_cells, writer_cells,
                            writer_cells, payload_elements, TRUE, FALSE,
                            shared_mask, TRUE, Zeros{PTO_XLEN},
                            Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
                            Zeros{PTO_XLEN},
                            Zeros{PTO_XLEN} +
                                UInt(_BundleDataAttributes.data_layout));
                    if !committed then
                        if BundleSharedGenerationRequestWaiting(0) then
                            return (FALSE, result_writer_effects);
                        end;
                        SetFault(Fault_TileLegality, ReadTPC());
                    end;
                elsif !SharedTileProspectiveFullyInitialized(shared_tile_id,
                        candidate.tile, shared_mask) ||
                      !AtomicUpdateSharedTileWithPublication(shared_tile_id,
                          candidate.tile, shared_mask, TRUE) then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
            else
            var prior_shared = SharedTileRecord(shared_tile_id);
            if assembling then
                prior_shared = BeginBundleSharedGenerationProbe(shared_tile_id);
                TMOVLocalToShared(shared_tile_id, binding.source0,
                    shared_size as integer {1..12}, shared_mask, FALSE);
                let candidate = SharedTileRecord(shared_tile_id);
                RestoreBundleSharedGenerationProbe(shared_tile_id, prior_shared);
                if _LastFault == Fault_None then
                    let committed = if _CurrentPEContextValid then
                        CommitBundleSharedGenerationCandidateForCurrentPE(
                            0, candidate)
                        else CommitBundleSharedGenerationCandidate(0,
                            candidate);
                    if !committed then
                        if BundleSharedGenerationRequestWaiting(0) then
                            return (FALSE, result_writer_effects);
                        end;
                        SetFault(Fault_TileLegality, ReadTPC());
                    end;
                end;
            else
                TMOVLocalToShared(shared_tile_id, binding.source0,
                    shared_size as integer {1..12}, shared_mask, TRUE);
            end;
            end;
        else
            // The same parent-level readiness gate applies before any Local
            // destination allocation or Shared payload materialization. The
            // block remains active so completion can retry after publication.
            if !SharedTilePublished(shared_tile_id) then
                return (FALSE, result_writer_effects);
            end;
            if !BundleSharedTMOVDestinationSchemaLegal(shared_tile_id, function) ||
               !SelectedBundleTileMasksLegal() then
                if _LastFault == Fault_None then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
                return (FALSE, result_writer_effects);
            end;
            let binding = _BundleTileBindings[[0]];
            let capacity_bytes = TileSizeCodeBytes(
                binding.destination_size as integer {1..12});
            let valid_rows = BundleDestinationValidRows(FALSE, 0);
            let valid_columns = BundleDestinationValidColumns(FALSE, 0);
            let columns = BundleDestinationPhysicalColumns(FALSE, 0);
            let (data_type_valid, operation_type) =
                ResolveBundleEffectiveDataType();
            if !data_type_valid then
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
            let has_subview =
                _BundleSharedBindings[[0]].source0_subview.valid;
            let source_type = if has_subview then MaterializeBundleSharedSubview(0).data_type else SharedTileRecord(shared_tile_id).tile.data_type;
            let source_interpretation = operation_type == TileDataType_E6M2 || operation_type == TileDataType_RCPE6M2;
            let data_type = if source_interpretation then source_type
                else operation_type;
            let shared_tile = if has_subview then
                MaterializeBundleSharedSubview(0)
            else MaterializeSharedTileForReadSchemaAtCapacity(
                shared_tile_id, valid_rows, valid_columns, columns, data_type,
                CurrentBundleTileLayout(), capacity_bytes);
            let (destinations_resolved, resolved_writer_effects) =
                ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
                    TRUE,
                    shared_tile.valid_rows as integer {1..65535},
                    shared_tile.valid_columns as integer {1..65535},
                    shared_tile.columns as integer {1..65535},
                    TRUE, data_type);
            if !destinations_resolved then return (FALSE, result_writer_effects); end;
            var writer_effects = resolved_writer_effects;
            if !ValidateBundleLocalGenerationWritersWithWriterEffects(
                   writer_effects) then
                RollBackBundleTileDestinations(); return (FALSE, result_writer_effects);
            end;
            let destination = _BundleTileBindings[[0]].destination;
            let (writer_found, writer_value) =
                BundleLocalGenerationCubeWriterValueForDestination(
                    writer_effects, destination, _Tiles[[destination]]);
            let destination_value = if writer_found then writer_value
                else _Tiles[[destination]];
            if destination_value.rows != shared_tile.rows ||
               destination_value.columns != shared_tile.columns ||
               destination_value.valid_rows != shared_tile.valid_rows ||
               destination_value.valid_columns != shared_tile.valid_columns ||
               destination_value.data_type != shared_tile.data_type ||
               destination_value.layout != shared_tile.layout then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
            if writer_found then
                let target = TileOutputValueTarget {
                    destination = destination,
                    value = writer_value
                };
                var result = target.value;
                if has_subview then
                    var per_pe_shared_tiles: CorePETileInfos;
                    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                        let agent = pe as MemoryAgentId;
                        per_pe_shared_tiles[[agent]] =
                            MaterializeBundleSharedSubviewForPE(0, agent);
                    end;
                    result = TMOVSharedToLocalPerPEToValue(
                        target, per_pe_shared_tiles, shared_mask);
                else
                    result = TMOVSharedToLocalToValue(
                        target, shared_tile_id, shared_tile, shared_mask);
                end;
                writer_effects =
                    BundleLocalGenerationCubeWriterEffectWithOutput(
                        writer_effects, destination, result);
            else
                if has_subview then
                    var per_pe_shared_tiles: CorePETileInfos;
                    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                        let agent = pe as MemoryAgentId;
                        per_pe_shared_tiles[[agent]] =
                            MaterializeBundleSharedSubviewForPE(0, agent);
                    end;
                    TMOVSharedToLocalPerPE(destination, per_pe_shared_tiles,
                        shared_mask);
                else
                    TMOVSharedToLocal(destination, shared_tile_id,
                        shared_tile, shared_mask);
                end;
            end;
            result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
        end;
    else
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return (FALSE, result_writer_effects);
    end;
    ConsumeBundleSharedBindings(1);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return (TRUE, result_writer_effects);
end;
