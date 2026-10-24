// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION","surface":"block","classification":["model","dispatch","tlsu-layout-conversion"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}

readonly func BundleCubeTransportSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid || !_BundleDataAttributesPresent then
        return FALSE;
    end;
    // Function-2 TMOV owns its CUBE-to-Shared-ND conversion selectors.
    if BundleTMOVSelected() then return FALSE; end;
    // Route every conversion-only selector through the owning CUBE
    // transport schema. That schema rejects an opposite function/direction
    // pair before generic layout derivation can reach its conversion-only
    // unreachable.
    return TileDataLayoutIsCubeConversion(
        _BundleDataAttributes.data_layout);
end;

pure func BundleCubeTransportDataTypeSupported(
    data_type: TileDataType, layout: TileLayout, function: integer {0..31})
    => boolean
begin
    // HiF4X2 is accepted only by the Matrix-MX input-role contract.  U64 is
    // the single descriptor-level exception, and only ND2N8 TLOAD may create
    // that Local CUBE_N8 representation.
    if layout == TileLayout_CUBE_M32 &&
       TileCubeM32B64DataType(data_type) then
        return function == 0 || function == 1;
    end;
    if data_type == TileDataType_U64 then
        return function == 0 && layout == TileLayout_CUBE_N8;
    end;
    return TileCubeLayoutDataTypeSupported(layout, data_type) &&
           data_type != TileDataType_HiF4X2;
end;

readonly func BundleCubeTransportDimensionsLegal() => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    return 1 <= valid_columns && valid_columns <= 65535 &&
           1 <= valid_rows && valid_rows <= 65535 &&
           UInt(_BundleDimensions[[2]]) == 1;
end;

readonly func BundleCubeTransportDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent ||
       _BundleDataAttributes.data_type != DTYPE_NONE ||
       !TileDataLayoutIsCubeConversion(
           _BundleDataAttributes.data_layout) ||
       _BundleDataAttributes.comparison_mode != Zeros{3} ||
       _BundleDataAttributes.rounding_mode != Zeros{3} ||
       _BundleDataAttributes.saturating ||
       _BundleDataAttributes.canonicalize then
        return FALSE;
    end;
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    if function == 0 then
        return TileDataLayoutConversionIsLoad(
            _BundleDataAttributes.data_layout);
    elsif function == 1 then
        return TileDataLayoutConversionIsStore(
            _BundleDataAttributes.data_layout);
    end;
    return FALSE;
end;

readonly func BundleCubeTransportBindingsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if BundleSharedBindingCount() != 0 ||
       BundleTileBindingCount() != 1 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationScalarBindingSchemaLegal(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.valid || !binding.last then return FALSE; end;
    if function == 0 then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               (binding.source0_valid == execution_mask_tile) &&
               !binding.source1_valid &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 0);
    elsif function == 1 then
        return !binding.destination_valid &&
               binding.source0_valid &&
               (binding.source1_valid == execution_mask_tile) &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 1);
    end;
    return FALSE;
end;

func ResolveBundleCubeTransportDestination(
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let binding = _BundleTileBindings[[0]];
    let capacity_bytes = BundleTileDestinationSizeBytes(0);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        let local_generation = binding.destination_assemble.valid;
        let parent_rows = if layout == TileLayout_CUBE_M16 then 16 else 32;
        let parent_columns = TileCubePhysicalColumnsFromCapacity(
            capacity_bytes, layout, data_type);
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           (if local_generation then
                destination.rows != parent_rows ||
                destination.columns != parent_columns
            else
                destination.valid_rows != valid_rows ||
                destination.valid_columns != valid_columns) ||
           destination.data_type != data_type ||
           destination.layout != layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(capacity_bytes, valid_rows,
           valid_columns, data_type, layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let hand = UInt(binding.destination_hand);
    var destination: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            destination = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found || !ConfigureCubeTileForMask(
           destination, capacity_bytes, valid_rows, valid_columns,
           data_type, layout, binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = destination;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;

func ExecuteBundleCubeTransportOperation() => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var result_writer_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    // A zero Local mask is resolved before every schema, GPR, descriptor,
    // allocation, and memory check.
    if SelectedBundleTileMaskIsZero() then return (TRUE, result_writer_effects); end;
    let decoded = DecodeTileOperation(
        TileDecode_TLSU, BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleCubeTransportDimensionsLegal() ||
       !BundleCubeTransportDataAttributesLegal() ||
       !BundleExecutionMaskDataAttributesLegal(operation) ||
       !BundleCubeTransportBindingsLegal(operation) ||
       _BundleFixedPointAttributes.valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let (type_valid, data_type) = ResolveBundleEffectiveDataType();
    let layout = TileDataLayoutCubeLayout(
        _BundleDataAttributes.data_layout);
    let function = UInt(_BundleOperation.selector[4:0]);
    if !type_valid || !BundleCubeTransportDataTypeSupported(
           data_type, layout, function) then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]])
        as integer {1..65535};
    let base_address = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0)
        else Zeros{PTO_XLEN};
    let row_stride_bytes = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source1)
        else TileDenseRowStrideBytes(valid_columns, data_type);
    if function == 0 then
        if !ResolveBundleCubeTransportDestination(
               valid_rows, valid_columns, data_type, layout) then
            return (FALSE, result_writer_effects);
        end;
        let (writer_effects_legal, writer_effects) =
            BeginBundleLocalGenerationCubeWriterEffects(
                valid_rows, valid_columns);
        if !writer_effects_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            RollBackBundleTileDestinations();
            return (FALSE, result_writer_effects);
        end;
        if !ValidateBundleLocalGenerationWritersWithWriterEffects(
               writer_effects) then
            RollBackBundleTileDestinations(); return (FALSE, result_writer_effects);
        end;
        let destination = _BundleTileBindings[[0]].destination;
        if writer_effects.count != 0 then
            let writer_effect = writer_effects.entries[[0]];
            let result = TLOADToValue(writer_effect.writer,
                base_address, row_stride_bytes);
            let updated_effects =
                BundleLocalGenerationCubeWriterEffectWithOutput(
                    writer_effects, writer_effect.destination, result);
            result_writer_effects = updated_effects;
            FinishBundleLocalGenerationCubeWriterEffects(updated_effects);
        else
            TLOAD(destination, base_address, row_stride_bytes);
            result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
        end;
        if _LastFault != Fault_None then
            // A memory fault retains the beats completed before it but must
            // not publish the speculative Local destination.  Release it and
            // re-synchronize the saved trap context exactly like the generic
            // destination path does.
            RollBackBundleTileDestinations();
            return (FALSE, result_writer_effects);
        end;
    else
        let source = _BundleTileBindings[[0]].source0;
        let tile = _Tiles[[source]];
        if !TileCubeDescriptorLegal(tile) ||
           !TileElementwiseSourceContentsDefined(source) ||
           tile.data_type != data_type || tile.layout != layout ||
           tile.valid_rows != valid_rows ||
           tile.valid_columns != valid_columns ||
           (_TileAllocationMasks[[source]] AND
               _BundleTileBindings[[0]].pe_mask) !=
               _BundleTileBindings[[0]].pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
        TSTORE(base_address, row_stride_bytes, source);
        if _LastFault != Fault_None then
            RollBackBundleTileDestinations();
            return (FALSE, result_writer_effects);
        end;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return (TRUE, result_writer_effects);
end;
