// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-ATOMIC-TSTORE","surface":"block","classification":["model","dispatch","tlsu-atomic-tstore"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-INSTRUCTION-OPERANDS","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-MEMORY-ATOMIC-TSTORE","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-STRIDE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL"]}

readonly func BundleAtomicTStoreSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           BundleTileDecodeFamily(_BundleOperation.operation_class) ==
               TileDecode_TLSU &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 1 &&
           _BundleDataAttributesPresent &&
           _BundleDataAttributes.canonicalize;
end;

readonly func AtomicTStoreCurrentPESelected(pe_mask: bits(4)) => boolean
begin
    return pe_mask[PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] == '1';
end;

readonly func BundleAtomicTStoreCurrentPESelected() => boolean
begin
    if BundleSharedBindingPhysicalCount() != 0 then
        return BundleSharedBindingPhysicalCount() == 1 &&
               AtomicTStoreCurrentPESelected(
                   _BundleSharedBindings[[0]].pe_mask);
    end;
    return BundleTileBindingCount() == 1 &&
           AtomicTStoreCurrentPESelected(_BundleTileBindings[[0]].pe_mask);
end;

// Resolve only the command/binding participation boundary.  A valid Atomic
// TSTORE nonparticipant must not inspect its source payload, Shared readiness,
// or target addresses; those checks belong to the PE that owns the occurrence.
readonly func BundleAtomicTStoreCurrentPENonparticipant() => boolean
begin
    if !BundleAtomicTStoreSelected() || SelectedBundleTileMaskIsZero() ||
       !SelectedBundleTileMasksLegal() then
        return FALSE;
    end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then return FALSE; end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        return FALSE;
    end;
    if BundleSharedBindingPhysicalCount() != 0 then
        return BundleSharedBindingPhysicalCount() == 1 &&
               BundleSharedBindingCount() == 1 &&
               BundleTileBindingCount() == 0 &&
               BundleLocalTileSourceCount() == 0 &&
               BundleLocalTileDestinationCount() == 0 &&
               _BundleSharedBindings[[0]].valid &&
               _BundleSharedBindings[[0]].pe_mask != Zeros{4} &&
               !AtomicTStoreCurrentPESelected(
                   _BundleSharedBindings[[0]].pe_mask);
    end;
    if BundleSharedBindingCount() != 0 || BundleTileBindingCount() != 1 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    let mask_tile = BundleExecutionMaskTileCarrierPresent(operation);
    if mask_tile && !BundleExecutionMaskTileCarrierSchemaLegal(operation) then
        return FALSE;
    end;
    return binding.valid && !binding.destination_valid &&
           binding.source0_valid &&
           (binding.source1_valid == mask_tile) && binding.last &&
           BundleLocalTileSourceCount() == (if mask_tile then 2 else 1) &&
           BundleLocalTileDestinationCount() == 0 &&
           binding.pe_mask != Zeros{4} &&
           !AtomicTStoreCurrentPESelected(binding.pe_mask);
end;

readonly func AtomicTStoreSnapshotEncodingsLegal(tile: TileInfo,
    data_type: TileDataType) => boolean
begin
    // Local source definedness is checked before this helper; a Shared
    // materialized read schema is intentionally value-defined without setting
    // the temporary Local tile's contents_defined carrier.
    if !tile.allocated || tile.data_type != data_type then return FALSE; end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(tile.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

func ExecuteBundleAtomicTSTOREOperation() => boolean
begin
    // A successfully admitted occurrence is serviced from its immutable GM
    // obligation by the per-PE progress scheduler. Re-entering the instruction
    // cannot reinterpret live bundle fields or repeat committed coordinates.
    let existing = FindCurrentAtomicTStoreOccurrence();
    if existing >= 0 &&
       _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
           [[existing as GMObligationIndex]].captured_atomic_tstore then
        if _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
               [[existing as GMObligationIndex]].state ==
           GMObligation_Cancelled then
            return TRUE;
        end;
        if _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
               [[existing as GMObligationIndex]].state ==
           GMObligation_Completed then
            return TRUE;
        end;
        return TRUE;
    end;

    let shared = BundleSharedBindingPhysicalCount() != 0;
    let participant_mask = if shared then
        _BundleSharedBindings[[0]].pe_mask
        else if BundleTileBindingCount() != 0 then
            _BundleTileBindings[[0]].pe_mask else Zeros{4};
    if participant_mask == Zeros{4} then return TRUE; end;
    if !AtomicTStoreCurrentPESelected(participant_mask) then return TRUE; end;

    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT ||
       TileOperationOfIndex(decoded as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) != TileOperation_TSTORE then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !_BundleDataAttributesPresent ||
       !_BundleDataAttributes.canonicalize ||
       UInt(_BundleDataAttributes.rounding_mode) != 0 ||
       _BundleDataAttributes.saturating ||
       _BundleDataAttributes.execution_mask_zero ||
       _BundleControlAttributes.atomic then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleExecutionMaskDataAttributesLegal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (type_valid, data_type) = ResolveBundleEffectiveDataType();
    let mode = _BundleDataAttributes.comparison_mode;
    let reduction = GMReductionOperationForTStoreMode(mode);
    if !type_valid || !GMReductionOperationDataTypeLegal(
           reduction, data_type) ||
       !TileRegularTLSUDataTypeSupported(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;

    var tile: TileInfo;
    var source: TileIndex = 0;
    var source_generation: Word = Zeros{PTO_XLEN};
    var base_address = Zeros{PTO_XLEN};
    var row_stride_bytes = Zeros{PTO_XLEN};
    let layout_code = UInt(_BundleDataAttributes.data_layout);
    let cube_store = layout_code == 24 || layout_code == 25;
    if shared then
        if BundleSharedBindingPhysicalCount() != 1 ||
           BundleSharedBindingCount() != 1 ||
           BundleTileBindingCount() != 0 ||
           _BundleSharedBindings[[0]].size_code != 0 ||
           BundleSharedBindingIsDestination(0) ||
           BundleSharedBindingIsReusedDestination(0) || cube_store ||
           TileDataLayoutIsCubeConversion(
               _BundleDataAttributes.data_layout) ||
           _BundleExecutionMask.valid ||
           _BundleDataAttributes.execution_mask_invert then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let shared_id = BundleSharedBindingId(0);
        if !SharedTilePublished(shared_id) then return FALSE; end;
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = UInt(_BundleDimensions[[2]]);
        let store_layout = TileDataLayoutDestinationLayout(
            TileDataLayoutOfCode(_BundleDataAttributes.data_layout));
        if _BundleSharedBindings[[0]].source0_subview.valid then
            if !BundleSharedSubviewLegalForPE(0, _CurrentMemoryAgent) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            tile = MaterializeBundleSharedSubviewForPE(0,
                _CurrentMemoryAgent);
        else
            if valid_columns < 1 || valid_columns > 65535 ||
               valid_rows < 1 || valid_rows > 65535 ||
               columns < 1 || columns > 65535 || valid_columns > columns ||
               !SharedTileReadSchemaLegal(shared_id,
                   valid_rows as integer {1..65535},
                   valid_columns as integer {1..65535},
                   columns as integer {1..65535}, data_type, store_layout) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            tile = MaterializeSharedTileForReadSchema(shared_id,
                valid_rows as integer {1..65535},
                valid_columns as integer {1..65535},
                columns as integer {1..65535}, data_type, store_layout);
        end;
        if tile.data_type != data_type || TileLayoutIsCube(tile.layout) ||
           !TileRegularTLSUDataTypeSupported(tile.data_type) ||
           !AtomicTStoreSnapshotEncodingsLegal(tile, data_type) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        row_stride_bytes = TileDenseRowStrideBytes(
            columns as integer {0..65535}, data_type);
    else
        if BundleSharedBindingCount() != 0 ||
           BundleSharedBindingPhysicalCount() != 0 ||
           BundleTileBindingCount() != 1 ||
           !BundleOperationBindingsComplete(operation) ||
           !SelectedBundleTileMasksLegal() then
            SetFault(Fault_BundleControl, ReadTPC());
            return FALSE;
        end;
        let binding = _BundleTileBindings[[0]];
        let execution_mask_tile = _BundleExecutionMask.valid &&
            _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
        if !binding.valid || binding.destination_valid ||
           !binding.source0_valid ||
           (binding.source1_valid != execution_mask_tile) || !binding.last ||
           binding.destination_size != 0 ||
           (execution_mask_tile &&
            _BundleExecutionMask.predicate_source_ordinal != 1) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if cube_store then
            if layout_code == 26 ||
               _BundleDataAttributes.data_type != DTYPE_NONE ||
               !_BundleDimensionPresent[[0]] ||
               !_BundleDimensionPresent[[1]] ||
               _BundleDimensionPresent[[2]] ||
               UInt(_BundleDimensions[[2]]) != 1 then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        elsif layout_code != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        source = BundleTileSourceIndex(0, FALSE);
        tile = _Tiles[[source]];
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let physical_columns = if cube_store then valid_columns
            else BundleDestinationPhysicalColumns(TRUE, source);
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           physical_columns < 1 || physical_columns > 65535 ||
           valid_columns > physical_columns || tile.data_type != data_type then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if cube_store then
            let cube_layout = TileDataLayoutCubeLayout(
                _BundleDataAttributes.data_layout);
            if UInt(_BundleDimensions[[2]]) != 1 ||
               !TileCubeDescriptorLegal(tile) ||
               !TileCubeLayoutDataTypeSupported(cube_layout, data_type) ||
               tile.layout != cube_layout ||
               tile.valid_rows != valid_rows ||
               tile.valid_columns != valid_columns then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        else
            if !TileDescriptorLegal(source) ||
               tile.layout != TileLayout_RowMajor ||
               tile.columns != physical_columns ||
               valid_rows > tile.valid_rows ||
               valid_columns > tile.valid_columns then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        end;
        if !TileElementwiseSourceContentsDefined(source) ||
           !TileElementwiseSourceEncodingsValidAs(source, data_type) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if _BundleExecutionMask.valid &&
           (tile.valid_rows != valid_rows ||
            tile.valid_columns != valid_columns) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        tile.valid_rows = valid_rows as integer {1..65535};
        tile.valid_columns = valid_columns as integer {1..65535};
        source_generation = TileStoreSourceGeneration(source);
        row_stride_bytes = TileDenseRowStrideBytes(
            (if cube_store then valid_columns else physical_columns)
                as integer {1..65535}, data_type);
    end;

    if _BundleScalarBindings[[0]].valid then
        if _BundleScalarBindings[[0]].source_count > 0 then
            base_address = ReadScalarRegisterOperand(
                _BundleScalarBindings[[0]].source0);
        end;
        if _BundleScalarBindings[[0]].source_count > 1 then
            row_stride_bytes = ReadScalarRegisterOperand(
                _BundleScalarBindings[[0]].source1);
        end;
    end;

    if _BundleDataAttributes.pad_value != Zeros{2} &&
       !cube_store then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !GMReductionOperationDataTypeLegal(reduction, tile.data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TSTOREAtomic(base_address, row_stride_bytes, source,
        source_generation, tile);
end;
