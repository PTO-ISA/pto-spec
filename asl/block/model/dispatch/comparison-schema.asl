// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","surface":"block","classification":["model","dispatch","comparison-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedTCMPSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCMP;
end;

pure func TileOperationUsesClosedTSELSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TSEL;
end;

pure func TileOperationUsesClosedComparisonSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedTCMPSchema(operation) ||
           TileOperationUsesClosedTSELSchema(operation);
end;

readonly func SelectedBundleComparisonDimensionsLegal() => boolean
begin
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
    return TRUE;
end;

readonly func SelectedBundleComparisonShapeMatches(
    source: TileIndex) => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns;
    return _Tiles[[source]].valid_rows == valid_rows &&
           _Tiles[[source]].valid_columns == valid_columns &&
           _Tiles[[source]].columns == columns;
end;

readonly func SelectedBundleClosedTCMPSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCMPSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       !binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;
    if UInt(_BundleDataAttributes.comparison_mode) > 5 then
        return FALSE;
    end;

    let source_left = BundleTileSourceIndex(0, FALSE);
    let source_right = BundleTileSourceIndex(0, TRUE);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileCompareDataTypeSupported(data_type) &&
           TileShapeAndTypeMatch(source_left, source_right) &&
           _Tiles[[source_left]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source_left]].data_type == data_type &&
           _Tiles[[source_left]].layout == TileLayout_RowMajor &&
           TileSourceContentsDefined(source_left) &&
           TileSourceContentsDefined(source_right) &&
           TileSourceEncodingsValid(source_left) &&
           TileSourceEncodingsValid(source_right) &&
           SelectedBundleComparisonShapeMatches(source_left);
end;

readonly func SelectedBundleClosedTSELSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 2 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let inputs = _BundleTileBindings[[0]];
    let result = _BundleTileBindings[[1]];
    if inputs.destination_valid ||
       !inputs.source0_valid ||
       !inputs.source1_valid ||
       inputs.last ||
       !result.destination_valid ||
       result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(1) ||
       !result.source0_valid ||
       result.source1_valid ||
       !result.last then
        return FALSE;
    end;

    let mask = BundleTileSourceIndex(0, FALSE);
    let source_true = BundleTileSourceIndex(0, TRUE);
    let source_false = BundleTileSourceIndex(1, FALSE);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileSelectDataTypeSupported(data_type) &&
           TilePredicateValuesLegal(mask) &&
           TileShapeAndTypeMatch(source_true, source_false) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source_true]].data_type == data_type &&
           _Tiles[[source_true]].layout == TileLayout_RowMajor &&
           TileSourceContentsDefined(source_true) &&
           TileSourceContentsDefined(source_false) &&
           TileLogicalShapeMatch(mask, source_true) &&
           SelectedBundleComparisonShapeMatches(source_true);
end;
