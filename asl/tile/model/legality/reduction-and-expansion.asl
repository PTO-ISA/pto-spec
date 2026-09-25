// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION","surface":"tile","classification":["model","legality","reduction-and-expansion"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func TileReductionAndExpansionLayoutSupported(layout: TileLayout)
    => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

readonly func TileReductionAndExpansionDescriptorLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionLayoutSupported(tile.layout) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileDescriptorLegal(index);
    end;
    return TileCubeDescriptorLegal(tile);
end;

readonly func TileReductionAndExpansionSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileSourceEncodingsValid(index);
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
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
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
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
    end;
    return TRUE;
end;

readonly func TileExpansionBroadcastElementsLegalAs(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType, validate_encoding: boolean) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid && !tile.contents_defined then
        return FALSE;
    end;
    if _BundleExecutionMask.valid &&
       tile.layout != _BundleExecutionMask.layout then
        return FALSE;
    end;
    if axis == TileAxis_Row then
        if _BundleExecutionMask.valid &&
           tile.valid_rows != _BundleExecutionMask.valid_rows then
            return FALSE;
        end;
        for row = 0 to tile.valid_rows - 1 looplimit 65536 do
            var consumed = !_BundleExecutionMask.valid;
            if _BundleExecutionMask.valid then
                for column = 0 to _BundleExecutionMask.valid_columns - 1
                    looplimit 65536 do
                    if BundleExecutionMaskActiveAt(
                           tile.layout, row as integer {0..65535},
                           column as integer {0..65535}) then
                        consumed = TRUE;
                    end;
                end;
            end;
            if consumed then
                if !TileElementDefined(index, row as integer {0..65535}, 0) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535}, 0);
                if validate_encoding &&
                   !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    else
        if _BundleExecutionMask.valid &&
           tile.valid_columns != _BundleExecutionMask.valid_columns then
            return FALSE;
        end;
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            var consumed = !_BundleExecutionMask.valid;
            if _BundleExecutionMask.valid then
                for row = 0 to _BundleExecutionMask.valid_rows - 1
                    looplimit 65536 do
                    if BundleExecutionMaskActiveAt(
                           tile.layout, row as integer {0..65535},
                           column as integer {0..65535}) then
                        consumed = TRUE;
                    end;
                end;
            end;
            if consumed then
                if !TileElementDefined(index, 0,
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, 0, column as integer {0..65535});
                if validate_encoding &&
                   !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileExpansionBroadcastLegalAs(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType) => boolean
begin
    return TileExpansionBroadcastElementsLegalAs(
        index, axis, operation_type, TRUE);
end;

readonly func TileExpansionBroadcastNonzero(
    axis: TileAxis, source: TileIndex, broadcast: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let broadcast_row = if axis == TileAxis_Row then row else 0;
                let broadcast_column = if axis == TileAxis_Row then 0 else column;
                let element = TileLogicalLinearIndex(broadcast_tile,
                    broadcast_row as integer {0..65535},
                    broadcast_column as integer {0..65535});
                if !TileElementDefined(broadcast,
                       broadcast_row as integer {0..65535},
                       broadcast_column as integer {0..65535}) ||
                   IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if !TileReductionAndExpansionDescriptorLegal(left) ||
       !TileReductionAndExpansionDescriptorLegal(right) then
        return FALSE;
    end;
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.layout == right_tile.layout;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileReductionAndExpansionDescriptorLegal(destination) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           TileFillPadDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    if destination == source ||
       !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionSourceLegal(source) then
        return FALSE;
    end;

    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_reduction =
        operation == TileReduction_ARGMIN ||
        operation == TileReduction_ARGMAX;
    let source_type_legal =
        if index_reduction then
            TileArgReductionSourceDataTypeSupported(source_tile.data_type)
        else
            TileVecArithmeticDataTypeSupported(source_tile.data_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != source_tile.layout ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
           !source_type_legal then
        return FALSE;
    end;

    if index_reduction then
        if destination_tile.data_type != TileDataType_U32 then
            return FALSE;
        end;
    elsif destination_tile.data_type != source_tile.data_type then
        return FALSE;
    end;

    if axis == TileAxis_Row then
        if destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != 1 then
            return FALSE;
        end;
        if source_tile.layout == TileLayout_RowMajor then
            return destination_tile.rows == DerivedTileRows(
                       destination_tile.capacity_bytes, 1,
                       destination_tile.data_type) &&
                   destination_tile.columns == 1;
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
    if source_tile.layout == TileLayout_RowMajor then
        return destination_tile.rows == DerivedTileRows(
                   destination_tile.capacity_bytes, source_tile.columns,
                   destination_tile.data_type) &&
               destination_tile.columns == source_tile.columns;
    end;
    return destination_tile.rows == source_tile.rows &&
           destination_tile.columns == TileCubeStorageColumns(
               destination_tile.layout, source_tile.valid_columns,
               destination_tile.data_type);
end;

readonly func TileOperandsLegal_ExecuteTileExpandAs(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex,
    source_operation_type: TileDataType,
    destination_operation_type: TileDataType) => boolean
begin
    let copy = operation == TileExpand_COPY;
    let expdif = operation == TileExpand_EXPDIF;
    if !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionDescriptorLegal(source) ||
       !TileReductionAndExpansionDescriptorLegal(broadcast_source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       !TileVecArithmeticDataTypeSupported(destination_operation_type) ||
       destination_tile.data_type != destination_operation_type ||
       source_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.layout != destination_tile.layout ||
       source_tile.layout != destination_tile.layout then
        return FALSE;
    end;

    if copy then
        if source != broadcast_source ||
           !TileExpansionBroadcastElementsLegalAs(
               broadcast_source, axis, destination_operation_type, FALSE) then
            return FALSE;
        end;
    else
        if !TileReductionAndExpansionSourceLegalAs(
               source, source_operation_type) ||
           !TileExpansionBroadcastLegalAs(
               broadcast_source, axis, source_operation_type) then
            return FALSE;
        end;
    end;

    if (expdif && !TileExpdifTypePairLegal(
                      source_operation_type, destination_operation_type)) ||
       (!expdif && source_operation_type != destination_operation_type) then
        return FALSE;
    end;

    let broadcast_shape_legal = if axis == TileAxis_Row then
        broadcast_tile.valid_rows == destination_tile.valid_rows &&
        broadcast_tile.valid_columns >= 1
    else
        broadcast_tile.valid_rows >= 1 &&
        broadcast_tile.valid_columns == destination_tile.valid_columns;
    if !broadcast_shape_legal then return FALSE; end;

    if !copy &&
       !TileReductionAndExpansionLogicalShapeMatch(destination, source) then
        return FALSE;
    end;

    if operation == TileExpand_DIV &&
       TileDataTypeIsInteger(destination_operation_type) then
        return TileExpansionBroadcastNonzero(
            axis, source, broadcast_source);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex) => boolean
begin
    let expdif = operation == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(_Tiles[[destination]].data_type);
    if !operation_type_valid then return FALSE; end;
    let source_operation_type = if expdif && !BundleTileOperationSelected() then
        _Tiles[[source]].data_type else selected_type;
    let destination_operation_type = if expdif then
        _Tiles[[destination]].data_type else selected_type;
    return TileOperandsLegal_ExecuteTileExpandAs(
        operation, axis, destination, source, broadcast_source,
        source_operation_type, destination_operation_type);
end;
