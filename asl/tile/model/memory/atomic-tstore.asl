// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ATOMIC-TSTORE","surface":"tile","classification":["model","memory","atomic-tstore"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ATOMICITY","PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-TILE-MODEL-MEMORY-LOAD-STORE","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED"]}
func PreflightAtomicTStore(tile: TileInfo, base_address: Word,
    row_stride_bytes: Word, execution_mask: BundleExecutionMaskBinding)
    => (boolean, bits(PTO_MODEL_TILE_ELEMENTS), TilePayload,
        integer {0..PTO_MODEL_TILE_ELEMENTS})
begin
    var selected_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    var selected_targets: TilePayload = EmptyTilePayload();
    var selected_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let active = if execution_mask.valid then
                BundleExecutionMaskActiveAt(tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535})
                else TRUE;
            if active then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let address = TileMemoryStridedByteAddress(base_address,
                    row as integer {0..65535},
                    column as integer {0..65535}, row_stride_bytes,
                    tile.data_type);
                let read_probe = ProbeTileMemoryAccess(address,
                    tile.data_type, FALSE);
                if RaiseDataAccessFault(read_probe, address) then
                    return (FALSE, selected_elements, selected_targets,
                        selected_count);
                end;
                let write_probe = ProbeTileMemoryAccess(address,
                    tile.data_type, TRUE);
                if RaiseDataAccessFault(write_probe, address) then
                    return (FALSE, selected_elements, selected_targets,
                        selected_count);
                end;
                if read_probe.translated_address !=
                   write_probe.translated_address then
                    SetFault(Fault_DataPage, address);
                    return (FALSE, selected_elements, selected_targets,
                        selected_count);
                end;
                selected_elements[element] = '1';
                selected_targets[[element]] = read_probe.translated_address;
                selected_count = (selected_count + 1)
                    as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    return (TRUE, selected_elements, selected_targets, selected_count);
end;

func ExecuteAtomicTStoreSnapshotProgress(core: PTOModelCoreIdentity,
    pe: MemoryAgentId, obligation_slot: GMObligationIndex,
    beat_budget: integer {0..32768}) => TileStoreProgressResult
begin
    let obligation = _GMObligations[[core]][[pe]][[obligation_slot]];
    let tile = obligation.source_snapshot;
    let data_type = tile.data_type;
    let operation = GMReductionOperationForTStoreMode(
        obligation.atomic_tstore_data_attributes.comparison_mode);
    let element_bytes = TileMemoryElementBytes(data_type);
    let start_element = obligation.progress_element;
    var committed_this_call: integer {0..32768} = 0;
    var budget_reached = FALSE;
    var logical_element: integer {0..32768} = 0;
    BeginMemoryReplay(obligation.instruction_pc);
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if logical_element >= start_element && !budget_reached &&
               obligation.atomic_tstore_active_elements[element] == '1' &&
               obligation.atomic_tstore_committed_elements[element] == '0' then
                if beat_budget != 0 && committed_this_call >= beat_budget then
                    budget_reached = TRUE;
                else
                    let original_address = TileMemoryStridedByteAddress(
                        obligation.base_address,
                        row as integer {0..65535},
                        column as integer {0..65535},
                        obligation.row_stride_bytes, data_type);
                    let translated_address =
                        obligation.atomic_tstore_translated_targets[[element]];
                    let old_raw = LoadTranslatedUnsigned(translated_address,
                        element_bytes);
                    let old_value = DecodeTileMemoryElementRaw(old_raw,
                        data_type, FALSE);
                    let input_value = TileReadLogicalElement(tile, element);
                    let new_value = GMReductionResult(operation, data_type,
                        old_value, input_value);
                    let stored_value = StoreTileMemoryElement(
                        original_address, translated_address, data_type,
                        FALSE, new_value);
                    MarkGMObligationIrrevocable(core, pe, obligation_slot);
                    RecordAtomicEventForAgent(pe, translated_address,
                        element_bytes, old_raw,
                        NormalizeMemoryAccessValue(stored_value,
                            element_bytes),
                        obligation.memory_order, TRUE);
                    CommitMemoryReplayEffect();
                    _GMObligations[[core]][[pe]][[obligation_slot]]
                        .atomic_tstore_committed_elements[element] = '1';
                    _GMObligations[[core]][[pe]][[obligation_slot]]
                        .atomic_tstore_committed_count =
                        (_GMObligations[[core]][[pe]][[obligation_slot]]
                            .atomic_tstore_committed_count + 1)
                            as integer {0..32768};
                    _GMObligations[[core]][[pe]][[obligation_slot]]
                        .progress_element = (logical_element + 1)
                            as integer {0..32768};
                    committed_this_call = (committed_this_call + 1)
                        as integer {0..32768};
                    if beat_budget != 0 &&
                       committed_this_call >= beat_budget then
                        budget_reached = TRUE;
                    end;
                end;
            end;
            logical_element = (logical_element + 1)
                as integer {0..32768};
        end;
    end;
    CompleteMemoryReplay();
    return if _GMObligations[[core]][[pe]][[obligation_slot]]
        .atomic_tstore_committed_count <
        _GMObligations[[core]][[pe]][[obligation_slot]]
            .atomic_tstore_target_count then TileStoreProgress_Pending
        else TileStoreProgress_Completed;
end;

func ExecuteAtomicTStoreDirect(tile: TileInfo, base_address: Word,
    row_stride_bytes: Word, execution_mask: BundleExecutionMaskBinding,
    data_attributes: BundleDataAttributes, memory_order: MemoryOrder,
    active_elements: bits(PTO_MODEL_TILE_ELEMENTS),
    translated_targets: TilePayload)
begin
    let data_type = tile.data_type;
    let operation = GMReductionOperationForTStoreMode(
        data_attributes.comparison_mode);
    let element_bytes = TileMemoryElementBytes(data_type);
    BeginMemoryReplay(ReadBPC());
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if (!execution_mask.valid ||
                active_elements[TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535})] == '1') then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let original_address = TileMemoryStridedByteAddress(
                    base_address, row as integer {0..65535},
                    column as integer {0..65535}, row_stride_bytes,
                    data_type);
                let translated_address = translated_targets[[element]];
                let old_raw = LoadTranslatedUnsigned(translated_address,
                    element_bytes);
                let old_value = DecodeTileMemoryElementRaw(old_raw,
                    data_type, FALSE);
                let input_value = TileReadLogicalElement(tile, element);
                let new_value = GMReductionResult(operation, data_type,
                    old_value, input_value);
                let stored_value = StoreTileMemoryElement(original_address,
                    translated_address, data_type, FALSE, new_value);
                RecordAtomicEvent(translated_address, element_bytes, old_raw,
                    NormalizeMemoryAccessValue(stored_value, element_bytes),
                    memory_order, TRUE);
                CommitMemoryReplayEffect();
            end;
        end;
    end;
    CompleteMemoryReplay();
end;

func TSTOREAtomic(base_address: Word, row_stride_bytes: Word,
    source: TileIndex, source_generation: Word, tile: TileInfo) => boolean
begin
    let core = _CurrentModelCore;
    let pe = _CurrentMemoryAgent;
    let request_pc = ReadBPC();
    let order = CurrentBundleMemoryOrder();
    let existing = FindCurrentAtomicTStoreObligation();
    var slot: GMObligationIndex = 0;
    if existing >= 0 &&
       _GMObligations[[core]][[pe]][[existing as GMObligationIndex]]
           .captured_atomic_tstore then
        slot = existing as GMObligationIndex;
        if _GMObligations[[core]][[pe]][[slot]].state ==
           GMObligation_Validated then
            IssueGMObligation(core, pe, slot);
        end;
    else
        var active_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
        var translated_targets: TilePayload = EmptyTilePayload();
        var target_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
        let (preflighted, selected_elements, selected_targets, selected_count) =
            PreflightAtomicTStore(tile, base_address, row_stride_bytes,
                _BundleExecutionMask);
        if !preflighted then
            return FALSE;
        end;
        active_elements = selected_elements;
        translated_targets = selected_targets;
        target_count = selected_count;
        if !_KernelInvocationActiveByCore[[core]] ||
           _CurrentKernelInvocation == 0 ||
           _CurrentMemoryOrigin != MemoryEventOrigin_Kernel then
            if target_count != 0 then
                ExecuteAtomicTStoreDirect(tile, base_address,
                    row_stride_bytes, _BundleExecutionMask,
                    _BundleDataAttributes, order, active_elements,
                    translated_targets);
            end;
            return TRUE;
        end;
        if existing >= 0 then
            slot = existing as GMObligationIndex;
        else
            slot = RegisterKernelGMObligation(GMRequest_Atomic,
                _BundleStartEncodedInstruction, request_pc, _BundleOperation,
                _BundleArgument, _BundleTileBindings, _BundleScalarBindings,
                _BundleSharedBindings, _BundleDimensions, source,
                source_generation, tile, _BundleExecutionMask, base_address,
                row_stride_bytes, order, TRUE, FALSE, FALSE, FALSE, TRUE);
            IssueGMObligation(core, pe, slot);
        end;
        _GMObligations[[core]][[pe]][[slot]].captured_atomic_tstore = TRUE;
        _GMObligations[[core]][[pe]][[slot]].descriptor = _BundleOperation;
        _GMObligations[[core]][[pe]][[slot]].bundle_argument = _BundleArgument;
        _GMObligations[[core]][[pe]][[slot]].bundle_tile_bindings =
            _BundleTileBindings;
        _GMObligations[[core]][[pe]][[slot]].bundle_scalar_bindings =
            _BundleScalarBindings;
        _GMObligations[[core]][[pe]][[slot]].bundle_shared_bindings =
            _BundleSharedBindings;
        _GMObligations[[core]][[pe]][[slot]].bundle_dimensions =
            _BundleDimensions;
        _GMObligations[[core]][[pe]][[slot]].source_tile = source;
        _GMObligations[[core]][[pe]][[slot]].source_generation =
            source_generation;
        _GMObligations[[core]][[pe]][[slot]].source_snapshot = tile;
        _GMObligations[[core]][[pe]][[slot]].base_address = base_address;
        _GMObligations[[core]][[pe]][[slot]].row_stride_bytes =
            row_stride_bytes;
        _GMObligations[[core]][[pe]][[slot]].execution_mask =
            _BundleExecutionMask;
        _GMObligations[[core]][[pe]][[slot]].memory_order = order;
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_data_attributes = _BundleDataAttributes;
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_active_elements = active_elements;
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_committed_elements =
                Zeros{PTO_MODEL_TILE_ELEMENTS};
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_translated_targets = translated_targets;
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_target_count =
                target_count as integer {0..32768};
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_committed_count = 0;
        _GMObligations[[core]][[pe]][[slot]]
            .atomic_tstore_finalization_pending = TRUE;
        ResolveGMObligationFaultRisk(core, pe, slot);
        IssueGMObligation(core, pe, slot);
    end;
    if _GMObligations[[core]][[pe]][[slot]]
           .atomic_tstore_target_count == 0 then
        let obligation = _GMObligations[[core]][[pe]][[slot]];
        CompleteGMObligationForIdentity(core, pe, slot,
            obligation.invocation, obligation.identity);
        return TRUE;
    end;
    if VerificationGMProgressIsDeferred() then return TRUE; end;
    let result = ExecuteAtomicTStoreSnapshotProgress(core, pe, slot,
        _VerificationGMProgressBeatBudget);
    let obligation = _GMObligations[[core]][[pe]][[slot]];
    if result == TileStoreProgress_Completed then
        CompleteGMObligationForIdentity(core, pe, slot,
            obligation.invocation, obligation.identity);
    end;
    return TRUE;
end;
