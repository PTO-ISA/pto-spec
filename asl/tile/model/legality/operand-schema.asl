// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","surface":"tile","classification":["model","legality","operand-schema"],"depends_on":["PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
readonly func TileElementwiseDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile);
    end;
    return TileDescriptorLegal(index);
end;
readonly func TileElementwiseShapeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    if !TileElementwiseDescriptorLegal(left) || !TileElementwiseDescriptorLegal(right) then return FALSE; end;
    return _Tiles[[left]].rows == _Tiles[[right]].rows && _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows && _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout && _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind;
end;
readonly func TileElementwiseShapeAndTypeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    if !TileElementwiseDescriptorLegal(left) || !TileElementwiseDescriptorLegal(right) then return FALSE; end;
    return _Tiles[[left]].rows == _Tiles[[right]].rows && _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows && _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout && _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;
readonly func TileElementwiseSourceContentsDefined(index: TileIndex)
    => boolean
begin
    return TileElementwiseDescriptorLegal(index) &&
           _Tiles[[index]].contents_defined;
end;
readonly func TileElementwiseSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(
           _Tiles[[index]].data_type, operation_type) then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if !TileNumericEncodingValid(
                   operation_type,
                   TileReadLogicalElement(tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
readonly func TileElementwiseSourceEncodingsValid(index: TileIndex)
    => boolean
begin
    if !TileElementwiseSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if !TileNumericEncodingValid(
                   tile.data_type,
                   TileReadLogicalElement(tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileBinary(
    op: TileBinaryOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else _Tiles[[destination]].data_type;
    let raw_carrier = op == TileBinary_AND || op == TileBinary_OR ||
                      op == TileBinary_XOR || op == TileBinary_SHL ||
                      op == TileBinary_SHR;
    if !TileElementwiseShapeMatch(source_left, source_right) ||
       !TileElementwiseShapeMatch(destination, source_left) ||
       _Tiles[[destination]].data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source_left]].data_type, operation_type) ||
       !TileCarrierWidthCompatible(
           _Tiles[[source_right]].data_type, operation_type) then
        return FALSE;
    end;
    if TileBinaryUsesClosedElementwiseContract(op) then
        if !TileElementwiseSourceContentsDefined(source_left) ||
           !TileElementwiseSourceContentsDefined(source_right) ||
           !TileBinaryDataTypeSupported(op, operation_type) ||
           !TileElementwiseLayoutSupported(_Tiles[[source_left]].layout) then
            return FALSE;
        end;
        if (op == TileBinary_SHL || op == TileBinary_SHR) &&
           !TileDataTypeIsInteger(_Tiles[[source_right]].data_type) then
            return FALSE;
        end;
        if !raw_carrier &&
           (!TileElementwiseSourceEncodingsValidAs(
                source_left, operation_type) ||
            !TileElementwiseSourceEncodingsValidAs(
                source_right, operation_type)) then
            return FALSE;
        end;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(operation_type) then
        return TilePayloadNonzero(source_right);
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileUnary(
    op: TileUnaryOperation, destination: TileIndex, source: TileIndex) => boolean
begin
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else _Tiles[[destination]].data_type;
    if op == TileUnary_NOT then
        return TileElementwiseShapeAndTypeMatch(destination, source) &&
               _Tiles[[destination]].data_type == operation_type &&
               TileVecScalarIntegerDataTypeSupported(operation_type) &&
               _Tiles[[source]].layout == TileLayout_RowMajor &&
               TileElementwiseSourceContentsDefined(source);
    end;
    if !TileElementwiseShapeMatch(destination, source) ||
       _Tiles[[destination]].data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source]].data_type, operation_type) then
        return FALSE;
    end;
    if TileUnaryUsesCompleteElementwiseSchema(op) then
        return TileElementwiseSourceContentsDefined(source) &&
               TileUnaryDataTypeSupported(op, operation_type) &&
               TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
               TileElementwiseSourceEncodingsValidAs(source, operation_type);
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileScalar(
    op: TileBinaryOperation, destination: TileIndex,
    source: TileIndex, scalar: Word) => boolean
begin
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else _Tiles[[destination]].data_type;
    let carrier_logical = op == TileBinary_AND || op == TileBinary_OR ||
                          op == TileBinary_XOR || op == TileBinary_SHL ||
                          op == TileBinary_SHR;
    if !TileElementwiseShapeMatch(destination, source) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       _Tiles[[destination]].data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source]].data_type, operation_type) ||
       !TileElementwiseLayoutSupported(_Tiles[[source]].layout) ||
       !TileBinaryDataTypeSupported(op, operation_type) ||
       !TileElementwiseSourceContentsDefined(source) then
        return FALSE;
    end;
    if !carrier_logical &&
       !TileElementwiseSourceEncodingsValidAs(source, operation_type) then
        return FALSE;
    end;
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    if !carrier_logical &&
       !TileNumericEncodingValid(operation_type, normalized_scalar) then
        return FALSE;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(operation_type) then
        return !IsZero(TileIntegerOperandValue(
            normalized_scalar, operation_type));
    end;
    return TRUE;
end;
readonly func TileOperandsLegal_ExecuteTileCompare(
    destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    if _Tiles[[source_left]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source_left]].layout == TileLayout_CUBE_M32 then
        return TileCubeNumericShapeAndTypeMatch(source_left, source_right) &&
               TileCubeNumericSourceLegal(source_left) &&
               TileCubeNumericSourceLegal(source_right) &&
               TilePredicateCellShapeMatchesNumeric(
                   destination, source_left);
    end;
    return TileShapeAndTypeMatch(source_left, source_right) &&
           _Tiles[[source_left]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source_left]].layout == TileLayout_RowMajor &&
           TileCompareDataTypeSupported(_Tiles[[source_left]].data_type) &&
           TileSourceContentsDefined(source_left) &&
           TileSourceContentsDefined(source_right) &&
           TileSourceEncodingsValid(source_left) &&
           TileSourceEncodingsValid(source_right) &&
           TileLogicalShapeMatch(destination, source_left) &&
           _Tiles[[destination]].storage_kind == TileStorage_Predicate;
end;
readonly func TileOperandsLegal_ExecuteTileCompareScalar(
    destination: TileIndex, source: TileIndex, scalar: Word,
    comparison: TileComparison) => boolean
begin
    let normalized_scalar = TileRawElementValue(
        scalar,
        _Tiles[[source]].data_type);
    if _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source]].layout == TileLayout_CUBE_M32 then
        return TileCubeNumericSourceLegal(source) &&
               TileNumericEncodingValid(
                   _Tiles[[source]].data_type, normalized_scalar) &&
               TilePredicateCellShapeMatchesNumeric(destination, source);
    end;
    return _Tiles[[source]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source]].layout == TileLayout_RowMajor &&
           TileCompareDataTypeSupported(_Tiles[[source]].data_type) &&
           TileSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source) &&
           TileNumericEncodingValid(
               _Tiles[[source]].data_type,
               normalized_scalar) &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].storage_kind == TileStorage_Predicate;
end;
readonly func TileOperandsLegal_ExecuteTileSelect(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex) => boolean
begin
    if _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source_true]].layout == TileLayout_CUBE_M32 then
        return TileCubeNumericShapeAndTypeMatch(source_true, source_false) &&
               TileCubeNumericContentsDefined(source_true) &&
               TileCubeNumericContentsDefined(source_false) &&
               TilePredicateCellValuesLegal(mask) &&
               TilePredicateCellShapeMatchesNumeric(mask, source_true) &&
               TileCubeNumericShapeAndTypeMatch(destination, source_true);
    end;
    return TileShapeAndTypeMatch(source_true, source_false) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source_true]].layout == TileLayout_RowMajor &&
           TileSelectDataTypeSupported(_Tiles[[source_true]].data_type) &&
           TileSourceContentsDefined(source_true) &&
           TileSourceContentsDefined(source_false) &&
           TilePredicateValuesLegal(mask) &&
           TileLogicalShapeMatch(mask, source_true) &&
           TileShapeAndTypeMatch(destination, source_true) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric;
end;
readonly func TileOperandsLegal_ExecuteTileSelectScalar(
    destination: TileIndex, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word) => boolean
begin
    if _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
       _Tiles[[source_true]].layout == TileLayout_CUBE_M32 then
        return TileCubeNumericContentsDefined(source_true) &&
               TilePredicateCellValuesLegal(mask) &&
               TilePredicateCellShapeMatchesNumeric(mask, source_true) &&
               TileCubeNumericShapeAndTypeMatch(destination, source_true);
    end;
    return _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source_true]].layout == TileLayout_RowMajor &&
           TileSelectDataTypeSupported(_Tiles[[source_true]].data_type) &&
           TileSourceContentsDefined(source_true) &&
           TilePredicateValuesLegal(mask) &&
           TileLogicalShapeMatch(mask, source_true) &&
           TileShapeAndTypeMatch(destination, source_true) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric;
end;
readonly func TileOperandsLegal_TCI(
    destination: TileIndex, start: Word, descending: boolean) => boolean
begin
    if !TileDescriptorLegal(destination) then return FALSE; end;
    let tile = _Tiles[[destination]];
    return TileTCIDataTypeSupported(tile.data_type) &&
           tile.storage_kind == TileStorage_Numeric &&
           tile.layout == TileLayout_RowMajor &&
           tile.valid_rows == 1 &&
           tile.valid_columns >= 1 &&
           tile.columns >= tile.valid_columns;
end;
readonly func TileOperandsLegal_TTRI(
    destination: TileIndex, upper: boolean,
    diagonal: integer {-65535..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) then return FALSE; end;
    let tile = _Tiles[[destination]];
    return TileTTRIDataTypeSupported(tile.data_type) &&
           tile.storage_kind == TileStorage_Numeric &&
           tile.layout == TileLayout_RowMajor &&
           tile.valid_rows >= 1 &&
           tile.valid_columns >= 1 &&
           tile.rows >= tile.valid_rows &&
           tile.columns >= tile.valid_columns;
end;
readonly func TileTCVTSourceContentsDefined(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileSourceContentsDefined(index);
end;
readonly func TileTCVTSourceEncodingsValidAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileTCVTSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                tile, row as integer {0..65535},
                column as integer {0..65535});
            if !TileNumericEncodingValid(
                   operation_type,
                   TileReadLogicalElement(tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
readonly func TileTCVTSourceEncodingsValid(index: TileIndex) => boolean
begin
    return TileTCVTSourceEncodingsValidAs(index, _Tiles[[index]].data_type);
end;
readonly func TileOperandsLegal_TCVT(destination: TileIndex,
                                     source: TileIndex,
                                     control: NumericExecutionControl) => boolean
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let source_operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else source_tile.data_type;
    if source_tile.location == TileLocation_Matrix &&
       source_tile.data_type != source_operation_type then
        return FALSE;
    end;
    if (if TileLayoutIsCube(destination_tile.layout) then
            !TileCubeDescriptorLegal(destination_tile)
        else !TileDescriptorLegal(destination)) ||
       !TileTCVTSourceContentsDefined(source) ||
       !TileTCVTSourceEncodingsValidAs(source, source_operation_type) then
        return FALSE;
    end;
    if !TileCarrierWidthCompatible(
           source_tile.data_type, source_operation_type) ||
       !HardwareTCVTTypePairSupported(
           source_operation_type,
           destination_tile.data_type) then
        return FALSE;
    end;
    if destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    let source_cube_m_layout =
        source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        // A CUBE M-format conversion preserves the physical matrix format
        // while allowing the element width, and therefore the CELL count and
        // minimum legal TSize, to change.
        return !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               source_tile.location == TileLocation_Matrix &&
               destination_tile.location == TileLocation_Matrix &&
               destination_tile.layout == source_tile.layout &&
               TileCubeDescriptorShapeLegal(
                   source_tile.capacity_bytes, source_tile.valid_rows,
                   source_tile.valid_columns, source_tile.data_type,
                   source_tile.layout) &&
               TileCubeDescriptorShapeLegal(
                   destination_tile.capacity_bytes, destination_tile.valid_rows,
                   destination_tile.valid_columns, destination_tile.data_type,
                   destination_tile.layout);
    end;
    if destination_tile.rows != source_tile.rows ||
       destination_tile.columns != source_tile.columns then return FALSE; end;
    if TileLayoutIsCube(destination_tile.layout) then
        return FALSE;
    end;
    let private_cube_source =
        source_tile.location == TileLocation_Matrix;
    if private_cube_source != CurrentBundleCanonicalize() then
        return FALSE;
    end;
    if private_cube_source then
        return CurrentBundleDataLayout() == TileDataLayout_NORM &&
               source_tile.layout == TileLayout_RowMajor &&
               destination_tile.layout == TileLayout_RowMajor;
    end;
    return source_tile.layout == CurrentBundleTileSourceLayout() &&
           destination_tile.layout == CurrentBundleTileLayout();
end;
readonly func TileOperandsLegal_TRESHAPE(destination: TileIndex, source: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows * _Tiles[[destination]].columns == _Tiles[[source]].rows * _Tiles[[source]].columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns == _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;
readonly func TileOperandsLegal_TINTERLEAVE(destination: TileIndex, source_even: TileIndex, source_odd: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source_even) || !TileDescriptorLegal(source_odd) then return FALSE; end;
    let extent: integer = _Tiles[[source_even]].valid_rows * _Tiles[[source_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 && extent == _Tiles[[source_odd]].valid_rows * _Tiles[[source_odd]].valid_columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns == extent * 2 &&
           _Tiles[[destination]].data_type == _Tiles[[source_even]].data_type && _Tiles[[destination]].data_type == _Tiles[[source_odd]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source_even]].layout && _Tiles[[destination]].layout == _Tiles[[source_odd]].layout;
end;
readonly func TileOperandsLegal_TDEINTERLEAVE(destination_even: TileIndex, destination_odd: TileIndex, source: TileIndex) => boolean
begin
    if destination_even == destination_odd then return FALSE; end;
    if !TileDescriptorLegal(destination_even) || !TileDescriptorLegal(destination_odd) || !TileDescriptorLegal(source) then return FALSE; end;
    let extent: integer = _Tiles[[destination_even]].valid_rows * _Tiles[[destination_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 && extent == _Tiles[[destination_odd]].valid_rows * _Tiles[[destination_odd]].valid_columns &&
           _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns == extent * 2 &&
           _Tiles[[destination_even]].data_type == _Tiles[[source]].data_type && _Tiles[[destination_odd]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_even]].layout == _Tiles[[source]].layout && _Tiles[[destination_odd]].layout == _Tiles[[source]].layout;
end;
