<!-- GENERATED FROM: asl/tile/model/legality/destination-value.asl -->
# Destination Value

**Normative ASL source:** `asl/tile/model/legality/destination-value.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-DESTINATION-VALUE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/destination-value.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DESTINATION-VALUE","surface":"tile","classification":["model","legality","destination-value"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"]}
readonly func TileElementwiseCubeValueShapeMatch(
    left: TileInfo, right: TileInfo) => boolean
begin
    return (left.layout == TileLayout_CUBE_M16 ||
            left.layout == TileLayout_CUBE_M32) &&
           TileCubeDescriptorLegal(left) &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind;
end;

readonly func TileOutputValueSourceTile(
    destination: TileOutputValueTarget, source: TileIndex) => TileInfo
begin
    // Writer views are output sinks only.  Even when a source aliases the
    // architectural destination, it observes the retained full parent that
    // was resolved before the producer begins.
    return _Tiles[[source]];
end;

readonly func TileOutputValueSourceContentsDefined(
    destination: TileOutputValueTarget, source: TileIndex) => boolean
begin
    return TileElementwiseSourceContentsDefined(source);
end;

readonly func TileOutputValueSourceEncodingsValidAs(
    destination: TileOutputValueTarget, source: TileIndex,
    operation_type: TileDataType) => boolean
begin
    let tile = TileOutputValueSourceTile(destination, source);
    if !TileOutputValueSourceContentsDefined(destination, source) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(tile.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileElementwiseCubeValueShapeMatches(
    left: TileInfo, right: TileInfo) => boolean
begin
    return (left.layout == TileLayout_CUBE_M16 ||
            left.layout == TileLayout_CUBE_M32) &&
           TileCubeDescriptorLegal(left) && TileCubeDescriptorLegal(right) &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind;
end;

readonly func TileOperandsLegal_ExecuteTileUnaryToValue(
    op: TileUnaryOperation, destination: TileOutputValueTarget,
    source: TileIndex) => boolean
begin
    let source_tile = TileOutputValueSourceTile(destination, source);
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else destination.value.data_type;
    if !TileElementwiseCubeValueShapeMatches(
           destination.value, source_tile) ||
       destination.value.data_type != operation_type ||
       !TileCarrierWidthCompatible(source_tile.data_type, operation_type) then
        return FALSE;
    end;
    if op == TileUnary_NOT then
        return TileVecScalarIntegerDataTypeSupported(operation_type) &&
               TileElementwiseLayoutSupported(source_tile.layout) &&
               TileOutputValueSourceContentsDefined(destination, source);
    end;
    if TileUnaryUsesClosedElementwiseContract(op) then
        return TileOutputValueSourceEncodingsValidAs(
                   destination, source, operation_type) &&
               TileUnaryDataTypeSupported(op, operation_type) &&
               TileElementwiseLayoutSupported(source_tile.layout);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileScalarToValue(
    op: TileBinaryOperation, destination: TileOutputValueTarget,
    source: TileIndex, scalar: Word) => boolean
begin
    let source_tile = TileOutputValueSourceTile(destination, source);
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else destination.value.data_type;
    if op == TileBinary_EXPDIF ||
       !TileElementwiseCubeValueShapeMatches(destination.value, source_tile) ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination.value.data_type != operation_type ||
       !TileCarrierWidthCompatible(source_tile.data_type, operation_type) ||
       !TileElementwiseLayoutSupported(source_tile.layout) ||
       !TileBinaryDataTypeSupported(op, operation_type) ||
       !TileOutputValueSourceContentsDefined(destination, source) then
        return FALSE;
    end;
    let carrier_logical = op == TileBinary_AND || op == TileBinary_OR ||
        op == TileBinary_XOR || op == TileBinary_SHL || op == TileBinary_SHR;
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    if !carrier_logical &&
       (!TileOutputValueSourceEncodingsValidAs(
            destination, source, operation_type) ||
        !TileNumericEncodingValid(operation_type, normalized_scalar)) then
        return FALSE;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(operation_type) then
        return !IsZero(TileIntegerOperandValue(normalized_scalar,
                   operation_type)) || BundleExecutionMaskHasActiveCoordinate();
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileBinaryToValue(
    op: TileBinaryOperation, destination: TileOutputValueTarget,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    let left_tile = TileOutputValueSourceTile(destination, source_left);
    let right_tile = TileOutputValueSourceTile(destination, source_right);
    if op == TileBinary_EXPDIF ||
       !TileElementwiseCubeValueShapeMatches(destination.value, left_tile) ||
       !TileElementwiseCubeValueShapeMatches(left_tile, right_tile) then
        return FALSE;
    end;
    let operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else destination.value.data_type;
    let raw_carrier = op == TileBinary_AND || op == TileBinary_OR ||
                      op == TileBinary_XOR || op == TileBinary_SHL ||
                      op == TileBinary_SHR;
    if destination.value.data_type != operation_type ||
       !TileCarrierWidthCompatible(
           _Tiles[[source_left]].data_type, operation_type) ||
       !TileCarrierWidthCompatible(
           _Tiles[[source_right]].data_type, operation_type) then
        return FALSE;
    end;
    if TileBinaryUsesClosedElementwiseContract(op) then
        if !TileOutputValueSourceContentsDefined(destination, source_left) ||
           !TileOutputValueSourceContentsDefined(destination, source_right) ||
           !TileBinaryDataTypeSupported(op, operation_type) ||
           !TileElementwiseLayoutSupported(
               _Tiles[[source_left]].layout) then
            return FALSE;
        end;
        if (op == TileBinary_SHL || op == TileBinary_SHR) &&
           !TileDataTypeIsInteger(_Tiles[[source_right]].data_type) then
            return FALSE;
        end;
        if !raw_carrier &&
           (!TileOutputValueSourceEncodingsValidAs(
                destination, source_left, operation_type) ||
            !TileOutputValueSourceEncodingsValidAs(
                destination, source_right, operation_type)) then
            return FALSE;
        end;
    end;
    if (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(operation_type) then
        return TilePayloadNonzero(source_right);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileReductionToValue(
    operation: TileReductionOperation, axis: TileAxis,
    destination: TileOutputValueTarget, source: TileIndex) => boolean
begin
    let destination_tile = destination.value;
    if destination.destination == source ||
       !TileCubeDescriptorLegal(destination_tile) ||
       !TileReductionAndExpansionDescriptorLegal(source) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveTileSelectedOperationType(source_tile.data_type);
    if !operation_type_valid ||
       !TileReductionSourceLegalAs(source, operation_type) then
        return FALSE;
    end;
    let index_reduction = operation == TileReduction_ARGMIN ||
        operation == TileReduction_ARGMAX;
    let source_type_legal = if index_reduction then
        TileArgReductionSourceDataTypeSupported(operation_type)
    else TileVecArithmeticDataTypeSupported(operation_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != source_tile.layout ||
       source_tile.valid_rows == 0 || source_tile.valid_columns == 0 ||
       !source_type_legal then
        return FALSE;
    end;
    if index_reduction then
        if destination_tile.data_type != TileDataType_U32 then
            return FALSE;
        end;
    elsif destination_tile.data_type != operation_type then
        return FALSE;
    end;
    if axis == TileAxis_Row then
        if destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != 1 then
            return FALSE;
        end;
        return destination_tile.rows == TileCubeStorageRows(
                   destination_tile.layout, source_tile.valid_rows,
                   destination_tile.data_type) &&
               destination_tile.columns == source_tile.columns;
    end;
    if destination_tile.valid_rows != 1 ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    let required_columns = TileCubePhysicalColumnsFromCapacity(
        destination_tile.capacity_bytes, destination_tile.layout,
        destination_tile.data_type);
    return destination_tile.rows == source_tile.rows &&
           destination_tile.columns == required_columns;
end;

readonly func TileOperandsLegal_ExecuteTileExpandToValue(
    operation: TileExpandOperation, axis: TileAxis,
    destination: TileOutputValueTarget, source: TileIndex,
    broadcast_source: TileIndex) => boolean
begin
    let destination_tile = destination.value;
    let source_tile = TileOutputValueSourceTile(destination, source);
    let broadcast_tile = TileOutputValueSourceTile(destination, broadcast_source);
    let copy = operation == TileExpand_COPY;
    let expdif = operation == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(destination_tile.data_type);
    if !operation_type_valid || !TileCubeDescriptorLegal(destination_tile) ||
       !TileReductionAndExpansionDescriptorLegal(source) ||
       !TileReductionAndExpansionDescriptorLegal(broadcast_source) ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       source_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.layout != destination_tile.layout ||
       source_tile.layout != destination_tile.layout then
        return FALSE;
    end;
    let source_type = if expdif && !BundleTileOperationSelected() then
        source_tile.data_type else selected_type;
    let destination_type = if expdif then destination_tile.data_type
        else selected_type;
    if !TileVecArithmeticDataTypeSupported(destination_type) ||
       destination_tile.data_type != destination_type then
        return FALSE;
    end;
    if copy then
        if source != broadcast_source ||
           !TileExpansionBroadcastElementsLegalAs(
               broadcast_source, axis, destination_type, FALSE) then
            return FALSE;
        end;
    else
        if !TileOutputValueSourceEncodingsValidAs(
               destination, source, source_type) ||
           !TileExpansionBroadcastLegalAs(
               broadcast_source, axis, source_type) then
            return FALSE;
        end;
    end;
    if (expdif && !TileExpdifTypePairLegal(
                      source_type, destination_type)) ||
       (!expdif && source_type != destination_type) then
        return FALSE;
    end;
    let broadcast_shape_legal = if axis == TileAxis_Row then
        broadcast_tile.valid_rows == destination_tile.valid_rows &&
        broadcast_tile.valid_columns >= 1
    else broadcast_tile.valid_rows >= 1 &&
         broadcast_tile.valid_columns == destination_tile.valid_columns;
    if !broadcast_shape_legal then return FALSE; end;
    if !copy && (destination_tile.valid_rows != source_tile.valid_rows ||
                 destination_tile.valid_columns != source_tile.valid_columns) then
        return FALSE;
    end;
    if operation == TileExpand_DIV && TileDataTypeIsInteger(destination_type) then
        return TileExpansionBroadcastNonzero(
            axis, source, broadcast_source, source_type);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpdifToValue(
    destination: TileOutputValueTarget,
    source0: TileIndex, source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    let destination_tile = destination.value;
    let left_tile = TileOutputValueSourceTile(destination, source0);
    let right_tile = TileOutputValueSourceTile(destination, source1);
    return operation_type_valid &&
           TileExpdifTypePairLegal(operation_type, destination_tile.data_type) &&
           destination_tile.storage_kind == TileStorage_Numeric &&
           destination_tile.layout == left_tile.layout &&
           destination_tile.valid_rows == left_tile.valid_rows &&
           destination_tile.valid_columns == left_tile.valid_columns &&
           TileCubeDescriptorLegal(destination_tile) &&
           TileExpdifSourcesLegal(source0, source1) &&
           left_tile.layout == right_tile.layout &&
           left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalarToValue(
    destination: TileOutputValueTarget, scalar: Word) => boolean
begin
    let tile = destination.value;
    return TileCubeDescriptorLegal(tile) &&
           tile.storage_kind == TileStorage_Numeric &&
           TileFillPadDataTypeSupported(tile.data_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
