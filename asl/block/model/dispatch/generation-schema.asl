// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","surface":"block","classification":["model","dispatch","generation-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-EXECUTION-GENERATION"]}
pure func TileOperationUsesClosedGenerationSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCI ||
           decoded == TileOperation_TTRI;
end;

readonly func SelectedBundleGenerationDimensionsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleDimensionPresent[[0]] ||
       UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    if _BundleDimensionPresent[[2]] &&
       (UInt(_BundleDimensions[[2]]) < UInt(_BundleDimensions[[0]]) ||
        UInt(_BundleDimensions[[2]]) > 65535) then
        return FALSE;
    end;

    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCI then
        return !_BundleDimensionPresent[[1]] ||
               UInt(_BundleDimensions[[1]]) == 1;
    end;
    return !_BundleDimensionPresent[[1]] ||
           (UInt(_BundleDimensions[[1]]) >= 1 &&
            UInt(_BundleDimensions[[1]]) <= 65535);
end;

readonly func SelectedBundleClosedGenerationSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedGenerationSchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       binding.source0_valid ||
       binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;
    if !SelectedBundleGenerationDimensionsLegal(operation) then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let decoded = TileOperationOfIndex(operation);
    let data_type_legal = if decoded == TileOperation_TCI then
        TileTCIDataTypeSupported(data_type)
    else
        TileTTRIDataTypeSupported(data_type);
    return data_type_legal &&
           CurrentBundleTileLayout() == TileLayout_RowMajor;
end;
