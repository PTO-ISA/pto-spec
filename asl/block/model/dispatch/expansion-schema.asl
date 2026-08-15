// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","surface":"block","classification":["model","dispatch","expansion-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"]}

pure func TileOperationUsesClosedRowExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TROWEXPANDADD ||
           decoded == TileOperation_TROWEXPANDSUB ||
           decoded == TileOperation_TROWEXPANDMUL ||
           decoded == TileOperation_TROWEXPANDDIV ||
           decoded == TileOperation_TROWEXPANDMAX ||
           decoded == TileOperation_TROWEXPANDMIN ||
           decoded == TileOperation_TROWEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedColumnExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCOLEXPAND ||
           decoded == TileOperation_TCOLEXPANDADD ||
           decoded == TileOperation_TCOLEXPANDSUB ||
           decoded == TileOperation_TCOLEXPANDMUL ||
           decoded == TileOperation_TCOLEXPANDDIV ||
           decoded == TileOperation_TCOLEXPANDMAX ||
           decoded == TileOperation_TCOLEXPANDMIN ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedRowExpansionSchema(operation) ||
           TileOperationUsesClosedColumnExpansionSchema(operation);
end;

pure func TileExpansionOperationIsCopy(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TCOLEXPAND;
end;

pure func TileExpansionOperationIsExponentialDifference(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPANDEXPDIF ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

readonly func SelectedBundleExpansionBroadcastShapeMatches(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    broadcast: TileIndex) => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns;
    if TileOperationUsesClosedRowExpansionSchema(operation) then
        return _Tiles[[broadcast]].valid_rows == valid_rows &&
               _Tiles[[broadcast]].valid_columns == 1 &&
               _Tiles[[broadcast]].columns == 1;
    end;
    return _Tiles[[broadcast]].valid_rows == 1 &&
           _Tiles[[broadcast]].valid_columns == valid_columns &&
           _Tiles[[broadcast]].columns == columns;
end;

readonly func SelectedBundleClosedExpansionSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedExpansionSchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let copy = TileExpansionOperationIsCopy(operation);
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       binding.source1_valid != !copy ||
       !binding.last then
        return FALSE;
    end;

    let broadcast = if copy then
        binding.source0 else binding.source1;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    if !TileVecArithmeticDataTypeSupported(data_type) ||
       (TileExpansionOperationIsExponentialDifference(operation) &&
        !TileUnaryDataTypeSupported(TileUnary_EXP, data_type)) ||
       !TileDescriptorLegal(broadcast) ||
       _Tiles[[broadcast]].storage_kind != TileStorage_Numeric ||
       _Tiles[[broadcast]].data_type != data_type ||
       _Tiles[[broadcast]].layout != TileLayout_RowMajor ||
       !TileSourceContentsDefined(broadcast) ||
       !TileSourceEncodingsValid(broadcast) ||
       !SelectedBundleExpansionBroadcastShapeMatches(
           operation,
           broadcast) then
        return FALSE;
    end;

    if copy then
        return TRUE;
    end;
    return TileDescriptorLegal(binding.source0) &&
           _Tiles[[binding.source0]].storage_kind == TileStorage_Numeric &&
           _Tiles[[binding.source0]].data_type == data_type &&
           _Tiles[[binding.source0]].layout == TileLayout_RowMajor &&
           TileSourceContentsDefined(binding.source0) &&
           TileSourceEncodingsValid(binding.source0) &&
           SelectedBundleComparisonShapeMatches(binding.source0) &&
           ((TileOperationOfIndex(operation) != TileOperation_TROWEXPANDDIV &&
             TileOperationOfIndex(operation) != TileOperation_TCOLEXPANDDIV) ||
            !TileDataTypeIsInteger(data_type) ||
            TileBroadcastPayloadNonzero(
                if TileOperationUsesClosedRowExpansionSchema(operation) then
                    TileAxis_Row
                else
                    TileAxis_Column,
                binding.source0,
                binding.source1));
end;
