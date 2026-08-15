// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA","surface":"block","classification":["model","dispatch","sorting-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-SORTING"]}

pure func TileOperationUsesClosedSortingSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TSORT ||
           decoded == TileOperation_TMRGSORT;
end;

readonly func BundleSortingSourceAt(
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

readonly func BundleSortingDescending(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleScalarBindings[[0]].valid then return FALSE; end;
    let slot = BundleOperationGPRInputSlot(operation, TileOperand_flag0);
    let raw = ReadScalarRegisterOperand(
        BundleOperationGPRInputSelector(slot as integer {0..2}));
    return UInt(raw) == 1;
end;

readonly func BundleSortingDestinationsLegal() => boolean
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

readonly func SelectedBundleClosedSortingSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedSortingSchema(operation) then return TRUE; end;
    let decoded = TileOperationOfIndex(operation);
    let tsort = decoded == TileOperation_TSORT;
    let expected_sources: integer = if tsort then 1 else 2;
    let expected_destinations: integer = if tsort then 2 else 1;
    if BundleSharedBindingCount() != 0 ||
       BundleLocalTileSourceCount() != expected_sources ||
       BundleLocalTileDestinationCount() != expected_destinations ||
       !BundleTileBindingStreamTerminated() ||
       !BundleSortingDestinationsLegal() then
        return FALSE;
    end;

    if tsort then
        if _BundleDimensionPresent[[1]] || _BundleDimensionPresent[[2]] then
            return FALSE;
        end;
        if _BundleDimensionPresent[[0]] &&
           UInt(_BundleDimensions[[0]]) > 64 then
            return FALSE;
        end;
    elsif _BundleDimensionPresent[[0]] ||
          _BundleDimensionPresent[[1]] ||
          _BundleDimensionPresent[[2]] then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileSortDataTypeSupported(data_type) ||
       CurrentBundleTileLayout() != TileLayout_RowMajor then
        return FALSE;
    end;

    let source_left = BundleSortingSourceAt(0);
    if !TileDescriptorLegal(source_left) ||
       _Tiles[[source_left]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source_left]].data_type != data_type ||
       _Tiles[[source_left]].layout != TileLayout_RowMajor ||
       _Tiles[[source_left]].valid_rows == 0 ||
       _Tiles[[source_left]].valid_columns == 0 ||
       !TileSortSourceValuesLegal(source_left) then
        return FALSE;
    end;
    if tsort then return TRUE; end;

    let source_right = BundleSortingSourceAt(1);
    if !TileDescriptorLegal(source_right) ||
       _Tiles[[source_right]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source_right]].data_type != data_type ||
       _Tiles[[source_right]].layout != TileLayout_RowMajor ||
       _Tiles[[source_left]].valid_rows != 1 ||
       _Tiles[[source_right]].valid_rows != 1 ||
       _Tiles[[source_right]].valid_columns == 0 ||
       !TileSortSourceValuesLegal(source_right) then
        return FALSE;
    end;
    let output_columns =
        _Tiles[[source_left]].valid_columns +
        _Tiles[[source_right]].valid_columns;
    if output_columns > 32768 then return FALSE; end;

    let descending = BundleSortingDescending(operation);
    return TileSortSequenceOrdered(source_left, descending) &&
           TileSortSequenceOrdered(source_right, descending);
end;
