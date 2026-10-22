// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION","surface":"block","classification":["model","dispatch","predicate-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-STATE-ALLOCATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}

readonly func BundleFirstDestinationBinding()
    => (boolean, BundleTileBindingIndex)
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return (TRUE, binding as BundleTileBindingIndex);
        end;
    end;
    return (FALSE, 0);
end;

readonly func BundleFreeDestinationIndex(
    binding: BundleTileBindingIndex) => (boolean, TileIndex)
begin
    let hand = UInt(_BundleTileBindings[[binding]].destination_hand);
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !_Tiles[[raw_index]].allocated then
            return (TRUE, raw_index as TileIndex);
        end;
    end;
    return (FALSE, 0);
end;

func ResolveBundlePredicateDestination(operation_type: TileDataType) => boolean
begin
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    // Comparison input binding 0 owns the numeric shape and basis.  A later
    // binding may carry both the fresh destination and a PredicateCell
    // ExecutionMask, so the destination binding is not a source-type owner.
    let source = BundleTileSourceIndex(0, FALSE);
    let source_tile = _Tiles[[source]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    let cube = source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if binding.destination_allocated_by_bundle ||
       binding.destination_reused_by_generation then
        let destination = binding.destination;
        let destination_tile = _Tiles[[destination]];
        let descriptor_legal = if cube then
            TilePredicateCellDescriptorLegal(destination) &&
            destination_tile.predicate_basis_type == operation_type &&
            destination_tile.valid_rows == source_tile.valid_rows &&
            destination_tile.valid_columns == source_tile.valid_columns &&
            destination_tile.layout == source_tile.layout
        else
            TileDescriptorLegal(destination) &&
            destination_tile.storage_kind == TileStorage_Predicate &&
            destination_tile.rows == source_tile.rows &&
            destination_tile.columns == source_tile.columns &&
            destination_tile.valid_rows == source_tile.valid_rows &&
            destination_tile.valid_columns == source_tile.valid_columns &&
            destination_tile.layout == TileLayout_RowMajor;
        if !descriptor_legal ||
           _TileAllocationMasks[[destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if cube then
        if !TileCubePredicateDataTypeSupported(operation_type) ||
           !TileCarrierWidthCompatible(
               source_tile.data_type, operation_type) ||
           !TileCubeDescriptorShapeLegal(
               capacity_bytes, source_tile.valid_rows,
               source_tile.valid_columns, TileDataType_U8,
               source_tile.layout) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    elsif source_tile.storage_kind != TileStorage_Numeric ||
          source_tile.rows * source_tile.columns >
              TileLogicalElementCapacity(
                  source_tile.capacity_bytes, source_tile.data_type) ||
          PredicateTileStorageBytes(
              source_tile.rows, source_tile.columns) > capacity_bytes then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if cube then
        if !ConfigurePredicateCellForMask(
               resolved, capacity_bytes, source_tile.valid_rows,
               source_tile.valid_columns, operation_type,
               source_tile.layout, binding.pe_mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    else
        ConfigurePredicateTileForMask(
            resolved, capacity_bytes, source_tile.rows, source_tile.columns,
            source_tile.valid_rows, source_tile.valid_columns,
            binding.pe_mask);
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;


func ResolveBundlePredicateDestinationWithWriterEffects(
    operation_type: TileDataType)
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var effects = EmptyBundleLocalGenerationCubeWriterEffects();
    if !ResolveBundlePredicateDestination(operation_type) then
        return (FALSE, effects);
    end;
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return (FALSE, effects);
    end;
    let source = BundleTileSourceIndex(0, FALSE);
    let source_tile = _Tiles[[source]];
    let (writer_legal, updated_effects) =
        AddBundleLocalGenerationCubeWriterEffect(
            effects, destination_binding,
            source_tile.valid_rows as integer {1..65535},
            source_tile.valid_columns as integer {1..65535});
    if !writer_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        RollBackBundleTileDestinations();
        return (FALSE, updated_effects);
    end;
    return (TRUE, updated_effects);
end;

readonly func BundleComparisonSelectTrueSource(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileIndex
begin
    let decoded = TileOperationOfIndex(operation);
    let first = BundleTileSourceIndex(0, FALSE);
    let cell_select = _BundleTileBindings[[0]].source0_valid &&
        _Tiles[[first]].storage_kind == TileStorage_PredicateCell;
    if (decoded == TileOperation_TSEL || decoded == TileOperation_TSELS) &&
       cell_select then
        return BundleTileSourceIndex(0, TRUE);
    end;
    return first;
end;

func ResolveBundleCUBESelectDestinationWithWriterEffects(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var effects = EmptyBundleLocalGenerationCubeWriterEffects();
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return (FALSE, effects);
    end;
    let source = BundleComparisonSelectTrueSource(operation);
    let source_tile = _Tiles[[source]];
    let binding = _BundleTileBindings[[destination_binding]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, effects);
    end;
    if !TileCubeDescriptorLegal(source_tile) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return (FALSE, effects);
    end;
    if binding.destination_allocated_by_bundle ||
       binding.destination_reused_by_generation then
        let destination_tile = _Tiles[[binding.destination]];
        let local_generation = binding.destination_assemble.valid;
        let parent_rows = if source_tile.layout == TileLayout_CUBE_M16 then
            16 else 32;
        let parent_columns = TileCubePhysicalColumnsFromCapacity(
            capacity_bytes, source_tile.layout, operation_type);
        if !TileCubeDescriptorLegal(destination_tile) ||
           destination_tile.storage_kind != TileStorage_Numeric ||
           (if local_generation then
                destination_tile.rows != parent_rows ||
                destination_tile.columns != parent_columns
            else
                destination_tile.valid_rows != source_tile.valid_rows ||
                destination_tile.valid_columns != source_tile.valid_columns) ||
           destination_tile.data_type != operation_type ||
           destination_tile.layout != source_tile.layout ||
           _TileAllocationMasks[[binding.destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, effects);
        end;
        let (writer_legal, updated_effects) =
            AddBundleLocalGenerationCubeWriterEffect(
                effects, destination_binding,
                source_tile.valid_rows as integer {1..65535},
                source_tile.valid_columns as integer {1..65535});
        if !writer_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            RollBackBundleTileDestinations();
            return (FALSE, updated_effects);
        end;
        return (TRUE, updated_effects);
    end;
    if !TileCubeDescriptorShapeLegal(
           capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, operation_type,
           source_tile.layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return (FALSE, effects);
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found || !ConfigureCubeTileForMask(
           resolved, capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, operation_type,
           source_tile.layout,
           binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return (FALSE, effects);
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    let (writer_legal, updated_effects) =
        AddBundleLocalGenerationCubeWriterEffect(
            effects, destination_binding,
            source_tile.valid_rows as integer {1..65535},
            source_tile.valid_columns as integer {1..65535});
    if !writer_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        RollBackBundleTileDestinations();
        return (FALSE, updated_effects);
    end;
    return (TRUE, updated_effects);
end;

func ResolveBundleCUBESelectDestination(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let (legal, -) =
        ResolveBundleCUBESelectDestinationWithWriterEffects(operation);
    return legal;
end;

func ExecuteBundleComparisonGPRCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !SelectedBundleComparisonUsesGPRCarrier(operation) then return FALSE; end;
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid then return FALSE; end;
    let selected_high = _BundleDataAttributes.saturating;
    case TileOperationOfIndex(operation) of
        when TileOperation_TCMP =>
            let left = BundleTileSourceIndex(0, FALSE);
            let right = BundleTileSourceIndex(0, TRUE);
            let gpr_destination = _BundleScalarBindings[[0]].destination
                as GPRIndex;
            var value = TileCompareCUBEToGPRAs(
                left, right, BundleComparisonCodeAsTileComparison(),
                selected_high, operation_type);
            if _BundleExecutionMask.valid then
                let old_value = ReadGPR(gpr_destination);
                let tile = _Tiles[[left]];
                value = TileExecutionMaskPredicateGPRResult(
                    value, old_value, operation_type, tile.layout,
                    tile.valid_rows as integer {1..65535},
                    tile.valid_columns as integer {1..65535}, selected_high);
            end;
            WriteGPR(gpr_destination, value);
        when TileOperation_TCMPS =>
            let source = BundleTileSourceIndex(0, FALSE);
            let scalar = ReadScalarRegisterOperand(
                _BundleScalarBindings[[0]].source0);
            let gpr_destination = _BundleScalarBindings[[0]].destination
                as GPRIndex;
            var value = TileCompareCUBEScalarToGPRAs(
                source, scalar,
                BundleComparisonCodeAsTileComparison(), selected_high,
                operation_type);
            if _BundleExecutionMask.valid then
                let old_value = ReadGPR(gpr_destination);
                let tile = _Tiles[[source]];
                value = TileExecutionMaskPredicateGPRResult(
                    value, old_value, operation_type, tile.layout,
                    tile.valid_rows as integer {1..65535},
                    tile.valid_columns as integer {1..65535}, selected_high);
            end;
            WriteGPR(gpr_destination, value);
        otherwise => return FALSE;
    end;
    return TRUE;
end;
