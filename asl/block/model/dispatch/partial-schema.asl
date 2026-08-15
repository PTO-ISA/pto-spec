// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-PARTIAL-SCHEMA","surface":"block","classification":["model","dispatch","partial-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"]}

pure func TileOperationUsesClosedPartialSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TPARTADD ||
           decoded == TileOperation_TPARTMUL ||
           decoded == TileOperation_TPARTMAX ||
           decoded == TileOperation_TPARTMIN;
end;

readonly func BundlePartialSourceAt(
    ordinal: integer {0..1}) => TileIndex
begin
    var current: integer {0..2} = 0;
    var selected: TileIndex = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if current == ordinal then
                    selected = _BundleTileBindings[[binding]].source0;
                end;
                current = (current + 1) as integer {0..2};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if current == ordinal then
                    selected = _BundleTileBindings[[binding]].source1;
                end;
                current = (current + 1) as integer {0..2};
            end;
        end;
    end;
    return selected;
end;

readonly func BundlePartialDestinationsLegal() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           (_BundleTileBindings[[binding]].destination_allocated_by_bundle ||
            !BundleTileDestinationSizeLegal(
                binding as BundleTileBindingIndex)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func SelectedBundleClosedPartialSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedPartialSchema(operation) then return TRUE; end;
    if BundleLocalTileSourceCount() != 2 ||
       BundleLocalTileDestinationCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid ||
       _BundleDataAttributesPresent ||
       !BundleTileBindingStreamTerminated() ||
       !BundlePartialDestinationsLegal() ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns;
    if columns < valid_columns || columns > 65535 then return FALSE; end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TilePartialDataTypeSupported(data_type) ||
       CurrentBundleTileLayout() != TileLayout_RowMajor then
        return FALSE;
    end;
    let source_left = BundlePartialSourceAt(0);
    let source_right = BundlePartialSourceAt(1);
    if !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) ||
       _Tiles[[source_left]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source_right]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source_left]].data_type != data_type ||
       _Tiles[[source_right]].data_type != data_type ||
       _Tiles[[source_left]].layout != TileLayout_RowMajor ||
       _Tiles[[source_right]].layout != TileLayout_RowMajor ||
       _Tiles[[source_left]].valid_rows == 0 ||
       _Tiles[[source_left]].valid_columns == 0 ||
       _Tiles[[source_right]].valid_rows == 0 ||
       _Tiles[[source_right]].valid_columns == 0 ||
       _Tiles[[source_left]].valid_rows > valid_rows ||
       _Tiles[[source_left]].valid_columns > valid_columns ||
       _Tiles[[source_right]].valid_rows > valid_rows ||
       _Tiles[[source_right]].valid_columns > valid_columns ||
       !TileSourceContentsDefined(source_left) ||
       !TileSourceContentsDefined(source_right) then
        return FALSE;
    end;
    let left_covers =
        _Tiles[[source_left]].valid_rows == valid_rows &&
        _Tiles[[source_left]].valid_columns == valid_columns;
    let right_covers =
        _Tiles[[source_right]].valid_rows == valid_rows &&
        _Tiles[[source_right]].valid_columns == valid_columns;
    if !left_covers && !right_covers then return FALSE; end;
    return !TileDataTypeIsFloating(data_type) ||
           (TileSourceEncodingsValid(source_left) &&
            TileSourceEncodingsValid(source_right));
end;
