// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","surface":"block","classification":["model","dispatch","destination-shape"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}

pure func SmallestTilePhysicalColumns(
    valid_columns: integer {1..65535}) => integer {0..65535}
begin
    var columns: integer = 1;
    for exponent = 0 to 15 do
        if valid_columns <= columns then
            return columns as integer {1..32768};
        end;
        columns = columns * 2;
    end;
    return 0;
end;
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

readonly func BundleGroupMaxColumns(columns: integer {0..65535})
                                      => integer {0..65535}
begin
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    if !_BundleFixedPointAttributes.group_max_en || group_n == 0 then
        return columns;
    end;
    return ((columns + (group_n - 1)) DIVRM group_n)
        as integer {0..65535};
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
    var required_capacity: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
            !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            required_capacity = required_capacity +
                TileCoreAllocationBytes(
                    _BundleTileBindings[[binding]].pe_mask,
                    BundleTileDestinationSizeBytes(
                        binding as BundleTileBindingIndex));
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
    if CoreTileCapacityInUse() + required_capacity >
       TileCapacityLimitBytes() then
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
                shape_source = _BundleTileBindings[[binding]].source0;
                shape_source_valid = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                shape_source = _BundleTileBindings[[binding]].source1;
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
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            let rows = DerivedTileRows(capacity_bytes, auxiliary_columns,
                destination_type);
            if !TileDescriptorShapeLegal(capacity_bytes, auxiliary_columns,
                   valid_rows, auxiliary_valid_columns, destination_type) ||
               rows * auxiliary_columns > PTO_MODEL_TILE_ELEMENTS then
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
            let capacity_bytes = BundleTileDestinationSizeBytes(
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
    let capacity_bytes = BundleTileDestinationSizeBytes(
        destination_binding);
    if source_tile.storage_kind != TileStorage_Numeric ||
       source_tile.rows * source_tile.columns > PTO_MODEL_TILE_ELEMENTS ||
       PredicateTileStorageBytes(
           source_tile.rows,
           source_tile.columns) > capacity_bytes then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if CoreTileCapacityInUse() + TileCoreAllocationBytes(
           binding.pe_mask,
           capacity_bytes) > TileCapacityLimitBytes() then
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

func ResolveBundleTMATMULDestination(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
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
    let output_type = if
        UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 then
        accumulator_type
    else
        BundleFPATROutputType(
            _BundleFixedPointAttributes.pre_quant_mode);
    let capacity_bytes = BundleTileDestinationSizeBytes(destination_binding);
    let rows = DerivedTileRows(capacity_bytes, n, output_type);
    if !TileDescriptorShapeLegal(
           capacity_bytes, n, m, n, output_type) ||
       !IsNonzeroPowerOfTwo(rows) || rows * n > PTO_MODEL_TILE_ELEMENTS then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    // The generic reservation pass allocates a fresh register and accounts
    // for the exact B.IOT capacity.  Supported TMATMUL inputs are never wider
    // than their FP32/S32/U32 result, so its preliminary AType descriptor is
    // no stricter than the result descriptor validated above.
    if !ResolveBundleTileDestinationsWithShape(TRUE, m, n, n) then
        return FALSE;
    end;
    return TRUE;
end;
