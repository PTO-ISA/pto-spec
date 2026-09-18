// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","surface":"block","classification":["model","dispatch","tcvt-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedTCVTSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCVT;
end;

readonly func SelectedBundleClosedTCVTSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCVTSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;
    if UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if UInt(_BundleDimensions[[dimension]]) < 1 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;

    let source = BundleTileSourceIndex(0, FALSE);
    let source_operation_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    // CUBE M-layout sources are private matrix operands: their backing type
    // must match the operation type. An ordinary source backing type MAY
    // differ only for a same-width non-packed carrier.
    if (_Tiles[[source]].layout == TileLayout_CUBE_M16 ||
        _Tiles[[source]].layout == TileLayout_CUBE_M32) &&
       _Tiles[[source]].data_type != source_operation_type then
        return FALSE;
    end;
    if !TileTCVTSourceEncodingsValidAs(source, source_operation_type) then
        return FALSE;
    end;
    let (destination_type_valid, destination_type) =
        ResolveBundleEffectiveDataType();
    if !destination_type_valid ||
       !HardwareTCVTTypePairSupported(
           source_operation_type, destination_type) then
        return FALSE;
    end;
    // E6M2 and RCPE6M2 have a closed RNE/RNA profile. Resolve the operation
    // default here, while the bundle is still in schema preflight, so an
    // unsupported mode cannot reach destination allocation or effects. The
    // operand legality check repeats this rule after decoded operands exist.
    let rounding_selection = DecodeBundleRoundingSelection(
        _BundleDataAttributes.rounding_mode);
    let resolved_rounding_mode = if
        rounding_selection.use_operation_default then NumericRound_RNE
        else rounding_selection.rounding_mode;
    if !HardwareTCVTRoundingModeSupported(
           source_operation_type, destination_type,
           resolved_rounding_mode) then
        return FALSE;
    end;

    let source_layout = _Tiles[[source]].layout;
    let requested_valid_columns = UInt(_BundleDimensions[[0]]);
    let requested_valid_rows = UInt(_BundleDimensions[[1]]);
    let source_cube_m_layout =
        source_layout == TileLayout_CUBE_M16 ||
        source_layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        // CUBE_M16/M32 TCVT keeps the same CUBE layout and valid region.
        // Destination physical geometry is derived later from the selected
        // destination type and the requested TSize.
        return requested_valid_columns == _Tiles[[source]].valid_columns &&
               requested_valid_rows == _Tiles[[source]].valid_rows &&
               UInt(_BundleDimensions[[2]]) == 1 &&
               !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               TileCubeDescriptorShapeLegal(
                   _Tiles[[source]].capacity_bytes,
                   _Tiles[[source]].valid_rows,
                   _Tiles[[source]].valid_columns,
                   source_operation_type, source_layout) &&
               TileCubeDataTypeSupported(destination_type);
    end;
    if TileLayoutIsCube(source_layout) then
        return FALSE;
    end;

    let requested_columns = UInt(_BundleDimensions[[2]]);
    let destination_capacity = BundleLocalDestinationAllocationBytes(0);
    let destination_rows = DerivedTileRows(
        destination_capacity,
        requested_columns as integer {1..65535},
        destination_type);
    let odd_physical_profile =
        !IsNonzeroPowerOfTwo(requested_columns as integer {1..65535}) &&
        TileDataTypeAllowsOddPhysicalColumns(source_operation_type) &&
        TileDataTypeAllowsOddPhysicalColumns(destination_type);
    let destination_physical_shape_legal = if odd_physical_profile then
        TileStorageFitsCapacity(
            _Tiles[[source]].rows,
            requested_columns as integer {1..65535},
            destination_type, destination_capacity)
    else destination_rows == _Tiles[[source]].rows;
    if requested_valid_columns != _Tiles[[source]].valid_columns ||
       requested_valid_rows != _Tiles[[source]].valid_rows ||
       requested_columns != _Tiles[[source]].columns ||
       !destination_physical_shape_legal then
        return FALSE;
    end;

    if CurrentBundleCanonicalize() then
        return FALSE;
    end;
    return source_layout == CurrentBundleTileSourceLayout();
end;
