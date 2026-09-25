// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","surface":"block","classification":["model","dispatch","destination-shape"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func BundleDestinationValidRows(
    shape_source_valid: boolean, shape_source: TileIndex) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB1);
    if UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {0..65535};
    end;
    return 0;
end;
readonly func BundleDestinationValidColumns(
    shape_source_valid: boolean, shape_source: TileIndex) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB0);
    if UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {0..65535};
    end;
    return 0;
end;
readonly func BundleDestinationPhysicalColumns(
    shape_source_valid: boolean, shape_source: TileIndex) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB2);
    if !_BundleDimensionPresent[[index]] && _BundleOperation.valid then
        let decoded = DecodeTileOperation(
            BundleTileDecodeFamily(_BundleOperation.operation_class),
            BundleOperationDecodeCode(_BundleOperation));
        if decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationOfIndex(
               decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
               TileOperation_TCI &&
           (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
            CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
            let (type_valid, data_type) = ResolveBundleEffectiveDataType();
            if type_valid then
                let cell_columns = TileCubeCellColumns(CurrentBundleTileLayout(), data_type);
                if cell_columns != 0 then
                    return TileCubeAlignedExtent(
                        BundleDestinationValidColumns(shape_source_valid,
                            shape_source),
                        cell_columns as integer {1..65535});
                end;
            end;
        end;
        return BundleDestinationValidColumns(shape_source_valid, shape_source);
    end;
    if UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {0..65535};
    end;
    return 0;
end;
readonly func BundleReusedDestinationDescriptorMatches(
    binding: BundleTileBindingIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    columns: integer {0..65535}, data_type: TileDataType,
    layout: TileLayout, cube: boolean, exact_cube_columns: boolean,
    preserve_physical_rows: boolean, expected_physical_rows: integer {0..65535}) => boolean
begin
    let index = _BundleTileBindings[[binding]].destination;
    let destination = _Tiles[[index]];
    let mask_legal = (_TileAllocationMasks[[index]] AND
        _BundleTileBindings[[binding]].pe_mask) ==
        _BundleTileBindings[[binding]].pe_mask;
    if cube then
        return TileCubeDescriptorLegal(destination) &&
               destination.capacity_bytes == capacity_bytes &&
               destination.valid_rows == valid_rows &&
               destination.valid_columns == valid_columns &&
               (!exact_cube_columns || destination.columns == columns) &&
               destination.data_type == data_type &&
               destination.layout == layout && mask_legal;
    end;
    return TileDescriptorLegal(index) &&
           destination.storage_kind == TileStorage_Numeric &&
           destination.capacity_bytes == capacity_bytes &&
           destination.rows == (if preserve_physical_rows then expected_physical_rows else DerivedTileRows(capacity_bytes, columns, data_type)) &&
           destination.columns == columns &&
           destination.valid_rows == valid_rows &&
           destination.valid_columns == valid_columns &&
           destination.data_type == data_type &&
           destination.layout == layout && mask_legal;
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
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_reused_by_generation then
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
            !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
            !_BundleTileBindings[[binding]].destination_reused_by_generation then
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
    let decoded_operation = DecodeTileOperation(BundleTileDecodeFamily(_BundleOperation.operation_class), BundleOperationDecodeCode(_BundleOperation));
    let reduction_operation = if decoded_operation != PTO_TILE_OPERATION_COUNT then
        TileOperationUsesClosedReductionSchema(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1})
        else FALSE;
    let reduction_row = if decoded_operation != PTO_TILE_OPERATION_COUNT then
        TileOperationUsesClosedRowReductionSchema(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1})
        else FALSE;
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let matrix_output_type = if matrix then
        BundleFPATREffectiveDataType(
            _BundleFixedPointAttributes.pre_quant_mode, accumulator_type)
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
    // Validate every derived descriptor before allocating; preserve precise all-or-nothing B.IOT allocation when a size code is too small for its logical shape.
    var destination_ordinal: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            let valid_rows = if explicit_shape then explicit_valid_rows else
                BundleDestinationValidRows(shape_source_valid, shape_source);
            let valid_columns = if explicit_shape then
                explicit_valid_columns else BundleDestinationValidColumns(
                    shape_source_valid, shape_source);
            let columns = if explicit_shape then explicit_columns else
                BundleDestinationPhysicalColumns(
                    shape_source_valid, shape_source);
            let destination_layout = if decoded_operation != PTO_TILE_OPERATION_COUNT &&
                TileOperationOfIndex(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TGPR2T then
                if valid_rows == 32 then TileLayout_CUBE_M32 else TileLayout_CUBE_M16
            else CurrentBundleTileLayout();
            let destination_type = if destination_ordinal == 0 then
                primary_output_type else if matrix then matrix_output_type
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
            let capacity_bytes = BundleLocalDestinationAllocationBytes(binding as BundleTileBindingIndex);
            let reused = _BundleTileBindings[[binding]].destination_reused_by_generation;
            let cube_destination = destination_layout == TileLayout_CUBE_M16 ||
                destination_layout == TileLayout_CUBE_M32;
            let ordinary_tcvt = BundleDestinationIsOrdinaryTCVT(decoded_operation, cube_destination);
            let exact_cube_columns = cube_destination &&
                decoded_operation != PTO_TILE_OPERATION_COUNT &&
                TileOperationOfIndex(
                    decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
                    TileOperation_TCI;
            let source_geometry = if shape_source_valid then _Tiles[[shape_source]] else _Tiles[[0]];
            let physical_rows = if cube_destination then
                if reduction_operation && !reduction_row then source_geometry.rows
                else TileCubeStorageRows(destination_layout, valid_rows,
                    destination_type)
            else if ordinary_tcvt then source_geometry.rows else 0;
            let physical_columns = if cube_destination then
                if exact_cube_columns then auxiliary_columns
                else if reduction_operation && reduction_row then
                    source_geometry.columns
                else TileCubeStorageColumns(destination_layout,
                    auxiliary_valid_columns, destination_type)
            else auxiliary_columns;
            let rows = if ordinary_tcvt then source_geometry.rows else DerivedTileRows(capacity_bytes, auxiliary_columns, destination_type);
            let shape_legal = if cube_destination then
                TileCubeDescriptorShapeAndPhysicalLegal(capacity_bytes,
                    physical_rows, physical_columns, valid_rows,
                    auxiliary_valid_columns, destination_type,
                    destination_layout)
            else if ordinary_tcvt then
                TileDescriptorPhysicalShapeLegal(capacity_bytes, source_geometry.rows, auxiliary_columns, valid_rows, auxiliary_valid_columns, destination_type)
            else
                TileDescriptorShapeLegal(capacity_bytes, auxiliary_columns,
                    valid_rows, auxiliary_valid_columns, destination_type);
            if exact_cube_columns &&
               !TileCubeGeometryLegalWithColumns(valid_rows,
                   auxiliary_valid_columns, auxiliary_columns,
                   destination_type, destination_layout) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            if !shape_legal ||
               (!cube_destination && rows * auxiliary_columns >
                   TileLogicalElementCapacity(capacity_bytes,
                       destination_type)) then
                if reused then SetFault(Fault_TileLegality, ReadTPC());
                else SetFault(Fault_TileAllocation, ReadTPC()); end;
                return FALSE;
            end;
            if reused && !BundleReusedDestinationDescriptorMatches(
                   binding as BundleTileBindingIndex, capacity_bytes,
                   valid_rows, auxiliary_valid_columns, auxiliary_columns,
                   destination_type, destination_layout, cube_destination,
                   exact_cube_columns, ordinary_tcvt, source_geometry.rows) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                let valid_rows = if explicit_shape then explicit_valid_rows else
                    BundleDestinationValidRows(shape_source_valid, shape_source);
                let valid_columns = if explicit_shape then
                    explicit_valid_columns else BundleDestinationValidColumns(
                        shape_source_valid, shape_source);
                let destination_layout = if decoded_operation != PTO_TILE_OPERATION_COUNT &&
                    TileOperationOfIndex(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TGPR2T then
                    if valid_rows == 32 then TileLayout_CUBE_M32 else TileLayout_CUBE_M16
                else CurrentBundleTileLayout();
                let columns = if explicit_shape then explicit_columns else
                    BundleDestinationPhysicalColumns(
                        shape_source_valid, shape_source);
                let destination_type = if destination_ordinal == 0 then
                    primary_output_type else if matrix then matrix_output_type
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
                let capacity_bytes = BundleLocalDestinationAllocationBytes(binding as BundleTileBindingIndex);
                let tgpr2t = (decoded_operation != PTO_TILE_OPERATION_COUNT &&
                    TileOperationOfIndex(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TGPR2T) ||
                    destination_layout == TileLayout_CUBE_M16 ||
                    destination_layout == TileLayout_CUBE_M32;
                let exact_cube_columns = tgpr2t &&
                    decoded_operation != PTO_TILE_OPERATION_COUNT &&
                    TileOperationOfIndex(
                        decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
                        TileOperation_TCI;
                let source_geometry = if shape_source_valid then _Tiles[[shape_source]] else _Tiles[[0]];
                let ordinary_tcvt = BundleDestinationIsOrdinaryTCVT(decoded_operation, tgpr2t);
                let physical_rows = if destination_layout == TileLayout_CUBE_M16 ||
                    destination_layout == TileLayout_CUBE_M32 then
                    if reduction_operation && !reduction_row then
                        source_geometry.rows
                    else TileCubeStorageRows(destination_layout, valid_rows,
                        destination_type)
                else if ordinary_tcvt then source_geometry.rows else 0;
                let physical_columns = if destination_layout == TileLayout_CUBE_M16 ||
                    destination_layout == TileLayout_CUBE_M32 then
                    if exact_cube_columns then auxiliary_columns
                    else if reduction_operation && reduction_row then
                        source_geometry.columns
                    else TileCubeStorageColumns(destination_layout,
                        auxiliary_valid_columns, destination_type)
                else auxiliary_columns;
                if !ConfigureBundleTileDestination(resolved[[binding]],
                        capacity_bytes, physical_rows, physical_columns,
                        valid_rows, auxiliary_columns,
                        auxiliary_valid_columns, destination_type,
                        destination_layout, _BundleTileBindings[[binding]].pe_mask,
                        tgpr2t, exact_cube_columns, ordinary_tcvt) then
                    SetFault(Fault_TileAllocation, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].destination = resolved[[binding]];
                _BundleTileBindings[[binding]].destination_allocated_by_bundle = TRUE;
                if _BundleTileBindings[[binding]].destination_assemble.valid &&
                   _BundleTileBindings[[binding]].destination_assemble.init then
                    PublishRelativeTileDestination(resolved[[binding]]);
                end;
            end;
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
