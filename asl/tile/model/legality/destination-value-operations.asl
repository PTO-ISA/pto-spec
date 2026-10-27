// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DESTINATION-VALUE-OPERATIONS","surface":"tile","classification":["model","legality","destination-value-operations"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-LEGALITY-DESTINATION-VALUE","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"]}

readonly func TileOperandsLegal_TFMAToValue(
    destination: TileOutputValueTarget, source_left: TileIndex,
    source_right: TileIndex, addend: TileIndex) => boolean
begin
    let output = destination.value;
    let left = TileOutputValueSourceTile(destination, source_left);
    let right = TileOutputValueSourceTile(destination, source_right);
    let addend_tile = TileOutputValueSourceTile(destination, addend);
    return TileCubeDescriptorLegal(output) &&
           output.storage_kind == TileStorage_Numeric &&
           TileOutputValueSourceContentsDefined(destination, source_left) &&
           TileOutputValueSourceContentsDefined(destination, source_right) &&
           TileOutputValueSourceContentsDefined(destination, addend) &&
           TileFusedMultiplyAddDataTypeSupported(output.data_type) &&
           TileElementwiseCubeValueShapeMatches(output, left) &&
           TileElementwiseCubeValueShapeMatches(output, right) &&
           TileElementwiseCubeValueShapeMatches(output, addend_tile) &&
           output.data_type == left.data_type &&
           output.data_type == right.data_type &&
           output.data_type == addend_tile.data_type &&
           TileElementwiseLayoutSupported(output.layout) &&
           (!TileDataTypeIsFloating(output.data_type) ||
            (TileOutputValueSourceEncodingsValidAs(
                 destination, source_left, output.data_type) &&
             TileOutputValueSourceEncodingsValidAs(
                 destination, source_right, output.data_type) &&
             TileOutputValueSourceEncodingsValidAs(
                 destination, addend, output.data_type)));
end;

readonly func TilePredicateCellValueDescriptorLegal(
    tile: TileInfo, operation_type: TileDataType) => boolean
begin
    return tile.allocated &&
           tile.storage_kind == TileStorage_PredicateCell &&
           tile.data_type == TileDataType_U8 &&
           TileCubePredicateDataTypeSupported(tile.predicate_basis_type) &&
           tile.predicate_basis_type == operation_type &&
           TileCubeLayoutDataTypeSupported(tile.layout,
               tile.predicate_basis_type) &&
           TileCubeDescriptorShapeAndPhysicalLegal(tile.capacity_bytes,
               tile.rows, tile.columns, tile.valid_rows,
               tile.valid_columns, tile.data_type, tile.layout) &&
           tile.cube_k_repeat == TileCubePhysicalKRepeat(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_n_repeat == TileCubePhysicalNRepeat(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_cell_count == TileCubePhysicalCellCount(tile.layout,
               tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes == TileCubePhysicalRequiredBytes(
               tile.layout, tile.rows, tile.columns, tile.data_type) &&
           tile.cube_storage_bytes <= tile.capacity_bytes;
end;

readonly func TileCubeNumericOrPredicateCellDescriptorLegal(
    tile: TileInfo) => boolean
begin
    // A Local generation parent may retain either ordinary numeric storage or
    // a U8 comparison PredicateCell. The comparison resolver checks the
    // requested operation basis before writer effects are admitted.
    if tile.storage_kind == TileStorage_Numeric then
        return TileCubeDescriptorLegal(tile);
    elsif tile.storage_kind == TileStorage_PredicateCell then
        return TilePredicateCellValueDescriptorLegal(
            tile, tile.predicate_basis_type);
    end;
    return FALSE;
end;

readonly func TileOperandsLegal_ExecuteTileCompareToValue(
    destination: TileOutputValueTarget, source_left: TileIndex,
    source_right: TileIndex, comparison: TileComparison) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    let output = destination.value;
    let left = TileOutputValueSourceTile(destination, source_left);
    let right = TileOutputValueSourceTile(destination, source_right);
    if !operation_type_valid ||
       !TileVecArithmeticDataTypeSupported(operation_type) then
        return FALSE;
    end;
    if left.layout == TileLayout_CUBE_M16 ||
       left.layout == TileLayout_CUBE_M32 then
        return TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericShapeMatch(source_left, source_right) &&
               TileCubeNumericSourceLegalAs(source_left, operation_type) &&
               TileCubeNumericSourceLegalAs(source_right, operation_type) &&
               TilePredicateCellValueDescriptorLegal(output, operation_type) &&
               output.valid_rows == left.valid_rows &&
               output.valid_columns == left.valid_columns &&
               output.layout == left.layout;
    end;
    return TileRowMajorNumericCarrierLegal(source_left, operation_type) &&
           TileRowMajorNumericCarrierLegal(source_right, operation_type) &&
           TileLogicalShapeMatch(source_left, source_right) &&
           TileElementwiseSourceContentsDefined(source_left) &&
           TileElementwiseSourceContentsDefined(source_right) &&
           TileElementwiseSourceEncodingsValidAs(source_left, operation_type) &&
           TileElementwiseSourceEncodingsValidAs(source_right, operation_type) &&
           output.storage_kind == TileStorage_Predicate &&
           output.rows == left.rows && output.columns == left.columns &&
           output.valid_rows == left.valid_rows &&
           output.valid_columns == left.valid_columns &&
           output.layout == TileLayout_RowMajor;
end;

readonly func TileOperandsLegal_ExecuteTileCompareScalarToValue(
    destination: TileOutputValueTarget, source: TileIndex, scalar: Word,
    comparison: TileComparison) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    let output = destination.value;
    let source_tile = TileOutputValueSourceTile(destination, source);
    if !operation_type_valid ||
       !TileVecArithmeticDataTypeSupported(operation_type) ||
       !TileNumericEncodingValid(operation_type,
           TileRawElementValue(scalar, operation_type)) then
        return FALSE;
    end;
    if source_tile.layout == TileLayout_CUBE_M16 ||
       source_tile.layout == TileLayout_CUBE_M32 then
        return TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericSourceLegalAs(source, operation_type) &&
               TilePredicateCellValueDescriptorLegal(output, operation_type) &&
               output.valid_rows == source_tile.valid_rows &&
               output.valid_columns == source_tile.valid_columns &&
               output.layout == source_tile.layout;
    end;
    return TileRowMajorNumericCarrierLegal(source, operation_type) &&
           TileElementwiseSourceContentsDefined(source) &&
           TileElementwiseSourceEncodingsValidAs(source, operation_type) &&
           output.storage_kind == TileStorage_Predicate &&
           output.rows == source_tile.rows &&
           output.columns == source_tile.columns &&
           output.valid_rows == source_tile.valid_rows &&
           output.valid_columns == source_tile.valid_columns &&
           output.layout == TileLayout_RowMajor;
end;

readonly func TileOperandsLegal_ExecuteTileSelectToValue(
    destination: TileOutputValueTarget, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(destination.value.data_type);
    let output = destination.value;
    let true_tile = TileOutputValueSourceTile(destination, source_true);
    let false_tile = TileOutputValueSourceTile(destination, source_false);
    if !operation_type_valid ||
       !TileVecArithmeticDataTypeSupported(operation_type) ||
       output.storage_kind != TileStorage_Numeric ||
       output.data_type != operation_type then
        return FALSE;
    end;
    if true_tile.layout == TileLayout_CUBE_M16 ||
       true_tile.layout == TileLayout_CUBE_M32 then
        return TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericShapeMatch(source_true, source_false) &&
               TileCubeNumericContentsDefined(source_true) &&
               TileCubeNumericContentsDefined(source_false) &&
               TileCarrierWidthCompatible(true_tile.data_type, operation_type) &&
               TileCarrierWidthCompatible(false_tile.data_type, operation_type) &&
               TilePredicateCellOperationValuesLegal(mask) &&
               TilePredicateCellSelectShapeMatchesNumericAs(
                   mask, source_true, operation_type) &&
               TileElementwiseCubeValueShapeMatches(output, true_tile);
    end;
    return TileRowMajorNumericCarrierLegal(source_true, operation_type) &&
           TileRowMajorNumericCarrierLegal(source_false, operation_type) &&
           TileLogicalShapeMatch(source_true, source_false) &&
           TileElementwiseSourceContentsDefined(source_true) &&
           TileElementwiseSourceContentsDefined(source_false) &&
           TilePredicateValuesLegal(mask) &&
           TileLogicalShapeMatch(mask, source_true) &&
           output.storage_kind == TileStorage_Numeric &&
           output.data_type == operation_type &&
           output.rows == true_tile.rows &&
           output.columns == true_tile.columns &&
           output.valid_rows == true_tile.valid_rows &&
           output.valid_columns == true_tile.valid_columns &&
           output.layout == true_tile.layout;
end;

readonly func TileOperandsLegal_ExecuteTileSelectScalarToValue(
    destination: TileOutputValueTarget, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(destination.value.data_type);
    let output = destination.value;
    let true_tile = TileOutputValueSourceTile(destination, source_true);
    if !operation_type_valid ||
       !TileVecArithmeticDataTypeSupported(operation_type) ||
       !TileNumericEncodingValid(operation_type,
           TileRawElementValue(scalar_false, operation_type)) ||
       output.storage_kind != TileStorage_Numeric ||
       output.data_type != operation_type then
        return FALSE;
    end;
    if true_tile.layout == TileLayout_CUBE_M16 ||
       true_tile.layout == TileLayout_CUBE_M32 then
        return TileCubePredicateDataTypeSupported(operation_type) &&
               TileCubeNumericContentsDefined(source_true) &&
               TileCarrierWidthCompatible(true_tile.data_type, operation_type) &&
               TilePredicateCellOperationValuesLegal(mask) &&
               TilePredicateCellSelectShapeMatchesNumericAs(
                   mask, source_true, operation_type) &&
               TileElementwiseCubeValueShapeMatches(output, true_tile);
    end;
    return TileRowMajorNumericCarrierLegal(source_true, operation_type) &&
           TileElementwiseSourceContentsDefined(source_true) &&
           TilePredicateValuesLegal(mask) &&
           TileLogicalShapeMatch(mask, source_true) &&
           output.rows == true_tile.rows &&
           output.columns == true_tile.columns &&
           output.valid_rows == true_tile.valid_rows &&
           output.valid_columns == true_tile.valid_columns &&
           output.layout == true_tile.layout;
end;
