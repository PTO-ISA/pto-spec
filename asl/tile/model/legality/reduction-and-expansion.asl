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
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != TileLayout_RowMajor ||
       source_tile.layout != TileLayout_RowMajor ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
       !TileVecArithmeticDataTypeSupported(source_tile.data_type) ||
       !TileSourceEncodingsValid(source) then
        return FALSE;
    end;

    let index_reduction =
        operation == TileReduction_ARGMIN ||
        operation == TileReduction_ARGMAX;
    if index_reduction then
        if destination_tile.data_type != TileDataType_U32 then
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
    if destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != TileLayout_RowMajor ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       !TileVecArithmeticDataTypeSupported(destination_tile.data_type) ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.data_type != destination_tile.data_type ||
       broadcast_tile.layout != TileLayout_RowMajor ||
       !TileSourceContentsDefined(broadcast_source) ||
       !TileSourceEncodingsValid(broadcast_source) then
        return FALSE;
    end;

    if operation == TileExpand_EXPDIF &&
       !TileUnaryDataTypeSupported(
           TileUnary_EXP,
           destination_tile.data_type) then
        return FALSE;
    end;

    if operation == TileExpand_COPY then
        if source != broadcast_source then
            return FALSE;
        end;
    elsif !TileShapeAndTypeMatch(destination, source) ||
          source_tile.storage_kind != TileStorage_Numeric ||
          source_tile.layout != TileLayout_RowMajor ||
          !TileSourceContentsDefined(source) ||
          !TileSourceEncodingsValid(source) then
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
