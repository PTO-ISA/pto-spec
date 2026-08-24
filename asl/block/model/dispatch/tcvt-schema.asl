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
    if !TileSourceContentsDefined(source) ||
       !TileSourceEncodingsValid(source) then
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

    let private_cube_source =
        _Tiles[[source]].location == TileLocation_Matrix;
    if private_cube_source != CurrentBundleCanonicalize() then
        return FALSE;
    end;
    if private_cube_source then
        return CurrentBundleDataLayout() == TileDataLayout_NORM &&
               _Tiles[[source]].layout == TileLayout_RowMajor;
    end;
    return _Tiles[[source]].layout == CurrentBundleTileSourceLayout();
end;
