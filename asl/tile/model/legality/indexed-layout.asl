// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
readonly func TileOperandsLegal_ExecuteTilePartial(
    op: TilePartialOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    return TilePartialCoverageLegal(destination, source_left, source_right) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type;
end;

readonly func TileOperandsLegal_TFMA(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, addend: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(source_left) &&
           TileSourceContentsDefined(source_right) &&
           TileSourceContentsDefined(addend) &&
           TileLogicalShapeMatch(destination, source_left) &&
           TileLogicalShapeMatch(destination, source_right) &&
           TileLogicalShapeMatch(destination, addend) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[addend]].data_type;
end;

readonly func TileOperandsLegal_ExecuteTilePartialArg(
    maximum: boolean, destination: TileIndex, destination_indices: TileIndex,
    source_left: TileIndex, source_right: TileIndex,
    left_indices: TileIndex, right_indices: TileIndex) => boolean
begin
    if destination == destination_indices then return FALSE; end;
    return TilePartialCoverageLegal(destination, source_left, source_right) &&
           TileDescriptorLegal(destination_indices) &&
           TileLogicalShapeMatch(destination_indices, destination) &&
           TileLogicalShapeMatch(left_indices, source_left) &&
           TileLogicalShapeMatch(right_indices, source_right) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type;
end;

readonly func TileOperandsLegal_TSORT(destination: TileIndex,
                                      destination_indices: TileIndex,
                                      source: TileIndex,
                                      sort_width: integer {1..64},
                                      descending: boolean) => boolean
begin
    return destination != destination_indices &&
           TileDescriptorLegal(destination) &&
           TileDescriptorLegal(destination_indices) &&
           TileSourceContentsDefined(source) &&
           _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns ==
               _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination_indices]].valid_rows *
               _Tiles[[destination_indices]].valid_columns ==
               _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination_indices]].data_type == TileDataType_U32;
end;

readonly func TileOperandsLegal_THISTOGRAM(
    destination: TileIndex, source: TileIndex, indices: TileIndex,
    selected_byte: integer {0..3}) => boolean
begin
    if !TileDescriptorLegal(destination) || !TileDescriptorLegal(source) ||
       !TileDescriptorLegal(indices) ||
       _Tiles[[destination]].valid_rows != _Tiles[[source]].valid_rows ||
       _Tiles[[destination]].valid_columns < 256 ||
       !(_Tiles[[source]].data_type == TileDataType_U16 ||
         _Tiles[[source]].data_type == TileDataType_U32) then return FALSE; end;
    if _Tiles[[source]].data_type == TileDataType_U16 then
        if selected_byte > 1 then return FALSE; end;
        return selected_byte == 1 ||
               (_Tiles[[indices]].valid_rows >= _Tiles[[source]].valid_rows &&
                _Tiles[[indices]].valid_columns >= 1);
    else
        let required_rows: integer = if selected_byte == 0 then 3 else
                                     if selected_byte == 1 then 2 else
                                     if selected_byte == 2 then 1 else 0;
        return _Tiles[[indices]].valid_rows >= required_rows &&
               (required_rows == 0 || _Tiles[[indices]].valid_columns >= 1);
    end;
end;

readonly func TileOperandsLegal_GMOV(
    destination: TileIndex, source: TileIndex, peer_tid: Word) => boolean
begin
    return UInt(peer_tid) < 4 &&
           TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(source) &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout &&
           _Tiles[[destination]].location != TileLocation_Memory &&
           _Tiles[[destination]].location != TileLocation_Matrix &&
           _Tiles[[source]].location != TileLocation_Memory &&
           _Tiles[[source]].location != TileLocation_Matrix;
end;

readonly func TileOperandsLegal_TMRGSORT(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, descending: boolean) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) then return FALSE; end;
    let left_extent: integer =
        _Tiles[[source_left]].valid_rows * _Tiles[[source_left]].valid_columns;
    let right_extent: integer =
        _Tiles[[source_right]].valid_rows * _Tiles[[source_right]].valid_columns;
    return _Tiles[[destination]].valid_rows *
               _Tiles[[destination]].valid_columns == left_extent + right_extent &&
           _Tiles[[source_left]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type;
end;
