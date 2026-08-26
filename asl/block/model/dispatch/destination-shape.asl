// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","surface":"block","classification":["model","dispatch","destination-shape"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}

readonly func BundleDestinationValidRows(shape_source_valid: boolean,
                                         shape_source: TileIndex)
                                         => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB1);
    if UInt(_BundleDimensions[[index]]) >= 1 &&
       UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].valid_rows;
    elsif BundleSharedBindingCount() == 1 &&
          SharedTileDescriptorLegal(BundleSharedBindingId(0)) then
        return SharedTileRecord(BundleSharedBindingId(0)).tile.valid_rows;
    else
        return 1;
    end;
end;
readonly func BundleDestinationValidColumns(shape_source_valid: boolean,
                                            shape_source: TileIndex)
                                            => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB0);
    if UInt(_BundleDimensions[[index]]) >= 1 &&
       UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].valid_columns;
    elsif BundleSharedBindingCount() == 1 &&
          SharedTileDescriptorLegal(BundleSharedBindingId(0)) then
        return SharedTileRecord(BundleSharedBindingId(0)).tile.valid_columns;
    else
        return 1;
    end;
end;
readonly func BundleDestinationPhysicalColumns(shape_source_valid: boolean,
                                               shape_source: TileIndex)
                                               => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB2);
    if UInt(_BundleDimensions[[index]]) >= 1 &&
       UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].columns;
    elsif BundleSharedBindingCount() == 1 &&
          SharedTileDescriptorLegal(BundleSharedBindingId(0)) then
        return SharedTileRecord(BundleSharedBindingId(0)).tile.columns;
    else
        return BundleDestinationValidColumns(FALSE, 0);
    end;
end;
readonly func BundleLocalDestinationCapacityGroupFits() => boolean
begin
    var additional0: integer = 0;
    var additional1: integer = 0;
    var additional2: integer = 0;
    var additional3: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let capacity_bytes = BundleLocalDestinationAllocationBytes(
                binding as BundleTileBindingIndex);
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if mask[PTOPEMaskBitOfPEIdentity(0)] == '1' then
                additional0 = additional0 + capacity_bytes;
            end;
            if mask[PTOPEMaskBitOfPEIdentity(1)] == '1' then
                additional1 = additional1 + capacity_bytes;
            end;
            if mask[PTOPEMaskBitOfPEIdentity(2)] == '1' then
                additional2 = additional2 + capacity_bytes;
            end;
            if mask[PTOPEMaskBitOfPEIdentity(3)] == '1' then
                additional3 = additional3 + capacity_bytes;
            end;
        end;
    end;
    return TileCapacityInUseForPE(0) + additional0 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(1) + additional1 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(2) + additional2 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(3) + additional3 <=
               TileCapacityLimitBytes();
end;

func ResolveBundleTileDestinationsWithShapeAndType(
    explicit_shape: boolean,
    explicit_valid_rows: integer {0..65535},
    explicit_valid_columns: integer {0..65535},
    explicit_columns: integer {0..65535},
    explicit_primary_type: boolean,
    primary_type: TileDataType) => boolean
begin
    let (effective_type_valid, selected_type) =
        ResolveBundleEffectiveDataType();
    if !effective_type_valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BUNDLE_TILE_BINDING_COUNT]] of TileIndex;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
            !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let hand =
                UInt(_BundleTileBindings[[binding]].destination_hand);
            var found = FALSE;
            for offset = 0 to 15 do
                let raw_index: integer = hand * 16 + offset;
                if !found && !_Tiles[[raw_index]].allocated &&
                   !reserved[[raw_index]] then
                    resolved[[binding]] = raw_index as TileIndex;
                    reserved[[raw_index]] = TRUE;
                    found = TRUE;
                end;
            end;
            if !found then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    if !BundleLocalDestinationCapacityGroupFits() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let matrix_output_type = if matrix &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 then
        accumulator_type
    else if matrix then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else selected_type;
    let primary_output_type = if explicit_primary_type then
        primary_type
    else
        matrix_output_type;
    var shape_source_valid = FALSE;
    var shape_source: TileIndex = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !shape_source_valid && _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                shape_source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                shape_source_valid = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                shape_source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                shape_source_valid = TRUE;
            end;
        end;
    end;

    // Validate every derived descriptor before allocating any destination.
    // This preserves precise all-or-nothing B.IOT allocation when a size code
    // is too small for its logical shape.
    var destination_ordinal: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let valid_rows = if explicit_shape then explicit_valid_rows else
                BundleDestinationValidRows(shape_source_valid, shape_source);
            let valid_columns = if explicit_shape then
                explicit_valid_columns else BundleDestinationValidColumns(
                    shape_source_valid, shape_source);
            let columns = if explicit_shape then explicit_columns else
                BundleDestinationPhysicalColumns(
                    shape_source_valid, shape_source);
            let destination_type = if destination_ordinal == 0 then
                primary_output_type else if matrix then accumulator_type
                else TileDataType_U32;
            let auxiliary_row = matrix &&
                _BundleFixedPointAttributes.row_max_en &&
                destination_ordinal == 1;
            let auxiliary_group = matrix &&
                _BundleFixedPointAttributes.group_max_en &&
                ((!_BundleFixedPointAttributes.row_max_en &&
                  destination_ordinal == 1) ||
                 (_BundleFixedPointAttributes.row_max_en &&
                  destination_ordinal == 2));
            let auxiliary_columns = if auxiliary_row then 1
                else if auxiliary_group then
                    BundleGroupMaxColumns(columns)
                else columns;
            let auxiliary_valid_columns = if auxiliary_row then 1
                else if auxiliary_group then
                    BundleGroupMaxColumns(valid_columns)
                else valid_columns;
            let capacity_bytes = BundleLocalDestinationAllocationBytes(
                binding as BundleTileBindingIndex);
            let rows = DerivedTileRows(capacity_bytes, auxiliary_columns,
                destination_type);
            if !TileDescriptorShapeLegal(capacity_bytes, auxiliary_columns,
                   valid_rows, auxiliary_valid_columns, destination_type) ||
               rows * auxiliary_columns >
                   TileLogicalElementCapacity(capacity_bytes,
                       destination_type) then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;

    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let valid_rows = if explicit_shape then explicit_valid_rows else
                BundleDestinationValidRows(shape_source_valid, shape_source);
            let valid_columns = if explicit_shape then
                explicit_valid_columns else BundleDestinationValidColumns(
                    shape_source_valid, shape_source);
            let columns = if explicit_shape then explicit_columns else
                BundleDestinationPhysicalColumns(
                    shape_source_valid, shape_source);
            let destination_type = if destination_ordinal == 0 then
                primary_output_type else if matrix then accumulator_type
                else TileDataType_U32;
            let auxiliary_row = matrix &&
                _BundleFixedPointAttributes.row_max_en &&
                destination_ordinal == 1;
            let auxiliary_group = matrix &&
                _BundleFixedPointAttributes.group_max_en &&
                ((!_BundleFixedPointAttributes.row_max_en &&
                  destination_ordinal == 1) ||
                 (_BundleFixedPointAttributes.row_max_en &&
                  destination_ordinal == 2));
            let auxiliary_columns = if auxiliary_row then 1
                else if auxiliary_group then
                    BundleGroupMaxColumns(columns)
                else columns;
            let auxiliary_valid_columns = if auxiliary_row then 1
                else if auxiliary_group then
                    BundleGroupMaxColumns(valid_columns)
                else valid_columns;
            let capacity_bytes = BundleLocalDestinationAllocationBytes(
                binding as BundleTileBindingIndex);
            ConfigureTileForMask(resolved[[binding]],
                capacity_bytes, valid_rows, auxiliary_columns, valid_rows,
                auxiliary_valid_columns, destination_type,
                CurrentBundleTileLayout(), TileLocation_Any,
                _BundleTileBindings[[binding]].pe_mask);
            _BundleTileBindings[[binding]].destination = resolved[[binding]];
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                TRUE;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    return TRUE;
end;

func ResolveBundleTileDestinationsWithShape(
    explicit_shape: boolean,
    explicit_valid_rows: integer {0..65535},
    explicit_valid_columns: integer {0..65535},
    explicit_columns: integer {0..65535}) => boolean
begin
    return ResolveBundleTileDestinationsWithShapeAndType(
        explicit_shape,
        explicit_valid_rows,
        explicit_valid_columns,
        explicit_columns,
        FALSE,
        TileDataType_FP64);
end;

func ResolveBundleTileDestinations() => boolean
begin
    return ResolveBundleTileDestinationsWithShape(FALSE, 0, 0, 0);
end;

func ResolveBundlePredicateDestination() => boolean
begin
    var destination_binding: BundleTileBindingIndex = 0;
    var destination_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !destination_seen &&
           _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            destination_binding = binding as BundleTileBindingIndex;
            destination_seen = TRUE;
        end;
    end;
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;

    let binding = _BundleTileBindings[[destination_binding]];
    let source = binding.source0;
    let source_tile = _Tiles[[source]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    if source_tile.storage_kind != TileStorage_Numeric ||
       source_tile.rows * source_tile.columns >
           TileLogicalElementCapacity(source_tile.capacity_bytes,
               source_tile.data_type) ||
       PredicateTileStorageBytes(
           source_tile.rows,
           source_tile.columns) > capacity_bytes then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let hand = UInt(binding.destination_hand);
    var resolved: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            resolved = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    ConfigurePredicateTileForMask(
        resolved,
        capacity_bytes,
        source_tile.rows,
        source_tile.columns,
        source_tile.valid_rows,
        source_tile.valid_columns,
        binding.pe_mask);
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;

func ResolveBundleTileDestinationsForOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // CUBE matrix handlers own the primary CUBE destination shape and
    // atomic allocation group.  Leave the binding unresolved here so the
    // selected handler can apply its authoritative M/N/layout/type rules;
    // the generic RowMajor resolver would mark the destination as already
    // allocated and prevent that conversion.
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix then
        return TRUE;
    end;
    let decoded_operation = TileOperationOfIndex(operation);
    if decoded_operation == TileOperation_TPERMUTE ||
       decoded_operation == TileOperation_TSHUF ||
       decoded_operation == TileOperation_TPACK ||
       decoded_operation == TileOperation_TUNPACK then
        return ResolveBundleCellRearrangementDestination();
    end;
    if TileOperationOfIndex(operation) == TileOperation_TIMG2COL then
        let resolved = ResolveBundleTileDestinations();
        if resolved then
            MarkBundleTIMG2COLDestinationsMatrix();
        end;
        return resolved;
    end;
    if TileOperationOfIndex(operation) == TileOperation_TCONCAT then
        let (legal, valid_rows, valid_columns, physical_columns,
             data_type) = BundleTCONCATDestinationShape();
        if !legal then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, physical_columns,
            TRUE, data_type);
    end;
    if TileOperationUsesClosedSortingSchema(operation) then
        let decoded = TileOperationOfIndex(operation);
        let source_left = BundleSortingSourceAt(0);
        if decoded == TileOperation_TSORT then
            let source = _Tiles[[source_left]];
            return ResolveBundleTileDestinationsWithShapeAndType(
                TRUE,
                source.valid_rows,
                source.valid_columns,
                source.columns,
                TRUE,
                source.data_type);
        end;
        let source_right = BundleSortingSourceAt(1);
        let output_columns =
            _Tiles[[source_left]].valid_columns +
            _Tiles[[source_right]].valid_columns;
        if output_columns < 1 || output_columns > 32768 then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
        let physical_columns = SmallestTilePhysicalColumns(
            output_columns as integer {1..65535});
        if physical_columns == 0 then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE,
            1,
            output_columns as integer {1..65535},
            physical_columns,
            TRUE,
            _Tiles[[source_left]].data_type);
    end;
    if TileOperationUsesClosedHistogramSchema(operation) then
        let source = _BundleTileBindings[[0]].source0;
        return ResolveBundleTileDestinationsWithShape(
            TRUE,
            _Tiles[[source]].valid_rows,
            256,
            256);
    end;
    if TileOperationUsesClosedReductionSchema(operation) then
        let source = _BundleTileBindings[[0]].source0;
        let source_tile = _Tiles[[source]];
        let row_reduction =
            TileOperationUsesClosedRowReductionSchema(operation);
        let destination_type =
            if TileReductionOperationReturnsIndex(operation) then
                TileDataType_U32
            else
                source_tile.data_type;
        let valid_rows =
            if row_reduction then source_tile.valid_rows else 1;
        let valid_columns =
            if row_reduction then 1 else source_tile.valid_columns;
        let columns =
            if row_reduction then 1 else source_tile.columns;
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE,
            valid_rows,
            valid_columns,
            columns,
            TRUE,
            destination_type);
    end;
    if TileOperationUsesClosedTCMPSchema(operation) ||
       TileOperationUsesClosedTCMPSSchema(operation) then
        return ResolveBundlePredicateDestination();
    end;
    if TileExpansionOperationIsExponentialDifference(operation) then
        let (types_legal, -, destination_type) =
            SelectedBundleExpansionExponentialDifferenceTypes();
        if !types_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = if _BundleDimensionPresent[[1]] then
            UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
        let columns = if _BundleDimensionPresent[[2]] then
            UInt(_BundleDimensions[[2]]) as integer {1..65535}
            else valid_columns;
        return ResolveBundleTileDestinationsWithShapeAndType(
            TRUE, valid_rows, valid_columns, columns,
            TRUE, destination_type);
    end;
    if !TileOperationUsesClosedBinarySchema(operation) &&
       !TileOperationUsesClosedUnarySchema(operation) &&
       !TileOperationUsesClosedTFMASchema(operation) &&
       !TileOperationUsesClosedQuantizationSchema(operation) &&
       !TileOperationUsesClosedGenerationSchema(operation) &&
       !TileOperationUsesClosedExpansionSchema(operation) &&
       !TileOperationUsesClosedTCVTSchema(operation) &&
       !TileOperationUsesClosedComparisonSchema(operation) &&
       !TileOperationUsesClosedTileScalarSchema(operation) then
        return ResolveBundleTileDestinations();
    end;
    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) as integer {1..65535}
        else valid_columns;
    return ResolveBundleTileDestinationsWithShape(
        TRUE, valid_rows, valid_columns, columns);
end;
