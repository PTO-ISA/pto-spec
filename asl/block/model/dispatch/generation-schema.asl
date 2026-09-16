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
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCI then
        if !_BundleDimensionPresent[[0]] ||
           UInt(_BundleDimensions[[0]]) < 1 ||
           UInt(_BundleDimensions[[0]]) > 65535 then
            return FALSE;
        end;
        let data_type = TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding);
        if !TileTCIDataTypeSupported(data_type) then return FALSE; end;
        let layout = CurrentBundleTileLayout();
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = if _BundleDimensionPresent[[2]] then
            UInt(_BundleDimensions[[2]])
        else if layout == TileLayout_CUBE_M16 ||
              layout == TileLayout_CUBE_M32 then
            TileCubeAlignedExtent(valid_columns,
                TileCubeCellColumns(layout, data_type) as integer {1..65535})
        else
            valid_columns;
        if valid_rows < 1 || valid_rows > 65535 ||
           columns < valid_columns || columns > 65535 then
            return FALSE;
        end;
        if layout == TileLayout_CUBE_M16 then
            if valid_rows > 16 then return FALSE; end;
            let cell_columns = TileCubeCellColumns(layout, data_type);
            if cell_columns == 0 then return FALSE; end;
            return columns MOD (cell_columns as integer {1..65535}) == 0;
        elsif layout == TileLayout_CUBE_M32 then
            let cell_columns = TileCubeCellColumns(layout, data_type);
            if cell_columns == 0 then return FALSE; end;
            return columns MOD (cell_columns as integer {1..65535}) == 0;
        end;
        return layout == TileLayout_RowMajor && valid_rows == 1;
    end;
    if decoded != TileOperation_TTRI then
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]])
    else
        valid_columns;
    if valid_columns < 1 || valid_columns > 65535 ||
       columns < valid_columns || columns > 65535 then
        return FALSE;
    end;
    return UInt(_BundleDimensions[[1]]) >= 1 &&
           UInt(_BundleDimensions[[1]]) <= 65535;
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
    let layout = CurrentBundleTileLayout();
    return data_type_legal &&
           (layout == TileLayout_RowMajor ||
            (decoded == TileOperation_TCI &&
             (layout == TileLayout_CUBE_M16 ||
              layout == TileLayout_CUBE_M32)));
end;
