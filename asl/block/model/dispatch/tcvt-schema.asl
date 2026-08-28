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
    if !_BundleDimensionPresent[[0]] ||
       UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) < 1 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;

    let source = BundleTileSourceIndex(0, FALSE);
    if !TileTCVTSourceContentsDefined(source) ||
       !TileTCVTSourceEncodingsValid(source) then
        return FALSE;
    end;
    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if _Tiles[[source]].data_type != source_type then return FALSE; end;
    let (destination_type_valid, destination_type) =
        ResolveBundleEffectiveDataType();
    if !destination_type_valid ||
       !HardwareTCVTTypePairSupported(source_type, destination_type) then
        return FALSE;
    end;

    let source_layout = _Tiles[[source]].layout;
    let source_cube_m_layout =
        source_layout == TileLayout_CUBE_M16 ||
        source_layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        // CUBE_M16/M32 TCVT keeps the same CUBE layout and valid region.
        // Destination physical geometry is derived later from the selected
        // destination type and the requested TSize.
        let requested_valid_columns = UInt(_BundleDimensions[[0]]);
        let requested_valid_rows = if _BundleDimensionPresent[[1]] then
            UInt(_BundleDimensions[[1]]) else 1;
        return requested_valid_columns == _Tiles[[source]].valid_columns &&
               requested_valid_rows == _Tiles[[source]].valid_rows &&
               !_BundleDimensionPresent[[2]] &&
               !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               _Tiles[[source]].location == TileLocation_Matrix &&
               TileCubeDescriptorShapeLegal(
                   _Tiles[[source]].capacity_bytes,
                   _Tiles[[source]].valid_rows,
                   _Tiles[[source]].valid_columns,
                   source_type, source_layout) &&
               TileCubeDataTypeSupported(destination_type);
    end;
    if TileLayoutIsCube(source_layout) then
        return FALSE;
    end;

    let private_cube_source =
        _Tiles[[source]].location == TileLocation_Matrix;
    if private_cube_source != CurrentBundleCanonicalize() then
        return FALSE;
    end;
    if private_cube_source then
        return CurrentBundleDataLayout() == TileDataLayout_NORM &&
               source_layout == TileLayout_RowMajor;
    end;
    return source_layout == CurrentBundleTileSourceLayout();
end;
