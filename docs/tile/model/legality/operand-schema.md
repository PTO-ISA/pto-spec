<!-- GENERATED FROM: asl/tile/model/legality/operand-schema.asl -->
# Operand Schema

**Normative ASL source:** `asl/tile/model/legality/operand-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/operand-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","surface":"tile","classification":["model","legality","operand-schema"],"depends_on":["PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY"]}

readonly func TileElementwiseDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile);
    end;
    return TileDescriptorLegal(index);
end;

readonly func TileElementwiseShapeAndTypeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if !TileElementwiseDescriptorLegal(left) ||
       !TileElementwiseDescriptorLegal(right) then
        return FALSE;
    end;
    return _Tiles[[left]].rows == _Tiles[[right]].rows &&
           _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout &&
           _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;

readonly func TileElementwiseSourceContentsDefined(index: TileIndex)
    => boolean
begin
    return TileElementwiseDescriptorLegal(index) &&
           _Tiles[[index]].contents_defined;
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
    if !TileElementwiseShapeAndTypeMatch(source_left, source_right) ||
       !TileElementwiseShapeAndTypeMatch(destination, source_left) then return FALSE; end;
    if TileBinaryUsesClosedElementwiseContract(op) then
        if !TileElementwiseSourceContentsDefined(source_left) ||
           !TileElementwiseSourceContentsDefined(source_right) ||
           !TileBinaryDataTypeSupported(
               op,
               _Tiles[[source_left]].data_type) ||
           !TileElementwiseLayoutSupported(_Tiles[[source_left]].layout) then
            return FALSE;
        end;
    end;
    if (op == TileBinary_MAX || op == TileBinary_MIN) &&
       TileDataTypeIsFloating(_Tiles[[source_left]].data_type) &&
       (!TileElementwiseSourceEncodingsValid(source_left) ||
        !TileElementwiseSourceEncodingsValid(source_right)) then
        return FALSE;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(_Tiles[[source_right]].data_type) then
        return TilePayloadNonzero(source_right);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileDescriptorLegal(destination) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           _Tiles[[destination]].layout == TileLayout_RowMajor &&
           TileFillPadDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_ExecuteTileUnary(
    op: TileUnaryOperation, destination: TileIndex, source: TileIndex) => boolean
begin
    if !TileElementwiseShapeAndTypeMatch(destination, source) then return FALSE; end;
    if TileUnaryUsesCompleteElementwiseSchema(op) then
        if !TileElementwiseSourceContentsDefined(source) ||
           !TileUnaryDataTypeSupported(op, _Tiles[[source]].data_type) ||
           !TileElementwiseLayoutSupported(_Tiles[[source]].layout) then
            return FALSE;
        end;
        if TileDataTypeIsFloating(_Tiles[[source]].data_type) &&
           !TileElementwiseSourceEncodingsValid(source) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileScalar(
    op: TileBinaryOperation, destination: TileIndex,
    source: TileIndex, scalar: Word) => boolean
begin
    let carrier_logical = (op == TileBinary_AND ||
                           op == TileBinary_OR ||
                           op == TileBinary_XOR) &&
                          TileVecScalarIntegerDataTypeSupported(
                              _Tiles[[source]].data_type);
    if !TileElementwiseShapeAndTypeMatch(destination, source) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       !TileElementwiseLayoutSupported(_Tiles[[source]].layout) ||
       !TileBinaryDataTypeSupported(op, _Tiles[[source]].data_type) ||
       !TileElementwiseSourceContentsDefined(source) ||
       (!carrier_logical && !TileElementwiseSourceEncodingsValid(source)) then
        return FALSE;
    end;
    let normalized_scalar = TileRawElementValue(
        scalar,
        _Tiles[[source]].data_type);
    if !carrier_logical && !TileNumericEncodingValid(
           _Tiles[[source]].data_type,
           normalized_scalar) then
        return FALSE;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(_Tiles[[source]].data_type) then
        return !IsZero(TileIntegerOperandValue(
            normalized_scalar,
            _Tiles[[source]].data_type));
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileCompare(
    destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
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

readonly func TileTCVTSourceEncodingsValid(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileTCVTSourceContentsDefined(index) then return FALSE; end;
    if !TileLayoutIsCube(tile.layout) then
        return TileSourceEncodingsValid(index);
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                tile, row as integer {0..65535},
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

readonly func TileOperandsLegal_TCVT(destination: TileIndex,
                                     source: TileIndex,
                                     control: NumericExecutionControl) => boolean
begin
    let destination_tile = _Tiles[[destination]];
    if (if TileLayoutIsCube(destination_tile.layout) then
            !TileCubeDescriptorLegal(destination_tile)
        else !TileDescriptorLegal(destination)) ||
       !TileTCVTSourceContentsDefined(source) ||
       !TileTCVTSourceEncodingsValid(source) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    if !HardwareTCVTTypePairSupported(
           source_tile.data_type,
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

readonly func TileOperandsLegal_TQUANT(destination: TileIndex,
                                       source: TileIndex, scale: Word,
                                       zero_point: Word,
                                       control: NumericExecutionControl) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       _Tiles[[destination]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       (_Tiles[[destination]].data_type != TileDataType_S8 &&
        _Tiles[[destination]].data_type != TileDataType_U8) ||
       _Tiles[[source]].data_type != TileDataType_FP32 ||
       _Tiles[[destination]].layout != TileLayout_RowMajor ||
       _Tiles[[source]].layout != TileLayout_RowMajor ||
       _Tiles[[destination]].valid_rows != _Tiles[[source]].valid_rows ||
       _Tiles[[destination]].valid_columns !=
           _Tiles[[source]].valid_columns ||
       _Tiles[[destination]].valid_rows == 0 ||
       _Tiles[[destination]].valid_columns == 0 ||
       !TileSourceContentsDefined(source) ||
       !TileSourceEncodingsValid(source) ||
       !TileQuantizationScaleLegal(scale) then
        return FALSE;
    end;
    return TileQuantizationZeroPointLegal(
        zero_point,
        _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_TDEQUANT(destination: TileIndex,
                                         source: TileIndex, scale: Word,
                                         zero_point: Word,
                                         control: NumericExecutionControl) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       _Tiles[[destination]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       _Tiles[[destination]].data_type != TileDataType_FP32 ||
       (_Tiles[[source]].data_type != TileDataType_S8 &&
        _Tiles[[source]].data_type != TileDataType_U8) ||
       _Tiles[[destination]].layout != TileLayout_RowMajor ||
       _Tiles[[source]].layout != TileLayout_RowMajor ||
       _Tiles[[destination]].valid_rows != _Tiles[[source]].valid_rows ||
       _Tiles[[destination]].valid_columns !=
           _Tiles[[source]].valid_columns ||
       _Tiles[[destination]].valid_rows == 0 ||
       _Tiles[[destination]].valid_columns == 0 ||
       !TileSourceContentsDefined(source) ||
       !TileSourceEncodingsValid(source) ||
       !TileQuantizationScaleLegal(scale) ||
       control.saturating then
        return FALSE;
    end;
    return TileQuantizationZeroPointLegal(
        zero_point,
        _Tiles[[source]].data_type);
end;

readonly func TileOperandsLegal_TRESHAPE(destination: TileIndex,
                                         source: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) && TileDescriptorLegal(source) &&
           _Tiles[[destination]].rows * _Tiles[[destination]].columns ==
               _Tiles[[source]].rows * _Tiles[[source]].columns &&
           _Tiles[[destination]].valid_rows * _Tiles[[destination]].valid_columns ==
               _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type;
end;

readonly func TileOperandsLegal_TINTERLEAVE(
    destination: TileIndex, source_even: TileIndex,
    source_odd: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_even) ||
       !TileDescriptorLegal(source_odd) then return FALSE; end;
    let extent: integer =
        _Tiles[[source_even]].valid_rows * _Tiles[[source_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 &&
           extent == _Tiles[[source_odd]].valid_rows *
                     _Tiles[[source_odd]].valid_columns &&
           _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns == extent * 2 &&
           _Tiles[[destination]].data_type == _Tiles[[source_even]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_odd]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source_even]].layout &&
           _Tiles[[destination]].layout == _Tiles[[source_odd]].layout;
end;

readonly func TileOperandsLegal_TDEINTERLEAVE(
    destination_even: TileIndex, destination_odd: TileIndex,
    source: TileIndex) => boolean
begin
    if destination_even == destination_odd then return FALSE; end;
    if !TileDescriptorLegal(destination_even) ||
       !TileDescriptorLegal(destination_odd) ||
       !TileDescriptorLegal(source) then return FALSE; end;
    let extent: integer = _Tiles[[destination_even]].valid_rows *
                          _Tiles[[destination_even]].valid_columns;
    return extent <= PTO_MODEL_TILE_ELEMENTS DIV 2 &&
           extent == _Tiles[[destination_odd]].valid_rows *
                     _Tiles[[destination_odd]].valid_columns &&
           _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns ==
               extent * 2 &&
           _Tiles[[destination_even]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_odd]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_even]].layout == _Tiles[[source]].layout &&
           _Tiles[[destination_odd]].layout == _Tiles[[source]].layout;
end;
```
<!-- GENERATED-ASL-END: unit -->
