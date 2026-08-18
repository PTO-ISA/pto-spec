// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION","surface":"tile","classification":["model","legality","reduction-and-expansion"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}

readonly func TileOperandsLegal_ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    if destination == source ||
       !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source) then
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
        else if operation == TileReduction_PRODUCT then
            TileA7DataTypeSupported(source_tile.data_type)
        else
            TileA9DataTypeSupported(source_tile.data_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != TileLayout_RowMajor ||
       source_tile.layout != TileLayout_RowMajor ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
       !source_type_legal ||
       !TileSourceEncodingsValid(source) then
        return FALSE;
    end;

    if index_reduction then
        if destination_tile.data_type != TileDataType_S32 &&
           destination_tile.data_type != TileDataType_U32 then
            return FALSE;
        end;
    elsif destination_tile.data_type != source_tile.data_type then
        return FALSE;
    end;

    if axis == TileAxis_Row then
        return destination_tile.rows >= source_tile.valid_rows &&
               destination_tile.columns == 1 &&
               destination_tile.valid_rows == source_tile.valid_rows &&
               destination_tile.valid_columns == 1;
    end;
    return destination_tile.rows >= 1 &&
           destination_tile.columns == source_tile.columns &&
           destination_tile.valid_rows == 1 &&
           destination_tile.valid_columns ==
               source_tile.valid_columns;
end;

pure func TileExpandExpdifTypePairLegal(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return (source_type == TileDataType_FP16 &&
            (destination_type == TileDataType_FP16 ||
             destination_type == TileDataType_FP32)) ||
           (source_type == TileDataType_BF16 &&
            (destination_type == TileDataType_BF16 ||
             destination_type == TileDataType_FP32)) ||
           (source_type == TileDataType_FP32 &&
            destination_type == TileDataType_FP32);
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(broadcast_source) then
        return FALSE;
    end;

    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    let expdif = operation == TileExpand_EXPDIF;
    let operation_type_legal =
        if operation == TileExpand_COPY then
            TileCarrierOnlyDataTypeSupported(destination_tile.data_type)
        else if expdif then
            TileExpandExpdifTypePairLegal(
                source_tile.data_type,
                destination_tile.data_type)
        else if operation == TileExpand_ADD ||
           operation == TileExpand_SUB ||
           operation == TileExpand_MAX ||
           operation == TileExpand_MIN then
            TileA9DataTypeSupported(destination_tile.data_type)
        else if operation == TileExpand_MUL ||
              operation == TileExpand_DIV then
            TileA7DataTypeSupported(destination_tile.data_type)
        else
            TileVecArithmeticDataTypeSupported(destination_tile.data_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != TileLayout_RowMajor ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       !operation_type_legal ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.data_type !=
           (if expdif then source_tile.data_type
            else destination_tile.data_type) ||
       broadcast_tile.layout != TileLayout_RowMajor ||
       !TileSourceContentsDefined(broadcast_source) ||
       (operation != TileExpand_COPY &&
        !TileSourceEncodingsValid(broadcast_source)) then
        return FALSE;
    end;

    if operation == TileExpand_COPY then
        if source != broadcast_source then
            return FALSE;
        end;
    elsif (if expdif then !TileLogicalShapeMatch(destination, source)
           else !TileShapeAndTypeMatch(destination, source)) ||
          source_tile.storage_kind != TileStorage_Numeric ||
          source_tile.layout != TileLayout_RowMajor ||
          !TileSourceContentsDefined(source) ||
          (operation != TileExpand_COPY &&
           !TileSourceEncodingsValid(source)) then
        return FALSE;
    end;

    let broadcast_shape_legal =
        if axis == TileAxis_Row then
            broadcast_tile.valid_rows == destination_tile.valid_rows &&
            broadcast_tile.valid_columns == 1 &&
            broadcast_tile.columns == 1
        else
            broadcast_tile.valid_rows == 1 &&
            broadcast_tile.valid_columns ==
                destination_tile.valid_columns &&
            broadcast_tile.columns == destination_tile.columns;
    if !broadcast_shape_legal then
        return FALSE;
    end;

    if operation == TileExpand_DIV &&
       TileDataTypeIsInteger(destination_tile.data_type) then
        return TileBroadcastPayloadNonzero(
            axis,
            source,
            broadcast_source);
    end;
    return TRUE;
end;
